#!/usr/bin/env python3
"""Referee's extra checks on Section 6 (uses the referee's own enumeration and profile).

1. How the 'some enumerated hypothesis dissents' fraction depends on the size cap (9, 10, 11).
2. Seed-to-seed spread of the headline numbers (addition, n = 16).
3. At which sizes the dissenting hypotheses sit (addition, n = 16).
4. The functions of size 7 within distance 17 of addition; the equal-size neighbours of the patches.
5. Weight of the truncated tail.

Usage: python3 extra_checks.py DUMP.bin PROF.bin
"""
import sys

import numpy as np

raw = np.fromfile(sys.argv[1], dtype=np.uint8)
n = int(np.frombuffer(raw[:4].tobytes(), dtype=np.int32)[0])
rec = raw[4:].reshape(n, 37)
F, K = rec[:, :36].astype(np.int64), rec[:, 36].astype(np.int64)
prof = np.fromfile(sys.argv[2], dtype=np.uint8).reshape(n, 37).astype(np.int64)
ex = np.where(prof == 0, 99, prof)
ex[:, 0] = 99
R = np.array([(np.nonzero(ex[i] <= K[i])[0][:1].tolist() or [37])[0] for i in range(n)])
X, Y = np.repeat(np.arange(6), 6), np.tile(np.arange(6), 6)
row = {F[i].astype(np.uint8).tobytes(): i for i in range(n)}
find = lambda tab: row[np.asarray(tab, dtype=np.uint8).tobytes()]
add, suc = find(X + Y), find(X + 1)
classes = [("all", np.ones(n, bool)), ("R>=6", R >= 6), ("R>=12", R >= 12)]


def run(i, nn, seed, trials=300):
    """returns dict class -> array over (trial, unseen x) of the least size of a dissenter (99 if none)"""
    rng = np.random.default_rng(seed)
    f = F[i]
    out = {c: [] for c, _ in classes}
    for _ in range(trials):
        seen = np.unique(rng.integers(0, 36, size=nn))
        unseen = np.setdiff1d(np.arange(36), seen)
        if len(unseen) == 0:
            continue
        ok = (F[:, seen] == f[seen]).all(axis=1)
        for c, cm in classes:
            J = np.nonzero(ok & cm)[0]
            wrong = F[J][:, unseen] != f[unseen]
            out[c].append(np.where(wrong, K[J][:, None], 99).min(axis=0))
    return {c: np.concatenate(v) for c, v in out.items()}


print("1. fraction of (trial, unseen input) pairs with a dissenter of size <= cap  (seed 1, 300 trials)")
for name, i in (("addition", add), ("successor", suc)):
    for nn in (8, 16, 32):
        d = run(i, nn, 1)
        print(f"   {name:9s} n={nn:2d}  " + "   ".join(
            f"{c}: " + "/".join(f"{(d[c] <= cap).mean():.3f}" for cap in (9, 10, 11)) for c, _ in classes)
            + "   (caps 9/10/11)")

print("\n2. addition, n = 16, cap 11: dissent fraction for seeds 1..8 (300 trials each)")
for c, _ in classes:
    vals = []
    for seed in range(1, 9):
        d = run(add, 16, seed)
        vals.append((d[c] <= 11).mean())
    print(f"   {c:6s} " + " ".join(f"{v:.3f}" for v in vals) + f"   mean {np.mean(vals):.3f} sd {np.std(vals, ddof=1):.3f}")

print("\n3. addition, n = 16, seed 1: least size of a dissenter, distribution over (trial, unseen x)")
d = run(add, 16, 1)
for c, _ in classes:
    print(f"   {c:6s} " + " ".join(f"{s}:{(d[c] == s).mean():.3f}" for s in range(5, 12)) + f"  none:{(d[c] == 99).mean():.3f}")

print("\n4a. functions of size 7 within distance 17 of addition")
for j in np.nonzero(K == 7)[0]:
    df = np.nonzero(F[j] != F[add])[0]
    if 0 < len(df) <= 17:
        print(f"   distance {len(df):2d}: " + ", ".join(f"({p // 6},{p % 6}):{F[add][p]}->{F[j][p]}" for p in df))
print("4b. neighbours at distance 1, of size <= K, of the patched additions")
for name, tab in (("add, but 1 at (0,0)", np.where((X == 0) & (Y == 0), 1, X + Y)),
                  ("add, but y+1 where x=0", np.where(X == 0, Y + 1, X + Y)),
                  ("add, but x where y<=1", np.where(Y <= 1, X, X + Y)),
                  ("add, but 0 where x=0", np.where(X == 0, 0, X + Y))):
    i = find(tab)
    dist = (F != F[i]).sum(axis=1)
    js = np.nonzero((dist == 1) & (K <= K[i]))[0]
    print(f"   {name} (K={K[i]}, R={R[i]}, distance to addition {int((F[i] != F[add]).sum())}): "
          + ("; ".join(f"size {K[j]}" + (" = addition" if j == add else "") + " at "
                       + ",".join(f"({p // 6},{p % 6}):{F[i][p]}->{F[j][p]}" for p in np.nonzero(F[j] != F[i])[0])
                       for j in js) or "none"))

print("\n5. prior weight 8^-K by size (sum over functions of that size), and the ratio between sizes")
w = [float((K == s).sum()) * 8.0 ** (-s) for s in range(1, 12)]
print("   " + " ".join(f"{s}:{w[s - 1]:.2e}" for s in range(1, 12)))
print("   ratio w(11)/w(10) = %.3f; geometric extrapolation of the tail above 11: %.2e (compare 8^-5 = %.2e, 8^-2 = %.2e)"
      % (w[10] / w[9], w[10] * (w[10] / w[9]) / (1 - w[10] / w[9]), 8.0 ** -5, 8.0 ** -2))
