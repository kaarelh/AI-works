"""Tanh MLP of the repo model: h^0 = (1,x), h^l = tanh(W^l h^{l-1}) (l=1..H), z = v^T h^H.
Ws = [W1 (N x (d+1)), W2 .. WH (N x N)], v (N,).  Energy
kappa_N = (d/N)|W1|_F^2 + sum_{l=2}^H |W^l|_F^2 + N |v|^2.
"""
import numpy as np


def xbar(X):
    return np.hstack([np.ones((X.shape[0], 1)), X])


def forward(Ws, v, X, keep=False):
    h = xbar(X)
    hs = [h]
    for W in Ws:
        h = np.tanh(h @ W.T)
        hs.append(h)
    z = h @ v
    return (z, hs) if keep else z


def energy_terms(Ws, v, d):
    N = v.shape[0]
    terms = [(d / N) * np.sum(Ws[0] ** 2)] + [np.sum(W ** 2) for W in Ws[1:]] + [N * np.sum(v ** 2)]
    return np.array(terms)


def energy(Ws, v, d):
    return float(np.sum(energy_terms(Ws, v, d)))


def path_norm(Ws, v):
    """P = |v|^T |W^H| ... |W^2| 1 (first layer not included)."""
    N = v.shape[0]
    r = np.ones(N)
    for W in Ws[1:]:
        r = np.abs(W) @ r
    return float(np.abs(v) @ r)


def rho_list(Ws):
    """rho^1 = 1, rho^l_j = sum_i |W^l_ji| rho^{l-1}_i."""
    N = Ws[0].shape[0]
    rhos = [np.ones(N)]
    for W in Ws[1:]:
        rhos.append(np.abs(W) @ rhos[-1])
    return rhos


def grad_linear_functional(Ws, v, X, a):
    """Gradient of J = sum_i a_i z(x_i) w.r.t. (Ws, v)."""
    z, hs = forward(Ws, v, X, keep=True)
    gv = hs[-1].T @ a
    delta = np.outer(a, v) * (1 - hs[-1] ** 2)          # n x N, dJ/d(preact of layer H)
    gWs = [None] * len(Ws)
    for l in range(len(Ws) - 1, -1, -1):
        gWs[l] = delta.T @ hs[l]
        if l > 0:
            delta = (delta @ Ws[l]) * (1 - hs[l] ** 2)
    return z, gWs, gv


def flatten(Ws, v):
    return np.concatenate([W.ravel() for W in Ws] + [v])


def unflatten(theta, d, N, H):
    Ws = []
    k = 0
    W1 = theta[k:k + N * (d + 1)].reshape(N, d + 1); k += N * (d + 1)
    Ws.append(W1)
    for _ in range(H - 1):
        Ws.append(theta[k:k + N * N].reshape(N, N)); k += N * N
    v = theta[k:k + N]
    return Ws, v


def lam2_vector(d, N, H):
    """Diagonal of Lambda^2 so that kappa = sum lam2 * theta^2."""
    return np.concatenate([np.full(N * (d + 1), d / N)] + [np.ones(N * N)] * (H - 1) + [np.full(N, float(N))])


def random_net(rng, d, N, H, scales):
    s1, s_int, s_out = scales
    Ws = [rng.normal(size=(N, d + 1)) * s1] + [rng.normal(size=(N, N)) * s_int for _ in range(H - 1)]
    v = rng.normal(size=N) * s_out
    return Ws, v


def clone(teacher_Ws, teacher_v, N):
    """Balanced cloning of a width-C teacher into width N >= C (paper.tex, Section 'Cloning')."""
    C = teacher_v.shape[0]
    q, r = divmod(N, C)
    sizes = np.array([q + 1] * r + [q] * (C - r))
    groups = np.repeat(np.arange(C), sizes)              # group index of each learner neuron
    Ws = [teacher_Ws[0][groups, :].copy()]
    for U in teacher_Ws[1:]:
        Ws.append(U[np.ix_(groups, groups)] / sizes[groups][None, :])
    v = teacher_v[groups] / sizes[groups]
    return Ws, v


def minimize_Fc(X, y, c, d, N, H, rng, restarts=5, maxiter=5000, init_scales=None, weights=None):
    """Minimize F_c(w) = kappa_N(w) + (1/c) sum_i wt_i (z_w(x_i) - y_i)^2 by L-BFGS from random starts.
    Returns (best F, best params). Local optimization: the result is an UPPER bound on min F_c."""
    from scipy.optimize import minimize
    lam2 = lam2_vector(d, N, H)
    wt = np.ones(len(y)) if weights is None else weights
    def obj(th):
        Ws, v = unflatten(th, d, N, H)
        z = forward(Ws, v, X)
        res = z - y
        a = 2 * wt * res / c
        _, gWs, gv = grad_linear_functional(Ws, v, X, a)
        F = np.sum(lam2 * th ** 2) + np.sum(wt * res ** 2) / c
        return F, 2 * lam2 * th + flatten(gWs, gv)
    best = (np.inf, None)
    for r in range(restarts):
        sc = init_scales if init_scales is not None else (10 ** rng.uniform(-0.5, 1), 10 ** rng.uniform(-1, 0.5) / np.sqrt(N), 10 ** rng.uniform(-1, 0.5) / N)
        th0 = flatten(*random_net(rng, d, N, H, sc))
        res = minimize(obj, th0, jac=True, method="L-BFGS-B", options=dict(maxiter=maxiter, maxfun=4 * maxiter))
        if res.fun < best[0]:
            best = (res.fun, res.x)
    return best
