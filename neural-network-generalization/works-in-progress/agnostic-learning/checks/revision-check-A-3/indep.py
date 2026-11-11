# Independent recomputation of new numbers in A (revision 2), written from the formulas in the text.
from mpmath import mp, mpf, sqrt, log, exp, loggamma, floor
mp.dps = 50
def alpha(d): return log(4*sqrt(2*d))/2
def Kmem(d,s,a,H): return d*(d+1)*alpha(d)**2 + (H+1)*max((8*d*s)**(mpf(1)/H), mpf(9)/(2*a))
def N0(d,s,a): return floor(64*log(2)*d*(d+1)*s/a**2)+1
def beta_n(n, M):
    p = mpf(1)/M; tot = mpf(0)
    # sum over k=1..kmax using log pmf
    for k in range(1, 200):
        lp = loggamma(n+1)-loggamma(k+1)-loggamma(n-k+1)+k*log(p)+(n-k)*log(1-p)
        tot += exp(lp)/k
    return tot
def e_thm44(d,H,lam,a,c=1,t=1,delta=mpf('0.01')):
    M = mpf(2)**d; n = lam*M; s = min(n,M)
    eps = c*(Kmem(d,s,a,H)+t)/M + lam*a**2
    q = beta_n(n,M) - sqrt(2*lam*log(1/delta)/M)
    q = max(q,0)
    v = sqrt(q)-sqrt(eps)
    return max(v,0)**2
def astar(d,H,lam,c=1):
    M = mpf(2)**d; n = lam*M; s = min(n,M)
    akink = mpf(9)/(2*(8*d*s)**(mpf(1)/H)); aint = (9*(H+1)*c/(4*lam*M))**(mpf(1)/3)
    return min(aint, akink, mpf(1))
def Phi(q,u,Bud,M):
    v = sqrt(q)-sqrt(Bud/M); v = max(v,0)
    w = sqrt(1+v**2)-u; w = max(w,0)
    return w**2
def e_thm72(d,H,lam,a,c=1,t=1,delta=mpf('0.01'), sharper=False):
    M = mpf(2)**d; n = lam*M; s=min(n,M)
    K = Kmem(d,s,a,H)
    if sharper: Bud = c*(K+t)+n*a**2+7
    else:
        E = sqrt(c*(K+t)) + (a+mpf(2)/n)*sqrt(n); Bud = 2*E*sqrt(n)+E**2
    q = max(beta_n(n,M)-sqrt(2*lam*log(1/delta)/M),0)
    return Phi(q, mpf(1)/n, Bud, M)-1
def maximize(f, lo, hi, it=200):
    # golden-section on log a
    import math
    a, b = log(lo), log(hi); gr = (sqrt(5)-1)/2
    c_ = b - gr*(b-a); d_ = a + gr*(b-a)
    for _ in range(it):
        if f(exp(c_)) > f(exp(d_)): b = d_
        else: a = c_
        c_ = b - gr*(b-a); d_ = a + gr*(b-a)
    x = exp((a+b)/2); return x, f(x)
rows = [(2,20),(2,30),(2,40),(2,60),(3,20),(3,30),(3,40),(4,30)]
print("Table 4.1 recomputed: H d | e(1) a* K_mem N0 | e(1.5) | largest a within 0.001, its N0, N0/n, factor")
for H,d in rows:
    a1 = astar(d,H,1); e1 = e_thm44(d,H,1,a1); a15 = astar(d,H,mpf('1.5')); e15 = e_thm44(d,H,mpf('1.5'),a15)
    M = mpf(2)**d
    # largest a with e(a) >= e1 - 0.001 (bisection on a in [a1, 1])
    lo, hi = a1, mpf(1)
    for _ in range(200):
        mid = (lo+hi)/2
        if e_thm44(d,H,1,mid) >= e1 - mpf('0.001'): lo = mid
        else: hi = mid
    print(H,d,"| %.4f %.3g %.3g %.3g | %.4f | a=%.4g N0=%.4g N0/n=%.4g factor=%.4g" % (e1, a1, Kmem(d,M,a1,H), N0(d,M,a1), e15, lo, N0(d,M,lo), N0(d,M,lo)/M, N0(d,M,a1)/N0(d,M,lo)))
print()
print("Theorem 7.2 (optimized a) vs Prop 7.2a at a*, lambda=1")
for H,d in [(2,20),(2,30),(3,20),(2,60),(2,40),(3,30),(3,40),(4,30)]:
    M = mpf(2)**d
    a_opt, e_opt = maximize(lambda a: e_thm72(d,H,1,a), mpf(10)**-14, mpf(1))
    a1 = astar(d,H,1); e2 = e_thm72(d,H,1,a1,sharper=True)
    print(H,d,"Thm7.2 e'=%.4f at a=%.3g | Prop7.2a e''=%.4f c(K+t)/n=%.3g" % (e_opt, a_opt, e2, (Kmem(d,M,a1,H)+1)/M))
print()
print("Fixed a finite-d values")
for a in [mpf('0.1'), mpf('0.3')]:
    for H in [2,3]:
        print(a, H, ["%.6f" % e_thm44(d,H,1,a) for d in [20,30,40]])
