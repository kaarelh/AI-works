"""Remark B1.5: the 'trivial' a-priori displacement bound from worst-case gradient norms (no smoothness,
any minibatch, SGD or GD).  u_k = ||theta_k - theta_0||_{M^-1} satisfies u_{k+1} <= u_k + eta G(u_k), where
G(u) bounds the per-example gradient M-norm over the M^-1-ball of radius u around theta_0, so u_k <= U(eta k)
with U' = G(U), U(0) = 0.  We print G(0), U after one SGD step, and the blow-up time of U.
Init norms are those of the study's seed-0 muP initialisation (d = 30, N = 128).
"""
import numpy as np
from scipy.integrate import quad

d, N = 30, 128
D = d + 1
rng = np.random.default_rng(0)
W1 = rng.standard_normal((N, d)) / np.sqrt(d); W2 = rng.standard_normal((N, N)) / np.sqrt(N); a = rng.standard_normal(N) / N
F1_0, F2_0, A_0 = np.linalg.norm(W1), np.linalg.norm(W2), np.linalg.norm(a)
m1, m2, ma = 2.0, 1.0, 0.5          # SGD multipliers (W1,b1), (W2,b2), a
eta = 0.2

def G(u):
    F1 = F1_0 + np.sqrt(m1) * u; F2 = F2_0 + np.sqrt(m2) * u; A = A_0 + np.sqrt(ma) * u
    h1 = F1 * np.sqrt(D)                     # ||relu([W1 b1] xhat)|| <= ||[W1 b1]||_F ||xhat||
    h1hat = np.sqrt(h1 ** 2 + 1)
    h2 = F2 * h1hat
    r = 1 + A * h2                           # |f - y| <= 1 + |f|
    gradf = np.sqrt(ma * h2 ** 2 + m2 * A ** 2 * h1hat ** 2 + m1 * F2 ** 2 * A ** 2 * D)
    return r * gradf

print(f"init norms: ||W1||_F={F1_0:.2f} ||W2||_F={F2_0:.2f} ||a||={A_0:.3f}")
print(f"G(0) = {G(0):.1f}   (per-example gradient M-norm bound at init)")
print(f"one SGD step (eta={eta}) can move theta by up to eta*G(0) = {eta * G(0):.1f} in M^-1 norm")
Tstar = quad(lambda u: 1 / G(u), 0, np.inf)[0]
print(f"blow-up time of U' = G(U): T* = {Tstar:.2e}  (= {Tstar / eta:.2e} SGD steps)")
# for comparison: typical (not worst-case) hidden norms at init
X = rng.choice([-1.0, 1.0], size=(1000, d))
h1 = np.maximum(X @ W1.T, 0); h2 = np.maximum(h1 @ W2.T, 0)
print(f"typical ||h1|| = {np.linalg.norm(h1, axis=1).mean():.2f} (worst-case bound {F1_0 * np.sqrt(D):.1f}); "
      f"typical ||h2|| = {np.linalg.norm(h2, axis=1).mean():.2f} (bound {F2_0 * np.sqrt((F1_0 * np.sqrt(D)) ** 2 + 1):.1f})")
