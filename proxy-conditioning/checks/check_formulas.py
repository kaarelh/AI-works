"""Numerical checks of the formulas in framing.md (sections 1.4 and 1.6).

1. Hierarchical persona model: the gradient of the episode log-likelihood with
   respect to the global persona logits w is sum_i [r_i(theta) - q(theta | x_i)].
2. Small tilt of a prior over latents (R3): the change in E[J_T] is
   sqrt(2 KL) * sd(J_T) * Corr(J_P, J_T) to first order.
3. Several proxies, Gaussian latent (R3): the largest change in T within a KL
   budget kappa is sqrt(2 kappa) * sd(T) * R, with R the multiple correlation.
4. Goodhart threshold (R4): n* = ln(O) / -ln(1 - eps).

Run: python3 check_formulas.py  (needs numpy). Output: check_formulas_output.txt.
"""
import numpy as np

rng = np.random.default_rng(0)

# 1. Gradient identity, against central finite differences.
K, n = 5, 7
w = rng.normal(size=K)
lam = rng.uniform(0.1, 1, size=(n, K))   # lambda_theta(x_i): how strongly prompt x_i suggests persona theta
pi = rng.uniform(0.01, 1, size=(n, K))   # pi_theta(y_i | x_i)


def loglik(w):
    q = np.exp(w)[None, :] * lam
    q /= q.sum(1, keepdims=True)
    return np.log((q * pi).sum(1)).sum()


q = np.exp(w)[None, :] * lam
q /= q.sum(1, keepdims=True)
r = q * pi
r /= r.sum(1, keepdims=True)
analytic = (r - q).sum(0)
h = 1e-6
numeric = np.array([(loglik(w + h * np.eye(K)[k]) - loglik(w - h * np.eye(K)[k])) / (2 * h) for k in range(K)])
print(f"1. gradient identity: max abs error vs finite differences = {np.abs(analytic - numeric).max():.2e}")

# 2. Small exponential tilt of a uniform prior over M latents.
M = 200_000
mu = np.ones(M) / M
JP = rng.normal(size=M)
JT = 0.4 * JP + rng.normal(size=M) * np.sqrt(1 - 0.16)
corr = np.corrcoef(JP, JT)[0, 1]
for beta in [0.02, 0.05, 0.1]:
    wts = mu * np.exp(beta * JP)
    wts /= wts.sum()
    kl = np.sum(wts * np.log(wts / mu))
    dT = wts @ JT - mu @ JT
    pred = np.sqrt(2 * kl) * JT.std() * corr
    print(f"2. tilt beta={beta}: Delta E[J_T] = {dT:.5f}, first-order formula = {pred:.5f}")

# 3. Gaussian latent z ~ N(0, Sig); proxies A z, target aT . z; mean shift with
#    minimum KL for a required proxy shift delta; maximise over delta at fixed KL.
d, m = 30, 4
Sig = rng.normal(size=(d, d))
Sig = Sig @ Sig.T / d + np.eye(d) * 0.1
A = rng.normal(size=(m, d))
aT = rng.normal(size=d)
Kpp = A @ Sig @ A.T
kTp = aT @ Sig @ A.T
sT2 = aT @ Sig @ aT
R2 = kTp @ np.linalg.solve(Kpp, kTp) / sT2
kappa = 0.3
best = 0.0
for _ in range(20_000):
    delta = rng.normal(size=m)
    kl = 0.5 * delta @ np.linalg.solve(Kpp, delta)
    delta *= np.sqrt(kappa / kl)
    best = max(best, kTp @ np.linalg.solve(Kpp, delta))
print(f"3. several proxies: random-search max Delta T = {best:.4f}, formula sqrt(2 kappa) sd(T) R = {np.sqrt(2 * kappa * sT2 * R2):.4f} (R = {np.sqrt(R2):.3f})")

# 4. Goodhart threshold.
for O, eps in [(1e6, 0.01), (1e3, 0.01), (1e6, 0.001)]:
    print(f"4. prior odds O={O:.0e}, predictable error rate eps={eps}: n* = {np.log(O) / -np.log(1 - eps):.0f}")
