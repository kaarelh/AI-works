"""Checks of the deterministic lemmas of B.md Section 2 and Lemma 5.2:
 (a) sup|z_w| <= sqrt(N)|v|_2 <= sqrt(kappa);
 (b) Lip(z_w) <= d^{-1/2} (kappa/L)^{L/2}   (AM-GM form of paper.tex eq. energy-lipschitz);
 (c) path norm P <= (kappa/H)^{H/2}, and |z| <= P, |h^l_j| <= rho^l_j  (normalized units in [-1,1]);
 (d) balanced cloning: exact output, kappa_N <= E_* = d(d+1)B^2 + 2(L-1)C^2B^2, per-layer bounds;
 (e) finite-difference check of the manual backprop used by the optimization scripts.
"""
import numpy as np
from nn_utils import *

rng = np.random.default_rng(1)
worst = dict(a=0, b=0, c1=0, c2=0, c3=0)
for trial in range(400):
    H = int(rng.integers(1, 5)); L = H + 1; d = int(rng.integers(1, 7)); N = int(rng.integers(1, 30))
    Ws, v = random_net(rng, d, N, H, (10 ** rng.uniform(-1, 1), 10 ** rng.uniform(-1.5, 0.5), 10 ** rng.uniform(-2, 0)))
    kap = energy(Ws, v, d)
    X = rng.uniform(-1, 1, size=(300, d))
    z, hs = forward(Ws, v, X, keep=True)
    worst['a'] = max(worst['a'], np.max(np.abs(z)) / np.sqrt(kap))
    # Lipschitz: gradient norm in x at random points (z is C^1, so sup grad norm = Lip on convex sets)
    eps = 1e-6; g = np.zeros((X.shape[0], d))
    for k in range(d):
        E = np.zeros(d); E[k] = eps
        g[:, k] = (forward(Ws, v, X + E) - forward(Ws, v, X - E)) / (2 * eps)
    lipb = (kap / L) ** (L / 2) / np.sqrt(d)
    worst['b'] = max(worst['b'], np.max(np.linalg.norm(g, axis=1)) / lipb)
    P = path_norm(Ws, v)
    worst['c1'] = max(worst['c1'], P / (kap / H) ** (H / 2) if kap > 0 else 0)
    worst['c2'] = max(worst['c2'], np.max(np.abs(z)) / P if P > 0 else 0)
    rhos = rho_list(Ws)
    for l in range(1, H + 1):
        worst['c3'] = max(worst['c3'], np.max(np.abs(hs[l]) / rhos[l - 1][None, :]))
print("(a) max sup|z|/sqrt(kappa)                 :", round(worst['a'], 4), "(<= 1)")
print("(b) max |grad_x z| / [d^-1/2 (kappa/L)^(L/2)]:", round(worst['b'], 4), "(<= 1)")
print("(c) max P/(kappa/H)^(H/2)                   :", round(worst['c1'], 4), "(<= 1)")
print("    max sup|z|/P                            :", f"{worst['c2']:.15f}", "(<= 1)")
print("    max |h^l_j|/rho^l_j                     :", f"{worst['c3']:.15f}", "(<= 1)")

# (d) cloning
wc = 0.0; ok = True
for trial in range(300):
    H = int(rng.integers(1, 5)); L = H + 1; d = int(rng.integers(1, 6)); C = int(rng.integers(1, 6))
    B = 10 ** rng.uniform(0, 1)
    TW = [rng.uniform(-B, B, size=(C, d + 1))] + [rng.uniform(-B, B, size=(C, C)) for _ in range(H - 1)]
    Tv = rng.uniform(-B, B, size=C)
    N = int(rng.integers(C, 6 * C + 3))
    Ws, v = clone(TW, Tv, N)
    X = rng.uniform(-1, 1, size=(50, d))
    ok &= np.allclose(forward(Ws, v, X), forward(TW, Tv, X), atol=1e-10)
    terms = energy_terms(Ws, v, d)
    Estar = d * (d + 1) * B ** 2 + 2 * (L - 1) * C ** 2 * B ** 2
    ok &= terms[0] <= d * (d + 1) * B ** 2 + 1e-9
    ok &= np.all(terms[1:] <= 2 * C ** 2 * B ** 2 + 1e-9)
    wc = max(wc, terms.sum() / Estar)
print("(d) cloning exact and per-layer bounds hold:", bool(ok), "; max kappa_N/E_* =", round(wc, 4))

# (e) backprop check
H, d, N, n = 3, 3, 7, 11
Ws, v = random_net(rng, d, N, H, (1.0, 0.5, 0.3))
X = rng.uniform(-1, 1, size=(n, d)); a = rng.normal(size=n)
_, gWs, gv = grad_linear_functional(Ws, v, X, a)
th = flatten(Ws, v); gth = flatten(gWs, gv)
J = lambda t: a @ forward(*unflatten(t, d, N, H), X)
num = np.array([(J(th + 1e-6 * e) - J(th - 1e-6 * e)) / 2e-6 for e in np.eye(th.size)])
print("(e) backprop max abs error vs finite differences:", f"{np.max(np.abs(num - gth)):.2e}")
