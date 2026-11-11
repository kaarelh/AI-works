"""Independent sanity checks for the referee report on A.md (logic lens).
Not proofs. Each block prints what it checks."""
import math, itertools, random
import numpy as np
from scipy import integrate, optimize, special, stats
import mpmath as mp

print("== 1. beta(lambda) values (Lemma 4.3(d)) ==")
def beta(lam):
    # e^{-lam} * int_0^lam (e^u - 1)/u du
    val, _ = integrate.quad(lambda u: math.expm1(u) / u if u > 0 else 1.0, 0, lam, epsabs=1e-14, epsrel=1e-14)
    return math.exp(-lam) * val
def beta_series(lam, K=400):
    return sum(stats.poisson.pmf(k, lam) / k for k in range(1, K))
print("beta(1) quad =", beta(1.0), " series =", beta_series(1.0))
res = optimize.minimize_scalar(lambda l: -beta(l), bounds=(0.5, 3.0), method="bounded", options={"xatol": 1e-10})
ls = res.x
print("argmax lambda* =", ls, " beta(lambda*) =", beta(ls), " (1-e^{-l})/l =", (1 - math.exp(-ls)) / ls)
print("Ei form at 1:", math.exp(-1) * (special.expi(1.0) - np.euler_gamma - math.log(1.0)))
# Lipschitz
grid = np.linspace(1e-4, 20, 4000)
b = np.array([beta(x) for x in grid])
print("max |beta'| on grid ~", np.max(np.abs(np.diff(b) / np.diff(grid))))

print("\n== 2. Lemma 2.2(d): |c_{k,alpha_d}| * 2 sqrt(2k) >= 1, k <= d <= 40 (mpmath) ==")
mp.mp.dps = 80
def c_k_alpha(k, alpha):
    bk = 0 if k % 2 == 1 else 1
    s = mp.mpf(0)
    for j in range(k + 1):  # j = number of -1 coordinates
        s += (-1) ** j * mp.binomial(k, j) * mp.tanh(alpha * (k - 2 * j - bk))
    return s / mp.mpf(2) ** k
worst = (10, None)
for d in range(1, 41):
    ad = mp.log(4 * mp.sqrt(2 * d)) / 2
    for k in range(1, d + 1):
        r = abs(c_k_alpha(k, ad)) * 2 * mp.sqrt(2 * k)
        if r < worst[0]:
            worst = (float(r), (k, d))
print("min ratio", worst)
# closed form check (a)
ok = True
for k in range(1, 30):
    bk = 0 if k % 2 == 1 else 1
    s = sum((-1) ** j * math.comb(k, j) * (1 if (k - 2 * j - bk) > 0 else -1) for j in range(k + 1))
    if k % 2 == 1:
        m = (k - 1) // 2; cf = (-1) ** m * math.comb(2 * m, m) * 2  # times 2^k / 4^m = 2
        ok &= (s == (-1) ** m * math.comb(2 * m, m) * 2)
    else:
        m = k // 2
        ok &= (s == (-1) ** (m - 1) * math.comb(2 * m, m))
print("closed form (a) exact for k<30:", ok)

print("\n== 3. Lemma 2.3 chain bound ==")
worst = 0
rng = np.random.default_rng(0)
for _ in range(20000):
    H = rng.integers(2, 7)
    R = math.sqrt(2) + rng.random() * 10
    g = (rng.random() * 2 - 1) * 3
    y = math.tanh(g / R ** (H - 1))
    for _j in range(2, H):
        y = math.tanh(R * y)
    err = abs(R * y - g)
    bound = abs(g) ** 3 / 3 * sum(R ** (-2 * i) for i in range(1, H))
    if bound > 0:
        worst = max(worst, err / bound)
print("max err/bound =", worst)

print("\n== 4. Lemma 6.4(b) Monte Carlo (no atom with both labels) vs bound ==")
def bound64(n, M):
    n1 = n // 2; n2 = n - n1
    mu1 = M * (1 - (1 - 1 / M) ** n1)
    return math.exp(-n2 * mu1 / (4 * M)) + math.exp(-mu1 ** 2 / (2 * n1))
rr = random.Random(1)
for (M, n) in [(64, 16), (256, 64), (256, 128), (1024, 128), (1024, 512)]:
    trials = 4000; cnt = 0
    for _ in range(trials):
        seen = {}
        conflict = False
        for i in range(n):
            x = rr.randrange(M); y = rr.choice((-1, 1))
            if x in seen and seen[x] != y:
                conflict = True; break
            seen.setdefault(x, y)
        cnt += (not conflict)
    print(f"M={M} n={n}: MC P(no conflict)={cnt/trials:.4f}  bound={bound64(n, M):.4f}  "
          f"numeric form={math.exp(-0.039*n*(n-1)/M)+math.exp(-0.19*(n//2)):.4f}")

print("\n== 5. Prop 6.3 chain tau_l = tanh(2 tau_{l-1}) ==")
t = math.tanh(1.0); print("tanh 1 =", t, " tanh(2 tanh 1) =", math.tanh(2 * t), " 1/tanh1 =", 1 / t)

print("\n== 6. Lemma 3.2 bound (3.2) in a 1-D toy: F(w) = w^2 + 4 sin^2(w)  (F >= kappa = w^2, Gamma=1, P=1) ==")
F = lambda w: w * w + 4 * math.sin(w) ** 2
Fstar = 0.0; t = 1.0; p = 0.5
# ball where F <= t/4 around 0: F(w) <= w^2 + 4 w^2 = 5 w^2 <= 1/4 -> |w| <= sqrt(1/20)
delta = math.sqrt(1 / 20); V = 2 * delta
for s2 in [0.2, 0.1, 0.05, 0.02]:
    Z, _ = integrate.quad(lambda w: math.exp(-F(w) / (2 * s2)), -50, 50, limit=400, points=[0])
    num, _ = integrate.quad(lambda w: (1 + F(w)) ** p * math.exp(-F(w) / (2 * s2)) * (F(w) > Fstar + t), -50, 50, limit=800)
    lhs = num / Z
    rhs = (1 + Fstar + t) ** p / V * (8 * math.pi * s2 * (Fstar + t) / t) ** 0.5 * math.exp(-t / (4 * s2))
    print(f"sigma^2={s2}: lhs={lhs:.3e} rhs={rhs:.3e} ok={lhs <= rhs}")
