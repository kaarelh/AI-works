"""rB4 (referee B): notes Section 8 (Lemma 8.1, the link to T2) and lambda-MAPs for all lambda via the hull.

(A) The right side of Lemma 8.1.  The lemma proves rho_C(alpha) >= S_n - alpha - delta* for every alpha.
    The notes read this as "to the right [of l*], each bit of length buys at most one bit of fit, plus
    delta* in total", i.e.  rho_C(l*) - rho_C(alpha) <= (alpha - l*) + delta*  for alpha > l*.
    Counterexample class (Kraft 0.625 + 2^-k):  truth = coin (fair labels), length k = l*;
    Bern(1/4) (length 2), Bern(3/4) (length 3); and the 2^M deterministic parities on the first M input bits,
    length M + 2.  Inputs uniform on {0,1}^M, labels fresh per query (the per-query object of the notes).
    At n = M - 5, alpha = M + 2:  drop = rho(l*) - rho(alpha) and excess = drop - (alpha - l*).
    Exact: P[parity consistent | y] = c_n for every y != 0 (GL(n,2) symmetry), so the joint law of
    (#ones, parity consistent) is exact.  Since P[delta* >= c] <= 2^-c (Lemma 2.2),
        P[reading fails] >= P[excess >= c and a parity is consistent] - 2^-c.
(B) Monte Carlo illustration of (A) (seed 41), with the running deficiency max_{n' <= n} delta_{n'}.
(C) The left side of Lemma 8.1, exactly: class {coin (l* = 6), Bern(1/4) (2), Bern(3/4) (3), Bern(0.6) (5)};
    P[every program shorter than l* has -log L_n >= S_n + gamma_< n log e]  vs  1 - 2^{l*} e^{-gamma_< n/2}.
(D) lambda-MAPs for all lambda: for sampled data sets, the set of minimisers of lambda*l - log L, computed
    by brute force on a fine grid of lambda and at the hull breakpoints, equals the set of programs on the
    supporting line of slope -lambda of the lower convex hull of {(l(pi), -log L(pi))}.  Reports the
    lambda-interval on which the truth is the MAP, i.e. (right slope, left slope) at its hull vertex.
"""
import numpy as np
from math import comb, log2, log, exp, e, lgamma
from fractions import Fraction

rng = np.random.default_rng(41)


def QT():
    q = np.zeros(400)
    for a in range(1, 400):
        q[a] = q[a - 1] + np.log2(1 - 2.0 ** (-a))
    return q
Qt = QT()
def Q(a):
    return Qt[min(a, 399)]


def p_span(n, m):
    """E[2^{rank - n}], A uniform n x m over GF(2) (closed form of the rank law)."""
    tot = 0.0
    for r in range(max(0, min(n, m) - 80), min(n, m) + 1):
        lg = -(n - r) * (m - r) + Q(n) - Q(n - r) + Q(m) - Q(m - r) - Q(r) + (r - n)
        tot += 2.0 ** max(lg, -1100)
    return tot


print("=" * 78)
print("(A) Lemma 8.1, right side: is rho(l*) - rho(alpha) <= (alpha - l*) + delta* ?  (exact)")
for k in [16, 24, 32]:
    for n in [20, 30, 60]:
        M = n + 5
        alpha = M + 2
        if alpha <= k:            # the reading concerns alpha > l* only (parities must be longer than l*)
            continue
        Pspan = p_span(n, M)
        c_n = (Pspan - 2.0 ** -n) / (1 - 2.0 ** -n)       # P[consistent | y], y != 0
        res = {}
        for c in [k - 12, k - 9]:
            if c <= 0:
                continue
            tot = 0.0
            for n1 in range(n + 1):
                pr = comb(n, n1) / 2 ** n
                n0 = n - n1
                B14 = n1 * 2 + n0 * log2(4 / 3)
                B34 = n0 * 2 + n1 * log2(4 / 3)
                rho_l = min(n, B14, B34)                    # rho(l*): programs of length <= k
                excess = rho_l - 0.0 - (alpha - k)          # rho(alpha) = 0 when a parity is consistent
                if excess >= c:
                    tot += pr * (1.0 if n1 == 0 else c_n)
            res[c] = (tot, tot - 2.0 ** -c)
        s = "; ".join(f"c={c}: P[excess>=c, parity consistent]={v[0]:.4f}, so P[reading fails] >= {v[1]:.4f}"
                      for c, v in res.items())
        print(f"  k=l*={k}, n={n}, M={M}, alpha=M+2={alpha} (alpha-l*={alpha - k}): {s}")

