#!/usr/bin/env python3
"""Referee's own analysis of the referee's own exhaustive enumeration (independent_full.c dump and
independent_profile.c profile), and comparison with the authors' saved results.

Usage: python3 independent_analysis.py DUMP.bin PROF.bin AUTHORS_pr11.npz AUTHORS_nearest11.npy
"""
import sys

import numpy as np

dump, proff, their_npz, their_prof = sys.argv[1:5]
raw = np.fromfile(dump, dtype=np.uint8)
n = int(np.frombuffer(raw[:4].tobytes(), dtype=np.int32)[0])
rec = raw[4:].reshape(n, 37)
F = rec[:, :36].astype(np.int64)          # input index i = 6x + y
K = rec[:, 36].astype(np.int64)
prof = np.fromfile(proff, dtype=np.uint8).reshape(n, 37).astype(np.int64)
print(f"my enumeration: {n} functions; by K:", {int(k): int((K == k).sum()) for k in np.unique(K)})

# ---- A. exact comparison with the authors' saved enumeration and profile
d = np.load(their_npz)
Ft, Kt = d["F"].astype(np.int64), d["K"].astype(np.int64)
mine = {F[i].astype(np.uint8).tobytes(): int(K[i]) for i in range(n)}
theirs = {Ft[i].astype(np.uint8).tobytes(): int(Kt[i]) for i in range(len(Kt))}
print("A1. same set of functions:", set(mine) == set(theirs),
      "| same least size for every function:", mine == theirs)
row = {F[i].astype(np.uint8).tobytes(): i for i in range(n)}
perm = np.array([row[Ft[i].astype(np.uint8).tobytes()] for i in range(len(Kt))])
tp = np.load(their_prof).astype(np.int64)
print("A2. authors' nearest11.npy equals my profile at every (function, distance):",
      bool((tp[:, 1:] == prof[perm][:, 1:]).all()))

# ---- B. isolation radius and tables
BIG = 99
ex = np.where(prof == 0, BIG, prof)
ex[:, 0] = BIG
R = np.full(n, 37)
for i in range(n):
    hit = np.nonzero(ex[i] <= K[i])[0]
    if len(hit):
        R[i] = hit[0]
X = np.repeat(np.arange(6), 6)
Y = np.tile(np.arange(6), 6)
targets = [
    ("successor x+1", X + 1), ("addition x+y", X + Y), ("x+y+1", X + Y + 1),
    ("monus x-y", np.maximum(X - Y, 0)), ("product x*y", X * Y), ("max(x,y)", np.maximum(X, Y)),
    ("add, but 1 at (0,0)", np.where((X == 0) & (Y == 0), 1, X + Y)),
    ("add, but y+1 where x=0", np.where(X == 0, Y + 1, X + Y)),
    ("add, but x where y<=1", np.where(Y <= 1, X, X + Y)),
    ("add, but 0 where x=0", np.where(X == 0, 0, X + Y)),
    ("double 2x", 2 * X), ("min(x,y)", np.minimum(X, Y)), ("[x<=y]", (X <= Y).astype(int)),
    ("[x=y]", (X == Y).astype(int)), ("|x-y|", np.abs(X - Y)),
]
print("\nB1. named functions (the note's table: K, R, within 1, within 6)")
print(f"{'function':26s} {'K':>3s} {'R':>3s} {'<=1':>4s} {'<=6':>4s}   full profile of least sizes within r = 1,2,3,5,6,8,11,17")
idx = {}
for name, tab in targets:
    i = row.get(np.asarray(tab, dtype=np.uint8).tobytes())
    if i is None:
        print(f"{name:26s} not expressible with <= 11 nodes")
        continue
    idx[name] = i
    w = lambda r: (lambda v: str(v) if v < BIG else ">11")(int(ex[i, 1:r + 1].min()))
    print(f"{name:26s} {K[i]:3d} {R[i]:3d} {w(1):>4s} {w(6):>4s}   " + " ".join(w(r) for r in (1, 2, 3, 5, 6, 8, 11, 17)))

