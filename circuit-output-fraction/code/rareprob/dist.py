"""Product distributions on {0,1}^n."""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from .circuit import pack_rows


@dataclass
class Product:
    """x_i independent with Pr[x_i = 1] = q[i]."""

    q: np.ndarray

    def __post_init__(self):
        self.q = np.asarray(self.q, dtype=float)
        assert np.all((self.q >= 0) & (self.q <= 1))

    @classmethod
    def uniform(cls, n: int) -> "Product":
        return cls(np.full(n, 0.5))

    @property
    def n(self) -> int:
        return len(self.q)

    def lit_prob(self, i: int, b: int) -> float:
        return float(self.q[i] if b else 1.0 - self.q[i])

    def sample(self, N: int, rng: np.random.Generator) -> np.ndarray:
        return rng.random((N, self.n)) < self.q

    def sample_packed(self, N: int, rng: np.random.Generator) -> np.ndarray:
        """Packed (n, ceil(N/64)) uint64 sample; bits beyond N are junk."""
        W = (N + 63) // 64
        if np.all(self.q == 0.5):
            return rng.integers(0, 2**64, size=(self.n, W), dtype=np.uint64)
        return pack_rows(self.sample(W * 64, rng))

    def pmf(self, X: np.ndarray) -> np.ndarray:
        X = np.asarray(X, dtype=bool)
        return np.exp(self.logpmf(X))

    def logpmf(self, X: np.ndarray) -> np.ndarray:
        X = np.asarray(X, dtype=bool)
        with np.errstate(divide="ignore"):
            lq = np.log(self.q)
            l1q = np.log1p(-self.q)
        return np.where(X, lq, l1q).sum(axis=-1)
