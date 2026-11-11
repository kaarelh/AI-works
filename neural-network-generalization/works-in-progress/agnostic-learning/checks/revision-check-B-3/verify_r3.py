"""Round-3 check of the revised B-tempered-likelihood.md: independent recomputation of the numbers,
exponents and inequalities in the passages changed by the revision. Written from the formulas in the
text, not from the authors' scripts (only the final comparison reads their .out files)."""
import math, random
import mpmath as mp
import numpy as np

mp.mp.dps = 60
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)

# ---------------------------------------------------------------- A. Theorem 6.3 example (route 2)
def exc_disp(n, th, H, d, Es, U, dl):
    n = mp.mpf(n)
    Dn = mp.sqrt(2*(d+1)*mp.log(n+1)) + mp.mpf(H-1)/2
    return (Es+1)*n**(-th) + 8*(mp.mpf(2)/H)**(mp.mpf(H)/2)*Dn*n**(-(1-th*H)/2) + (4+(U+1)**2)*mp.sqrt(mp.log(2/mp.mpf(dl))/(2*n))
def exc_K(n, th, H, d, Es, U, dl):
    n = mp.mpf(n); K = n**th + 1
    Dn = mp.sqrt(2*(d+1)*mp.log(n+1)) + mp.mpf(H-1)/2
    return (Es+1)*n**(-th) + 8*(K/H)**(mp.mpf(H)/2)*Dn/mp.sqrt(n) + (4+(U+1)**2)*mp.sqrt(mp.log(2/mp.mpf(dl))/(2*n))
def n0_closed_log10(th, H, d, Es, U, dl, eps):
    g = 1-th*H; c2 = (2/H)**(H/2)
    t = [(1/th)*math.log10(3*(Es+1)/eps), (4/g)*math.log10(48*c2*math.sqrt(4*(d+1)/g)/eps),
         math.log10(9*(4+(U+1)**2)**2*math.log(2/dl)/(2*eps**2))]
    if H > 1: t.append((2/g)*math.log10(24*c2*(H-1)/eps))
    return max(t)
def crossings(f, eps, lo, hi, steps):
    xs = [lo + (hi-lo)*i/steps for i in range(steps+1)]
    vals = [f(mp.mpf(10)**x) - eps for x in xs]
    cr = [(xs[i], xs[i+1]) for i in range(steps) if (vals[i] > 0) != (vals[i+1] > 0)]
    res = []
    for a, b in cr:
        for _ in range(80):
            m = (a+b)/2
            if (f(mp.mpf(10)**m) - eps > 0) == (f(mp.mpf(10)**a) - eps > 0): a = m
            else: b = m
        res.append(b)
    return res

L, d, m, B, eps, dl = 3, 10, 1, 1, 0.1, 0.05
H = L-1; th = 1/4
Es = d*(d+1)*B**2 + 2*(L-1)*m**2*B**2; U = m*B
P("A. Thm 6.3 example, L=3 d=10 m=B=1 eps=0.1 delta=0.05 theta=1/4")
cd = crossings(lambda n: exc_disp(n, th, H, d, Es, U, dl), eps, 0, 60, 600)
ck = crossings(lambda n: exc_K(n, th, H, d, Es, U, dl), eps, 0, 60, 600)
P("   displayed Exc_n crossings (log10 n):", [round(x, 3) for x in cd])
P("   K=n^theta+1 bound crossings (log10 n):", [round(x, 3) for x in ck])
P("   closed-form n0 (log10):", round(n0_closed_log10(th, H, d, Es, U, dl, eps), 3))
P("   Exc_n at 10^13.4:", mp.nstr(exc_disp(mp.mpf(10)**13.4, th, H, d, Es, U, dl), 5))

# ---------------------------------------------------------------- B. Theorem 6.2 (route 1), own cover count
def ln_cover(K, a, d, L):
    K = mp.mpf(K); a = mp.mpf(a)
    r = min(mp.mpf(1), a*mp.sqrt(d)/(8*K**(mp.mpf(L)/2)))
    log2s = d*mp.log(1 + 2*mp.sqrt(d)/r, 2)
    DT = max(1, int(mp.ceil(log2s)))
    lam = a*mp.mpf(2)**(-L)*K**(-(mp.mpf(L)-1)/2)/(4*(L-1))
    J = max(mp.ceil(4*K), mp.ceil(256*lam**(-4)*(DT + mp.log(L/lam))))
    Delta = a/(4*(d+L+1)*(2*J**2)**L)
    PJ = J*(d+1) + (L-2)*J**2 + J
    return PJ*mp.log(1 + 2*(J+1)/Delta)
