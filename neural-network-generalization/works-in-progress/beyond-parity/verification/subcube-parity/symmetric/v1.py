"""Independent checks for the 'symmetric' claims (verifier)."""
import itertools, math
import numpy as np
from math import comb
import mpmath as mp

mp.mp.dps = 80

print("== S2: gamma_d = E[chi(Z) ReLU(sum Z)] vs 2^{1-d} C(d-2,d/2-1) ==")
for d in [2, 4, 6, 8, 10, 20, 50, 100, 101, 7]:
    g = mp.mpf(0)
    for k in range(d + 1):
        g += comb(d, k) * (-1) ** k * max(d - 2 * k, 0)
    g /= mp.mpf(2) ** d
    form = mp.mpf(2) ** (1 - d) * comb(d - 2, d // 2 - 1) if d % 2 == 0 else 0
    print(d, mp.nstr(g, 8), mp.nstr(form, 8), "1/sqrt(2 pi d)=", mp.nstr(1 / mp.sqrt(2 * mp.pi * d), 6))

print("\n== S3: arcsine L=2 top eigenvalue, exact ==")
def arcsine_levels(d, L=2):
    # K(x,1) as function of k = #(-1) in x: t = (1 + d - 2k)/(d+1)
    vals = []
    for k in range(d + 1):
        t = mp.mpf(1 + d - 2 * k) / (d + 1)
        for _ in range(L - 1):
            t = 2 * mp.asin(t) / mp.pi
        vals.append(t)
    lam = []
    for j in [0, 1, 2, 3, d - 1, d]:
        # lambda_U for |U|=j: 2^-d sum_x K(x,1) chi_U(x) = 2^-d sum_k Kraw_j(k) C(d,k)... careful
        # sum over x with k minus-ones of chi_U(x) = Krawtchouk K_j(k) * C(d,k)/C(d,j)?  use direct: E_x K(x,1) chi_U(x)
        s = mp.mpf(0)
        for k in range(d + 1):
            # number of x with k minus ones and chi_U(x)=... : sum_{i} C(j,i)C(d-j,k-i)(-1)^i
            c = sum((-1) ** i * comb(j, i) * comb(d - j, k - i) for i in range(0, min(j, k) + 1))
            s += c * vals[k]
        lam.append((j, s / mp.mpf(2) ** d))
    return lam
for d in [20, 60, 100]:
    lam = arcsine_levels(d)
    print(d, [(j, mp.nstr(v, 5)) for j, v in lam])

print("\n== S3: Rademacher sign kernel by brute force (d small), lambda_U = Ghat(U)^2 ==")
for d in [4, 6, 8]:
    X = np.array(list(itertools.product([-1, 1], repeat=d)))
    W = X.copy()
    S = np.sign(1 + W @ X.T)  # rows w, cols x ; d even so 1 + w.x odd, nonzero
    K = (S.T @ S) / len(W)
    # Walsh eigenvalues
    out = {}
    for j in range(d + 1):
        U = list(range(j))
        chi = np.prod(X[:, U], axis=1) if j > 0 else np.ones(len(X))
        lam = chi @ K @ chi / len(X) ** 2
        out[j] = lam
    G = np.sign(1 + X.sum(1))
    gh = {j: (np.prod(X[:, :j], axis=1) if j > 0 else np.ones(len(X))) @ G / len(X) for j in range(d + 1)}
    print(d, {j: round(out[j], 6) for j in out}, " Ghat^2:", {j: round(gh[j] ** 2, 6) for j in gh},
          " (C(d,d/2)/2^d)^2=", round((comb(d, d // 2) / 2 ** d) ** 2, 6))
    # translation invariance: K(x,y) depends only on x.y
    ip = X @ X.T
    ok = all(np.ptp(K[ip == v]) < 1e-12 for v in np.unique(ip))
    print("   depends only on x.y:", ok, " PSD dominance Psi(K) - (2/pi)K min eig:",
          np.linalg.eigvalsh(2 / np.pi * np.arcsin(np.clip(K, -1, 1)) - 2 / np.pi * K).min())

print("\n== S5: minimal M_q and eta bound ==")
def wvec(M, q):
    w = np.zeros(2 * q)
    for K in range(M + 1):
        w[K % (2 * q)] += comb(M, K) / 2 ** M
    return w
for q in [1, 2, 3, 4, 5, 6, 8]:
    found = None
    etas = []
    for M in range(1, 400):
        w = wvec(M, q)
        eta = 1 - sum(min(w[i], w[(i + q) % (2 * q)]) for i in range(2 * q))
        b1 = math.sqrt(sum(abs(math.cos(math.pi * l / (2 * q))) ** (2 * M) for l in range(1, 2 * q, 2)))
        b2 = math.sqrt(q) * math.cos(math.pi / (2 * q)) ** M
        assert eta <= b1 + 1e-12 and b1 <= b2 + 1e-12, (q, M, eta, b1, b2)
        if eta <= 0.25 and found is None:
            found = M
        etas.append(eta)
    # M where analytic bound sqrt(q) cos^M <= 1/4
    Man = next(M for M in range(1, 10 ** 6) if math.sqrt(q) * math.cos(math.pi / (2 * q)) ** M <= 0.25)
    # monotone after found?
    nonmono = [M for M in range(found, 400) if etas[M - 1] > 0.25]
    print(f"q={q}: minimal M with eta<=1/4: {found}; analytic-bound M: {Man}; "
          f"M>=found with eta>1/4: {nonmono[:5]}")

print("\n== S1': hinge matrix T = 2 L^2, sigma_min(T) >= 1/2 ==")
for d in [5, 20, 101]:
    g = np.arange(-d, d + 1, 2)
    T = np.maximum(0, g[:, None] - g[None, :] + 2).astype(float)
    Lm = np.tril(np.ones((d + 1, d + 1)))
    sv = np.linalg.svd(T, compute_uv=False)
    print(d, "T==2L^2:", np.allclose(T, 2 * Lm @ Lm), " smin=", sv.min(), " smax=", sv.max(), " 2(d+1)^2=", 2 * (d + 1) ** 2)
