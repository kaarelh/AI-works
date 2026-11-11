"""Caricature of the sample dependence of the scale threshold (high precision).
P=1, kappa=w^2, prior N(0,sigma^2). Conditioning set O_r=(1-r,1+r) U (2,3):
thin low-energy part around a 'clone' of energy 1 (width ~ margin r) and a fat part of
energy in [4,9] where the fit is much better ('memorizers'). Posterior mass of {kappa>2}."""
import mpmath as mp
mp.mp.dps = 120
sf = lambda t: mp.erfc(t / mp.sqrt(2)) / 2
def tail(r, s):
    thin = sf((1 - r) / s) - sf((1 + r) / s)
    fat = sf(mp.mpf(2) / s) - sf(mp.mpf(3) / s)
    return fat / (thin + fat)
rs = [mp.mpf('1e-1'), mp.mpf('1e-4'), mp.mpf('1e-8'), mp.mpf('1e-16'), mp.mpf('1e-32')]
print("sigma  " + "  ".join(f"r={mp.nstr(r,2):>6}" for r in rs))
for s in [0.5, 0.3, 0.2, 0.1, 0.05]:
    s = mp.mpf(s)
    print(f"{mp.nstr(s,2):5} " + "  ".join(f"{mp.nstr(tail(r, s), 3):>8}" for r in rs))
print("\nFor each fixed sigma the posterior sits on the high-energy part once r is small enough;"
      "\nfor each fixed r it concentrates on the low-energy part as sigma->0 (the pointwise limit).")
