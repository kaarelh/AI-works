"""Independent recomputation of the explicit constants in A.md (referee check, computation lens).

Everything here is recomputed from the formulas, not copied from A_scripts.
"""
import math
from fractions import Fraction
import numpy as np
import mpmath as mp
from scipy import optimize, stats, special

mp.mp.dps = 60
out = []
def say(*a):
    s = " ".join(str(x) for x in a)
    print(s)

# ---------------------------------------------------------------- slope alpha_d
say("== (1) slope alpha_d = 0.5 log(4 sqrt(2d))")
for d in [1, 2, 3, 10, 30, 100]:
    al = mp.log(4 * mp.sqrt(2 * d)) / 2
    lhs = 2 * mp.e ** (-2 * al); rhs = 1 / (2 * mp.sqrt(2 * d))
    say(f"  d={d}: alpha={float(al):.6f}  2e^(-2alpha)={float(lhs):.6e} vs 1/(2sqrt(2d))={float(rhs):.6e}"
        f"  (d+1)alpha^2={float((d+1)*al**2):.4f}")
dd = np.arange(1, 10**6 + 1, dtype=float)
al = 0.5 * np.log(4 * np.sqrt(2 * dd))
say("  alpha_d <= 1.5 log(d+1) for all 1<=d<=1e6:", bool(np.all(al <= 1.5 * np.log(dd + 1))),
    " min slack", float(np.min(1.5 * np.log(dd + 1) - al)))
say("  d(d+1)alpha_d^2 <= 4.5 d^2 log^2(d+1) for 1<=d<=1e6:",
    bool(np.all(dd * (dd + 1) * al ** 2 <= 4.5 * dd ** 2 * np.log(dd + 1) ** 2)))
say("  2 alpha_1^2 =", float(2 * (mp.log(4 * mp.sqrt(2)) / 2) ** 2), "(A.md: > 1.4)")
say("  1/tanh(1) =", float(1 / mp.tanh(1)), " 2 sqrt 2 =", float(2 * mp.sqrt(2)))

# ---------------------------------------------------------------- parity coefficients
say("== (2) parity coefficients c_{k,inf} (exact) and c_{k,alpha_d} (60 digits)")
def ck_inf_exact(k):
    b = 0 if k % 2 else 1
    tot = Fraction(0)
    for j in range(k + 1):          # j = number of -1 coordinates
        t = k - 2 * j - b
        tot += Fraction(math.comb(k, j) * (-1) ** j * (1 if t > 0 else -1))
    return tot / 2 ** k
def ck_inf_closed(k):
    if k % 2:
        m = (k - 1) // 2; return Fraction((-1) ** m * math.comb(2 * m, m), 4 ** m)
    m = k // 2; return Fraction((-1) ** (m - 1) * math.comb(2 * m, m), 4 ** m)
ok = all(ck_inf_exact(k) == ck_inf_closed(k) for k in range(1, 61))
ok2 = all(ck_inf_exact(k) ** 2 >= Fraction(1, 2 * k) for k in range(1, 61))
say("  closed form (a) exact for k<=60:", ok, "; |c_{k,inf}|>=1/sqrt(2k) exact for k<=60:", ok2)
def ck_alpha(k, alpha):
    b = 0 if k % 2 else 1
    s = mp.mpf(0)
    for j in range(k + 1):
        s += mp.binomial(k, j) * (-1) ** j * mp.tanh(alpha * (k - 2 * j - b))
    return s / 2 ** k
worst = (10.0, None)
for d in range(1, 81):
    alpha = mp.log(4 * mp.sqrt(2 * d)) / 2
    for k in range(1, d + 1):
        r = abs(ck_alpha(k, alpha)) * 2 * mp.sqrt(2 * k)
        if r < worst[0]:
            worst = (float(r), (d, k))
        # Lemma 2.2(c): |c_{k,a}-c_{k,inf}| <= 1 - tanh a
        diff = abs(ck_alpha(k, alpha) - mp.mpf(ck_inf_exact(k).numerator) / ck_inf_exact(k).denominator) if k <= 60 else 0
        assert diff <= 1 - mp.tanh(alpha) + mp.mpf(10) ** -40
