"""SMC lower bounds at d = 32 ... 128, where p is not known exactly: this lane's
own nets (results/scaling_nets/smc_*, smc2_*; set "smc") and the suite's d =
64 and 128 nets (experiments/nets; set "suite").

Phase "ref", one job per net: a reference estimate p_ref = the mean of R_REF
independent fixed-plan SMC replicates (N = 3000; an unbiased estimator of
D(A_K) <= p, with its standard error), the betting lower bound from those
same replicates, the number of certified witnesses, and plain Monte Carlo
when p_ref > 2e-6 (min(2e8, 400 / p_ref) samples).

Phase "lb", for every net with p_ref > 0: TRIALS runs of
nets_lower.lower_bound at budgets S, M, L (ratios are taken against p_ref
in summarize.py).

usage: python3 run_scaling.py [--jobs J] [--set smc|suite] [--phase ref|lb] [name-substring ...]
       (appends to results/scaling.jsonl)
"""

import math
import os
import sys
import time

from common import (BUDGETS, DELTA, MOVES, RES, RHO, get_net, jobs_arg, lane_nets, large_suite, load_rows,
                    mc_seconds_per_sample, run_parallel, seed_of)
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets_lower import Evaluator, Witnesses, betting_lower, lower_bound, pilot_plan, random_cube, run_smc

PATH = os.path.join(RES, "scaling.jsonl")
TRIALS = 3
R_REF = 100
N_REF = 3000


def nets(which):
    out = []
    if which in (None, "smc"):
        out += [dict(set="smc", **{k: r[k] for k in ("name", "d", "widths", "loss", "step", "z")}) for r in lane_nets()]
    if which in (None, "suite"):
        out += [dict(set="suite", **{k: r[k] for k in ("name", "d", "widths", "loss", "step", "z")})
                for r in large_suite()]
    return out


def monte_carlo(net, n, rng, block=1 << 16):
    hits = done = 0
    while done < n:
        k = min(block, n - done)
        hits += int((net.forward(random_cube(rng, k, net.d)) < net.threshold).sum())
        done += k
    return hits


def ref_job(meta):
    net = get_net(meta["name"])
    rng = np.random.default_rng(seed_of("ref", meta["name"]))
    mc_sec = mc_seconds_per_sample(net)
    t0 = time.time()
    ev = Evaluator(net)
    W = Witnesses(ev)
    pil = pilot_plan(ev, N_REF, RHO, MOVES, rng, W)
    reps = [run_smc(ev, pil.plan, rng, W) for _ in range(R_REF)]
    Z = np.array([r.Z for r in reps])
    p_ref = float(Z.mean())
    out = dict(kind="ref", **meta, p_ref=p_ref, p_ref_se=float(Z.std(ddof=1) / math.sqrt(R_REF)),
               ref_relvar=float(Z.var() / p_ref ** 2) if p_ref > 0 else None, ref_R=R_REF, ref_N=N_REF,
               ref_evals=ev.evals, ref_K=len(pil.plan.levels), ref_seconds=round(time.time() - t0, 1),
               ref_pilot_log10Z=pil.log10Z, ref_L_bet=betting_lower(Z, DELTA), ref_witnesses=W.count,
               ref_L_wit=W.lower(), ref_flagged=sum(r.flagged for r in reps), E=ev.E, mc_sec_per_sample=mc_sec,
               Z=Z.tolist())
    if p_ref > 2e-6:
        n = int(min(2e8, 400 / p_ref))
        t1 = time.time()
        h = monte_carlo(net, n, rng)
        out.update(mc_hits=h, mc_n=n, p_mc=h / n, mc_seconds=round(time.time() - t1, 1))
    return out


def lb_job(args):
    meta, budget, trial = args
    N, R = BUDGETS[budget]
    net = get_net(meta["name"])
    mc_sec = mc_seconds_per_sample(net)
    seed = seed_of("lb", meta["name"], budget, trial)
    t = time.time()
    res = lower_bound(net, delta=DELTA, N=N, R=R, moves=MOVES, rho=RHO, rng=np.random.default_rng(seed))
    return dict(kind="lb", **meta, budget=budget, N=N, R=R, trial=trial, seed=seed, K=len(res.plan.levels),
                flips=res.plan.flips, evals_pilot=res.evals_pilot, evals_final=res.evals_final, evals=res.evals,
                seconds=round(time.time() - t, 2), seconds_pilot=round(res.seconds_pilot, 2),
                mc_sec_per_sample=mc_sec, flagged=res.flagged, pilot_log10Z=res.pilot_log10Z, L=res.lower,
                L_bet=res.smc_lower, L_wit=res.witness_lower, n_wit=round(res.witness_lower * 2.0 ** net.d), Z=res.Z)


def show(r):
    if r["kind"] == "ref":
        mc = f" p_mc={r['p_mc']:.3g} ({r['mc_hits']}/{r['mc_n']:.2g})" if "p_mc" in r else ""
        return (f"REF {r['name']} z={r['z']:.2f} p_ref={r['p_ref']:.3g} +- {r['p_ref_se']:.2g} K={r['ref_K']} "
                f"L_bet={r['ref_L_bet']:.3g} witnesses={r['ref_witnesses']} evals={r['ref_evals']:.3g} "
                f"{r['ref_seconds']}s{mc}")
    return (f"LB {r['name']} {r['budget']} t{r['trial']} L_bet={r['L_bet']:.3g} wit={r['n_wit']} "
            f"evals={r['evals']:.3g} {r['seconds']}s")


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args)
    which = phase = None
    if "--set" in args:
        i = args.index("--set")
        which = args[i + 1]
        del args[i:i + 2]
    if "--phase" in args:
        i = args.index("--phase")
        phase = args[i + 1]
        del args[i:i + 2]
    todo = [m for m in nets(which) if not args or any(q in m["name"] for q in args)]
    if phase in (None, "ref"):
        done = {r["name"] for r in load_rows(PATH) if r["kind"] == "ref"}
        # the largest nets first, so that the pool stays busy
        jobs = sorted([m for m in todo if m["name"] not in done], key=lambda m: -m["d"] * sum(m["widths"]))
        run_parallel(ref_job, jobs, PATH, n_jobs, show)
    if phase in (None, "lb"):
        rows = load_rows(PATH)
        refs = {r["name"]: r for r in rows if r["kind"] == "ref"}
        done = {(r["name"], r["budget"], r["trial"]) for r in rows if r["kind"] == "lb"}
        jobs = [(m, b, t) for b in ("L", "M", "S") for m in todo for t in range(TRIALS)
                if m["name"] in refs and refs[m["name"]]["p_ref"] > 0 and (m["name"], b, t) not in done]
        jobs.sort(key=lambda j: -(j[0]["d"] * sum(j[0]["widths"])) * BUDGETS[j[1]][0] * BUDGETS[j[1]][1])
        run_parallel(lb_job, jobs, PATH, n_jobs, show)


if __name__ == "__main__":
    main()
