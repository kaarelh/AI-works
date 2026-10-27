"""Datasets: Boolean targets on the uniform hypercube, and MNIST-style images."""

import gzip
import os

import numpy as np

DATA_DIR = os.environ.get("CGB_DATA", "/home/user/data")


# ----------------------------------------------------------------------------
# Boolean targets.  Inputs are in {-1, +1}^n, labels in {0, 1}.
# ----------------------------------------------------------------------------

def uniform_cube(n, N, rng):
    return rng.integers(0, 2, size=(N, n), dtype=np.int8) * 2 - 1


def all_inputs(n):
    """All 2^n points of {-1,+1}^n, as an int8 array (row i = binary of i)."""
    idx = np.arange(2 ** n, dtype=np.int64)
    bits = (idx[:, None] >> np.arange(n)[None, :]) & 1
    return (bits * 2 - 1).astype(np.int8)


class BooleanTarget:
    """A target function given by a name, the relevant coordinates and a rule."""

    def __init__(self, name, n, coords, rule, table=None):
        self.name = name
        self.n = n
        self.coords = np.asarray(coords, dtype=np.int64)
        self.rule = rule
        self.table = table

    def __call__(self, X):
        Z = X[:, self.coords].astype(np.int64)
        k = Z.shape[1]
        if self.rule == "parity":
            return (np.prod(Z, axis=1) < 0).astype(np.int64)
        if self.rule == "majority":
            return (Z.sum(axis=1) > 0).astype(np.int64)  # k odd
        if self.rule == "and":
            return np.all(Z > 0, axis=1).astype(np.int64)
        if self.rule == "table":
            idx = ((Z > 0).astype(np.int64) << np.arange(k)[None, :]).sum(axis=1)
            return self.table[idx]
        if self.rule == "threshold":  # sum of relevant bits >= 2
            return (Z.sum(axis=1) >= 2).astype(np.int64)
        raise ValueError(self.rule)


def make_target(name, n, seed=0):
    """Named targets.  Relevant coordinates are a fixed random subset."""
    rng = np.random.default_rng(1000 + seed)
    perm = rng.permutation(n)
    if name.startswith("parity"):
        k = int(name[len("parity"):])
        return BooleanTarget(name, n, perm[:k], "parity")
    if name.startswith("maj"):
        k = int(name[len("maj"):])
        coords = np.arange(n) if k == n else perm[:k]
        return BooleanTarget(name, n, coords, "majority")
    if name.startswith("and"):
        k = int(name[len("and"):])
        return BooleanTarget(name, n, perm[:k], "and")
    if name.startswith("junta"):
        k = int(name[len("junta"):])
        table = rng.integers(0, 2, size=2 ** k)
        return BooleanTarget(name, n, perm[:k], "table", table=table)
    if name == "fullmaj":
        return BooleanTarget(name, n, np.arange(n), "majority")
    raise ValueError(name)


# ----------------------------------------------------------------------------
# MNIST / Fashion-MNIST (idx format, gzip).
# ----------------------------------------------------------------------------

def _read_idx(path):
    with gzip.open(path, "rb") as fh:
        data = fh.read()
    magic = int.from_bytes(data[0:4], "big")
    ndim = magic & 0xFF
    dims = [int.from_bytes(data[4 + 4 * i: 8 + 4 * i], "big") for i in range(ndim)]
    return np.frombuffer(data, dtype=np.uint8, offset=4 + 4 * ndim).reshape(dims)


def load_images(name="mnist"):
    """Returns (Xtr, ytr, Xte, yte); X float32 in [0,1] of shape (N, 784)."""
    d = os.path.join(DATA_DIR, name)
    Xtr = _read_idx(os.path.join(d, "train-images-idx3-ubyte.gz"))
    ytr = _read_idx(os.path.join(d, "train-labels-idx1-ubyte.gz"))
    Xte = _read_idx(os.path.join(d, "t10k-images-idx3-ubyte.gz"))
    yte = _read_idx(os.path.join(d, "t10k-labels-idx1-ubyte.gz"))
    f = lambda X: (X.reshape(X.shape[0], -1).astype(np.float32) / 255.0)
    return f(Xtr), ytr.astype(np.int64), f(Xte), yte.astype(np.int64)
