import sys, time, json, numpy as np
sys.path.insert(0, "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p10_hier")
from feats import *

ds = sys.argv[1]; n = int(sys.argv[2]); variants = sys.argv[3].split(","); rounds = int(sys.argv[4]) if len(sys.argv) > 4 else 300
X, y, Xv, yv, C = load(ds, n)
act, S = neigh(X, 49)
cache = {}


def P(k, A):
    key = (k, id(A))
    if key not in cache:
        cache[key] = pooled(A, act, S, k)
    return cache[key]


def pairs(Xr, yr, m, rng):
    a = rng.integers(len(Xr), size=m); b = rng.integers(len(Xr), size=m)
    for _ in range(100):
        bad = yr[a] == yr[b]
        if not bad.any():
            break
        b[bad] = rng.integers(len(Xr), size=int(bad.sum()))
    keep = yr[a] != yr[b]
    return (np.asarray(Xr[a[keep]], np.float32) - np.asarray(Xr[b[keep]], np.float32))


U = pairs(X, y, 300, np.random.default_rng(5))


def bank(A, v):
    A32 = np.asarray(A, np.float32)
    parts = [A32, P(4, A), P(9, A), P(16, A)]
    if "pairs" in v:
        parts.append(A32 @ U.T)
    if "big" in v:
        parts += [P(25, A), P(49, A)]
    if "max" in v:                     # level-2 max pooling of level-1 sums
        parts += [maxpool(P(4, A), S, 9), maxpool(P(9, A), S, 16)]
    if "max2" in v:
        parts += [maxpool(P(4, A), S, 16), maxpool(P(9, A), S, 25), maxpool(P(16, A), S, 49)]
    if "cnt" in v:                     # level-2 counts of active gates [p4 > t] over S_i(16), thresholds at global quantiles
        p4tr = P(4, X)
        for q in (0.5, 0.8):
            t = np.quantile(p4tr[p4tr > 0][:2000000], q)
            G = (P(4, A) > t).astype(np.float32)
            parts += [countpool(G, S, 16)]
    if "dog" in v:                     # centre-surround signed sums
        parts += [4 * P(4, A) - P(16, A), P(9, A) * 25 / 9 - P(25, A)]
    return np.concatenate(parts, 1)


for v in variants:
    t0 = time.process_time()
    F = bank(X, v); Fv = bank(Xv, v); tf = time.process_time() - t0
    curve, best, bi, cpu = lgb_curve(F, y, Fv, yv, C, rounds=rounds)
    print(json.dumps(dict(ds=ds, n=n, v=v, cols=F.shape[1], best=best, at=bi, cpu=round(cpu, 1), feat_cpu=round(tf, 1),
                          curve={k: round(e, 4) for k, e in curve.items() if k % 50 == 0})), flush=True)
    del F, Fv
