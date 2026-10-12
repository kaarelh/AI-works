#!/usr/bin/env python3
"""Independent recomputation of the numbers of Paper 2, Section 4 (teacher) and Appendix C.

Written from the formulas printed in paper-steeper/sections/teacher.tex and app-teacher.tex,
without importing or reading the track's check scripts. Deterministic (no randomness).
All logs base 2 unless ln. kappa is substituted for every occurrence of the machine constant.
"""
from math import log2, log, sqrt, ceil, inf, lgamma

def H(p):
    if p <= 0 or p >= 1: return 0.0
    return -p*log2(p) - (1-p)*log2(1-p)

def log2binom(n, k):
    return (lgamma(n+1) - lgamma(k+1) - lgamma(n-k+1))/log(2)

def jmin(Gam):
    """least integer j >= 0 with j - 2 log(j+1) > Gam"""
    j = 0
    while not (j - 2*log2(j+1) > Gam):
        j += 1
    return j

class Inst:
    def __init__(self, d, m, r, kappa=0.0, dS=0.0, B=inf):
        self.d, self.m, self.r, self.k, self.dS, self.B = d, m, r, kappa, dS, B
        self.p = 2.0**-r
        self.s0 = 2**(m-r)
        self.LS = log2binom(2**m, self.s0)
        self.BS = self.LS - dS
        self.H = H(self.p)
        if B == inf:
            self.tau = 0.0; self.beta = 0.0; self.logB = 0.0; self.twoB = 0.0
        else:
            self.tau = 2.0**(1-B); self.beta = 2**m*log2(1+self.tau); self.logB = 2*log2(B); self.twoB = 2.0**-B
        self.Lam1 = 2*log2(d) + 2*log2(m) + self.logB + self.beta + kappa
        self.kg = 2*log2(d) + 2*log2(r) + kappa
        self.kb = 2*log2(d) + 2*log2(m) + 2*log2(self.s0) + kappa
        self.tstar = (d - self.Lam1)/4
        self.Lam2 = 2**m*self.H - self.BS + 4 + self.Lam1 + self.kg
        self.Lam3 = 4 + 2*log2(d) + kappa
    def G(self, j):
        v = 0.0 if j == inf else 2.0**-j
        return 1 - log2(1 + v + 2*self.p + self.tau)
    def Phi2(self, c):
        if self.tstar >= 2:
            return min(c*(self.d - 8 - self.Lam1) + self.G(1), self.G(self.tstar - 1))
        return self.G(1)
    def Phi1(self, c):
        return c*(self.d - 4 - self.Lam1) + self.BS/2**self.m
    def Jg(self, c): return c*(self.d + self.kg) + self.H
    def Jb(self, c): return c*(self.d + ceil(self.LS) + self.kb)
    def chi(self):
        if self.tstar >= 2:
            return min((self.G(1) - self.H)/(8 + self.Lam1 + self.kg),
                       (self.G(self.tstar - 1) - self.H)/(self.d + self.kg))
        return (self.G(1) - self.H)/(self.d + self.kg)
    def ident(self, c, eps=0.0, g=None):
        """Theorem (ii) bounds; g optimised over 1..60 if None"""
        m = self.m
        assert c*2**m > 1
        Dl = self.kg + eps/c + (self.Lam2 + eps/c)/(c*2**m - 1)
        u = max(0.75, 2**-(self.Jg(c) + eps) - self.p - self.twoB)
        RB = self.H - (c*self.Lam2 + eps)/(c*2**m - 1)
        I = Dl + self.Lam3
        def ebound(gg):
            Gam = self.dS + Dl + self.Lam3 + 1 + 2*log2(m) + 2*log2(self.s0) + gg + 2*log2(gg) + self.k
            j = jmin(Gam)
            gam = sqrt(j*log(2)/(2*self.s0))
            return 1 - u + gam + 2.0**-gg
        if g is None:
            gbest = min(range(1, 61), key=ebound)
            e = ebound(gbest)
        else:
            gbest = g; e = ebound(g)
        return dict(u=u, Dl=Dl, I=I, LSK=self.dS + I, e=e, g=gbest, RB=RB,
                    ok=self.Jg(c) + eps < self.Phi2(c))
    def memo(self, c, eps=0.0):
        m = self.m
        rho = c*(ceil(self.LS) - self.LS + self.dS + 4 + self.Lam1 + self.kb) + eps
        cond = rho < (1 - c*2**m)*self.BS/2**m
        cond2 = self.Jb(c) + eps < self.Phi2(c)
        RB = rho/(1 - c*2**m)
        e = 2**(-RB/self.p) - self.twoB
        return cond, cond2, e
    def thr_iv(self):
        return self.H/(ceil(self.LS) + self.kb + 4 + self.Lam1)

def bisect(f, lo, hi, it=200):
    for _ in range(it):
        mid = (lo+hi)/2
        if f(mid): lo = mid
        else: hi = mid
    return lo

