"""rBcommon: helpers for referee B's independent checks (sub-track "teacher").

Written independently of the prover's checks/tcommon.py; nothing is imported from checks/.

* exact log2 binomials and exact ceilings (integer arithmetic, no lgamma);
* the Elias delta code for positive integers (Kraft sum exactly 1);
* a rate code: q = 0 costs 1 bit; q = j / 2^b (j odd, 1 <= b <= BMAX) costs 1 + delta(b) + (b - 1) bits;
  Kraft sum = 1/2 + (1/2) sum_b 2^-delta(b) <= 1;
* exact Bernoulli fits (total bits) and the best rate at each precision;
* lambda-intervals by the O(|G| |P|) secant method (no convex-hull routine), so that a bug in a
  monotone-chain hull would not be shared.
"""
import math
from fractions import Fraction

LN2 = math.log(2)
BMAX = 14


def log2_int(x):
    """log2 of a positive integer, accurate for big integers."""
    if x <= 0:
        raise ValueError
    b = x.bit_length()
    if b <= 1000:
        return math.log2(x)
    shift = b - 64
    return math.log2(x >> shift) + shift


def log2comb(n, k):
    return log2_int(math.comb(n, k))


def ceil_log2_int(x):
    """exact ceil(log2 x) for an integer x >= 1."""
    return (x - 1).bit_length()


def ceil_log2comb(n, k):
    return ceil_log2_int(math.comb(n, k))


def delta_len(k):
    """Elias delta code length of an integer k >= 1."""
    assert k >= 1
    L = k.bit_length() - 1           # floor(log2 k)
    return L + 2 * ((L + 1).bit_length() - 1) + 1


def rate_len(b):
    """length of the rate code of a rate with precision b (b = 0 means q = 0)."""
    return 1 if b == 0 else 1 + delta_len(b) + (b - 1)


# Kraft checks (exact)
_kd = sum(Fraction(1, 2 ** delta_len(k)) for k in range(1, 1 << 12))
assert _kd <= 1
_kr = Fraction(1, 2) + sum(Fraction(2 ** (b - 1), 2 ** rate_len(b)) for b in range(1, 60))
assert _kr <= 1


def H(q):
    if q <= 0.0 or q >= 1.0:
        return 0.0
    return -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def bern_bits(k, n, q):
    """-log2 of q^k (1-q)^(n-k); inf if impossible."""
    if q == 0.0:
        return 0.0 if k == 0 else math.inf
    if q == 1.0:
        return 0.0 if k == n else math.inf
    return -(k * math.log2(q) + (n - k) * math.log2(1 - q))


def rate_options(k, n, below_half=True, bmax=BMAX):
    """[(code length, fit, q)]: q = 0 if possible, and the best odd j / 2^b for each b <= bmax
    (the fit is convex in q, so the best j is one of the odd neighbours of the empirical rate)."""
    out = []
    if k == 0:
        out.append((rate_len(0), 0.0, 0.0))
    for b in range(1, bmax + 1):
        M = 1 << b
        x = (k / n) * M if n > 0 else M / 2
        cands = set()
        for j in range(int(math.floor(x)) - 2, int(math.ceil(x)) + 3):
            if 1 <= j < M and j % 2 == 1:
                if below_half and 2 * j > M:
                    continue
                cands.add(j)
        if not cands:
            continue
        best = min((bern_bits(k, n, j / M), j / M) for j in cands)
        out.append((rate_len(b), best[0], best[1]))
    return out


def lambda_set(points, is_target, tol=1e-9):
    """points: list of (length, fit, desc) with finite fits. Returns the list of closed intervals
    [lo, hi] (lo >= 0) of lambda on which some target point is a lambda-MAP, computed point by point:
    a point P minimises lam*l + F iff lam >= (F_P - F_Q)/(l_Q - l_P) for every longer Q,
    lam <= (F_Q - F_P)/(l_P - l_Q) for every shorter Q, and F_P <= F_Q for every Q of equal length."""
    pts = [(l, f, d) for (l, f, d) in points if f < math.inf]
    ivs = []
    for (lP, fP, dP) in pts:
        if not is_target(dP):
            continue
        lo, hi, ok = 0.0, math.inf, True
        for (lQ, fQ, _) in pts:
            if lQ > lP:
                lo = max(lo, (fP - fQ) / (lQ - lP))
            elif lQ < lP:
                hi = min(hi, (fQ - fP) / (lP - lQ))
            elif fQ < fP - tol:
                ok = False
                break
        if ok and lo <= hi + tol:
            ivs.append((lo, hi, lP, fP, dP))
    return ivs


def union_span(ivs):
    """smallest and largest end of a list of intervals, and whether their union is one interval."""
    if not ivs:
        return None
    s = sorted((a, b) for (a, b, *_rest) in ivs)
    lo, hi = s[0]
    connected = True
    for a, b in s[1:]:
        if a > hi + 1e-9:
            connected = False
        hi = max(hi, b)
    return lo, hi, connected


def map_at(points, lam):
    """all lambda-MAP points (ties within 1e-9) at a given lambda."""
    vals = [(lam * l + f, l, f, d) for (l, f, d) in points if f < math.inf]
    best = min(v[0] for v in vals)
    return [v for v in vals if v[0] <= best + 1e-9]


def parity_table(a, d):
    import numpy as np
    x = np.arange(1 << d, dtype=np.int64)
    return (np.bitwise_count(x & a) & 1).astype(np.int8)
