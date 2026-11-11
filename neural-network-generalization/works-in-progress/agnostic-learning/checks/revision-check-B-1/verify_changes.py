"""Independent checks of the passages changed in the revision of B-tempered-likelihood.md.
Written from the statements in the note, not from the authors' scripts."""
import math
import numpy as np
from mpmath import mp, mpf, log as mlog, ceil as mceil

mp.dps = 60
rng = np.random.default_rng(12345)

# ---------------------------------------------------------------------------------------------
print("(1) Lemma 4.2, Step 1:  ln(4L(L-1)) + L ln2 <= 2L for L >= 2;  also the L>=3 bound route")
worst = min(2 * L - (math.log(4 * L * (L - 1)) + L * math.log(2)) for L in range(2, 5001))
print(f"    min over L=2..5000 of 2L - LHS = {worst:.4f} (>0 needed); at L=2: {4 - math.log(32):.4f}")
f = lambda L: L * (2 - math.log(2)) - 2 * math.log(L) - math.log(4)
print(f"    L(2-ln2)-2lnL-ln4: L=2 {f(2):.4f} (negative, so L=2 needs its own line), L=3 {f(3):.4f}, "
      f"increasing on [2,5000]: {all(f(L + 1) > f(L) for L in range(2, 5000))}")

print("(2) Lemma 4.2, Step 4: two inequalities on a grid (60-digit arithmetic)")
viol1 = viol2 = viol_term = cnt = 0
minslack1 = minslack2 = mpf(10) ** 9
for L in [2, 3, 4, 5, 8, 12, 16, 17, 20, 30, 50, 100, 200, 500, 1000]:
    for d in [1, 2, 3, 10, 100, 10 ** 4]:
        for K in [1, 1.5, 10, 1e3, 1e8, 1e12]:
            for a in [1, 0.3, 1e-2, 1e-4, 1e-8]:
                cnt += 1
                L_, d_, K_, a_ = mpf(L), mpf(d), mpf(K), mpf(a)
                ell = mlog(17 * d_ * K_ / a_)
                lhs1 = mlog(d_) + 2 * (L_ - 1) * mlog(K_) + 4 * mlog(1 / a_) + mlog(ell)
                rhs1 = (2 * L_ + 1) * ell
                lhs2 = mlog(2 ** (L_ + 5) * (d_ + L_ + 1) / a_)
                rhs2 = L_ + 5 + ell
                viol1 += lhs1 > rhs1; viol2 += lhs2 > rhs2
                minslack1 = min(minslack1, rhs1 - lhs1); minslack2 = min(minslack2, rhs2 - lhs2)
                # the termwise split that the note says fails for large L
                viol_term += (mlog(d_ + L_ + 1) + mlog(1 / a_) > ell)
print(f"    {cnt} points: violations of ln d+2(L-1)lnK+4ln(1/a)+ln l <= (2L+1)l: {viol1} (min slack {float(minslack1):.3f});"
      f"  of ln(2^(L+5)(d+L+1)/a) <= L+5+l: {viol2} (min slack {float(minslack2):.3f})")
print(f"    termwise split ln(d+L+1)+ln(1/a) <= l fails at {viol_term} points; with d=K=1 it first fails at "
      f"L={min(L for L in range(2, 100) if math.log(1 + L + 1) > math.log(17))}")

# ---------------------------------------------------------------------------------------------
print("(3) Remark 6.1a: n^theta + zeta <= (1+zeta) n^theta for n >= 1:",
      all(n ** th + z <= (1 + z) * n ** th + 1e-12 for n in [1, 2, 10, 1e6] for th in [0.01, 0.3, 0.9] for z in [0.1, 1, 5]))

# ---------------------------------------------------------------------------------------------
print("(4) Section 1: fixed c, noisy cube, t = n^(-1/4), s = n, H >= 2 (Prop 7.3 / Lemma 7.2 formulas)")
def kmem(d, H, t, s):
    n = 2.0 ** d
    Amax = (d + 1) * math.sqrt(s)
    beta = max(1.0, 0.5 * math.log(2 * Amax / t))
    R2 = max(2.0, 9 / (4 * t), Amax ** (2 / H))
    return beta ** 2 * d ** 3 + (H + 1) * R2
