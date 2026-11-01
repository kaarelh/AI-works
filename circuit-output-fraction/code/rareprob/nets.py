"""Small ReLU MLPs trained to output a constant, as a test bed for rare-output
estimation on trained networks.

A net maps x in {-1,+1}^d to a real output f(x). Training uses uniform random
inputs and the constant target 1: either the squared loss (f(x) - 1)^2, where
the rare event is "the net does not output 1", [f(x) < 1/2], or the logistic
loss log(1 + e^{-f(x)}) on a logit, where the rare event is [f(x) < 0].

Everything is plain numpy (Adam, manual backpropagation). The exact failure
probability is computed by enumerating {-1,+1}^d in chunks (d <= 30).
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np


@dataclass
class MLP:
    """f(x) = w_L . relu(... relu(W_1 x + b_1) ...) + b_L."""

    Ws: list = field(default_factory=list)  # weight matrices, layer by layer
    bs: list = field(default_factory=list)
    threshold: float = 0.5  # the rare event is [f(x) < threshold]
    loss: str = "mse"

    @property
    def d(self) -> int:
        return self.Ws[0].shape[1]

    @property
    def widths(self) -> list[int]:
        return [W.shape[0] for W in self.Ws[:-1]]

    def forward(self, X: np.ndarray, keep: bool = False):
        """X: (N, d) array of +-1 (any real dtype). Returns f (N,), and the
        pre-activations of every hidden layer if keep."""
        h = np.asarray(X, dtype=np.float64)
        pre = []
        for W, b in zip(self.Ws[:-1], self.bs[:-1]):
            z = h @ W.T + b
            pre.append(z)
            h = np.maximum(z, 0.0)
        out = h @ self.Ws[-1].T + self.bs[-1]
        out = out[:, 0]
        return (out, pre) if keep else out

    def fails(self, X: np.ndarray) -> np.ndarray:
        return self.forward(X) < self.threshold

    def copy(self) -> "MLP":
        return MLP([W.copy() for W in self.Ws], [b.copy() for b in self.bs], self.threshold, self.loss)


def init_mlp(d: int, widths: list[int], rng: np.random.Generator, loss: str = "mse") -> MLP:
    """He initialisation; the output layer starts at scale 1/sqrt(width)."""
    sizes = [d] + list(widths) + [1]
    Ws, bs = [], []
    for i, (a, b) in enumerate(zip(sizes[:-1], sizes[1:])):
        scale = np.sqrt(2.0 / a) if i < len(sizes) - 2 else 1.0 / np.sqrt(a)
        Ws.append(rng.normal(0.0, scale, size=(b, a)))
        bs.append(np.zeros(b))
    return MLP(Ws, bs, threshold=0.5 if loss == "mse" else 0.0, loss=loss)


def _grads(net: MLP, X: np.ndarray):
    """Loss and gradients for a batch with target 1."""
    f, pre = net.forward(X, keep=True)
    N = X.shape[0]
    if net.loss == "mse":
        loss = float(np.mean((f - 1.0) ** 2))
        g = 2.0 * (f - 1.0) / N
    else:  # logistic loss on a logit, label 1
        loss = float(np.mean(np.logaddexp(0.0, -f)))
        g = -1.0 / (1.0 + np.exp(f)) / N
    gW, gb = [None] * len(net.Ws), [None] * len(net.bs)
    hs = [np.asarray(X, dtype=np.float64)] + [np.maximum(z, 0.0) for z in pre]
    delta = g[:, None]  # (N, 1)
    for k in range(len(net.Ws) - 1, -1, -1):
        gW[k] = delta.T @ hs[k]
        gb[k] = delta.sum(axis=0)
        if k > 0:
            delta = (delta @ net.Ws[k]) * (pre[k - 1] > 0)
    return loss, gW, gb


def train_constant(d: int, widths: list[int], steps: int, rng: np.random.Generator, loss: str = "mse",
                   lr: float = 1e-3, batch: int = 256, snapshots: tuple = (), weight_decay: float = 0.0):
    """Train on fresh uniform +-1 inputs with target 1 (Adam). Returns the final
    net and a dict {step: net copy} for the requested snapshot steps."""
    net = init_mlp(d, widths, rng, loss)
    params = net.Ws + net.bs
    m = [np.zeros_like(p) for p in params]
    v = [np.zeros_like(p) for p in params]
    b1, b2, eps = 0.9, 0.999, 1e-8
    snaps = {}
    for t in range(1, steps + 1):
        X = rng.choice([-1.0, 1.0], size=(batch, d))
        _, gW, gb = _grads(net, X)
        grads = gW + gb
        for i, (p, g) in enumerate(zip(params, grads)):
            if weight_decay and i < len(net.Ws):
                g = g + weight_decay * p
            m[i] = b1 * m[i] + (1 - b1) * g
            v[i] = b2 * v[i] + (1 - b2) * g * g
            p -= lr * (m[i] / (1 - b1 ** t)) / (np.sqrt(v[i] / (1 - b2 ** t)) + eps)
        if t in snapshots:
            snaps[t] = net.copy()
    return net, snaps


def all_inputs(d: int, start: int, stop: int) -> np.ndarray:
    """Rows start..stop-1 of the enumeration of {-1,+1}^d (bit i of the index is x_i)."""
    idx = np.arange(start, stop, dtype=np.int64)
    return np.where((idx[:, None] >> np.arange(d)) & 1, 1.0, -1.0)


def _half_inputs(k: int) -> np.ndarray:
    idx = np.arange(1 << k, dtype=np.int64)
    return np.where((idx[:, None] >> np.arange(k)) & 1, 1.0, -1.0)


def exact_failure_count(net: MLP, block: int = 1 << 16) -> int:
    """Number of x in {-1,+1}^d with f(x) < threshold (f evaluated in float64,
    as by MLP.forward). Meet in the middle on the first layer: with x = (u, v),
    W_1 x + b_1 = (W_u u + b_1) + W_v v, so the first-layer pre-activations of
    all 2^d inputs are sums of two precomputed tables."""
    d = net.d
    assert d <= 34, "enumeration too large"
    k1 = d // 2
    k2 = d - k1
    W, b = net.Ws[0], net.bs[0]
    A = _half_inputs(k1) @ W[:, :k1].T + b  # (2^k1, m)
    B = _half_inputs(k2) @ W[:, k1:].T  # (2^k2, m)
    rows = max(1, block // B.shape[0])
    total = 0
    for s in range(0, A.shape[0], rows):
        Z = (A[s:s + rows, None, :] + B[None, :, :]).reshape(-1, W.shape[0])
        h = np.maximum(Z, 0.0)
        for Wl, bl in zip(net.Ws[1:-1], net.bs[1:-1]):
            h = np.maximum(h @ Wl.T + bl, 0.0)
        out = h @ net.Ws[-1].T + net.bs[-1]
        total += int((out[:, 0] < net.threshold).sum())
    return total


def exact_failure_prob(net: MLP) -> float:
    return exact_failure_count(net) / float(1 << net.d)


def load_net(path: str) -> MLP:
    """Load a net saved by experiments/make_net_suite.py."""
    z = np.load(path)
    L = len([k for k in z.files if k.startswith("W")])
    return MLP([z[f"W{i}"] for i in range(L)], [z[f"b{i}"] for i in range(L)],
               threshold=float(z["threshold"]), loss=str(z["loss"]))