print("=" * 78)
print("(B) Monte Carlo (seed 41): k = 24, n = 30, M = 35; 4000 runs")
k, n, M = 24, 30, 35
runs = 4000
cnt_fail = 0
exc_list = []
for r in range(runs):
    X = rng.integers(0, 2, size=(n, M))
    y = rng.integers(0, 2, size=n)
    # consistency of some parity on M bits: Gaussian elimination over GF(2) on [X | y]
    A = np.concatenate([X, y[:, None]], axis=1).astype(np.uint8)
    row = 0
    for col in range(M):
        piv = np.flatnonzero(A[row:, col])
        if len(piv) == 0:
            continue
        p = row + piv[0]
        A[[row, p]] = A[[p, row]]
        others = np.flatnonzero(A[:, col]); others = others[others != row]
        A[others] ^= A[row]
        row += 1
        if row == n:
            break
    consistent = not np.any((A[:, :M].sum(1) == 0) & (A[:, M] == 1))
    n1 = int(y.sum()); n0 = n - n1
    rho_l = min(n, n1 * 2 + n0 * log2(4 / 3), n0 * 2 + n1 * log2(4 / 3))
    # running deficiency along the path: xi_m / L_m(nu), m <= n (parities: count consistent ones exactly
    # is expensive; use the lower bound "number of consistent parities >= 1" only at m = n and the
    # Bern/coin terms at every m).  This UNDER-estimates delta_n; P[delta* >= c] <= 2^-c is used in (A).
    if consistent:
        exc = rho_l - (M + 2 - k)
        exc_list.append(exc)
exc_list = np.array(exc_list)
print(f"  fraction with a consistent parity: {len(exc_list) / runs:.4f} (exact {p_span(n, M):.4f})")
print(f"  excess = drop - (alpha - l*) when consistent: min {exc_list.min():.2f}, median {np.median(exc_list):.2f}; "
      f"it would have to be <= delta*, and P[delta* >= {int(np.median(exc_list))}] <= 2^-{int(np.median(exc_list))}")

print("=" * 78)
print("(C) Lemma 8.1, left side, exact (truth = coin, l* = 6; shorter: Bern(1/4) l=2, Bern(3/4) l=3, Bern(0.6) l=5)")
short = [0.25, 0.75, 0.6]
gam = min(1 - (np.sqrt(0.5 * q) + np.sqrt(0.5 * (1 - q))) for q in short)
LST = 6
print(f"  gamma_< = {gam:.5f}")
for n in [50, 200, 800, 2000, 5000]:
    ok = 0.0
    for n1 in range(n + 1):
        lp = (lgamma(n + 1) - lgamma(n1 + 1) - lgamma(n - n1 + 1)) - n * log(2)
        pr = exp(lp)
        S = n
        good = all(-(n1 * log2(q) + (n - n1) * log2(1 - q)) >= S + gam * n * log2(e) for q in short)
        ok += pr * good
    bound = 1 - 2 ** LST * exp(-gam * n / 2)
    print(f"  n={n:5d}: exact P[left side holds] = {ok:.6f}   lemma's lower bound = {bound:.4f}")

print("=" * 78)
print("(D) lambda-MAPs for all lambda via the lower convex hull (sampled data sets, seed 41)")