add = idx["addition x+y"]
near = [j for j in range(n) if (F[j] != F[add]).sum() == 1]
near.sort(key=lambda j: K[j])
print("\nB2. functions at Hamming distance exactly 1 from addition (all sizes <= 11):")
for j in near:
    p = int(np.nonzero(F[j] != F[add])[0][0])
    print(f"   size {K[j]}: at (x,y)=({p // 6},{p % 6}) value {F[add][p]} -> {F[j][p]}")
print("   least size within distance 17 of addition:", int(ex[add, 1:18].min()),
      "; number of functions of that size within 17:",
      sum(1 for j in range(n) if j != add and K[j] == ex[add, 1:18].min() and (F[j] != F[add]).sum() <= 17))

print("\nB3. isolation counts R >= r by K (Part 2 of analyze_pr11.out)")
rs = [1, 2, 3, 6, 9, 12, 18]
print(f"{'K':>3s} {'count':>7s}  " + " ".join(f"r={r:<6d}" for r in rs))
for k in range(1, 12):
    m = K == k
    print(f"{k:3d} {m.sum():7d}  " + " ".join(f"{(R[m] >= r).sum():8d}" for r in rs))
print(f"{'all':>3s} {n:7d}  " + " ".join(f"{(R >= r).sum():8d}" for r in rs))
for r, lab in ((6, "1/6"), (12, "1/3"), (18, "1/2")):
    m = K == 11
    print(f"   delta={lab}: all {100 * (R >= r).mean():.2f}%   size 11: {100 * (R[m] >= r).mean():.2f}%")

# ---- C. dissent statistics, own implementation, same random stream as analyze.py (seed 0)
print("\nC. dissent after random data; per class: a/b/c  e   (a: size<=K, b: size<=K+2, c: any enumerated; "
      "e: mean wrong-label posterior, weights 8^-K)")
rng = np.random.default_rng(0)
W = 8.0 ** (-K)
classes = [("all", np.ones(n, bool)), ("R>=3", R >= 3), ("R>=6", R >= 6), ("R>=12", R >= 12)]
for name in ["successor x+1", "addition x+y", "monus x-y", "max(x,y)", "product x*y"]:
    i = idx[name]
    f = F[i]
    print(f"\n{name} (K={K[i]}, R={R[i]})")
    for nn in [2, 4, 8, 12, 16, 24, 32, 48]:
        tot = 0
        acc = np.zeros((len(classes), 4))
        for _ in range(300):
            seen = np.unique(rng.integers(0, 36, size=nn))
            unseen = np.array([q for q in range(36) if q not in set(seen.tolist())], dtype=int)
            if len(unseen) == 0:
                continue
            ok = (F[:, seen] == f[seen]).all(axis=1)
            tot += len(unseen)
            for ci, (_, cm) in enumerate(classes):
                J = np.nonzero(ok & cm)[0]
                if len(J) == 0:
                    continue
                wrong = F[J][:, unseen] != f[unseen]            # (hypothesis, unseen input)
                Kw = np.where(wrong, K[J][:, None], BIG).min(axis=0)
                post = (wrong * W[J][:, None]).sum(axis=0) / W[J].sum()
                acc[ci] += [(Kw <= K[i]).sum(), (Kw <= K[i] + 2).sum(), (Kw < BIG).sum(), post.sum()]
        cells = []
        for ci, (cn, cm) in enumerate(classes):
            if not cm[i]:
                cells.append("f not in class".rjust(30))
            else:
                a, b, c, e = acc[ci] / max(tot, 1)
                cells.append(f"{a:.3f}/{b:.3f}/{c:.3f}  {e:.1e}".rjust(30))
        print(f"{nn:3d}  " + "  ".join(cells), flush=True)