def exc1(n, th, L, d, Es, U, dl, eps):
    n = mp.mpf(n); a = mp.mpf(eps)/32; K = n**th + 1
    lnH = ln_cover(K, a, d, L)
    parts = [(Es+1)*n**(-th), 8*a, 4*mp.sqrt((lnH + mp.log(2/mp.mpf(dl)))/(2*n)), (U+1)**2*mp.sqrt(mp.log(2/mp.mpf(dl))/(2*n))]
    return sum(parts), parts
P("B. Thm 6.2 (route 1), own implementation of the Prop 4.1 count, eps=0.1, delta=0.05, d=10, m=B=1")
for (Lr, thr, hi) in [(2, 1/4, 120), (3, 1/16, 200), (3, 1/32, 200), (3, 1/10, 400)]:
    Esr = d*(d+1) + 2*(Lr-1)
    f = lambda n: exc1(n, thr, Lr, d, Esr, 1, dl, eps)[0]
    cr = crossings(f, eps, 1, hi, 400)
    tot, parts = exc1(mp.mpf(10)**cr[0], thr, Lr, d, Esr, 1, dl, eps)
    P(f"   L={Lr} theta={thr:.4f}: crossings log10 n = {[round(x, 2) for x in cr]};  at the crossing: "
      f"(E*+1)n^-th={mp.nstr(parts[0],3)}, 8a={mp.nstr(parts[1],3)}, cover={mp.nstr(parts[2],3)}, Hoeffding={mp.nstr(parts[3],3)}")

# ---------------------------------------------------------------- C. Theorem 7.4(b) scale
def eps_n(d, H, th):
    n = mp.mpf(2)**d
    beta = max(1, mp.log(2*(d+1)*n**((1+th)/2))/2)
    R2 = max(2, mp.mpf(9)/4*n**(th/2), ((d+1)**2*n)**(mp.mpf(1)/H))
    terms = {'beta2d3': n**(-th)*beta**2*d**3, 'R2': n**(-th)*(H+1)*R2, 'one': n**(-th), 'nine': 9*n**(-th)}
    return sum(terms.values()), terms
P("C. Thm 7.4(b): (sqrt(1/e-n^-1/3)-sqrt(eps_n))_+^2")
for (H, th, ds) in [(2, 0.55, [50, 100, 200, 400]), (2, 0.75, [50, 100])]:
    row = []
    for dd in ds:
        e, terms = eps_n(dd, H, th)
        n = mp.mpf(2)**dd
        b = max(0, mp.sqrt(1/mp.e - n**(-mp.mpf(1)/3)) - mp.sqrt(e))**2
        mem = (H+1)*(dd+1)**(mp.mpf(2)/H)*n**(mp.mpf(1)/H-th)
        slow = max(terms, key=lambda k: terms[k])
        row.append(f"d={dd}: {mp.nstr(b,3)} (largest term {slow}; memorizer term {mp.nstr(mem,3)} of eps_n {mp.nstr(e,3)})")
    P(f"   H={H} theta={th}: " + "; ".join(row))

# ---------------------------------------------------------------- D. degrees of n0 (Theorem 6.3) per variable
def n0_log(th, H, d, m, B, eps, dl):
    Es = d*(d+1)*B**2 + 2*H*m**2*B**2; U = m*B
    return n0_closed_log10(th, H, d, Es, U, dl, eps)
P("D. degrees of closed-form n0 (numerical log-log slopes at large values)")
for (H, th) in [(1, 0.3), (1, 0.8), (2, 0.2), (2, 0.45), (3, 0.3)]:
    sd = (n0_log(th, H, 1e61, 1, 1, 0.1, 0.05) - n0_log(th, H, 1e60, 1, 1, 0.1, 0.05))
    sm = (n0_log(th, H, 1, 1e61, 1, 0.1, 0.05) - n0_log(th, H, 1, 1e60, 1, 0.1, 0.05))
    sB = (n0_log(th, H, 1, 1, 1e61, 0.1, 0.05) - n0_log(th, H, 1, 1, 1e60, 0.1, 0.05))
    se = (n0_log(th, H, 1, 1, 1, 1e-61, 0.05) - n0_log(th, H, 1, 1, 1, 1e-60, 0.05))
    P(f"   H={H} th={th}: d {sd:.3f} (claim {max(2/th, 2/(1-th*H)):.3f}); m {sm:.3f}, B {sB:.3f} (claim {max(2/th, 4):.3f}); "
      f"1/eps {se:.3f} (claim {max(1/th, 4/(1-th*H)):.3f})")

