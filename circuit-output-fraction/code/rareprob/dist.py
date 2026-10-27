"""Product distributions on {0,1}^n."""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from .circuit import pack_rows

def _bernoulli(q: np.ndarray, U: np.ndarray, rng: np.random.Generator) -> np.ndarray:
    """[V < q] exactly, for V uniform on [0, 1) whose first 53 binary digits
    are given by U (uniform on the grid 2^-53 Z, as rng.random() returns)
    and whose later digits are drawn here when needed; q broadcasts against
    U. With s = q 2^53 = m + f (m an integer, 0 <= f < 1, both exact in
    floating point): V < q iff U < m 2^-53, or U = m 2^-53 and the rest of V,
    uniform on [0, 1), is below f. The tie has probability 2^-53 and f has
    53 fewer significant digits than q, so the recursion ends after at most
    21 levels."""
    s = np.ldexp(q, 53)
    m = np.floor(s)
    f = s - m
    qf = np.ldexp(m, -53)
    X = U < qf
    T = (U == qf) & (f > 0)
    if T.any():
        fT = np.broadcast_to(f, U.shape)[T]
        X[T] = _bernoulli(fT, rng.random(fT.size), rng)
    return X


@dataclass
class Product:
    """x_i independent with Pr[x_i = 1] = q[i].

    sample() draws exactly from this law: x_i = [V_i < q_i] for a uniform
    V_i in [0, 1) whose 53-bit digits are drawn lazily and compared with
    those of q_i (a float has finitely many binary digits), so Pr[x_i = 1] is
    exactly q_i, not q_i rounded up to the grid 2^-53 Z."""

    q: np.ndarray

    def __post_init__(self):
        q = np.array(self.q, dtype=float)
        # explicit check (an assert would vanish under python -O); NaN fails it
        if q.ndim != 1 or not np.all((q >= 0.0) & (q <= 1.0)):
            raise ValueError("Product: marginals must be a vector of numbers in [0, 1]")
        self.q = q

    @classmethod
    def uniform(cls, n: int) -> "Product":
        return cls(np.full(n, 0.5))

    @property
    def n(self) -> int:
        return len(self.q)

    def lit_prob(self, i: int, b: int) -> float:
        return float(self.q[i] if b else 1.0 - self.q[i])

    def sample(self, N: int, rng: np.random.Generator) -> np.ndarray:
        """N exact samples, an (N, n) bool array."""
        N = max(int(N), 0)
        return _bernoulli(self.q, rng.random((N, self.n)), rng)

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
