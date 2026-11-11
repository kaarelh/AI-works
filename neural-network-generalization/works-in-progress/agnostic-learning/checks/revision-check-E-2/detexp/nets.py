"""Minimal tanh-network utilities matching the repo conventions:
h^0 = (1,x), h^l = tanh(W^l h^{l-1}) (l=1..H), z = v^T h^H,
kappa_N = (d/N)||W^1||_F^2 + sum_{l=2}^H ||W^l||_F^2 + N||v||^2.
Finite-scale prior mu_{N,gamma}: entries N(0, N^{1-g}/d), N(0, N^{-g}), N(0, N^{-g-1})."""
import numpy as np
import itertools

def cube(d):
    return np.array(list(itertools.product([-1.0, 1.0], repeat=d)))

def xbar(X):
    return np.hstack([np.ones((X.shape[0], 1)), X])

def forward(w, X):
    W1, Ws, v = w
    h = np.tanh(xbar(X) @ W1.T)          # (n, N)
    for W in Ws:
        h = np.tanh(h @ W.T)
    return h @ v

def energy(w, d):
    W1, Ws, v = w
    N = W1.shape[0]
    return (d/N)*np.sum(W1**2) + sum(np.sum(W**2) for W in Ws) + N*np.sum(v**2)

def layer_energies(w, d):
    W1, Ws, v = w
    N = W1.shape[0]
    return [(d/N)*np.sum(W1**2)] + [np.sum(W**2) for W in Ws] + [N*np.sum(v**2)]

def prior_scales(N, d, gamma):
    tau = N**((1-gamma)/2)
    return tau/np.sqrt(d), tau/np.sqrt(N), tau/N   # std of first-layer, internal, readout entries

def perturb(w0, d, gamma, rng):
    W1, Ws, v = w0
    N = W1.shape[0]
    s1, si, sv = prior_scales(N, d, gamma)
    xi1 = rng.standard_normal(W1.shape)
    Zs = [rng.standard_normal(W.shape) for W in Ws]
    zeta = rng.standard_normal(v.shape)
    w = (W1 + s1*xi1, [W + si*Z for W, Z in zip(Ws, Zs)], v + sv*zeta)
    return w, (xi1, Zs, zeta)

def standardized_sqnorm(w0, d, gamma):
    """||D_s^{-1} w0||^2 = N^gamma kappa_N(w0)."""
    N = w0[0].shape[0]
    return N**gamma * energy(w0, d)
