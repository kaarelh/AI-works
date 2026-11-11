"""Independent recomputation of the explicit constants of A.r1.md (Lemmas 2.1-2.3, 4.3, Cor. 4.5,
Prop. 6.3, Lemma 6.4, Prop. 8.2, 8.3, Thm 7.2 radius).  Written from the formulas, not copied."""
from fractions import Fraction
from math import comb, log, sqrt, exp, tanh, pi, e, floor, log2, log10
import mpmath as mp

mp.mp.dps = 60
out = []
def P(*a):
    s = " ".join(str(x) for x in a)
    print(s); out.append(s)

# ---------- Lemma 2.2 ----------
def alpha(d): return 0.5*log(4*sqrt(2*d))
P("== Lemma 2.2 / slope ==")
P("2 e^{-2 alpha_d} * 2 sqrt(2d) (should be 1):", [round(2*exp(-2*alpha(d))*2*sqrt(2*d), 15) for d in (1, 7, 40)])
P("alpha_1 =", alpha(1), " 2 alpha_1^2 =", 2*alpha(1)**2, "(>1.4 needed)")
P("alpha_d = 0.8664 + log(d)/4 check:", 0.5*log(4)+0.25*log(2), )
worst = min(1.5*log(d+1)-alpha(d) for d in range(1, 10**6, 7))
P("min_d [1.5 log(d+1) - alpha_d] over d<=1e6 (should be >=0):", worst)
# closed form of c_{k,inf} in exact rationals
ok = True
for k in range(1, 61):
    b = 0 if k % 2 else 1
    s = Fraction(0)
    for j in range(k+1):  # j coordinates equal to -1
        t = k - 2*j - b
        s += (-1)**j * comb(k, j) * (1 if t > 0 else -1)
    c = s / 2**k
    m = k//2
    if k % 2: cf = Fraction((-1)**m * comb(2*m, m), 4**m)
    else:     cf = Fraction((-1)**(m-1) * comb(2*m, m), 4**m)
    ok &= (c == cf) and (c*c*2*k >= 1)
P("c_{k,inf} closed form and |c|>=(2k)^{-1/2}, k<=60:", ok)
# |c_{k,alpha_d}| >= 1/(2 sqrt(2k)) for k<=d<=60 (high precision)
mn = mp.mpf(10)
for d in range(1, 61):
    a = mp.mpf(0.5)*mp.log(4*mp.sqrt(2*d))
    for k in range(1, d+1):
        b = 0 if k % 2 else 1
        s = mp.mpf(0)
        for j in range(k+1):
            s += (-1)**j * comb(k, j) * mp.tanh(a*(k-2*j-b))
        c = abs(s/2**k)
        mn = min(mn, c*2*mp.sqrt(2*k))
P("min over 1<=k<=d<=60 of |c_{k,alpha_d}| * 2 sqrt(2k) (>=1 needed):", mp.nstr(mn, 6))
P("1/tanh(1) =", 1/tanh(1), " 2 sqrt 2 =", 2*sqrt(2))

# ---------- Lemma 2.3 chain at the worst case of Step 6 ----------
P("== Lemma 2.3 chain at R^2 = 9/(2a), |g| = 3/2 ==")
worst_ratio = 0
for H in range(2, 12):
    for a in (1.0, 0.5, 0.1, 1e-3, 1e-6):
        R = mp.sqrt(mp.mpf(9)/(2*a))
        for g in (mp.mpf(1.5), mp.mpf(1.0), mp.mpf(0.3)):
            y = mp.tanh(g/R**(H-1))
            for j in range(2, H):
                y = mp.tanh(R*y)
            err = abs(R*y - g)
            bound_sum = g**3/3*sum(R**(-2*i) for i in range(1, H))
            assert err <= bound_sum*(1+mp.mpf(10)**-40)
            worst_ratio = max(worst_ratio, float(err/(a/2)))
P("max chain error / (a/2) over H<=11, a in {1,..,1e-6}, |g|<=3/2:", worst_ratio, "(<=1 needed)")
P("2(3/2)^3/3 * 2a/9 / (a/2) =", 2*(1.5**3)/3*2/9/0.5)

# ---------- Hoeffding / N_0 constant ----------
P("== N_0 constant and Corollary 4.5 threshold ==")
P("64 log 2 =", 64*log(2))
okN = all(64*log(2)*d*(d+1)*2**(5*d/3)+1 <= 45*d*(d+1)*2**(5*d/3) for d in range(1, 200))
P("44.36 d(d+1)2^{5d/3}+1 <= 45 d(d+1) 2^{5d/3} for d<200:", okN)

# ---------- beta(lambda) ----------
P("== beta ==")
def beta(lam):
    lam = mp.mpf(lam)
    return mp.e**(-lam)*(mp.ei(lam) - mp.euler - mp.log(lam))
def beta_series(lam):
    lam = mp.mpf(lam)
    return mp.e**(-lam)*mp.nsum(lambda k: lam**k/(k*mp.factorial(k)), [1, mp.inf])
