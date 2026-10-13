"""v4: independent checks in the parity classes C_k and C_{k,M} (iid notes-final Prop 5.1(b'), Remark 4.5,
Lemma 8.1(iv), Remark 4.7).  Written for verify-iid.md; it does not import or read any record script.

Setting (iid Prop 5.1).  Inputs uniform on {0,1}^D, fresh fair-coin labels (PQ).  C_k: the coin (length k) and
the parities f_{m,w}, 1 <= m <= D, w in {0,1}^m, of length l(m) = m + 2*ceil(log2(m+1)) + 1.  C_{k,M}: the coin and
the 2^M parities on the first M bits, each of length M + 2.

Tools.
  * GF(2) rank law of a uniform n x m matrix, written here from the q-binomial count
        #{rank r} = [m r]_2 * prod_{i<r} (2^n - 2^i),
    i.e. P(rank = r) = 2^{-(n-r)(m-r)} phi(m-r+1, m) phi(n-r+1, n) / phi(1, r),  phi(a,b) = prod_{t=a}^b (1-2^-t).
    Cross-checked (T1) against brute-force enumeration of all matrices (exact fractions, n*m <= 16),
    (T2) against an exact row-by-row Markov chain (fractions, n, m <= 30), and
    (T3) against a Monte Carlo that draws A and y and decides solvability of A w = y by Gaussian elimination.
  * P(n) := P[set of 1-MAPs != {coin}] = E[2^{rank(A_{n x m*}) - n}], m*(n) = max{m >= 1 : l(m) <= k + n}
    (ties included); the reduction to "y in colspan(A_{n x m*})" is re-derived in verify-iid.md.

Parts.
  (A) Prop 5.1(b'): P(n) <= 2^{k+1}/n^2 on every integer n in [32, N] for k = 4..40 (D >= m*; capping at a finite
      D only lowers P).  Certified recovery times n_rec(eps) for even k in 14..40 and eps in {0.5,0.1,0.01,0.001},
      checked against the bracket (2^{(k-8)/2} - 6, max(32, ceil(2^{(k+1)/2}/sqrt eps))].  The scan is certified by
      the nonincreasing bound 2^{m*(n)-n} (a consequence of rank <= m* only).  Also: n_rec(0.01) = 2^{(k+4)/2}+6?
  (B) Remark 4.5, exact arithmetic: the tie, delta_n, the gap, and the invertibility probability; and a Monte
      Carlo of the lambda-MAP set by Gaussian elimination at (k, lambda) = (20, 2) and (16, 1.25).
  (C) Lemma 8.1(iv): brute force over all 2^M parities in small C_{k,M}; the excess rho(l0)-rho(alpha)-(alpha-l0)
      equals k-7 on the event that a parity is consistent; the event's probability from the rank law.
  (D) Remark 4.7 in the parity classes: the free-exponent bound (iv') at lambda = 1 with the per-program optimal
      s, and with one fixed s < 1, in C_k with D finite and D = infinity, and in C_{k,M}.
Deterministic except (B) and (C) Monte Carlo (seed 4401) and (T3) (seed 4402).
"""
import itertools
import math
from fractions import Fraction as Fr

import numpy as np
import mpmath as mp

mp.mp.dps = 50
LN2 = math.log(2)

# ----------------------------------------------------------------------------- GF(2) rank law
TMAX = 400
_lphi = np.zeros(TMAX + 1)
for t in range(1, TMAX + 1):
    _lphi[t] = _lphi[t - 1] + math.log1p(-2.0 ** -t)


def lphi(a, b):
    """log prod_{t=a}^{b} (1 - 2^-t), vectorised; empty product -> 0.  Terms beyond TMAX are < 1e-120."""
    a = np.minimum(np.maximum(a, 1), TMAX + 1)
    b = np.minimum(b, TMAX)
    return np.where(b >= a, _lphi[np.maximum(b, 0)] - _lphi[np.maximum(a - 1, 0)], 0.0)


def e_two_rank_minus_n(n, m, J=14):
    """E[2^{rank - n}] for a uniform n x m GF(2) matrix (n, m arrays of positive ints)."""
    n = np.asarray(n, dtype=np.int64)
    m = np.asarray(m, dtype=np.int64)
    r0 = np.minimum(n, m)
    tot = np.zeros(np.broadcast(n, m).shape)
    for j in range(J):
        r = r0 - j
        ok = r >= 0
        rr = np.where(ok, r, 0)
        lp = (-(n - rr) * (m - rr) * LN2 + lphi(m - rr + 1, m) + lphi(n - rr + 1, n) - lphi(1, rr))
        tot += np.where(ok, np.exp(lp - (n - rr) * LN2), 0.0)
    return tot


