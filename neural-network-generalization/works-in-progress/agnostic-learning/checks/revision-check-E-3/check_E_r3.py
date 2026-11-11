"""Independent re-derivations for the third check of E-finite-prior-scale.md (changed passages)."""
import numpy as np, sympy as sp
from fractions import Fraction as Fr
from math import log, sqrt, exp

print("== 1. Degrees D_T, D_H and gamma_H ==")
for L in range(3, 9):
    H = L - 1
    DT = 4 * 3**(L - 1); DH = 4 + 16 * (L - 2) * 3**(L - 2)
    gH = Fr(DH - 1, DH - H); cross = 2 - Fr(2, H) + Fr(1, H * H)
    # grid check: theta_{L,gamma} < 1/D_H  iff gamma < gamma_H, for 1<gamma<2-1/H
    gs = np.linspace(1 + 1e-7, 2 - 1 / H - 1e-7, 200001)
    th = np.maximum((gs - 1) / (gs * H - 1), (gs - 1) / (H * (H - 1) * (2 - gs)))
    below = th < 1 / DH
    ok = np.all(below == (gs < float(gH)))
    print(f"L={L}: D_T={DT} D_H={DH} D_H-(D_T+1)={DH-DT-1} gamma_H={float(gH):.5f} "
          f"< crossover {float(cross):.4f}: {gH < cross}; grid iff-check: {ok}")

print("\n== 2. Xi bound in Proposition 4.4, Step 6 ==")
for H in [1, 2, 3, 10]:
    tot = Fr(1, 8) + Fr(1, 8) + Fr(1, 16) + Fr(1, 16) + Fr(1, 24 * H * H)
    print(f"H={H}: five terms sum to {tot} = {float(tot):.4f} a")
print("output error a/8+0.39a+a/8+a/8 =", 0.125 * 3 + 0.39)

print("\n== 3. General-c PAC-Bayes terms (Lemma 2.2) ==")
N, g, n, c, A, dl = sp.symbols('N gamma n c A delta_p', positive=True)
Lam = N**g * n / (2 * c)
extra = (N**g * A + sp.log(1 / dl)) / Lam + 2 * Lam / n
target = 2 * c * A / n + 2 * c * sp.log(1 / dl) / (N**g * n) + N**g / c
print("residual general c:", sp.simplify(extra - target))
th = sp.symbols('theta', positive=True)
disp = 2 * n**(-th) * (A + sp.log(1 / dl) / N**g) + N**g * n**(th - 1)
print("residual at c=n^(1-theta):", sp.simplify(sp.powsimp(sp.expand(target.subs(c, n**(1 - th)) - disp), force=True)))

print("\n== 4. (C1), (C2) slack and regime totals ==")
U, eps, de = 3.0, 0.1, 0.05
n1 = 512 * (U + 1)**4 * log(4 / de) / eps**2
hn = (U + 1)**2 * sqrt(log(4 / de) / (2 * n1))
print(f"(C1) at equality: h_n/eps = {hn/eps:.6f} (1/32 = {1/32:.6f}); 4sqrt(.)/eps = {4*sqrt(log(4/de)/(2*n1))/eps:.6f}")
E_T = Fr(1, 8) + (Fr(1, 4) + Fr(1, 256)) + Fr(1, 4) + Fr(1, 16) + Fr(1, 8)
S = Fr(1, 8) + Fr(1, 8) + Fr(1, 256) + Fr(1, 4) + Fr(1, 4)
MF = Fr(1, 8) + (Fr(1, 4) + Fr(1, 256)) + Fr(1, 8) + Fr(1, 8) + Fr(1, 8)
print(f"regime E/T {float(E_T):.4f}, S {float(S):.4f}, MF {float(MF):.4f}; pi^2/24 = {np.pi**2/24:.4f}")

