"""i2: lambda = 1 has no recovery-time bound in terms of (l0, gamma, eps); 1/(lambda-1) is necessary
(notes-final Prop 5.1 and Prop 4.4(b)).
[Labels updated to the notes-final numbering and notation (l0, E0) on 2026-10-13; computations unchanged.]

Class C_k.  Truth: fair-coin labels, nu(y|x) = 1/2, given by the program "coin" of length k.
Fill-ins: for m >= 1 and w in {0,1}^m the deterministic parity x -> <w, x_{1:m}> mod 2, of length
l(m) = m + 2*ceil(log2(m+1)) + 1.  Kraft: sum_m 2^m 2^{-l(m)} = sum_m 2^{-2 ceil(log2(m+1)) - 1} = 1/4 (m >= 1),
plus 2^{-k}.  E = {coin}, l0 = k.  Every parity has Hellinger gap 1 - 1/sqrt(2) = 0.2929 (uniform margin).
Data: x_i uniform on {0,1}^Dlen (Dlen >= every m used), labels fresh per query.

The lambda-MAP is not the coin iff some parity consistent with the data has lambda*l(m) <= lambda*k + n.
Parities on the first m bits include those on fewer bits (pad w with zeros), so with
m*(n) := max{m : lambda l(m) <= lambda k + n} the event is {y in colspan(A_{n x m*})}, where A has
i.i.d. uniform rows (the first m* bits of the inputs) and y is uniform and independent.  Its probability
is E[2^{rank(A) - n}], computed exactly by the column-by-column rank chain
  r -> r+1 with probability 1 - 2^{r-n},  r -> r otherwise.
(A) exact P[lambda-MAP != coin at n] for k in {16, 24, 32, 40}, lambda in {1, 1.1, 1.25, 1.5, 2, 3},
    and the recovery time n_rec(eps): the least n such that the probability is <= eps at n and at all
    larger n on the grid (the probability is eventually decreasing in n).  Compared with
    lambda (k + log2(1/eps)) / (lambda - 1) for lambda > 1 and sqrt(2^{k-1}/eps) for lambda = 1.
(B) Thm 4.1(iv)'s Renyi bound for this class, 0.25 * 2^{k - (1 - 1/lambda) n}, and its margin bound
    2^k exp(-2 min(1, lambda-1) (1 - 2^{-1/2}) n / lambda), at the recovery times.
(C) Monte Carlo cross-check of (A) for k = 12 (rank over GF(2) with bit operations), seeded.
(D) The truncated rank chain used in (A) against the full column chain, n < 40, m < 60.
"""
from math import ceil, log2, sqrt, exp
import numpy as np

def ell(m):
    return m + 2 * ceil(log2(m + 1)) + 1

KRAFT_PAR = sum(2.0 ** (-2 * ceil(log2(m + 1)) - 1) for m in range(1, 10 ** 6))
assert KRAFT_PAR <= 0.25
print(f"Kraft weight of all parities = {KRAFT_PAR:.4f} (<= 1/4); with the coin (k >= 2) the total is < 1")

def mstar(n, k, lam):
    """Largest m with lam*l(m) <= lam*k + n (l is increasing); 0 if none.  Binary search."""
    if lam * ell(1) > lam * k + n:
        return 0
    lo, hi = 1, 2
    while lam * ell(hi) <= lam * k + n:
        lo, hi = hi, 2 * hi
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if lam * ell(mid) <= lam * k + n:
            lo = mid
        else:
            hi = mid
    return lo

def p_in_span(n, m, W=120):
    """P[y in colspan(A)] for A uniform n x m over GF(2), y uniform and independent: E[2^{rank - n}].
    m >= n: add the n rows one by one; a row fails (is in the span) with probability 2^{rank - m}.
    m <  n: add the m columns one by one; a column fails with probability 2^{rank - n}.
    Failures before the last W steps have total probability <= 2^{-W}; they are ignored.
    The answer is E[2^{-def}] (m >= n) or 2^{m-n} E[2^{-def}] (m < n), def = number of failures."""
    if m <= 0:
        return 0.0
    if m >= n:
        steps, dim, start = n, m, max(0, n - W)
    else:
        steps, dim, start = m, n, max(0, m - W)
    dist = np.zeros(W + 2)
    dist[0] = 1.0
    for i in range(start, steps):
        new = np.zeros_like(dist)
        for d in range(W + 1):
            if dist[d] == 0:
                continue
            pf = 2.0 ** (i - d - dim)
            new[d] += dist[d] * (1 - pf)
            new[d + 1] += dist[d] * pf
        dist = new
    e = float(sum(dist[d] * 2.0 ** (-d) for d in range(W + 2)))
    return e if m >= n else 2.0 ** (m - n) * e

