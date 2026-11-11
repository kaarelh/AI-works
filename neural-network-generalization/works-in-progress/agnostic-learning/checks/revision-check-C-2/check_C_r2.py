"""Independent round-2 check of the changed passages of C-fixed-temperature-bayes.md.
All computations are my own; nothing is imported from the note's scripts."""
import numpy as np
from math import log, sqrt, exp
rng = np.random.default_rng(12345)

print("== 1. Remark 3, two-point example (Theta={w1,w2}, mu uniform, z1=M, z2=-1, y=-1, eta=1/8, Q=delta_w2)")
eta = 1 / 8
def post_w1(t):          # FIX_eta likelihood uses clipped outputs: loss of w1 is 4, of w2 is 0
    a = np.exp(-4 * eta * t)
    return a / (1 + a)
for n in [10, 100, 1000]:
    print(f"  bound log2/(eta(n+1)) at n={n}: {log(2)/(eta*(n+1)):.4g}")
for M, n in [(1e3, 1000), (1e6, 1000)]:
    t = np.arange(n + 1); p = post_w1(t); zbar = p * M - (1 - p)
    print(f"  M={M:.0e} n={n}: loss of progressive mixture of zbar_t = {(zbar.mean()+1)**2:.4g}")
ok_all = True; last = None
for n in range(0, 400):
    t = np.arange(n + 1); p = post_w1(t); zbar = p * 1e3 - (1 - p)
    L = (np.clip(zbar.mean(), -1, 1) + 1) ** 2
    if L == 4.0: last = n
    if n <= 100 and L != 4.0: ok_all = False
print(f"  M=1e3: clip of progressive mixture has loss 4 for every n<=100: {ok_all}; largest n with loss 4: {last}")
print(f"  lower bound ((M-1)/2-n)/(n+1)>=1 iff n<=(M-3)/4 = {(1e3-3)/4}")
viol = [n for n in range(0, 101) if 4.0 > log(2) / (eta * (n + 1))]
print(f"  loss 4 exceeds the bound exactly for n in [{min(viol)}, {max(viol)}] within 0..100")
M = 10; zb0 = (M - 1) / 2; rhs = -log((exp(-4 * eta) + 1) / 2) / eta
print(f"  M=10, T=1: zbar_0={zb0}, (zbar_0-y)^2={(zb0+1)**2}, (clip zbar_0-y)^2={(min(zb0,1)+1)**2}, -(1/eta)log(Z1/Z0)={rhs:.4f}")

print("\n== 2. Prop C.3(c): root of 4u+sqrt(2u)=1/4")
v = (sqrt(6) - sqrt(2)) / 8
print(f"  v=(sqrt6-sqrt2)/8={v:.6f}: 4v^2+sqrt2 v={4*v*v+sqrt(2)*v:.6f}; v^2={v*v:.6f}; (2-sqrt3)/16={(2-sqrt(3))/16:.6f}")
# brute force: over sigma^2<=1 and k, min of eta sigma^2 n / m_nu = sigma^2 k subject to sigma^2(4k+sqrt(2k))>1/4
s2 = np.linspace(1e-3, 1, 2000)[:, None]; k = np.logspace(-6, 6, 4000)[None, :]
feas = s2 * (4 * k + np.sqrt(2 * k)) > 0.25
print(f"  brute force min sigma^2 k over the feasible set (sigma^2<=1): {np.min(np.where(feas, s2*k, np.inf)):.6f}")
# the referee's example
for s in [2.0, 10.0]:
    kk = 1 / (16 * s**4)
    print(f"  sigma={s}: k=1/(16 sigma^4): sigma^2 sqrt(2k)={s*s*sqrt(2*kk):.4f}, eta sigma^2 n/m_nu={s*s*kk:.5f}")
# the record's alternative argument
c0 = (2 - sqrt(3)) / 16; b = exp(4 * c0) - 1
print(f"  record: eta n < {c0:.5f} => |fhat| <= e^(4 eta n)-1 = {b:.4f}, excess >= {(1-b)**2:.4f}")

