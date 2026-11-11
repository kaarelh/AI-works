"""Gaussian translation inequality with the exact normal CDF (mpmath, 50 digits):
   P(E + a) >= P(E) exp(-a^2/2) for E = [-s, s] and E = [-s2,-s1] u [s1,s2]; the ratio tends to 1 as s -> 0 (equality limit)."""
import mpmath as mp, numpy as np
mp.mp.dps = 50
rng = np.random.default_rng(8)
Phi = lambda x: mp.ncdf(x)
worst = mp.inf; arg = None
for _ in range(20000):
    a = mp.mpf(rng.uniform(-4, 4))
    if rng.uniform() < 0.5:
        s = mp.mpf(np.exp(rng.uniform(np.log(1e-6), np.log(5))))
        lhs = Phi(a + s) - Phi(a - s); base = Phi(s) - Phi(-s)
    else:
        s1, s2 = sorted(rng.uniform(0, 5, 2)); s1 = mp.mpf(s1); s2 = mp.mpf(s2)
        lhs = (Phi(a - s1) - Phi(a - s2)) + (Phi(a + s2) - Phi(a + s1)); base = 2 * (Phi(s2) - Phi(s1))
    r = lhs / (base * mp.e ** (-a * a / 2))
    if r < worst: worst, arg = r, (float(a),)
print(f"min ratio over 20000 random symmetric sets = {mp.nstr(worst, 20)}  (>= 1 required; -> 1 as s -> 0)")