say(f"  min over 1<=k<=d<=80 of |c_(k,alpha_d)| 2 sqrt(2k) = {worst[0]:.4f} at (d,k)={worst[1]}  (Lemma 2.2(d) needs >=1)")

# ---------------------------------------------------------------- chain Lemma 2.3
say("== (3) scalar tanh chain, Lemma 2.3 and Step 6")
mp.mp.dps = 50
def chain(g, R, H):
    y = mp.tanh(g / R ** (H - 1))
    for _ in range(H - 2):
        y = mp.tanh(R * y)
    return R * y
worst_ratio = 0; worst_acc = 0; worst_acc_at = None
for H in [2, 3, 4, 5, 8, 12, 20]:
    for R2 in [2, 2.5, 4.5, 9, 30, 300, 1e4]:
        R = mp.sqrt(R2)
        for g in [mp.mpf(x) for x in np.linspace(-1.5, 1.5, 121) if abs(x) > 1e-12]:
            err = abs(chain(g, R, H) - g)
            bnd = abs(g) ** 3 / 3 * sum(R ** (-2 * i) for i in range(1, H))
            worst_ratio = max(worst_ratio, float(err / bnd))
    for a in [1.0, 0.9, 0.7, 0.5, 0.3, 0.1, 0.01, 1e-4]:
        R = mp.sqrt(mp.mpf(9) / (2 * a))
        for g in [mp.mpf(x) for x in np.linspace(-1.5, 1.5, 61)]:
            v = float(abs(chain(g, R, H) - g) / (mp.mpf(a) / 2))
            if v > worst_acc:
                worst_acc, worst_acc_at = v, (H, a, float(g))
say(f"  max (chain error)/(bound 2.3) = {worst_ratio:.10f}  (must be <=1)")
say(f"  max (chain error)/(a/2) at R^2=9/(2a), |g|<=3/2: {worst_acc:.4f} at (H,a,g)={worst_acc_at}  (must be <=1)")
say("  Step 6 arithmetic: 2(3/2)^3/3 * 2a/9 / a =", float(mp.mpf(2) * mp.mpf(1.5) ** 3 / 3 * 2 / 9), "(A.md: 1/2)")

# ---------------------------------------------------------------- beta
say("== (4) beta(lambda) = E[1/K; K>=1], K ~ Poisson(lambda)")
mp.mp.dps = 40
beta = lambda lam: mp.e ** (-lam) * (mp.ei(lam) - mp.euler - mp.log(lam))
beta_series = lambda lam: mp.e ** (-lam) * mp.nsum(lambda k: lam ** k / (k * mp.factorial(k)), [1, mp.inf])
beta_int = lambda lam: mp.e ** (-lam) * mp.quad(lambda u: mp.expm1(u) / u, [0, lam])
for lam in [0.5, 1, 1.5, 2, 4]:
    say(f"  beta({lam}) closed={float(beta(lam)):.7f} series={float(beta_series(lam)):.7f} integral={float(beta_int(lam)):.7f}")
h = lambda lam: -mp.expm1(-lam) / lam
lamstar = mp.findroot(lambda l: h(l) - beta(l), 1.5)
say(f"  lambda* (root of beta'=h-beta) = {float(lamstar):.6f}, beta(lambda*) = {float(beta(lamstar)):.7f},"
    f" (1-e^-l*)/l* = {float(h(lamstar)):.7f}")
for lam in [1e-1, 1e-2, 1e-3, 1e-5]:
    say(f"  beta'({lam:g}) = h-beta = {float(h(lam) - beta(lam)):.6f}   (sup |beta'| over (0,inf) is 1, approached as lambda->0)")
