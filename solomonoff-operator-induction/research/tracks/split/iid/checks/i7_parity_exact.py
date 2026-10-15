"""i7: the parity classes of notes-final Prop 5.1, Prop 4.4(b) and Remark 4.5, exactly, on every integer n.
Deterministic, except part (D2), which is seeded with numpy default_rng(7).

Classes (as in i2).
  C_k:     the fair coin (the truth, length k) and, for m >= 1 and w in {0,1}^m, the deterministic parity
           x -> <w, x_{1:m}> mod 2 of length l(m) = m + 2 ceil(log2(m+1)) + 1.  Kraft weight of the parities 1/4.
  C_{k,M}: the coin (length k) and the 2^M parities on the first M bits, each of length M + 2.
Data: inputs uniform on {0,1}^Dlen (Dlen large), labels fresh fair coins per query (the per-query object).

The lambda-MAP set differs from {coin} iff some parity consistent with the labels has lambda l(m) <= lambda k + n
("weak" event; "strict" event: <).  Parities on fewer bits are parities on more bits, so with
m* = max{m >= 1 : lambda l(m) <= lambda k + n} the weak event is {y in colspan(A)} for A uniform n x m* over GF(2)
and y uniform, and its probability is P(n) = E[2^{rank(A) - n}].

Method (independent of i2's truncated Markov chain): the closed-form rank law
    log2 P[rank = r] = -(n-r)(m-r) + Q(n) - Q(n-r) + Q(m) - Q(m-r) - Q(r),   Q(a) = sum_{j<=a} log2(1 - 2^-j),
summed over the W = 48 largest ranks.  It is validated against (D1) exact enumeration of all matrices (Fractions)
and (D2) a Monte Carlo that solves A w = y by Gaussian elimination over GF(2), and (D3) against i2's printed values.

Certified recovery times.  P(n) <= T(n) := 2^{m*(n) - n}, and T is nonincreasing in n when lambda >= 1
(one more sample raises the budget by 1, and one more bit of m costs at least lambda >= 1).  So once T(n) <= eps,
P <= eps at every later n.  n_rec(eps) := 1 + max{n : P(n) > eps} is computed by scanning every integer n up to
that point.  No grid is used.

(A) n_rec(0.01) for k in {16, 24, 32, 40} and lambda in {1, 11/10, 5/4, 3/2, 2, 3}.
(B) lambda = 1: n_rec - 2^((k+4)/2); the ratio P(n) n^2 / 2^(k-1) on [2^(k/2+2), end of scan];
    the proved bound P(n) <= 2^(k+1)/n^2 for n >= 32 (Prop 5.1(b')).
(C) Prop 5.1(b) and Prop 4.4(b) with the strict condition: min P[strict event] over the stated n range.
(E) Remark 4.5: tightness of Thm 4.1(i) in C_{k,M} with M = n = lambda (k-2)/(lambda-1).
"""
import itertools
import math
from fractions import Fraction as Fr

import numpy as np

AMAX = 400
QT = np.zeros(AMAX + 1)
for a in range(1, AMAX + 1):
    QT[a] = QT[a - 1] + math.log2(1.0 - 2.0 ** (-a))


def Qf(a):
    return QT[np.minimum(a, AMAX)]


def p_span(n, m, W=48):
    """E[2^{rank(A) - n}] for A uniform n x m over GF(2); arrays n >= 1, m >= 0 (m = 0 gives 2^{-n})."""
    n = np.asarray(n, dtype=np.int64)
    m = np.asarray(m, dtype=np.int64)
    rmax = np.minimum(n, m)
    tot = np.zeros(np.broadcast(n, m).shape)
    for j in range(W):
        r = rmax - j
        ok = r >= 0
        rr = np.where(ok, r, 0)
        lp = (-(n - rr).astype(np.float64) * (m - rr).astype(np.float64)
              + Qf(n) - Qf(n - rr) + Qf(m) - Qf(m - rr) - Qf(rr) + (rr - n))
        tot += np.where(ok, np.exp2(np.maximum(lp, -2000.0)), 0.0)
    return tot


