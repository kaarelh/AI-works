"""N3 on the full range c in [1/M, sqrt M] (the grid of rr_numbers.py stopped at M^{1/4}).
Worst case on the event of Lemma 1.3 for Proposition 5.3, lambda = 1, with the revised proof's Q <= M step:
bound = (sqrt(Q^-) - sqrt(c(2 sqrt(min(Q^+, M)) + 1) + n/(9 Q^-)))_+^2 / M.
Reports sup over the grid of (beta - K sqrt c M^{-1/4} - bound) M^{1/3} for K = 2 sqrt 3 and K = 4."""
import sys
sys.path.insert(0, '.')
import mpmath as mp
from rr_numbers_lib import bin_stats, beta_series
mp.mp.dps = 60
b1 = beta_series(1)
out = {}
for K, lab in ((2 * mp.sqrt(3), '2sqrt3'), (mp.mpf(4), '4')):
    worst, at = mp.mpf(-10), None
    for k in list(range(8, 61, 2)) + [80, 100, 120]:
        M, n, b, p = bin_stats(k)
        n23 = n ** (mp.mpf(2) / 3)
        Qm, Qp = M * b - 2 * n23, M * b + 2 * n23
        if Qm <= 0:
            continue
        for i in range(-8 * k, 4 * k + 1):
            c = mp.mpf(2) ** (mp.mpf(i) / 8)
            R = c * (2 * mp.sqrt(min(Qp, M)) + 1) + n / (9 * Qm)
            v = max(mp.sqrt(Qm) - mp.sqrt(R), 0) ** 2 / M
            C = (b1 - K * mp.sqrt(c) * M ** (-mp.mpf(1) / 4) - v) * M ** (mp.mpf(1) / 3)
            if C > worst:
                worst, at = C, (k, float(i) / 8)
    print("K = %s: sup (beta - K sqrt c M^-1/4 - bound) M^{1/3} = %s at (log2 M, log2 c) = %s" % (lab, mp.nstr(worst, 6), at))
