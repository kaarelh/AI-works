import numpy as np
from scipy.optimize import brentq
# units g=1, R=1. Sphere center (0,1), radius 1; top T=(0,2).
# Reverse-time: launch from T with speed w at angle beta (to +x), must reach z=0 without entering open disk.
def clears(w, beta, n=20001):
    vx, vz = w*np.cos(beta), w*np.sin(beta)
    # time to reach z=0: 2 + vz t - t^2/2 = 0
    tf = vz + np.sqrt(vz**2 + 4)
    t = np.linspace(1e-6, tf, n)
    x = vx*t; z = 2 + vz*t - t**2/2
    d2 = x**2 + (z-1)**2
    return np.all(d2 >= 1 - 1e-9)
def feasible(w):
    return any(clears(w, b) for b in np.linspace(-0.2, 1.5, 1701))
lo, hi = 0.1, 1.2
for _ in range(40):
    mid = (lo+hi)/2
    if feasible(mid): hi = mid
    else: lo = mid
w = hi
print("min speed at top w^2/(gR) =", w**2)
print("v_min^2/(gR) = w^2 + 4 =", w**2 + 4, " v_min/sqrt(gR)=", np.sqrt(w**2+4))
best = [b for b in np.linspace(-0.2,1.5,1701) if clears(hi*1.0001,b)]
print("feasible betas near optimum (deg):", np.degrees(min(best)), np.degrees(max(best)))
print("candidates: 2*(1+sqrt2)=", 2*(1+np.sqrt(2)), " sqrt(2(1+sqrt2))=",np.sqrt(2*(1+np.sqrt(2))))