def rank_gf2(rows, ncols):
    """rank over GF(2) of a list of int bitmasks."""
    basis = []
    for v in rows:
        for b in basis:
            v = min(v, v ^ b)
        if v:
            basis.append(v)
    return len(basis)


def solvable(A_rows, y_bits, m):
    """Is A w = y solvable?  A_rows: list of n ints (m-bit rows), y_bits: list of n bits.  Augmented-rank test."""
    aug = [(r << 1) | yb for r, yb in zip(A_rows, y_bits)]
    return rank_gf2(aug, m + 1) == rank_gf2(A_rows, m)


def count_solutions(A_rows, y_bits, m):
    if not solvable(A_rows, y_bits, m):
        return 0
    return 2 ** (m - rank_gf2(A_rows, m))


print("=" * 100)
print("(T) the rank law used below")
# T1 brute force
maxdiff = Fr(0)
for n in range(1, 9):
    for m in range(1, 9):
        if n * m > 16:
            continue
        tot = Fr(0)
        for rows in itertools.product(range(2 ** m), repeat=n):
            tot += Fr(2 ** rank_gf2(list(rows), m), 2 ** n)
        exact = tot / (2 ** (n * m))
        val = float(e_two_rank_minus_n(np.array([n]), np.array([m]))[0])
        maxdiff = max(maxdiff, abs(Fr(val) - exact))
print(f"  T1 brute force over all n x m matrices with n*m <= 16: max |closed form - exact| = {float(maxdiff):.2e}")


# T2 exact row chain (rows of the transpose: m rows in F_2^n; rank r -> r+1 w.p. 1 - 2^{r-n})
def chain(n, m):
    dist = {0: Fr(1)}
    for _ in range(m):
        new = {}
        for r, p in dist.items():
            up = 1 - Fr(2 ** r, 2 ** n)
            new[r + 1] = new.get(r + 1, 0) + p * up
            new[r] = new.get(r, 0) + p * (1 - up)
        dist = new
    return sum(p * Fr(2 ** r, 2 ** n) for r, p in dist.items())


md = 0.0
for n in range(1, 31, 3):
    for m in range(1, 31, 4):
        md = max(md, abs(float(chain(n, m)) - float(e_two_rank_minus_n(np.array([n]), np.array([m]))[0])))
print(f"  T2 exact transpose-row chain, n, m <= 30: max difference = {md:.2e}")
# T3 Monte Carlo with Gaussian elimination
rng3 = np.random.default_rng(4402)
for n, m in [(10, 12), (20, 18), (30, 35), (40, 40)]:
    R = 20000
    hits = 0
    for _ in range(R):
        rows = [int(v) for v in rng3.integers(0, 2 ** min(m, 62), size=n)] if m <= 62 else None
        if m > 62:
            raise ValueError
        y = [int(v) for v in rng3.integers(0, 2, size=n)]
        hits += solvable(rows, y, m)
    p = float(e_two_rank_minus_n(np.array([n]), np.array([m]))[0])
    se = math.sqrt(p * (1 - p) / R)
    print(f"  T3 n={n:2d} m={m:2d}: MC P[y in colspan] = {hits / R:.4f}, closed form {p:.4f}, "
          f"z = {(hits / R - p) / se:+.2f}")


# ----------------------------------------------------------------------------- (A) Prop 5.1(b')
def ell_m(m):
    m = np.asarray(m, dtype=np.int64)
    bl = np.zeros_like(m)
    for j in range(1, 64):
        bl = np.where(m >= (1 << (j - 1)), j, bl)        # bit_length(m) = ceil(log2(m+1)) for m >= 1
    return m + 2 * bl + 1


def mstar(n, k):
    """max{m >= 1 : l(m) <= k + n}, 0 if none (lambda = 1, ties included)."""
    n = np.asarray(n, dtype=np.int64)
    best = np.zeros_like(n)
    for j in range(1, 64):
        lo, hi = 1 << (j - 1), (1 << j) - 1
        cap = k + n - 1 - 2 * j                          # l(m) <= k + n  <=>  m <= k + n - 1 - 2j on block j
        cand = np.minimum(hi, cap)
        best = np.where(cand >= lo, np.maximum(best, cand), best)
    return best


