"""Round-2 check of the revised Claim B note: independent re-derivation of changed numbers and constructions.
Run: python3 verify_r2.py > verify_r2.out"""
import math
import numpy as np
import mpmath as mp
import sympy as sp

mp.mp.dps = 50
rng = np.random.default_rng(20261111)

print("== A. Theorem 6.3 example: L=3, d=10, m=B=1, eps=0.1, delta=0.05, theta=1/4 ==")
def Dn(n, d, H):
    return mp.sqrt(2 * (d + 1) * mp.log(n + 1)) + mp.mpf(H - 1) / 2
def exc_disp(n, th, H, d, m, B, dl):
    Es = d * (d + 1) * B**2 + 2 * H * m**2 * B**2
    U = m * B
    return ((Es + 1) * n**(-th) + 8 * (mp.mpf(2) / H)**(mp.mpf(H) / 2) * Dn(n, d, H) * n**(-(1 - th * H) / 2)
            + (4 + (U + 1)**2) * mp.sqrt(mp.log(2 / dl) / (2 * n)))
def exc_K(n, th, H, d, m, B, dl):
    Es = d * (d + 1) * B**2 + 2 * H * m**2 * B**2
    U = m * B
    K = n**th + 1
    return ((Es + 1) * n**(-th) + 8 * (K / H)**(mp.mpf(H) / 2) * Dn(n, d, H) / mp.sqrt(n)
            + (4 + (U + 1)**2) * mp.sqrt(mp.log(2 / dl) / (2 * n)))
def first_below(f, eps):
    # dense scan in log10 n, then bisection; also count sign changes to confirm a single crossing
    xs = np.arange(0.0, 60.0, 0.01)
    vals = [f(mp.mpf(10)**mp.mpf(x)) - eps for x in xs]
    changes = sum(1 for a, b in zip(vals, vals[1:]) if (a > 0) != (b > 0))
    i = next(k for k, v in enumerate(vals) if v <= 0)
    lo, hi = mp.mpf(xs[i - 1]), mp.mpf(xs[i])
    for _ in range(60):
        mid = (lo + hi) / 2
        if f(mp.mpf(10)**mid) - eps <= 0: hi = mid
        else: lo = mid
    return float(hi), changes
th = mp.mpf(1) / 4
for name, f in [("displayed Exc_n", exc_disp), ("K = n^theta+1 version", exc_K)]:
    x, ch = first_below(lambda n: f(n, th, 2, 10, 1, 1, mp.mpf('0.05')), mp.mpf('0.1'))
    print(f"  {name}: first <= 0.1 at log10 n = {x:.3f}  (sign changes on grid 10^0..10^60: {ch})")
n = mp.mpf(10)**mp.mpf('13.4')
print(f"  at n = 10^13.4: displayed Exc_n = {float(exc_disp(n, th, 2, 10, 1, 1, mp.mpf('0.05'))):.4f}, "
      f"K-version = {float(exc_K(n, th, 2, 10, 1, 1, mp.mpf('0.05'))):.4f}")
def log10_n0(th, H, d, m, B, eps, dl):
    d, m, B, eps = mp.mpf(d), mp.mpf(m), mp.mpf(B), mp.mpf(eps)
    Es = d * (d + 1) * B**2 + 2 * H * m**2 * B**2; U = m * B; g = 1 - mp.mpf(th) * H; c2 = (mp.mpf(2) / H)**(mp.mpf(H) / 2)
    e = [(1 / mp.mpf(th)) * mp.log10(3 * (Es + 1) / eps),
         (4 / g) * mp.log10(48 * c2 / eps * mp.sqrt(4 * (d + 1) / g)),
         mp.log10(9 * (4 + (U + 1)**2)**2 * mp.log(2 / mp.mpf(dl)) / (2 * eps**2))]
    if H > 1: e.append((2 / g) * mp.log10(24 * c2 * (H - 1) / eps))
    return float(max(e))
