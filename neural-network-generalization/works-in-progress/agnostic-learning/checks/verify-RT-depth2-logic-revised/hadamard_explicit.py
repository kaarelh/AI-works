"""Explicit check of Proposition 5.3's construction (Hadamard atoms, d = M), at widths N in {1, 2, 5}.

For each M in {16, 64, 256, 1024} and lambda in {1, 1.5}, and 5 random samples:
  * Sylvester-Hadamard rows xi_j in {-1,1}^M, xi_j . xi_l = M delta_jl;
  * u = M^{-1} sum_{j in T} ybar_j xi_j; check u . xi_l = ybar_l 1_T(l), ||u||^2 = Q/M;
  * width-N network: every first-layer row (0, tau u), every readout 1/(N tau), tau^2 = Q^{-1/2};
  * kappa_N = (d/N)||W1||_F^2 + N ||v||^2 computed from the explicit matrices; check = tau^2 Q + tau^{-2} = 2 sqrt Q;
  * outputs z(xi_l) computed by the generic forward pass; error vs tau^2/3 on T; exactly 0 off T;
  * residual R(z) <= n/(9Q); within/between identity sum_i (z(x_i)-y_i)^2 = R + W;
  * the budget c kappa_N(w_u) + R(z_{w_u}) <= c 2 sqrt(Q) + n/(9Q) for c in {0.1, 1, 10}.
Unit-ball variant (Remark 5.4): inputs xi/sqrt(d), rows (0, tau sqrt(d) u): kappa = tau^2 M Q + tau^{-2}.
"""
import numpy as np
from scipy.linalg import hadamard

rng = np.random.default_rng(20261111)


def forward(W1, v, X):
    Xb = np.hstack([np.ones((X.shape[0], 1)), X])
    return np.tanh(Xb @ W1.T) @ v


def energy(W1, v, d):
    N = W1.shape[0]
    return d / N * np.sum(W1 ** 2) + N * np.sum(v ** 2)


worst_ratio = 0.0
fails = 0
for M in (16, 64, 256, 1024):
    H = hadamard(M).astype(float)
    assert np.allclose(H @ H.T, M * np.eye(M))
    d = M
    for lam in (1.0, 1.5):
        n = int(np.ceil(lam * M))
        for rep in range(5):
            idx = rng.integers(0, M, size=n)
            y = rng.choice([-1.0, 1.0], size=n)
            k = np.bincount(idx, minlength=M).astype(float)
            S = np.bincount(idx, weights=y, minlength=M)
            T = k > 0
            ybar = np.zeros(M); ybar[T] = S[T] / k[T]
            Q = np.sum(ybar[T] ** 2); G = np.sum(k[T] * ybar[T] ** 2)
            W = np.sum((y - ybar[idx]) ** 2)
            if Q == 0:
                continue
            u = (ybar[T][:, None] * H[T]).sum(axis=0) / M
            ok_orth = np.allclose(H @ u, ybar * T, atol=1e-12) and np.isclose(u @ u, Q / M)
            tau = Q ** -0.25
            for N in (1, 2, 5):
                W1 = np.tile(np.concatenate([[0.0], tau * u]), (N, 1))
                v = np.full(N, 1.0 / (N * tau))
                kap = energy(W1, v, d)
                z = forward(W1, v, H)
                err = np.abs(z[T] - ybar[T])
                ratio = err.max() / (tau ** 2 / 3)
                worst_ratio = max(worst_ratio, ratio)
                R = np.sum(k[T] * (z[T] - ybar[T]) ** 2)
                ident = np.isclose(np.sum((z[idx] - y) ** 2), R + W)
                checks = [ok_orth, np.isclose(kap, 2 * np.sqrt(Q)), ratio <= 1 + 1e-12,
                          np.abs(z[~T]).max(initial=0) < 1e-12, R <= n / (9 * Q) + 1e-12, ident]
                for c in (0.1, 1.0, 10.0):
                    checks.append(c * kap + R <= c * 2 * np.sqrt(Q) + n / (9 * Q) + 1e-9)
                # unit-ball variant
                Xb = H / np.sqrt(d)
                tau_b = (M * Q) ** -0.25
                W1b = np.tile(np.concatenate([[0.0], tau_b * np.sqrt(d) * u]), (N, 1))
                vb = np.full(N, 1.0 / (N * tau_b))
                kb = energy(W1b, vb, d)
                zb = forward(W1b, vb, Xb)
                Rb = np.sum(k[T] * (zb[T] - ybar[T]) ** 2)
                checks += [np.isclose(kb, 2 * np.sqrt(M * Q)), Rb <= n / (9 * M * Q) + 1e-12,
                           np.isclose(zb, z * 0 + zb).all()]
                if not all(checks):
                    fails += 1
                    print("FAIL", M, lam, rep, N, checks)
print("Hadamard explicit checks: failures =", fails, "; largest error ratio |z-ybar|/(tau^2/3) = %.4f" % worst_ratio)
