"""Proposition 5.3 (Hadamard atoms, d = M) and Remark 5.4 of depth-two.md.

(1) Explicit width-N networks: rows (0, tau u), readout 1/(N tau), tau^2 = Q^{-1/2}.
    Check u.xi_k = ybar_k 1_T(k), ||u||^2 = Q/M, kappa_N = 2 sqrt(Q), |z - ybar| <= tau^2/3 on T, z = 0 off T,
    R(z) <= n/(9Q), and the near-minimizer budget R(z_w) <= c(2 sqrt Q + 1) + n/(9Q).
    Unit-ball normalisation (inputs xi/sqrt d): the same construction costs tau^2 M Q + tau^{-2} >= 2 sqrt(M Q).
(2) Explicit lower bound on the event of Lemma 1.3:
    Psi_H = (sqrt(Q^-) - sqrt(c (2 sqrt(Q^+) + 1) + n/(9 Q^-)))_+^2 / M,
    for c = 1, c = nu sqrt(M), and its limit beta (1 - sqrt(2 nu / sqrt beta))_+^2.
    Printed with five decimals, so that the three-decimal values of the table in section 5 can be read off
    without double rounding (second-round computation referee: 0.01549 had been printed as 0.0155, then as 0.016).
(3) The same bound under unit-ball normalisation, for several c.
"""
import numpy as np
import mpmath as mp
import sys
sys.path.insert(0, '.')
from bounds_t51 import binom_stats, beta_lim

rng = np.random.default_rng(20261111)


def sylvester(M):
    H = np.array([[1.0]])
    while H.shape[0] < M:
        H = np.block([[H, H], [H, -H]])
    return H


def energy(W1, v, d):
    N = v.size
    return d / N * np.sum(W1 ** 2) + N * np.sum(v ** 2)


def net(W1, v, X):
    Xb = np.hstack([np.ones((X.shape[0], 1)), X])
    return np.tanh(Xb @ W1.T) @ v


print("(1) explicit networks")
worst_err_ratio = 0.0
for M in [16, 64, 256, 1024]:
    d = M
    Xi = sylvester(M)
    assert np.allclose(Xi @ Xi.T, M * np.eye(M))
    for lam in [1.0, 1.5]:
        n = int(np.ceil(lam * M))
        idx = rng.integers(0, M, size=n)
        y = rng.choice([-1.0, 1.0], size=n)
        k = np.bincount(idx, minlength=M).astype(float)
        S = np.bincount(idx, weights=y, minlength=M)
        T = k > 0
        ybar = np.zeros(M); ybar[T] = S[T] / k[T]
        Q = np.sum(ybar[T] ** 2); G = np.sum(k[T] * ybar[T] ** 2)
        if Q == 0:
            continue
        u = (Xi[T].T @ ybar[T]) / M
        assert np.allclose(Xi @ u, ybar * T)
        assert abs(u @ u - Q / M) < 1e-9 * max(1, Q / M)
        tau = Q ** (-0.25)
        for N in [1, 3]:
            W1 = np.tile(np.concatenate([[0.0], tau * u]), (N, 1))
            v = np.full(N, 1.0 / (N * tau))
            kap = energy(W1, v, d)
            z = net(W1, v, Xi)
            err = np.abs(z - ybar)
            assert abs(kap - 2 * np.sqrt(Q)) < 1e-8 * kap
            assert np.all(err[T] <= tau ** 2 / 3 + 1e-12)
            assert np.all(np.abs(z[~T]) < 1e-12)
            worst_err_ratio = max(worst_err_ratio, np.max(err[T]) / (tau ** 2 / 3))
            R = np.sum(k[T] * (z[T] - ybar[T]) ** 2)
            assert R <= n / (9 * Q) + 1e-12
            # unit-ball version: rows must be scaled by sqrt(d) to give the same function on xi/sqrt(d)
            W1b = W1.copy(); W1b[:, 1:] *= np.sqrt(d)
            zb = net(W1b, v, Xi / np.sqrt(d))
            assert np.allclose(zb, z)
            kapb = energy(W1b, v, d)
            assert abs(kapb - (tau ** 2 * M * Q + tau ** -2)) < 1e-8 * kapb
        print("  M=%5d lam=%.1f n=%5d Q=%8.2f G=%8.2f kappa=2sqrtQ=%7.3f  R=%.3e <= n/(9Q)=%.3e  unit-ball min cost 2sqrt(MQ)=%9.1f vs G=%8.1f" % (
            M, lam, n, Q, G, 2 * np.sqrt(Q), R, n / (9 * Q), 2 * np.sqrt(M * Q), G))