print(f"  closed-form n0: log10 = {log10_n0(0.25, 2, 10, 1, 1, 0.1, 0.05):.3f}")

print("\n== B. Degrees of n0 per variable (numerical log-log slopes at large values) ==")
def n0_ln(th, H, d, m, B, eps, dl):
    return log10_n0(th, H, d, m, B, eps, dl) * math.log(10)
for (H, th) in [(1, 0.3), (1, 0.7), (2, 0.2), (2, 0.45), (3, 0.3)]:
    def slope(var):
        base = dict(d=10, m=2, B=2, eps=0.1)
        lo = dict(base); hi = dict(base)
        if var == 'eps':
            lo['eps'] = 1e-200; hi['eps'] = 1e-201
            num = n0_ln(th, H, hi['d'], hi['m'], hi['B'], hi['eps'], 0.05) - n0_ln(th, H, lo['d'], lo['m'], lo['B'], lo['eps'], 0.05)
            return num / math.log(10)
        lo[var] = 1e200; hi[var] = 1e201
        num = n0_ln(th, H, hi['d'], hi['m'], hi['B'], hi['eps'], 0.05) - n0_ln(th, H, lo['d'], lo['m'], lo['B'], lo['eps'], 0.05)
        return num / math.log(10)
    pred_d = max(2 / th, 2 / (1 - th * H)); pred_mB = max(2 / th, 4); pred_e = max(1 / th, 4 / (1 - th * H))
    print(f"  H={H} theta={th}: d {slope('d'):.3f} (pred {pred_d:.3f}); m {slope('m'):.3f}, B {slope('B'):.3f} "
          f"(pred {pred_mB:.3f}); 1/eps {slope('eps'):.3f} (pred {pred_e:.3f})")

print("\n== C. Section 1: fixed c on the noisy cube, t = n^{-1/4} ==")
def Kmem(d, H, t, s):
    A = (d + 1) * math.sqrt(s)
    beta = max(1.0, 0.5 * math.log(2 * A / t))
    R2 = max(2.0, 9 / (4 * t), A**(2 / H))
    return beta**2 * d**3 + (H + 1) * R2, A
for H in [2, 3]:
    for c in [1.0, 10.0]:
        row = []
        for d in [20, 50, 100, 200, 400]:
            n = 2.0**d; t = n**-0.25
            K, A = Kmem(d, H, t, n)
            eps = c / n * (K + 1) + 9 * t**2
            ratio = K / (math.sqrt(n) * math.log(n))
            row.append(f"d={d}: eps={eps:.3g}, Kmem/(sqrt(n) ln n)={ratio:.3g}")
        print(f"  H={H} c={c}: " + "; ".join(row))
# m_t formula: ceil(2(d+1) A^2 ln2 / t^2) + 1 with A^2 = (d+1)^2 n, t^2 = n^{-1/2}
for d in [8, 10, 12]:
    n = 2**d
    A2 = sp.Integer(d + 1)**2 * n
    mt = sp.ceiling(2 * (d + 1) * A2 * sp.log(2) / sp.Rational(1, 1) * sp.sqrt(n)) + 1
    claimed = sp.ceiling(2 * sp.Integer(d + 1)**3 * sp.Integer(n)**sp.Rational(3, 2) * sp.log(2)) + 1
    print(f"  d={d}: m_t = {mt}, claimed ceil(2(d+1)^3 n^(3/2) ln2)+1 = {claimed}, equal: {mt == claimed}")
print(f"  t = n^(-1/4) <= 1/4 iff n >= 256: n=255 -> {255**-0.25:.5f}, n=256 -> {256**-0.25:.5f}")