# ---------------------------------------------------------------- E. Section 1 (fixed c), Section 7.5 item 1 width
P("E. Section 1: fixed c, t = n^-1/4")
for H in [2, 3]:
    for c in [1, 10]:
        vals = []
        for dd in [20, 40, 80, 160]:
            n = mp.mpf(2)**dd; t = n**(-mp.mpf(1)/4); Amax = (dd+1)*mp.sqrt(n)
            beta = max(1, mp.log(2*Amax/t)/2); R2 = max(2, mp.mpf(9)/(4*t), Amax**(mp.mpf(2)/H))
            Kmem = beta**2*dd**3 + (H+1)*R2
            e = c/n*(Kmem+1) + 9*t**2
            vals.append(f"d={dd}: Kmem/(sqrt(n) log2 n)={mp.nstr(Kmem/(mp.sqrt(n)*dd),3)}, eps_ct={mp.nstr(e,3)}")
        P(f"   H={H} c={c}: " + "; ".join(vals))
ok = True
for dd in range(1, 60):
    n = mp.mpf(2)**dd; t = n**(-mp.mpf(1)/4); Amax = (dd+1)*mp.sqrt(n)
    mt = mp.ceil(2*(dd+1)*Amax**2*mp.log(2)/t**2) + 1
    ok &= (mt == mp.ceil(2*(dd+1)**3*n**1.5*mp.log(2)) + 1)
    c = mp.mpf(3)*n**0.4; t2 = mp.sqrt(c/n)
    mt2 = mp.ceil(2*(dd+1)*Amax**2*mp.log(2)/t2**2) + 1
    ok &= (mt2 == mp.ceil(2*(dd+1)**3*n**2*mp.log(2)/c) + 1)
P("   m_t = ceil(2(d+1)^3 n^{3/2} ln2)+1 (t=n^-1/4) and m_t = ceil(2(d+1)^3 n^2 ln2/c)+1 (t=(c/n)^1/2):", ok)
P("   n^-1/4 <= 1/4 iff n >= 256:", all(((n**-0.25) <= 0.25 + 1e-15) == (n >= 256) for n in range(1, 2000)))

# ---------------------------------------------------------------- F. Section 7.5 item 4; Corollary 8.1
import sympy as sp
kap, Hs, al, th_ = sp.symbols('kappa H alpha theta', positive=True)
P("F. 7.5(4): 2kappa < (1-kappa)/H  <=>  kappa < 1/(2H+1):",
  sp.simplify(sp.solve(sp.Eq(2*kap, (1-kap)/Hs), kap)[0] - 1/(2*Hs+1)) == 0)
beta1 = lambda a: min((1-4*a)/3, 0.5-4*a)
P("   Cor 8.1, H=1: beta>0 iff alpha<1/8:", all((beta1(a) > 0) == (a < 1/8) for a in np.linspace(1e-4, 0.2499, 5000)),
  "; beta = 1/2-4alpha for alpha>1/16:", all(abs(beta1(a) - (0.5-4*a)) < 1e-15 for a in np.linspace(1/16+1e-6, 0.2499, 1000)))
Hn = 2; a = sp.Rational(1, 16); th8 = (1+8*a)/(Hn+2)
P("   depth 3, alpha=1/16: beta =", (1-4*a*Hn)/(Hn+2), "theta =", th8, "< 1/H:", th8 < sp.Rational(1, Hn))
P("   L/(2H(2L-1)) at L=3:", sp.Rational(3, 2*2*5), "; 1/(4H):", sp.Rational(1, 8))

# ---------------------------------------------------------------- G. Remark 8.2 bias conversion
def std_net(x, Ws, bs, v, bo):
    h = x
    for W, b in zip(Ws, bs): h = np.tanh(W @ h + b)
    return v @ h + bo
def repo_net(x, Ws, v):
    h = np.concatenate([[1.0], x])
    for W in Ws: h = np.tanh(W @ h)
    return v @ h
rng = np.random.default_rng(3); maxerr = 0; maxw = 0; worst_ratio = 0
t1 = math.tanh(1)
for trial in range(300):
    dd = rng.integers(1, 5); Hh = rng.integers(1, 5); mm = rng.integers(1, 6); Bb = float(rng.choice([0.3, 1.0, 2.5]))
    Ws = [rng.uniform(-Bb, Bb, (mm, dd))] + [rng.uniform(-Bb, Bb, (mm, mm)) for _ in range(Hh-1)]
    bs = [rng.uniform(-Bb, Bb, mm) for _ in range(Hh)]; v = rng.uniform(-Bb, Bb, mm); bo = rng.uniform(-Bb, Bb)
    W1 = np.zeros((mm+1, dd+1)); W1[:mm, 0] = bs[0]; W1[:mm, 1:] = Ws[0]; W1[mm, 0] = 1.0
    RW = [W1]
    for l in range(1, Hh):
        W = np.zeros((mm+1, mm+1)); W[:mm, :mm] = Ws[l]; W[:mm, mm] = bs[l]/t1; W[mm, mm] = 1/t1; RW.append(W)
    vv = np.concatenate([v, [bo/t1]])
    Bp = max(Bb, 1)/t1
    maxw = max(maxw, max(np.abs(W).max() for W in RW + [vv]) / Bp)
    for _ in range(20):
        x = rng.uniform(-1, 1, dd)
        maxerr = max(maxerr, abs(std_net(x, Ws, bs, v, bo) - repo_net(x, RW, vv)))
