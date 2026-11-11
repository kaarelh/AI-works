"""Independent check of Lemma C.6.1 (i)-(iii) in C.md, by 1-D quadrature.
Toy prior: z_w(x) = s * xi (one readout coordinate, hidden activation identically 1, so sigma_out^2 = s^2),
xi ~ N(0,1) (m_nu = 1). FIX_eta posterior Pi_t ∝ exp(-eta * sum_i (clip z - y_i)^2) N(0, s^2).
This is the extreme case |h| = 1 of the lemma, where sum_j a_j^2 = sigma_out^2 exactly.
We take the worst label sequence y_i = 1 (pushes the mean up) and also random labels; any eta > 0.
Checks:  (i) |fhat_t| <= s^2 (4k + sqrt(2k)),  k = eta t;  (ii) KL <= eta t s^2 (1 + 8k + 2 sqrt(2k));
(iii) int z^2 dPi_t <= 4 s^2 (KL + log(2)/2).
"""
import numpy as np
rng = np.random.default_rng(0)
xi = np.linspace(-40, 40, 400001)
dxi = xi[1] - xi[0]
phi0 = np.exp(-xi**2 / 2) / np.sqrt(2 * np.pi)
worst = {"i": 0.0, "ii": 0.0, "iii": 0.0}
nviol = 0
for s2 in [1e-4, 1e-3, 1e-2, 3e-2, 0.1, 0.3, 1.0]:
    s = np.sqrt(s2)
    z = s * xi
    c = np.clip(z, -1, 1)
    for eta in [0.01, 0.125, 0.5, 2.0, 10.0]:
        for t in [1, 5, 20, 100]:
            for labels in ["ones", "rand"]:
                y = np.ones(t) if labels == "ones" else rng.uniform(-1, 1, t)
                # sum_i (c - y_i)^2 = t c^2 - 2 c sum y + sum y^2
                ell = eta * (t * c**2 - 2 * c * y.sum() + (y**2).sum())
                ell -= ell.min()
                lik = np.exp(-ell)
                Z = (lik * phi0).sum() * dxi
                post = lik * phi0 / Z
                fhat = (c * post).sum() * dxi
                KL = (post * np.log(np.where(post > 0, post / phi0, 1.0))).sum() * dxi
                Ez2 = (z**2 * post).sum() * dxi
                k = eta * t
                b1 = s2 * (4 * k + np.sqrt(2 * k))
                b2 = eta * t * s2 * (1 + 8 * k + 2 * np.sqrt(2 * k))
                b3 = 4 * s2 * (KL + 0.5 * np.log(2))
                r1, r2, r3 = abs(fhat) / b1, KL / b2, Ez2 / b3
                worst["i"] = max(worst["i"], r1); worst["ii"] = max(worst["ii"], r2); worst["iii"] = max(worst["iii"], r3)
                if r1 > 1 + 1e-9 or r2 > 1 + 1e-9 or r3 > 1 + 1e-9:
                    nviol += 1
                    print("VIOLATION", s2, eta, t, labels, r1, r2, r3)
print("max ratio actual/bound: (i) %.3f  (ii) %.3f  (iii) %.3f ; violations: %d" % (worst["i"], worst["ii"], worst["iii"], nviol))

# small arithmetic claims
from scipy.optimize import brentq
u = brentq(lambda u: u - np.tanh(2*u), 0.5, 1.0)
print("u* =", u, " in (0.957,0.958):", 0.957 < u < 0.958, " tanh2 > u*:", np.tanh(2) > u)
print("16+4*sqrt2 =", 16 + 4*np.sqrt(2), "< 22:", 16 + 4*np.sqrt(2) < 22)
# Prop C.3(c) 'learn only when eta sigma^2 n >~ 1': if sigma^2<=1 and sigma^2(4k+sqrt(2k))>1/4 then sigma^2 k > ?
ks = np.logspace(-8, 4, 200001)
best = np.inf
for s2 in np.logspace(-8, 0, 801):
    mask = s2 * (4*ks + np.sqrt(2*ks)) > 0.25
    if mask.any():
        best = min(best, (s2 * ks[mask]).min())
print("min of sigma^2*k over {sigma^2<=1, sigma^2(4k+sqrt(2k))>1/4}: %.4g  (so learning needs eta*sigma^2*n >= this * m_nu)" % best)
