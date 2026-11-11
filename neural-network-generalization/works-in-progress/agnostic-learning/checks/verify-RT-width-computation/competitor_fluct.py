"""How large is hat L(g) - L_D(g) for an admissible competitor of the 'In particular' class?

Explicit depth-3 (H = 2) tanh network of width m (even) with all weights in [-B, B]:
  layer 1: neuron 1 has row (B, 0, ..., 0) -> tanh(B) (constant); neurons 2..m have row (0, B, 0, ...) -> tanh(B x_1)
  layer 2: neurons 1..m/2 take weight B from neurons 2..m -> tanh(B (m-1) tanh(B x_1));
           neurons m/2+1..m take weight B from neuron 1 only -> tanh(B tanh B)
  readout: +B on the first half, -B on the second half.
So g(x) = (m/2) B [tanh(B(m-1)tanh(B x_1)) - tanh(B tanh B)]:  g ~ 0 at x_1 = +1 and g ~ -m B = -U at x_1 = -1.

Law D: x = (-1, 0, ..., 0) with probability p, x = (+1, 0, ..., 0) otherwise; y = 0.  Choose p = 1/(2 g1^2),
so L_D(g) ~ 1/2 <= 1.  Then hat L(g) = (K1 g1^2 + (n - K1) g0^2)/n with K1 ~ Bin(n, p): exact quantiles below.

We compare the 95% upper quantile of hat L(g) - L_D(g) with
  * U/sqrt(n)                         (Bernstein scale, n^{2 alpha - 1/2})
  * (U+1)^2 sqrt(ln(4/delta)/(2n))    (the Hoeffding term in Prop. 6.1, n^{4 alpha - 1/2})
  * the report's claimed excess rate n^{4 alpha - 1} + n^{alpha - 1/2} sqrt(ln n).
"""
import numpy as np
from scipy.stats import binom

delta = 0.05


def net_values(m, B, d=3):
    W1 = np.zeros((m, d + 1))
    W1[0, 0] = B
    W1[1:, 1] = B
    W2 = np.zeros((m, m))
    W2[: m // 2, 1:] = B
    W2[m // 2:, 0] = B
    v = np.concatenate([B * np.ones(m // 2), -B * np.ones(m // 2)])
    assert np.abs(W1).max() <= B and np.abs(W2).max() <= B and np.abs(v).max() <= B

    def g(x):
        xb = np.concatenate([[1.0], x])
        return v @ np.tanh(W2 @ np.tanh(W1 @ xb))

    x1 = np.zeros(d); x1[0] = -1.0
    x0 = np.zeros(d); x0[0] = +1.0
    # sup over the cube grid of |g| (sanity: should be <= U = m B)
    pts = np.array(np.meshgrid(*[np.linspace(-1, 1, 21)] * d)).reshape(d, -1).T
    sup = max(abs(g(x)) for x in pts)
    return g(x1), g(x0), sup


for alpha in (0.1, 0.2):
    for k in (6, 8, 10, 12):
        n = 10 ** k
        m = int(np.ceil(n ** alpha))
        m -= m % 2  # even width, still <= N = ceil(n^alpha)
        B = n ** alpha
        U = m * B
        g1, g0, sup = net_values(m, B)
        p = 1.0 / (2 * g1 ** 2)
        LD = p * g1 ** 2 + (1 - p) * g0 ** 2
        q95 = binom.ppf(0.95, n, p)
        dev95 = (q95 * g1 ** 2 + (n - q95) * g0 ** 2) / n - LD
        sd = np.sqrt(n * p * (1 - p)) * (g1 ** 2 - g0 ** 2) / n
        hoeff = (U + 1) ** 2 * np.sqrt(np.log(4 / delta) / (2 * n))
        bern = (U + 1) * np.sqrt(2 * LD * np.log(4 / delta) / n) + 2 * (U + 1) ** 2 * np.log(4 / delta) / (3 * n)
        claimed = n ** (4 * alpha - 1) + n ** (alpha - 0.5) * np.sqrt(np.log(n))
        print(f"alpha={alpha} n=1e{k:<2d} m={m:4d} B={B:8.2f} U={U:10.1f} |g(x1)|={abs(g1):10.2f} |g(x0)|={abs(g0):.1e} "
              f"sup|g|/U={sup/U:.3f} np={n*p:9.1f} L_D(g)={LD:.3f} | sd(hatL)={sd:.4f} U/sqrt(n)={U/np.sqrt(n):.4f} "
              f"q95 dev={dev95:.4f} Bernstein(1-delta/4)={bern:.4f} Hoeffding term={hoeff:.3g} claimed rate={claimed:.2e} "
              f"dev/claimed={dev95/claimed:.1f}")