print("="*78)
print("(1) Hanni's calculation, Version 2")
p = 2.0**-10
Hp = H(p)
print(f"  H(2^-10) = {Hp:.6f}; p log(1/p) = {p*10:.6f}")
print(f"  model rate (1-H)/110 = {(1-Hp)/110:.6e}; error rate H/9990 = {Hp/9990:.6e}; ratio = {((1-Hp)/110)/(Hp/9990):.1f}")
print(f"  lambda=1 switch: n = 9990/H = {9990/Hp:.6e}")

print("="*78)
print("(2) instance at Hanni's sizes")
I0 = Inst(100, 20, 10)
print(f"  s0 = {I0.s0}, L_S = {I0.LS:.4f}, 2^m H(p) - L_S = {2**20*I0.H - I0.LS:.4f}, log(2^m+1) = {log2(2**20+1):.4f}")
pc = bisect(lambda q: (1 - log2(1.5 + 2*q)) > H(q), 1e-6, 0.2)
print(f"  crossover G_1 = H(p) at B = inf: p = {pc:.5f}")
for kap in (0.0, 30.0):
    I = Inst(100, 20, 10, kappa=kap)
    ch = I.chi()
    # check by bisection on Jg <= Phi2
    chb = bisect(lambda c: I.Jg(c) <= I.Phi2(c), 0.0, 1.0)
    print(f"  kappa={kap:4.0f}: Lam1={I.Lam1:.3f} kg={I.kg:.3f} kb={I.kb:.3f} t*={I.tstar:.3f} c_hi={ch:.5e} (bisect {chb:.5e}),"
          f" ratio c_hi*2^m = {ch*2**20:.1f}")

print("="*78)
print("(3) Table (a): identification at c = 1e-4 (g optimised)")
for kap in (0.0, 30.0):
    for dS in (0.0, 20.0):
        I = Inst(100, 20, 10, kappa=kap, dS=dS)
        r = I.ident(1e-4)
        print(f"  kappa={kap:3.0f} dS={dS:3.0f}: u>={r['u']:.4f} l<=d+{r['Dl']:.2f} I<={r['I']:.2f} LS-K<={r['LSK']:.2f}"
              f" e<={r['e']:.4f} (g={r['g']}) cond Jg<Phi2: {r['ok']}")
I = Inst(100, 20, 10)
r = I.ident(1e-3)
print(f"  c=1e-3 kappa=0 dS=0: u>={r['u']:.4f} e<={r['e']:.4f}")
for kap in (0.0, 30.0):
    I24 = Inst(100, 24, 10, kappa=kap)
    r = I24.ident(1e-4)
    print(f"  m=24 kappa={kap:.0f}: L_S={I24.LS:.1f} c_hi={I24.chi():.4e} e<={r['e']:.4f} (g={r['g']}) cond={r['ok']}")

print("="*78)
print("(4) Memoriser regime near 2^-m (Table (b)) and thresholds")
for kap in (0.0, 30.0):
    I = Inst(100, 20, 10, kappa=kap)
    row = []
    for x in (0.5, 0.8, 0.9, 0.94, 0.97, 0.99):
        cond, cond2, e = I.memo(x*2.0**-20)
        row.append(f"{x}:{max(e,0):.3f}{'' if (cond and cond2) else '(cond FAILS)'}")
    thr = bisect(lambda x: I.memo(x*2.0**-20)[0], 0.0, 1.0)
    half = bisect(lambda x: I.memo(x*2.0**-20)[2] >= 0.5, 0.0, 1.0)
    print(f"  kappa={kap:.0f}: " + "  ".join(row))
    print(f"     (iii) applies iff c < {thr:.5f}*2^-m; e>=1/2 iff c <= {half:.4f}*2^-m; threshold (iv) = {I.thr_iv()*2**20:.5f}*2^-m"
          f" = {I.thr_iv():.4e}")

print("="*78)
print("(5) Full table, m = d = 20")
for kap in (0.0, 30.0):
    I = Inst(20, 20, 10, kappa=kap)
    N = 2**20
    print(f"  kappa={kap:.0f}: t*={I.tstar:.3f}, c_hi={I.chi():.6f}, window lambda in (1, {N*I.chi():.1f}]")
for kap in (0.0, 30.0):
    for dE in (0.0, 20.0):
        I = Inst(20, 20, 10, kappa=kap, dS=dE)
        N = 2**20
        out = []
        for lam in (2, 105):
            r = I.ident(lam/N)
            out.append(f"lam={lam}: u>={r['u']:.3f} l<=d+{r['Dl']:.1f} I<={r['I']:.1f} e<={r['e']:.3f}")
        print(f"  kappa={kap:.0f} dE={dE:.0f}: " + " | ".join(out))

print("="*78)
print("(6) Finite samples (B = 30, delta = 0.01, kappa = 0, dS = 0, g = 7)")
def finite(c, n, B=30, delta=0.01, kap=0.0, g=7, d=100, m=20, r=10):
    I = Inst(d, m, r, kappa=kap, B=B)
    A = log2(1/I.p)
    eps1 = A*sqrt(log(2/delta)/(2*n))
    Ihat = Inst(d, m, r, kappa=kap)  # J_g does not depend on B
    Lhat = (I.Jg(c) + eps1)/c
    epsn = eps1 + B*sqrt((Lhat*log(2) + log(2/delta))/(2*n))
    res = I.ident(c, eps=epsn, g=g)
    return epsn, res, I
