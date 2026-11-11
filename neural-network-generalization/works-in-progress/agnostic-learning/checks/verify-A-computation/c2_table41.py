"""Independent recomputation of Table 4.1, Remark 4.7 (admissible c, fixed-a numbers) and the finite-d
size of the A' certified excess of Theorem 7.2.  The optimal accuracy a is found in closed form:
eps(a) = c (K_mem(a)+t)/M + lam a^2 has its minimum at a* = min(a_kink, a_int, 1), where
a_kink = 9/(2 (8 d s)^{1/H}) and a_int = (9 (H+1) c / (4 M lam))^{1/3}."""
from math import log, sqrt, floor
import mpmath as mp
mp.mp.dps = 40
out = []
def P(*a):
    s = " ".join(str(x) for x in a); print(s); out.append(s)

def alpha(d): return 0.5*log(4*sqrt(2*d))
def Kmem(d, s, a, H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*s)**(1/H), 9/(2*a))
def N0(d, s, a): return floor(64*log(2)*d*(d+1)*s/a**2) + 1

def beta_n(n, M):
    n = mp.mpf(n); p = mp.mpf(1)/M
    lp, lq = mp.log(p), mp.log(1-p)
    tot = mp.mpf(0)
    lam = float(n/M)
    for k in range(1, int(80 + 30*lam)):
        lpmf = mp.loggamma(n+1) - mp.loggamma(k+1) - mp.loggamma(n-k+1) + k*lp + (n-k)*lq
        tot += mp.e**lpmf/k
    return float(tot)

def astar(d, H, c, lam, M, s):
    a_kink = 9/(2*(8*d*s)**(1/H))
    a_int = (9*(H+1)*c/(4*M*lam))**(1/3)
    return min(a_kink, a_int, 1.0)

def e_low(d, H, lam, c=1.0, t=1.0, delta=0.01, a=None):
    M = 2.0**d; n = lam*M; s = min(n, M)
    bn = beta_n(n, M)
    q = max(bn - sqrt(2*lam*log(1/delta)/M), 0.0)
    if a is None: a = astar(d, H, c, lam, M, s)
    eps = c*(Kmem(d, s, a, H)+t)/M + lam*a*a
    return max(sqrt(q) - sqrt(eps), 0.0)**2, a, bn, eps

# brute-force check of the closed-form optimum on a log grid
def e_grid(d, H, lam, c=1.0):
    best = (-1, None)
    for i in range(4000):
        a = 10**(-14 + 14*i/3999)
        v = e_low(d, H, lam, c=c, a=a)[0]
        if v > best[0]: best = (v, a)
    return best

P("Table 4.1 recomputed (c=1,t=1,delta=0.01):")
P(" H  d | e(1)    a*(1)     K_mem     N0        | e(1.5)  a*(1.5)  | beta_n(1) beta_n(1.5) | grid check e(1)")
rows = [(2, 20), (2, 30), (2, 40), (2, 60), (3, 20), (3, 30), (3, 40), (4, 30)]
for H, d in rows:
    e1, a1, b1, _ = e_low(d, H, 1.0)
    e15, a15, b15, _ = e_low(d, H, 1.5)
    M = 2.0**d
    g = e_grid(d, H, 1.0)
    P(f" {H} {d:2d} | {e1:.4f} {a1:.2e} {Kmem(d, M, a1, H):.2e} {N0(d, M, a1):.2e} | {e15:.4f} {a15:.2e} | {b1:.5f} {b15:.5f} | {g[0]:.4f} at a={g[1]:.2e}")
P("gaps beta_n - e at (2,40):", round(e_low(40, 2, 1.0)[2]-e_low(40, 2, 1.0)[0], 4), round(e_low(40, 2, 1.5)[2]-e_low(40, 2, 1.5)[0], 4))
P("gaps beta_n - e at (3,30):", round(e_low(30, 3, 1.0)[2]-e_low(30, 3, 1.0)[0], 4), round(e_low(30, 3, 1.5)[2]-e_low(30, 3, 1.5)[0], 4))

P("\nLargest c with e >= beta_n/2 at lambda=1 (bisection on log c):")
for H, d in ((2, 30), (3, 30), (2, 40), (3, 40)):
    lo, hi = 1e-3, 1e12
    bn = e_low(d, H, 1.0)[2]
    for _ in range(200):
        mid = sqrt(lo*hi)
        if e_low(d, H, 1.0, c=mid)[0] >= bn/2: lo = mid
        else: hi = mid
    n = 2.0**d
    P(f"  (H,d)=({H},{d}): c_max = {lo:.4g};  n^(1-1/H) d^(-1/H) = {n**(1-1/H)*d**(-1/H):.4g}")

P("\nFixed accuracy a (Remark 4.7):")
b1 = float(mp.e**(-1)*(mp.ei(1)-mp.euler))
for a in (0.1, 0.3):
    P(f"  a={a}: (sqrt(beta(1)) - a)^2 = {(sqrt(b1)-a)**2:.4f}; N0/n at d=20,30,40:",
      [f"{N0(d, 2.0**d, a)/2.0**d:.3e}" for d in (20, 30, 40)])

P("\nTheorem 7.2 (A') certified excess e' at c=t=1, delta=0.01, lambda=1, a optimised on a grid:")
def e_prime(d, H, a, c=1.0, t=1.0, delta=0.01, lam=1.0):
    M = 2.0**d; n = lam*M; s = min(n, M)
    bn = beta_n(n, M)
    q = max(bn - sqrt(2*lam*log(1/delta)/M), 0.0)
    E = sqrt(c*(Kmem(d, s, a, H)+t)) + (a + 2/n)*sqrt(n)
    Bp = 2*E*sqrt(n) + E*E
    inner = max(sqrt(q) - sqrt(Bp/M), 0.0)**2
    return max(sqrt(1+inner) - 1/n, 0.0)**2 - 1, bn
for H, d in rows:
    best = max((e_prime(d, H, 10**(-14+14*i/3999))[0], 10**(-14+14*i/3999)) for i in range(4000))
    P(f"  (H,d)=({H},{d}): e'_max = {best[0]:.4f} at a = {best[1]:.2e};  Theorem 4.4's e = {e_low(d, H, 1.0)[0]:.4f}")
# d > 100 is treated in c2b_flatness.py with the Poisson beta (the binomial loggamma sum loses precision there)
for d in (80, 100):
    best = max((e_prime(d, 2, 10**(-30+30*i/3999))[0], 10**(-30+30*i/3999)) for i in range(4000))
    P(f"  (H,d)=(2,{d}): e'_max = {best[0]:.4f}")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