print("\n== D. Theorem 7.4(b): lower bound (sqrt(1/e - n^-1/3) - sqrt(eps_n))_+^2 at H=2 ==")
def eps_n(d, H, th):
    n = mp.mpf(2)**d
    beta = max(mp.mpf(1), mp.log(2 * (d + 1) * n**((1 + th) / 2)) / 2)
    R2 = max(mp.mpf(2), mp.mpf(9) / 4 * n**(th / 2), ((d + 1)**2 * n)**(mp.mpf(1) / H))
    return n**(-th) * (beta**2 * d**3 + (H + 1) * R2 + 1) + 9 * n**(-th)
for th in [mp.mpf('0.55'), mp.mpf('0.75')]:
    out = []
    for d in [50, 100, 200, 400]:
        n = mp.mpf(2)**d
        e = eps_n(d, 2, th)
        q = 1 / mp.e - n**(-mp.mpf(1) / 3)
        lb = max(mp.mpf(0), mp.sqrt(q) - mp.sqrt(e))**2
        out.append(f"d={d}: eps_n={float(e):.3g}, bound={float(lb):.3f}")
    print(f"  theta={float(th)}: " + "; ".join(out))
# N_0(n) vs m_t with t = n^{-theta/2}
d = 20; n = 2**d; th = 0.6
A2 = (d + 1)**2 * n; mt = math.ceil(2 * (d + 1) * A2 * math.log(2) / (n**(-th))) + 1
print(f"  N_0 check d=20, theta=0.6: m_t={mt}, ceil(2(d+1)^3 n^(1+theta) ln2)+1={math.ceil(2*(d+1)**3*n**(1+th)*math.log(2))+1}")

print("\n== E. Slowest term of eps_n for 1/H < theta <= 2/H (ratio of each term to the claimed slowest, large d) ==")
for H in [2, 3]:
    for th in [1 / H + 0.05, 1.5 / H, 2 / H]:
        res = []
        for d in [400, 2000, 10000]:
            n = mp.mpf(2)**d
            beta = max(mp.mpf(1), mp.log(2 * (d + 1) * n**((1 + th) / 2)) / 2)
            slow = (H + 1) * ((d + 1)**2 * n)**(mp.mpf(1) / H) * n**(-th)
            t1 = beta**2 * d**3 * n**(-th)
            t2 = (H + 1) * mp.mpf(9) / 4 * n**(th / 2) * n**(-th)
            res.append(f"d={d}: t1/slow={float(t1/slow):.2e}, (9/4)-term/slow={float(t2/slow):.2e}")
        print(f"  H={H} theta={th:.3f}: " + "; ".join(res))

print("\n== F. Lemma 4.2 inequalities (Steps 1 and 4) on a grid, L up to 2000 ==")
viol = 0; cnt = 0; termwise_first_fail = None
for L in list(range(2, 60)) + [100, 200, 500, 1000, 2000]:
    s1 = math.log(4 * L * (L - 1)) + L * math.log(2) <= 2 * L
    f = lambda x: x * (2 - math.log(2)) - 2 * math.log(x) - math.log(4)
    s1b = (L == 2) or (f(L) > 0)
    for d in [1, 2, 5, 10, 100, 10**4]:
        for K in [1, 1.5, 10, 1e3, 1e8]:
            for a in [1, 0.5, 1e-2, 1e-6]:
                cnt += 1
                ell = math.log(17 * d * K / a)
                lhs4a = math.log(d) + 2 * (L - 1) * math.log(K) + 4 * math.log(1 / a) + math.log(ell)
                ok4a = lhs4a <= (2 * L + 1) * ell
                lhs4b = math.log(2**(L + 5) * (d + L + 1) / a) if L < 900 else (L + 5) * math.log(2) + math.log((d + L + 1) / a)
                ok4b = lhs4b <= L + 5 + ell
                if not (s1 and s1b and ok4a and ok4b): viol += 1
                if termwise_first_fail is None and d == 1 and K == 1 and not (d + L + 1 <= 17 * d * K):
                    termwise_first_fail = L
