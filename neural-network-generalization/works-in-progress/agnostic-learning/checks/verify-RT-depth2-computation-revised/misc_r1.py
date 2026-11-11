"""Small scalar checks: alternating binomial identity, u_m >= 1/(2 sqrt m), Hoeffding failure frequency in Lemma 2.1 Step 3,
and the first d at which the c=1 bound reaches 2 eps_d when a = 1/d (the corollary's recommended accuracy) instead of a = 1/n."""
from math import comb, sqrt, log, ceil
import numpy as np, mpmath as mp
import sys; sys.path.insert(0, '.')
from t51_r1 import ubound, stats, gam
ok = all(sum((-1)**i * comb(q, i) for i in range(t + 1)) == (-1)**t * comb(q - 1, t) for q in range(1, 40) for t in range(0, q))
print("alternating identity sum_{i<=t} (-1)^i C(q,i) = (-1)^t C(q-1,t), q<40:", ok)
u = 0.5; worst = 1.0
for m in range(2, 100001):
    u *= (2 * m - 1) / (2 * m); worst = min(worst, u * 2 * sqrt(m))
print("min_m u_m * 2 sqrt(m) for m <= 1e5: %.6f (>= 1 needed)" % worst)
# Hoeffding frequency: d=3, r = random in [-1,1], law pi from Lemma 2.1 (approximated by sampling rows directly from the exact mixture)
rng = np.random.default_rng(5)
from lemma21_r1 import build
fails = 0; trials = 0
d = 3; r = rng.uniform(-1, 1, 8)
B = build(d, r, 1.0)
print("Hoeffding (d=3, a=1): m0=%d; first draw met sup|g-r|<=a/2 in build(): tries=%d" % (B['m0'], B['tries']))
g1 = gam(1)
for a_lab in ['1/n', '1/d']:
    first = None
    for dd in range(30, 60):
        M, n, _, _ = stats(dd)
        a = 1 / n if a_lab == '1/n' else mp.mpf(1) / dd
        tri, cor, th = ubound(dd, 1, a)
        if max(tri, cor) >= 2 * g1 * th**2 / 3 and first is None: first = dd
    print("c=1: first d with bound >= 2 eps_d when a = %s: %d" % (a_lab, first))
M, n, _, _ = stats(33)
for a_lab, a in [('1/n', 1 / n), ('1/d', mp.mpf(1) / 33)]:
    tri, cor, th = ubound(33, 1, a)
    print("   d=33, a=%s: bound %.4e vs 2 eps_d %.4e" % (a_lab, float(cor), float(2 * g1 * th**2 / 3)))
