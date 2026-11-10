"""Isolation and pinning margins in the enumerated language (see enumerate_pr.py).

Usage: python3 analyze.py ENUM.npz NEAREST.npy [SEED]

Part 1. Isolation of named functions: for each Hamming radius r, the least size of a function
        g != f within distance r of f.
Part 2. How many functions are isolated, by size and by scale.
Part 3. Pinning margins from random data: the smallest consistent hypothesis that disagrees with
        f at a held-out input, among all functions (vanilla) and among isolated functions
        (patch-free).
"""
import sys

import numpy as np

d = np.load(sys.argv[1])
F, K, T = d["F"].astype(np.int16), d["K"].astype(np.int64), d["T"]
prof = np.load(sys.argv[2]).astype(np.int64)     # prof[i, r] = least K(g), g at distance exactly r
seed = int(sys.argv[3]) if len(sys.argv) > 3 else 0
XMAX, VMAX, CAP = int(d["xmax"]), int(d["vmax"]), int(d["maxsize"])
n, NXY = F.shape
X = np.repeat(np.arange(XMAX), XMAX)
Y = np.tile(np.arange(XMAX), XMAX)
BIG = 10 ** 6

# least K of a function g != f at distance <= r
exact = np.where(prof == 0, BIG, prof)
exact[:, 0] = BIG
within = np.minimum.accumulate(exact, axis=1)
# isolation radius: distance to the nearest g != f with K(g) <= K(f)  (NXY + 1 if none)
leq = exact <= K[:, None]
R = np.where(leq.any(axis=1), leq.argmax(axis=1), NXY + 1)

targets = {
    "successor  x+1": np.minimum(X + 1, VMAX),
    "addition   x+y": np.minimum(X + Y, VMAX),
    "monus      x-y": np.maximum(X - Y, 0),
    "product    x*y": np.minimum(X * Y, VMAX),
    "double     2x": np.minimum(2 * X, VMAX),
    "max(x,y)": np.maximum(X, Y),
    "min(x,y)": np.minimum(X, Y),
    "[x = y]": (X == Y).astype(int),
    "[x <= y]": (X <= Y).astype(int),
    "|x - y|": np.abs(X - Y),
    "x+y+1": np.minimum(X + Y + 1, VMAX),
    "add, but 0 where x=0": np.where(X == 0, 0, X + Y),
    "add, but y+1 where x=0": np.where(X == 0, Y + 1, X + Y),
    "add, but 1 at (0,0)": np.where((X == 0) & (Y == 0), 1, X + Y),
    "add, but x where y<=1": np.where(Y <= 1, X, X + Y),
}
index = {F[i].tobytes(): i for i in range(n)}


def find(tab):
    return index.get(np.asarray(tab, dtype=np.int16).tobytes())


print(f"language: sizes <= {CAP}, {n} functions on {XMAX}x{XMAX} inputs")
print("\n== Part 1: isolation of named functions ==")
print("K = least size. R = distance (number of inputs out of 36) to the nearest other function")
print("of size <= K. 'within r' = least size of another function within distance r "
      f"('>{CAP}' = none of size <= {CAP}).")
radii = [1, 2, 3, 5, 6, 8, 11, 17]
print(f"{'function':26s} {'K':>3s} {'R':>4s}  " + " ".join(f"r<={r:<3d}" for r in radii) + "  term")
tidx = {}
for name, tab in targets.items():
    i = find(tab)
    if i is None:
        print(f"{name:26s}  not expressible with size <= {CAP}")
        continue
    tidx[name] = i
    cells = [(str(within[i, r]) if within[i, r] < BIG else f">{CAP}") for r in radii]
    Rs = str(R[i]) if R[i] <= NXY else "none"
    print(f"{name:26s} {K[i]:3d} {Rs:>4s}  " + " ".join(f"{c:>6s}" for c in cells) + f"  {T[i]}")

print("\n== Part 2: how many functions are isolated ==")
print("f is isolated at radius r if every other function within distance < r of f has larger size")
print("(delta = r/36). Entries: number isolated / number of functions of that size.")
rs = [1, 2, 3, 6, 9, 12, 18]
print(f"{'K':>3s} {'count':>7s}  " + " ".join(f"r={r:<6d}" for r in rs))
for k in range(1, CAP + 1):
    m = K == k
    print(f"{k:3d} {m.sum():7d}  " + " ".join(f"{(R[m] >= r).sum():8d}" for r in rs))
m = np.ones(n, dtype=bool)
print(f"{'all':>3s} {m.sum():7d}  " + " ".join(f"{(R >= r).sum():8d}" for r in rs))

print("\n== Part 3: surviving dissent after random data ==")
print("Data: n inputs drawn uniformly with replacement, labelled by f. For each input x outside the")
print("data, dissent(x) = least size of a function consistent with the data whose value at x differs")
print("from f(x). Each cell gives three fractions of (trial, x) pairs:")
print(f"  a = dissent <= K(f)       (f is not yet the strict Occam answer at x)")
print(f"  b = dissent <= K(f) + 2")
print(f"  c = dissent <= {CAP}          (some enumerated function still dissents)")
print("and then e = mean posterior probability of a wrong value at x under the prior 8^-K(g)")
print(f"restricted to the class (functions of size > {CAP} are left out, so e is a lower estimate).")
print("'vanilla' = all functions; 'patch-free r' = functions isolated at radius r.")
rng = np.random.default_rng(seed)
TRIALS = 300
NS = [2, 4, 8, 12, 16, 24, 32, 48]
classes = [("vanilla", np.ones(n, dtype=bool))] + [(f"patch-free r={r}", R >= r) for r in (3, 6, 12)]
W8 = 8.0 ** (-K.astype(float))
for name in ["successor  x+1", "addition   x+y", "monus      x-y", "max(x,y)", "product    x*y"]:
    if name not in tidx:
        continue
    i = tidx[name]
    f = F[i]
    print(f"\n{name} (K = {K[i]}); isolated at radius: "
          + ", ".join(f"r={r}: {'yes' if R[i] >= r else 'no'}" for r in (3, 6, 12)))
    print(f"{'n':>3s}  " + "  ".join(f"{c[0] + '  a/b/c  e':>30s}" for c in classes))
    for nn in NS:
        acc = {c[0]: np.zeros(5) for c in classes}
        for _ in range(TRIALS):
            A = np.unique(rng.integers(0, NXY, size=nn))
            cons = (F[:, A] == f[A]).all(axis=1)
            out = np.setdiff1d(np.arange(NXY), A)
            if len(out) == 0:
                continue
            for cname, cmask in classes:
                sel = cons & cmask
                Ks, Ws = K[sel], W8[sel]
                diff = F[sel][:, out] != f[out][None, :]
                kk = np.where(diff, Ks[:, None], BIG)
                dis = kk.min(axis=0) if len(Ks) else np.full(len(out), BIG)
                err = (diff * Ws[:, None]).sum(axis=0) / Ws.sum() if len(Ks) else np.zeros(len(out))
                acc[cname] += [(dis <= K[i]).sum(), (dis <= K[i] + 2).sum(), (dis <= CAP).sum(),
                               err.sum(), len(out)]
        cells = []
        for cname, cmask in classes:
            if not cmask[i]:
                cells.append("f not in class".rjust(30))
                continue
            a, b, c, e, tot = acc[cname]
            tot = max(tot, 1)
            cells.append(f"{a / tot:.3f}/{b / tot:.3f}/{c / tot:.3f}  {e / tot:.1e}".rjust(30))
        print(f"{nn:3d}  " + "  ".join(cells))
