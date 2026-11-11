"""(1) Exact optimiser at (H,d)=(2,60) in high precision; (2) how flat e(a) is above the kink, i.e. the
width N0 needed to stay within 0.001 / 0.01 of the optimal certified excess; (3) A' excess e' for large d
using the Poisson beta (Le Cam error n/M^2 is negligible there); (4) e' with a sharper Step 4."""
from math import log, sqrt, floor
import mpmath as mp
mp.mp.dps = 80
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)

def alpha(d): return mp.mpf(0.5)*mp.log(4*mp.sqrt(2*d))
def Kmem(d, s, a, H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*mp.mpf(s))**(mp.mpf(1)/H), mp.mpf(9)/(2*a))
def N0(d, s, a): return mp.floor(64*mp.log(2)*d*(d+1)*s/a**2) + 1
def beta_pois(lam):
    lam = mp.mpf(lam); return mp.e**(-lam)*(mp.ei(lam) - mp.euler - mp.log(lam))
def beta_n(n, M):
    n = mp.mpf(n); p = mp.mpf(1)/M; lp, lq = mp.log(p), mp.log(1-p)
    lam = n/M; tot = mp.mpf(0)
    for k in range(1, int(80 + 30*lam)):
        tot += mp.e**(mp.loggamma(n+1) - mp.loggamma(k+1) - mp.loggamma(n-k+1) + k*lp + (n-k)*lq)/k
    return tot
def e_low(d, H, lam, a, c=1, t=1, delta=mp.mpf('0.01'), bn=None):
    M = mp.mpf(2)**d; n = lam*M; s = min(n, M)
    if bn is None: bn = beta_n(n, M)
    q = max(bn - mp.sqrt(2*lam*mp.log(1/delta)/M), 0)
    eps = c*(Kmem(d, s, a, H)+t)/M + lam*a*a
    return max(mp.sqrt(q) - mp.sqrt(eps), 0)**2

P("(1) (H,d)=(2,60), lambda=1: e(a) in 80-digit arithmetic")
d, H = 60, 2; M = mp.mpf(2)**d; bn = beta_n(M, M)
akink = mp.mpf(9)/(2*(8*d*M)**(mp.mpf(1)/H))
P("   a_kink =", mp.nstr(akink, 6), "  N0(a_kink) =", mp.nstr(N0(d, M, akink), 4))
for a in (mp.mpf('1.85e-10'), akink, mp.mpf('2.0e-10'), mp.mpf('1e-9'), mp.mpf('1e-6')):
    P(f"   a={mp.nstr(a,4)}: e = {mp.nstr(e_low(d, H, 1, a, bn=bn), 22)}  N0 = {mp.nstr(N0(d, M, a), 3)}")

P("\n(2) Flatness of e(a) above the kink (c=t=1, delta=0.01, lambda=1): largest a, and its N0,")
P("    keeping e within 0.001 (resp. 0.01) of the optimum")
rows = [(2, 20), (2, 30), (2, 40), (2, 60), (3, 20), (3, 30), (3, 40), (4, 30)]
for H, d in rows:
    M = mp.mpf(2)**d; bn = beta_n(M, M)
    akink = mp.mpf(9)/(2*(8*d*M)**(mp.mpf(1)/H))
    aint = (mp.mpf(9)*(H+1)/(4*M))**(mp.mpf(1)/3)
    astar = min(akink, aint, 1)
    eopt = e_low(d, H, 1, astar, bn=bn)
    res = []
    for tol in (mp.mpf('0.001'), mp.mpf('0.01')):
        lo, hi = astar, mp.mpf(1)
        if e_low(d, H, 1, hi, bn=bn) >= eopt - tol: lo = hi
        else:
            for _ in range(200):
                mid = mp.sqrt(lo*hi)
                if e_low(d, H, 1, mid, bn=bn) >= eopt - tol: lo = mid
                else: hi = mid
        res.append((lo, N0(d, M, lo)))
    P(f"   (H,d)=({H},{d}): a*={mp.nstr(astar,3)} e*={mp.nstr(eopt,4)} N0*={mp.nstr(N0(d,M,astar),3)} | "
      f"tol 1e-3: a={mp.nstr(res[0][0],3)} N0={mp.nstr(res[0][1],3)} (N0/n={mp.nstr(res[0][1]/M,3)}) | "
      f"tol 1e-2: a={mp.nstr(res[1][0],3)} N0={mp.nstr(res[1][1],3)} (N0/n={mp.nstr(res[1][1]/M,3)})")

P("\n(3) Theorem 7.2's certified excess e' (as stated) versus a sharper Step 4, lambda=1, c=t=1, delta=0.01")
def e_prime(d, H, a, sharp=False, c=1, t=1, delta=mp.mpf('0.01'), bn=None):
    M = mp.mpf(2)**d; n = M; s = M
    if bn is None: bn = beta_pois(1) if d > 60 else beta_n(n, M)
    q = max(bn - mp.sqrt(2*mp.log(1/delta)/M), 0)
    K = Kmem(d, s, a, H)
    if not sharp:
        E = mp.sqrt(c*(K+t)) + (a + 2/n)*mp.sqrt(n)
        Bp = 2*E*mp.sqrt(n) + E*E
    else:
        # sharper Step 4 (see report): Delta(zeta) <= c(K+t) + n a^2 + 2 sqrt(a^2+1) + 1/n + 4 sqrt(...)/sqrt(n) + ...
        # crude explicit form Delta(zeta) <= c(K+t) + n a^2 + 7, valid when c(K+t) <= n and n >= 100 (see report)
        if c*(K+t) > n: return mp.mpf(-1)  # outside the validity range of the sharper bound
        Bp = c*(K+t) + n*a*a + 7
    inner = max(mp.sqrt(q) - mp.sqrt(Bp/M), 0)**2
    return max(mp.sqrt(1+inner) - 1/n, 0)**2 - 1
for H, d in rows + [(2, 80), (2, 100), (2, 140)]:
    M = mp.mpf(2)**d
    bn = beta_pois(1) if d > 60 else beta_n(M, M)
    grid = [mp.mpf(10)**(-mp.mpf(45)*i/1500) for i in range(1, 1500)]
    best = max((e_prime(d, H, a, bn=bn), a) for a in grid)
    bests = max((e_prime(d, H, a, sharp=True, bn=bn), a) for a in grid)
    P(f"   (H,d)=({H},{d}): e' as stated = {mp.nstr(best[0],4)} (a={mp.nstr(best[1],2)}); with sharper Step 4 = {mp.nstr(bests[0],4)}")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
