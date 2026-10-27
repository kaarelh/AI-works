"""Soundness on nets that were not trained: planted failures and random nets.

1. hidden: f = c - a1 relu(<x,u> - (d - 2m)) / (2m) - relu(<x_S, b> - (k - 1)) + small random units.
   Failures: a Hamming ball around u (visible: f decreases towards it) and
   the subcube {x_S = b} (hidden: f is flat outside it). The SMC lower bound
   must stay below p; it can only see the ball.
2. needle: only the subcube with k = d (one failing point).
3. coverage: random untrained nets (He init, output bias shifted so that p is
   about 1e-3 .. 1e-6) at d = 20 with exact p; many runs at delta = 0.05 and
   at delta = 0.3, counting how often the bound exceeds p.

usage: python3 run_adversarial.py   (writes results/adversarial.jsonl)
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
from rareprob.nets import MLP, exact_failure_count, init_mlp  # noqa: E402
from rareprob.nets_lower import lower_bound, random_cube  # noqa: E402

OUT = os.path.join(HERE, "results")
os.makedirs(OUT, exist_ok=True)


def planted(d, m, k, rng, ball=True, noise=0.002, width=16):
    u = rng.choice([-1.0, 1.0], d)
    S = rng.choice(d, k, replace=False)
    b = rng.choice([-1.0, 1.0], k)
    W = [rng.normal(0, 1 / math.sqrt(d), (width, d))]
    a = list(rng.normal(0, noise, width))
    bias = list(np.zeros(width))
    if ball:
        W.append(u[None, :])
        a.append(-0.75 / (2 * m))
        bias.append(-(d - 2 * m))
    w = np.zeros(d)
    w[S] = b
    W.append(w[None, :])
    a.append(-1.0)
    bias.append(-(k - 1.0))
    W1 = np.concatenate(W, axis=0)
    return MLP([W1, np.array(a)[None, :]], [np.array(bias), np.array([1.0])], threshold=0.5, loss="mse")


def run_case(name, net, rng, delta=0.05, trials=5, **kw):
    t = time.time()
    p = exact_failure_count(net) / float(1 << net.d)
    rows = []
    for tr in range(trials):
        res = lower_bound(net, delta=delta, rng=rng, **kw)
        rows.append(dict(kind="planted", case=name, d=net.d, p_exact=p, trial=tr, L=res.lower, L_bet=res.smc_lower,
                         L_wit=res.witness_lower, ratio=res.lower / p if p > 0 else float("nan"),
                         point_estimate=float(np.mean(res.Z)), miss=bool(res.lower > p),
                         evals=res.evals_pilot + res.evals_final, K=len(res.plan.levels)))
        print(json.dumps(rows[-1]), flush=True)
    return rows


def coverage(rng, d=20, nets=20, runs=10):
    rows = []
    for i in range(nets):
        net = init_mlp(d, [32], rng)
        f = net.forward(random_cube(rng, 200000, d))
        target = 10 ** rng.uniform(-6, -3)
        q = np.quantile(f, min(0.5, target * 3)) if target * 3 < 1 else np.median(f)
        net.bs[-1] = net.bs[-1] + (0.5 - q)  # move the threshold to about the target quantile
        cnt = exact_failure_count(net)
        p = cnt / float(1 << d)
        if cnt == 0:
            continue
        for delta in (0.05, 0.3):
            for r in range(runs):
                res = lower_bound(net, delta=delta, N=300, R=16, rng=rng)
                rows.append(dict(kind="coverage", net=i, d=d, p_exact=p, delta=delta, run=r, L=res.lower,
                                 L_bet=res.smc_lower, L_clip=res.clipped_lower, L_min=res.minmarkov_lower,
                                 miss_bet=bool(res.smc_lower > p), miss_clip=bool(res.clipped_lower > p),
                                 miss_min=bool(res.minmarkov_lower > p), miss=bool(res.lower > p),
                                 ratio=res.smc_lower / p))
        sub = [r for r in rows if r["net"] == i]
        print(f"coverage net {i}: p={p:.3g} mean ratio(delta=.05)="
              f"{np.mean([r['ratio'] for r in sub if r['delta'] == 0.05]):.3f} "
              f"misses={sum(r['miss'] for r in sub)}", flush=True)
    return rows


def hidden_d40(rng, trials=5):
    """d = 40: visible ball (Hamming radius 2 around u, 821 points) and a hidden
    subcube of codimension 26 (2^14 points), with f flat (up to noise below
    0.03) elsewhere. p is computed exactly from the two candidate sets, since
    outside them f >= 0.6 - 0.03."""
    d, m, k = 40, 6, 26
    u = rng.choice([-1.0, 1.0], d)
    S = rng.choice(d, k, replace=False)
    b = rng.choice([-1.0, 1.0], k)
    width = 16
    Wn = rng.normal(0, 1 / math.sqrt(d), (width, d))
    an = rng.normal(0, 3e-5, width)
    noise_bound = float(np.sum(np.abs(an) * np.abs(Wn).sum(axis=1)))
    assert noise_bound < 0.03, noise_bound
    w = np.zeros(d)
    w[S] = b
    W1 = np.concatenate([Wn, u[None, :], w[None, :]], axis=0)
    a = np.concatenate([an, [-0.8 / (2 * m), -1.0]])
    bias = np.concatenate([np.zeros(width), [-(d - 2 * m), -(k - 1.0)]])
    net = MLP([W1, a[None, :]], [bias, np.array([1.0])], threshold=0.5, loss="mse")
    # candidates: Hamming ball of radius 2 around u, and the subcube
    from itertools import combinations
    ball = [u.copy()]
    for i in range(d):
        x = u.copy(); x[i] *= -1; ball.append(x)
    for i, j in combinations(range(d), 2):
        x = u.copy(); x[i] *= -1; x[j] *= -1; ball.append(x)
    free = np.setdiff1d(np.arange(d), S)
    idx = np.arange(1 << len(free))
    cube = np.empty((len(idx), d))
    cube[:, S] = b
    cube[:, free] = np.where((idx[:, None] >> np.arange(len(free))) & 1, 1.0, -1.0)
    cand = np.unique(np.concatenate([np.array(ball), cube]), axis=0)
    f = net.forward(cand)
    assert np.all(np.abs(f - 0.5) > 0.02)
    fails = cand[f < 0.5]
    vis = int((net.forward(np.array(ball)) < 0.5).sum())
    p = len(fails) / float(1 << d)
    p_vis = vis / float(1 << d)
    rows = []
    for tr in range(trials):
        res = lower_bound(net, delta=0.05, rng=rng, N=1000, R=32)
        rows.append(dict(kind="planted", case="hidden_d40_k26", d=d, p_exact=p, p_visible=p_vis, trial=tr,
                         L=res.lower, L_bet=res.smc_lower, L_wit=res.witness_lower, ratio=res.lower / p,
                         point_estimate=float(np.mean(res.Z)), miss=bool(res.lower > p),
                         evals=res.evals_pilot + res.evals_final, K=len(res.plan.levels)))
        print(json.dumps(rows[-1]), flush=True)
    return rows


def main():
    if sys.argv[1:] == ["hidden"]:
        rows = hidden_d40(np.random.default_rng(7))
        with open(os.path.join(OUT, "adversarial_hidden.jsonl"), "w") as f:
            for r in rows:
                f.write(json.dumps(r) + "\n")
        return
    rng = np.random.default_rng(99)
    rows = []
    d = 24
    rows += run_case("hidden_k14_ball", planted(d, 8, 14, rng), rng, N=1000, R=32)
    rows += run_case("needle_k24", planted(d, 8, d, rng, ball=False), rng, N=1000, R=32, trials=3)
    rows += coverage(rng)
    with open(os.path.join(OUT, "adversarial.jsonl"), "w") as f:
        for r in rows:
            f.write(json.dumps(r) + "\n")
    cov = [r for r in rows if r["kind"] == "coverage"]
    for delta in (0.05, 0.3):
        c = [r for r in cov if r["delta"] == delta]
        print(f"delta={delta}: runs={len(c)} misses: bet={sum(r['miss_bet'] for r in c)} "
              f"clip={sum(r['miss_clip'] for r in c)} min={sum(r['miss_min'] for r in c)} "
              f"combined={sum(r['miss'] for r in c)}")


if __name__ == "__main__":
    main()
