"""rB7 (referee B): two small checks.  Seeded: numpy default_rng(71).

(A) lambda_n = c n (notes Prop 3.4 and the sentence after it: "the selection is governed by the
    population hull").  In a finite class (the notes' i1 class, rebuilt here), simulate per-query data
    and record the c n-MAP at n = 10^4 and 10^5, for c on a grid across the switching value
    c* = 0.1348; compare with the population minimiser of c l + R.  200 runs per c.
(B) Tightness of Thm 4.1(i) (length bound (lambda l* + delta)/(lambda - 1)) in the parity class
    C_{k,M} of notes Prop 5.1: fair-coin truth (length k), 2^M parities on M bits (length M+2).  At
    n with lambda (M+2) <= lambda k + n a consistent parity is the MAP; compare its length with the bound
    computed from the deficiency delta_n = log2(xi_n / L_n(nu)) at that n (exact: xi_n counts the
    consistent parities, 2^{M - rank}, when y is in the span).
"""
import numpy as np
from math import log2

rng = np.random.default_rng(71)

print("=" * 78)
print("(A) lambda_n = c n in the i1 class: empirical c n-MAP vs population minimiser of c l + R")
MU = np.array([0.5, 0.5]); NU1 = np.array([0.1, 0.8])
C = {"t5": (5, [0.1, 0.8]), "t7": (7, [0.1, 0.8]), "coin": (2, [0.5, 0.5]), "s3": (3, [0.1, 0.1]),
     "near": (4, [0.1, 0.4]), "far6": (6, [0.5, 0.8]), "det": (3, [0.0, 1.0])}
# (sub6 omitted: a sub-probability kernel never minimises here)
names = list(C)
lens = np.array([C[k][0] for k in names], float)
K1 = np.array([C[k][1] for k in names])
with np.errstate(divide="ignore"):
    L1, L0 = np.log2(K1), np.log2(1 - K1)
R = np.array([sum(MU[x] * (-(NU1[x] * L1[i, x] if NU1[x] > 0 else 0) - (1 - NU1[x]) * L0[i, x])
                  for x in range(2)) for i in range(len(names))])
for c in [0.05, 0.10, 0.12, 0.13, 0.14, 0.15, 0.2, 0.4]:
    pop = names[int(np.argmin(c * lens + R))]
    agree = {10 ** 4: 0, 10 ** 5: 0}
    for r in range(200):
        n = 10 ** 5
        xs = rng.integers(0, 2, size=n)
        ys = rng.random(n) < NU1[xs]
        for nn in agree:
            cnt = np.array([[np.sum((xs[:nn] == x) & (ys[:nn] == y)) for y in (0, 1)] for x in (0, 1)])
            with np.errstate(invalid="ignore"):
                LL = np.array([np.nansum(np.where(cnt[:, 0] > 0, cnt[:, 0] * L0[i], 0) +
                                         np.where(cnt[:, 1] > 0, cnt[:, 1] * L1[i], 0)) for i in range(len(names))])
            J = c * nn * lens - LL
            agree[nn] += names[int(np.argmin(J))] == pop
    print(f"  c={c:.2f}: population minimiser {pop:5s}; empirical MAP equals it in "
          f"{agree[10 ** 4]}/200 runs at n=1e4, {agree[10 ** 5]}/200 at n=1e5")

print("=" * 78)
print("(B) Thm 4.1(i) tightness in C_{k,M}: MAP length vs (lambda k + delta_n)/(lambda - 1)")


def gf2_rank_and_span(A, y):
    """rank of A over GF(2) and whether y is in its column span (Gaussian elimination on rows of [A|y])."""
    M = np.concatenate([A, y[:, None]], axis=1).astype(np.uint8)
    nrow, ncol = M.shape
    r = 0
    for col in range(ncol - 1):
        piv = np.flatnonzero(M[r:, col])
        if len(piv) == 0:
            continue
        p = r + piv[0]
        M[[r, p]] = M[[p, r]]
        others = np.flatnonzero(M[:, col]); others = others[others != r]
        M[others] ^= M[r]
        r += 1
        if r == nrow:
            break
    incons = np.any((M[:, :ncol - 1].sum(1) == 0) & (M[:, ncol - 1] == 1))
    return r, not incons


# Choose M = n = lambda (k-2)/(lambda-1): then lambda (M+2) = lambda k + n (the parity ties the coin),
# and a full-rank square system has exactly one consistent parity, so delta_n = log2(2^-k + 2^-2).
for (k, lam, M) in [(20, 2.0, 36), (20, 1.5, 54), (30, 3.0, 42), (16, 1.25, 70), (20, 2.0, 30)]:
    ratios = []
    for r in range(300):
        n = int(np.ceil(lam * (M + 2 - k)))           # least n at which lambda (M+2) <= lambda k + n
        if n < 1 or n > M:
            continue
        A = rng.integers(0, 2, size=(n, M)); y = rng.integers(0, 2, size=n)
        rk, ok = gf2_rank_and_span(A, y)
        if not ok:
            continue
        ncons = 2 ** (M - rk)                                   # consistent parities
        xi = 2.0 ** -k * 2.0 ** -n + ncons * 2.0 ** -(M + 2)          # coin + consistent parities
        delta = log2(xi) + n                                    # log2(xi / 2^-n)
        bound = (lam * k + delta) / (lam - 1)
        ratios.append((M + 2, bound, M - rk))
    ls = np.array(ratios)
    print(f"  k={k}, lambda={lam}, M={M}, n={int(np.ceil(lam * (M + 2 - k)))}: parity MAP length {M + 2}; "
          f"bound (lambda k + delta_n)/(lambda-1): min {ls[:, 1].min():.2f}, median {np.median(ls[:, 1]):.2f} "
          f"(slack = log2 #consistent parities, median {np.median(ls[:, 2]):.0f}) over {len(ls)} runs with a consistent parity")
