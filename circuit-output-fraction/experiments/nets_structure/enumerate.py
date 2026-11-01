"""Exhaustive pass over {-1,+1}^d for the suite nets (d <= 28).

For each net records (results/enum/<name>.json):
  * the exact count of failures [f < t] (checked against suite.json),
  * the exact first four moments of f over the cube,
  * the exact lower-tail quantile function: the k-th smallest value of f for
    k = 1, 2, 3, ... on a geometric grid up to 2e6, so that
    Pr[f < q_k] = (#values < q_k) / 2^d exactly gives the whole lower-tail
    curve P(s) = Pr[f < s] (used to test tail shapes and heuristics at every
    threshold, not only at t),
and caches (cache/<name>.npz, regenerable) the 100k lowest inputs with their
f values and a uniform subsample (<= 100k) of the failing inputs.

usage: python3 enumerate.py name [name ...]
"""

import json
import os
import sys
import time

import numpy as np

from common import HERE, mitm_blocks, suite, suite_net

ENUM = os.path.join(HERE, "results", "enum")
CACHE = os.path.join(HERE, "cache")
os.makedirs(ENUM, exist_ok=True)
os.makedirs(CACHE, exist_ok=True)

L_TAIL = 2_000_000
K_LOW = 100_000
K_FAIL = 100_000


def ranks(n):
    r = np.unique(np.round(1.03 ** np.arange(0, 600)).astype(np.int64))
    return r[r <= n]


def run(net, name, rng):
    d, t = net.d, net.threshold
    X = rng.choice([-1.0, 1.0], size=(100000, d))
    shift = float(net.forward(X).mean())
    S = np.zeros(5)
    low = np.empty(0)
    low_f = np.empty(0)
    low_i = np.empty(0, dtype=np.int64)
    fail_i = np.empty(0, dtype=np.int64)
    fail_key = np.empty(0)
    count = 0
    fmin, argmin = np.inf, -1
    t0 = time.time()
    for gidx, f in mitm_blocks(net):
        y = f - shift
        y2 = y * y
        S += [len(y), y.sum(), y2.sum(), (y2 * y).sum(), (y2 * y2).sum()]
        j = int(np.argmin(f))
        if f[j] < fmin:
            fmin, argmin = float(f[j]), int(gidx[j])
        # lower tail values
        cut = low[-1] if len(low) >= L_TAIL else np.inf
        sel = f[f < cut] if np.isfinite(cut) else f
        if len(sel):
            low = np.concatenate([low, sel])
            if len(low) > L_TAIL:
                low = np.partition(low, L_TAIL - 1)[:L_TAIL]
            low.sort()
        # lowest inputs with indices
        cut = low_f.max() if len(low_f) >= K_LOW else np.inf
        m = f < cut
        if m.any():
            low_f = np.concatenate([low_f, f[m]])
            low_i = np.concatenate([low_i, gidx[m]])
            if len(low_f) > K_LOW:
                k = np.argpartition(low_f, K_LOW - 1)[:K_LOW]
                low_f, low_i = low_f[k], low_i[k]
        # failures: uniform subsample by random keys
        m = f < t
        nf = int(m.sum())
        count += nf
        if nf:
            fail_i = np.concatenate([fail_i, gidx[m]])
            fail_key = np.concatenate([fail_key, rng.random(nf)])
            if len(fail_i) > K_FAIL:
                k = np.argpartition(fail_key, K_FAIL - 1)[:K_FAIL]
                fail_i, fail_key = fail_i[k], fail_key[k]
    secs = time.time() - t0
    n = S[0]
    m1 = S[1] / n
    c2 = S[2] / n - m1 ** 2
    c3 = S[3] / n - 3 * m1 * S[2] / n + 2 * m1 ** 3
    c4 = S[4] / n - 4 * m1 * S[3] / n + 6 * m1 ** 2 * S[2] / n - 3 * m1 ** 4
    mean, var = shift + m1, c2
    rk = ranks(len(low))
    o = np.argsort(low_f)
    np.savez_compressed(os.path.join(CACHE, name + ".npz"), low_i=low_i[o].astype(np.int64), low_f=low_f[o],
                        fail_i=np.sort(fail_i), fail_count=count)
    out = dict(name=name, d=d, threshold=t, loss=net.loss, widths=net.widths, fail_count=count,
               p_exact=count / 2.0 ** d, mean=mean, var=var, std=float(np.sqrt(var)),
               skew=float(c3 / var ** 1.5), exkurt=float(c4 / var ** 2 - 3), fmin=fmin, argmin=argmin,
               tail_ranks=rk.tolist(), tail_q=low[rk - 1].tolist(), seconds=round(secs, 1))
    with open(os.path.join(ENUM, name + ".json"), "w") as fh:
        json.dump(out, fh)
    return out


def main():
    names = sys.argv[1:]
    rows = {r["name"]: r for r in suite()}
    rng = np.random.default_rng(7)
    for name in names:
        if os.path.exists(os.path.join(ENUM, name + ".json")):
            print("skip", name, flush=True)
            continue
        net = suite_net(name)
        o = run(net, name, rng)
        ref = rows.get(name, {}).get("fail_count")
        print(name, "count", o["fail_count"], "suite", ref, "fmin", round(o["fmin"], 4), "mean", round(o["mean"], 4),
              "std", round(o["std"], 4), "skew", round(o["skew"], 3), "exkurt", round(o["exkurt"], 3),
              "sec", o["seconds"], flush=True)


if __name__ == "__main__":
    main()
