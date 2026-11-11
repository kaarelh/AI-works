"""(1) Lemma C.3.1 sanity check: Monte Carlo prior mass of the teacher tube vs the bound exp(-A_L N^gamma) and vs (C.3.1),
    tiny networks (d=1, L=2, m=1, B=1), Gaussian mu_{N,1}, N = 1, 2.
(2) Appendix C.B (fan-in prior) at larger width/depth than the authors' check: E_q|z-g|^2 <= A^fi t, KL formula (sympy).
(3) Small numeric facts: fixed point of tanh(2u); readout bound; tanh(7/8) > 1/2; tanh(2u) > 1/2 for u > 1/2;
    1 - tanh a <= 2 e^{-2a}; parity step error 2 d e^{-A} with A = log(2d/eps'); b0 values.
"""
import numpy as np, sympy as sp
from scipy.optimize import brentq
rng = np.random.default_rng(31)

def A_L(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    c = 3 / 8 * min(1, np.sqrt(m_nu)); b0 = 2 * np.sqrt(2 / m_nu * (2 * np.log(9) + np.log(4 * L)))
    A0 = 2 + 3 * m * B + b0; P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2); h = rho / (2 * P0)
    Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
    return 1 + M_nu / 2 * Es + (d + 2 + (L - 2) * m) * np.log(1 / (c * h)) + np.log(2)

print("(1) teacher-tube mass, d=1, L=2, m=1, B=1, gamma=1 (Gaussian); X = [-1,1] (grid of 201 points)")
xg = np.linspace(-1, 1, 201)
for (a, b, uu) in [(0.5, 1.0, 1.0), (-1.0, 0.3, -0.7)]:
    g = uu * np.tanh(a + b * xg)
    for N in [1, 2]:
        S = 2_000_000 if N == 1 else 4_000_000
        hits = 0
        for _ in range(S // 500_000):
            W = rng.standard_normal((500_000, N, 2)) * np.sqrt(N ** 0 / 1.0)   # first layer var N^{1-gamma}/d = 1
            v = rng.standard_normal((500_000, N)) * N ** (-1.0)               # readout var N^{-gamma-1} = N^-2
            Hh = np.tanh(W[:, :, :1] + W[:, :, 1:] * xg[None, None, :])        # (S, N, X)
            z = np.einsum('sn,snx->sx', v, Hh)
            for rho in [0.5, 0.3]:
                pass
            err = np.max(np.abs(z - g[None, :]), axis=1)
            hits += np.array([np.sum(err < 0.5), np.sum(err < 0.3)])
        for i, rho in enumerate([0.5, 0.3]):
            p = hits[i] / S
            bound = np.exp(-A_L(1, 1, 1, rho, 2) * N)
            print(f"   g=({a},{b},{uu}) N={N} rho={rho}: MC mass={p:.3e}  bound exp(-A_L N)={bound:.3e}  holds: {p >= bound}")

print("\n(2) fan-in reference law q_t (Appendix C.B), larger N and L")
def fanin_check(d, m, B, L, N, t, R=1500):
    D0 = d + 1
    T = [rng.uniform(-B, B, (m, D0))] + [rng.uniform(-B, B, (m, m)) for _ in range(L - 2)]; u = rng.uniform(-B, B, m)
    X = np.vstack([np.ones(40), rng.choice([-1, 1], (d, 40)) * rng.uniform(0.5, 1, (d, 40))])
    def fwd(Ws, v):
        h = np.tanh(Ws[0] @ X)
        for W in Ws[1:]: h = np.tanh(W @ h)
        return v @ h
    g = fwd(T, u)
    err = np.zeros(X.shape[1])
    for _ in range(R):
        W1 = rng.standard_normal((N, D0)) / np.sqrt(D0); W1[:m] = T[0] + rng.standard_normal((m, D0)) * np.sqrt(t / D0)
        Ws = [W1]
        for Tl in T[1:]:
            W = rng.standard_normal((N, N)) / np.sqrt(N); W[:m] = rng.standard_normal((m, N)) * np.sqrt(t / N); W[:m, :m] += Tl
            Ws.append(W)
        v = rng.standard_normal(N) * np.sqrt(t / N); v[:m] += u
        err += (fwd(Ws, v) - g) ** 2
    err /= R
    Afi = sum((m * m * B * B) ** j for j in range(L))
    return err.max(), Afi * t
for cfg in [(3, 2, 1.0, 4, 200, 0.01), (5, 3, 1.5, 3, 300, 0.002), (2, 1, 2.0, 5, 150, 0.02), (4, 2, 1.0, 2, 400, 0.05)]:
    e, b = fanin_check(*cfg)
    print(f"   (d,m,B,L,N,t)={cfg}: max_x E|z-g|^2 = {e:.3e} <= A^fi t = {b:.3e}: {e <= b}")
al, vs, tt = sp.symbols('alpha varsigma t', positive=True)
kl = sp.log(sp.sqrt(1 / tt)) + (tt * vs**2 + al**2) / (2 * vs**2) - sp.Rational(1, 2)   # KL(N(al, t vs^2) || N(0, vs^2))
print("   KL(N(alpha, t s^2)||N(0,s^2)) - [alpha^2/(2 s^2) + (t-1-log t)/2] =", sp.simplify(kl - (al**2 / (2 * vs**2) + (tt - 1 - sp.log(tt)) / 2)))
ts = np.linspace(1e-6, 1, 100001); print("   max over t in (0,1] of (t-1-log t) - log(1/t) =", float(np.max(ts - 1 - np.log(ts) - np.log(1 / ts))), "(<= 0)")

print("\n(3) small numeric facts")
us = brentq(lambda x: x - np.tanh(2 * x), 0.5, 1.0); print(f"   fixed point u* of tanh(2u) = {us:.6f} in (0.957,0.958): {0.957 < us < 0.958};  tanh 2 = {np.tanh(2):.6f};  1/u* = {1/us:.4f} <= 1.05")
print(f"   tanh(7/8) = {np.tanh(7/8):.4f} > 1/2;  tanh(2*0.5) = {np.tanh(1):.4f} > 1/2")
aa = np.linspace(0, 20, 200001); print(f"   max of (1 - tanh a) - 2 e^(-2a) on [0,20] = {np.max(1 - np.tanh(aa) - 2 * np.exp(-2 * aa)):.2e} (<= 0)")
for d, ep in [(3, 0.1), (10, 0.01), (100, 1e-3)]:
    A = np.log(2 * d / ep); print(f"   parity d={d} eps'={ep}: 2 d e^(-A) = {2*d*np.exp(-A):.4g} (= eps');  depth-2 max weight A d/2 = {A*d/2:.2f}")
for L in [2, 3, 4]:
    print(f"   b0(L={L}) Gaussian = {2*np.sqrt(2*(2*np.log(9)+np.log(4*L))):.4f}")