print("\n== 5. A_L - E_*/2 versus (d+m)(1+ln(1/rho)+ln(dmB)) ==")
def AL_minus(d, m, B, rho, L):
    b0 = 2 * sqrt(2 * (2 * log(9) + log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0**(L - 2)
    eta = min(0.5, rho / (2 * P0))
    return 1 + (d + 2 + (L - 2) * m) * log(8 / (3 * eta)) + log(2)
for L in [2, 3, 4, 5]:
    worst = 0
    for d in [1, 2, 5, 20, 100, 1000]:
        for m in [1, 2, 5, 50, 500]:
            for B in [1, 2, 10, 1e3]:
                for rho in [1, 0.5, 1e-2, 1e-6, 1e-12]:
                    r = AL_minus(d, m, B, rho, L) / ((d + m) * (1 + log(1 / rho) + log(d * m * B)))
                    worst = max(worst, r)
    print(f"L={L}: max ratio over grid = {worst:.2f}")
print(f"at d=m=B=rho=1, L=3: A_L - E_*/2 = {AL_minus(1,1,1,1,3):.2f} while (d+m)(ln(1/rho)+ln(dmB)) = 0")

print("\n== 6. N_* = O_H(d^2 s/a^2 + d (ds)^{(H-1)/H}/a^2 + d a^{-(H+1)}) ==")
def Nstar(d, s, a, H):
    Sb = 3**((H - 1) / 2) + 0.25; Amax = 2 * sqrt(2 * d * s) * 3**((H - 1) / 2)
    R = max(Amax**(1 / H), sqrt(128 * H * H * Sb**3 / a), 2.0)
    u0 = min(a / (16 * R**(H - 1)), a / (32 * H * H * Sb)); ld = (d + 1) * log(2) + log(8 * H)
    mf = int(128 * log(2) * Amax**2 * (d + 1) / a**2) + 1
    return max(mf, 256 * Amax**2 * ld / a**2, 512 * H * H * Sb**2 * ld / a**2, 2 * ld / u0**2)
for H in [2, 3, 4]:
    worst = 0; best = 1e300
    for d in [1, 3, 10, 30, 100]:
        for s in [1e-3, 1, 10, 1e4, 1e9]:
            for a in [1, 0.3, 1e-2, 1e-5, 1e-9]:
                r = Nstar(d, s, a, H) / (d * d * s / a**2 + d * (d * s)**((H - 1) / H) / a**2 + d * a**(-(H + 1)))
                worst = max(worst, r); best = min(best, r)
    print(f"H={H}: ratio range over grid [{best:.3g}, {worst:.3g}]")

print("\n== 7. Corollary 5.3: eta_d -> 0, a_d <= 1 (c_d=1 and c=n^(1-theta), theta>1/H) ==")
def eta_d(d, c, H, lam=1.0):
    n = lam * 2.0**d; s0 = min(n, 2.0**d)
    a = (max(c, 1) / 2.0**d)**(1 / 3)
    Sb = 3**((H - 1) / 2) + 0.25; Amax = 2 * sqrt(2 * d * s0) * 3**((H - 1) / 2)
    alpha = 2 + max(0.5 * log(4 * sqrt(2 * d)), 0.5 * log(256 * H * Sb / a))
    R2 = max(Amax**(2 / H), 128 * H * H * Sb**3 / a, 4)
    K = d * (d + 1) * alpha**2 + (H + 1) * R2
    return a, a * a + c * (K + 2) / n
for H in [2, 3]:
    for theta in [None, 1 / H + 0.1, 1 / H + 0.02]:
        row = []
        for d in [40, 80, 160, 320, 640]:
            c = 1.0 if theta is None else (2.0**d)**(1 - theta)
            a, e = eta_d(d, c, H); row.append(f"d={d}: a={a:.1e} eta={e:.1e}")
        print(f"H={H} theta={'c=1' if theta is None else round(theta,3)}: " + "; ".join(row))

print("\n== 8. Remark 5.4a: (1-2x)(1+e) >= 1+e-4x for e in [0,1], x in [0,1/2] ==")
E_, X_ = np.meshgrid(np.linspace(0, 1, 1001), np.linspace(0, 0.5, 1001))
print("min of (1-2x)(1+e) - (1+e-4x):", float(((1 - 2 * X_) * (1 + E_) - (1 + E_ - 4 * X_)).min()))

print("\n== 9. Section 2.3 bullet: equivalence at gamma=1, non-necessity for gamma>1 ==")
d_, H_, Kp = 5, 3, 100.0
for gam in [1.0, 1.5]:
    eq = True; strict = 0
    for Nn in range(1, 200):
        cond21 = Nn**gam * Kp >= 3 * (Nn * (d_ + 2) + (H_ - 1) * Nn * Nn)
        suff = 3 * (H_ - 1) * Nn**(2 - gam) <= Kp - 3 * (d_ + 2)
        if suff and not cond21: eq = False
        if cond21 and not suff: strict += 1
    print(f"gamma={gam}: sufficient condition implies (2.1) for all N: {eq}; N where (2.1) holds but the condition fails: {strict}")

print("\n== 10. Section 7 item 4 quoted numbers ==")
Pi2, Pi3 = 0.6057055096021591, 0.4625
print("1-Pi*(H=2), 1-Pi*(H=3):", round(1 - Pi2, 3), round(1 - Pi3, 3))
print("Pi*x dropped: H=2 N=2000:", round(Pi2 * 0.132, 4), " H=3 N=3000:", round(Pi3 * 0.173, 4))
masses = [(0.132, 15.0), (0.023, 15.0), (0.023, 15.0), (0.015, 10.0), (0.028, 9.1), (0.173, 19.7), (0.030, 19.7)]
print("dropped fractions (%):", [round(100 * a / b, 2) for a, b in masses])
samp = [1.383, 1.157, 0.788, 0.727, 1.515, 1.031]; pis = [Pi2, Pi2, Pi2, 0.9847, Pi3, Pi3]
med = [0.838, 0.710, 0.451, 0.711, 0.691, 0.420]
print("Pi* x sampling err vs noisy median:", [(round(p * s, 3), m) for p, s, m in zip(pis, samp, med)])

print("\n== 11. B Lemma 4.2 degree and the cover threshold quoted in E Section 2.7 ==")
for L in [2, 3, 4]:
    deg = 2 if L == 2 else 4 * (L - 1)
    print(f"L={L}: cover entropy degree in K = {deg} -> theta < 1/{deg} = {1/deg:.4f}; E text says 1/(4(L-1)) = {1/(4*(L-1)):.4f}")

print("\n== 12. theta_{L,gamma} at gamma=1.5 and red-team exponent ==")
for H in [2, 3, 4]:
    gm = 1.5
    t = 1 / H if gm >= 2 - 1 / H else max((gm - 1) / (gm * H - 1), (gm - 1) / (H * (H - 1) * (2 - gm)))
    print(f"H={H}: theta={t:.4f}, red-team (gamma-1)/(2(L-2)) = {(gm-1)/(2*(H-1)):.4f}")