print("  all assertions passed; largest |z - ybar| / (tau^2/3) on T = %.4f" % worst_err_ratio)

print("\n(2) explicit lower bound on the event of Lemma 1.3, lambda = 1")
mp.mp.dps = 60
b1 = beta_lim(1)
print("   log2 M   c=1        c=0.1 sqrtM   c=0.3 sqrtM   c=0.35 sqrtM | limits: nu=0.1 -> %.4f, nu=0.3 -> %.4f, nu=0.35 -> %.4f, c=o(sqrtM) -> %.4f" % (
    float(b1 * max(1 - mp.sqrt(2 * 0.1 / mp.sqrt(b1)), 0) ** 2), float(b1 * max(1 - mp.sqrt(2 * 0.3 / mp.sqrt(b1)), 0) ** 2),
    float(b1 * max(1 - mp.sqrt(2 * 0.35 / mp.sqrt(b1)), 0) ** 2), float(b1)))
for k in [10, 14, 20, 30, 40, 60, 100]:
    M, n, bd, pd = binom_stats(k, 1.0)
    n23 = n ** (mp.mpf(2) / 3)
    Qm = M * bd - 2 * n23; Qp = M * bd + 2 * n23
    row = []
    for c in [mp.mpf(1), mp.mpf('0.1') * mp.sqrt(M), mp.mpf('0.3') * mp.sqrt(M), mp.mpf('0.35') * mp.sqrt(M)]:
        Rmax = c * (2 * mp.sqrt(Qp) + 1) + n / (9 * Qm)
        row.append(max(mp.sqrt(Qm) - mp.sqrt(Rmax), 0) ** 2 / M)
    # deficit at c=1 versus 2 sqrt2 beta^{3/4} M^{-1/4}
    pred = 2 * mp.sqrt(2) * b1 ** mp.mpf(0.75) * M ** (-mp.mpf(0.25))
    print("   %4d     %.5f    %.5f       %.5f       %.5f     (c=1 deficit %.4f, 2sqrt2 beta^.75 M^-.25 = %.4f)" % (
        k, float(row[0]), float(row[1]), float(row[2]), float(row[3]), float(b1 - row[0]), float(pred)))
print("   threshold nu < sqrt(beta(1))/2 = %.4f" % float(mp.sqrt(b1) / 2))

print("\n(3) unit-ball normalisation (inputs xi/sqrt d): construction cost 2 sqrt(MQ), accuracy tau^2/3 with tau^2=(MQ)^{-1/2};")
print("    explicit bound (sqrt(Q^-) - sqrt(c(2 sqrt(M Q^+)+1) + n/(9 M Q^-)))_+^2 / M on the event, lambda = 1")
print("   log2 M   c=1      c=0.5    c=0.3    c=0.1    c=0.01   c=1/log2M | limits (sqrt b - sqrt(2 c sqrt b))_+^2: c=0.3 -> %.4f, c=0.1 -> %.4f, c=0.01 -> %.4f" % (
    float(max(mp.sqrt(b1) - mp.sqrt(2 * 0.3 * mp.sqrt(b1)), 0) ** 2), float(max(mp.sqrt(b1) - mp.sqrt(2 * 0.1 * mp.sqrt(b1)), 0) ** 2),
    float(max(mp.sqrt(b1) - mp.sqrt(2 * 0.01 * mp.sqrt(b1)), 0) ** 2)))
for k in [10, 14, 20, 30, 40, 60]:
    M, n, bd, pd = binom_stats(k, 1.0)
    n23 = n ** (mp.mpf(2) / 3)
    Qm = M * bd - 2 * n23; Qp = M * bd + 2 * n23
    row = []
    for c in [mp.mpf(1), mp.mpf('0.5'), mp.mpf('0.3'), mp.mpf('0.1'), mp.mpf('0.01'), mp.mpf(1) / k]:
        Rmax = c * (2 * mp.sqrt(M * Qp) + 1) + n / (9 * M * Qm)
        row.append(max(mp.sqrt(Qm) - mp.sqrt(Rmax), 0) ** 2 / M)
    print("   %4d     %s" % (k, "   ".join("%.4f" % float(v) for v in row)))
print("   threshold for a positive limit: c < sqrt(beta(1))/2 = %.4f" % float(mp.sqrt(b1) / 2))
