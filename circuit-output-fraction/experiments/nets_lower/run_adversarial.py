"""Soundness on nets that were not trained (adversarial_nets.py).

Parts (all write to results/adversarial.jsonl, one "kind" each):
  planted   hidden failure sets: a visible Hamming ball plus a hidden subcube
            (d = 24 and d = 40), and a single needle (d = 24). The bound must
            stay below p; it can only see the ball.
  random    coverage on random untrained nets (He init, output bias shifted so
            that p is about 1e-6 .. 1e-3, d = 20, exact p): 10 runs each at
            delta = 0.05 and 0.3.
  float     the float64 attacks of the red-team review (gradual underflow,
            FMA order, overflow; exact-real p = 0, or 1/2 for the overflow
            net): 5 runs each; every bound must be <= p.
  campaign  the red-team coverage campaign rerun on the fixed code: 9
            adversarial shapes x 5 tiny-budget configurations x delta in
            {0.2, 0.5} x RUNS runs; miss rates of the reported bound, of the
            SMC part and of the witness bound.

usage: python3 run_adversarial.py [--jobs J] [planted] [random] [float] [campaign]
"""

import os
import sys

from common import RES, jobs_arg, run_parallel, seed_of
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
import adversarial_nets as A  # noqa: E402
from rareprob.nets import init_mlp  # noqa: E402
from rareprob.nets_lower import lower_bound, random_cube  # noqa: E402

PATH = os.path.join(RES, "adversarial.jsonl")
RUNS = 150
CONFIGS = {
    "R4_N50": dict(N=50, R=4, moves=2, rho=0.3),
    "R2_N30": dict(N=30, R=2, moves=1, rho=0.3),
    "R8_N100_stratified": dict(N=100, R=8, moves=2, rho=0.3, stratify=True),
    "R8_N50_untuned_2flips": dict(N=50, R=8, moves=1, rho=0.3, tune=False, fixed_flips=2),
    "sequential_N50": dict(N=50, R=64, moves=2, rho=0.3, target_ratio=0.9, min_R=2),
}


def run_row(kind, case, net, p, rng, delta=0.05, **kw):
    res = lower_bound(net, delta=delta, rng=rng, **kw)
    return dict(kind=kind, case=case, d=net.d, p_exact=p, L=res.lower, L_bet=res.smc_lower, L_wit=res.witness_lower,
                ratio=res.lower / p if p > 0 else None, point_estimate=float(np.mean(res.Z)) if res.Z else 0.0,
                miss=bool(res.lower > p), flagged=res.flagged, evals=res.evals, K=len(res.plan.levels),
                seconds=round(res.seconds, 2))


def planted_job(case):
    rng = np.random.default_rng(seed_of("planted", case))
    if case == "hidden_d40_k26":
        net, p, p_vis = A.hidden_d40(np.random.default_rng(7))
        rows = [run_row("planted", case, net, p, rng, N=1000, R=32) for _ in range(5)]
        for r in rows:
            r["p_visible"] = p_vis
        return rows
    net = A.planted(24, 8, 14, rng) if case == "hidden_k14_ball" else A.planted(24, 8, 24, rng, ball=False)
    p = A.exact_p(net)
    return [run_row("planted", case, net, p, rng, N=1000, R=32) for _ in range(5 if case == "hidden_k14_ball" else 3)]


def random_job(i):
    rng = np.random.default_rng(seed_of("random", i))
    d = 20
    net = init_mlp(d, [32], rng)
    f = net.forward(random_cube(rng, 200000, d))
    target = 10 ** rng.uniform(-6, -3)
    net.bs[-1] = net.bs[-1] + (0.5 - np.quantile(f, min(0.5, target * 3)))
    p = A.exact_p(net)
    if p == 0:
        return []
    rows = []
    for delta in (0.05, 0.3):
        for run in range(10):
            r = run_row("random", f"random_{i}", net, p, rng, delta=delta, N=300, R=16)
            r.update(delta=delta, run=run)
            rows.append(r)
    return rows


def float_job(case):
    make, p = A.FLOAT_ATTACKS[case]
    net = make()
    rng = np.random.default_rng(seed_of("float", case))
    kw = dict(N=1000, R=32) if net.d >= 40 else dict(N=200, R=16)
    return [run_row("float", case, net, p, rng, **kw) for _ in range(5)]


def campaign_job(args):
    name, cfg, delta = args
    net = A.ADVERSARIAL[name]()
    p = A.exact_p(net)
    rng = np.random.default_rng(seed_of("campaign", name, cfg, delta))
    miss = dict(lower=0, smc=0, wit=0)
    flagged = ratio = 0.0
    for _ in range(RUNS):
        r = lower_bound(net, delta=delta, rng=rng, **CONFIGS[cfg])
        miss["lower"] += r.lower > p
        miss["smc"] += r.notes["stratum"] + r.smc_lower > p
        miss["wit"] += r.witness_lower > p
        flagged += r.flagged / max(1, len(r.Z))
        ratio += r.lower / p if p > 0 else 0.0
    return dict(kind="campaign", net=name, d=net.d, p_exact=p, config=cfg, delta=delta, runs=RUNS,
                miss_lower=miss["lower"] / RUNS, miss_smc=miss["smc"] / RUNS, miss_witness=miss["wit"] / RUNS,
                flagged_fraction=flagged / RUNS, mean_ratio=ratio / RUNS if p > 0 else None)


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args)
    parts = args or ["planted", "random", "float", "campaign"]
    if "float" in parts:
        run_parallel(float_job, list(A.FLOAT_ATTACKS), PATH, n_jobs)
    if "planted" in parts:
        run_parallel(planted_job, ["hidden_k14_ball", "needle_k24", "hidden_d40_k26"], PATH, n_jobs)
    if "random" in parts:
        run_parallel(random_job, list(range(20)), PATH, n_jobs, lambda r: f"{r['case']} delta={r['delta']} "
                     f"ratio={r['ratio']:.3f} miss={r['miss']}")
    if "campaign" in parts:
        jobs = [(n, c, dl) for n in A.ADVERSARIAL for c in CONFIGS for dl in (0.5, 0.2)]
        run_parallel(campaign_job, jobs, PATH, n_jobs)


if __name__ == "__main__":
    main()
