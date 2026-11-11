"""Round-3 check of C-fixed-temperature-bayes.md: independent re-derivation of the numbers and
inequalities in the passages changed since the referee round.  Pure numpy/scipy; fixed seeds."""
import numpy as np, itertools, math
from math import log, sqrt, exp, tanh

rng = np.random.default_rng(20261111)
print("=" * 70)
print("1. Remark 3 after Thm C.1: two-point example (clipped likelihood of FIX_eta)")
eta = 1 / 8
def post_w1(t):  # weight of w1 (z=M, clip=1) when y=-1: clipped loss 4 for w1, 0 for w2
    return 1 / (1 + exp(4 * eta * t))
for n in [10, 100, 1000]:
    print(f"  bound log2/(eta(n+1)) at n={n}: {log(2)/(eta*(n+1)):.4g}")
M = 10
zb0 = (M + 1) * post_w1(0) - 1
Z1 = 0.5 * (exp(-eta * 4) + 1)
print(f"  M=10: zbar_0={zb0}, (zbar_0-y)^2={(zb0+1)**2}, (clip zbar_0 - y)^2={(min(1,zb0)+1)**2}, -(1/eta)log(Z1/Z0)={-log(Z1)/eta:.4f}")
def pm_loss(M, n, clip_after=False):
    zb = [(M + 1) * post_w1(t) - 1 for t in range(n + 1)]
    m = sum(zb) / (n + 1)
    if clip_after:
        m = max(-1, min(1, m))
    return (m + 1) ** 2
print(f"  unclipped PM loss: M=1e3,n=1000: {pm_loss(1e3,1000):.4f};  M=1e6,n=1000: {pm_loss(1e6,1000):.4e}")
ok = all(abs(pm_loss(1e3, n, True) - 4) < 1e-12 for n in range(0, 101))
print(f"  clip of PM has loss 4 at M=1e3 for every n<=100: {ok}")
viol = [n for n in range(0, 101) if pm_loss(1e3, n, True) > log(2) / (eta * (n + 1))]
print(f"  clip of PM violates (C.2.5) exactly for n in [{min(viol)},{max(viol)}] within 0..100 (n=0 excluded? {0 not in viol})")
lb_ok = [n for n in range(0, 400) if ((1e3 - 1) / 2 - n) / (n + 1) >= 1]
print(f"  lower bound ((M-1)/2-n)/(n+1) >= 1 at M=1e3 iff n <= {max(lb_ok)}")
# clip zbar_t used per step: (C.2.4) average risk vs bound at M=1e3
for n in [100, 1000]:
    avg = np.mean([(max(-1, min(1, (1e3 + 1) * post_w1(t) - 1)) + 1) ** 2 for t in range(n + 1)])
    print(f"  clip(zbar_t) per step, M=1e3, n={n}: average risk {avg:.4f} vs bound {log(2)/(eta*(n+1)):.4f}")

print("=" * 70)
print("2. Remark 3, unclipped likelihood with clipped-mean predictor: (C.2.3) both inequalities, random dictionaries")
worst1 = -np.inf; worst2 = -np.inf; cnt = 0
for trial in range(400):
    K = rng.integers(2, 8); T = rng.integers(1, 40)
    scale = rng.choice([1.0, 3.0, 10.0])
    X = 5
    Z = rng.uniform(-scale, scale, (K, X))             # unclipped outputs z_w(x), x in {0..X-1}
    mu = rng.dirichlet(np.ones(K))
    xs = rng.integers(0, X, T); ys = rng.uniform(-1, 1, T)
    if trial % 3 == 0:
        ys = np.sign(ys)
    logw = np.log(mu); online = 0.0
    for t in range(T):
        w = np.exp(logw - logw.max()); w /= w.sum()
        fh = w @ np.clip(Z[:, xs[t]], -1, 1)
        online += (fh - ys[t]) ** 2
        logw = logw - eta * (Z[:, xs[t]] - ys[t]) ** 2
    mm = logw.max(); logZ = np.log(np.sum(np.exp(logw - mm))) + mm
    mid = -logZ / eta
    worst1 = max(worst1, online - mid)
    # second inequality for random Q (Dirichlet) and point masses
    losses = ((Z[:, xs] - ys[None, :]) ** 2).sum(1)
    for q in list(np.eye(K)) + [rng.dirichlet(np.ones(K)) for _ in range(5)]:
        kl = np.sum(np.where(q > 0, q * np.log(np.where(q > 0, q, 1) / mu), 0))
        rhs = q @ losses + kl / eta
        worst2 = max(worst2, mid - rhs); cnt += 1
