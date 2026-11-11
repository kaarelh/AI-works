import mpmath as mp, numpy as np
mp.mp.dps = 60
rng = np.random.default_rng(0)
worst = (0, None)
for _ in range(20000):
    H = int(rng.integers(2, 7)); R = mp.sqrt(2) + mp.mpf(rng.random()) * 10
    g = (mp.mpf(rng.random()) * 2 - 1) * 3
    y = mp.tanh(g / R ** (H - 1))
    for _j in range(2, H):
        y = mp.tanh(R * y)
    err = abs(R * y - g)
    bound = abs(g) ** 3 / 3 * sum(R ** (-2 * i) for i in range(1, H))
    r = err / bound
    if r > worst[0]:
        worst = (r, (H, float(R), float(g)))
print("60-digit max err/bound =", mp.nstr(worst[0], 15), worst[1])
