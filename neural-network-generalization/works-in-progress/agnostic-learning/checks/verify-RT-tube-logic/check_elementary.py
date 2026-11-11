"""Random checks of the elementary implications used in redteam.md Prop. 4.1.

(1) Cover step:  |z_i - y_i| < rho, |y_i - g_i| <= rho0, |z - h| <= a
      ==>  |h_i - g_i| < rho + rho0 + a      (no training input in A_h)
(2) Cover step:  |z - g| > tau, |z - h| <= a, 2a < tau - rho - rho0
      ==>  |h - g| > rho + rho0 + a          (test error lies in A_h)
(3) Risk step:   |y| <= 1, |y - g| <= rho0
      ==>  (clip z - y)^2 <= min{4, (|z - g| + rho0)^2}
(4) For the sharpened bound: |(clip u - y)^2 - (clip u' - y)^2| <= 4 |u - u'|, |y|<=1
(5) Denominator: sup|z - g| < rho - rho0 and |y_i - g_i| <= rho0 ==> |z_i - y_i| < rho
"""
import numpy as np
rng = np.random.default_rng(0)
T = 2_000_000
clip = lambda u: np.clip(u, -1.0, 1.0)

rho0 = rng.uniform(0, 1.5, T)
rho = rho0 + rng.uniform(1e-6, 1.5, T)
tau = rho + rho0 + rng.uniform(1e-6, 2.0, T)
a = rng.uniform(0, 1, T) * (tau - rho - rho0) / 2 * (1 - 1e-9)   # 2a < tau-rho-rho0

# (1)
g = rng.uniform(-3, 3, T)
y = g + rng.uniform(-1, 1, T) * rho0
z = y + rng.uniform(-1, 1, T) * rho * (1 - 1e-12)
h = z + rng.uniform(-1, 1, T) * a
viol1 = np.sum(~(np.abs(h - g) < rho + rho0 + a))
print("(1) violations:", viol1)

# (2)
g = rng.uniform(-3, 3, T)
s = rng.choice([-1, 1], T)
z = g + s * (tau + rng.uniform(1e-9, 3, T))
h = z + rng.uniform(-1, 1, T) * a
viol2 = np.sum(~(np.abs(h - g) > rho + rho0 + a))
print("(2) violations:", viol2)

# (3)
y = rng.uniform(-1, 1, T)
rho0b = rng.uniform(0, 2, T)
g = y + rng.uniform(-1, 1, T) * rho0b
z = rng.uniform(-5, 5, T)
lhs = (clip(z) - y) ** 2
rhs = np.minimum(4.0, (np.abs(z - g) + rho0b) ** 2)
print("(3) violations:", np.sum(lhs > rhs + 1e-12), " max lhs-rhs:", np.max(lhs - rhs))

# (4)
u = rng.uniform(-4, 4, T); up = rng.uniform(-4, 4, T); y = rng.uniform(-1, 1, T)
d4 = np.abs((clip(u) - y) ** 2 - (clip(up) - y) ** 2) - 4 * np.abs(u - up)
print("(4) violations:", np.sum(d4 > 1e-12), " max:", np.max(d4))

# (5)
g = rng.uniform(-3, 3, T)
y = g + rng.uniform(-1, 1, T) * rho0
z = g + rng.uniform(-1, 1, T) * (rho - rho0) * (1 - 1e-12)
print("(5) violations:", np.sum(~(np.abs(z - y) < rho)))