print(f"  max(online - (-(1/eta)log Z_T)) = {worst1:.3e} (must be <= 0);  max(mid - rhs) over {cnt} Q = {worst2:.3e} (must be <= 0)")

print("=" * 70)
print("3. Second check, row 2: counterexample to the literal reading of C.9's first bullet")
# mu uniform on {w1,w2}, z_w1 = 10, z_w2 = -1, y = 1, eta = 1/8, Q = delta_w1; UNCLIPPED likelihood
s = 0.0; logw = np.log([0.5, 0.5]); z = np.array([10.0, -1.0]); phi = np.clip(z, -1, 1)
for t in range(50):
    w = np.exp(logw - logw.max()); w /= w.sum()
    if t == 1:
        print(f"  posterior weight of w1 at t=1: {w[0]:.3e}  (claimed (1+e^9.625)^-1 = {1/(1+exp(9.625)):.3e})")
    s += (w @ phi - 1) ** 2
    logw = logw - eta * (z - 1) ** 2
mm = logw.max(); logZ = np.log(np.sum(np.exp(logw - mm))) + mm
print(f"  sum_(t<50) (fhat_t - y)^2 = {s:.4f}; clipped rhs 8 log 2 = {8*log(2):.4f}; -(1/eta) log Z_50 = {-logZ/eta:.4f};"
      f" unclipped rhs 50*81 + 8 log 2 = {50*81+8*log(2):.4f}")

print("=" * 70)
print("4. Prop C.3(c): constant and the referee's example; first-check likelihood-ratio argument")
v = (sqrt(6) - sqrt(2)) / 8
print(f"  root of 4v^2 + sqrt2 v = 1/4: v={v:.6f}, residual {4*v*v+sqrt(2)*v-0.25:.1e}; u=v^2={v*v:.6f}; (2-sqrt3)/16={(2-sqrt(3))/16:.6f}")
# brute force: min over sigma^2<=1 of eta sigma^2 n / m_nu subject to sigma^2(4k+sqrt(2k)) > 1/4
best = np.inf
for s2 in np.concatenate([np.logspace(-6, 0, 2000), [1.0]]):
    # smallest k with s2(4k+sqrt(2k)) > 1/4, then u = s2 k
    lo, hi = 0.0, 1e12
    for _ in range(200):
        mid = (lo + hi) / 2
        if s2 * (4 * mid + sqrt(2 * mid)) > 0.25: hi = mid
        else: lo = mid
    best = min(best, s2 * hi)
print(f"  brute-force inf over sigma^2<=1 of sigma^2 k_n with sigma^2(4k_n+sqrt(2k_n))>1/4: {best:.6f}")
print(f"  referee example: sigma^2 sqrt(2 k) with k=1/(16 sigma^4) = sqrt2/4 = {sqrt(2)/4:.4f} > 1/4")
etan = (2 - sqrt(3)) / 16
print(f"  first check: eta n < {etan:.5f}; e^(4 eta n)-1 = {exp(4*etan)-1:.4f}; excess >= {(1-(exp(4*etan)-1))**2:.4f}")

print("=" * 70)
print("5. Thm C.5(d): ratio of thresholds")
print(f"  16(4+sqrt2) = {16*(4+sqrt(2)):.3f} (< 87);  limit factor 16*4 = 64")
mx = 0
for _ in range(100000):
    mnu = rng.uniform(0.01, 1); et = rng.uniform(1e-4, 1/8); n = int(rng.integers(1, 10**7))
    k = et * n / mnu
    if k < 1: continue
    mx = max(mx, 16 * (4 * k + sqrt(2 * k)) / (et * (n + 1)) * mnu)
print(f"  max over random (m_nu, eta, n) with k_n>=1 of ratio/(A_L/m_nu) = {mx:.3f}")

