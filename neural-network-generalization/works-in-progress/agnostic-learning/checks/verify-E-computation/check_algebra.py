"""Independent symbolic re-derivation of the algebra in E.md (computation referee).
Every line prints the residual of an identity (should be 0) or a boolean."""
import sympy as sp

N, g, d, n, th, c, A, U, rho, eps, H, K, a, b = sp.symbols('N gamma d n theta c A U rho epsilon H K a b', positive=True)

print("== (1.2) standardized norm ==")
tau = N**((1-g)/2)
print("first layer:", sp.simplify((sp.sqrt(d)/tau)**2 - N**g*(d/N)))
print("internal   :", sp.simplify((sp.sqrt(N)/tau)**2 - N**g))
print("readout    :", sp.simplify((N/tau)**2 - N**g*N))
print("variances  :", sp.simplify((tau/sp.sqrt(d))**2 - N**(1-g)/d), sp.simplify((tau/sp.sqrt(N))**2 - N**(-g)), sp.simplify((tau/N)**2 - N**(-g-1)))

print("== Lemma 1.1(b): Lambda with c=n^(1-theta) ==")
Lam = N**g*n/(2*c)
print(sp.simplify(Lam.subs(c, n**(1-th)) - N**g*n**th/2))

print("== Lemma 2.1(b): exponent ==")
eta = 2*rho*(U+1) + rho**2 + 2*n**(-th)*(A + sp.log(64/eps))
Lam2 = N**g*n**th/2
expo = -Lam2*eta + N**g*(A + n**th*(rho*(U+1) + rho**2/2))
print("exponent + N^g ln(64/eps) =", sp.simplify(expo + N**g*sp.log(64/eps)))

print("== Lemma 2.1(c): (U+1)^2 + 2rho(U+1) + rho^2 = (U+1+rho)^2 ==")
print(sp.expand((U+1)**2 + 2*rho*(U+1) + rho**2 - (U+1+rho)**2))

print("== Lemma 2.2: substitution of Lambda ==")
dl = sp.symbols('ln_dinv', positive=True)
expr = (N**g*A + dl)/Lam2 + 2*Lam2/n
target = 2*n**(-th)*(A + dl/N**g) + N**g*n**(th-1)
print(sp.simplify(expr - target))
print("Hoeffding lemma per term: ((4Lam/n)^2/8)*n = 2Lam^2/n :", sp.simplify(((4*Lam2/n)**2/8)*n - 2*Lam2**2/n))
print("general c (for the c=1 remark): (N^g A)/Lam + 2 Lam/n with Lam=N^g n/(2c):", sp.simplify((N**g*A)/Lam + 2*Lam/n))

print("== Lemma 2.5: 7/b with b = a/(2(H-1)K^((H-1)/2)), a = eps/64 ==")
bb = (eps/64)/(2*(H-1)*K**((H-1)/2))
print(sp.simplify(7/bb - 896*(H-1)*K**((H-1)/2)/eps))

print("== Lemma 2.6: dev_mf: Hoeffding range 4 => t = sqrt(8 log(M/delta)/n) = 4 sqrt(log/(2n)) ==")
Lg = sp.symbols('Lg', positive=True)
print(sp.simplify(sp.sqrt(8*Lg/n) - 4*sp.sqrt(Lg/(2*n))))

print("== Theorem 2.7 Case II route (i) exponent ==")
ei = (1-th)/g - th*(H-1)/(g-1)
print(sp.simplify(ei - (g-1-th*(g*H-1))/(g*(g-1))))
print("== crossover of routes ==")
sol = sp.solve(sp.Eq((g-1)/(g*H-1), (g-1)/(H*(H-1)*(2-g))), g)
print("solutions gamma (excluding 1):", [sp.simplify(s) for s in sol])
print("2-2/H+1/H^2 :", sp.simplify(2-2/H+1/H**2))
print("== route (ii) reaches 1/H iff gamma >= 2-1/H ==")
print(sp.simplify(sp.solve(sp.Eq((g-1)/(H*(H-1)*(2-g)), 1/H), g)[0]))
print("== Case I polynomial: exponents in (C3) ==")
e = (1-th*H)/2
print("n^{theta H/2} n^{e/2} / sqrt(n) = n^{-e/2}:", sp.simplify(th*H/2 + e/2 - sp.Rational(1,2) + e/2))
print("n^{theta H/2} / sqrt(n) = n^{-e}:", sp.simplify(th*H/2 - sp.Rational(1,2) + e))

print("== Remark 2.8 optimum: theta = (1-theta H)/2 ==")
print(sp.solve(sp.Eq(th, (1-th*H)/2), th))

