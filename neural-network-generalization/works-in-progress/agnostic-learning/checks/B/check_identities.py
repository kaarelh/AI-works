"""Numerical checks of the elementary identities used in B.md, Section 5 and Section 7.
(1) clip_t(u) = (|u+t| - |u-t|)/2.
(2) Clip-mixture identity: tanh(r u)/r = int_0^1 clip_t(u) 2r tanh(rt) sech^2(rt) dt + sech^2(r) clip_1(u), |u|<=1.
(3) tanh(s) = E sign(s - T), T with CDF (1+tanh t)/2.
(4) Staircase identity for parities: chi_S = c0 + sum_j eps_j sign(t_S - theta_j), |eps_j| = 1, |c0| <= 1.
(5) 1 - tanh(b) <= 2 exp(-2b);  |t - tanh t| <= |t|^3/3.
"""
import numpy as np
np.seterr(over="ignore")
from scipy import integrate

rng = np.random.default_rng(0)
clip = lambda u, t: np.maximum(-t, np.minimum(t, u))

# (1)
err1 = 0.0
for _ in range(10000):
    u, t = rng.uniform(-3, 3), rng.uniform(0, 2)
    err1 = max(err1, abs(clip(u, t) - (abs(u + t) - abs(u - t)) / 2))
print(f"(1) clip formula max error: {err1:.2e}")

# (2)
err2 = 0.0
for _ in range(400):
    r = 10 ** rng.uniform(-2, 1.5); u = rng.uniform(-1, 1)
    dens = lambda t: 2 * r * np.tanh(r * t) / np.cosh(r * t) ** 2
    val, _ = integrate.quad(lambda t: clip(u, t) * dens(t), 0, 1, points=[abs(u)], limit=200)
    rhs = val + clip(u, 1.0) / np.cosh(r) ** 2
    mass, _ = integrate.quad(dens, 0, 1, limit=200)
    err2 = max(err2, abs(np.tanh(r * u) / r - rhs), abs(mass + 1 / np.cosh(r) ** 2 - 1))
print(f"(2) clip-mixture identity (and total mass 1) max error over 400 (r,u): {err2:.2e}")

# (3)  density of T is (1/2) sech^2 t
err3 = 0.0
for s in np.linspace(-4, 4, 41):
    pdf = lambda t: 0.5 / np.cosh(t) ** 2
    plus, _ = integrate.quad(pdf, -np.inf, s); minus, _ = integrate.quad(pdf, s, np.inf)
    err3 = max(err3, abs(plus - minus - np.tanh(s)))
print(f"(3) tanh(s) = E sign(s-T) max error: {err3:.2e}")

# (4) exhaustive over k = 1..12 and all sign patterns of the k coordinates
ok = True; maxl1 = 0
for k in range(1, 13):
    thetas = np.arange(-k + 1, k, 2)              # k thresholds, parity opposite to k
    ts = np.arange(-k, k + 1, 2)                  # possible values of t_S
    phi = (-1.0) ** ((k - ts) // 2)               # parity as a function of t_S
    c0 = (phi[0] + phi[-1]) / 2
    jumps = np.diff(phi)                          # Delta_j, at threshold thetas[j]
    eps = jumps / 2
    rep = c0 + np.array([np.sum(eps * np.sign(t - thetas)) for t in ts])
    ok &= np.allclose(rep, phi) and np.all(np.abs(eps) == 1) and abs(c0) <= 1
    maxl1 = max(maxl1, (abs(c0) + np.sum(np.abs(eps))) / (k + 1))
    # direct check on the cube {-1,1}^k
    X = np.array(np.meshgrid(*[[-1, 1]] * k)).reshape(k, -1).T
    tS = X.sum(1)
    rep2 = c0 + np.sign(tS[:, None] - thetas[None, :]) @ eps
    ok &= np.allclose(rep2, X.prod(1))
    ok &= np.min(np.abs(tS[:, None] - thetas[None, :])) >= 1   # margin >= 1
print(f"(4) staircase parity identity k=1..12 exact on the cube: {ok};  max l1/(k+1) = {maxl1:.3f}")

# (5)
b = np.linspace(0, 20, 2001)
import mpmath as mp
mp.mp.dps = 50
ratio = max(float((1 - mp.tanh(mp.mpf(x))) / (2 * mp.e ** (-2 * mp.mpf(x)))) for x in np.linspace(0, 20, 401))
print(f"(5a) max of (1-tanh b)/(2exp(-2b)) on [0,20] (50-digit arithmetic): {ratio:.6f}  (<= 1 expected; equals 1/(1+e^-2b))")
t = np.linspace(-5, 5, 2001)
print(f"(5b) max of |t - tanh t| - |t|^3/3 on [-5,5]: {np.max(np.abs(t - np.tanh(t)) - np.abs(t) ** 3 / 3):.2e}  (<= 0 expected)")
