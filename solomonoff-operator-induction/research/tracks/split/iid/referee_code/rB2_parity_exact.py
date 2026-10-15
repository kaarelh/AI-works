"""rB2 (referee B): the parity classes of notes Prop 5.1 / Prop 4.4(b), by a method independent of i2.

i2 computes P[y in colspan(A)] by a truncated rank Markov chain on a geometric grid of n.  Here:
  * P[y in colspan(A)] = E[2^{rank(A) - n}] for A uniform n x m over GF(2), y uniform and independent,
    is computed from the CLOSED FORM of the rank distribution,
        P[rank = r] = 2^{-(n-r)(m-r)} prod_{i<r} (1-2^{i-n})(1-2^{i-m}) / (1-2^{i-r}),
    vectorised over EVERY integer n (no grid), with exact rational comparisons lambda*l(m) <= lambda*k + n.
  * Brute force: for tiny n, m all 2^{nm} matrices are enumerated; and a seeded Monte Carlo
    (numpy default_rng(2026)) checks the whole reduction by trying EVERY parity w in {0,1}^m for every
    m <= m*, with no use of the span argument, of padding, or of the rank formula.
Claims checked:
  (A) closed form vs brute force; Monte Carlo vs closed form.
  (B) exact recovery times n_rec(0.01) on all integers, against the notes' table (grid values).
      Monotonicity of P(n) in n is checked on the whole range used.
  (C) Prop 5.1(a): C_{k,M}, n = M - 5, lambda = 1: P[a parity is a 1-MAP] >= 31/32 (k >= 8);
      for lambda > 1: P[MAP != coin] <= 2^{k-2-(1-1/lambda) n} for all M.
  (D) Prop 5.1(b) and Prop 4.4(b): P[a parity is a lambda-MAP] >= 31/32 on the stated ranges of n
      (weak event "J(parity) <= J(coin)" and strict event "<").
  (E) Thm 4.1(iv) in C_k: exact <= 0.25 * 2^{k - (1-1/lambda) n} for all n.
  (F) the notes' "P ~ 2^{k-1}/n^2 at lambda = 1 for n > 2^{k/2}": the ratio P n^2 / 2^{k-1}.
"""
from fractions import Fraction as Fr
from math import ceil, log2
import itertools
import numpy as np

rng = np.random.default_rng(2026)
QT = np.zeros(400)
for a in range(1, 400):
    QT[a] = QT[a - 1] + np.log2(1 - 2.0 ** (-a))


def Q(a):
    return QT[np.minimum(a, 399)]


def p_span(n, m, W=80):
    """E[2^{rank - n}], vectorised over arrays n, m (int64, n >= 1, m >= 0)."""
    n = np.asarray(n, dtype=np.int64); m = np.asarray(m, dtype=np.int64)
    rmax = np.minimum(n, m)
    out = np.zeros(np.broadcast(n, m).shape)
    for off in range(W):
        r = rmax - off
        ok = r >= 0
        rr = np.where(ok, r, 0)
        lg = -(n - rr) * (m - rr) + Q(n) - Q(n - rr) + Q(m) - Q(m - rr) - Q(rr) + (rr - n)
        out += np.where(ok, np.exp2(np.maximum(lg, -1100.0)), 0.0)
    return out


def ell(m):
    m = np.asarray(m, dtype=np.int64)
    return m + 2 * np.ceil(np.log2(m + 1)).astype(np.int64) + 1


# exact integer ceil(log2(m+1)) (avoid float issues): bit_length of m
def ell_int(m):
    return m + 2 * (m).bit_length() + 1 if m > 0 else 1


MMAX = 12_000_000
ELL = np.array([0] + [ell_int(m) for m in range(1, 70)], dtype=np.int64)
ms = np.arange(1, MMAX + 1, dtype=np.int64)
bl = np.floor(np.log2(ms)).astype(np.int64) + 1          # bit_length(m) = ceil(log2(m+1))
# fix floating boundaries
bl = np.where(2 ** (bl - 1) > ms, bl - 1, bl)
bl = np.where(2 ** bl <= ms, bl + 1, bl)
ELLV = ms + 2 * bl + 1                                      # l(m) for m = 1..MMAX, increasing
assert all(ELLV[m - 1] == ell_int(m) for m in [1, 2, 3, 4, 7, 8, 1023, 1024, 1025, 65535, 65536])
assert np.all(np.diff(ELLV) > 0)