def hull_maps(lens, F):
    """Lower convex hull of the points (l, F) (decreasing part).  Returns (vertices, intervals) where
    intervals[(l, f)] = (lo, hi): the vertex is a lambda-MAP exactly for lambda in [lo, hi]."""
    best = {}
    for l, f in zip(lens, F):
        if l not in best or f < best[l]:
            best[l] = f
    P = sorted(best.items())
    hull = []
    for p in P:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            if (y2 - y1) * (p[0] - x1) >= (p[1] - y1) * (x2 - x1):    # hull[-1] on or above the chord
                hull.pop()
            else:
                break
        hull.append(p)
    while len(hull) >= 2 and hull[-1][1] >= hull[-2][1]:
        hull.pop()
    iv = {}
    for idx, (l, f) in enumerate(hull):
        hi = np.inf if idx == 0 else (hull[idx - 1][1] - f) / (l - hull[idx - 1][0])
        lo = 0.0 if idx == len(hull) - 1 else (f - hull[idx + 1][1]) / (hull[idx + 1][0] - l)
        iv[(l, f)] = (lo, hi)
    return hull, iv


def hull_set(lens, F, hull, iv, lam, tol=1e-9):
    """Programs that the hull characterisation declares lambda-MAPs: vertices whose interval contains
    lambda, and points lying on the hull edge of slope -lambda (collinear points included)."""
    out = set()
    for i in range(len(lens)):
        if not np.isfinite(F[i]):
            continue
        pt = (lens[i], F[i])
        if pt in iv and iv[pt][0] - tol <= lam <= iv[pt][1] + tol:
            out.add(i); continue
        for (x1, y1), (x2, y2) in zip(hull[:-1], hull[1:]):
            s = (y1 - y2) / (x2 - x1)
            if abs(s - lam) <= tol * max(1, lam) and x1 <= pt[0] <= x2 and abs(y1 - s * (pt[0] - x1) - pt[1]) <= 1e-7:
                out.add(i)
    return out


def brute_maps(lens, F, lam):
    J = lam * lens + F
    m = J.min()
    return set(np.flatnonzero(J <= m + 1e-9 * max(1, abs(m))))


mismatch = 0; checked = 0
for trial in range(200):
    d = 5
    nq = int(rng.integers(5, 120))
    xs = rng.integers(0, 2 ** d, size=nq)
    pstar = 1 / 8
    astar = int(rng.integers(1, 2 ** d))
    par = np.array([bin(a & x).count("1") % 2 for a in range(2 ** d) for x in range(2 ** d)]).reshape(2 ** d, 2 ** d)
    ys = par[astar, xs] ^ (rng.random(nq) < pstar)
    rates = [0.0, 1 / 4, 1 / 8, 1 / 16, 3 / 16, 5 / 16]
    lr = [2, 2, 3, 4, 5, 5]
    lens, F, names = [], [], []
    for a in range(2 ** d):
        for q, l in zip(rates, lr):
            pred = par[a, xs]
            nerr = int(np.sum(pred != ys))
            if q == 0:
                f = 0.0 if nerr == 0 else np.inf
            else:
                f = -(nerr * log2(q) + (nq - nerr) * log2(1 - q))
            lens.append(1 + d + l); F.append(f); names.append((a, q))
    lens.append(2); F.append(float(nq)); names.append("coin")
    lens = np.array(lens, float); F = np.array(F)
    fin = np.isfinite(F)
    hull, hm = hull_maps(list(lens[fin]), list(F[fin]))
    # breakpoints and a grid of lambdas
    bps = sorted({v for lo_hi in hm.values() for v in lo_hi if np.isfinite(v) and v > 0})
    grid = sorted(set(list(np.linspace(0.05, 12, 120)) + bps + [b * (1 + 1e-6) for b in bps] + [b * (1 - 1e-6) for b in bps]))
    for lam in grid:
        bm = brute_maps(lens, F, lam)
        hm_set = hull_set(lens, F, hull, hm, lam)
        checked += 1
        if bm != hm_set:
            mismatch += 1
    if trial < 6:
        it = names.index((astar, pstar))
        iv = hm.get((lens[it], F[it]))
        print(f"  trial {trial}: n={nq:3d}  truth's point on the hull: {iv is not None}; "
              f"lambda-interval where the truth is a MAP: {('(%.3f, %.3f)' % iv) if iv else 'empty'}")
print(f"  brute-force argmin vs hull at {checked} (data set, lambda) pairs, breakpoints included: {mismatch} mismatches")