MMAX = 40_000_000
_m = np.arange(1, MMAX + 1, dtype=np.int64)
_bl = np.floor(np.log2(_m)).astype(np.int64) + 1          # bit_length(m) = ceil(log2(m+1)) for m >= 1
ELL = _m + 2 * _bl + 1                                       # l(m), increasing
assert all(int(ELL[i]) == (i + 1) + 2 * math.ceil(math.log2(i + 2)) + 1 for i in range(0, 5000))
del _m, _bl


def ell(m):
    return m + 2 * math.ceil(math.log2(m + 1)) + 1


def mstar(n, k, lam, strict=False):
    """max{m >= 1 : lam*l(m) <= lam*k + n} (strict: <), vectorised over n; 0 if none."""
    a, b = lam.numerator, lam.denominator                    # lam = a/b
    bn = b * n
    if strict:
        B = k + (-(-bn // a)) - 1                            # l - k < bn/a  <=>  l - k <= ceil(bn/a) - 1
    else:
        B = k + bn // a                                      # l - k <= bn/a <=> l - k <= floor(bn/a)
    return np.searchsorted(ELL, B, side="right").astype(np.int64)


def scan(k, lam, eps, chunk=2_000_000, nmax=60_000_000):
    """Exact P(n) on every n until the certificate T(n) <= eps; returns n_rec, n_T and the arrays (lambda=1 only)."""
    last_bad = 0
    n0 = 1
    keep_n, keep_p = [], []
    while n0 <= nmax:
        n = np.arange(n0, n0 + chunk, dtype=np.int64)
        ms = mstar(n, k, lam)
        assert ms.max() < MMAX - 10
        T = np.exp2((ms - n).astype(np.float64))
        P = p_span(n, ms)
        assert np.all(P <= T * (1 + 1e-9) + 1e-300)
        good = np.flatnonzero(T <= eps)
        stop = good[0] if len(good) else len(n)
        bad = np.flatnonzero(P[:stop] > eps)
        if len(bad):
            last_bad = int(n[bad[-1]])
        if lam == 1:
            keep_n.append(n[:stop]); keep_p.append(P[:stop])
        if len(good):
            nT = int(n[good[0]])
            if lam == 1:
                return last_bad + 1, nT, np.concatenate(keep_n), np.concatenate(keep_p)
            return last_bad + 1, nT, None, None
        n0 += chunk
    raise RuntimeError("certificate not reached")


LAMS = [Fr(1), Fr(11, 10), Fr(5, 4), Fr(3, 2), Fr(2), Fr(3)]
NOTES_GRID = {16: [1084, 88, 50, 38, 25, 22], 24: [17736, 153, 76, 58, 38, 29],
              32: [290272, 233, 116, 76, 58, 38], 40: [4750753, 308, 153, 101, 76, 50]}
REFEREE_B = {16: [1030, 78, 46, 34, 23, 20], 24: [16390, 144, 76, 52, 38, 29],
             32: [262150, 232, 116, 70, 51, 38], 40: [4194310, 298, 146, 94, 67, 50]}

print("=" * 78)
print("(D1) closed form vs exact enumeration of all n x m matrices over GF(2) (Fractions)")


def rank_gf2(rows):
    rows = list(rows)
    r = 0
    for bit in reversed(range(64)):
        piv = None
        for i in range(r, len(rows)):
            if rows[i] >> bit & 1:
                piv = i
                break
        if piv is None:
            continue
        rows[r], rows[piv] = rows[piv], rows[r]
        for i in range(len(rows)):
            if i != r and rows[i] >> bit & 1:
                rows[i] ^= rows[r]
        r += 1
    return r


worst = 0.0
for n in range(1, 5):
    for m in range(0, 5):
        if n * m > 16:
            continue
        tot = Fr(0)
        for A in itertools.product(range(2 ** m), repeat=n):
            tot += Fr(2) ** (rank_gf2(A) - n)
        exact = tot / Fr(2) ** (n * m)
        cf = float(p_span(np.array([n]), np.array([m]))[0])
        worst = max(worst, abs(cf - float(exact)))
print(f"  max |closed form - enumeration| over n <= 4, m <= 4, nm <= 16: {worst:.2e}")
assert worst < 1e-12

print("=" * 78)
print("(D2) closed form vs Monte Carlo that solves A w = y over GF(2) (seed 7, 20000 runs per point)")
rng = np.random.default_rng(7)


def solvable(A_rows, y, m):
    """A_rows: list of ints (m bits), y: list of bits.  Is A w = y solvable over GF(2)?"""
    rows = [(a << 1) | b for a, b in zip(A_rows, y)]       # augmented rows; bit 0 is the right-hand side
    r = 0
    for bit in reversed(range(1, m + 1)):
        piv = None
        for i in range(r, len(rows)):
            if rows[i] >> bit & 1:
                piv = i
                break
        if piv is None:
            continue
        rows[r], rows[piv] = rows[piv], rows[r]
        for i in range(len(rows)):
            if i != r and rows[i] >> bit & 1:
                rows[i] ^= rows[r]
        r += 1
    return all(row != 1 for row in rows[r:])                  # no row 0...0 | 1


for (k, lam, n) in [(8, Fr(1), 6), (8, Fr(1), 10), (10, Fr(3, 2), 14), (10, Fr(2), 10), (12, Fr(1), 20),
                    (12, Fr(5, 4), 30)]:
    ms = int(mstar(np.array([n]), k, lam)[0])
    hits = 0
    R = 20000
    for _ in range(R):
        A = [int(v) for v in rng.integers(0, 2 ** ms, size=n)] if ms > 0 else [0] * n
        y = [int(v) for v in rng.integers(0, 2, size=n)]
        hits += solvable(A, y, ms)
    pmc = hits / R
    pcf = float(p_span(np.array([n]), np.array([ms]))[0])
    se = math.sqrt(max(pcf * (1 - pcf), 1e-12) / R)
    print(f"  k={k:2d} lambda={str(lam):5s} n={n:3d} m*={ms:3d}: MC {pmc:.4f}  closed form {pcf:.4f}  |diff|/se = {abs(pmc - pcf) / se:.2f}")

print("=" * 78)
print("(D3) closed form vs i2's printed exact values (i2_parity_fillins.out, part (B))")
for (k, lam, n, i2val) in [(16, Fr(5, 4), 113, 2.38e-07), (16, Fr(2), 45, 3.81e-06), (16, Fr(3), 33, 7.63e-06),
                           (32, Fr(5, 4), 193, 5.96e-08), (32, Fr(2), 77, 9.54e-07), (32, Fr(3), 57, 1.91e-06)]:
    ms = mstar(np.array([n]), k, lam)
    v = float(p_span(np.array([n]), ms)[0])
    print(f"  k={k} lambda={str(lam):4s} n={n}: closed form {v:.3g}   i2 {i2val:.3g}")

print("=" * 78)
print("(A) exact recovery times n_rec(0.01) on every integer n, certified by T(n) = 2^(m*(n)-n) <= 0.01")
EPS = 0.01
results = {}
for k in (16, 24, 32, 40):
    row = []
    for lam in LAMS:
        nrec, nT, nn, pp = scan(k, lam, EPS)
        row.append(nrec)
        if lam == 1:
            results[k] = (nn, pp, nT)
    results[(k, "row")] = row
    s = "  ".join(f"lam={str(l):5s}: {r:7d}" for l, r in zip(LAMS, row))
    print(f"  k={k}: {s}")
    print(f"        notes.md (grid): {NOTES_GRID[k]}")
    print(f"        referee B rB2:   {REFEREE_B[k]}   agree with this scan: {row == REFEREE_B[k]}")

print("=" * 78)
print("(B) lambda = 1 in C_k")
for k in (16, 24, 32, 40):
    nn, pp, nT = results[k]
    nrec = results[(k, "row")][0]
    lo = 2 ** (k // 2 + 2)
    sel = nn >= lo
    ratio = pp[sel] * nn[sel].astype(float) ** 2 / 2.0 ** (k - 1)
    sel32 = nn >= 32
    viol = int(np.sum(pp[sel32] > 2.0 ** (k + 1) / nn[sel32].astype(float) ** 2))
    inc = float(np.max(np.diff(pp))) if len(pp) > 1 else 0.0
    print(f"  k={k}: n_rec - 2^((k+4)/2) = {nrec - 2 ** ((k + 4) // 2)};  certificate reached at n = {nT};"
          f"  ratio P n^2/2^(k-1) on [2^(k/2+2), {nT}) in [{ratio.min():.3f}, {ratio.max():.3f}];"
          f"  violations of P <= 2^(k+1)/n^2 (n >= 32): {viol};  largest increase of P between consecutive n: {inc:.1e}")

print("=" * 78)
print("(C) strict conditions: P[some parity has J < J(coin)] for every n in the stated range (claim >= 31/32)")
for k in (16, 24, 32):
    for lam in [Fr(1), Fr(11, 10), Fr(3, 2), Fr(2), Fr(3)]:
        # stated range: (lambda - 1) n < lambda (k - 6 - 2 ceil(log2(n+6)))   (lambda = 1: 2 ceil(log2(n+6)) + 6 < k)
        ns = [n for n in range(1, 100000)
              if (lam - 1) * n < lam * (k - 6 - 2 * math.ceil(math.log2(n + 6)))]
        if not ns:
            print(f"  k={k} lambda={str(lam):5s}: empty range")
            continue
        n = np.array(ns, dtype=np.int64)
        ms = mstar(n, k, lam, strict=True)
        assert np.all(ms >= n + 5)
        P = p_span(n, ms)
        print(f"  k={k} lambda={str(lam):5s}: n in [1, {ns[-1]}]: min P(strict) = {P.min():.4f}  (31/32 = {31 / 32:.4f})")

print("=" * 78)
print("(E) Remark 4.5: C_{k,M}, M = n = lambda (k-2)/(lambda-1): a consistent parity ties the coin")
for k, lam in [(20, Fr(2)), (20, Fr(3, 2)), (30, Fr(3)), (16, Fr(5, 4)), (40, Fr(2))]:
    nF = lam * (k - 2) / (lam - 1)
    assert nF.denominator == 1
    n = int(nF)
    M = n
    Jpar = lam * (M + 2)
    Jcoin = lam * k + n
    assert Jpar == Jcoin
    pfull = math.prod(1 - 2.0 ** (-i) for i in range(1, n + 1))
    delta_n = math.log2(0.25 + 2.0 ** (-k))
    bound = (float(lam) * k + delta_n) / (float(lam) - 1)
    gap = bound - (M + 2)
    print(f"  k={k} lambda={str(lam):4s}: n=M={n}, parity length {M + 2} = (lambda k - 2)/(lambda - 1) = "
          f"{float((lam * k - 2) / (lam - 1)):.1f}; J(parity) = J(coin) = {float(Jcoin):.1f}; "
          f"P[A invertible] = {pfull:.4f}; bound (lambda k + delta_n)/(lambda-1) - length = {gap:.2e} "
          f"(= log2(1+2^(2-k))/(lambda-1) = {math.log2(1 + 2.0 ** (2 - k)) / (float(lam) - 1):.2e})")
print("  On {A invertible} exactly one parity is consistent, so delta_n = log2(1/4 + 2^-k) and the MAP set is {coin, parity}.")
