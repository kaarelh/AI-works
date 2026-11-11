"""Pointwise checks of the two inequalities behind B.md Lemma 3.1, on the network d=1, N=1, H=1 (w=(a,b,v), z=v tanh(a+bx)),
kappa = a^2+b^2+v^2 (Lambda = I), F = kappa + (1/c) sum (z(x_i)-y_i)^2.
(i)  normalizer: F < m* + zeta/4 on the ball |w - w*| < rho, rho = min{1, zeta/(4 l_F)},
     l_F = 2 lam_max max_Omega|Lam w| + (n/c) G (2Z+2), Omega = {dist(w, {|w|^2 <= n/c}) <= 1}.
(ii) tail envelope: on {F > m*+zeta} and sigma^2 <= alpha/2, alpha = zeta/(8(n/c+zeta)):
     (1+F) e^{-F/(2 s^2)} <= e^{-(1-2 alpha)(m*+zeta)/(2 s^2)} e^{-alpha |w|^2/(2 s^2)}   (checked in log form).
(iii) exponent bookkeeping: (1-2alpha)(m*+zeta) - (m*+zeta/4) >= zeta/2."""
import math
import numpy as np
from scipy.optimize import minimize
rng = np.random.default_rng(3)
n, c, zeta = 20, 4.0, 0.2
x = rng.uniform(-1, 1, n); y = rng.uniform(-1, 1, n)
def F(w):
    a, b, v = w
    return a * a + b * b + v * v + np.sum((v * np.tanh(a + b * x) - y) ** 2) / c
best = None
for _ in range(60):
    r = minimize(F, rng.standard_normal(3) * 1.5, method="BFGS")
    if best is None or r.fun < best.fun: best = r
ws, ms = best.x, best.fun
print(f"m* = {ms:.6f} (<= n/c = {n/c}), |w*|^2 = {ws@ws:.4f}")
R0 = math.sqrt(n / c) + 1                        # Omega is inside the ball of radius sqrt(n/c)+1 (Lambda = I)
G = math.sqrt(2 * R0 ** 2 + 1)                   # |grad_w z|^2 <= v^2 (1 + x^2) + tanh^2 <= 2 v^2 + 1 for |x| <= 1
Z = R0
lF = 2 * R0 + (n / c) * G * (2 * Z + 2)
rho = min(1.0, zeta / (4 * lF)); alpha = zeta / (8 * (n / c + zeta))
print(f"l_F = {lF:.2f}, rho = {rho:.3e}, alpha = {alpha:.4e}, sigma_max = sqrt(alpha/2) = {math.sqrt(alpha/2):.4f}")
# (i)
u = rng.standard_normal((200000, 3)); u /= np.linalg.norm(u, axis=1, keepdims=True)
pts = ws + u * rho * rng.uniform(0, 1, (200000, 1)) ** (1 / 3)
vals = np.array([F(p) for p in pts[:20000]])
print(f"(i)  max F - m* on the rho-ball (20000 pts) = {vals.max() - ms:.3e}  < zeta/4 = {zeta/4}")
# (ii)
worst = -np.inf; cnt = 0
for s in [math.sqrt(alpha / 2), 0.03, 0.01]:
    W = rng.standard_normal((200000, 3)) * rng.choice([0.3, 1, 3, 10], (200000, 1))
    Fv = np.array([F(w) for w in W[:40000]])
    mask = Fv > ms + zeta
    lhs = np.log1p(Fv[mask]) - Fv[mask] / (2 * s * s)
    rhs = -(1 - 2 * alpha) * (ms + zeta) / (2 * s * s) - alpha * np.sum(W[:40000][mask] ** 2, 1) / (2 * s * s)
    worst = max(worst, np.max(lhs - rhs)); cnt += mask.sum()
print(f"(ii) max [log LHS - log RHS] over {cnt} tail points, sigma in {{sqrt(alpha/2), .03, .01}} = {worst:.3e} (<= 0)")
# (iii)
for m_ in [0.0, ms, n / c]:
    print(f"(iii) m*={m_:.3f}: (1-2a)(m*+z) - (m*+z/4) - z/2 = {(1-2*alpha)*(m_+zeta) - (m_+zeta/4) - zeta/2:.3e} (>= 0)")
