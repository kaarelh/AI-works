import math
from scipy.special import gammaln
ct = math.sqrt(2*math.pi)*(1/math.e - 0.35)
C0 = 2 + 2/ct**2
eps = 1/(64*(2 + 8/ct**2))
print("c_theta", ct, "c_theta^2", ct**2, "C0", C0, "8/ct^2", 8/ct**2, "eps", eps)
print("pi/(256 e^2)", math.pi/(256*math.e**2), "pi/(64 e^2)", math.pi/(64*math.e**2), "1/(8e^2 log32)", 1/(8*math.e**2*math.log(32)))
print("1/2 - 1/(5 sqrt(2pi))", 0.5 - 1/(5*math.sqrt(2*math.pi)), " minus 1/23:", 0.5 - 1/(5*math.sqrt(2*math.pi)) - 1/23)
def logbinom(n, k): return gammaln(n+1) - gammaln(k+1) - gammaln(n-k+1)
cstar = 1e-3
for e10 in [7, 8, 8.3, 8.5, 9, 10]:
    d = 10**e10
    t = math.floor(math.sqrt(d)/5)
    ln0 = logbinom(d, t) - math.log(23*C0)
    lnmax = cstar*d*math.log(math.log(d))/math.log(d)
    print(f"d=1e{e10}: log n0 = {ln0:.4g}, log nmax = {lnmax:.4g}, ratio = {lnmax/ln0:.3f}")
# bisection for crossover
lo, hi = 1e7, 1e10
for _ in range(100):
    mid = math.sqrt(lo*hi)
    d = mid; t = math.floor(math.sqrt(d)/5)
    f = cstar*d*math.log(math.log(d))/math.log(d) - (logbinom(d, t) - math.log(23*C0))
    if f > 0: hi = mid
    else: lo = mid
print("crossover d ~", hi)
# erf gamma check
for q in [0.5, 1, 2]:
    b = 2*q/(1+2*q)
    import numpy as np
    k = np.arange(0, 200)
    logc = np.array([math.lgamma(2*kk+1) - 2*math.lgamma(kk+1) - kk*math.log(4) + (2*kk+1)*math.log(b) - math.log(2*kk+1) for kk in k])
    rat = np.exp(logc[1:] - logc[:-1])
    print("erf q", q, "min ratio", rat.min(), "b^2/6", b*b/6)
