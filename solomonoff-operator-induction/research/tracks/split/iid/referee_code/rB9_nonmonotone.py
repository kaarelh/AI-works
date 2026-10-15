"""rB9 (referee B): which competitors cause the non-monotone failure frequency seen in rB3 (lambda = 1, 1.25:
P[MAPs != E*] is larger at n = 800 than at n = 400)?  Same class and law as rB3; 2000 runs, seed 91.
For each n on a grid, counts the runs in which the MAP set contains a program of each kind.
"""
import numpy as np
from math import ceil, log2

rng = np.random.default_rng(91)
X = np.arange(8)
mu = 1.0 / (X + 1); mu /= mu.sum()
nu1 = (2 * X + 1) / 16.0
progs, lens, kinds, info = [], [], [], []
def add(p1, L, kind, inf=""):
    progs.append(np.asarray(p1, float)); lens.append(L); kinds.append(kind); info.append(inf)
add(nu1, 10, "T")
for L in (12, 14, 16):
    add(nu1, L, "Tcopy")
for j in range(1, 16):
    add(np.full(8, j / 16), 6, "BERN")
for t in range(8):
    add(np.where(X >= t, 0.75, 0.25), 7, "THR")
for f in range(256):
    add(np.array([(f >> x) & 1 for x in X], float), 11, "DET")
for x in X:
    for b in (0, 1):
        p = nu1.copy(); p[x] = b; add(p, 12, "EXC", f"x={x},b={b}")
for x in X:
    for sgn in (-1, 1):
        for j in range(3, 21):
            q = nu1[x] + sgn * 2.0 ** -j
            if not 0 < q < 1:
                continue
            p = nu1.copy(); p[x] = q; add(p, 14 + 2 * ceil(log2(j + 1)), "NEAR", f"x={x},j={j}")
P1 = np.stack(progs); lens = np.array(lens, float); kinds = np.array(kinds); info = np.array(info)
with np.errstate(divide="ignore"):
    LK1, LK0 = np.log2(P1), np.log2(1 - P1)
NS = [100, 200, 300, 400, 500, 600, 800, 1000, 1200, 1600, 2000]
R, N = 2000, 2000
for lam in (1.0, 1.25):
    tally = {n: {} for n in NS}
    fails = {n: 0 for n in NS}
    for r in range(R):
        xs = rng.choice(8, size=N, p=mu)
        ys = rng.random(N) < nu1[xs]
        inc = np.where(ys[None, :], LK1[:, xs], LK0[:, xs])
        cum = np.cumsum(inc, axis=1)
        for n in NS:
            J = lam * lens - cum[:, n - 1]
            maps = np.flatnonzero(J <= J.min() + 1e-9)
            if any(kinds[i] != "T" for i in maps):
                fails[n] += 1
                for i in maps:
                    if kinds[i] != "T":
                        key = kinds[i] + ("(" + info[i] + ")" if kinds[i] in ("EXC",) else "")
                        tally[n][key] = tally[n].get(key, 0) + 1
    print(f"lambda = {lam}")
    for n in NS:
        top = sorted(tally[n].items(), key=lambda t: -t[1])[:3]
        print(f"  n={n:5d}: P[fail] = {fails[n] / R:.4f}; most frequent non-E* MAPs: {top}")