print(f"  {cnt} grid points, violations: {viol}; termwise split first fails (d=K=1) at L = {termwise_first_fail}")
print(f"  f(3) = 3(2-ln2)-2ln3-ln4 = {3*(2-math.log(2))-2*math.log(3)-math.log(4):.4f}; f'(2) = {2-math.log(2)-1:.4f}; ln32 = {math.log(32):.4f}")

print("\n== G. Remark 8.2: biased tanh nets as bias-free nets of width m+1, weights <= max(B,1)/tanh1 ==")
def biased(x, Us, bs, u, b_out):
    h = x
    for U, b in zip(Us, bs): h = np.tanh(U @ h + b)
    return u @ h + b_out
def arch(x, Ws, v):
    h = np.concatenate([[1.0], x])
    for W in Ws: h = np.tanh(W @ h)
    return v @ h
maxerr = 0.0; ratio_max = 0.0
T1 = math.tanh(1.0)
for trial in range(300):
    H = rng.integers(1, 5); d = rng.integers(1, 6); m = rng.integers(1, 6); B = float(rng.choice([0.3, 1.0, 2.5]))
    Us = [rng.uniform(-B, B, (m, d))] + [rng.uniform(-B, B, (m, m)) for _ in range(H - 1)]
    bs = [rng.uniform(-B, B, m) for _ in range(H)]
    u = rng.uniform(-B, B, m); b_out = rng.uniform(-B, B)
    Ws = []
    W1 = np.zeros((m + 1, d + 1)); W1[:m, 0] = bs[0]; W1[:m, 1:] = Us[0]; W1[m, 0] = 1.0; Ws.append(W1)
    for l in range(1, H):
        W = np.zeros((m + 1, m + 1)); W[:m, :m] = Us[l]; W[:m, m] = bs[l] / T1; W[m, m] = 1.0 / T1; Ws.append(W)
    v = np.concatenate([u, [b_out / T1]])
    Bp = max(B, 1.0) / T1
    ratio_max = max(ratio_max, max(np.abs(W).max() for W in Ws + [v]) / Bp)
    for _ in range(20):
        x = rng.uniform(-1, 1, d)
        maxerr = max(maxerr, abs(biased(x, Us, bs, u, b_out) - arch(x, Ws, v)))
print(f"  300 random nets: max |difference| = {maxerr:.2e}; max weight / B' = {ratio_max:.4f} (<= 1)")

print("\n== H. Corollary 8.1 exponents (sympy) ==")
a, Hs = sp.symbols('alpha H', positive=True)
th = (1 + 8 * a) / (Hs + 2); beta = (1 - 4 * a * Hs) / (Hs + 2)
print("  4a - theta + beta =", sp.simplify(4 * a - th + beta), ";  (1-theta H)/2 - beta =", sp.simplify((1 - th * Hs) / 2 - beta))
print("  -beta - (4a - 1/2) =", sp.factor(sp.simplify(-beta - (4 * a - sp.Rational(1, 2)))))
th1 = (1 + 8 * a) / 3
print("  H=1: 4a - theta =", sp.simplify(4 * a - th1), "; (1-4a)/3 <= 1/2-4a iff a <=",
      sp.solve(sp.Eq((1 - 4 * a) / 3, sp.Rational(1, 2) - 4 * a), a))
print("  H=1: beta>0 iff alpha < 1/8; at alpha=3/16 beta =", min((1 - 4 * 3 / 16) / 3, 0.5 - 4 * 3 / 16))
print("  depth 3 (H=2), alpha=1/16: beta =", sp.Rational(1, 1) * (1 - 4 * sp.Rational(1, 16) * 2) / 4)
print("  L=3: L/(2H(2L-1)) =", sp.Rational(3, 2 * 2 * 5), " 1/(4H) =", sp.Rational(1, 8))
x = sp.symbols('x', positive=True)
print("  8x^4 - 4 - (x^2+1)^2 =", sp.factor(8 * x**4 - 4 - (x**2 + 1)**2))