for H in [2, 3]:
    for c in [1e-3, 1.0, 100.0]:
        row = []
        for d in [20, 40, 80, 160, 320]:
            n = 2.0 ** d; t = n ** -0.25
            K = kmem(d, H, t, n)
            eps = c / n * (K + 1) + 9 * t ** 2
            row.append(f"d={d}: K/(sqrt(n) log2 n)={K / (math.sqrt(n) * d):.3g}, eps={eps:.3g}")
        print(f"    H={H} c={c:g}: " + ";  ".join(row))
d = 30; n = 2.0 ** d; t = n ** -0.25
mt = math.ceil(2 * (d + 1) * ((d + 1) ** 2 * n) * math.log(2) / t ** 2) + 1
print(f"    m_t at d=30 equals ceil(2(d+1)^3 n^(3/2) ln2)+1: {mt == math.ceil(2 * (d + 1) ** 3 * n ** 1.5 * math.log(2)) + 1};"
      f"  t<=1/4 iff n>=256: {256 ** -0.25 <= 0.25 and 255 ** -0.25 > 0.25}")

# ---------------------------------------------------------------------------------------------
print("(5) Theorem 6.3 displayed Exc_n, L=3 (H=2), d=10, m=B=1, eps=0.1, delta=0.05, theta=1/4: first crossing")
def exc_disp(n, th, H, d, m, B, dl):
    Es = d * (d + 1) * B ** 2 + 2 * H * m ** 2 * B ** 2; U = m * B
    Dn = math.sqrt(2 * (d + 1) * math.log1p(n)) + (H - 1) / 2
    return (Es + 1) * n ** -th + 8 * (2 / H) ** (H / 2) * Dn * n ** (-(1 - th * H) / 2) + (4 + (U + 1) ** 2) * math.sqrt(math.log(2 / dl) / (2 * n))
def excK(n, th, H, d, m, B, dl):
    Es = d * (d + 1) * B ** 2 + 2 * H * m ** 2 * B ** 2; U = m * B; K = n ** th + 1
    Dn = math.sqrt(2 * (d + 1) * math.log1p(n)) + (H - 1) / 2
    return (Es + 1) * n ** -th + 8 * (K / H) ** (H / 2) * Dn / math.sqrt(n) + (4 + (U + 1) ** 2) * math.sqrt(math.log(2 / dl) / (2 * n))
def first_cross(f):
    lo, hi = 0.0, 60.0
    for _ in range(200):
        mid = (lo + hi) / 2
        if f(10 ** mid) <= 0.1: hi = mid
        else: lo = mid
    return hi
print(f"    displayed: 10^{first_cross(lambda n: exc_disp(n, .25, 2, 10, 1, 1, .05)):.3f};  K=n^theta+1: 10^{first_cross(lambda n: excK(n, .25, 2, 10, 1, 1, .05)):.3f};"
      f"  displayed value at 10^13.4: {exc_disp(10 ** 13.4, .25, 2, 10, 1, 1, .05):.4f}")
# monotone after crossing?
xs = np.linspace(14.1, 40, 400)
print("    displayed bound <= 0.1 on [10^14.1, 10^40]:", all(exc_disp(10 ** x, .25, 2, 10, 1, 1, .05) <= 0.1 for x in xs))

# ---------------------------------------------------------------------------------------------
print("(6) Theorem 6.3 degrees of n0 per variable (local log-log slopes far out)")
def log_n0(th, H, d, m, B, eps, dl):
    L = H + 1; Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B; g = 1 - th * H; c2 = (2 / H) ** (H / 2)
    t = [(1 / th) * math.log(3 * (Es + 1) / eps), (4 / g) * math.log(48 * c2 * math.sqrt(4 * (d + 1) / g) / eps),
         math.log(9 * (4 + (U + 1) ** 2) ** 2 * math.log(2 / dl) / (2 * eps ** 2))]
    if H > 1: t.append((2 / g) * math.log(24 * c2 * (H - 1) / eps))
    return max(t)
