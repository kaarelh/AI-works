"""Prefix codes / priors for describing compressed networks.

A description is a sequence of self-delimiting fields.  Each field's length
is -log2 of a conditional probability under a sub-probability distribution
fixed before seeing the data, so the total length L(g) satisfies the Kraft
inequality over all descriptions and 2^-L(g) is a valid Occam prior.  We do
not round lengths up to integers: the Occam bound only needs sum_g 2^-L(g)
<= 1, which holds for -log2 of a product of conditional probabilities.

Fields used:
* `elias_delta(n)`: Elias delta code for integers n >= 1.
* `signed_int(z)`: zigzag map z -> 2z (z >= 0), -2z-1 (z < 0), then Elias delta.
* `subset(n, k)`: a k-subset of [n] given n: Elias delta for k+1 plus
  log2 C(n, k) (enumerative code).
* `kt_counts(counts)`: adaptive Krichevsky-Trofimov code for a sequence of
  N symbols over an alphabet of size K, given N and K.  Its length depends
  only on the symbol counts: -log2 [ prod_a G(n_a + 1/2)/G(1/2) * G(K/2)/G(N + K/2) ].
* `quantized(q)`: an integer array of known size: the range [min, max] as two
  signed integers, then a KT code over the range.
"""

import math
from collections import OrderedDict

import numpy as np
from scipy.special import gammaln

LN2 = math.log(2.0)


def elias_delta(n):
    n = int(n)
    if n < 1:
        raise ValueError("Elias delta needs n >= 1")
    nb = n.bit_length()  # floor(log2 n) + 1
    return (nb - 1) + 2 * ((nb).bit_length() - 1) + 1


def signed_int(z):
    z = int(z)
    zz = 2 * z if z >= 0 else -2 * z - 1
    return elias_delta(zz + 1)


def log2_binom(n, k):
    return float((gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1)) / LN2)


def subset(n, k):
    return elias_delta(k + 1) + log2_binom(n, k)


def kt_counts(counts):
    counts = np.asarray(counts, dtype=np.float64)
    K = counts.size
    N = counts.sum()
    if K <= 1 or N == 0:
        return 0.0
    lp = (np.sum(gammaln(counts + 0.5)) - K * gammaln(0.5)
          + gammaln(K / 2.0) - gammaln(N + K / 2.0))
    return float(-lp / LN2)


def quantized(q):
    """Bits for an integer array whose shape is already known to the decoder."""
    q = np.asarray(q).astype(np.int64).ravel()
    if q.size == 0:
        return 0.0
    lo, hi = int(q.min()), int(q.max())
    bits = signed_int(lo) + elias_delta(hi - lo + 1)
    counts = np.bincount(q - lo, minlength=hi - lo + 1)
    return bits + kt_counts(counts)


def sparse_quantized(q):
    """Bits for an integer array of known shape that is mostly zeros:
    the support as a subset, then the nonzero values with a KT code."""
    q = np.asarray(q).astype(np.int64).ravel()
    nz = np.flatnonzero(q)
    bits = subset(q.size, nz.size)
    if nz.size:
        bits += quantized(q[nz])
    return bits


def best_tensor_code(q):
    """min over the dense and sparse codes, plus one bit saying which."""
    return 1.0 + min(quantized(q), sparse_quantized(q))


def log_grid_scalar(x, per_octave=4):
    """Code a positive scalar rounded to the grid 2^(e/per_octave), e integer.

    Returns (rounded value, bits)."""
    e = int(round(per_octave * math.log2(x)))
    return 2.0 ** (e / per_octave), signed_int(e)


def uniform_choice(num_options):
    return math.log2(num_options)


class Description:
    """Accumulates the fields of a description with a named breakdown."""

    def __init__(self):
        self.fields = OrderedDict()

    def add(self, name, bits):
        bits = float(bits)
        if bits < 0:
            raise ValueError(f"negative code length for {name}")
        self.fields[name] = self.fields.get(name, 0.0) + bits
        return self

    @property
    def bits(self):
        return float(sum(self.fields.values()))

    def summary(self):
        return {k: round(v, 2) for k, v in self.fields.items()}