print("== Prop 4.4 Xi: five terms ==")
Sb, R, u0, phi = sp.symbols('Sbar R u0 varphi', positive=True)
fbar = phi + H*(u0 + 4*Sb**2/R**2)
Xi = 2*R**(H-1)*u0 + 2*H*Sb*fbar + 16*Sb**3/(3*R**2)
five = 2*R**(H-1)*u0 + 2*H*Sb*phi + 2*H**2*Sb*u0 + 8*H**2*Sb**3/R**2 + 16*Sb**3/(3*R**2)
print("Xi - five-term sum:", sp.simplify(Xi - five))
sub = {phi: a/(16*H*Sb)}
t1 = 2*R**(H-1)*(a/(16*R**(H-1)))
t2 = (2*H*Sb*phi).subs(sub)
t3 = 2*H**2*Sb*(a/(32*H**2*Sb))
t4 = 8*H**2*Sb**3/(128*H**2*Sb**3/a)
t5 = 16*Sb**3/(3*(128*H**2*Sb**3/a))
print("terms at the extreme parameter values:", [sp.simplify(t) for t in (t1, t2, t3, t4, t5)])
print("fifth term at H=1 (the 'H^2>=1' justification):", sp.simplify(t5.subs(H, 1)), " at H=2:", sp.simplify(t5.subs(H, 2)))
tot = sp.Rational(1,8)+sp.Rational(1,8)+sp.Rational(1,16)+sp.Rational(1,16)+sp.Rational(1,96)
print("sum with a/96:", tot, float(tot), "; with a/24:", float(tot - sp.Rational(1,96) + sp.Rational(1,24)))
print("output error 1/8+Xi+1/8+1/8 with Xi=0.39a:", 3/8+0.39)

print("== Lemma 4.3 telescoping sums for R>=2 ==")
Rv = sp.symbols('Rv', positive=True)
print("sum_{j>=1} R^{-2j} = 1/(R^2-1) <= 4/(3R^2) <= 2/R^2 at R=2:", sp.Rational(1,3), sp.Rational(4,12), sp.Rational(2,4))

print("== Prop 4.4 Step 5: 2^{d+1} e^{-ell_d} ==")
dd = sp.symbols('dd', positive=True, integer=True)
ell = (dd+1)*sp.log(2) + sp.log(8*H)
print(sp.simplify(2**(dd+1)*sp.exp(-ell) - 1/(8*H)))
print("E_S: 2 t^2 / (8 A^2/N) with t=a/8 -> a^2 N/(256 A^2):", sp.simplify(2*(a/8)**2/(8*A**2/N) - a**2*N/(256*A**2)))
print("E_1: 2 N t^2, t=a/(32 H Sbar) -> N a^2/(512 H^2 Sbar^2):", sp.simplify(2*N*(a/(32*H*Sb))**2 - N*a**2/(512*H**2*Sb**2)))
print("E_m: 2 t^2/(N (2/N)^2) = N t^2/2:", sp.simplify(2*u0**2/(N*(2/N)**2) - N*u0**2/2))
print("E_out: (a/8)^2/(2/N) = N a^2/128:", sp.simplify((a/8)**2/(2/N) - N*a**2/128))
print("sampling: 2 t^2/(m (2A/m)^2), t=a/8 -> m a^2/(128 A^2):", sp.simplify(2*(a/8)**2/(N*(2*A/N)**2) - N*a**2/(128*A**2)))
print("alpha choice: 8 e^{4-2 alpha} <= a/(32 H Sbar) when alpha >= 2 + (1/2) ln(256 H Sbar/a):",
      sp.simplify(8*sp.exp(4-2*(2+sp.log(256*H*Sb/a)/2)) - a/(32*H*Sb)))

print("== Theorem 2.7 arithmetic (exact rationals) ==")
r = sp.Rational
ET = r(1,8) + (r(1,4)+r(1,256)) + r(1,4) + r(1,16) + r(1,8)
S_ = r(1,8) + r(1,8) + r(1,256) + r(1,4) + r(1,4)
MF = r(1,8) + (r(1,4)+r(1,256)) + r(1,8) + r(1,8) + r(1,8)
print("regime T:", ET, float(ET), "; regime E (no eps/16):", float(ET - r(1,16)), "; regime S:", float(S_), "; regime MF:", float(MF))
print("pi^2/24 =", float(sp.pi**2/24), "; total failure 1/4+1/4+pi^2/24 =", float(r(1,2)+sp.pi**2/24))
print("(C1) => h_n <= eps * ", sp.sqrt(r(1,2)/512), "=", float(sp.sqrt(r(1,2)/512)), "(E.md states eps/8)")
print("(C1) => 4 sqrt(ln(4/delta)/(2n)) <= eps/(8 (U+1)^2)")
print("(C2) => 2 n^-theta (A+ln4/delta+1) <= eps/8 (E.md states eps/4)")
print("Remark 2.9(b) good-parameter bounds: E", float(r(1,8)+r(1,4)+r(1,256)+r(1,4)), "T", float(r(1,8)+r(1,4)+r(1,256)+r(1,4)+r(1,16)),
      "MF", float(r(1,8)+r(1,4)+r(1,256)+r(1,8)+r(1,8)))

print("== Lemma 3.1 constant ==")
for HH in range(2, 12):
    assert 2*sp.sqrt(2) + 3*(HH-1) + 2 <= 3*HH + 2
print("2 sqrt2 + 3(H-1) + 2 <= 3H+2 for H=2..11: True;  slack = 2 - 2sqrt2 + 1 =", float(3 - 2*sp.sqrt(2)))
print("e_1 constant: 2 sqrt((d+1)/d) <= 2 sqrt 2 at d=1:", float(2*sp.sqrt(2)))

print("== Lemma 2.4 union-bound constant 2 + (H-1)/2 <= L = H+1 ==")
print(all(2 + (HH-1)/2 <= HH+1 for HH in range(1, 50)))
print("3.5 sqrt N >= 2 sqrt N + sqrt(2 ln 2) iff sqrt N >= sqrt(2 ln2)/1.5 =", float(sp.sqrt(2*sp.log(2))/1.5))
