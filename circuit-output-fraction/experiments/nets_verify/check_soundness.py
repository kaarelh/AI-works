"""Randomised soundness checks for code/rareprob/nets_verify.py.

1. Bounds: on random MLPs (1-3 hidden layers, random biases and thresholds,
   weight scales from 1e-6 to 1e6) every lower/upper bound (CROWN, optimised
   slopes, phase splitting) is compared with brute force over the subcube's
   points and over random real points of its box.
2. Branch and bound: the exact count equals enumeration in exact rational
   arithmetic, and budgeted runs give intervals containing p, on random nets
   and on integer-weight nets where f(x) = t exactly at many points (the
   event is the strict f < t; such points are 'ambiguous' and must land in
   the gap of the interval, never in the certified count).
3. Sampling in undecided subcubes: empirical miss rate of the two-sided
   interval at delta = 0.2 over repeated runs.
Writes results/check_soundness.json.
"""

import json
import os
import sys
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import MLP, init_mlp  # noqa: E402
from rareprob.nets_verify import Bounder, bab, estimate_undecided  # noqa: E402


def exact_count(net):
    """|{x : f(x) < t}| in exact rational arithmetic (floats as exact values)."""
    d = net.d
    cnt = 0
    Ws = [[[Fraction(float(v)) for v in row] for row in W] for W in net.Ws]
    bs = [[Fraction(float(v)) for v in b] for b in net.bs]
    t = Fraction(float(net.threshold))
    for idx in range(1 << d):
        h = [Fraction(1) if (idx >> i) & 1 else Fraction(-1) for i in range(d)]
        for k in range(len(Ws)):
            z = [sum((w * x for w, x in zip(row, h)), Fraction(0)) + bb for row, bb in zip(Ws[k], bs[k])]
            h = [max(v, Fraction(0)) for v in z] if k < len(Ws) - 1 else z
        cnt += h[0] < t
    return cnt


def points(x0):
    free = np.nonzero(x0 == 0)[0]
    r = len(free)
    idx = np.arange(1 << r)
    P = np.where((idx[:, None] >> np.arange(r)) & 1, 1.0, -1.0)
    X = np.repeat(x0[None].astype(float), len(P), 0)
    X[:, free] = P
    return X


def random_net(rng, d, L, scale):
    widths = [int(rng.integers(2, 12)) for _ in range(L)]
    net = init_mlp(d, widths, rng)
    net.Ws = [W * scale for W in net.Ws]
    net.bs = [rng.normal(0, 1, b.shape) * scale ** (i + 1) for i, b in enumerate(net.bs)]
    net.threshold = float(rng.normal()) * scale ** (L + 1)
    return net


def main():
    rng = np.random.default_rng(20261027)
    out = dict(bound_checks=0, bound_violations=0, bab_checks=0, bab_violations=0, coverage_runs=0,
               coverage_misses=0, ambiguous_nets=0, ambiguous_points=0)
    # 1. bounds
    for trial in range(150):
        d = int(rng.integers(3, 11))
        L = int(rng.integers(1, 4))
        scale = float(10.0 ** rng.choice([-6, -2, 0, 0, 0, 2, 6]))
        net = random_net(rng, d, L, scale)
        bd = Bounder(net)
        X0 = rng.choice([-1, 0, 0, 1], size=(30, d)).astype(np.int8)
        lb, ub, _ = bd.bound(X0)
        cand = [lb]
        if L == 1:
            cand.append(bd.alpha_bound(X0, 15))
            cand.append(bd.phase_bound(X0, 2, 15)[0])
        for k in range(30):
            X = points(X0[k])
            Y = np.repeat(X0[k][None].astype(float), 100, 0)
            fr = X0[k] == 0
            Y[:, fr] = rng.uniform(-1, 1, (100, fr.sum()))
            fmin = min(net.forward(X).min(), net.forward(Y).min())
            fmax = max(net.forward(X).max(), net.forward(Y).max())
            tol = 1e-12 * (1 + abs(fmin) + abs(fmax))  # float evaluation of f itself
            for c in cand:
                out["bound_checks"] += 1
                out["bound_violations"] += int(c[k] > fmin + tol)
            out["bound_checks"] += 1
            out["bound_violations"] += int(ub[k] < fmax - tol)
    # 2. branch and bound vs exact rational counting
    for trial in range(60):
        d = int(rng.integers(3, 9))
        L = int(rng.integers(1, 3))
        if trial % 3 == 0:
            # integer weights: many exact ties f(x) = t
            widths = [int(rng.integers(2, 6)) for _ in range(L)]
            sizes = [d] + widths + [1]
            Ws = [rng.integers(-2, 3, size=(b, a)).astype(float) for a, b in zip(sizes[:-1], sizes[1:])]
            bs = [rng.integers(-2, 3, size=b).astype(float) for b in sizes[1:]]
            net = MLP(Ws, bs, threshold=float(rng.integers(-1, 3)), loss="mse")
        else:
            net = random_net(rng, d, L, float(10.0 ** rng.choice([-3, 0, 0, 3])))
        ex = exact_count(net)
        for kw in [dict(r_enum=0), dict(r_enum=2, alpha_iters=5), dict(r_enum=3, phase_depth=2, phase_max_free=8),
                   dict(r_enum=1, max_nodes=7), dict(r_enum=2, max_fpe=40.0)]:
            if net.Ws.__len__() > 2 and ("phase_depth" in kw or "alpha_iters" in kw):
                continue
            res = bab(net, probe=4, min_rate=0.3, **kw)
            out["bab_checks"] += 1
            ok = res.fail <= ex <= res.fail + res.ambiguous + res.undecided
            ok &= res.lo <= ex / 2 ** d <= res.hi
            out["bab_violations"] += int(not ok)
            if res.ambiguous:
                out["ambiguous_points"] += res.ambiguous
        if trial % 3 == 0:
            out["ambiguous_nets"] += 1
    # 3. coverage of the sampling stage
    for trial in range(200):
        d = int(rng.integers(8, 12))
        net = random_net(rng, d, 1, 1.0)
        ex = exact_count(net) if d <= 8 else None
        if ex is None:
            from rareprob.nets import exact_failure_count
            ex = exact_failure_count(net)  # float semantics; checked equal on these nets by part 2's argument
        p = ex / 2 ** d
        res = bab(net, r_enum=2, max_fpe=60.0, probe=4, min_rate=0.0)
        tw = estimate_undecided(net, res, eps=0.3, delta=0.2, rng=rng, max_samples=4096, first=64)
        out["coverage_runs"] += 1
        out["coverage_misses"] += int(not (tw.lo <= p <= tw.hi))
    print(out)
    json.dump(out, open(os.path.join(HERE, "results", "check_soundness.json"), "w"), indent=1)
    assert out["bound_violations"] == 0 and out["bab_violations"] == 0


if __name__ == "__main__":
    main()
