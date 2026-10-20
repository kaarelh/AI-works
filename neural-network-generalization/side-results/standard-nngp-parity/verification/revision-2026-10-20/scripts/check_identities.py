"""Monte Carlo checks of the exact identities used in the proof of Theorem A.

(1) E_S[y^T Q_SS y] = n tau_r + n(n-1) lambda_d          (y_i = parity(X_i))
(2) E_S[eps^2] = D_r / n,  eps^2 = sum_{|U|<=r} (n^-1 sum_i y_i chi_U(X_i))^2
(3) lambda_max(Q_SS) >= max(n lambda_{r+1}, tau_r)        (every sample)
(4) Gaussian quadratic-form Chernoff:
    P(||t||^2 > s) <= exp(-(s - 2 log2 tr Q)/(4 lambda_max)),  t ~ N(0,Q_SS)
(5) Gaussian linear tail: P(y^T t > x) <= exp(-x^2/(2 y^T Q y)).
Kernel: tanh, L=2, unit gains (exact spectrum from spec.py).
"""
import numpy as np
from math import comb, log
from spec import spectrum

rng = np.random.default_rng(12345)


def kraw(d):
    """K[q,h] = sum_{|U|=q} chi_U(x) chi_U(y) at Hamming distance h."""
    K = np.zeros((d + 1, d + 1))
    for q in range(d + 1):
        for h in range(d + 1):
            K[q, h] = sum((-1) ** i * comb(h, i) * comb(d - h, q - i)
                          for i in range(0, min(h, q) + 1) if q - i <= d - h)
    return K


def run(d, r, ns, reps=None):
    sp = spectrum(d)
    lam = sp['lam']
    Kr = kraw(d)
    tau = sum(comb(d, q) * lam[q] for q in range(r + 1, d + 1))
    Dr = sum(comb(d, q) for q in range(r + 1))
    qtail = np.array([lam[q] if q > r else 0.0 for q in range(d + 1)])
    Qh = qtail @ Kr                     # Q as a function of distance
    Ph = np.array([1.0 if q <= r else 0.0 for q in range(d + 1)]) @ Kr
    print(f"d={d} r={r} tau_r={tau:.4e} lambda_(r+1)={lam[r+1]:.4e} lambda_d={lam[d]:.4e} D_r={Dr}")
    for n in ns:
        reps_n = reps if reps is not None else (400 if n <= 400 else 60)
        yQy, eps2, worst_ratio = [], [], np.inf
        for _ in range(reps_n):
            a = rng.integers(0, 2 ** d, size=n, dtype=np.int64)
            y = np.where(np.bitwise_count(a) % 2 == 0, 1.0, -1.0)   # parity prod x_i, x = 1-2*bits
            H = np.bitwise_count(a[:, None] ^ a[None, :]).astype(int)
            Q = Qh[H]
            P = Ph[H]
            yQy.append(y @ Q @ y)
            eps2.append(y @ P @ y / n ** 2)
            lmax = np.linalg.eigvalsh(Q)[-1]
            worst_ratio = min(worst_ratio, lmax / max(n * lam[r + 1], tau))
        pred = n * tau + n * (n - 1) * lam[d]
        se = np.std(yQy) / np.sqrt(reps_n)
        print(f"  n={n:5d}: E y'Qy MC={np.mean(yQy):.5e} (+-{se:.1e})  exact={pred:.5e}  2n tau={2*n*tau:.3e}"
              f" | E eps^2 MC={np.mean(eps2):.5f} (+-{np.std(eps2)/np.sqrt(reps_n):.1e}) D_r/n={Dr/n:.5f}"
              f" | min lmax/max(n lam_(r+1),tau)={worst_ratio:.3f}")
    return sp, Qh, tau


def chernoff_check(d, r, n, nsamp=200000):
    sp, Qh, tau = None, None, None
    sp = spectrum(d)
    lam = sp['lam']
    Kr = kraw(d)
    qtail = np.array([lam[q] if q > r else 0.0 for q in range(d + 1)])
    Qh = qtail @ Kr
    a = rng.integers(0, 2 ** d, size=n, dtype=np.int64)
    y = np.where(np.bitwise_count(a) % 2 == 0, 1.0, -1.0)
    H = np.bitwise_count(a[:, None] ^ a[None, :]).astype(int)
    Q = Qh[H]
    ev, U = np.linalg.eigh(Q)
    ev = np.clip(ev, 0, None)
    lmax = ev[-1]
    tr = np.trace(Q)
    Z = rng.standard_normal((nsamp, n))
    T = (Z * np.sqrt(ev)) @ U.T
    sq = (T ** 2).sum(1)
    lin = T @ y
    vy = y @ Q @ y
    print(f"Chernoff check d={d} r={r} n={n}: tr={tr:.3e} lmax={lmax:.3e} y'Qy={vy:.3e}")
    for mult in [2.0, 3.0, 4.0, 6.0]:
        s = mult * tr
        emp = (sq > s).mean()
        bnd = np.exp(-(s - 2 * log(2) * tr) / (4 * lmax))
        print(f"   s={mult}*tr: P_emp={emp:.3e}  bound={bnd:.3e}  ok={emp <= bnd}")
    for k in [1.0, 2.0, 3.0]:
        x = k * np.sqrt(vy)
        emp = (lin > x).mean()
        bnd = np.exp(-x ** 2 / (2 * vy))
        print(f"   linear x={k}*sd: P_emp={emp:.3e}  bound={bnd:.3e}  ok={emp <= bnd}")


if __name__ == "__main__":
    run(10, 1, [20, 100, 400])
    run(10, 3, [20, 100, 400])
    run(12, 3, [50, 300, 1500])
    chernoff_check(10, 1, 200)
    chernoff_check(12, 3, 400)
