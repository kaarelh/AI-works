"""Independent recomputation of the numbers added or changed in the second revision of
A-tight-conditioning-fails.md (Table 4.1 last column, finite-d fixed-a values, Corollary 4.5 vs 4.5a,
Theorem 7.2 vs Proposition 7.2a, Proposition 7.2a constants, Proposition 6.6a(e)).
Written from the formulas in the text, not from the note's scripts."""
import math
from fractions import Fraction
import itertools
import numpy as np
from scipy import optimize, special

LOG2 = math.log(2.0)


def alpha(d):
    return 0.5 * math.log(4 * math.sqrt(2 * d))


def beta_n(n, M):
    """E[1/K; K>=1], K ~ Bin(n, 1/M), by direct summation in log space (accurate for huge n)."""
    p = 1.0 / M
    logq = math.log1p(-p)
    tot = 0.0
    logfall = 0.0  # log n(n-1)...(n-k+1)
    for k in range(1, 400):
        logfall += math.log(n - k + 1)
        lp = logfall - math.lgamma(k + 1) + k * math.log(p) + (n - k) * logq
        term = math.exp(lp) / k
        tot += term
        if k > 50 and term < 1e-20:
            break
    return tot


def beta_pois(lam):
    return math.exp(-lam) * (special.expi(lam) - np.euler_gamma - math.log(lam))


def kmem(d, s, a, H):
    return d * (d + 1) * alpha(d) ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))


def N0(d, s, a):
    return math.floor(64 * LOG2 * d * (d + 1) * s / a ** 2) + 1


def setup(H, d, lam, c=1.0, t=1.0, delta=0.01):
    M = 2 ** d
    n = int(round(lam * M))
    s = min(n, M)
    bn = beta_n(n, M)
    qd = max(bn - math.sqrt(2 * (n / M) * math.log(1 / delta) / M), 0.0)
    return M, n, s, bn, qd


def e_thm44(a, H, d, lam, c=1.0, t=1.0, delta=0.01):
    M, n, s, bn, qd = setup(H, d, lam, c, t, delta)
    eps = c * (kmem(d, s, a, H) + t) / M + (n / M) * a * a
    return max(math.sqrt(qd) - math.sqrt(eps), 0.0) ** 2


def a_star(H, d, lam, c=1.0):
    M = 2 ** d
    n = int(round(lam * M)); s = min(n, M)
    a_kink = 9 / (2 * (8 * d * s) ** (1.0 / H))
    a_int = (9 * (H + 1) * c / (4 * (n / M) * M)) ** (1 / 3)
    return min(a_int, a_kink, 1.0), a_int, a_kink


def e_prime(a, H, d, lam, c=1.0, t=1.0, delta=0.01, sharper=False):
    M, n, s, bn, qd = setup(H, d, lam, c, t, delta)
    K = kmem(d, s, a, H)
    if sharper:
        B = c * (K + t) + n * a * a + 7
    else:
        E = math.sqrt(c * (K + t)) + (a + 2 / n) * math.sqrt(n)
        B = 2 * E * math.sqrt(n) + E * E
    inner = max(math.sqrt(qd) - math.sqrt(B / M), 0.0) ** 2
    phi = max(math.sqrt(1 + inner) - 1 / n, 0.0) ** 2
    return phi - 1, c * (K + t) / n


def best_over_a(f):
    # log-grid then refine
    grid = np.logspace(-14, 0, 4001)
    vals = [f(a) for a in grid]
    i = int(np.argmax(vals))
    lo, hi = grid[max(i - 2, 0)], grid[min(i + 2, len(grid) - 1)]
    res = optimize.minimize_scalar(lambda la: -f(math.exp(la)), bounds=(math.log(lo), math.log(hi)), method="bounded",
                                   options={"xatol": 1e-12})
    a = math.exp(res.x)
    return max(f(a), vals[i]), a if f(a) >= vals[i] else grid[i]


