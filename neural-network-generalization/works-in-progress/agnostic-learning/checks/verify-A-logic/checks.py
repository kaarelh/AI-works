import math, itertools
from fractions import Fraction
import numpy as np

print("1. N0/n = 64 log2 d(d+1)/a^2 at lambda=1 (s=n)")
for a in (0.1, 0.3):
    vals = [64*math.log(2)*d*(d+1)/a**2 for d in (20, 40)]
    print(f"   a={a}: d=20 -> {vals[0]:.4g}, d=40 -> {vals[1]:.4g}")

print("2. tanh(2 tanh 1) =", math.tanh(2*math.tanh(1)), " tanh 1 =", math.tanh(1), " 1/tanh1 =", 1/math.tanh(1))

print("3. Lemma 6.4(b) constants: (1-1/e)/16 =", (1-math.exp(-1))/16, " (1-1/e)^2/2 =", (1-math.exp(-1))**2/2)

print("4. d/2 log2(8 pi e) per d =", 0.5*math.log2(8*math.pi*math.e))

print("5. Prop 6.6(b): exact P[labels at one atom agree] vs bound 2exp(-n(1-eta0)/(2M))")
for d in (1, 2, 3):
    M = 2**d
    for eta0 in (Fraction(1,4), Fraction(1,2), Fraction(9,10)):
        p = (1+eta0)/2
        for n in (4, 16, 64):
            exact = (1-(1-p)/M)**n + (1-p/M)**n - (1-Fraction(1,M))**n
            bound = 2*math.exp(-n*(1-float(eta0))/(2*M))
            assert float(exact) <= bound + 1e-15, (d, eta0, n)
print("   one-atom expression <= bound in all 27 cases")

print("6. Constant network energy in 8.3 remark: (d+H) eps0^2")
d, H, N, e0 = 5, 3, 7, 0.1
k1 = d/N * N*e0**2; kint = (H-1)*N*N*(e0/N)**2; kv = N*N*(e0/N)**2
print("   computed", k1+kint+kv, " claimed", (d+H)*e0**2)

print("7. Monte Carlo: P[U_rho nonempty] for TUBE rho<=1 equals P[no atom has both labels]; compare with 2exp bound")
rng = np.random.default_rng(0)
for d, eta0, n in ((3, 0.5, 64), (4, 0.25, 128)):
    M = 2**d; p = (1+eta0)/2; T = 20000; cnt = 0
    for _ in range(T):
        x = rng.integers(0, M, n); y = rng.random(n) < p
        pos = np.zeros(M, bool); neg = np.zeros(M, bool)
        pos[x[y]] = True; neg[x[~y]] = True
        cnt += not np.any(pos & neg)
    print(f"   d={d}, eta0={eta0}, n={n}: MC {cnt/T:.4f}  bound {2*math.exp(-n*(1-eta0)/(2*M)):.4f}")
