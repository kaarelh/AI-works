"""check-E-r2: re-derivations of the passages of E-finite-prior-scale.md changed in revision.
Run: python3 check_E_r2.py > check_E_r2.out"""
import numpy as np, sympy as sp
from math import log, sqrt, exp, tanh

print("== 1. Prop 4.4 'Sizes': N_* = O_H(d^2 s/a^2 + d (ds)^{(H-1)/H}/a^2 + d a^{-(H+1)}) and R^{2H-2} form")
def consts(d, s, a, H):
    Sb = 3**((H-1)/2) + 0.25
    Amax = 2*sqrt(2*d*s)*3**((H-1)/2)
    ad = 0.5*log(4*sqrt(2*d))
    alpha = 2 + max(ad, 0.5*log(256*H*Sb/a))
    R = max(Amax**(1/H), sqrt(128*H**2*Sb**3/a), 2.0)
    K = d*(d+1)*alpha**2 + (H+1)*R**2
    u0 = min(a/(16*R**(H-1)), a/(32*H**2*Sb))
    ld = (d+1)*log(2) + log(8*H)
    mf = np.floor(128*log(2)*Amax**2*(d+1)/a**2) + 1
    Ns = max(mf, 256*Amax**2*ld/a**2, 512*H**2*Sb**2*ld/a**2, 2*ld/u0**2)
    return Ns, R, K, Sb, Amax
for H in [2, 3, 4, 5]:
    r1 = []; r2 = []
    for d in [1, 2, 5, 10, 30, 100, 1000]:
        for s in [1e-3, 1, 10, 1e3, 1e6, 1e12]:
            for a in [1, 0.3, 1e-2, 1e-4, 1e-8]:
                Ns, R, K, Sb, Amax = consts(d, s, a, H)
                form = d*d*s/a**2 + d*(d*s)**((H-1)/H)/a**2 + d*a**(-(H+1))
                r1.append(Ns/form)
                r2.append(R**(2*H-2)/((d*s)**((H-1)/H) + a**(-(H-1)) + 1))
    print(f"H={H}: max N_*/form = {max(r1):.3g}, min = {min(r1):.3g}; max R^(2H-2)/((ds)^((H-1)/H)+a^-(H-1)+1) = {max(r2):.3g}")

print("== 2. §3 first consequence: A_L - E_*/2 = O_L((d+m)(1+ln(1/rho)+ln(dmB))); the r1 corner case")
def AL(d, m, B, rho, L):
    Es = d*(d+1)*B**2 + 2*(L-1)*m**2*B**2
    b0 = 2*sqrt(2*(2*log(9) + log(4*L)))
    A0 = 2 + 3*m*B + b0
    P0 = 1 + 2*m*B*(d+L+1)*A0**(L-2)
    eta = min(0.5, rho/(2*P0))
    return 1 + 0.5*Es + (d+2+(L-2)*m)*log(8/(3*eta)) + log(2), Es
for L in [2, 3, 4, 5]:
    rat = []
    for d in [1, 3, 10, 100, 1000]:
        for m in [1, 3, 10, 100]:
            for B in [1, 2, 10, 1e3]:
                for rho in [1, 0.5, 1e-2, 1e-6]:
                    A, Es = AL(d, m, B, rho, L)
                    rat.append((A - Es/2)/((d+m)*(1 + log(1/rho) + log(d*m*B))))
    A1, Es1 = AL(1, 1, 1, 1.0, L)
    print(f"L={L}: max ratio = {max(rat):.3f}, min ratio = {min(rat):.3f}; at d=m=B=rho=1: A_L - E_*/2 = {A1-Es1/2:.2f}")

print("== 3. gamma_H = (D_H-1)/(D_H-H): theta_{L,gamma} < 1/D_H iff 1 < gamma < gamma_H (grid)")
def th(H, g):
    return max((g-1)/(g*H-1), (g-1)/(H*(H-1)*(2-g)))
for H in [2, 3, 4, 5]:
    L = H+1; DH = 4 + 16*(L-2)*3**(L-2); gH = (DH-1)/(DH-H); cross = 2 - 2/H + 1/H**2
    gs = np.linspace(1+1e-9, 2-1/H-1e-9, 200001)
    below = np.array([th(H, g) < 1/DH for g in gs])
    ok = np.all(below == (gs < gH))
    print(f"H={H}: D_H={DH}, gamma_H={gH:.5f} (< crossover {cross:.4f}: {gH < cross}); equivalence on grid: {ok}")

