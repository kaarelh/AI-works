"""How large a subcube can be certified safe, as a function of d.

For random subcubes with r free coordinates (the fixed ones uniform), the
fraction certified safe by
  crown   CROWN with the default slopes,
  alpha   CROWN with optimised slopes (50 supergradient steps; one hidden
          layer; close to the LP / triangle relaxation),
  box     the exact minimum over the subcube's BOX (MILP over real points,
          HiGHS): the limit of every method that bounds f over the box
          (any linear relaxation, the LP, complete ReLU phase splitting).
          A subcube counts as 'box-refuted' only if the MILP (5 s limit)
          returns a real point of the box at which our own evaluation gives
          f < t, so the refutations are checked witnesses and box_open is an
          upper bound on the fraction any box method can certify; once it is
          <= 0.05 at two consecutive r, larger r are not measured;
  cube    exact enumeration of the subcube's points (no failing point),
and r50 for each: the largest r at which at least half of the subcubes are
certified. Nets: one hidden layer of width 32 trained with squared loss for
1500 and 3000 steps at d = 16, 24, 32, 48, 64 (seeded), plus suite nets.
Writes results/barrier.json.
"""

import json
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, train_constant  # noqa: E402
from rareprob.nets_verify import Bounder, milp_min  # noqa: E402

OUT = os.path.join(HERE, "results")
os.makedirs(OUT, exist_ok=True)


def subcubes(d, r, n, rng):
    X0 = rng.choice([-1, 1], size=(n, d)).astype(np.int8)
    for b in range(n):
        X0[b, rng.choice(d, r, replace=False)] = 0
    return X0


def cube_min(bd, x0):
    free = np.nonzero(x0 == 0)[0]
    r = len(free)
    idx = np.arange(1 << r)
    P = np.where((idx[:, None] >> np.arange(r)) & 1, 1.0, -1.0)
    X = np.repeat(x0[None].astype(float), len(P), 0)
    X[:, free] = P
    return bd.forward(X).min()


def measure(net, rs, n, rng, cube_max=16, box_max=None, milp_time=5.0):
    bd = Bounder(net)
    t = bd.t
    rows = []
    box_dead = 0
    for r in rs:
        if box_dead >= 2 and r > cube_max:
            break
        X0 = subcubes(bd.d, r, n, rng)
        lb, _, _ = bd.bound(X0)
        row = dict(r=r, n=n, crown=float((lb >= bd.thr_safe).mean()))
        if bd.L == 1:
            la = np.maximum(lb, bd.alpha_bound(X0, 50))
            row["alpha"] = float((la >= bd.thr_safe).mean())
        if (box_max is None or r <= box_max) and box_dead < 2:
            refuted = 0
            unsolved = 0
            tt = time.time()
            for b in range(n):
                v, x, st, _ = milp_min(net, X0[b], integer=False, time_limit=milp_time)
                if x is not None and bd.forward(x[None])[0] < bd.pt_fail:
                    refuted += 1
                elif st != 0:
                    unsolved += 1
            row["box_open"] = 1.0 - refuted / n  # upper bound on what box methods can certify
            row["box_unsolved"] = unsolved
            row["milp_seconds_each"] = round((time.time() - tt) / n, 3)
            box_dead = box_dead + 1 if row["box_open"] <= 0.05 else 0
        if r <= cube_max:
            cm = np.array([cube_min(bd, X0[b]) for b in range(n)])
            row["cube"] = float((cm >= t).mean())
        rows.append(row)
        print("   ", row, flush=True)
    return rows


def r50(rows, key):
    best = None
    for row in rows:
        if key in row and row[key] >= 0.5:
            best = row["r"] if best is None else max(best, row["r"])
    return best


def main():
    path = os.path.join(OUT, "barrier.json")
    out = json.load(open(path)) if os.path.exists(path) else []
    done = {o["name"] for o in out}
    jobs = []
    for d in [16, 24, 32, 48, 64]:
        for steps in [1500, 3000]:
            jobs.append((f"own_mse_d{d}_w32_s{steps}", d, steps))
    for name, d, steps in jobs:
        if name in done:
            continue
        rng = np.random.default_rng(1000 + d)
        net, snaps = train_constant(d, [32], steps, rng)
        bd = Bounder(net)
        X = rng.choice([-1.0, 1.0], size=(100000, d))
        f = net.forward(X)
        z = float((f.mean() - net.threshold) / f.std())
        rs = list(range(2, min(d, 30) + 1, 2))
        print(name, "z", round(z, 2), flush=True)
        rows = measure(net, rs, 30, np.random.default_rng(d), cube_max=16,
                       box_max=26)
        o = dict(name=name, d=d, widths=[32], steps=steps, z=z, f0=float(bd.forward(np.zeros((1, d)))[0]),
                 rows=rows, r50={k: r50(rows, k) for k in ["crown", "alpha", "box_open", "cube"]})
        print(name, o["r50"], flush=True)
        out.append(o)
        json.dump(out, open(path, "w"), indent=1)
        np.savez(os.path.join(OUT, name + ".npz"), **{f"W{i}": W for i, W in enumerate(net.Ws)},
                 **{f"b{i}": b for i, b in enumerate(net.bs)}, threshold=net.threshold, loss=net.loss)


if __name__ == "__main__":
    main()
