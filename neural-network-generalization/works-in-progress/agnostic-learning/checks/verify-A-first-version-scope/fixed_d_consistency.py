"""Scope check 1: at FIXED d the cube example does not refute anything.

For SP_c on D_d (uniform x on {-1,1}^d, fair label), every near-minimizer w in N_t(S),
at EVERY width, satisfies (compare with the zero network, Lemma 4.1(a) of A.md):
    Delta(z_w) <= Delta(0) + c t,   Delta(0) = sum_x k_x ybar_x^2.
If every atom is seen (k_min >= 1):
    sum_x (z(x)-ybar_x)^2 <= Delta(z_w)/k_min,   Q = sum_x ybar_x^2 <= Delta(0)/k_min,
    ||z||_2 <= sqrt((Delta(0)+ct)/k_min) + sqrt(Delta(0)/k_min)   (Minkowski),
    excess L(z_w) - 1 = (1/M) sum_x z(x)^2 <= U := ||z||^2 / M.
This bound is width-uniform and needs no network construction.  We simulate Delta(0),
k_min and U, and compare with the certified LOWER bound scale beta(n/M) of Theorem 4.4.
"""
import numpy as np
from scipy import integrate

rng = np.random.default_rng(12345)

def beta(lam):
    # beta(lam) = e^{-lam} int_0^lam (e^u-1)/u du = int_0^lam e^{u-lam} (1-e^{-u})/u du  (stable form)
    f = lambda u: np.exp(u - lam) * (-np.expm1(-u) / u if u > 0 else 1.0)
    val, _ = integrate.quad(f, 0, lam, limit=500, points=[max(lam - 50.0, 0.0)] if lam > 60 else None)
    return val

c, t = 1.0, 1.0
print("Fixed d: width-uniform UPPER bound U on the excess of every near-minimizer of F_c (c=t=1)")
for d in (6, 8):
    M = 2 ** d
    print(f"\n d={d}, M={M}")
    print(f"{'lambda=n/M':>10} {'n':>9} {'reps':>4} {'median k_min':>12} {'median Delta(0)/M':>17} "
          f"{'median U':>10} {'max U':>10} {'M/n':>8} {'beta(lambda)':>12}")
    for lam in (1, 4, 16, 64, 256, 1024, 4096):
        n = lam * M
        reps = 200 if n <= 2 ** 16 else 40
        kmins, d0s, Us = [], [], []
        for _ in range(reps):
            xs = rng.integers(0, M, size=n)
            ys = rng.choice([-1.0, 1.0], size=n)
            k = np.bincount(xs, minlength=M).astype(float)
            s = np.bincount(xs, weights=ys, minlength=M)
            seen = k > 0
            delta0 = np.sum(s[seen] ** 2 / k[seen])          # sum_x k_x ybar_x^2
            kmin = k.min()
            kmins.append(kmin); d0s.append(delta0 / M)
            if kmin >= 1:
                norm = np.sqrt((delta0 + c * t) / kmin) + np.sqrt(delta0 / kmin)
                Us.append(norm ** 2 / M)
            else:
                Us.append(np.inf)   # bound needs every atom seen
        Us = np.array(Us)
        print(f"{lam:>10} {n:>9} {reps:>4} {np.median(kmins):>12.1f} {np.median(d0s):>17.3f} "
              f"{np.median(Us):>10.4f} {np.max(Us):>10.4f} {M/n:>8.4f} {beta(lam):>12.5f}")
print("\nReading: U = O(M/n) -> 0 as n/M -> infinity at fixed d (once every atom is seen),")
print("so at fixed d the learner is consistent on D_d at every width; the Omega(1) excess of")
print("Theorem 4.4 lives only in the window n = Theta(2^d), i.e. it needs d -> infinity.")
