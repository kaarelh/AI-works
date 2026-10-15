"""e2: Monte Carlo of Eisenstat's example with computable proxies (track notes §3.8).

For each horizon n and each seeded run we report, in bits:
  * SFIproxy : exact -log2 of the x-only mixture (iid-Laplace + threshold families,
               threshold s ~ 1/((s+1)(s+2)), Laplace bias), order-free;
  * UB       : -log2 P_{1/3}(b_{<tau_n}) = the 'threshold function' loss of Prop 3.2;
  * BayesX   : -log2 P(D_n | S_n), the exact conditional surprisal of the labels
               given the revealed domain (lower bound for every x-only predictor in
               expectation, Prop 3.7);
  * iid13    : loss of the i.i.d. Bern(1/3) hypothesis;  iidLap: Laplace i.i.d.;
  * Pstar    : loss of the Bayes history-aware predictor P*;
  * SIproxy  : label loss of a Bayes mixture of three joint models of the
               interleaved sequence (true process / true inputs + Laplace labels / null).
Theory: E[UB] = n h(1/3)/2 = 0.459148 n; Var(UB) ~ 1.04966 n; E[iid13] = (log2 3 - 1/3) n;
E[Pstar over all time] = 3 kappa = 2.39855.

Seed 20261011; output in e2_eisenstat_sim.out.txt.
"""
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..", "..", "..", "code")))
import sfi_examples as se  # noqa: E402

OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def main():
    t0 = time.time()
    rng = np.random.default_rng(20261011)
    say("e2_eisenstat_sim.py  seed=20261011")
    say(f"h(1/3)/2 = {se.H13/2:.6f};  log2(3) - 1/3 = {se.LOG2_3 - 1/3:.6f};  3*kappa = {3*se.kappa_touching():.5f}")
    say("")
    hdr = ("   n  runs | SFIproxy/n   UB/n    BayesX/n  iid13/n  iidLap/n | sd(UB)/sqrt(n) | "
           "SFIproxy-UB: mean  [min,max] | UB-BayesX: mean [min,max] | Pstar mean  SIproxy mean  touch")
    say(hdr)
    rows = []
    for n, R in [(100, 400), (300, 300), (1000, 200), (3000, 100), (10000, 40)]:
        vals = {k: [] for k in ["sfi", "ub", "bx", "iid13", "iidlap", "pstar", "si", "touch", "tau", "T"]}
        for _ in range(R):
            res = se.simulate_eisenstat(n, rng)
            st = res["state"]
            mix = se.threshold_mixture_loss(res["xs"], res["ys"])
            vals["sfi"].append(mix["loss"])
            vals["ub"].append(se.threshold_cost_13(st))
            vals["bx"].append(se.bayes_xonly_surprisal(st))
            vals["iid13"].append(se.iid13_cost(st))
            vals["iidlap"].append(mix["iid_laplace"])
            vals["pstar"].append(res["pstar_losses"].sum())
            vals["si"].append(res["si_label_losses"].sum())
            vals["touch"].append(res["touching_steps"])
            vals["tau"].append(st.tau)
            vals["T"].append(st.n_tails)
        v = {k: np.array(x, dtype=float) for k, x in vals.items()}
        d1 = v["sfi"] - v["ub"]
        d2 = v["ub"] - v["bx"]
        say(f"{n:5d} {R:5d} | {v['sfi'].mean()/n:9.4f} {v['ub'].mean()/n:8.4f} {v['bx'].mean()/n:9.4f} "
            f"{v['iid13'].mean()/n:8.4f} {v['iidlap'].mean()/n:8.4f} | {v['ub'].std()/math.sqrt(n):8.4f}       | "
            f"{d1.mean():7.2f} [{d1.min():6.2f},{d1.max():6.2f}] | {d2.mean():6.2f} [{d2.min():6.2f},{d2.max():6.2f}] | "
            f"{v['pstar'].mean():6.3f}  {v['si'].mean():8.3f}  {v['touch'].mean():5.2f}")
        rows.append((n, v))
    say("")
    say("Standard errors of the means (bits/n) at each n: UB/n, SFIproxy/n")
    for n, v in rows:
        R = len(v["ub"])
        say(f"  n={n:5d}: se(UB/n) = {v['ub'].std()/n/math.sqrt(R):.5f}, se(SFIproxy/n) = {v['sfi'].std()/n/math.sqrt(R):.5f};"
            f" mean tau/n = {v['tau'].mean()/n:.4f}, mean T/n = {v['T'].mean()/n:.4f}")
    say("")
    say("Max over runs of Pstar and SIproxy label loss (bits); SIproxy - Pstar")
    for n, v in rows:
        dd = v["si"] - v["pstar"]
        say(f"  n={n:5d}: max Pstar = {v['pstar'].max():.3f}, max SIproxy = {v['si'].max():.3f}, "
            f"SIproxy-Pstar: mean {dd.mean():.3f}, max {dd.max():.3f}")
    say("")
    # A learning curve for one run: cumulative losses at checkpoints (order-free SFI proxy)
    rng2 = np.random.default_rng(7)
    n = 20000
    res = se.simulate_eisenstat(n, rng2)
    xs, ys = res["xs"], res["ys"]
    say("One run (seed 7), n = 20000: cumulative losses at checkpoints t")
    say("      t |  SFIproxy   SFIproxy/t   UB(t)/t   iid13(t)/t | Pstar(t)  SIproxy(t)")
    st = se.EisenstatState()
    cps = [10, 30, 100, 300, 1000, 3000, 10000, 20000]
    ptr = 0
    for cp in cps:
        while ptr < cp:
            st.add(int(xs[ptr]), int(ys[ptr]))
            ptr += 1
        mix = se.threshold_mixture_loss(xs[:cp], ys[:cp])
        say(f"  {cp:6d} | {mix['loss']:9.2f}  {mix['loss']/cp:9.4f}  {se.threshold_cost_13(st)/cp:9.4f}  "
            f"{se.iid13_cost(st)/cp:9.4f}  | {res['pstar_losses'][:cp].sum():7.3f}  {res['si_label_losses'][:cp].sum():8.3f}")
    # Order independence of the SFI proxy: shuffle the reveal order of the final data set
    perm = np.random.default_rng(11).permutation(n)
    a = se.threshold_mixture_loss(xs, ys)["loss"]
    b = se.threshold_mixture_loss(xs[perm], ys[perm])["loss"]
    say(f"Order independence: SFIproxy loss on reveal order {a:.6f}, on a shuffled order {b:.6f}")
    # The brief's literal rule: "the new input is a tail iff it equals the smallest unrevealed index"
    rng3 = np.random.default_rng(20261012)
    errs, last_err = [], []
    for _ in range(1000):
        res = se.simulate_eisenstat(1000, rng3)
        st = se.EisenstatState()
        e, last = 0, 0
        for t, (x, y) in enumerate(zip(res["xs"], res["ys"]), start=1):
            pred = 0 if int(x) == st.g else 1
            if pred != int(y):
                e += 1
                last = t
            st.add(int(x), int(y))
        errs.append(e)
        last_err.append(last)
    errs = np.array(errs)
    last_err = np.array(last_err)
    say("")
    say("Brief's rule 'tail iff x_t = smallest unrevealed index' (1000 runs, n = 1000, seed 20261012):")
    say(f"  errors per run: mean {errs.mean():.3f}, max {errs.max()}, P(no error) = {np.mean(errs==0):.3f}; "
        f"step of last error: median {np.median(last_err[errs>0]):.0f}, 99th pct {np.percentile(last_err[errs>0], 99):.0f}, "
        f"max {last_err.max()}")
    say(f"(runtime {time.time()-t0:.1f} s)")
    with open(os.path.join(HERE, "e2_eisenstat_sim.out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