P("beta(1) closed / series:", mp.nstr(beta(1), 10), mp.nstr(beta_series(1), 10))
h = lambda l: (1-mp.e**(-l))/l
lstar = mp.findroot(lambda l: h(l) - beta(l), 1.5)
P("lambda* =", mp.nstr(lstar, 8), " beta(lambda*) =", mp.nstr(beta(lstar), 8), " h(lambda*) =", mp.nstr(h(lstar), 8))
P("beta(1.5) =", mp.nstr(beta(1.5), 8))
P("beta'(1e-3) = h-beta =", mp.nstr(h(mp.mpf('1e-3'))-beta(mp.mpf('1e-3')), 6))
# global min of beta' (most negative)
mins = min(float(h(l)-beta(l)) for l in [mp.mpf(x)/10 for x in range(1, 400)])
P("min of beta' on (0,40] (grid):", mins)

def beta_n_exact(n, M):
    p = mp.mpf(1)/M
    tot = mp.mpf(0)
    lp, lq = mp.log(p), mp.log(1-p)
    kmax = int(min(n, 60 + 20*n/M))
    for k in range(1, kmax+1):
        lpmf = mp.loggamma(n+1) - mp.loggamma(k+1) - mp.loggamma(n-k+1) + k*lp + (n-k)*lq
        tot += mp.e**lpmf / k
    return tot
for d in (10, 14, 18):
    M = 2**d
    bn = beta_n_exact(M, M)
    P(f"d={d}: beta_n (n=M) = {mp.nstr(bn, 7)}; |beta_n - beta(1)| = {mp.nstr(abs(bn-beta(1)), 3)} <= n/M^2 = {1/M:.3g};"
      f" McDiarmid dev sqrt(2 log 100 / M) = {sqrt(2*log(100)/M):.4f}")

# ---------- Proposition 6.3 width-one network ----------
P("== Prop 6.3 ==")
P("tanh(2 tanh 1) =", tanh(2*tanh(1)), " tanh 1 =", tanh(1), " tanh(2) =", tanh(2))
for H in range(1, 8):
    tau = tanh(1.0)
    for _ in range(H-1):
        tau = tanh(2*tau)
    assert tau >= tanh(1.0)
P("tau_H >= tanh 1 for H<=7: True")

# ---------- Lemma 6.4(b) constants ----------
P("== Lemma 6.4(b) ==")
P("(1-e^-1)/16 =", (1-exp(-1))/16, " (1-e^-1)^2/2 =", (1-exp(-1))**2/2)
okn = all((n//2)*(n-n//2) >= n*(n-1)/4 for n in range(2, 5000))
P("n1 n2 >= n(n-1)/4 for 2<=n<5000:", okn)

# ---------- Proposition 8.2 numbers ----------
P("== Prop 8.2 numbers (s=2^d, a=1/2) ==")
def D(d, H): return sqrt(2*log(2))*(d+1) + (H-1)/2
def Kmem(d, s, a, H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*s)**(1/H), 9/(2*a))
for H, d in ((2, 40), (3, 40)):
    s = 2.0**d
    lb = H*((0.5*sqrt(s))/D(d, H))**(2/H)
    P(f"(H,d)=({H},{d}): K_mem = {Kmem(d, s, 0.5, H):.5g}, lower bound = {lb:.5g}, D = {D(d,H):.5g}")
# ratio of construction to lower bound, s-term only
for H in (2, 3, 4):
    for d in (10, 40):
        a = 0.5
        ratio = (H+1)/H*(8*d*D(d, H)**2/(1-a)**2)**(1/H)
        P(f"  ratio (H+1)/H (8 d D^2/(1-a)^2)^(1/H) at H={H}, d={d}: {ratio:.4g}")

# ---------- Proposition 8.3 constant C_t ----------
P("== Prop 8.3 ==")
for t in (0.5, 1.0, 2.0):
    Ct = 2*(1+sqrt(t/2))**2/t
    # check: c >= Ct n => t/2 + (n/c)(1+sqrt(t/2))^2 <= t
    P(f"t={t}: C_t = {Ct:.4f}; t/2 + (1/C_t)(1+sqrt(t/2))^2 = {t/2 + (1+sqrt(t/2))**2/Ct:.6f} (<= t)")
P("constant-net energy check, d=5,H=3,N=7,eps0=0.1: ",
  5/7*7*0.1**2 + (3-1)*7*7*(0.1/7)**2 + 7*7*(0.1/7)**2, "vs (d+H) eps0^2 =", (5+3)*0.01)

# ---------- Theorem 7.2 radius ----------
P("== Theorem 7.2 radius at c=t=1, a=a_d ==")
for H, d in ((2, 20), (2, 30), (2, 40)):
    L = H+1; n = 2.0**d
    a_d = (1/2**d)**(1/3)
    K2 = max(n + 1, Kmem(d, n, a_d, H))
    r = (1/n)*(L/K2)**(L/2)
    P(f"(H,d)=({H},{d}): K_mem={Kmem(d, n, a_d, H):.4g}, K2={K2:.4g}, log10 r = {log10(r):.3f}, log2 r = {log2(r):.3f}, "
      f"5.2 n^-2.5 -> log2 {log2(3**1.5)-2.5*d:.3f}")

open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