print("\n== I. Proposition 9.1(c) arithmetic ==")
vals = [(L, (1 + 5 / (4 * L)) * 4**(1 / L), 2**(1 / L) / math.sqrt(L), 4**(1 / L) * (2 * L + 1) / L) for L in range(2, 40)]
print(f"  max (1+5/(4L))4^(1/L) = {max(v[1] for v in vals):.4f} at L={max(vals, key=lambda v: v[1])[0]}; "
      f"max 2^(1/L)/sqrt(L) = {max(v[2] for v in vals):.4f}; min omega^2 at n^theta=2L: {min(v[3] for v in vals):.4f} (>= 2)")
# matching sentence: last term O((kappa+1) n^{-1/2}) with kappa = o(n^theta), theta <= 1/2
for thv in [0.3, 0.5]:
    ns = [1e4, 1e8, 1e16]
    print(f"  theta={thv}: (sqrt(k)+1)^2 n^-1/2 with k = n^theta/log n:",
          ", ".join(f"{(math.sqrt(nn**thv/math.log(nn))+1)**2/math.sqrt(nn):.3g}" for nn in ns))

print("\n== J. Remark 9.4: chain bound |R^{H-1}-chain(f) - f| <= 2|f|^3/(3R^2) for R^2 >= 2, large |f| allowed ==")
worst = 0.0
for H in [2, 3, 4, 6]:
    for R2 in [2.0, 3.0, 10.0, 100.0, 1e4]:
        R = math.sqrt(R2)
        for fval in np.concatenate([np.linspace(-20, 20, 801), [1e-3, -1e-3]]):
            s = fval / R**(H - 1); u = math.tanh(s)
            for _ in range(3, H + 1): u = math.tanh(R * u)
            z = R * u
            bound = 2 * abs(fval)**3 / (3 * R2)
            if bound > 0: worst = max(worst, abs(z - fval) / bound)
print(f"  max |z-f| / (2|f|^3/(3R^2)) = {worst:.4f} (<= 1)")

print("\n== K. Section 9 counterexample g_R (d=1, x ~ U[-1,1], y fair sign) ==")
for H in [1, 2, 3]:
    L = H + 1
    for R in [10.0, 1e3]:
        xs = np.linspace(-1, 1, 200001)
        g = xs * R
        g = np.tanh(g)
        for _ in range(H - 1): g = np.tanh(g)
        g = g / 10
        deriv0 = (np.tanh(R * 1e-9) if H >= 1 else 0) / 1e-9 / 10
        LD = 1 + np.mean(g**2)
        clone_energy = R**2 + (H - 1) * 1.0 + 0.01
        lb = L * (R / 10)**(2 / L)
        print(f"  H={H} R={R:g}: g'(0)={deriv0:.4f} (R/10={R/10:g}); L_D(g_R)={LD:.4f} > 1; "
              f"energy lower bound L(R/10)^(2/L)={lb:.3f} <= width-1 energy {clone_energy:.3f}")

print("\n== L. Section 7.5 item 4: 2kappa < (1-kappa)/H nonempty iff kappa < 1/(2H+1) ==")
k, h = sp.symbols('kappa H', positive=True)
print("  boundary:", sp.solve(sp.Eq(2 * k, (1 - k) / h), k))
print("\n== M. Corollary 9.3 thresholds ==")
L_ = sp.symbols('L', positive=True)
H_ = L_ - 1
print("  (b) alpha*(2L-1) > L/(2H) boundary:", sp.simplify(L_ / (2 * H_ * (2 * L_ - 1))), " L=3:", (L_ / (2 * H_ * (2 * L_ - 1))).subs(L_, 3))
print("  (a) alpha*L > L/(2H) boundary: 1/(2H)")
print("  closing step: 1 - e^{-n^{1/3}/2} at n=1:", 1 - math.exp(-0.5), "> 1/4")
