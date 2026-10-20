from mpmath import mp, mpf, log, sqrt, exp, pi, loggamma, floor, findroot
mp.dps=40
ct=sqrt(2*pi)*(exp(-1)-mpf(7)/20); C0=2+2/ct**2
def lb(n,k): return loggamma(n+1)-loggamma(k+1)-loggamma(n-k+1)
def ratio(d):
    d=floor(d); t=floor(sqrt(d)/5)
    ln0=lb(d,t)-log(23*C0); lnm=mpf('1e-3')*d*log(log(d))/log(d)
    return lnm/ln0
for x in [8,8.4,8.41,8.42,9,10]: print(x, float(ratio(mpf(10)**x)))
lo,hi=mpf(8),mpf(9)
for _ in range(60):
    m=(lo+hi)/2
    if ratio(mpf(10)**m)<1: lo=m
    else: hi=m
print('crossover d=',float(mpf(10)**lo))
# gamma, Theta at sigma=1
g=1/(6*(1+pi/2)**4); print('gamma1',float(g), float(log(1+4/g)))