# sanity: mstar against brute force
for k in (5, 16, 23):
    for n in list(range(1, 200)) + [1000, 5000]:
        ms = max([m for m in range(1, n + k + 2) if m + 2 * m.bit_length() + 1 <= k + n] or [0])
        assert ms == int(mstar(np.array([n]), k)[0]), (k, n)


def P_lambda1(n, k):
    ms = mstar(n, k)
    return np.where(ms >= 1, e_two_rank_minus_n(n, np.maximum(ms, 1)), 0.0)


print("=" * 100)
print("(A) Prop 5.1(b'): P(n) <= 2^{k+1}/n^2 for n >= 32 (lambda = 1, C_k with D >= m*)")
CH = 2_000_000
worst_overall = 0.0
for k in range(4, 41):
    N = min(20_000_000, max(100_000, int(64 * 2 ** ((k + 1) / 2))))
    worst = 0.0
    viol = 0
    for s0 in range(32, N + 1, CH):
        n = np.arange(s0, min(N, s0 + CH - 1) + 1, dtype=np.int64)
        P = P_lambda1(n, k)
        ratio = P * n.astype(float) ** 2 / 2.0 ** (k + 1)
        worst = max(worst, float(ratio.max()))
        viol += int((ratio > 1 + 1e-12).sum())
    worst_overall = max(worst_overall, worst)
    if k % 4 == 0 or viol:
        print(f"  k={k:2d}: scanned n in [32, {N}]: max P(n) n^2 / 2^(k+1) = {worst:.4f}, violations = {viol}")
print(f"  over k = 4..40: max ratio = {worst_overall:.4f}")


def n_rec(k, eps):
    """least n0 with P(n) <= eps for all n >= n0; certified by 2^{m*(n)-n} <= eps (nonincreasing in n)."""
    last_bad = 0
    s0 = 1
    while True:
        n = np.arange(s0, s0 + CH, dtype=np.int64)
        P = P_lambda1(n, k)
        bad = np.flatnonzero(P > eps)
        if bad.size:
            last_bad = int(n[bad[-1]])
        ms = mstar(n, k)
        cert = np.flatnonzero((ms - n).astype(float) <= math.log2(eps))
        # certify at the first n in this chunk beyond last_bad where 2^{m*-n} <= eps
        cert = cert[n[cert] > last_bad]
        if cert.size:
            # m*(n) - n is nonincreasing, so P <= 2^{m*-n} <= eps from there on
            assert np.all(np.diff((ms - n)[cert[0]:]) <= 0)
            return last_bad + 1
        s0 += CH


print("  certified recovery times n_rec(eps) and the bracket of (b'):")
ok_all = True
for k in range(14, 41, 2):
    row = []
    for eps in (0.5, 0.1, 0.01, 0.001):
        if k == 40 and eps == 0.001:
            row.append("   (skipped)")
            continue
        nr = n_rec(k, eps)
        lo = 2 ** ((k - 8) / 2) - 6
        hi = max(32, math.ceil(2 ** ((k + 1) / 2) / math.sqrt(eps)))
        ok = lo < nr <= hi
        ok_all &= ok
        row.append(f"{nr:>9d}{'' if ok else '!'}")
    tag = ""
    if k in (16, 24, 32, 40):
        tag = f"   n_rec(0.01) - 2^((k+4)/2) = {n_rec(k, 0.01) - 2 ** ((k + 4) // 2)}"
    print(f"    k={k:2d}: eps=0.5,0.1,0.01,0.001 -> " + " ".join(row) + tag)
