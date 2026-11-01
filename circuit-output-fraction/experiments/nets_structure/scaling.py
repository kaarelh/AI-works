"""How p, its tail shape and its structure change with training time, d, width,
depth and loss, on nets trained here (d <= 24, exact enumeration of the cube).

For each configuration and seed, train_constant is run once with snapshots;
for each snapshot the whole cube is evaluated and we record the exact
failure count, min f, the exact first four moments of f, the exact lower-tail
quantile function on a geometric rank grid (as in enumerate.py), and, for
d <= 20, Walsh statistics (degree profile, odd share, participation ratio).
Nets are cached in cache/own/ for heuristics.py and structure.py.

usage: python3 scaling.py [config ...]     (writes results/scaling_<config>.json)
"""

import os
import sys
import time

import numpy as np

from common import HERE, all_f, save_json, train_constant

OWN = os.path.join(HERE, "cache", "own")
os.makedirs(OWN, exist_ok=True)

STEPS_MSE = (100, 200, 300, 500, 700, 1000, 1500, 2000, 3000, 4000)
STEPS_BCE = (10, 20, 30, 50, 70, 100, 150, 200, 300)
STEPS_MSE2 = (50, 100, 200, 300, 500, 700, 1000, 1500)
STEPS_BCE2 = (10, 20, 40, 60, 100, 150, 200, 300)

CONFIGS = {
    # name: (loss, widths, lr, steps, ds, seeds)
    "mse1": ("mse", [32], 1e-3, STEPS_MSE, (12, 16, 20, 24), 4),
    "bce1": ("bce", [32], 1e-3, STEPS_BCE, (12, 16, 20, 24), 4),
    "mse2": ("mse", [32, 32], 1e-3, STEPS_MSE2, (16, 20, 24), 3),
    "bce2": ("bce", [32, 32], 3e-4, STEPS_BCE2, (16, 20, 24), 3),
    "msewidth": ("mse", None, 1e-3, STEPS_MSE, (20,), 3),
    "bcewidth": ("bce", None, 1e-3, STEPS_BCE, (20,), 3),
}
WIDTHS = (8, 16, 64, 128)


def ranks(n):
    r = np.unique(np.round(1.03 ** np.arange(0, 600)).astype(np.int64))
    return r[r <= n]


def walsh_stats(f, d):
    from walsh import fwht
    fh = fwht(f.copy())
    idx = np.arange(len(fh), dtype=np.int64)
    deg = np.zeros(len(fh), dtype=np.int64)
    for i in range(d):
        deg += (idx >> i) & 1
    sq = fh * fh
    W = np.bincount(deg, weights=sq, minlength=d + 1)
    var = W[1:].sum()
    sq[0] = 0
    return dict(W=(W[1:] / var).tolist(), mean_degree=float((np.arange(1, d + 1) * W[1:]).sum() / var),
                odd_share=float(W[1::2].sum() / var), participation=float(var ** 2 / (sq ** 2).sum()))


def record(net, f, name, extra):
    d, t = net.d, net.threshold
    mu, sd = float(f.mean()), float(f.std())
    y = (f - mu) / sd
    srt = np.sort(f)[:2_000_000]
    rk = ranks(len(srt))
    F = int((f < t).sum())
    row = dict(name=name, d=d, widths=net.widths, loss=net.loss, threshold=t, F=F, p=F / 2.0 ** d,
               fmin=float(srt[0]), mean=mu, std=sd, z=(mu - t) / sd, skew=float((y ** 3).mean()),
               exkurt=float((y ** 4).mean() - 3), tail_ranks=rk.tolist(), tail_q=srt[rk - 1].tolist())
    # corr(f(x), f(-x)) exactly: index of -x is the bitwise complement
    neg = f[::-1]  # complement of all bits = reversal of the index order
    row["corr_f_fneg"] = float(np.corrcoef(f, neg)[0, 1])
    row.update(extra)
    if d <= 20:
        row.update(walsh_stats(f, d))
    return row


def run_config(cname):
    loss, widths, lr, steps, ds, seeds = CONFIGS[cname]
    rows = []
    wlist = [widths] if widths else [[w] for w in WIDTHS]
    for d in ds:
        for wd in wlist:
            for seed in range(seeds):
                rng = np.random.default_rng(1000 * seed + 17 * d + len(wd) * 7 + wd[0])
                t0 = time.time()
                _, snaps = train_constant(d, wd, max(steps), rng, loss=loss, lr=lr, snapshots=steps)
                for s in steps:
                    net = snaps[s]
                    wname = "x".join(str(w) for w in wd)
                    name = f"own_{loss}_d{d}_w{wname}_seed{seed}_s{s}"
                    f = all_f(net)
                    row = record(net, f, name, dict(step=s, seed=seed, config=cname, lr=lr))
                    np.savez(os.path.join(OWN, name + ".npz"), **{f"W{i}": W for i, W in enumerate(net.Ws)},
                             **{f"b{i}": b for i, b in enumerate(net.bs)}, threshold=net.threshold, loss=loss)
                    rows.append(row)
                print(cname, d, wd, seed, "p by step:", " ".join("%.1e" % r["p"] for r in rows[-len(steps):]),
                      "(%.0fs)" % (time.time() - t0), flush=True)
                save_json(rows, f"scaling_{cname}.json")


def main():
    for c in sys.argv[1:] or list(CONFIGS):
        run_config(c)


if __name__ == "__main__":
    main()