print("=" * 70)
print("6. A_L and Corollary C.2.2 explicit constants; separate exponents")
def A_L(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    E = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    c = 3 / 8 * min(1.0, sqrt(m_nu))
    b0 = 2 * sqrt((2 / m_nu) * (2 * log(9) + log(4 * L)))
    A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = rho / (2 * P0)
    return 1 + M_nu / 2 * E + (d + 2 + (L - 2) * m) * log(1 / (c * h)) + log(2), E, b0
def Kconst(L, gam, m_nu, M_nu):
    b0 = 2 * sqrt((2 / m_nu) * (2 * log(9) + log(4 * L)))
    K1 = 2 * L - 1 + (log(L + 2) + (L - 2) * log(5 + b0) + log(16 / sqrt(m_nu))) / log(2)
    K2 = (1 + log(2) + M_nu * L) / log(2) + (L + 1) * K1
    return 2 ** gam * K2 + 1 / (2 * log(2))
print("  K (Gaussian): " + ", ".join(f"L={L},g={g}: {Kconst(L,g,1,1):.1f}" for g in [1, 2] for L in [2, 3, 5]))
worst = 0; npts = 0
for (m_nu, M_nu) in [(1, 1), (0.592, 1.184), (0.19, 1.142), (0.5, 3.0)]:
    for L in [2, 3, 4, 6]:
        for gam in [1, 1.5, 3]:
            for eta_ in [1/8, 1e-3]:
                for alpha in [0.01, 0.05, 0.1, 0.19, 0.3, 0.6, 1.0]:
                    for n in [2, 10, 1e3, 1e6, 1e12, 1e20]:
                        for d in [1, 2, 10, 1000]:
                            m = B = n ** alpha
                            A, _, _ = A_L(d, m, B, 1 / n, L, m_nu, M_nu)
                            eps = 4 / n + (2 * n ** alpha) ** gam * A / (eta_ * (n + 1))
                            rhs = Kconst(L, gam, m_nu, M_nu) * d ** 2 * n ** ((4 + gam) * alpha) * log(d * n) / (eta_ * n)
                            worst = max(worst, eps / rhs); npts += 1
print(f"  eps_n(d) / [K d^2 n^((4+g)a) log(dn)/(eta n)]: max {worst:.3f} over {npts} points (must be <= 1)")
mn = np.inf; cnt = 0
for L in [2, 3, 5]:
    for gam in [1, 2]:
        for (a, b, beta) in itertools.product([0.05, 0.1, 0.2, 0.3], [0.0, 0.1, 0.3], [0.1, 0.2, 0.5]):
            if beta < a or 2 * a + 2 * b + gam * beta < 1: continue
            for n in [2, 10, 1e4, 1e8]:
                for M_nu in [1.0, 2.0]:
                    A, _, _ = A_L(10, n ** a, n ** b, 1 / n, L, 1.0, M_nu)
                    bnd = 4 / n + (2 * n ** beta) ** gam * A / (eta * (n + 1))
                    mn = min(mn, bnd / (2 ** (gam - 1) * M_nu * (L - 1) / eta)); cnt += 1
print(f"  separate exponents, 2a+2b+g*beta>=1: min of bound / [2^(g-1) M_nu (L-1)/eta] = {mn:.3f} over {cnt} cases (must be >= 1)")
A10, _, _ = A_L(10, 1, 2, 1 / 16, 2)
print(f"  A_L(10,1,2,1/16) at L=2 = {A10:.2f}; 64 A_L = {64*A10:.1f}")

print("=" * 70)
print("7. Thm C.5(e) and Lemma C.6.1(iii) in an exact one-dimensional model")
# all hidden features equal to 1 (extremal), Gaussian readout: z_w(x) = sigma_out * G, G ~ N(0,1), at every x.
from scipy import integrate
worst_e = 0; worst_g = 0; viol = 0
for s2 in [1e-3, 1e-2, 0.1, 0.5]:
    so = sqrt(s2)
    for (et, n) in [(1/8, 5), (1/8, 50), (0.5, 20), (2.0, 10)]:
        k = et * n
        Sigma = 4 * s2 * (et * n * s2 * (1 + 8 * k + 2 * sqrt(2 * k)) + 0.5 * log(2))
        g = np.linspace(-12, 12, 200001); dens = np.exp(-g * g / 2) / sqrt(2 * math.pi)
        for t in [0, n // 2, n]:
            ys = np.ones(t)
            ell = et * ((np.clip(so * g, -1, 1)[:, None] - ys[None, :]) ** 2).sum(1) if t > 0 else np.zeros_like(g)
            wts = np.exp(-ell) * dens
            Zt = np.trapezoid(wts, g)
            m2 = np.trapezoid(wts * (so * g) ** 2, g) / Zt
            zbar = np.trapezoid(wts * so * g, g) / Zt
            if m2 > Sigma or abs(zbar) > sqrt(Sigma): viol += 1
            worst_e = max(worst_e, m2 / Sigma)
            if t == n:
                gibbs = np.trapezoid(wts * (so * g - 1) ** 2, g) / Zt   # unclipped Gibbs risk, target y = 1
                worst_g = max(worst_g, abs(gibbs - 1) / (Sigma + 2 * sqrt(Sigma)))
                if gibbs < (1 - zbar) ** 2 - 1e-12 or gibbs < max(0, 1 - sqrt(Sigma)) ** 2 - 1e-12: viol += 1
print(f"  max of int z^2 dPi_t / Sigma_N: {worst_e:.3f}; max |unclipped Gibbs - 1|/(Sigma+2 Sigma^1/2): {worst_g:.3f}; violations: {viol}")

print("=" * 70)
print("8. Remark C.4.1: parity networks at depths 2..6 (first stage A = log(16(d+1)) for L>=3)")
def first_stage(d, A):
    X = np.array(list(itertools.product([-1, 1], repeat=d))).T
    chi = np.prod(X, axis=0)
    yj = np.array([(-1) ** (d - j) for j in range(d + 1)])
    c = (yj[0] + yj[d]) / 2.0
    H = np.vstack([np.tanh(A / 2 * X.sum(0) + A * (d / 2 - j + 0.5)) for j in range(1, d + 1)] + [np.tanh(np.ones(X.shape[1]))])
    wout = np.concatenate([yj[1:], [c / np.tanh(1.0)]])
    return chi, wout, H
allok = True; rows = []
for d in [2, 3, 5, 8, 11]:
    for eps in [0.5, 0.1, 0.01, 1e-4]:
        Ap = log(2 / eps)
        chi, wout, H = first_stage(d, log(2 * d / eps)); s = wout @ H
        e2 = np.abs(s - chi).max(); allok &= e2 <= eps + 1e-12
        chi, wout, H = first_stage(d, log(16 * (d + 1))); s = wout @ H
        assert np.all(np.sign(s) == chi) and np.abs(s).min() > 7 / 8
        out3 = np.tanh(Ap * s); e3 = np.abs(out3 - chi).max()
        allok &= (e3 <= 2 * exp(-7 * Ap / 4) + 1e-15) and (2 * exp(-7 * Ap / 4) <= eps + 1e-15)
        allok &= Ap * np.abs(wout).max() <= Ap / tanh(1) + 1e-12
        for L in [4, 5, 6]:
            u = np.tanh(s)                                # summing neuron (layer 2)
            for _ in range(L - 4):
                u = np.tanh(2 * u)                        # margin-preserving layers, weight 2
            assert np.abs(u).min() > 0.5
            out = np.tanh(Ap * u)                         # last hidden neuron: weight 2 replaced by A'
            e = np.abs(out - chi).max(); allok &= e <= eps
        rows.append((d, eps, e2, e3))
print(f"  all depth-2/3/>=4 errors <= eps' and L=3 weights <= A'/tanh1: {allok}")
print(f"  2e^(-7A'/4) <= eps' iff eps' <= 2: at eps'=2: {2*exp(-7*log(1)/4)} ; at eps'=2.5 A'<0")

print("=" * 70)
print("9. C.9 rates: constants in the O-forms (AM-GM)")
mx_kl = 0; mx_tv = 0
for _ in range(200000):
    en = 10 ** rng.uniform(-4, 6); mnu = rng.uniform(0.01, 1)
    k = en / mnu
    kl = en * (1 + 8 * k + 2 * sqrt(2 * k))
    mx_kl = max(mx_kl, kl / (en + en ** 2 / mnu))
    mx_tv = max(mx_tv, sqrt(kl / 2) / (sqrt(en) + en / sqrt(mnu)))
print(f"  KL bound / (eta n + (eta n)^2/m_nu) <= {mx_kl:.3f};  TV bound / (sqrt(eta n) + eta n/sqrt(m_nu)) <= {mx_tv:.3f}")
mx1 = 0; mx2 = 0
for _ in range(200000):
    en = 10 ** rng.uniform(-6, 6); mnu = rng.uniform(0.01, 1); k = en / mnu
    b = 4 * k + sqrt(2 * k)
    if k >= 1: mx1 = max(mx1, b / (en / mnu))
    else: mx2 = max(mx2, b / sqrt(en / mnu))
print(f"  sup-bound/(eta n/m_nu) when k>=1: <= {mx1:.3f};  sup-bound/sqrt(eta n/m_nu) when k<=1: <= {mx2:.3f}")
