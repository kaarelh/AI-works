"""Size of the competitor term hat L(g) - L_D(g) for a competitor in the stated class.

The proof of redteam.md Prop. 6.1 runs the chain
   L_D(clip z_w) <= ... <= hat L(g) + c(E*+1)/n + ... <= L_D(g) + [hat L(g) - L_D(g)] + ...
so its rate can be no better than the upper (1-delta)-quantile of hat L(g) - L_D(g), uniformly over
the class.  Example in the class (L = 3, d = 1, X = {0,1}):
   first-layer rows (0, B), internal weights B, readout weights B, width m:
   g(x) = m B tanh(m B tanh(B x)),  g(0) = 0,  G := g(1) ~ mB.
Law D: x = 1 with prob p = 1/(G+1)^2 and y = -1; x = 0 otherwise and y = 0.  Then L_D(g) = 1 and the
loss is (G+1)^2 * Bernoulli(p).  We compute the exact binomial quantile.
"""
import math
from scipy.stats import binom

delta = 0.05
L = 3
print(f"delta = {delta}; columns: n, alpha, G=g(1), exact (1-delta)-quantile of hatL(g)-L_D(g), "
      f"(G+1)/sqrt(n), Hoeffding term, Bernstein term, claimed rate n^(4a-1)+n^(a-1/2)sqrt(ln n)")
for alpha in [0.1, 0.15, 0.2]:
    for e in [8, 10, 12, 14]:
        n = 10 ** e
        m = math.ceil(n ** alpha)
        B = n ** alpha
        G = m * B * math.tanh(m * B * math.tanh(B))
        p = 1.0 / (G + 1) ** 2
        k = binom.ppf(1 - delta, n, p)  # (1-delta)-quantile of the count at x = 1
        dev = (G + 1) ** 2 * (k / n - p)
        hoeff = (G + 1) ** 2 * math.sqrt(math.log(4 / delta) / (2 * n))
        bern = (G + 1) * math.sqrt(8 * math.log(4 / delta) / n) + 2 * (G + 1) ** 2 * math.log(4 / delta) / (3 * n)
        claimed = n ** (4 * alpha - 1) + n ** (alpha - 0.5) * math.sqrt(math.log(n))
        print(f"n=1e{e:<3d} a={alpha:<5} G={G:10.3e} quantile={dev:10.3e} (G+1)/sqrt(n)={(G+1)/math.sqrt(n):10.3e} "
              f"hoeff={hoeff:10.3e} bern={bern:10.3e} claimed={claimed:10.3e}  quantile/claimed={dev/claimed:8.2f}")
    print()