print(f"  every certified n_rec lies in the bracket: {ok_all}")
# lower end: at n_b = 2^{(k-8)/2}-6 the exact P is >= 31/32
for k in (16, 20, 24, 32, 40):
    nb = 2 ** ((k - 8) // 2) - 6
    assert 2 * (nb + 5).bit_length() + 6 < k and not 2 * (nb + 6).bit_length() + 6 < k
    print(f"  k={k}: n_b = {nb}: strict condition holds at n_b and fails at n_b+1; exact P(n_b) = "
          f"{float(P_lambda1(np.array([nb]), k)[0]):.5f} (>= 31/32 = 0.96875)")

# ----------------------------------------------------------------------------- (B) Remark 4.5
print("=" * 100)
print("(B) Remark 4.5: C_{k,M}, M = n = lambda (k-2)/(lambda-1)")
for k, lam in [(20, Fr(2)), (20, Fr(3, 2)), (30, Fr(3)), (16, Fr(5, 4)), (40, Fr(2)), (10, Fr(5)), (7, Fr(6))]:
    n = lam * (k - 2) / (lam - 1)
    assert n.denominator == 1
    n = int(n)
    J_par = lam * (n + 2)
    J_coin = lam * k + n
    delta_n = mp.log(mp.mpf(2) ** -k + mp.mpf(1) / 4, 2)
    bound = (mp.mpf(lam.numerator) / lam.denominator * k + delta_n) / (mp.mpf(lam.numerator) / lam.denominator - 1)
    gap = bound - (n + 2)
    claimed_gap = mp.log(1 + mp.mpf(2) ** (2 - k), 2) / (mp.mpf(lam.numerator) / lam.denominator - 1)
    upper = mp.mpf(2) ** (2 - k) / ((mp.mpf(lam.numerator) / lam.denominator - 1) * mp.log(2))
    pinv = mp.nprod(lambda i: 1 - mp.mpf(2) ** (-i), [1, n])
    print(f"  k={k:2d} lambda={str(lam):>4}: n={n:3d}, l(phi)={n + 2:3d} = (lambda k - 2)/(lambda-1) = "
          f"{(lam * k - 2) / (lam - 1)}; J(phi)=J(coin): {J_par == J_coin}; gap = {mp.nstr(gap, 6)} "
          f"(= claimed: {mp.almosteq(gap, claimed_gap, 1e-40)}; <= 2^(2-k)/((lam-1)ln2) = {mp.nstr(upper, 4)}: "
          f"{gap <= upper}); P[A invertible] = {mp.nstr(pinv, 8)}")
print(f"  infinite product prod (1-2^-i) = {mp.nstr(mp.nprod(lambda i: 1 - mp.mpf(2) ** (-i), [1, mp.inf]), 10)}")

rngB = np.random.default_rng(4401)
for k, lam in [(20, 2.0), (16, 1.25)]:
    n = round(lam * (k - 2) / (lam - 1))
    R = 4000
    exactly_two = 0
    attained = 0
    for _ in range(R):
        rows = [int(v) for v in rngB.integers(0, 2 ** n, size=n)] if n <= 62 else \
            [int.from_bytes(rngB.bytes((n + 7) // 8), "little") & ((1 << n) - 1) for _ in range(n)]
        y = [int(v) for v in rngB.integers(0, 2, size=n)]
        c = count_solutions(rows, y, n)
        # MAP set: coin (J = lam k + n) and the c consistent parities (J = lam (n+2), equal); others J = inf
        if c == 1:
            exactly_two += 1
            xi_over_nu = 2.0 ** -k + c * 2.0 ** -(n + 2) * 2.0 ** n
            dn = math.log2(xi_over_nu)
            bnd = (lam * k + dn) / (lam - 1)
            attained += abs(bnd - (n + 2) - math.log2(1 + 2 ** (2 - k)) / (lam - 1)) < 1e-9
    print(f"  MC (k={k}, lambda={lam}, n={n}, {R} runs): P[MAP set = {{coin, one parity}}] = {exactly_two / R:.4f} "
          f"(claimed prod = 0.2888); on that event the gap to the delta_n-bound matched in {attained}/{exactly_two}")

# ----------------------------------------------------------------------------- (C) Lemma 8.1(iv)
print("=" * 100)
print("(C) Lemma 8.1(iv): excess rho(l0) - rho(alpha) - (alpha - l0) in C_{k,M}, n = M - 5, alpha = M + 2")
rngC = np.random.default_rng(4401 + 1)
for k, M in [(10, 12), (12, 11), (9, 14)]:
    n = M - 5
    assert M + 2 > k and n >= 1
    R = 3000
    ev = 0
    exc_ok = 0
    allw = np.arange(2 ** M)
    for _ in range(R):
        X = rngC.integers(0, 2 ** M, size=n)                       # first M bits of the inputs
        y = rngC.integers(0, 2, size=n)
        # brute force over all 2^M parities: consistent iff <w, x_i> = y_i for all i
        par = np.zeros((2 ** M, n), dtype=np.int64)
        for i in range(n):
            v = np.bitwise_and(allw, X[i])
            pc = np.zeros_like(v)
            vv = v.copy()
            while vv.any():
                pc ^= vv & 1
                vv >>= 1
            par[:, i] = pc
        cons = np.all(par == y[None, :], axis=1)
        # points: coin (k, n); parity (M+2, 0 if consistent else inf)
        pts = [(k, float(n))] + [(M + 2, 0.0 if c else math.inf) for c in cons]
        rho = lambda a: min([L for l, L in pts if l <= a] or [math.inf])
        if cons.any():
            ev += 1
            excess = rho(k) - rho(M + 2) - (M + 2 - k)
            exc_ok += excess == k - 7
    p_exact = float(e_two_rank_minus_n(np.array([n]), np.array([M]))[0])
    print(f"  k={k:2d} M={M:2d} n={n}: MC P[a parity is consistent] = {ev / R:.4f} (rank law: {p_exact:.4f}, "
          f">= 31/32: {p_exact >= 31 / 32}); excess = k-7 = {k - 7} in {exc_ok}/{ev} event runs")
for k in (16, 24, 32):
    for M in (k, k + 10, k + 100):
        n = M - 5
        p = float(e_two_rank_minus_n(np.array([n]), np.array([M]))[0])
        print(f"    rank law: k={k} M={M} n={n}: P[some parity consistent] = {p:.5f}; "
              f"lower bound 31/32 - 2^(7-k) = {31 / 32 - 2.0 ** (7 - k):.5f}")

# ----------------------------------------------------------------------------- (D) Remark 4.7
print("=" * 100)
print("(D) Remark 4.7: the free-exponent bound (iv') at lambda = 1 in the parity classes")
print("  For a total deterministic parity against the coin, rho_s = 2^{s-1}, so the (iv') term of a parity of")
print("  length l is inf_{0<s<=1} 2^{-s(l-k)} 2^{-(1-s)n} = 2^{-max(n, l-k)} (s -> 0+ or s = 1).")


def free_exp_bound_Ck(n, k, D=None):
    """sum over parities of C_k (m = 1..D, D=None: infinity) of 2^m 2^{-max(n, l(m)-k)}; exact via blocks."""
    tot = mp.mpf(0)
    j = 1
    while True:
        lo, hi = 2 ** (j - 1), 2 ** j - 1
        if D is not None:
            hi = min(hi, D)
            if lo > hi:
                break
        # l(m) - k = m + 2j + 1 - k ; split at m <= n + k - 2j - 1
        split = n + k - 2 * j - 1
        a1, b1 = lo, min(hi, split)
        if b1 >= a1:
            tot += (mp.mpf(2) ** (b1 + 1) - mp.mpf(2) ** a1) * mp.mpf(2) ** (-n)
        a2 = max(lo, split + 1)
        if hi >= a2:
            tot += (hi - a2 + 1) * mp.mpf(2) ** (k - 2 * j - 1)
        if D is None and j > 200:
            break
        j += 1
    return tot


def fixed_s_bound_Ck(n, k, s, D):
    """2^{sk} sum_m 2^m 2^{-s l(m)} 2^{-(1-s) n}, m = 1..D."""
    tot = mp.mpf(0)
    for j in range(1, D.bit_length() + 1):
        lo, hi = 2 ** (j - 1), min(2 ** j - 1, D)
        if lo > hi:
            break
        # sum_{m=lo}^{hi} 2^{(1-s) m} = geometric
        r = mp.mpf(2) ** (1 - s)
        tot += (r ** (hi + 1) - r ** lo) / (r - 1) * mp.mpf(2) ** (-s * (2 * j + 1))
    return mp.mpf(2) ** (s * k) * tot * mp.mpf(2) ** (-(1 - s) * n)


k = 16
print(f"  C_k, k = {k}, D = infinity (Z(s) = infinity for every s < 1):")
for n in (10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6, 10 ** 7, 10 ** 8):
    B = free_exp_bound_Ck(n, k)
    print(f"    n = {n:>9d}: per-program-s bound = {mp.nstr(B, 5):>10}; bound * n / 2^k = {mp.nstr(B * n / 2 ** k, 5)}; "
          f"exact P(n) = {float(P_lambda1(np.array([n]), k)[0]):.3e}")
print("  C_k, k = 16, finite D: the fixed-s form 2^{sk} Z_par(s) 2^{-(1-s)n} at n = 10^4 grows with D:")
for s in (0.5, 0.9):
    vals = [mp.nstr(fixed_s_bound_Ck(10 ** 4, k, s, D), 3) for D in (100, 10 ** 3, 10 ** 4, 10 ** 5)]
    print(f"    s = {s}: D = 1e2, 1e3, 1e4, 1e5 -> {vals}")
print("  C_{k,M}: per-program-s bound at lambda = 1 is 2^{M - max(n, M+2-k)}:")
for M in (30, 60, 120):
    row = []
    for n in (10, M - 10, M, M + 10, M + 20):
        row.append(f"n={n}: {mp.nstr(mp.mpf(2) ** (M - max(n, M + 2 - k)), 3)}")
    print(f"    k=16, M={M}: " + ", ".join(row))
print("done")
