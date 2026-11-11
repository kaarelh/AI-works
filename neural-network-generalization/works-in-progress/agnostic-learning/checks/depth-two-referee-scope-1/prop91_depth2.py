"""Re-referee (scope lens) check for depth-two.md Remark 5.7a.

Claim checked: B-tempered-likelihood.md Proposition 9.1 (stated for every L=H+1>=2 and every c>0) gives a
depth-two (L=2) negative result for general c, which depth-two.md does not use ("B does not treat the negative
side at depth two").  At L=2, d=1, X={-d0,+d0}, labels y=sign(x):
  (a) every near-minimizer has kappa_N <= K = n/c+1 (B Lemma 2.3(a)), hence by B Lemma 2.1(b)
      |z(d0)-z(-d0)| <= (kappa/2)*2*d0 <= K*d0 = 2*eta,  eta = d0*K/2, and L_D(clip z) >= (1-eta)^2;
  (b) the width-1 competitor g(x) = v*tanh(omega*x), omega = d0^{-1/2}, v = 1/tanh(omega*d0), fits exactly.
Choosing d0 = min(1/2, 1/K) gives eta <= 1/2, so every near-minimizer (and every limiting posterior predictor)
has L_D >= 1/4, while L_D(g) = 0 and g has weights <= 1.5*sqrt(max(K,2)).
Consequences printed below:
  (1) c >= n/4 (K <= 5): one FIXED law (d0 = 1/5) and one FIXED competitor (weights <= 2.39) defeat SP_c for
      every n: (P_2) fails, even at fixed d = 1.
  (2) c = n/ln n etc. (K = n^{o(1)}): the competitor lies in G_n^(alpha) once 1.5*sqrt(K) <= n^alpha, for every
      alpha > 0, so (P_2^{o(1)}[phi]) fails for every phi >= 1.
  (3) Lemma 2.1(b) at L=2, d=1 is spot-checked on random networks (kappa = their own energy).
  (4) Direct L-BFGS minimisation of F_c at c = n/4 on the two-point law (illustration only).
"""
import math
import numpy as np
from scipy.optimize import minimize

rng = np.random.default_rng(20261111)

def competitor(K):
    d0 = min(0.5, 1.0 / K)
    eta = d0 * K / 2.0
    omega = d0 ** -0.5
    v = 1.0 / math.tanh(omega * d0)
    gp, gm = v * math.tanh(omega * d0), v * math.tanh(-omega * d0)
    return d0, eta, omega, v, gp, gm

print("(1) c >= n/4 at L=2: K = n/c+1 <= 5; fixed d0 = 1/5")
d0 = 0.2
omega = d0 ** -0.5
v = 1.0 / math.tanh(omega * d0)
for K in (1.0, 2.0, 3.0, 5.0):
    eta = d0 * K / 2
    print("   K=%.1f  eta=%.3f  learner L_D >= (1-eta)^2 = %.3f" % (K, eta, (1 - eta) ** 2))
print("   fixed competitor: omega=%.4f  v=%.4f  g(+d0)=%.12f  g(-d0)=%.12f  max weight=%.4f" % (
    omega, v, v * math.tanh(omega * d0), v * math.tanh(-omega * d0), max(omega, v)))

print("\n(2) c = n/ln n and c = n/ln^2 n: competitor in G_n^(alpha) once 1.5*sqrt(K) <= n^alpha")
for name, cfun in (("n/ln n", lambda n: n / math.log(n)), ("n/ln^2 n", lambda n: n / math.log(n) ** 2)):
    for alpha in (0.05, 0.01):
        # find the smallest log10 n (on a grid) from which 1.5*max(omega, v) <= n^alpha
        found = None
        for l10 in np.arange(1, 4001, 1.0):
            n = 10.0 ** l10
            K = n / cfun(n) + 1
            d0_, eta_, om_, v_, gp_, gm_ = competitor(K)
            if max(om_, v_) <= n ** alpha and eta_ <= 0.5 + 1e-12 and abs(gp_ - 1) < 1e-9:
                found = l10
                break
        print("   c=%-9s alpha=%.2f: competitor in G_n^(alpha) (zero loss, learner L_D >= 1/4) from n ~ 10^%s" % (
            name, alpha, "%d" % found if found is not None else ">4000"))

print("\n(3) Lemma 2.1(b) at L=2, d=1: |z(x)-z(x')| <= (kappa/2)|x-x'| on random width-N nets (kappa = their own energy)")
worst = 0.0
for trial in range(20000):
    N = int(rng.integers(1, 30))
    W = rng.normal(size=(N, 2)) * rng.exponential(3.0)
    vv = rng.normal(size=N) * rng.exponential(3.0)
    kappa = (1.0 / N) * np.sum(W ** 2) + N * np.sum(vv ** 2)   # d = 1: (d/N)||W1||^2 + N||v||^2
    x, xp = rng.uniform(-1, 1, size=2)
    z = lambda t: float(vv @ np.tanh(W @ np.array([1.0, t])))
    ratio = abs(z(x) - z(xp)) / ((kappa / 2) * abs(x - xp) + 1e-300)
    worst = max(worst, ratio)
print("   max |z(x)-z(x')| / ((kappa/2)|x-x'|) over 20000 random nets: %.4f (must be <= 1)" % worst)

print("\n(4) Illustration: L-BFGS on F_c, c = n/4, two-point law d0 = 1/5, n = 400 (balanced), widths 1, 4, 16")
n = 400
xs = np.array([d0] * (n // 2) + [-d0] * (n // 2))
ys = np.sign(xs)
c = n / 4
for N in (1, 4, 16):
    best = None
    for rs in range(30):
        def F(p):
            W = p[:2 * N].reshape(N, 2); vv = p[2 * N:]
            H = np.tanh(np.outer(np.ones_like(xs), W[:, 0]) + np.outer(xs, W[:, 1]))
            zz = H @ vv
            return (1.0 / N) * np.sum(W ** 2) + N * np.sum(vv ** 2) + np.sum((zz - ys) ** 2) / c
        p0 = rng.normal(size=3 * N) * rng.choice([0.1, 1.0, 3.0])
        r = minimize(F, p0, method="L-BFGS-B")
        if best is None or r.fun < best.fun:
            best = r
    W = best.x[:2 * N].reshape(N, 2); vv = best.x[2 * N:]
    zp = float(vv @ np.tanh(W @ np.array([1.0, d0]))); zm = float(vv @ np.tanh(W @ np.array([1.0, -d0])))
    LD = 0.5 * ((np.clip(zp, -1, 1) - 1) ** 2 + (np.clip(zm, -1, 1) + 1) ** 2)
    kap = (1.0 / N) * np.sum(W ** 2) + N * np.sum(vv ** 2)
    print("   N=%2d  min F found=%.4f  kappa=%.4f (<= K=%.0f)  z(+d0)=%.4f z(-d0)=%.4f  clipped L_D=%.4f (>= 1/4)" % (
        N, best.fun, kap, n / c + 1, zp, zm, LD))
