"""Compression by subsampling hidden units (Maurey's empirical method).

A one-hidden-layer network is a sum over its units,

    f(x) = c + sum_i a_i phi_i(x),    phi_i(x) = relu(w_i . x + b_i),

with a_i the i-th column of the output layer.  Draw k indices I_1..I_k i.i.d.
with probabilities p_i and set

    g(x) = c + (1/k) sum_j a_{I_j} phi_{I_j}(x) / p_{I_j}.

Then E_I g = f, and with p_i proportional to ||a_i|| ||phi_i||_{L2(D_X)},

    E_I ||g - f||^2_{L2(D_X)} <= A^2 / k,   A = sum_i ||a_i|| ||phi_i||_{L2(D_X)}

(the "D_X path norm"; see search/README.md; with A and p estimated on a pool,
the identity is exact for the pool's empirical distribution).  The same holds
for the update relative to the free initialization: f - f_0 = (c - c_0) +
sum_i delta_i with delta_i = a_i phi_i - a_i^0 phi_i^0, and sampling with
p_i = ||delta_i|| / A_delta gives g = f_0 + (c - c_0) + (1/k) sum_j
delta_{I_j} / p_{I_j}, with E ||g - f||^2 = (A_delta^2 - ||f - f_0 - (c - c_0)||^2) / k.
Least-squares refits use a tiny ridge (1e-6 of the mean feature variance) for
numerical stability.

Two-hidden-layer networks are subsampled layer by layer (last hidden layer
first), refitting the next layer's weights by least squares after each step.

All functions work on weight lists [(W1, b1), (W2, b2), ...] of float64
arrays, as returned by models.MLP.weights().
"""

import numpy as np

from .models import np_forward


def relu_features(W, b, X):
    return np.maximum(X.astype(np.float64) @ W.T + b, 0.0)


def unit_importance(a_cols, Phi):
    """||a_i||_2 * rms_x phi_i(x): the Maurey importance of each unit.
    a_cols: (C, N) output weights; Phi: (P, N) unit outputs on a pool."""
    return np.linalg.norm(a_cols, axis=0) * np.sqrt(np.mean(Phi ** 2, axis=0))


def path_norm(a_cols, Phi):
    return float(unit_importance(a_cols, Phi).sum())


def sample_units(scores, k, rng, mode="maurey"):
    """Returns (unique indices, multiplicities, probabilities used).
    mode: 'maurey' (i.i.d. with p proportional to scores), 'uniform' (i.i.d.
    uniform), 'topk' (the k largest scores, deterministic)."""
    N = len(scores)
    if mode == "topk":
        idx = np.argsort(-scores, kind="stable")[:k]
        return np.sort(idx), np.ones(len(idx)), None
    p = np.full(N, 1.0 / N) if mode == "uniform" else scores / scores.sum()
    draw = rng.choice(N, size=k, replace=True, p=p)
    idx, counts = np.unique(draw, return_counts=True)
    return idx, counts.astype(np.float64), p


def greedy_units(Phi, T, k, ridge=1e-6, return_order=False):
    """Orthogonal matching pursuit over units: repeatedly add the unit whose
    feature (centred) best explains the current residual of the targets T
    (P, C), refitting all kept units by least squares after each addition.
    Returns the sorted index set, or the selection order if return_order."""
    Pc = Phi - Phi.mean(0)
    norms = np.sqrt((Pc ** 2).sum(0)) + 1e-12
    R = T - T.mean(0)
    chosen = []
    for _ in range(k):
        score = np.sqrt(((Pc.T @ R) ** 2).sum(1)) / norms
        score[chosen] = -1.0
        chosen.append(int(np.argmax(score)))
        Wout, bout = refit_linear(Phi[:, chosen], T, ridge)
        R = T - (Phi[:, chosen] @ Wout.T + bout)
    return np.array(chosen) if return_order else np.sort(np.array(chosen))


def maurey_output(a_cols, idx, counts, p, k):
    """Unbiased output weights of the subsampled units: count * a_i / (k p_i)."""
    return a_cols[:, idx] * (counts / (k * p[idx]))[None, :]


def refit_linear(F, T, ridge=1e-6):
    """Least squares (with a tiny ridge) of targets T (P, C) on features F (P, k)
    plus a constant: returns (Wout (C, k), bout (C,))."""
    P = F.shape[0]
    Fa = np.concatenate([F, np.ones((P, 1))], axis=1)
    G = Fa.T @ Fa / P
    G[np.diag_indices_from(G)] += ridge * (np.trace(G) / G.shape[0] + 1e-12)
    sol = np.linalg.solve(G, Fa.T @ T / P)
    return sol[:-1].T.copy(), sol[-1].copy()


# ----------------------------------------------------------------------------
# One hidden layer
# ----------------------------------------------------------------------------

