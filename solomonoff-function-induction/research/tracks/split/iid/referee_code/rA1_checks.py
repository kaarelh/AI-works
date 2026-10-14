"""rA1: Referee A (proofs) checks for research/tracks/split/iid/notes.md.

Deterministic except (C), which is seeded with numpy default_rng(101).  Python 3.11, numpy, scipy.

(A) Prop 4.4(a): exact binomial values of P[log Lambda_n(pi') <= -lambda*Delta] for all n <= n1 on a
    grid of (lambda*Delta, eps'), against the stated bound 8.66/(lambda*Delta); the constants 8.66 and
    0.083; the gap bounds eps'^2/2 <= gamma <= 2 eps'^2.
(B) Cor 6.1(iii) "rate competitors have the smallest gaps": a function competitor that differs from f at
    one input of a uniform mu on {0,1}^d has gap 2^-d h_ne(p,p); compare with the rate competitor's
    h_eq(1/8, 3/16) of the notes' i4 class.
(C) Prop 7.3(ii) without D* < infinity: two sub-probability kernels c(x)*Bern(1/4) (l=2) and c(x)*Bern(1/2)
    (l=5) with E_mu log(1/c(x)) = infinity, so D = infinity for both and P = C.  The log-likelihood ratio does
    not depend on x; its mean is (1/2) log(4/3) > 0, so the walk drifts and the longer program is
    eventually the unique MAP forever (no oscillation).  Simulation of the walk only (x cancels).
(D) Ties at the boundary of Prop 4.4(b) / Prop 5.1(b): exact P[some parity strictly beats the coin] and
    P[some parity weakly beats the coin] (the event used in the proof) at the boundary
    lambda*l(n+5) = lambda*k + n, with the rank chain of i2.
(E) k versus l*: a toy class in which the shortest mu-a.e. equivalent program is defective off supp mu.
    The two-sided bound of Prop 5.3(c), read with pi_nu a program for the measure nu (length k), fails
    on its lower side when l* replaces k.
(F) Lemma 5.2: ceil(log2 M) <= R + 4 + log2 n + log2(d+1+log2|Y|) on a grid; Thm 4.1(v):
    1/(1-e^{-a}) <= 1 + 1/a on a grid.
"""
from math import ceil, log2, log, sqrt, exp
import numpy as np
from scipy.stats import binom

print("=" * 78)
print("(A) Prop 4.4(a): exact P[sum X_i <= -lambda*Delta] for n <= n1 versus 8.66/(lambda*Delta)")
worst_ratio = 0.0
for lD in [9, 12, 20, 50, 100, 300]:
    for ep in [0.1, 0.07, 0.05, 0.02, 0.01]:
        a, b = log2(1 + 2 * ep), log2(1 - 2 * ep)
        n1 = int(lD * (1 - 4 * ep ** 2) * log(2) / (4 * ep ** 2))
        ns = sorted(set([1, 2, 5, 10] + [int(n1 * f) for f in np.linspace(0.05, 1.0, 40)] + [n1]))
        pmax, nmax = 0.0, 0
        for n in ns:
            if n <= 0:
                continue
            # sum = j*a + (n-j)*b <= -lD  <=>  j <= (-lD - n b)/(a - b)
            jcrit = np.floor((-lD - n * b) / (a - b) + 1e-12)
            p = float(binom.cdf(jcrit, n, 0.5)) if jcrit >= 0 else 0.0
            if p > pmax:
                pmax, nmax = p, n
        bound = 8.66 / lD
        worst_ratio = max(worst_ratio, pmax / bound)
        print(f"  lambda*Delta={lD:4d} eps'={ep:5.2f} n1={n1:8d}: max_n P = {pmax:.4f} at n={nmax:8d};"
              f" bound 8.66/(lambda Delta) = {bound:.4f}; {'OK' if pmax <= bound else 'VIOLATED'}")
