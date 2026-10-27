"""Checks of the tail inversions and the code lengths."""
import math

import numpy as np
from scipy.stats import beta, binom

from cgb import coding
from cgb.bounds import binom_upper, cp_upper, kl_bern, kl_upper, occam_bound, occam_bound_kl


def test_cp_matches_beta_quantile():
    for k, n, d in [(0, 50, 0.05), (3, 100, 0.05), (40, 1000, 0.01), (500, 60000, 0.05)]:
        ref = 1.0 if k == n else beta.ppf(1 - d, k + 1, n - k)
        assert abs(cp_upper(k, n, d) - ref) < 1e-7


def test_binom_upper_definition():
    # P[Bin(n, p*) <= k] = alpha at the returned p*
    for k, n, la in [(5, 200, math.log(1e-3)), (100, 5000, -50.0), (0, 1000, -200.0)]:
        p = binom_upper(k, n, la)
        assert abs(math.log(binom.cdf(k, n, p)) - la) < 1e-5 or p >= 1.0


def test_occam_le_kl_and_monotone():
    for k, n, L in [(0, 1000, 50), (20, 5000, 500), (300, 60000, 20000)]:
        a = occam_bound(k, n, L, 0.05)
        b = occam_bound_kl(k, n, L, 0.05)
        assert a <= b + 1e-12
        assert occam_bound(k, n, L + 10, 0.05) >= a
        assert occam_bound(k + 1, n, L, 0.05) >= a


def test_kl_upper_inverts():
    for q, c in [(0.0, 0.1), (0.05, 0.02), (0.3, 0.5)]:
        p = kl_upper(q, c)
        assert p >= q and abs(kl_bern(q, p) - c) < 1e-6


def test_elias_delta_kraft():
    s = sum(2.0 ** -coding.elias_delta(n) for n in range(1, 200000))
    assert s < 1.0


def test_signed_int_kraft():
    s = sum(2.0 ** -coding.signed_int(z) for z in range(-100000, 100000))
    assert s < 1.0


def test_kt_is_a_probability():
    # sum over all binary sequences of length N of 2^-KT = 1
    N = 10
    tot = 0.0
    for ones in range(N + 1):
        tot += math.comb(N, ones) * 2.0 ** -coding.kt_counts([N - ones, ones])
    assert abs(tot - 1.0) < 1e-9
    # ternary, N = 6
    tot = 0.0
    for a in range(7):
        for b in range(7 - a):
            c = 6 - a - b
            tot += math.factorial(6) / (math.factorial(a) * math.factorial(b) * math.factorial(c)) * \
                2.0 ** -coding.kt_counts([a, b, c])
    assert abs(tot - 1.0) < 1e-9


def test_subset_code_is_a_probability_given_n():
    n = 12
    tot = sum(math.comb(n, k) * 2.0 ** -coding.subset(n, k) for k in range(n + 1))
    assert tot <= 1.0 + 1e-12


def test_quantized_close_to_entropy():
    rng = np.random.default_rng(0)
    q = rng.integers(-3, 4, size=20000)
    bits = coding.quantized(q)
    assert bits < 20000 * math.log2(7) + 100


if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn()
            print("ok", name)
