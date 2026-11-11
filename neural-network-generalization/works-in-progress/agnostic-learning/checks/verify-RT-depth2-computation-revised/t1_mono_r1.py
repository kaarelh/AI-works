"""Is Psi_cor/(gamma th^2) at c=1, a=1/n nondecreasing for d near 800-830? Recompute at 200 digits."""
import mpmath as mp
mp.mp.dps = 200
import t51_r1
t51_r1.mp.mp.dps = 200
from t51_r1 import ubound, stats, gam
g1 = gam(1); prev = None; dec = []
for d in range(800, 834):
    M, n, _, _ = stats(d)
    tri, cor, th = ubound(d, 1, 1 / n)
    r = cor / (g1 * th**2)
    if prev is not None and r < prev: dec.append(d)
    prev = r
print("decreases at 200 digits for d in [801,833]:", dec, "; 1 - ratio at d=833: %s" % mp.nstr(1 - r, 5))
