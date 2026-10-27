"""exp2: token-specified banks. base = [x, p4, p9, p16] (no pairs) unless 'nobase' / 'nop16'.
tokens joined by '+': m{k}_{K} = max over S_i(K) of p_k (k=1: raw pixels); P{k} = extra pooled scale;
c{k}_{K}_{q} = count over S_i(K) of [p_k > global quantile q of positive p_k]; mm{k}_{K1}_{K2} = max over S(K2) of m{k}_{K1}."""
import sys, time, json, numpy as np
sys.path.insert(0, "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p10_hier")
from feats import *

ds = sys.argv[1]; n = int(sys.argv[2]); variants = sys.argv[3].split(","); rounds = int(sys.argv[4]) if len(sys.argv) > 4 else 300
ff = float(sys.argv[5]) if len(sys.argv) > 5 else 0.12
X, y, Xv, yv, C = load(ds, n)
act, S = neigh(X, 49)


def bank(A, v):
    A32 = np.asarray(A, np.float32); cache = {}

    def P(k):
        if k not in cache:
            cache[k] = A32[:, act] if k == 1 else pooled(A, act, S, k)
        return cache[k]
    toks = v.split("+")
    parts = [] if "nobase" in toks else [A32, P(4), P(9)] + ([] if "nop16" in toks else [P(16)])
    for t in toks:
        if t.startswith("sm"):
            k, K1, K2 = map(int, t[2:].split("_")); parts.append(countpool(maxpool(P(k), S, K1), S, K2))
        elif t.startswith("mm"):
            k, K1, K2 = map(int, t[2:].split("_")); parts.append(maxpool(maxpool(P(k), S, K1), S, K2))
        elif t.startswith("m"):
            k, K = map(int, t[1:].split("_")); parts.append(maxpool(P(k), S, K))
        elif t.startswith("P"):
            parts.append(P(int(t[1:])))
        elif t.startswith("c"):
            k, K, q = t[1:].split("_"); k, K, q = int(k), int(K), float(q)
            ptr = pooled(X[:5000], act, S, k) if k > 1 else np.asarray(X[:5000], np.float32)[:, act]
            th = np.quantile(ptr[ptr > 0], q)
            parts.append(countpool((P(k) > th).astype(np.float32), S, K))
    return np.concatenate(parts, 1)


for v in variants:
    t0 = time.process_time()
    F = bank(X, v); Fv = bank(Xv, v); tf = time.process_time() - t0
    curve, best, bi, cpu = lgb_curve(F, y, Fv, yv, C, rounds=rounds, ff=ff)
    print(json.dumps(dict(ds=ds, n=n, v=v, ff=ff, cols=F.shape[1], best=best, at=bi, cpu=round(cpu, 1), feat_cpu=round(tf, 1),
                          curve={k: round(e, 4) for k, e in curve.items() if k % 50 == 0})), flush=True)
    del F, Fv
