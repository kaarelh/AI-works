"""Scaling of the SMC lower bound with the input dimension d (no exact p).

Trains MLPs to output 1 (nets.train_constant) at d in DIMS, keeps snapshots
whose failure z-score lies in [3.5, 6.5] (or --z), and for each:
  * a reference estimate p_ref: the mean of R_REF independent fixed-plan SMC
    replicates (an unbiased estimator of p; its standard error is reported),
    cross-checked by plain Monte Carlo when p_ref is large enough;
  * TRIALS runs of nets_lower.lower_bound at budgets S, M, L, with the ratio
    lower / p_ref and the cost.

usage: python3 run_scaling.py [--z zmin zmax] [--arch loss:w1xw2:lr] [d ...]  |  run_scaling.py --suite   (writes results/scaling.jsonl, nets in results/scaling_nets/)
"""

import json
import math
import os
import sys
import time

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, train_constant  # noqa: E402
from rareprob.nets_lower import (Evaluator, lower_bound, mc_lower_samples, pilot_plan,  # noqa: E402
                                 random_cube, run_smc)

OUT = os.path.join(HERE, "results")
NETDIR = os.path.join(OUT, "scaling_nets")
os.makedirs(NETDIR, exist_ok=True)
DELTA = 0.05
DIMS = [32, 48, 64, 96, 128]
STEPS = (300, 600, 1000, 1500, 2000, 3000, 4000)
BUDGETS = {"S": (300, 32, 10, 0.2), "M": (1000, 32, 10, 0.2), "L": (3000, 64, 10, 0.2)}
TRIALS = 3
R_REF = 100
N_REF = 3000
ZMIN, ZMAX = 3.5, 6.5


def zscore(net, rng, n=200000):
    f = net.forward(random_cube(rng, n, net.d))
    return float((f.mean() - net.threshold) / f.std())


def save(net, path):
    np.savez(path, **{f"W{i}": W for i, W in enumerate(net.Ws)}, **{f"b{i}": b for i, b in enumerate(net.bs)},
             threshold=net.threshold, loss=net.loss)


def monte_carlo(net, n, rng, block=1 << 18):
    hits = 0
    done = 0
    while done < n:
        k = min(block, n - done)
        hits += int((net.forward(random_cube(rng, k, net.d)) < net.threshold).sum())
        done += k
    return hits, n


def main():
    global ZMIN, ZMAX
    args = sys.argv[1:]
    if args == ["--suite"]:
        suite_nets(os.path.join(OUT, "scaling.jsonl"))
        return
    if "--z" in args:  # --z zmin zmax: the window of z-scores kept
        i = args.index("--z")
        ZMIN, ZMAX = float(args[i + 1]), float(args[i + 2])
        args = args[:i] + args[i + 3:]
    archs = [("mse", [64], 1e-3)]
    if "--arch" in args:  # --arch loss:w1xw2:lr, e.g. bce:32x32:3e-4
        i = args.index("--arch")
        loss, ws, lr = args[i + 1].split(":")
        archs = [(loss, [int(w) for w in ws.split("x")], float(lr))]
        args = args[:i] + args[i + 2:]
    dims = [int(a) for a in args] or DIMS
    path = os.path.join(OUT, "scaling.jsonl")
    extra = (ZMIN, ZMAX) != (3.5, 6.5)  # a second family of nets (own seed and name prefix)
    off = 0 if archs == [("mse", [64], 1e-3)] else 100 + 7 * len(archs[0][1]) + (archs[0][0] == "bce")
    rng = np.random.default_rng((4243 if extra else 4242) + off)
    for d in dims:
        for loss, widths, lr in archs:
            tag = ("z_" if extra else "") + f"{loss}_d{d}_w{'x'.join(map(str, widths))}"
            _, snaps = train_constant(d, widths, max(STEPS), rng, loss=loss, lr=lr, snapshots=STEPS)
            for st in STEPS:
                net = snaps[st]
                z = zscore(net, rng)
                if not ZMIN <= z <= ZMAX or os.path.exists(os.path.join(NETDIR, f"{tag}_s{st}.npz")):
                    print(f"{tag}_s{st}: z={z:.2f} skipped", flush=True)
                    continue
                name = f"{tag}_s{st}"
                save(net, os.path.join(NETDIR, name + ".npz"))
                evaluate(net, name, d, loss, widths, st, z, rng, path)


