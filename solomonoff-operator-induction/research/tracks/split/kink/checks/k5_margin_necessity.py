"""k5: the margin is necessary (notes.md Prop 5.8): exact binomial computation.

Two programs on one input type (or a product class where only the rate matters): the truth
pi* = Bernoulli(p) with length l0 and a shorter non-equivalent program pi1 = Bernoulli(q) with
length l1 < l0.  For fixed lambda, pi* beats pi1 iff
    lambda*l0 + L(p) < lambda*l1 + L(q),   L(r) = -k log r - (n-k) log(1-r),  k ~ Bin(n, p).
We compute P[pi* beats pi1] exactly and compare the sample size where it reaches 1/2 and 0.95 with
  * the KL scale     n_KL  = lambda (l0 - l1) / KL(p||q)            (the mean crossing), and
  * the margin scale n_H   = lambda (l0 - l1) / (2 log2(e) Hel(p, q)) (Thm 5.4 / Cor 5.5 scale).
KL >= 2 log2(e) Hel, so n_KL <= n_H; the computation shows that the true threshold sits near n_KL
(between 0.70 and 1.01 times it), so
a sample size proportional to 1/(gap) is necessary, and the Hellinger margin overstates it by the
factor KL / (2 log2(e) Hel), which is bounded for these rates.
Deterministic.
"""
import math
from scipy.stats import binom

LOG2E = math.log2(math.e)


def KL(p, q):
    return p * math.log2(p / q) + (1 - p) * math.log2((1 - p) / (1 - q))


def Hel(p, q):
    return 1 - math.sqrt(p * q) - math.sqrt((1 - p) * (1 - q))


def p_win(n, p, q, l0, l1, lam):
    # pi* wins iff lam*(l0-l1) < L(q) - L(p) = k log(p/q) + (n-k) log((1-p)/(1-q))
    a, b = math.log2(p / q), math.log2((1 - p) / (1 - q))
    # L(q)-L(p) = k (a - b) + n b, increasing or decreasing in k
    thr = lam * (l0 - l1)
    if abs(a - b) < 1e-15:
        return 1.0 if n * b > thr else 0.0
    kstar = (thr - n * b) / (a - b)
    if a - b > 0:   # need k > kstar
        return float(binom.sf(math.floor(kstar), n, p))
    return float(binom.cdf(math.ceil(kstar) - 1, n, p))


def first_n(target, p, q, l0, l1, lam, nmax=10 ** 7):
    lo, hi = 1, 1
    while p_win(hi, p, q, l0, l1, lam) < target:
        hi *= 2
        if hi > nmax:
            return None
    # the win probability is not exactly monotone in n (lattice effects); report the first n on a
    # fine scan below the doubling point
    for n in range(max(1, hi // 2), hi + 1):
        if p_win(n, p, q, l0, l1, lam) >= target:
            return n
    return hi


print(f"{'p':>6} {'q':>8} {'l0-l1':>5} {'lambda':>6} | {'n(P=.5)':>8} {'n(P=.95)':>9} | {'n_KL':>9} {'n_H':>9} {'KL/(2log e Hel)':>15}")
for (p, q) in [(1 / 8, 1 / 4), (1 / 8, 3 / 16), (1 / 8, 5 / 32), (1 / 4, 1 / 2), (0.1, 0.11)]:
    for gap in [1, 3, 10]:
        for lam in [1.5, 2, 8]:
            n50 = first_n(0.5, p, q, gap, 0, lam)
            n95 = first_n(0.95, p, q, gap, 0, lam)
            nkl = lam * gap / KL(p, q)
            nh = lam * gap / (2 * LOG2E * Hel(p, q))
            print(f"{p:6.4f} {q:8.5f} {gap:5d} {lam:6.1f} | {str(n50):>8} {str(n95):>9} | {nkl:9.1f} {nh:9.1f} "
                  f"{KL(p, q) / (2 * LOG2E * Hel(p, q)):15.3f}")
