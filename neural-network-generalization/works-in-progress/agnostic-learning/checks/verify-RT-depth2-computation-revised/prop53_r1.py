"""Independent checks of Proposition 5.3 and Remark 5.4 of RT-depth2.fixed.md (referee r1, computation lens).
(1) explicit networks on Sylvester-Hadamard atoms built by Kronecker products, widths N in {1,2,5}, lambda in {0.5,1,2},
    M in {8,...,4096}: u.xi_l = ybar_l 1_T(l), ||u||^2 = Q/M, z = tau^{-1} tanh(tau u.x), kappa_N = tau^2 Q + tau^-2 = 2 sqrt Q,
    |z - ybar| <= tau^2 |ybar|^3/3 <= tau^2/3, R <= n/(9Q); unit-ball cost tau^2 M Q + tau^-2.
(2) |tanh s - s| <= |s|^3/3 on a fine grid (and its sharpness constant near 0).
(3) event-level explicit bound table (c=1, c=0.1 sqrt M) and the rate claims:
     c <= nu sqrt M:  bound -> beta(1-sqrt(2nu/sqrt beta))^2
     c <= sqrt M:     bound >= beta - 4 sqrt(c) M^{-1/4} - C M^{-1/3}; report the smallest C that works on a grid.
(4) Remark 5.4 (unit ball): limits and M = 2^60 values."""
import numpy as np, mpmath as mp
import sys; sys.path.insert(0, '.')
from t51_r1 import stats
rng = np.random.default_rng(424242)

def hadamard(M):
    H = np.array([[1.0]]); H2 = np.array([[1.0, 1.0], [1.0, -1.0]])
    while H.shape[0] < M: H = np.kron(H, H2)
    return H

print("(1) explicit networks")
worst = 0.0; count = 0
for M in [8, 32, 128, 512, 2048, 4096]:
    Xi = hadamard(M); d = M
    assert np.array_equal(Xi @ Xi.T, M * np.eye(M))
    for lam in [0.5, 1.0, 2.0]:
        n = int(np.ceil(lam * M))
        idx = rng.integers(0, M, n); y = rng.choice([-1.0, 1.0], n)
        k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=y, minlength=M)
        T = k > 0; yb = np.where(T, S / np.maximum(k, 1), 0.0)
        Q = float(np.sum(yb**2)); G = float(np.sum(k * yb**2))
        if Q == 0: continue
        u = Xi[T].T @ yb[T] / M
        assert np.allclose(Xi @ u, yb, atol=1e-12) and abs(u @ u - Q / M) <= 1e-12 * max(1, Q)
        tau = Q**-0.25
        for N in [1, 2, 5]:
            W = np.tile(np.concatenate([[0.0], tau * u]), (N, 1)); v = np.full(N, 1 / (N * tau))
            kap = d / N * np.sum(W**2) + N * np.sum(v**2)
            Xb = np.hstack([np.ones((M, 1)), Xi]); z = np.tanh(Xb @ W.T) @ v
            assert abs(kap - (tau**2 * Q + tau**-2)) < 1e-9 * kap and abs(kap - 2 * np.sqrt(Q)) < 1e-9 * kap
            err = np.abs(z - yb)
            assert np.all(err[T] <= tau**2 * np.abs(yb[T])**3 / 3 + 1e-13) and np.all(np.abs(z[~T]) < 1e-13)
            R = float(np.sum(k[T] * (z[T] - yb[T])**2)); assert R <= n / (9 * Q) + 1e-12
            worst = max(worst, float(np.max(err[T] / (tau**2 / 3))))
            # unit ball
            Wb = W.copy(); Wb[:, 1:] *= np.sqrt(d)
            zb = np.tanh(np.hstack([np.ones((M, 1)), Xi / np.sqrt(d)]) @ Wb.T) @ v
            assert np.allclose(zb, z, atol=1e-12)
            kb = d / N * np.sum(Wb**2) + N * np.sum(v**2)
            assert abs(kb - (tau**2 * M * Q + tau**-2)) < 1e-9 * kb
            count += 1
print("   %d configurations passed; max |z-ybar|/(tau^2/3) = %.4f" % (count, worst))

print("\n(2) |tanh s - s| <= |s|^3/3")
s = np.linspace(-20, 20, 2000001); s = s[s != 0]
r = np.abs(np.tanh(s) - s) / (np.abs(s)**3 / 3)
print("   max ratio over [-20,20] = %.6f (<=1 needed; ->1 as s->0)" % r.max())

mp.mp.dps = 60
def beta(l): l = mp.mpf(l); return mp.e**(-l) * (mp.ei(l) - mp.euler - mp.log(l))
b = beta(1)
def psiH(k, c, unit=False, lam=1):
    M, n, bd, pd = stats(k, lam)
    n23 = n**(mp.mpf(2)/3); Qm = M * bd - 2 * n23; Qp = M * bd + 2 * n23
    if Qm <= 0: return mp.mpf(0)
    if unit: R = c * (2 * mp.sqrt(M * Qp) + 1) + n / (9 * M * Qm)
    else: R = c * (2 * mp.sqrt(Qp) + 1) + n / (9 * Qm)
    return max(mp.sqrt(Qm) - mp.sqrt(R), 0)**2 / M

print("\n(3) event-level explicit bound, lambda = 1")
for k in [10, 14, 20, 30, 40, 60]:
    M = mp.mpf(2)**k
    print("   log2M=%3d  c=1: %.4f   c=0.1 sqrtM: %.5f" % (k, float(psiH(k, 1)), float(psiH(k, mp.mpf('0.1') * mp.sqrt(M)))))
print("   limit nu=0.1: %.4f" % float(b * (1 - mp.sqrt(2 * mp.mpf('0.1') / mp.sqrt(b)))**2))
# rate claim: psiH >= beta - 4 sqrt(c) M^{-1/4} - C M^{-1/3}; smallest C on grid (only where RHS could be positive)
Cneed = 0; arg = None
for k in range(8, 121, 2):
    M = mp.mpf(2)**k
    for e in [-1, -0.5, 0, 0.1, 0.25, 0.4, 0.5]:
        c = M**mp.mpf(e) if e != -1 else 1 / M
        val = psiH(k, c)
        need = (b - 4 * mp.sqrt(c) * M**(-mp.mpf(1)/4) - val) * M**(mp.mpf(1)/3)
        if need > Cneed: Cneed, arg = need, (k, e)
print("   rate: smallest C with bound >= beta - 4 sqrt(c) M^-1/4 - C M^-1/3 over grid: C = %.3f at (log2M, exponent of c) = %s" % (float(Cneed), arg))
# what drives it: h_d = 2 n^{2/3}/M = 2 M^{-1/3} at lambda = 1
print("   (2 n^{2/3}/M * M^{1/3} = 2 at lambda = 1; plus beta_d - beta and Q^+ effects)")

print("\n(4) Remark 5.4, unit ball, lambda = 1: limits beta(1-sqrt(2c/sqrt beta))_+^2 and values at M=2^60")
for c in ['1', '0.5', '0.3', '0.1', '0.01']:
    c = mp.mpf(c)
    lim = b * max(1 - mp.sqrt(2 * c / mp.sqrt(b)), 0)**2
    print("   c=%-5s limit %.4f   M=2^60: %.4f" % (mp.nstr(c, 3), float(lim), float(psiH(60, c, unit=True))))
print("   threshold sqrt(beta)/2 = %.4f" % float(mp.sqrt(b) / 2))