def evaluate(net, name, d, loss, widths, st, z, rng, path):
    """Reference estimate (and Monte Carlo check), then lower bounds at every budget."""
    # reference estimate
    t0 = time.time()
    ev = Evaluator(net)
    pil = pilot_plan(ev, N_REF, 0.2, 10, rng)
    Zref = np.array([run_smc(ev, pil.plan, rng).Z for _ in range(R_REF)])
    p_ref = float(Zref.mean())
    se = float(Zref.std(ddof=1) / math.sqrt(R_REF))
    ref = dict(name=name, d=d, widths=widths, loss=loss, step=st, z=z, p_ref=p_ref, p_ref_se=se,
               ref_relvar=float(Zref.var() / max(p_ref, 1e-300) ** 2), ref_evals=ev.evals,
               ref_K=len(pil.plan.levels), ref_seconds=round(time.time() - t0, 1))
    if p_ref > 2e-6:
        nmc = int(min(2e8, 400 / p_ref))
        t1 = time.time()
        h, n = monte_carlo(net, nmc, rng)
        ref.update(mc_hits=h, mc_n=n, p_mc=h / n, mc_seconds=round(time.time() - t1, 1))
    print(json.dumps(ref), flush=True)
    with open(path, "a") as f:
        f.write(json.dumps(dict(kind="ref", **ref)) + "\n")
    if p_ref == 0:  # no failure found by the reference run: nothing to compare with
        return
    for b, (N, R, moves, rho) in BUDGETS.items():
        for trial in range(TRIALS):
            t = time.time()
            res = lower_bound(net, delta=DELTA, N=N, R=R, moves=moves, rho=rho, rng=rng)
            evals = res.evals_pilot + res.evals_final
            r = res.smc_lower / p_ref
            out = dict(kind="lb", name=name, d=d, loss=loss, widths=widths, step=st, z=z, p_ref=p_ref,
                       budget=b, trial=trial, K=len(res.plan.levels), evals=evals, evals_final=res.evals_final,
                       L_bet=res.smc_lower, r_bet=r, r_clip=res.clipped_lower / p_ref,
                       r_min=res.minmarkov_lower / p_ref, L_wit=res.witness_lower,
                       Z_over_pref=[x / p_ref for x in res.Z],
                       mc_samples_same_ratio=mc_lower_samples(p_ref, min(r, 0.999), DELTA) if r > 0 else 0,
                       seconds=round(time.time() - t, 1))
            out["speedup_vs_mc"] = out["mc_samples_same_ratio"] / evals
            with open(path, "a") as f:
                f.write(json.dumps(out) + "\n")
            print(f"{name} z={z:.2f} p_ref={p_ref:.3g} {b} t{trial} r_bet={r:.3f} evals={evals:.3g} "
                  f"x{out['speedup_vs_mc']:.1f} {out['seconds']}s", flush=True)


def suite_nets(path):
    """The nets of experiments/nets without an exact p (named suite_<name>)."""
    suite = json.load(open(os.path.join(HERE, "..", "nets", "suite.json")))
    done = set()
    if os.path.exists(path):
        done = {json.loads(l)["name"] for l in open(path)}
    rng = np.random.default_rng(777)
    for row in suite:
        name = "suite_" + row["name"]
        if "p_exact" in row or name in done:
            continue
        net = load_net(os.path.join(HERE, "..", "nets", row["name"] + ".npz"))
        evaluate(net, name, row["d"], row["loss"], row["widths"], row["step"], row["z"], rng, path)

if __name__ == "__main__":
    main()