def subsample_one_layer(weights, k, Xpool, rng, mode="maurey", refit=True):
    """weights = [(W, b), (V, c)].  Returns (subsampled weight list, kept unit
    indices, info dict)."""
    (W, b), (V, c) = weights
    Phi = relu_features(W, b, Xpool)
    scores = unit_importance(V, Phi)
    if mode == "greedy":
        idx, counts, p = greedy_units(Phi, Phi @ V.T + c, k), None, None
    else:
        idx, counts, p = sample_units(scores, k, rng, mode)
    if refit or p is None:
        T = Phi @ V.T + c                      # f's logits on the pool
        Vs, cs = refit_linear(Phi[:, idx], T)
    else:
        Vs, cs = maurey_output(V, idx, counts, p, k), c.copy()
    info = {"A": float(scores.sum()), "unique": int(len(idx))}
    return [(W[idx].copy(), b[idx].copy()), (Vs, cs)], idx, info


def subsample_update(weights, init, k, Xpool, rng, mode="maurey", refit=True):
    """Subsample the update relative to the (free) initialization: units
    contribute delta_i(x) = a_i phi_i(x) - a0_i phi0_i(x).  Returns
    (predict-logits function, kept indices, info).  The surrogate is

        g(x) = f_0(x) + sum_j beta_j delta_{I_j}(x) + (c - c_0) ...

    with beta from least squares on f - f_0 (refit) or Maurey weights."""
    (W, b), (V, c) = weights
    (W0, b0), (V0, c0) = init
    Phi, Phi0 = relu_features(W, b, Xpool), relu_features(W0, b0, Xpool)
    C = V.shape[0]
    # ||delta_i||^2 = sum_c E[(V_ci phi_i - V0_ci phi0_i)^2], from second moments
    # (a (P, C, N) array would not fit in memory for wide networks).
    m11, m10, m00 = np.mean(Phi ** 2, 0), np.mean(Phi * Phi0, 0), np.mean(Phi0 ** 2, 0)
    scores = np.sqrt(np.maximum(np.sum(V ** 2, 0) * m11 - 2 * np.sum(V * V0, 0) * m10
                                + np.sum(V0 ** 2, 0) * m00, 0.0))
    idx, counts, p = sample_units(scores, k, rng, mode)
    T = (Phi @ V.T + c) - (Phi0 @ V0.T + c0)   # f - f_0 on the pool
    if refit or p is None:
        # one coefficient per kept unit, shared across output channels
        Fk = Phi[:, None, idx] * V[None, :, idx] - Phi0[:, None, idx] * V0[None, :, idx]   # (P, C, k)
        A = Fk.transpose(1, 0, 2).reshape(-1, len(idx))
        A = np.concatenate([A, np.kron(np.eye(C), np.ones((Fk.shape[0], 1)))], axis=1)
        sol, *_ = np.linalg.lstsq(A, T.T.reshape(-1), rcond=None)
        beta, cshift = sol[:len(idx)], sol[len(idx):]
    else:
        beta, cshift = counts / (k * p[idx]), (c - c0)
    info = {"A_delta": float(scores.sum()), "unique": int(len(idx))}
    Wk, bk, Vk, W0k, b0k, V0k = W[idx], b[idx], V[:, idx], W0[idx], b0[idx], V0[:, idx]

    def logits(X):
        f0 = np_forward(init, X)
        Pk = relu_features(Wk, bk, X)
        P0k = relu_features(W0k, b0k, X)
        return f0 + (Pk * beta[None, :]) @ Vk.T - (P0k * beta[None, :]) @ V0k.T + cshift[None, :]

    return logits, idx, dict(info, beta=beta, cshift=cshift)


# ----------------------------------------------------------------------------
# Two hidden layers (layer-wise)
# ----------------------------------------------------------------------------

def subsample_two_layer(weights, k1, k2, Xpool, rng, mode="maurey"):
    """weights = [(W1,b1),(W2,b2),(V,c)].  Subsample the second hidden layer
    to k2 units (importance ||a_j|| rms phi2_j), refit the output layer; then
    subsample the first hidden layer to k1 units with importance
    ||W2[kept, i]|| rms phi1_i, refit the kept second-layer units'
    pre-activations by least squares, and finally refit the output layer."""
    (W1, b1), (W2, b2), (V, c) = weights
    H1 = relu_features(W1, b1, Xpool)
    Z2 = H1 @ W2.T + b2
    H2 = np.maximum(Z2, 0.0)
    T = H2 @ V.T + c
    s2 = unit_importance(V, H2)
    idx2, _, _ = sample_units(s2, k2, rng, mode)
    s1 = unit_importance(W2[idx2], H1)
    idx1, _, _ = sample_units(s1, k1, rng, mode)
    W2s, b2s = refit_linear(H1[:, idx1], Z2[:, idx2])     # pre-activations of kept layer-2 units
    H2s = np.maximum(H1[:, idx1] @ W2s.T + b2s, 0.0)
    Vs, cs = refit_linear(H2s, T)
    g = [(W1[idx1].copy(), b1[idx1].copy()), (W2s, b2s), (Vs, cs)]
    return g, (idx1, idx2), {"A2": float(s2.sum()), "unique1": int(len(idx1)), "unique2": int(len(idx2))}
