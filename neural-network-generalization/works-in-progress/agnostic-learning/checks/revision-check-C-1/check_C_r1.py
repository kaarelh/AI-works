"""Independent checks of the passages of C-fixed-temperature-bayes.md changed in revision 1.
Run: python3 -I check_C_r1.py > check_C_r1.out
"""
import numpy as np
from math import log, sqrt, exp

# ---------------------------------------------------------------- A_L of (C.3.2), written from the note's text
def A_L(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    E = d * (d + 1) * B**2 + 2 * (L - 1) * m**2 * B**2
    c_nu = 3 / 8 * min(1.0, sqrt(m_nu))
    b0 = 2 * sqrt((2 / m_nu) * (2 * log(9) + log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = rho / (2 * P0)
    return 1 + M_nu / 2 * E + (d + 2 + (L - 2) * m) * log(1 / (c_nu * h)) + log(2)

print("1. A_L values quoted in C.8 item 6 / Thm C.5(d)")
print(f"   A_L(10,1,2,eps/8=0.0125; L=2) = {A_L(10,1,2,0.0125,2):.1f}   n >= {2*A_L(10,1,2,0.0125,2)*1/(0.125*0.1):.3e}")
print(f"   A_L(10,10,2,0.0125; L=3) = {A_L(10,10,2,0.0125,3):.1f}   n >= {2*A_L(10,10,2,0.0125,3)*10/(0.125*0.1):.3e}")
print(f"   A_L(100,10,2,0.0125; L=3) = {A_L(100,10,2,0.0125,3):.1f}   n >= {2*A_L(100,10,2,0.0125,3)*10/(0.125*0.1):.3e}")
print(f"   A_L(10,100,2,0.0125; L=3) = {A_L(10,100,2,0.0125,3):.1f}   n >= {2*A_L(10,100,2,0.0125,3)*100/(0.125*0.1):.3e}")
print(f"   A_L(10,1,2,1/16; L=2) = {A_L(10,1,2,1/16,2):.2f}, 64 A_L = {64*A_L(10,1,2,1/16,2):.1f}")

print("\n2. eps_n(d) of (C.4.2): 4/n + (2 n^a)^gamma A_L(d, n^a, n^a, 1/n)/(eta (n+1)), d=10, L=3, gamma=1, eta=1/8")
def eps_n(n, a, d=10, L=3, gamma=1.0, eta=0.125, m_nu=1.0, M_nu=1.0):
    return 4 / n + (2 * n**a) ** gamma * A_L(d, n**a, n**a, 1 / n, L, m_nu, M_nu) / (eta * (n + 1))
for a, n in [(0.1, 1e6), (0.1, 1e18), (0.19, 1e18)]:
    print(f"   alpha={a}, n={n:.0e}: eps_n = {eps_n(n, a):.3e}")

print("\n3. Thm C.5(d) ratio 16 A_L (4k+sqrt(2k))/(eta(n+1)); claim: < 16(4+sqrt2) A_L/m_nu < 87 A_L/m_nu when k>=1, -> 64 A_L/m_nu")
print(f"   16(4+sqrt 2) = {16*(4+sqrt(2)):.3f}")
worst = 0.0
rng = np.random.default_rng(0)
for _ in range(200000):
    m_nu = rng.uniform(0.05, 1.0); eta = 10 ** rng.uniform(-4, np.log10(0.125)); n = int(10 ** rng.uniform(0, 9)) + 1
    k = eta * n / m_nu
    if k < 1: continue
    r = 16 * (4 * k + sqrt(2 * k)) / (eta * (n + 1)) * m_nu        # ratio / (A_L/m_nu)
    worst = max(worst, r)
print(f"   max over random (m_nu, eta, n) with k_n>=1 of ratio/(A_L/m_nu) = {worst:.3f}  (< 87: {worst < 87})")
for d, n in [(10, 1e6), (10, 1e8)]:
    A = A_L(d, 1, 2, 1/16, 2); eta = 0.125; k = eta * n
    print(f"   d={d}, n={n:.0e}: ratio = {16*A*(4*k+sqrt(2*k))/(eta*(n+1)):.1f}  vs 64 A_L = {64*A:.1f}")

print("\n4. Explicit K of Cor C.2.2 (K1, K2, K), checked on a grid incl. non-Gaussian (m_nu, M_nu)")
def Ks(L, gamma, m_nu, M_nu):
    b0 = 2 * sqrt((2 / m_nu) * (2 * log(9) + log(4 * L)))
    K1 = 2 * L - 1 + (log(L + 2) + (L - 2) * log(5 + b0) + log(16 / sqrt(m_nu))) / log(2)
    K2 = (1 + log(2) + M_nu * L) / log(2) + (L + 1) * K1
    return K1, K2, 2 ** gamma * K2 + 1 / (2 * log(2))
viol = 0; tot = 0; maxratio = 0
for (m_nu, M_nu) in [(1.0, 1.0), (0.592, 1.184), (0.19, 1.142), (0.5, 3.0)]:
    for L in [2, 3, 4, 6]:
        for gamma in [1.0, 1.5, 2.0, 3.0]:
            K = Ks(L, gamma, m_nu, M_nu)[2]
            for d in [1, 2, 5, 10, 100, 1e4]:
                for alpha in [0.01, 0.05, 0.1, 0.19, 0.3, 0.6, 1.0]:
                    for n in [2, 3, 10, 1e3, 1e6, 1e12, 1e24]:
                        for eta in [0.125, 1e-3]:
                            lhs = eps_n(n, alpha, d, L, gamma, eta, m_nu, M_nu)
                            rhs = K * d**2 * n ** ((4 + gamma) * alpha) * log(d * n) / (eta * n)
                            tot += 1; maxratio = max(maxratio, lhs / rhs)
                            if lhs > rhs * (1 + 1e-12): viol += 1
print(f"   {tot} grid points, violations of eps_n <= K d^2 n^((4+g)a) log(dn)/(eta n): {viol}; max lhs/rhs = {maxratio:.3f}")
print(f"   Gaussian K at (L,gamma)=(2,1),(3,1),(5,1): {Ks(2,1,1,1)[2]:.1f}, {Ks(3,1,1,1)[2]:.1f}, {Ks(5,1,1,1)[2]:.1f} (referee: 65.4, 133.9, 341.7)")

print("\n5. Separate exponents: lower bound (2n^b)^g A_L(d,n^a,n^bb,1/n)/(eta(n+1)) >= 2^(g-1) M_nu (L-1)/eta when 2a+2bb+g*b >= 1")
viol = 0; tot = 0
for (m_nu, M_nu) in [(1.0, 1.0), (0.19, 1.142)]:
    for L in [2, 3, 5]:
        for g in [1.0, 2.0]:
            for a in [0.0, 0.1, 0.3]:
                for bb in [0.0, 0.1, 0.4]:
                    for beta in [a, a + 0.2, 1.0]:
                        if 2*a + 2*bb + g*beta < 1: continue
                        for n in [2, 10, 1e4, 1e9]:
                            for eta in [0.125, 0.01]:
                                term = (2 * n**beta) ** g * A_L(10, n**a, n**bb, 1/n, L, m_nu, M_nu) / (eta * (n + 1))
                                tot += 1
                                if term < 2 ** (g - 1) * M_nu * (L - 1) / eta: viol += 1
print(f"   {tot} cases with 2a+2b+g*beta>=1, violations: {viol}")

print("\n6. Prop C.3(c)")
c = (2 - sqrt(3)) / 16
print(f"   (2-sqrt3)/16 = {c:.6f}; ((sqrt6-sqrt2)/8)^2 = {((sqrt(6)-sqrt(2))/8)**2:.6f}; root of 4v^2+sqrt2 v-1/4: {(-sqrt(2)+sqrt(6))/8:.6f}")
# (i) sigma^2<=1: sigma^2(4k+sqrt(2k)) > 1/4  ==>  sigma^2 k > c
bad = 0
for _ in range(200000):
    s2 = rng.uniform(0, 1); k = 10 ** rng.uniform(-6, 3)
    if s2 * (4*k + sqrt(2*k)) > 0.25 and not s2 * k > c: bad += 1
print(f"   sigma^2<=1 case, random check of 'sigma^2(4k+sqrt2k)>1/4 => sigma^2 k > (2-sqrt3)/16': violations {bad}")
# (ii) the new sentence 'Without sigma^2<=1 this implication fails'. Likelihood-ratio bound: Lambda_n/Z_n in [e^{-4 eta n}, e^{4 eta n}],
# prior mean of clip z_w is 0 (symmetry), so sup|fhat_t| <= e^{4 eta t} - 1 for EVERY prior scale.
for m_nu in [1.0, 0.19]:
    etan_max = c * m_nu      # sigma^2 >= 1 and eta sigma^2 n <= c m_nu  ==>  eta n <= c m_nu
    F = exp(4 * etan_max) - 1
    print(f"   m_nu={m_nu}: sigma^2>=1 and eta sigma^2 n <= {c*m_nu:.4f}: sup|fhat_n|,|fbar_n| <= {F:.4f}, so L_D >= {(1-F)**2:.4f} > 1/2: {(1-F)**2 > 0.5}")
for sigma in [1.5, 3.0, 10.0]:
    etan = 1.0 / (16 * sigma**4)          # the note's 'counterexample': k_n = 1/(16 sigma^4), m_nu = 1
    F = exp(4 * etan) - 1
    print(f"   note's example sigma={sigma}: eta n = {etan:.2e}, sup|fhat| <= {F:.2e}, excess >= {(1-F)**2:.4f} (> 1/2)")

# exact 2-d quadrature, strong prior, N=1, L=2, d=1, one input x0 = (1,0)-augmented, y = 1, Gaussian nu:
# z = sigma * xi * tanh(sigma * a) (first-layer: sigma sqrt(N/d) a on the constant coordinate; readout sigma N^{-1/2} xi)
ga = np.linspace(-12, 12, 2401); wa = np.exp(-ga**2 / 2); wa = wa / wa.sum()
def toy(sigma, eta, n):
    A, Xi = np.meshgrid(ga, ga, indexing="ij"); W = np.outer(wa, wa)
    z = sigma * Xi * np.tanh(sigma * A); phi = np.clip(z, -1, 1)
    lam = np.exp(-eta * n * (phi - 1) ** 2); Z = (W * lam).sum()
    fhat = (W * lam * phi).sum() / Z
    gibbs = (W * lam * (phi - 1) ** 2).sum() / Z
    return fhat, (1 - fhat) ** 2, gibbs
for sigma, eta, n in [(1.5, 1/(16*1.5**4), 1), (3.0, 1/(16*81), 1), (2.0, 0.125, 1), (2.0, 0.0167/4, 1), (5.0, 0.125, 2)]:
    f, L_bma, g = toy(sigma, eta, n)
    print(f"   toy sigma={sigma}, eta={eta:.3e}, n={n}: eta sigma^2 n = {eta*sigma**2*n:.4f}, fhat_n = {f:.4f}, excess BMA = {L_bma:.4f}, Gibbs = {g:.4f}")

print("\n7. Two-point example of Remark 3 (Theta={w1,w2}, mu uniform, z_w1=M, z_w2=-1, y=-1, eta=1/8)")
eta = 1/8
for M, n in [(1e3, 1000), (1e6, 1000), (1e3, 100), (1e3, 10), (1e3, 0), (1e3, 50)]:
    t = np.arange(n + 1); a = np.exp(-4 * eta * t); p1 = a / (1 + a)
    zbar = p1 * M - (1 - p1)
    bound = log(2) / (eta * (n + 1))
    mix = zbar.mean()
    mix_of_clips = np.clip(zbar, -1, 1).mean()
    avg_risk_clips = ((np.clip(zbar, -1, 1) + 1) ** 2).mean()
    print(f"   M={M:.0e} n={n:4d}: bound={bound:.3e} | L(mix of zbar)={(mix+1)**2:.4g} | L(clip(mix))={(np.clip(mix,-1,1)+1)**2:.4g}"
          f" | L(mix of clip zbar_t)={(mix_of_clips+1)**2:.4g} | avg_t L(clip zbar_t)={avg_risk_clips:.4g}")
z0 = 0.5 * 10 - 0.5
print(f"   M=10, t=0: zbar_0={z0}, (zbar_0-y)^2={(z0+1)**2}, (clip zbar_0 - y)^2={(min(z0,1)+1)**2}, -(1/eta)log(Z1/Z0)={-log(0.5*exp(-4*eta)+0.5)/eta:.4f}")

print("\n8. Theorem C.5(e) on an exact 1-d model: fixed features |h|=1, z = s*xi, xi ~ N(0,1) (sigma_out^2 = s^2), clipped likelihood, y=1")
gx = np.linspace(-14, 14, 200001); wx = np.exp(-gx**2 / 2); wx = wx / wx.sum()
worst = [0, 0, 0]
for s in [1.0, 0.5, 0.2, 0.05, 0.01]:
    for etan in [0.01, 0.5, 2.5, 20, 200]:
        z = s * gx; phi = np.clip(z, -1, 1)
        ell = etan * (phi - 1) ** 2; lam = np.exp(-ell); Z = (wx * lam).sum(); p = wx * lam / Z
        KL = (p * (-ell)).sum() - log(Z)
        k = etan; KLb = etan * s**2 * (1 + 8*k + 2*sqrt(2*k))
        Sigma = 4 * s**2 * (KLb + 0.5 * log(2))       # Sigma_N with s^2 = N^{-gamma}, m_nu = 1
        Ez2 = (p * z**2).sum(); zbar = (p * z).sum()
        gibbs_unc = (p * (z - 1) ** 2).sum()
        worst[0] = max(worst[0], Ez2 / Sigma); worst[1] = max(worst[1], abs(zbar) / sqrt(Sigma))
        worst[2] = max(worst[2], abs(gibbs_unc - 1) / (Sigma + 2 * sqrt(Sigma)))
        assert KL <= KLb + 1e-12 and gibbs_unc >= (zbar - 1) ** 2 - 1e-12
print(f"   max ratios: int z^2 dPi / Sigma = {worst[0]:.3f}, |zbar|/Sigma^(1/2) = {worst[1]:.3f}, |Gibbs_unclipped - E y^2|/(Sigma+2Sigma^(1/2)) = {worst[2]:.3f} (all <= 1)")

print("\n9. Remark 3, unclipped likelihood + clipped-mean predictor: full chain (C.2.3) against Q = point masses")
viol1 = viol2 = 0; tot = 0
for rep in range(300):
    K = 60; M = 15; xs = np.linspace(-1, 1, M)
    H = rng.uniform(-4, 4, K)[:, None] * np.tanh(rng.uniform(-4, 4, K)[:, None] * xs[None, :] + rng.uniform(-2, 2, K)[:, None])
    mu = rng.dirichlet(np.ones(K) * 0.3); T = 40
    idx = rng.integers(0, M, T); y = rng.uniform(-1, 1, T); y[: T // 2] = np.sign(y[: T // 2])
    logw = np.log(mu).copy(); lhs = 0.0; logZ = 0.0
    for t in range(T):
        w = np.exp(logw - logw.max()); w /= w.sum()
        f = w @ np.clip(H[:, idx[t]], -1, 1)
        lhs += (f - y[t]) ** 2
        logZ += np.log(np.sum(w * np.exp(-eta * (H[:, idx[t]] - y[t]) ** 2)))
        logw -= eta * (H[:, idx[t]] - y[t]) ** 2
    cum = ((H[:, idx] - y[None, :]) ** 2).sum(1)          # sum_i (z_j(x_i)-y_i)^2 for each j
    rhs = (cum + np.log(1 / mu) / eta).min()
    tot += 1
    if lhs > -logZ / eta + 1e-9: viol1 += 1
    if -logZ / eta > rhs + 1e-9: viol2 += 1
print(f"   {tot} sequences: violations of first inequality {viol1}, of comparison with best point mass {viol2}")