print("(1) Table 4.1 at lambda = 1 and 1.5 (c=t=1, delta=0.01), closed-form a*")
rows = [(2, 20), (2, 30), (2, 40), (2, 60), (3, 20), (3, 30), (3, 40), (4, 30)]
for H, d in rows:
    out = []
    for lam in (1.0, 1.5):
        a, a_int, a_kink = a_star(H, d, lam)
        M, n, s, bn, qd = setup(H, d, lam)
        e = e_thm44(a, H, d, lam)
        out.append((lam, a, e, kmem(d, s, a, H), N0(d, s, a), "kink" if a == a_kink else "int"))
    (l1, a1, e1, K1, N1, w1), (l2, a2, e2, K2, N2, w2) = out
    # flatness: largest a with e >= e* - 0.001 (lambda=1)
    target = e1 - 0.001
    f = lambda a: e_thm44(a, H, d, 1.0) - target
    a_hi = optimize.brentq(f, a1, 1.0, xtol=1e-15)
    M = 2 ** d
    print(f"  H={H} d={d}: e(1)={e1:.4f} a*={a1:.3e}({w1}) K={K1:.3e} N0={N1:.3e} | e(1.5)={e2:.4f} a*={a2:.3e} N0={N2:.3e}"
          f" | a_0.001={a_hi:.5f} N0={N0(d, M, a_hi):.4e} N0/n={N0(d, M, a_hi) / M:.4e} ratio={N1 / N0(d, M, a_hi):.4g}")

print("\n(2) fixed a, finite d (lambda=1, c=t=1, delta=0.01) and N0/n")
for a in (0.1, 0.3):
    lim = (math.sqrt(beta_pois(1.0)) - a) ** 2
    print(f"  a={a}: limit {lim:.5f}; N0/n at d=20,30,40: " +
          ", ".join(f"{N0(d, 2 ** d, a) / 2 ** d:.3e}" for d in (20, 30, 40)))
    for H in (2, 3):
        print(f"    H={H}: " + ", ".join(f"d={d}: {e_thm44(a, H, d, 1.0):.6f}" for d in (20, 30, 40)))

print("\n(3) Corollary 4.5 vs 4.5a displayed bound (c_d=1, t=1, n=2^d, delta_d=exp(-2^(d/2)))")
for H in (2, 3):
    for d in (20, 40, 60, 100):
        M = 2 ** d; n = M; lam = 1.0
        for name, a in (("4.5 ", (1.0 / M) ** (1 / 3)), ("4.5a", max((1.0 / M) ** (1 / 3), 1.0 / d))):
            epsbar = (d * (d + 1) * alpha(d) ** 2 + 1) / M + (H + 1) * ((8 * d * n) ** (1.0 / H) + 9 / (2 * a)) / M + lam * a * a
            inner = max(beta_pois(lam) - lam * 2.0 ** (-d) - math.sqrt(2 * lam) * 2.0 ** (-d / 4), 0.0)
            bound = max(math.sqrt(inner) - math.sqrt(epsbar), 0.0) ** 2
            print(f"  H={H} d={d:3d} Cor {name}: a={a:.3e} epsbar={epsbar:.3e} bound={bound:.4f} "
                  f"N0/n={64 * LOG2 * d * (d + 1) / a ** 2:.3e}  (45 d^3(d+1) = {45 * d ** 3 * (d + 1):.3e})")

print("\n(4) Theorem 7.2 (as stated) vs Proposition 7.2a (lambda=1, c=t=1, delta=0.01), a optimised for each")
for H, d in rows:
    ep, ap = best_over_a(lambda a: e_prime(a, H, d, 1.0)[0])
    es, as_ = best_over_a(lambda a: e_prime(a, H, d, 1.0, sharper=True)[0])
    astar = a_star(H, d, 1.0)[0]
    es_star, ratio = e_prime(astar, H, d, 1.0, sharper=True)
    print(f"  H={H} d={d}: Thm7.2 e'={ep:.4f} (a={ap:.2e}) | Prop7.2a e''={es:.4f} (a={as_:.2e}); at a*: {es_star:.4f},"
          f" c(K+t)/n={ratio:.3e} | Thm4.4 e={e_thm44(astar, H, d, 1.0):.4f}")

