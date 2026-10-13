"""tcommon: helpers shared by t2 and t3 (explicit prefix-coded product class, exact hulls).

Integer code g(k) = 2 floor(log2(k+1)) + 1 bits (Kraft sum 1 over k >= 0); rate code RC(q) = 1 bit
for q = 0, else 1 + g(b) + (b-1) bits for q = j/2^b with j odd and b <= BMAX (Kraft sum 3/4);
family tag 3 bits. Fits are total bits -log2 of the product likelihood.
"""
import math
import numpy as np

TAG = 3
BMAX = 12
LOG2 = math.log(2)


def gam(k):
    return 2 * int(math.floor(math.log2(k + 1))) + 1


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / LOG2


def rc_len(b):
    return 1 + gam(b) + (b - 1)


assert 0.5 + sum(2 ** (b - 1) * 2.0 ** -rc_len(b) for b in range(1, 200)) <= 1.0


def bern_fit(k, n, q):
    if q == 0.0:
        return 0.0 if k == 0 else math.inf
    if q == 1.0:
        return 0.0 if k == n else math.inf
    return -(k * math.log2(q) + (n - k) * math.log2(1 - q))


def best_rate_fits(k, n):
    """[(rate-code length, best fit, q)] over precisions b (and the deterministic flag)."""
    out = []
    if k == 0:
        out.append((1, 0.0, 0.0))
    for b in range(1, BMAX + 1):
        M = 2 ** b
        x = k / n * M if n > 0 else 0.5 * M
        cands = set()
        for j in (int(math.floor(x)), int(math.ceil(x)), int(math.floor(x)) - 1, int(math.ceil(x)) + 1):
            if j % 2 == 0:
                cands.update([j - 1, j + 1])
            else:
                cands.add(j)
        best = None
        for j in cands:
            if 1 <= j <= M - 1:
                f = bern_fit(k, n, j / M)
                if best is None or f < best[0]:
                    best = (f, j / M)
        out.append((rc_len(b), best[0], best[1]))
    return out


def wht(v):
    """unnormalised Walsh-Hadamard transform of a length-2^d numpy array (copy)."""
    a = v.astype(np.float64).copy()
    h = 1
    n = a.shape[0]
    while h < n:
        a = a.reshape(-1, 2 * h)
        x, y = a[:, :h].copy(), a[:, h:].copy()
        a[:, :h], a[:, h:] = x + y, x - y
        a = a.reshape(n)
        h *= 2
    return a


def parity_table(a, d):
    x = np.arange(2 ** d, dtype=np.int64)
    return (np.bitwise_count(x & a) & 1).astype(np.int8)


class Hull:
    """lower convex hull of (length, fit) points with descriptors; lambda-intervals of vertices."""

    def __init__(self):
        self.best = {}

    def add(self, l, f, desc):
        if f == math.inf:
            return
        if l not in self.best or f < self.best[l][0] - 1e-12:
            self.best[l] = (f, desc)

    def build(self):
        pts = sorted((l, f, desc) for l, (f, desc) in self.best.items())
        # Pareto filter
        par = []
        for l, f, desc in pts:
            if not par or f < par[-1][1] - 1e-12:
                par.append((l, f, desc))
        hull = []
        for q in par:
            while len(hull) >= 2:
                (l1, f1, _), (l2, f2, _) = hull[-2], hull[-1]
                # remove hull[-1] if it is on or above the segment hull[-2] -> q
                if (f2 - f1) * (q[0] - l1) >= (q[1] - f1) * (l2 - l1) - 1e-9:
                    hull.pop()
                else:
                    break
            hull.append(q)
        self.V = hull
        self.S = [(hull[i - 1][1] - hull[i][1]) / (hull[i][0] - hull[i - 1][0]) for i in range(1, len(hull))]
        return self

    def interval(self, i):
        hi = math.inf if i == 0 else self.S[i - 1]
        lo = 0.0 if i == len(self.V) - 1 else self.S[i]
        return lo, hi

    def map_at(self, lam):
        best = min(range(len(self.V)), key=lambda i: lam * self.V[i][0] + self.V[i][1])
        return self.V[best]

    def union_interval(self, pred):
        idx = [i for i in range(len(self.V)) if pred(self.V[i][2])]
        if not idx:
            return None
        lo = min(self.interval(i)[0] for i in idx)
        hi = max(self.interval(i)[1] for i in idx)
        # the union is an interval iff the indices are consecutive
        assert idx == list(range(idx[0], idx[-1] + 1))
        return lo, hi


def add_rate_family(hull, base_len, k, n, desc):
    for (rl, f, q) in best_rate_fits(k, n):
        hull.add(base_len + rl, f, desc + (q,))