for (H, th) in [(2, 0.25), (2, 0.45), (1, 0.8), (1, 0.3), (3, 0.3)]:
    base = dict(th=th, H=H, d=10, m=1, B=1, eps=0.1, dl=0.05)
    def slope(var, big):
        a = dict(base); a[var] = big; b = dict(base); b[var] = big * 10
        return (log_n0(**b) - log_n0(**a)) / math.log(10)
    sd = slope("d", 1e12); sm = slope("m", 1e12); sB = slope("B", 1e12)
    se = (log_n0(**{**base, "eps": 1e-30}) - log_n0(**{**base, "eps": 1e-29})) / math.log(10)
    print(f"    H={H} theta={th}: slope d {sd:.3f} (claim {max(2 / th, 2 / (1 - th * H)):.3f});  m {sm:.3f}, B {sB:.3f} (claim {max(2 / th, 4):.3f});"
          f"  1/eps {se:.3f} (claim {max(1 / th, 4 / (1 - th * H)):.3f})")

# ---------------------------------------------------------------------------------------------
print("(7) Corollary 8.1 exponents (sympy-free): beta>0 at H=1 iff alpha<1/8; min switches at 1/16; H>=2 identities")
ok = True
for a in np.linspace(1e-4, 0.2499, 2000):
    b1 = min((1 - 4 * a) / 3, 0.5 - 4 * a)
    ok &= ((b1 > 0) == (a < 1 / 8))
    ok &= (abs(b1 - (0.5 - 4 * a)) < 1e-12) == (a >= 1 / 16 - 1e-12)
for H in [2, 3, 4, 7]:
    for a in np.linspace(1e-4, 1 / (4 * H) - 1e-4, 200):
        th = (1 + 8 * a) / (H + 2); be = (1 - 4 * a * H) / (H + 2)
        ok &= abs(4 * a - th + be) < 1e-12 and abs((1 - th * H) / 2 - be) < 1e-12 and 4 * a - 0.5 <= -be + 1e-12 and th < 1 / H
print("    all identities hold:", ok, ";  depth 3, alpha=1/16 -> beta =", (1 - 4 * (1 / 16) * 2) / 4)

# ---------------------------------------------------------------------------------------------
print("(8) Remark 8.2: biased tanh net (width m, |weights|,|biases|<=B) == bias-free net of width m+1, weights <= max(B,1)/tanh 1")
T1 = math.tanh(1.0)
maxerr = 0.0; maxw_ratio = 0.0
for trial in range(300):
    H = int(rng.integers(1, 5)); m = int(rng.integers(1, 6)); d = int(rng.integers(1, 5)); B = float(rng.choice([0.3, 1.0, 2.5]))
    W = [rng.uniform(-B, B, (m, d))] + [rng.uniform(-B, B, (m, m)) for _ in range(H - 1)]
    b = [rng.uniform(-B, B, m) for _ in range(H)]
    v = rng.uniform(-B, B, m); bo = rng.uniform(-B, B)
    def f_biased(x):
        h = np.tanh(W[0] @ x + b[0])
        for l in range(1, H): h = np.tanh(W[l] @ h + b[l])
        return v @ h + bo
    # bias-free, width m+1, last unit = constant tanh(1)
    V1 = np.zeros((m + 1, d + 1)); V1[:m, 0] = b[0]; V1[:m, 1:] = W[0]; V1[m, 0] = 1.0
    Vs = []
    for l in range(1, H):
        M_ = np.zeros((m + 1, m + 1)); M_[:m, :m] = W[l]; M_[:m, m] = b[l] / T1; M_[m, m] = 1 / T1; Vs.append(M_)
    vv = np.zeros(m + 1); vv[:m] = v; vv[m] = bo / T1
    def f_free(x):
        h = np.tanh(V1 @ np.concatenate([[1.0], x]))
        for M_ in Vs: h = np.tanh(M_ @ h)
        return vv @ h
    for _ in range(20):
        x = rng.uniform(-1, 1, d)
        maxerr = max(maxerr, abs(f_biased(x) - f_free(x)))
    allw = np.concatenate([V1.ravel()] + [M_.ravel() for M_ in Vs] + [vv])
    maxw_ratio = max(maxw_ratio, np.max(np.abs(allw)) / (max(B, 1) / T1))
