"""Remark 6(b) of small-learner-width.md: an admissible competitor whose empirical loss fluctuates at scale U/sqrt(n).

Competitor (depth 3, d = 1, width m = ceil(n^a), all weights in [0, B], B = n^a):
first-layer rows (0, B), internal weights B, readout weights B, so g(x) = mB tanh(mB tanh(Bx)).
Law: x = 1 with probability p = 1/(G+1)^2 and label -1, where G = g(1); otherwise x = 0 with label 0.
Then L_D(g) = 1 and hat L(g) = (G+1)^2 Bin(n,p)/n. We print exact binomial upper quantiles of hat L(g) - L_D(g),
(G+1)/sqrt(n), the Bernstein term at level q, and the withdrawn rate n^(4a-1) + n^(a-1/2) sqrt(ln n) of red-team.md.
Run: python3 check_competitor_fluct.py > check_competitor_fluct.out
"""
import numpy as np
from scipy import stats

for a in [0.1, 0.15, 0.2]:
    for logn in [8, 10, 12, 14]:
        n = 10**logn
        m = int(np.ceil(n**a)); B = n**a
        G = m * B * np.tanh(m * B * np.tanh(B))
        p = 1 / (G + 1) ** 2
        rate = n ** (4 * a - 1) + n ** (a - 0.5) * np.sqrt(np.log(n))
        out = []
        for q in [0.05, 0.0125]:
            k = stats.binom.isf(q, n, p)  # smallest k with P(K > k) <= q
            dev = (G + 1) ** 2 * k / n - 1.0
            bern = (G + 1) * np.sqrt(2 * 1.0 * np.log(1 / q) / n) + 2 * (G + 1) ** 2 * np.log(1 / q) / (3 * n)
            out.append("q=%.4f: quantile %.3e, Bernstein %.3e" % (q, dev, bern))
        print("a=%.2f n=1e%d U=mB=%.3e G=%.3e (G+1)/sqrt(n)=%.3e red-team rate=%.3e | %s | quantile(0.05)/rate=%.1f"
              % (a, logn, m * B, G, (G + 1) / np.sqrt(n), rate, " ; ".join(out),
                 ((G + 1) ** 2 * stats.binom.isf(0.05, n, p) / n - 1) / rate))
