# Independent recomputation of the numbers the second revision of A added or changed.
import mpmath as mp
mp.mp.dps = 60
LOG2 = mp.log(2)

def alpha(d): return mp.mpf(1)/2*mp.log(4*mp.sqrt(2*d))
def Kmem(d, s, a, H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*mp.mpf(s))**(mp.mpf(1)/H), mp.mpf(9)/(2*a))
def N0(d, s, a): return mp.floor(64*LOG2*d*(d+1)*mp.mpf(s)/a**2) + 1

_bn = {}
def beta_n(n, M):
    key = (int(n), int(M))
    if key in _bn: return _bn[key]
    n = mp.mpf(n); M = mp.mpf(M); p = 1/M
    lam = n/M; tot = mp.mpf(0)
    lp, lq = mp.log(p), mp.log1p(-p)
    for k in range(1, int(100 + 40*lam)):
        tot += mp.e**(mp.loggamma(n+1)-mp.loggamma(k+1)-mp.loggamma(n-k+1)+k*lp+(n-k)*lq)/k
    _bn[key] = tot
    return tot

def beta_pois(lam):
    lam = mp.mpf(lam)
    return mp.e**(-lam)*mp.quad(lambda u: mp.expm1(u)/u, [0, lam])

def e_thm44(H, d, a, c=1, t=1, delta=mp.mpf('0.01'), lam=1):
    M = mp.mpf(2)**d; n = lam*M; s = min(n, M)
    eps = c*(Kmem(d, s, a, H)+t)/M + lam*a**2
    q = max(beta_n(n, M) - mp.sqrt(2*lam*mp.log(1/delta)/M), 0)
    return max(mp.sqrt(q) - mp.sqrt(eps), 0)**2

def astar(H, d, c=1, lam=1):
    M = mp.mpf(2)**d; s = lam*M if lam*M < M else M
    akink = mp.mpf(9)/(2*(8*d*s)**(mp.mpf(1)/H))
    aint = (9*(H+1)*mp.mpf(c)/(4*lam*M))**(mp.mpf(1)/3)
    return min(akink, aint, mp.mpf(1)), akink, aint

print("== Table 4.1: a*, e*, N0(a*), largest a with e >= e*-0.001, its N0, N0/n, ratio")
rows = [(2,20),(2,30),(2,40),(2,60),(3,20),(3,30),(3,40),(4,30)]
for H, d in rows:
    a0, ak, ai = astar(H, d)
    M = mp.mpf(2)**d
    e0 = e_thm44(H, d, a0)
    # e decreasing for a > a*: bisect
    lo, hi = a0, mp.mpf(1)
    for _ in range(200):
        mid = (lo+hi)/2
        if e_thm44(H, d, mid) >= e0 - mp.mpf('0.001'): lo = mid
        else: hi = mid
    a1 = lo
    n0a, n0b = N0(d, M, a0), N0(d, M, a1)
    print(f"({H},{d}): a*={mp.nstr(a0,4)} ({'kink' if a0==ak else 'int'}) e*={mp.nstr(e0,6)} N0*={mp.nstr(n0a,4)} | a_0.001={mp.nstr(a1,4)} N0={mp.nstr(n0b,4)} N0/n={mp.nstr(n0b/M,4)} ratio={mp.nstr(n0a/n0b,4)}")

print("\n== fixed a, finite d (c=t=1, delta=0.01, lambda=1)")
for a in (mp.mpf('0.1'), mp.mpf('0.3')):
    print(" a =", a, " limit (sqrt(beta(1))-a)^2 =", mp.nstr((mp.sqrt(beta_pois(1))-a)**2, 6))
    for H in (2,3):
        print("   H=%d:" % H, [mp.nstr(e_thm44(H, d, a), 6) for d in (20,30,40)])
    print("   N0/n:", [mp.nstr(N0(d, 2**d, a)/2**d, 4) for d in (20,30,40)])

