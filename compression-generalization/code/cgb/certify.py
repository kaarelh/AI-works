"""Certificates that every network in a described weight set K classifies a
point correctly.

K is given by centre weights G = [(W_l, b_l)] and, for each layer, a set of
allowed perturbations (Delta W_l, Delta b_l):

* bias: |Delta b_l[i]| <= eb[i]
* weights: the sum of "terms", each bounding |Delta W_l[i, :] . h| for an
  input h of the layer:
    ("box", E)        |Delta W[i,j]| <= E[i,j]           sup = E[i,:] . |h|
    ("l2", r, P)      ||Delta W[i,:] P||_2 <= r[i]       sup = r[i] ||P^T h||_2
  where the P's of a layer are orthonormal bases of mutually orthogonal
  subspaces that together span the input space (P = None means identity).
  Delta W = sum_j Delta W P_j P_j^T, so |Delta W_i h| <= sum_j ||Delta W_i P_j|| ||P_j^T h||.
  A layer uses either one box term or a list of l2 terms.

`certify` propagates sound interval bounds (float64, with a small outward
rounding margin) through the network and returns, for each (x, y), True only
if every network in K classifies x as y.  `contains` checks that a given
network lies in K.
"""

import numpy as np

EPS_REL = 1e-9
EPS_ABS = 1e-12


class Layer:
    def __init__(self, W, b, eb, terms):
        self.W = np.asarray(W, dtype=np.float64)
        self.b = np.asarray(b, dtype=np.float64)
        self.eb = np.broadcast_to(np.asarray(eb, dtype=np.float64), self.b.shape).copy()
        self.terms = terms  # list of tuples as described above
        kinds = {t[0] for t in terms}
        assert len(kinds) <= 1, "a layer uses one box term or a list of l2 terms"
        if kinds == {"box"}:
            assert len(terms) == 1 and terms[0][1].shape == self.W.shape
        if kinds == {"l2"}:
            Ps = [t[2] for t in terms]
            if any(P is None for P in Ps):
                assert len(Ps) == 1
            else:
                dim = sum(P.shape[1] for P in Ps)
                assert dim == self.W.shape[1], "l2 blocks must span the input space"


def _sup_delta(layer, hc, hr, exact):
    """Upper bound on sup_{Delta in K_l} |Delta W h| over h in [hc-hr, hc+hr],
    for each sample and output unit.  hc, hr: (N, in)."""
    N = hc.shape[0]
    out = np.zeros((N, layer.W.shape[0]))
    habs = np.abs(hc) + hr
    for t in layer.terms:
        if t[0] == "box":
            out += habs @ t[1].T
        elif t[0] == "l2":
            r, P = t[1], t[2]
            if P is None:
                norm = np.linalg.norm(hc, axis=1) + (0.0 if exact else np.linalg.norm(hr, axis=1))
                if not exact:  # h >= 0 after ReLU: ||h|| <= ||hc + hr||
                    norm = np.minimum(norm, np.linalg.norm(habs, axis=1))
            else:
                norm = np.linalg.norm(hc @ P, axis=1)
                if not exact:
                    norm = norm + np.linalg.norm(hr, axis=1)
            out += norm[:, None] * r[None, :]
        else:
            raise ValueError(t[0])
    return out


def bounds(layers, X):
    """Interval bounds on the logits over all networks in K, plus the
    post-ReLU interval of the last hidden layer (for margin certificates)."""
    hc = X.astype(np.float64)
    hr = np.zeros_like(hc)
    exact = True
    for li, L in enumerate(layers[:-1]):
        c = hc @ L.W.T + L.b
        rad = hr @ np.abs(L.W).T + _sup_delta(L, hc, hr, exact) + L.eb
        rad = rad * (1 + EPS_REL) + EPS_ABS
        lo = np.maximum(c - rad, 0.0)
        hi = np.maximum(c + rad, 0.0)
        hc, hr = 0.5 * (lo + hi), 0.5 * (hi - lo)
        exact = False
    return hc, hr, exact


def certify(layers, X, y, chunk=4096):
    """Boolean array: True where every network in K predicts y at x."""
    out = np.zeros(X.shape[0], dtype=bool)
    last = layers[-1]
    for s in range(0, X.shape[0], chunk):
        Xs, ys = X[s:s + chunk], y[s:s + chunk]
        hc, hr, exact = bounds(layers, Xs)
        sup = _sup_delta(last, hc, hr, exact) + last.eb  # (N, out)
        if last.W.shape[0] == 1:
            sgn = (2 * ys - 1).astype(np.float64)
            center = (hc @ last.W.T + last.b)[:, 0] * sgn
            spread = (hr @ np.abs(last.W).T)[:, 0] + sup[:, 0]
            lower = center - spread * (1 + EPS_REL) - EPS_ABS
            out[s:s + chunk] = lower > 0
        else:
            # z_y - z_c >= (W_y - W_c) hc - |W_y - W_c| hr + b_y - b_c - sup_y - sup_c
            Wy = last.W[ys]                       # (N, in)
            by = last.b[ys]
            D = Wy[:, None, :] - last.W[None, :, :]   # (N, C, in)
            center = np.einsum("nci,ni->nc", D, hc) + by[:, None] - last.b[None, :]
            spread = np.einsum("nci,ni->nc", np.abs(D), hr)
            supy = sup[np.arange(len(ys)), ys]
            lower = center - spread - supy[:, None] - sup
            lower = lower - np.abs(lower) * EPS_REL - EPS_ABS
            lower[np.arange(len(ys)), ys] = np.inf
            out[s:s + chunk] = lower.min(axis=1) > 0
    return out


def contains(layers, F):
    """Does the network with weights F = [(W, b)] lie in K?"""
    for L, (W, b) in zip(layers, F):
        D = np.asarray(W, dtype=np.float64) - L.W
        if np.any(np.abs(np.asarray(b) - L.b) > L.eb):
            return False
        if not L.terms and np.any(D != 0):
            return False
        for t in L.terms:
            if t[0] == "box":
                if np.any(np.abs(D) > t[1]):
                    return False
            elif t[0] == "l2":
                r, P = t[1], t[2]
                nrm = np.linalg.norm(D if P is None else D @ P, axis=1)
                if np.any(nrm > r):
                    return False
    return True


def dct_basis(side=28):
    """Orthonormal 2-D DCT-II basis of R^(side*side), columns indexed by
    (u, v) frequency pairs; returns (B, freq) with B of shape (side^2, side^2)
    and freq[k] = u + v for column k."""
    n = side
    k = np.arange(n)
    C = np.sqrt(2.0 / n) * np.cos(np.pi * (k[None, :] + 0.5) * k[:, None] / n)
    C[0] /= np.sqrt(2.0)  # rows: frequency, columns: position
    B = np.kron(C, C).T   # (pixels, freqs); column (u*n + v)
    u, v = np.meshgrid(k, k, indexing="ij")
    return B, (u + v).ravel()


def dct_bands(edges, side=28):
    """List of orthonormal bases P_j (pixels x dim_j) for frequency bands
    edges[j] <= u+v < edges[j+1] (last band open-ended)."""
    B, freq = dct_basis(side)
    edges = list(edges) + [10 ** 9]
    return [B[:, (freq >= a) & (freq < b)] for a, b in zip(edges[:-1], edges[1:])]
