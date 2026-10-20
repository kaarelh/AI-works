"""Bookkeeping of Theorem S1: constants, crossover, large-d conditions, adaptive cutoff in log space."""
import math, numpy as np
from scipy.special import gammaln
lb = lambda n, k: gammaln(n+1)-gammaln(k+1)-gammaln(n-k+1)
e = math.e
cth = math.sqrt(2*math.pi)*(math.exp(-1)-0.35)
C0 = 2+2/cth**2
eps = 1/(64*(2+8/cth**2))
print(f'c_theta={cth:.7f} c^2={cth**2:.7f} C0={C0:.3f} eps={eps:.4e} 1-1/e={1-math.exp(-1):.5f}<0.65')
print('Regime I: 1/2-1/(5sqrt(2pi)) - 1/23 =', 0.5-1/(5*math.sqrt(2*math.pi))-1/23, ' > 3/8?', 0.5-1/(5*math.sqrt(2*math.pi))-1/23 > 0.375)
print('budget 1/16+1/64+1/32+1/64 =', 1/16+1/64+1/32+1/64)
print('(2+8/c^2) eps =', (2+8/cth**2)*eps, ' e*sqrt(pi/(256e^2)/pi)=', e*math.sqrt(math.pi/(256*e*e)/math.pi))
print('pi/(256 e^2)=', math.pi/(256*e*e), ' pi/(64e^2)=', math.pi/(64*e*e), ' 1/(8e^2 log32)=', 1/(8*e*e*math.log(32)))
cs = 1e-3
def logn0(d):
    t = int(math.floor(math.sqrt(d)/5)); return lb(d, t) - math.log(23*C0)
def lognmax(d): return cs*d*math.log(math.log(d))/math.log(d)
for d in [1e7, 1e8, 2e8, 2.5e8, 2.6e8, 2.7e8, 3e8, 1e9, 1e10]:
    print(f'd={d:.2e}: log n0={logn0(d):.4e}  log nmax={lognmax(d):.4e}  ratio nmax/n0={lognmax(d)/logn0(d):.3f}')
# bisection for crossover
lo, hi = 1e8, 1e9
for _ in range(60):
    mid = math.sqrt(lo*hi)
    if lognmax(mid) > logn0(mid): hi = mid
    else: lo = mid
print('crossover d ~', hi)
# claim in L6.4(b): log(2 D_{t'}) <= sqrt(d)/4 log d for d>=3000 (D_{t'} <= 2 binom(d,t'))
bad = [d for d in range(3000, 200000, 7) if math.log(4)+lb(d, max(int(math.sqrt(d)/5)-3, 0)) > math.sqrt(d)/4*math.log(d)]
print('L6.4(b) step 2 failures for 3000<=d<2e5:', bad[:5])
bad = [d for d in range(3000, 200000, 7) if (lambda t: lb(d, t-3) - lb(d, t) > math.log(8/(125*d**1.5)))(int(math.sqrt(d)/5))]
print('L6.4(b) step 3 failures:', bad[:5])

def Jd_rd(d, gam, A=1.0, c1=0.3):
    lnd = math.log(d)
    betaA = 32*((e-1)*A+1)+A
    Jd = lnd + 1 + math.log(256*betaA/cth**2) + math.log(1+4/gam)*(1+(lnd+math.log(A/eps))/(2*math.log(lnd/(1.3*cs))))
    rd = 1.1*(cs/lnd + 2/d)
    return Jd, rd
for gam, nm in [(3.816e-3, 'sigma1=1'), (1.1e-4, 'sigma1=0.3'), (3.09e-2, 'sigma1=3')]:
    out = []
    for L10 in [9, 20, 50, 100, 200, 500, 1000, 1e4]:
        d = 10.0**L10 if L10 < 300 else None
        if d is None:
            lnd = L10*math.log(10)
            betaA = 32*((e-1)+1)+1
            Jd = lnd + 1 + math.log(256*betaA/cth**2) + math.log(1+4/gam)*(1+(lnd+math.log(1/eps))/(2*math.log(lnd/(1.3*cs))))
            rd = 1.1*cs/lnd
        else:
            Jd, rd = Jd_rd(d, gam)
        out.append(f'10^{L10}: JdRd={Jd*rd:.3e}')
    print(nm, 'need <=', f'{math.pi/(256*e*e):.3e}', '; '.join(out))
# find threshold log10 d for (L9) second condition with A=1
for gam in [3.816e-3, 1.1e-4, 3.09e-2]:
    for L10 in np.arange(5, 400, 0.5):
        lnd = L10*math.log(10)
        betaA = 32*((e-1)+1)+1
        Jd = lnd + 1 + math.log(256*betaA/cth**2) + math.log(1+4/gam)*(1+(lnd+math.log(1/eps))/(2*math.log(lnd/(1.3*cs))))
        rd = 1.1*cs/lnd
        if Jd*rd <= math.pi/(256*e*e):
            print(f'gamma={gam}: (L9) J_d r_d condition first holds (A=1) at d ~ 10^{L10}'); break

# Adaptive cutoff sanity check in log space for a moderately large d where Regime II nonempty.
def logD(d, r):  # log sum_{q<=r} binom(d,q), using ratios from the top term
    tot = 1.0; term = 1.0
    for k in range(min(r, 200)):
        term *= (r-k)/(d-r+k+1); tot += term
        if term < 1e-18: break
    return lb(d, r) + math.log(tot)
def adaptive(d, logn, A=1.0):
    ok = lambda r: math.log(A) + logD(d, r) + math.log(math.log(2)+logD(d, r)) <= logn
    lo, hi = 0, 1   # odd index k -> r=2k+1
    while ok(2*hi+1): hi *= 2
    while hi-lo > 1:
        mid = (lo+hi)//2
        if ok(2*mid+1): lo = mid
        else: hi = mid
    r = 2*lo+1
    assert ok(r) and not ok(r+2)
    return r
for d in [int(3e8), int(1e9), int(1e10)]:
    t = int(math.sqrt(d)/5); lnd = math.log(d)
    lo_, hi_ = logn0(d), lognmax(d)
    if hi_ <= lo_: print('d', d, 'Regime II empty'); continue
    for frac in [0.0001, 0.5, 1.0]:
        logn = lo_ + frac*(hi_-lo_)
        r = adaptive(d, logn)
        D = d+1
        Lam = 2*math.log(4)+2*(r+2)*math.log(e*d/(r+2))
        rhoh = 1.25*(r+2)/d
        kstar = math.ceil(math.log(Lam/eps)/(2*math.log(1/rhoh)))
        u = r+2*kstar
        # n / binom(D,u+2) < eps ?
        chk = logn - lb(D, u+2)
        chk_c = logn - lb(D, r+2) - math.log(Lam)
        print(f'd={d:.1e} frac={frac}: r={r} t-4={t-4} c*d/logd={cs*d/lnd:.0f} k*={kstar} u={u} '
              f'log(n/binom(D,u+2))={chk:.2f} (need < log eps={math.log(eps):.2f}); log(n/(binom(D,r+2)Lam))={chk_c:.2f}(<0)')