print("\n== 3. Theorem C.5(d) constants")
print(f"  16(4+sqrt2) = {16*(4+sqrt(2)):.4f} (<87)")
def AL(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    E = d * (d + 1) * B**2 + 2 * (L - 1) * m**2 * B**2
    c = 3 / 8 * min(1.0, sqrt(m_nu)); b0 = 2 * sqrt(2 / m_nu * (2 * log(9) + log(4 * L)))
    A0 = 2 + 3 * m * B + b0; P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = min(0.5, rho / (2 * P0))
    return 1 + M_nu / 2 * E + (d + 2 + (L - 2) * m) * log(1 / (c * h)) + log(2)
A = AL(10, 1, 2, 1 / 16, 2)
for n in [1e6, 1e8, 1e12]:
    kn = eta * n
    r = 16 * A * (4 * kn + sqrt(2 * kn)) / (eta * (n + 1))
    print(f"  d=10 L=2 n={n:.0e}: A_L={A:.2f}, ratio={r:.1f}, 64A_L={64*A:.1f}")
worst = 0
for _ in range(200000):
    m_nu = rng.uniform(0.05, 1); et = rng.uniform(1e-3, 0.125); kn = 10 ** rng.uniform(0, 6); n = kn * m_nu / et
    worst = max(worst, 16 * (4 * kn + sqrt(2 * kn)) / (et * (n + 1)) * m_nu)
print(f"  max of ratio/(A_L/m_nu) over random (m_nu, eta, k_n>=1): {worst:.3f}")

print("\n== 4. Corollary C.2.2: explicit K_1, K_2, K and a grid check of eps_n(d) <= K d^2 n^((4+g)a) log(dn)/(eta n)")
def Ks(L, g, m_nu=1.0, M_nu=1.0):
    b0 = 2 * sqrt(2 / m_nu * (2 * log(9) + log(4 * L)))
    K1 = 2 * L - 1 + (log(L + 2) + (L - 2) * log(5 + b0) + log(16 / sqrt(m_nu))) / log(2)
    K2 = (1 + log(2) + M_nu * L) / log(2) + (L + 1) * K1
    return K1, K2, 2 ** g * K2 + 1 / (2 * log(2))
for L in [2, 3, 5]:
    print(f"  L={L}: K(gamma=1)={Ks(L,1)[2]:.1f}, K(gamma=2)={Ks(L,2)[2]:.1f}")
worst = 0; cnt = 0; viol = 0
for (m_nu, M_nu) in [(1, 1), (0.592, 1.184), (0.19, 1.142), (0.5, 3.0)]:
    for L in [2, 3, 4, 6]:
        for g in [1, 1.5, 2, 3]:
            K = Ks(L, g, m_nu, M_nu)[2]
            for d in [1, 2, 5, 30, 1000]:
                for al in [0.01, 0.1, 0.2, 0.5, 1.0]:
                    for n in [2, 3, 10, 1e3, 1e8, 1e20]:
                        for et in [1/8, 1e-3]:
                            m = B = n ** al
                            eps = 4 / n + (2 * n ** al) ** g * AL(d, m, B, 1 / n, L, m_nu, M_nu) / (et * (n + 1))
                            rhs = K * d * d * n ** ((4 + g) * al) * log(d * n) / (et * n)
                            cnt += 1; worst = max(worst, eps / rhs); viol += eps > rhs
print(f"  {cnt} grid points, violations: {viol}, largest eps_n/majorant: {worst:.3f}")
# m_nu <= 1 is used: with log(16/min(1,sqrt m)) the formula needs min(1,sqrt(m_nu)) = sqrt(m_nu)

print("\n== 5. Separate exponents: lower bound 2^(g-1) M_nu (L-1)/eta when 2a+2b+g*beta >= 1")
viol = 0; cnt = 0
for L in [2, 3, 5]:
    for g in [1, 2]:
        for a in [0, 0.1, 0.3]:
            for bb in [0, 0.1, 0.3]:
                for be in [a, a + 0.2, 0.6]:
                    if 2 * a + 2 * bb + g * be < 1: continue
                    for n in [2, 10, 1e4, 1e9]:
                        for et in [1/8, 0.01]:
                            bound = 4 / n + (2 * n ** be) ** g * AL(3, n ** a, n ** bb, 1 / n, L) / (et * (n + 1))
                            cnt += 1; viol += bound < 2 ** (g - 1) * (L - 1) / et
print(f"  {cnt} cases, violations: {viol}")

print("\n== 6. Theorem C.5(e) in an exact 1-D model (fixed hidden features |h|=1, Gaussian readout, z = s_out*G)")
# posterior over G with clipped likelihood, constant target y = 1 (worst case for |fhat|), also random labels
G = np.linspace(-12, 12, 400001); dG = G[1] - G[0]; phi = np.exp(-G**2 / 2) / sqrt(2 * np.pi)
worst = [0, 0, 0, 0]
for s2 in [1e-4, 1e-3, 1e-2, 0.1, 0.5, 1.0]:
    so = sqrt(s2); z = so * G; c = np.clip(z, -1, 1)
    for et in [0.01, 0.125, 1, 10]:
        for n in [1, 5, 20, 100]:
            for lab in ["one", "rand"]:
                y = np.ones(n) if lab == "one" else rng.uniform(-1, 1, n)
                ell = et * ((c[:, None] - y[None, :]) ** 2).sum(1)
                lam = np.exp(-(ell - ell.min())); w = lam * phi; w /= w.sum()
                kn = et * n
                Sig = 4 * s2 * (kn * s2 * (1 + 8 * kn + 2 * sqrt(2 * kn)) + 0.5 * log(2))   # Sigma_N with sigma_out^2 = s2, m_nu = 1
                Ez2 = (w * z * z).sum(); zb = (w * z).sum()
                gibbs_unc = (w * (z - 1) ** 2).sum()   # unclipped Gibbs risk at y=1 (point mass x)
                worst[0] = max(worst[0], Ez2 / Sig); worst[1] = max(worst[1], abs(zb) / sqrt(Sig))
                if lab == "one":
                    worst[2] = max(worst[2], abs(gibbs_unc - 1) / (Sig + 2 * sqrt(Sig)))
                    lb = max(0, 1 - sqrt(Sig)) ** 2
                    if (1 - zb) ** 2 < lb - 1e-12 or gibbs_unc < (1 - zb) ** 2 - 1e-12: worst[3] += 1
print(f"  max ratios: int z^2 / Sigma = {worst[0]:.3f}, |zbar| / Sigma^(1/2) = {worst[1]:.3f}, |unclipped Gibbs - Ey^2| / (Sigma + 2 Sigma^(1/2)) = {worst[2]:.3f}; lower-bound violations: {worst[3]}")

print("\n== 7. Remark 3 (likelihood): unclipped likelihood, predictor = posterior mean of clipped outputs, eta = 1/8")
viol1 = viol2 = 0; tot = 0
for rep in range(400):
    K = rng.integers(2, 30); T = rng.integers(1, 60); scale = rng.choice([1.0, 3.0, 10.0])
    Z = rng.uniform(-scale, scale, (K, T)); mu = rng.dirichlet(np.ones(K)); y = rng.uniform(-1, 1, T)
    if rep % 2: y = np.sign(y)
    logw = np.log(mu); lhs = 0.0; logZ = 0.0
    for t in range(T):
        w = np.exp(logw - logw.max()); w /= w.sum()
        fhat = (w * np.clip(Z[:, t], -1, 1)).sum()
        lhs += (fhat - y[t]) ** 2
        step = np.log((w * np.exp(-eta * (Z[:, t] - y[t]) ** 2)).sum())
        logZ += step
        logw = logw - eta * (Z[:, t] - y[t]) ** 2
    mid = -logZ / eta
    # comparison: Q = point mass or random mixture
    Qs = [np.eye(K)[j] for j in range(K)] + [rng.dirichlet(np.ones(K)) for _ in range(5)]
    for Q in Qs:
        loss = ((Z - y[None, :]) ** 2).sum(1)
        kl = np.sum(np.where(Q > 0, Q * np.log(np.where(Q > 0, Q, 1) / mu), 0))
        tot += 1; viol2 += mid > (Q * loss).sum() + kl / eta + 1e-9
    viol1 += lhs > mid + 1e-9
print(f"  first inequality violations: {viol1}/400; second inequality violations: {viol2}/{tot}")
# literal reading 'Theorem C.1 holds verbatim with the unclipped likelihood' (clipped comparison term) is false:
M = 10.0; T = 50; logw = np.log(np.array([0.5, 0.5])); zz = np.array([M, -1.0]); lhs = 0
for t in range(T):
    w = np.exp(logw - logw.max()); w /= w.sum(); fhat = (w * np.clip(zz, -1, 1)).sum(); lhs += (fhat - 1) ** 2
    logw = logw - eta * (zz - 1) ** 2
print(f"  y=1, z_w1=10, z_w2=-1, unclipped likelihood: sum_t (fhat_t - y)^2 over T=50 = {lhs:.2f}; "
      f"clipped comparison with Q=delta_w1 gives {0 + log(2)/eta:.3f}; unclipped comparison gives {T*(M-1)**2 + log(2)/eta:.1f}")

print("\n== 8. Remark C.4.1 (L=3): 2 exp(-7A'/4) <= eps' iff eps' <= 2, with A' = log(2/eps')")
for e in [0.001, 0.1, 1.0, 1.99, 2.0, 2.5]:
    Ap = log(2 / e); print(f"  eps'={e}: 2e^(-7A'/4) = {2*exp(-7*Ap/4):.4g}  <= eps': {2*exp(-7*Ap/4) <= e + 1e-15}")
a = np.linspace(0, 20, 200001)
print(f"  max of (1-tanh a) - 2e^(-2a) on [0,20]: {np.max(1 - np.tanh(a) - 2 * np.exp(-2 * a)):.3e}")

print("\n== 9. C.9 rates: KL bound / (eta n + (eta n)^2/m_nu) and TV bound / (sqrt(eta n) + eta n/sqrt(m_nu)) stay bounded")
r1 = r2 = 0
for m_nu in [0.05, 0.3, 1.0]:
    for en in np.logspace(-6, 8, 400):
        k = en / m_nu; kl = en * (1 + 8 * k + 2 * sqrt(2 * k))
        r1 = max(r1, kl / (en + en * en / m_nu)); r2 = max(r2, sqrt(kl / 2) / (sqrt(en) + en / sqrt(m_nu)))
print(f"  sup ratios: KL {r1:.3f}, TV {r2:.3f} (finite constants, so the O-forms hold with absolute constants)")
