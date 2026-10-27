"""Exact output probabilities by enumeration (small n), for testing."""

from __future__ import annotations

import numpy as np

from .circuit import Circuit, unpack_bits
from .dist import Product


def all_inputs_packed(n: int) -> np.ndarray:
    """Packed (n, 2^n/64) array enumerating {0,1}^n (n >= 6)."""
    assert n >= 6
    N = 1 << n
    idx = np.arange(N, dtype=np.uint64)
    rows = []
    for i in range(n):
        bits = ((idx >> np.uint64(i)) & np.uint64(1)).astype(bool)
        rows.append(np.packbits(bits.reshape(-1, 64), axis=1, bitorder="little").view(np.uint64).ravel())
    return np.stack(rows)


def exact_prob(C: Circuit, D: Product | None = None, max_n: int = 26) -> float:
    n = C.n
    assert n <= max_n, "enumeration too large"
    if n < 6:
        X = ((np.arange(1 << n)[:, None] >> np.arange(n)) & 1).astype(bool)
        y = C.eval_bits(X)
        w = np.ones(len(X)) / len(X) if D is None else D.pmf(X)
        return float((w * y).sum())
    out = C.eval_packed(all_inputs_packed(n))
    N = 1 << n
    if D is None or np.all(D.q == 0.5):
        return int(np.unpackbits(out.view(np.uint8)).sum()) / N
    y = unpack_bits(out, N)
    ids = np.nonzero(y)[0]
    X = ((ids[:, None] >> np.arange(n)) & 1).astype(bool)
    return float(D.pmf(X).sum())