print(f"    max |f_biased - f_free| = {maxerr:.2e};  max |weight| / (max(B,1)/tanh1) = {maxw_ratio:.4f} (<= 1)")

# ---------------------------------------------------------------------------------------------
print("(9) Remark 9.4 / Lemma 7.2 Step 6: scalar chain with gain R, preactivation f/R^(H-1): |z - f| <= 2|f|^3/(3R^2) for R^2>=2")
worst = 0.0
for H in range(2, 9):
    for R2 in [2.0, 3.0, 10.0, 100.0, 1e4]:
        R = math.sqrt(R2)
        for fv in np.linspace(-50, 50, 2001):
            s = fv / R ** (H - 1); u = math.tanh(s)
            for _ in range(3, H + 1): u = math.tanh(R * u)
            z = R * u
            if fv != 0: worst = max(worst, abs(z - fv) / (2 * abs(fv) ** 3 / (3 * R2)))
print(f"    max ratio |z-f| / (2|f|^3/(3R^2)) = {worst:.4f} (<= 1 needed)")

# ---------------------------------------------------------------------------------------------
print("(10) Section 9 counterexample g_R: derivative at 0 and Lemma 2.1(b) energy lower bound")
for L in [2, 3, 5]:
    H = L - 1
    for R in [10.0, 1e3]:
        g = lambda x: 0.1 * (lambda y: [y := math.tanh(y) for _ in range(H - 1)] and y)(math.tanh(R * x)) if H > 1 else 0.1 * math.tanh(R * x)
        h = 1e-7; der = (g(h) - g(-h)) / (2 * h)
        print(f"    L={L} R={R:g}: g'(0)={der:.4f} (R/10={R / 10:g}); energy lower bound L(R/10)^(2/L) = {L * (R / 10) ** (2 / L):.3f}")

# ---------------------------------------------------------------------------------------------
print("(11) Prop 9.1(c): (1+5/(4L))4^(1/L) <= 3.25 with equality at L=2; 2^(1/L)/sqrt(L) <= 1; omega^2>=2 iff n^theta >= ~")
print("    ", max((1 + 5 / (4 * L)) * 4 ** (1 / L) for L in range(2, 200)), max(2 ** (1 / L) / math.sqrt(L) for L in range(2, 200)),
      all(4 ** (1 / L) * (2 * L + 1) / L >= 2 for L in range(2, 200)))
print("    theta<=1/2 suffices for the H=1 Hoeffding term: kappa=o(n^theta) => (sqrt(kappa)+1)^2 n^(-1/2) -> 0 at theta=1/2:",
      [round((math.sqrt(n ** 0.5 / math.log(n)) + 1) ** 2 / math.sqrt(n), 4) for n in [1e4, 1e8, 1e16, 1e32]])

# ---------------------------------------------------------------------------------------------
print("(12) after Thm 7.4: for 1/H<theta<=2/H the slowest term of eps_n is (H+1)(d+1)^(2/H) n^(1/H-theta)")
for (H, th) in [(2, 0.55), (2, 0.75), (2, 1.0), (3, 0.4), (3, 0.6)]:
    for d in [50, 400, 1600]:
        n = 2.0 ** d; beta = max(1, 0.5 * math.log(2 * (d + 1) * n ** ((1 + th) / 2)))
        terms = {"beta^2 d^3": n ** -th * beta ** 2 * d ** 3, "9/4 n^(th/2)": n ** -th * (H + 1) * 9 / 4 * n ** (th / 2),
                 "((d+1)^2 n)^(1/H)": n ** -th * (H + 1) * ((d + 1) ** 2 * n) ** (1 / H), "const": n ** -th * (H + 1) * 2 + 10 * n ** -th}
        big = max(terms, key=terms.get)
        print(f"    H={H} theta={th} d={d}: largest term: {big}  ({terms[big]:.3g})")
