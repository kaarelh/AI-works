"""Referee numerical checks of small claims in the theory sections.

1. Theorem 3, step 6: E[K] = m (h(eta) + eta log2(nq)) <= 8 eps m log2(en/(4 eps)) for
   eta = 8 eps, q = 2, and the resulting constant in Q >= n E[K] / (32 eps log2(en/(4 eps))).
2. Theorem 3, 'fixed humans' remark: how large m must be for Pr[K > 2 E[K]] <= eps,
   computed exactly from the binomial law of the number of problems with an insight.
3. Theorem 7: the total count of human queries with B = ceil(1/eps), compared with
   K (log(K/delta) + log(n/eps)).

Usage: python3 referee_theory_checks.py  (writes referee_theory_checks.out)
"""

import math
import os

import numpy as np
from math import comb, log2

HERE = os.path.dirname(os.path.abspath(__file__))


def h(x):
    return -x * log2(x) - (1 - x) * log2(1 - x)


def binom_sf(m, p, k):
    """Pr[Bin(m, p) > k], exactly, in log space."""
    tot = 0.0
    for j in range(k + 1, m + 1):
        tot += math.exp(math.lgamma(m + 1) - math.lgamma(j + 1) - math.lgamma(m - j + 1)
                        + j * math.log(p) + (m - j) * math.log1p(-p))
    return tot


def main():
    out = []
    out.append("## 1. E[K] bound in Theorem 3 (eta = 8 eps, q = 2)\n")
    out.append("| eps | n | E[K]/m | 8 eps log2(en/(4eps)) | ratio |")
    out.append("|---|---|---|---|---|")
    for eps in [1 / 16, 1 / 32, 1 / 100, 1 / 1000]:
        for n in [2, 16, 1024]:
            eta = 8 * eps
            ek = h(eta) + eta * log2(2 * n)
            bd = 8 * eps * log2(math.e * n / (4 * eps))
            assert ek <= bd + 1e-12
            out.append(f"| {eps:.4g} | {n} | {ek:.4f} | {bd:.4f} | {ek/bd:.3f} |")
    out.append("\nThe bound holds in every case (it uses h(x) <= x log2(e/x)).\n")

    out.append("## 2. 'Fixed humans': smallest m with Pr[K > 2E[K]] <= eps\n")
    out.append("K = N log2(nq/eta) + (m - N) log2(1/(1-eta)) with N ~ Bin(m, eta). "
               "Smallest m (searched over a grid) for which the exact tail is at most eps, "
               "and the corresponding E[K].\n")
    out.append("| eps | n | smallest m | E[K] at that m (bits) |")
    out.append("|---|---|---|---|")
    for eps in [1 / 16, 1 / 32, 1 / 100]:
        for n in [16, 1024]:
            eta, q = 8 * eps, 2
            a, b = log2(n * q / eta), log2(1 / (1 - eta))
            found = None
            for m in list(range(2, 200)) + list(range(200, 20001, 25)):
                ek = m * (h(eta) + eta * log2(n * q))
                # K > 2 E[K]  <=>  N (a - b) + m b > 2 ek  <=>  N > (2 ek - m b)/(a - b)
                kmax = math.floor((2 * ek - m * b) / (a - b))
                if binom_sf(m, eta, kmax) <= eps:
                    found = (m, ek)
                    break
            out.append(f"| {eps:.4g} | {n} | {found[0]} | {found[1]:.0f} |")
    out.append("\nSo 'm large' means m of order ln(1/eps)/eta (or smaller); the remark is right "
               "but the fixed-human version of the lower bound only applies to humans of at "
               "least this complexity.\n")

    out.append("## 3. Theorem 7 query count with B = ceil(1/eps)\n")
    out.append("Worst case allowed by Theorem 7(b): sum_{i <= K+1} m_i batch checks + "
               "K ceil(log2 B) halving batch checks + K ceil(log2 n) single checks + K task "
               "queries; every batch check covers B final states.\n")
    out.append("| K | n | eps | delta | human queries (bound) | K(log2(K/delta)+log2(n/eps)) | states the human looks at in batches |")
    out.append("|---|---|---|---|---|---|---|")
    for K, n, eps, delta in [(100, 64, 0.01, 0.01), (1000, 1024, 0.001, 0.01), (10**4, 10**4, 1e-3, 1e-3)]:
        B = math.ceil(1 / eps)
        mi = [math.ceil(math.log(i * (i + 1) / delta) / (eps * B)) for i in range(1, K + 2)]
        batch = sum(mi) + K * math.ceil(log2(B))
        total = batch + K * math.ceil(log2(n)) + K
        ref = K * (log2(K / delta) + log2(n / eps))
        out.append(f"| {K} | {n} | {eps} | {delta} | {total:,} | {ref:,.0f} | {batch * B:,} |")
    out.append("\nThe O(K (log(K/delta) + log(n/eps))) count of Theorem 7 is right, but each "
               "batch check is a look at ceil(1/eps) results, so the number of results the human "
               "inspects is of order K log(K/delta)/eps.\n")

    text = "\n".join(out)
    print(text)
    with open(os.path.join(HERE, "referee_theory_checks.out"), "w") as f:
        f.write(text + "\n")


if __name__ == "__main__":
    main()