print(f"  largest (exact / bound) over the grid = {worst_ratio:.3f}")
c866 = max(4 * (1 + 2 * e) / ((1 - 2 * e) * log(2)) for e in np.linspace(1e-6, 0.1, 10001))
print(f"  constant: max_{{eps'<=0.1}} 4(1+2eps')/((1-2eps') ln 2) = {c866:.4f} (stated 8.66)")
print(f"  constant: 0.96 ln2 / 8 = {0.96 * log(2) / 8:.5f} (stated >= 0.083)")
gl = []
for e in np.linspace(1e-4, 0.1, 2000):
    g = 1 - 0.5 * (sqrt(1 + 2 * e) + sqrt(1 - 2 * e))
    gl.append((g / e ** 2))
print(f"  gamma/eps'^2 over eps' in (0, 0.1]: min {min(gl):.4f} (claim >= 0.5), max {max(gl):.4f} (claim <= 2)")
r = min((lD * (1 - 4 * e ** 2) * log(2) / (4 * e ** 2)) /
        (0.083 * lD / (1 - 0.5 * (sqrt(1 + 2 * e) + sqrt(1 - 2 * e))))
        for e in np.linspace(1e-4, 0.1, 2000) for lD in [9])
print(f"  min over eps' of n1 / (0.083 lambda Delta / gamma) = {r:.4f} (claim >= 1)")

print("=" * 78)
print("(B) Cor 6.1(iii): rate competitor versus a one-input function competitor, p = 1/8")
p = 1 / 8
h_eq = lambda p, q: 1 - sqrt(p * q) - sqrt((1 - p) * (1 - q))
h_ne = lambda p, q: 1 - sqrt(p * (1 - q)) - sqrt((1 - p) * q)
print(f"  rate competitor (f, 3/16): gap h_eq(1/8, 3/16) = {h_eq(p, 3 / 16):.6f}")
for d in [6, 7, 8, 10, 16]:
    g = 2.0 ** -d * h_ne(p, p)
    print(f"  mu uniform on {{0,1}}^{d}: competitor (g, 1/8), g = f except at one input: gap = {g:.6f}"
          f"  {'< rate gap' if g < h_eq(p, 3 / 16) else '>= rate gap'}")

print("=" * 78)
print("(C) Prop 7.3(ii) with D* = infinity: walk with increments log(q2(y)/q1(y)), q1 = Bern(1/4), q2 = coin")
rng = np.random.default_rng(101)
inc1, inc0 = log2(0.5 / 0.25), log2(0.5 / 0.75)
mean = 0.5 * (inc1 + inc0)
print(f"  increments: y=1 -> {inc1:.4f}, y=0 -> {inc0:.4f}; mean = {mean:.4f} = (1/2) log2(4/3) = {0.5 * log2(4 / 3):.4f}")
lam, dl = 1.0, 5 - 2
Nn = 200000
lasts = []
for run in range(20):
    y = rng.integers(0, 2, size=Nn)
    S = np.cumsum(np.where(y == 1, inc1, inc0))
    pi1_map = S < lam * dl            # pi1 (shorter) is the unique MAP iff S_n < lambda*(l2 - l1)
    idx = np.flatnonzero(pi1_map)
    lasts.append(int(idx[-1]) + 1 if len(idx) else 0)
print(f"  lambda = {lam}: last n <= {Nn} at which pi1 is the MAP, 20 runs: max {max(lasts)}, median {int(np.median(lasts))}")
print("  (with mu(x) ~ x^-3 on x >= 1 and c(x) = 2^{-x^2}: E_mu log2(1/c) = sum x^2 x^-3 / zeta(3) = infinity,")
print("   so D(pi1) = D(pi2) = infinity = D*, both are in P, the log-ratio is bounded, and yet no oscillation.)")

print("=" * 78)
print("(D) ties at the boundary of Prop 4.4(b) / Prop 5.1(b)")

def ell(m):
    return m + 2 * ceil(log2(m + 1)) + 1

def p_in_span(n, m):
    """P[y in colspan(A)] for A uniform n x m over GF(2), y uniform independent; full column chain."""
    if m <= 0:
        return 0.0
    dist = {0: 1.0}
    for _ in range(m):
        new = {}
        for rk, pr in dist.items():
            pu = 1 - 2.0 ** (rk - n)
            new[rk + 1] = new.get(rk + 1, 0) + pr * pu
            new[rk] = new.get(rk, 0) + pr * (1 - pu)
        dist = new
    return sum(pr * 2.0 ** (rk - n) for rk, pr in dist.items())