mn = min(float(h(l) - beta(l)) for l in np.linspace(0.05, 40, 800))
say(f"  min beta' on [0.05,40] = {mn:.4f}  (so |beta'|<=1 also on the decreasing branch)")
say(f"  1+beta(1) = {1+float(beta(1)):.6f};  (sqrt(beta(1)) - 0.1)^2 = {float((mp.sqrt(beta(1)) - mp.mpf('0.1'))**2):.6f}  (A.md Remark 4.7: 0.356)")

# exact beta_n vs Le Cam
say("  binomial beta_n vs beta(n/M), Le Cam bound n/M^2:")
def beta_n(n, M):
    p = mp.mpf(1) / M
    s = mp.mpf(0); k = 1
    term_log = None
    # sum_{k=1}^{kmax} C(n,k) p^k (1-p)^(n-k) / k, with kmax large enough
    for k in range(1, min(n, 200) + 1):
        s += mp.binomial(n, k) * p ** k * (1 - p) ** (n - k) / k
    return s
for d in [4, 6, 8, 10, 14, 20]:
    M = 2 ** d
    for lam in [1, 1.5]:
        n = int(lam * M)
        bn = beta_n(n, M)
        say(f"    d={d:2d} n={n:8d}: beta_n={float(bn):.8f} |beta_n-beta(lam)|={float(abs(bn-beta(mp.mpf(n)/M))):.2e} <= n/M^2={n/M**2:.2e}: {abs(bn-beta(mp.mpf(n)/M)) <= mp.mpf(n)/M**2}")

# ---------------------------------------------------------------- Table 4.1, continuous optimisation in a
say("== (5) Table 4.1 recomputed: c=1, t=1, delta=0.01; continuous optimisation over a")
def alpha_d(d): return 0.5 * math.log(4 * math.sqrt(2 * d))
def Kmem(d, s, a, H): return d * (d + 1) * alpha_d(d) ** 2 + (H + 1) * max((8 * d * s) ** (1 / H), 9 / (2 * a))
def e_low(d, H, lam, c, a, t=1.0, delta=0.01, bn=None):
    M = 2.0 ** d; n = lam * M; s = min(n, M)
    eps = c * (Kmem(d, s, a, H) + t) / M + lam * a ** 2
    conc = math.sqrt(2 * lam * math.log(1 / delta) / M)
    return max(0.0, math.sqrt(max(0.0, bn - conc)) - math.sqrt(eps)) ** 2, eps
def best_a(d, H, lam, c, bn):
    f = lambda la: -e_low(d, H, lam, c, 10 ** la, bn=bn)[0]
    grid = np.linspace(-14, 0, 1401)
    vals = [f(x) for x in grid]
    i = int(np.argmin(vals))
    lo, hi = grid[max(i - 1, 0)], grid[min(i + 1, len(grid) - 1)]
    r = optimize.minimize_scalar(f, bounds=(lo, hi), method="bounded", options={"xatol": 1e-12})
    return -r.fun, 10 ** r.x
bn_cache = {}
for lam in [1.0, 1.5]:
    for d in [20, 30, 40, 60]:
        M = 2 ** d; n = int(lam * M)
        # beta_n: Le Cam => |beta_n - beta(lam)| <= lam/M; use the exact Poisson value (error < 1e-6 here)
        bn_cache[(lam, d)] = float(beta(lam))
rows = [(2, 20), (2, 30), (2, 40), (2, 60), (3, 20), (3, 30), (3, 40), (4, 30)]
for H, d in rows:
    res = []
    for lam in [1.0, 1.5]:
        e, a = best_a(d, H, lam, 1.0, bn_cache[(lam, d)])
        res.append((e, a))
    M = 2 ** d
    a1 = res[0][1]
    N0 = math.floor(64 * math.log(2) * d * (d + 1) * M / a1 ** 2) + 1
    say(f"  H={H} d={d}: e(lam=1)={res[0][0]:.4f} [a*={res[0][1]:.2e}]  e(lam=1.5)={res[1][0]:.4f} [a*={res[1][1]:.2e}]"
        f"  K_mem(a*)={Kmem(d, M, a1, H):.2e}  N0={N0:.2e}")