def p_bad(n, k, lam):
    return p_in_span(n, mstar(n, k, lam))

def grid(nmax):
    g = sorted(set([int(round(1.15 ** i)) for i in range(0, 400) if 1.15 ** i <= nmax] + [nmax]))
    return g

print("=" * 78)
print("(A) exact P[lambda-MAP != coin at n]; recovery time n_rec(eps), eps = 0.01")
EPS = 0.01
for k in [16, 24, 32, 40]:
    print(f"  k = l0 = {k}")
    for lam in [1.0, 1.1, 1.25, 1.5, 2.0, 3.0]:
        if lam == 1.0:
            nmax = int(4 * sqrt(2.0 ** (k - 1) / EPS)) + 10
        else:
            nmax = int(3 * lam * (k + log2(1 / EPS)) / (lam - 1)) + 50
        # p_bad depends on n only through m*(n) - n and n; evaluate on a geometric grid
        g = grid(nmax)
        vals = [(n, p_bad(n, k, lam)) for n in g]
        nrec = None
        for idx in range(len(vals)):
            if all(v <= EPS for _, v in vals[idx:]):
                nrec = vals[idx][0]
                break
        pred = sqrt(2.0 ** (k - 1) / EPS) if lam == 1.0 else lam * (k + log2(1 / EPS)) / (lam - 1)
        show = [(n, v) for n, v in vals if n in (g[len(g) // 4], g[len(g) // 2], g[3 * len(g) // 4])]
        s = "  ".join(f"P({n})={v:.3g}" for n, v in show)
        print(f"    lambda={lam:4.2f}: n_rec(0.01) on grid = {nrec}   heuristic {pred:.4g}   [{s}]")

print("=" * 78)
print("(B) Thm 4.1(iv) bounds at the heuristic recovery time n = lambda (k + log2(1/eps))/(lambda - 1)")
g0 = 1 - 2 ** -0.5
for k in [16, 32]:
    for lam in [1.25, 2.0, 3.0]:
        n = int(lam * (k + log2(1 / EPS)) / (lam - 1))
        BR = KRAFT_PAR * 2.0 ** (k - (1 - 1 / lam) * n)
        BH = 2.0 ** k * exp(-2 * min(1, lam - 1) * g0 * n / lam)
        nH = lam * (k + log2(2 / EPS)) * 0.6931471805599453 / (2 * min(1, lam - 1) * g0)
        print(f"  k={k} lambda={lam}: n={n}: exact={p_bad(n, k, lam):.3g}  Renyi bound={BR:.3g}  margin bound={BH:.3g};"
              f"  n(lambda,l0,gamma,eps) of Thm 4.1(iv) = {nH:.1f}")

print("=" * 78)
print("(C) Monte Carlo cross-check, k = 12, 20000 runs per (lambda, n); seed 2")
rng = np.random.default_rng(2)

def gf2_in_span(rows, y, m):
    """rows: list of ints (m-bit), y: list of bits. Is the system A w = y solvable? Gaussian elimination."""
    basis = {}  # pivot -> (row, rhs)
    for r, b in zip(rows, y):
        while r:
            p = r.bit_length() - 1
            if p in basis:
                br, bb = basis[p]
                r ^= br
                b ^= bb
            else:
                basis[p] = (r, b)
                break
        else:
            if b:
                return False
    return True

k = 12
for lam in [1.0, 1.5, 3.0]:
    for n in [8, 20, 40, 80]:
        m = mstar(n, k, lam)
        if m <= 0:
            print(f"  lambda={lam} n={n}: m*=0, exact=0"); continue
        runs = 20000
        hits = 0
        for _ in range(runs):
            nb = (m + 7) // 8
            rows = [int.from_bytes(rng.bytes(nb), "little") >> (8 * nb - m) for _ in range(n)]
            y = [int(v) for v in rng.integers(0, 2, size=n)]
            hits += gf2_in_span(rows, y, m)
        print(f"  lambda={lam} n={n}: m*={m}  MC={hits/runs:.4f}  exact={p_bad(n, k, lam):.4f}")

print("=" * 78)
print("(D) truncated rank chain (window 120) vs the full column chain, n < 40, m < 60")
def full_chain(n, m):
    dist = {0: 1.0}
    for _ in range(m):
        new = {}
        for r, p in dist.items():
            pu = 1 - 2.0 ** (r - n)
            new[r + 1] = new.get(r + 1, 0) + p * pu
            new[r] = new.get(r, 0) + p * (1 - pu)
        dist = new
    return sum(p * 2.0 ** (r - n) for r, p in dist.items())
mx = max(abs(full_chain(n, m) - p_in_span(n, m)) for n in range(1, 40) for m in range(1, 60))
print(f"  max |difference| = {mx:.2e}")
