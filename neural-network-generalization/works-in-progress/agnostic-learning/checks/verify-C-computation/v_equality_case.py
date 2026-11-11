"""C6: at 2a + 2b + gamma*beta = 1 the bound of the separate-exponent remark (after Corollary C.2.2) tends to a positive
constant (L=3, gamma=1, eta=1/8: 32), while its stated O(.) majorant grows like log n."""
import numpy as np
def A_L(d, m, B, rho, L):
    b0 = 2 * np.sqrt(2 * (2 * np.log(9) + np.log(4 * L))); A0 = 2 + 3 * m * B + b0
    P0 = 1 + 2 * m * B * (d + L + 1) * A0 ** (L - 2); h = rho / (2 * P0)
    return 1 + 0.5 * (d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2) + (d + 2 + (L - 2) * m) * np.log(1 / (3 / 8 * h)) + np.log(2)
for (a, b, beta) in [(0.1, 0.1, 0.6), (0.2, 0.05, 0.5)]:
    vals = []
    for e in (10, 20, 30, 40):
        n = 10.0 ** e
        vals.append('n=1e%d: %.4f' % (e, 4 / n + (2 * n ** beta) * A_L(10, n ** a, n ** b, 1 / n, 3) / (0.125 * (n + 1))))
    print('a,b,beta=', a, b, beta, '2a+2b+beta=', 2 * a + 2 * b + beta, vals)