for (c, n) in ((1e-4, 1e11), (1e-4, 1e13), (1e-3, 1e11), (1e-4, 1e9)):
    epsn, res, I = finite(c, n)
    print(f"  c={c:g} n={n:g}: eps_n/c={epsn/c:.2f} u>={res['u']:.4f} l<=d+{res['Dl']:.1f} e<={res['e']:.3f} cond={res['ok']}")

print("="*78)
print("(7) Version 1: d=100, m=10, r=6")
for kap in (0, 5, 10, 20, 30):
    I = Inst(100, 10, 6, kappa=kap)
    print(f"  kappa={kap}: L_S={I.LS:.3f} H={I.H:.4f} c_hi={I.chi():.4e} lambda window at n=1e4: ({1e4*2**-10:.3f}, {1e4*I.chi():.2f}]")
I = Inst(100, 10, 6)
for c in (1.5e-3, 2.5e-3, 4e-3, 5.5e-3):
    r = I.ident(c)
    print(f"  c={c:g}: u>={r['u']:.3f} (raw {2**-I.Jg(c)-I.p:.4f}) l<=d+{r['Dl']:.1f} I<={r['I']:.1f} e<={r['e']:.3f}")
print(f"  threshold (iv) = {I.thr_iv():.4e}")
print(f"  n=1e4 savings: model {1e4*(1-I.H):.0f} bits, error rule {1e4*I.H:.0f} bits, ratio per bit {1e4*I.H/I.LS:.2f}")
# finite sample at n=1e4: excess >= B*sqrt((d-4-Lam1(B))*ln2/(2n)) for admissible B; compare margin Phi2-Jg
n = 1e4
lowest = min(B*sqrt(((100 - 4 - 2*log2(100)) )*log(2)/(2*n)) for B in range(6, 200))
lam1inf = Inst(100, 10, 6).Lam1
print(f"  finite-sample excess lower bound with d-4-Lam1(inf) = {100-4-lam1inf:.2f}: {6*sqrt((100-4-lam1inf)*log(2)/(2*n)):.4f};"
      f" with the sharper (D1) constant d-4-2log d: min over B>=6 of B*sqrt(...) = {lowest:.4f}")
best_margin = 0.0
for B in [inf] + list(range(6, 60)):
    Ib = Inst(100, 10, 6, B=B)
    ch = Ib.chi()
    lo = 2.0**-10
    for k in range(2001):
        c = lo + (ch - lo)*k/2000
        best_margin = max(best_margin, Ib.Phi2(c) - Ib.Jg(c))
print(f"  max margin Phi2 - Jg over the window and B: {best_margin:.4f}")
# comparison full-table instance d=13, m=10, r=6
for kap in (0, 10, 30):
    I = Inst(13, 10, 6, kappa=kap)
    print(f"  d=13 m=10 r=6 kappa={kap}: lambda window ({2**13*2**-10:.0f}, {2**13*I.chi():.1f}]")

print("="*78)
print("(8) Concentration example")
I = Inst(100, 20, 10)
c, eps, n = 1e-4, 1e-3, 1e6
Jg = I.Jg(c)
print(f"  J_g(1e-4) = {Jg:.6f}; exponent -n eps + (J_g+eps)/c = {-n*eps + (Jg+eps)/c:.2f}")
B, delta, n2 = 30, 0.01, 1e13
eps1 = 10*sqrt(log(2/delta)/(2*n2))
Lp = (Jg + eps1 + eps)/c
epsp = eps + eps1 + B*sqrt((Lp*log(2) + log(2/delta))/(2*n2))
IB = Inst(100, 20, 10, B=30)
print(f"  L' = {Lp:.2f} bits, eps' = {epsp:.5e}, cond J_g + eps' < Phi2 (B=30): {Jg + epsp < IB.Phi2(c)}")

print("="*78)
print("(9) Per-input pricing example F = {(a,a),(a,b),(b,a),(c,a)}")
import itertools
best = (0, None)
# maximise H(q1+q2, q3, q4) + H(q1+q3+q4, q2) over the simplex by a fine grid + local refinement
import numpy as np
def obj(q):
    q = np.maximum(q, 0); q = q/q.sum()
    a1 = np.array([q[0]+q[1], q[2], q[3]]); a2 = np.array([q[0]+q[2]+q[3], q[1]])
    f = lambda v: -sum(x*np.log2(x) for x in v if x > 0)
    return f(a1) + f(a2)
from scipy.optimize import minimize
bestv = 0
rng = np.random.default_rng(11)
for _ in range(200):
    x0 = rng.dirichlet(np.ones(4))
    res = minimize(lambda q: -obj(q), x0, method='Nelder-Mead', options=dict(xatol=1e-12, fatol=1e-14, maxiter=20000))
    bestv = max(bestv, -res.fun)
print(f"  max_Q sum_i H(Q_xi) = {bestv:.5f}; log3+log2 = {log2(3)+1:.5f}")
