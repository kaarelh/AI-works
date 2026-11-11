"""Remark 8 (width transition) and Remark 7 (critical-exponent window) of RT-width.fixed.md.

(a) A.md Theorem 4.4 certified excess  e = ( sqrt((beta_n - sqrt(2 lam log(1/delta)/M))_+) - sqrt(eps) )_+^2,
    eps = c (K_mem + t)/M + lam a^2, K_mem = d(d+1) alpha_d^2 + (H+1) max{(8 d s)^{1/H}, 9/(2a)},
    N_0 = floor(64 ln2 d(d+1) s / a^2) + 1, s = min(n, M), at c = 1, t = 1, delta = 0.01, lam = 1,
    for several accuracy schedules a_d: fixed a, a = 1/d, a = 1/sqrt(d), a = 2^{-d/3} (Cor. 4.5 for c = 1).
    Report e, N_0 / n, N_0 / (n log2(n)^2).
(b) Success side: Dev_N >= 4 threshold N* = sqrt(2n/((H-1) ln 2n)) - check Dev at N* and at N*/2.
(c) Remark 7: eta = delta0 (K/L)^{L/2} with delta0 = tanh(1)^{-H} / (m^H B^L), m = floor(n^a), B = n^a, K = n+1.
"""
import math
import mpmath as mp
from scipy import stats
mp.mp.dps = 40

def beta_n(n, M):
    # E[1/K ; K>=1], K ~ Bin(n, 1/M). Exact binomial for n < 2^40; for larger n the Poisson limit
    # beta(n/M), whose error is at most (n/M)/M (A.md Lemma 4.3(c)), far below the printed precision.
    p = 1.0/M; tot = 0.0
    kmax = int(n*p + 60*math.sqrt(n*p + 1) + 60)
    if n < 2**40:
        for k in range(1, min(n, kmax)+1):
            tot += stats.binom.pmf(k, n, p)/k
        return tot
    lam = n/M
    for k in range(1, kmax+1):
        tot += stats.poisson.pmf(k, lam)/k
    return tot

def e_cert(d, H, a, c=1.0, t=1.0, delta=0.01, lam=1.0):
    M = 2**d; n = int(round(lam*M)); s = min(n, M)
    al = 0.5*math.log(4*math.sqrt(2*d))
    Kmem = d*(d+1)*al**2 + (H+1)*max((8*d*s)**(1.0/H), 9/(2*a))
    eps = c*(Kmem + t)/M + (n/M)*a**2
    b = beta_n(n, M)
    inner = max(b - math.sqrt(2*(n/M)*math.log(1/delta)/M), 0.0)
    e = max(math.sqrt(inner) - math.sqrt(eps), 0.0)**2
    N0 = math.floor(64*math.log(2)*d*(d+1)*s/a**2) + 1
    return e, b, N0, n

print("(a) A.md Theorem 4.4 at c=1, H=2, lambda=1, delta=0.01: certified excess and width threshold")
print("    beta(1) = 0.484829")
for sched, f in [("a=1/2 fixed", lambda d: 0.5), ("a=0.1 fixed", lambda d: 0.1), ("a=1/d", lambda d: 1.0/d),
                 ("a=1/sqrt(d)", lambda d: 1/math.sqrt(d)), ("a=2^(-d/3) (Cor 4.5)", lambda d: 2**(-d/3))]:
    out = []
    for d in [30, 40, 60, 100]:
        e, b, N0, n = e_cert(d, 2, f(d))
        out.append("d=%d: e=%.4f N0/(n log2^2 n)=%.3g N0/n^(5/3)=%.3g" % (d, e, N0/(n*math.log2(n)**2), N0/n**(5/3)))
    print("    %-22s " % sched + " | ".join(out))
print("    fixed-a limit (sqrt(beta)-a sqrt(lam))^2: a=1/2 -> %.4f, a=0.1 -> %.4f" % ((math.sqrt(0.4848291)-0.5)**2, (math.sqrt(0.4848291)-0.1)**2))

print("(b) parameter-counting stop: Dev_N at N* = sqrt(2n/((H-1)ln 2n)) and at N*/2 (H=2, d=log2 n, c=1, delta=0.05)")
def Dev(n, N, d, H, delta):
    K = mp.mpf(n)+1
    Lam = mp.log(2 + 2*n*mp.sqrt(K*N)*H*(d+N+1)*(K+1)**(mp.mpf(H)/2))
    P = N*(d+2) + (H-1)*N**2
    return 4*mp.sqrt((P*Lam + mp.log(4/mp.mpf(delta)))/(2*n))
for e10 in [6, 9, 12, 18]:
    n = mp.mpf(10)**e10; d = int(mp.log(n, 2)); H = 2
    Ns = int(mp.ceil(mp.sqrt(2*n/((H-1)*mp.log(2*n)))))
    # largest N with Dev <= 0.1 (bisection)
    lo, hi = 1, Ns
    while hi - lo > 1:
        mid = (lo+hi)//2
        if Dev(n, mid, d, H, 0.05) <= 0.1: lo = mid
        else: hi = mid
    print("    n=1e%-2d N*=%-10d Dev(N*)=%.3f Dev(N*/2)=%.3f  largest N with Dev<=0.1: %d = %.4f sqrt(n/ln n)" % (
        e10, Ns, float(Dev(n, Ns, d, H, 0.05)), float(Dev(n, Ns//2, d, H, 0.05)), lo, lo/float(mp.sqrt(n/mp.log(n)))))

print("(c) Remark 7: log10 eta for alpha = thr -/+ 0.01, n = 1e30, 1e100, 1e300")
for L in [2, 3, 4, 8]:
    H = L-1; thr = L/(2*(2*L-1)); row = []
    for a in [thr-0.01, thr+0.01]:
        vals = []
        for e10 in [30, 100, 300]:
            n = mp.mpf(10)**e10; m = mp.floor(n**a); B = n**a
            d0 = mp.tanh(1)**(-H)/(m**H*B**L); eta = d0*((n+1)/L)**(mp.mpf(L)/2)
            vals.append(float(mp.log10(eta)))
        row.append("a=%.4f: %s" % (a, ", ".join("%.1f" % v for v in vals)))
    print("    L=%d thr=%.4f  %s" % (L, thr, " | ".join(row)))