print("\n(5) Proposition 7.2a constants")
n = 100
print(f"  2 sqrt(3+3/n) at n=100: {2 * math.sqrt(3 + 3 / n):.5f} (<= 3.49)")
print(f"  2 sqrt 2 + 3/n at n=100: {2 * math.sqrt(2) + 3 / n:.5f} (<= 2.86)")
print(f"  R' <= 3n+3 needs 2 sqrt2 + 2/n <= 3: {2 * math.sqrt(2) + 2 / n:.5f}")
# worst case of the chain of inequalities: sup over C<=n, Y<=2n of the exact worst-case bound
worst = 0.0
for n in (100, 101, 128, 200, 1000, 10 ** 6):
    eps = n ** -0.5
    Y = 2.0 * n; C = 1.0 * n
    A = C + (math.sqrt(Y) + eps) ** 2
    excess = (math.sqrt(A) + eps) ** 2 - Y - C   # X - W - (C + na^2) in the worst case Y - W = na^2
    worst = max(worst, excess)
print(f"  worst-case additive constant over n>=100 (exact chain, C=n, Y=2n): {worst:.4f} (<= 7)")

print("\n(6) Proposition 6.6a(e): exact Pr[some atom lacks a label] (inclusion-exclusion over atoms) vs 2M exp(-n(1-eta0)/(2M))")
def prob_not_all_conflict(d, eta0, n):
    M = 2 ** d
    p = (1 + Fraction(eta0)) / 2
    q = 1 - p
    # P(every atom carries both labels) by inclusion-exclusion over the 2M events
    # "no +1 at x" and "no -1 at x"; a atoms with only the first, b with only the second, k with both (unseen)
    tot = Fraction(0)
    for a in range(M + 1):
        for b in range(M + 1 - a):
            for k in range(M + 1 - a - b):
                mult = math.factorial(M) // (math.factorial(a) * math.factorial(b) * math.factorial(k) * math.factorial(M - a - b - k))
                avoid = 1 - (a * p + b * q + k) / M
                tot += (-1) ** (a + b) * mult * avoid ** n
    return 1 - tot

ok = True
for d in (1, 2):
    for eta0 in (Fraction(1, 4), Fraction(1, 2), Fraction(9, 10)):
        for n in (4, 16, 64):
            exact = float(prob_not_all_conflict(d, eta0, n))
            bound = 2 * 2 ** d * math.exp(-n * (1 - float(eta0)) / (2 * 2 ** d))
            ok &= exact <= bound + 1e-15
            print(f"  d={d} eta0={float(eta0):.2f} n={n:3d}: exact {exact:.4e} <= bound {bound:.4e}: {exact <= bound}")
print("  all ok:", ok)

print("\n(7) Remark 5.1a and Section 5.4 numbers")
print(f"  1-e^-1 = {1 - math.exp(-1):.4f}, e^-1 = {math.exp(-1):.4f}, beta(1) = {beta_pois(1.0):.6f}")
print(f"  1/(6H+4) at H=2,3: {1 / 16:.4f}, {1 / 22:.4f}; 1/(4H): {1 / 8:.4f}, {1 / 12:.4f}")
for H in (2, 3, 4):
    # 2 alpha < (1 - 4 alpha H)/(H+2)  <=>  alpha < 1/(6H+4)
    al = 1 / (6 * H + 4)
    print(f"  H={H}: at alpha=1/(6H+4), 2alpha - beta = {2 * al - (1 - 4 * al * H) / (H + 2):.2e}")