def mbest(n, k, lam, strict):
    m, best = 1, 0
    while m < n + 60:
        lhs, rhs = lam * ell(m), lam * k + n
        if (lhs < rhs) if strict else (lhs <= rhs):
            best = m
        m += 1
    return best

cases = []
for k in range(10, 31):
    for n in range(1, 200):
        if 2 * ceil(log2(n + 6)) + 6 == k:          # lambda = 1 boundary of Prop 5.1(b)
            cases.append((k, n, 1.0))
            break
for lam, k in [(1.5, 20), (2.0, 24), (3.0, 30)]:    # lambda > 1 boundary of Prop 4.4(b)
    for n in range(1, 400):
        if abs((lam - 1) * n - lam * (k - 6 - 2 * ceil(log2(n + 6)))) < 1e-9:
            cases.append((k, n, lam))
for (k, n, lam) in cases:
    ms, mw = mbest(n, k, lam, True), mbest(n, k, lam, False)
    ps, pw = p_in_span(n, ms), p_in_span(n, mw)
    print(f"  lambda={lam} k={k} n={n}: strict m*={ms} P[parity strictly beats coin]={ps:.4f};"
          f"  weak m*={mw} P[weakly]={pw:.4f};  31/32={31/32:.4f}")
if not any(abs((lam - 1) * n - lam * (k - 6 - 2 * ceil(log2(n + 6)))) < 1e-9 for (k, n, lam) in cases if lam > 1):
    print("  (no exact lambda > 1 boundary case on this grid)")

print("=" * 78)
print("(E) k versus l*: toy class, X = {0..7}, mu uniform on A = {0,1,2,3}, nu = coin everywhere")
lstar, k, l_tab = 3, 12, 9
kraft = 2.0 ** -lstar + 2.0 ** -k + 256 * 2.0 ** -l_tab
# pi0: coin on A, mass 0 off A (defective; in E, length 3).  pi_nu: coin everywhere (length 12).
# tables: all 256 total functions X -> {0,1}, length 9 each.
ratios = []
for m in range(0, 5):                               # data = labels on m distinct inputs of A
    xi_over_nu = (2.0 ** -lstar + 2.0 ** -k) + (2 ** (8 - m)) * 2.0 ** -l_tab * 2 ** m
    ratios.append(log2(xi_over_nu))
delta = max(ratios)
S = 4
J_fill, J_pinu, J_pi0 = l_tab, k + S, lstar + S
print(f"  Kraft sum = {kraft:.4f}; delta* = {delta:.4f} (the same on every path)")
print(f"  full table on A: S = {S}; best fill-in J_1 = {J_fill}; J_1(pi_nu) = {J_pinu}; J_1(pi0) = {J_pi0}")
print(f"  J_1(fill) - J_1(pi_nu) = {J_fill - J_pinu};  stated lower end -l* - delta* = {-lstar - delta:.3f}"
      f"  -> {'holds' if J_fill - J_pinu >= -lstar - delta else 'FAILS'};  with k: -k - delta* = {-k - delta:.3f}"
      f" -> {'holds' if J_fill - J_pinu >= -k - delta else 'fails'}")

print("=" * 78)
print("(F) arithmetic side conditions")
worst = -1e9
for R in range(0, 200, 7):
    for n in [1, 2, 3, 10, 1000, 10 ** 6]:
        for d in [0, 1, 5, 20, 100]:
            for Y in [2, 3, 10]:
                B = n * (d + 1 + log2(Y))
                M = int(2 ** (R + 2) * B) + 1
                lhs = ceil(log2(M))
                rhs = R + 4 + log2(n) + log2(d + 1 + log2(Y))
                worst = max(worst, lhs - rhs)
print(f"  Lemma 5.2: max of ceil(log2 M) - (R + 4 + log2 n + log2(d+1+log2|Y|)) = {worst:.4f} (claim <= 0)")
w2 = max(1 / (1 - exp(-a)) - (1 + 1 / a) for a in np.geomspace(1e-6, 50, 5000))
print(f"  Thm 4.1(v): max of 1/(1-e^-a) - (1+1/a) over a in [1e-6, 50] = {w2:.2e} (claim <= 0)")