def mstar(n, k, lam, strict=False):
    """max m >= 1 with lam*l(m) <= lam*k + n (or <), lam a Fraction; 0 if none.  Vectorised in n."""
    p, q = lam.numerator, lam.denominator
    n = np.asarray(n, dtype=np.int64)
    if strict:   # l < k + n q / p  <=>  l <= k + ceil(n q / p) - 1
        bound = k + (-((-n * q) // p)) - 1
    else:        # l <= k + floor(n q / p)
        bound = k + (n * q) // p
    return np.searchsorted(ELLV, bound, side="right")       # number of m with l(m) <= bound


print("=" * 78)
print("(A) closed form vs brute force (all matrices) and vs Monte Carlo over all parities")
mx = 0.0
for n in range(1, 5):
    for m in range(0, 5):
        if n * m > 12:
            continue
        tot = 0
        cols_all = list(itertools.product(range(2 ** n), repeat=m))   # each column as an n-bit integer
        for cols in cols_all:
            span = {0}
            for c in cols:                       # span of the columns, by closure under xor
                span |= {s ^ c for s in span}
            tot += len(span)                     # number of y in the span
        P = tot / (2 ** n * len(cols_all))
        mx = max(mx, abs(P - float(p_span(n, m))))
print(f"  max |closed form - brute force| over n<=4, m<=4 (nm<=12): {mx:.2e}")


def mc_parity_map(n, k, lam, runs, strict=False):
    """Monte Carlo: inputs uniform bits, fair labels; is some parity (any m <= m*) consistent?  Tries all w."""
    m = int(mstar(n, k, lam, strict))
    if m == 0:
        return 0.0, m
    W = np.array(list(itertools.product([0, 1], repeat=m)), dtype=np.int64)    # all w in {0,1}^m
    hits = 0
    for _ in range(runs):
        X = rng.integers(0, 2, size=(n, m))
        y = rng.integers(0, 2, size=n)
        pred = (X @ W.T) % 2                     # (n, 2^m): every parity on the first m bits
        hits += bool(np.any(np.all(pred == y[:, None], axis=0)))
    return hits / runs, m


for (k, lam, n) in [(8, Fr(1), 6), (8, Fr(1), 10), (9, Fr(1), 9), (10, Fr(3, 2), 8), (10, Fr(3, 2), 14),
                    (10, Fr(2), 10), (9, Fr(5, 4), 7)]:
    est, m = mc_parity_map(n, k, lam, 20000)
    ex = float(p_span(n, m)) if m > 0 else 0.0
    se = (ex * (1 - ex) / 20000) ** 0.5
    print(f"  k={k} lambda={str(lam):4s} n={n:3d}: m*={m:2d}  MC (all 2^m parities tried) = {est:.4f}  "
          f"closed form = {ex:.4f}  (|diff|/se = {abs(est - ex) / max(se, 1e-9):.2f})")

print("=" * 78)
print("(B) exact recovery time n_rec(0.01) on ALL integers n (notes' table used a geometric grid)")
NOTES = {16: [1084, 88, 50, 38, 25, 22], 24: [17736, 153, 76, 58, 38, 29],
         32: [290272, 233, 116, 76, 58, 38], 40: [4750753, 308, 153, 101, 76, 50]}
LAMS = [Fr(1), Fr(11, 10), Fr(5, 4), Fr(3, 2), Fr(2), Fr(3)]
EPS = 0.01
for k in [16, 24, 32, 40]:
    out = []
    for j, lam in enumerate(LAMS):
        nmax = 8_000_000 if lam == 1 else 3000
        nrec = None
        worst_up = 0.0
        prev_tail_ok = True
        # scan in chunks; record the last n with P > eps, and check monotonicity
        last_bad = 0
        lastP = None
        for start in range(1, nmax + 1, 500_000):
            n = np.arange(start, min(start + 500_000, nmax + 1), dtype=np.int64)
            m = mstar(n, k, lam)
            P = p_span(n, m)
            bad = np.flatnonzero(P > EPS)
            if len(bad):
                last_bad = int(n[bad[-1]])
            d = np.diff(P)
            worst_up = max(worst_up, float(d.max()) if len(d) else 0.0)
            if lastP is not None:
                worst_up = max(worst_up, float(P[0] - lastP))
            lastP = P[-1]
        nrec = last_bad + 1
        out.append((nrec, NOTES[k][j], worst_up, float(lastP)))
    s = "  ".join(f"lam={str(l):5s}: {a} (notes {b})" for l, (a, b, _, _) in zip(LAMS, out))
    print(f"  k={k}: {s}")
    print(f"        lambda = 1: n_rec - 2^((k+4)/2) = {out[0][0] - 2 ** ((k + 4) // 2)}")
    print(f"        largest increase of P(n) between consecutive n: {max(o[2] for o in out):.2e};"
          f" P at the end of the scanned range: max {max(o[3] for o in out):.1e}")

print("=" * 78)
print("(C) Prop 5.1(a): C_{k,M} (coin of length k; 2^M parities on M bits, length M+2)")
Ms = np.arange(13, 4000, dtype=np.int64)
worst = float(p_span(Ms - 5, Ms).min())     # all 2^M parities; J_1 = M+2 <= k+n iff k >= 7
print(f"  lambda = 1, n = M - 5, M = 13..3999: min P[some parity consistent] = {worst:.6f} (>= 31/32 = {31/32:.6f})")
viol = 0; tight = 0.0
for k in [8, 12, 20]:
    for lam in [Fr(11, 10), Fr(3, 2), Fr(2), Fr(3)]:
        for M in list(range(1, 80)) + [100, 200, 400]:
            n = np.arange(1, 300, dtype=np.int64)
            sel = np.array([lam * (M + 2) <= lam * k + int(v) for v in n])
            P = np.where(sel, p_span(n, np.full_like(n, M)), 0.0)
            B = 2.0 ** (k - 2 - (1 - 1 / float(lam)) * n)
            viol += int(np.sum(P > B * (1 + 1e-12)))
            tight = max(tight, float(np.max(np.where(B < 1, P / B, 0))))
print(f"  lambda > 1: P[MAP != coin] > 2^(k-2-(1-1/lambda)n) in {viol} cases (k in 8,12,20; 4 lambdas; "
      f"M up to 400; n < 300); largest P/bound with bound < 1 = {tight:.3f}")

print("=" * 78)
print("(D) Prop 5.1(b) (lambda = 1) and Prop 4.4(b) (lambda > 1): P[a parity is a lambda-MAP] >= 31/32 on the stated range")
for k in [16, 24, 32]:
    for lam in [Fr(1), Fr(11, 10), Fr(3, 2), Fr(2), Fr(3)]:
        nmax = 2 ** ((k - 6) // 2 + 1) if lam == 1 else 2000
        n = np.arange(1, nmax + 1, dtype=np.int64)
        lg = np.ceil(np.log2(n + 6)).astype(np.int64)
        if lam == 1:
            rngmask = 2 * lg + 6 <= k
        else:
            rngmask = (float(lam) - 1) * n <= float(lam) * (k - 6 - 2 * lg)
        n = n[rngmask]
        if len(n) == 0:
            print(f"  k={k} lambda={lam}: empty range"); continue
        Pw = p_span(n, mstar(n, k, lam))
        Ps = p_span(n, mstar(n, k, lam, strict=True))
        print(f"  k={k} lambda={str(lam):5s}: n in [1,{int(n.max())}]: min P(weak <=) = {Pw.min():.4f}, "
              f"min P(strict <) = {Ps.min():.4f}  (claim >= {31/32:.4f})")

print("=" * 78)
print("(E) Thm 4.1(iv) in C_k: exact P[MAP != coin] <= 0.25 * 2^{k-(1-1/lambda) n}")
viol = 0; tight = 0.0
for k in [16, 24, 32, 40]:
    for lam in LAMS[1:]:
        n = np.arange(1, 3001, dtype=np.int64)
        P = p_span(n, mstar(n, k, lam))
        B = 0.25 * 2.0 ** (k - (1 - 1 / float(lam)) * n)
        viol += int(np.sum(P > B * (1 + 1e-12)))
        sel = (B < 1) & (B > 1e-280)
        tight = max(tight, float(np.max(P[sel] / B[sel])) if sel.any() else 0.0)
print(f"  violations: {viol}; largest exact/bound with 1e-280 < bound < 1: {tight:.3f}")

print("=" * 78)
print("(F) lambda = 1: the ratio P(n) n^2 / 2^{k-1} for n in [2^{k/2+2}, min(2^{k/2+10}, 8e6)]")
for k in [16, 24, 32]:
    n = np.unique(np.geomspace(2 ** (k // 2 + 2), min(2 ** (k // 2 + 10), 8_000_000), 4000).astype(np.int64))
    P = p_span(n, mstar(n, k, Fr(1)))
    r = P * n.astype(float) ** 2 / 2.0 ** (k - 1)
    print(f"  k={k}: ratio in [{r.min():.3f}, {r.max():.3f}]")