say("  largest c with e_low >= beta_n/2 (bisection in log c, a optimised continuously):")
for H, d in [(2, 30), (3, 30)]:
    bn = bn_cache[(1.0, d)]
    lo, hi = 0.0, 12.0
    for _ in range(80):
        mid = (lo + hi) / 2
        if best_a(d, H, 1.0, 10 ** mid, bn)[0] >= bn / 2: lo = mid
        else: hi = mid
    n = 2 ** d
    say(f"    (H,d)=({H},{d}): c_max = {10**lo:.2f};  n^(1-1/H) d^(-1/H) = {n**(1-1/H)*d**(-1/H):.3e}")

# ---------------------------------------------------------------- Corollary 4.5 constants
say("== (6) Corollary 4.5 constants")
say("  64 log 2 =", 64 * math.log(2))
for d in [5, 10, 20, 40]:
    M = 2 ** d; c = 1.0; a = (max(c, 1) / M) ** (1 / 3)
    N0 = math.floor(64 * math.log(2) * d * (d + 1) * M / a ** 2) + 1
    say(f"  d={d}: N0={N0:.4e} <= 45 d(d+1) 2^(5d/3) = {45*d*(d+1)*2**(5*d/3):.4e}: {N0 <= 45*d*(d+1)*2**(5*d/3)}")

# ---------------------------------------------------------------- Lemma 6.4 constants
say("== (7) Lemma 6.4(b) numeric constants")
say("  (1-e^-1)/16 =", (1 - math.exp(-1)) / 16, " (A.md: 0.039);  (1-e^-1)^2/2 =", (1 - math.exp(-1)) ** 2 / 2, " (A.md: 0.19)")
ok = True
for n in range(2, 400):
    n1 = n // 2; n2 = n - n1
    ok &= n1 * n2 >= n * (n - 1) / 4
say("  n1 n2 >= n(n-1)/4 for 2<=n<400:", ok)

# ---------------------------------------------------------------- Prop 6.3 constants
say("== (8) Prop 6.3: tanh(2 tanh 1) =", math.tanh(2 * math.tanh(1)), " tanh 1 =", math.tanh(1),
    " tanh 2 =", math.tanh(2), " 1/tanh1 =", 1 / math.tanh(1))
tau = math.tanh(1); mn = tau
for _ in range(50):
    tau = math.tanh(2 * tau); mn = min(mn, tau)
say("  min_l tau_l over 50 layers =", mn)

# ---------------------------------------------------------------- Prop 8.2 numbers, A' radii
say("== (9) Prop 8.2 numbers (s=2^d, a=1/2) and A' radius")
def D(d, H): return math.sqrt(2 * math.log(2)) * (d + 1) + (H - 1) / 2
for H, d in [(2, 40), (3, 40)]:
    s = 2 ** d; a = 0.5
    Klow = H * ((1 - a) * math.sqrt(s) / D(d, H)) ** (2 / H)
    say(f"  (H,d)=({H},{d}): K_mem={Kmem(d, s, a, H):.4e}  lower bound={Klow:.4e}")
for d in [20, 30, 40]:
    n = 2 ** d; H = 2; L = 3; t = 1.0
    a = n ** (-1 / 3)
    K2 = max(n + t, Kmem(d, n, a, H))
    r = (1 / n) * (L / K2) ** (L / 2)
    say(f"  d={d}: K2={K2:.4e} (K_mem={Kmem(d, n, a, H):.3e}) r={r:.4e} log2 r={math.log2(r):.2f}; 3^1.5 n^-2.5={3**1.5*n**-2.5:.4e}")
say("  3^1.5 =", 3 ** 1.5)