print("== 4. Remark 5.4a: (1-2x)(1+e) >= 1+e-4x for e in [0,1], x in [0,1/2]; e_d <= beta_n <= 1")
x, e = sp.symbols('x e', nonnegative=True)
print("  (1-2x)(1+e) - (1+e-4x) =", sp.factor(sp.expand((1-2*x)*(1+e) - (1+e-4*x))), "  (= 2x(1-e) >= 0 for e <= 1)")

print("== 5. paragraph after Cor 5.4: general-c PAC-Bayes extra terms; Lambda_N/n")
N, g, n, c, A_, dl = sp.symbols('N gamma n c A delta_p', positive=True)
Lam = N**g*n/(2*c)
expr = (N**g*A_ + sp.log(1/dl))/Lam + 2*Lam/n
target = 2*c*A_/n + 2*c*sp.log(1/dl)/(N**g*n) + N**g/c
print("  residual:", sp.simplify(expr - target), "; Lambda_N/n =", sp.simplify(Lam/n))
th_ = sp.symbols('theta', positive=True)
print("  at c=n^(1-theta): N^g/c =", sp.simplify((N**g/c).subs(c, n**(1-th_))), "(c=1 <=> theta=1)")

print("== 6. E2 and I-1")
a, H = sp.symbols('a H', positive=True)
Sb = sp.symbols('Sbar', positive=True)
fifth = sp.Rational(16, 3)*Sb**3/(128*H**2*Sb**3/a)
print("  fifth term at R^2 = 128H^2Sbar^3/a:", sp.simplify(fifth), "; at H=2:", fifth.subs(H, 2))
print("  five-term sum at H=2: 1/8+1/8+1/16+1/16+1/96 =", sp.Rational(1, 8)*2 + sp.Rational(1, 16)*2 + sp.Rational(1, 96), "<", 0.39)
eps, U, dlt = sp.symbols('epsilon U delta', positive=True)
nC1 = 512*(U+1)**4*sp.log(4/dlt)/eps**2
print("  (C1): h_n at equality =", sp.simplify((U+1)**2*sp.sqrt(sp.log(4/dlt)/(2*nC1))), "; 4 sqrt(ln(4/d)/(2n)) =",
      sp.simplify(4*sp.sqrt(sp.log(4/dlt)/(2*nC1))))

print("== 7. §7 item 4 derived numbers")
Pi2, Pi3 = 0.6057055096021591, 0.46249
print(f"  1-Pi*: H=2 {1-Pi2:.4f}, H=3 {1-Pi3:.4f}; Pi*x dropped: {Pi2*0.132:.4f}, {Pi3*0.173:.4f}")
A_vals = [15.0, 15.0, 15.0, 10.0, 9.1, 19.7, 19.7]; dr = [0.132, 0.023, 0.023, 0.015, 0.028, 0.173, 0.030]
print("  dropped/A (%):", [round(100*x/y, 2) for x, y in zip(dr, A_vals)])
print("  R=5 -> R=10 error ratio 0.154/0.084 =", round(0.154/0.084, 3))

print("== 8. §2.3 third bullet: at gamma=1 the condition is also necessary")
for d_, H_, N_ in [(5, 2, 10), (5, 3, 100)]:
    Kp = 3*(d_+2) + 3*(H_-1)*N_      # boundary value of K'
    PN = N_*(d_+2) + (H_-1)*N_**2
    print(f"  gamma=1, d={d_}, H={H_}, N={N_}: N K' - 3P_N at K'=3(d+2)+3(H-1)N: {N_*Kp - 3*PN};"
          f" at K' just below: {N_*(Kp-1e-9) - 3*PN:.2e} (<0, so (2.1) fails)")

print("== 9. Cor 5.3 'range of d': c_d <= c_d (d n_d)^{1/H}; ln(1/a_d) <= (d/3) ln 2")
print("  (d n)^{1/H} >= 1 for d,n >= 1: trivially; a_d = (max{c,1}/2^d)^{1/3} >= 2^{-d/3}")

print("== 10. Remark 2.9(d): B' = max{B,1}/tanh 1 >= 1, constant unit tanh(1) is a fixed point of u -> tanh(u/tanh 1 * tanh 1)")
print(f"  1/tanh(1) = {1/tanh(1):.4f}; tanh((1/tanh 1)*tanh 1) = {tanh((1/tanh(1))*tanh(1)):.6f} = tanh 1 = {tanh(1):.6f}")