P(f"G. Remark 8.2: max |standard - converted| = {maxerr:.2e}; max |weight|/B' = {maxw:.4f} (<= 1)")

# ---------------------------------------------------------------- H. Remark 9.4 chain bound
worst = 0
for Hh in range(2, 7):
    for R2 in [2, 3, 5, 10, 50, 1000]:
        R = math.sqrt(R2)
        for f in np.linspace(-6, 6, 2401):
            s = f/R**(Hh-1); u = math.tanh(s)
            for _ in range(Hh-2): u = math.tanh(R*u)
            z = R*u
            if f != 0: worst = max(worst, abs(z-f)/(2*abs(f)**3/(3*R2)))
P(f"H. Remark 9.4: max |chain - f| / (2|f|^3/(3R^2)) over H=2..6, R^2>=2, |f|<=6: {worst:.4f} (<= 1)")

# ---------------------------------------------------------------- I. Lemma 4.2 new proof lines
bad = 0; cnt = 0
for Lq in list(range(2, 60)) + [100, 1000, 10000]:
    bad += not (math.log(4*Lq*(Lq-1)) + Lq*math.log(2) <= 2*Lq); cnt += 1
    if Lq >= 3:
        bad += not (math.log(4*Lq*(Lq-1)) <= math.log(4) + 2*math.log(Lq))
    for dq in [1, 2, 10, 1000]:
        for Kq in [1, 1.5, 100, 1e8]:
            for aq in [1, 0.3, 1e-3, 1e-8]:
                ell = math.log(17*dq*Kq/aq)
                lhs = math.log(dq) + 2*(Lq-1)*math.log(Kq) + 4*math.log(1/aq) + math.log(ell)
                mid = math.log(17) + 2*math.log(dq) + (2*Lq-1)*math.log(Kq) + 5*math.log(1/aq)
                bad += not (lhs <= mid + 1e-12 <= (2*Lq+1)*ell + 1e-9)
                bad += not ((Lq+5)*math.log(2)+math.log(dq+Lq+1)+math.log(1/aq) <= Lq+5+ell + 1e-12)
                cnt += 2
g = lambda Lq: Lq*(2-math.log(2)) - 2*math.log(Lq) - math.log(4)
P("I. Lemma 4.2: violations", bad, "of", cnt, "; ln32<4:", math.log(32) < 4, "; g(3)=", round(g(3), 4),
  "; g increasing on [2,10^4]:", all(g(x+0.01) > g(x) for x in np.arange(2, 10000, 0.5)),
  "; first L with termwise split failing at d=K=1:", next(Lq for Lq in range(2, 100) if Lq+2 > 17))
P("   ln((L+2)/17) <= (1-ln2)(L+5) for L in [2, 10^6]:", all(math.log((Lq+2)/17) <= (1-math.log(2))*(Lq+5) for Lq in range(2, 10**6, 7)))

# ---------------------------------------------------------------- J. Proposition 9.1(c) arithmetic, g_R, Cor 9.3 closing
P("J. (1+5/(4L))4^(1/L) max over L>=2:", max((1+5/(4*Lq))*4**(1/Lq) for Lq in range(2, 1000)),
  "; max 2^(1/L)/sqrt(L):", max(2**(1/Lq)/math.sqrt(Lq) for Lq in range(2, 1000)),
  "; min omega^2 at n^theta = 2L:", min(4**(1/Lq)*(2*Lq+1)/Lq for Lq in range(2, 1000)))
P("   1-exp(-n^(1/3)/2) at n=1:", 1-math.exp(-0.5), "> 1/4")
Rg = 7.0
def gR(x, Hh=3):
    u = math.tanh(Rg*x)
    for _ in range(Hh-1): u = math.tanh(u)
    return u/10
P("   g_R'(0) numerically (R=7, H=3):", (gR(1e-7)-gR(-1e-7))/2e-7, "vs R/10 =", Rg/10)
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
