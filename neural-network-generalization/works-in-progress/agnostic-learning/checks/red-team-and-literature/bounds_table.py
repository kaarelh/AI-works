"""Explicit finite-d values of the bounds proved in redteam.md (Theorem A, Theorem A2).
Uses the high-probability approximations Q/M ~ beta(lambda), G/M ~ 1-e^{-lambda}, V/M ~ lambda (lambda=1)."""
import math
beta = 0.4848291069956878; lam = 1.0
def FD(d): return 1 + (d+1)*(d+2)**2
print("Theorem A (H>=2, c=1): residual budget eps_d = R/n and excess lower bound (sqrt(beta)-sqrt(lam*eps))^2")
for H in [2, 3]:
    for d in [20, 30, 40, 50, 60]:
        n = 2**d
        best = None
        for e in range(1, 400):
            a = 10**(-e/40)
            if a > 1: continue
            Kmem = d*FD(d) + (H+1)*max(2, 9/(2*a), (9*d*n)**(1/H))
            R = Kmem + n*a*a + 1
            if best is None or R < best[0]: best = (R, a, Kmem)
        R, a, Kmem = best
        eps = R/n
        lb = max(0.0, math.sqrt(beta) - math.sqrt(lam*eps))**2
        m = math.ceil(8*9*d*n*math.log(2**(d+1))/a**2) + 1
        print(f"  H={H} d={d}: a={a:.2e} K_mem={Kmem:.3e} eps_d={eps:.4f} excess_LB={lb:.4f}  width N0~{m:.2e}")
print("Theorem A2 (H=1, c=1): excess >= (theta*G - E0)^2/(4 M V), theta=1/(18d+1), E0 = d F_d + 3")
for d in [30, 35, 40, 50, 60]:
    M = 2**d; G = (1-math.exp(-lam))*M; V = lam*M
    th = 1/(18*d+1); E0 = d*FD(d) + 3
    lb = max(0.0, th*G - E0)**2/(4*M*V)
    print(f"  d={d}: theta={th:.2e} excess_LB={lb:.3e}  (asymptotic {th**2*(1-math.exp(-lam))**2/(4*lam):.3e})")