print("\n== Theorem 7.2 and Proposition 7.2a (c=t=1, delta=0.01, lambda=1, n=2^d)")
def e_prime(H, d, a, sharper, c=1, t=1, delta=mp.mpf('0.01')):
    M = mp.mpf(2)**d; n = M; lam = 1
    K = Kmem(d, M, a, H)
    if sharper:
        B = c*(K+t) + n*a**2 + 7
    else:
        E = mp.sqrt(c*(K+t)) + (a + 2/n)*mp.sqrt(n)
        B = 2*E*mp.sqrt(n) + E**2
    q = max(beta_n(n, M) - mp.sqrt(2*lam*mp.log(1/delta)/M), 0)
    inner = max(mp.sqrt(q) - mp.sqrt(B/M), 0)**2
    return max(mp.sqrt(1+inner) - 1/n, 0)**2 - 1

def maximize(f, lo, hi):
    # golden-section on log a (unimodal enough for these bounds)
    a, b = mp.log(lo), mp.log(hi)
    gr = (mp.sqrt(5)-1)/2
    for _ in range(200):
        c1 = b - gr*(b-a); c2 = a + gr*(b-a)
        if f(mp.e**c1) > f(mp.e**c2): b = c2
        else: a = c1
    x = mp.e**((a+b)/2)
    return f(x), x

for H, d in rows:
    a0 = astar(H, d)[0]
    e72, a72 = maximize(lambda a: e_prime(H, d, a, False), mp.mpf('1e-14'), mp.mpf(1))
    e72a_star = e_prime(H, d, a0, True)
    e72a_opt, a72a = maximize(lambda a: e_prime(H, d, a, True), mp.mpf('1e-14'), mp.mpf(1))
    M = mp.mpf(2)**d
    ratio = (Kmem(d, M, a0, H)+1)/M
    print(f"({H},{d}): Thm7.2 e'={mp.nstr(e72,5)} at a={mp.nstr(a72,4)} | Prop7.2a at a*: {mp.nstr(e72a_star,6)}, optimum {mp.nstr(e72a_opt,6)} at a={mp.nstr(a72a,4)} | c(K+t)/n at a*={mp.nstr(ratio,4)} | Thm4.4 e={mp.nstr(e_thm44(H,d,a0),5)}")

print("\n== Prop 7.2a at (3,20) on the referee's grid 10^(-0.03 i)")
H, d = 3, 20
for i in (68, 69, 70, 71):
    a = mp.mpf(10)**(-mp.mpf('0.03')*i)
    print(f"  i={i} a={mp.nstr(a,5)}: {mp.nstr(e_prime(H, d, a, True), 7)}")
print("  at a*:", mp.nstr(e_prime(H, d, astar(H,d)[0], True), 7))

print("\n== Corollary 4.5 vs 4.5a (c=t=1, n=2^d, delta_d)")
def cor45(H, d, a):
    lam = 1; M = mp.mpf(2)**d; n = M; c = 1; t = 1
    epsbar = c*(d*(d+1)*alpha(d)**2 + t)/M + (H+1)*c*((8*d*n)**(mp.mpf(1)/H) + mp.mpf(9)/(2*a))/M + lam*a**2
    q = max(beta_pois(1) - lam/M - mp.sqrt(2*lam)*mp.mpf(2)**(-mp.mpf(d)/4), 0)
    return epsbar, max(mp.sqrt(q)-mp.sqrt(epsbar), 0)**2, N0(d, M, a)/M
for H in (2,3):
    for d in (20, 40, 60, 100):
        ad = (mp.mpf(1)/2**d)**(mp.mpf(1)/3); ap = max(ad, mp.mpf(1)/d)
        e1, b1, r1 = cor45(H, d, ad); e2, b2, r2 = cor45(H, d, ap)
        print(f"  H={H} d={d}: a_d={mp.nstr(ad,3)} bound={mp.nstr(b1,5)} N0/n={mp.nstr(r1,3)} | a'_d={mp.nstr(ap,3)} bound={mp.nstr(b2,5)} N0/n={mp.nstr(r2,3)} (45 d^3(d+1)={mp.nstr(45*d**3*(d+1),3)})")

print("\n== Prop 7.2a constants")
n = 100
print("  2 sqrt(3+3/n) =", mp.nstr(2*mp.sqrt(3+mp.mpf(3)/n), 8), " 2 sqrt2 + 3/n =", mp.nstr(2*mp.sqrt(2)+mp.mpf(3)/n, 8))
print("  2 sqrt2 + 2/n <= 3 :", 2*mp.sqrt(2)+mp.mpf(2)/n <= 3)
