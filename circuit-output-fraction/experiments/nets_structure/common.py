"""Shared helpers for the structure analysis of nets trained to output 1.

Only reads the repository's library (rareprob.nets); everything written goes to
experiments/nets_structure/results/.
"""

import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "code"))
from rareprob.nets import MLP, load_net, train_constant, _half_inputs  # noqa: E402,F401

NETS = os.path.join(ROOT, "experiments", "nets")
RES = os.path.join(HERE, "results")
os.makedirs(RES, exist_ok=True)


def suite():
    with open(os.path.join(NETS, "suite.json")) as fh:
        return json.load(fh)


def suite_net(name):
    return load_net(os.path.join(NETS, name + ".npz"))


def decode(idx, d):
    """Cube points for enumeration indices (bit i of idx is x_i, 1 -> +1)."""
    idx = np.asarray(idx, dtype=np.int64)
    return np.where((idx[:, None] >> np.arange(d)) & 1, 1.0, -1.0)


def encode(X):
    X = np.asarray(X)
    return ((X > 0).astype(np.int64) << np.arange(X.shape[1])).sum(axis=1)


def mitm_blocks(net, block=1 << 21):
    """Yield (global indices, f values) covering {-1,+1}^d exactly once, f in
    float64 as MLP.forward. First-layer pre-activations by meet in the middle."""
    d = net.d
    k1 = d // 2
    k2 = d - k1
    W, b = net.Ws[0], net.bs[0]
    A = _half_inputs(k1) @ W[:, :k1].T + b
    B = _half_inputs(k2) @ W[:, k1:].T
    rows = max(1, block // B.shape[0])
    ivs = (np.arange(1 << k2, dtype=np.int64) << k1)
    for s in range(0, A.shape[0], rows):
        r = min(rows, A.shape[0] - s)
        Z = (A[s:s + r, None, :] + B[None, :, :]).reshape(-1, W.shape[0])
        h = np.maximum(Z, 0.0)
        for Wl, bl in zip(net.Ws[1:-1], net.bs[1:-1]):
            h = np.maximum(h @ Wl.T + bl, 0.0)
        out = (h @ net.Ws[-1].T + net.bs[-1])[:, 0]
        gidx = (np.arange(s, s + r, dtype=np.int64)[:, None] + ivs[None, :]).reshape(-1)
        yield gidx, out


def all_f(net):
    """f on the whole cube, indexed by enumeration index (d <= 26 or so)."""
    f = np.empty(1 << net.d)
    for gidx, out in mitm_blocks(net):
        f[gidx] = out
    return f


def one_layer(net):
    """W (m,d), b (m,), a (m,), c for a one-hidden-layer net."""
    assert len(net.Ws) == 2
    return net.Ws[0], net.bs[0], net.Ws[1][0], float(net.bs[1][0])


def log10s(x):
    x = np.asarray(x, dtype=float)
    with np.errstate(divide="ignore"):
        return np.log10(x)


def save_json(obj, name):
    path = os.path.join(RES, name)
    with open(path + ".tmp", "w") as fh:
        json.dump(obj, fh, indent=1, default=float)
    os.replace(path + ".tmp", path)
    return path
