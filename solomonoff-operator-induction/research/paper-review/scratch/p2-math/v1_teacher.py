"""Independent re-computation of the numbers of Paper 2, Section 4 (teacher's-mistakes theorem)
and its appendix. Written from the paper's own definitions (teacher.tex, app-teacher.tex), not from
the track scripts. Deterministic (no randomness).

Conventions: log = log2; kappa is the machine constant, set to 0 or 30 as in the paper.
"""
import math
from math import log2, sqrt, ceil, lgamma, log

LN2 = math.log(2)

def H(p):
    if p <= 0 or p >= 1:
        return 0.0
    return -p*log2(p) - (1-p)*log2(1-p)

def log2binom(n, k):
    # exact via lgamma (double precision is ample at these sizes); cross-checked with big ints below
    return (lgamma(n+1) - lgamma(k+1) - lgamma(n-k+1)) / LN2

def log2binom_exact(n, k):
    c = math.comb(n, k)
    # log2 of a big int
    b = c.bit_length()
    shift = max(0, b - 60)
    return log2(c >> shift) + shift

class Inst:
    def __init__(self, d, m, r, kappa=0.0, B=math.inf, deltaS=0.0, Lexact=True):
        self.d, self.m, self.r, self.kappa, self.B, self.deltaS = d, m, r, kappa, B, deltaS
        self.p = 2.0**(-r)
        self.s0 = 2**(m-r)
        self.LS = log2binom_exact(2**m, self.s0) if Lexact else log2binom(2**m, self.s0)
        self.BS = self.LS - deltaS
        self.Hp = H(self.p)
        if B == math.inf:
            self.tau = 0.0; self.beta = 0.0; self.logB = 0.0
        else:
            self.tau = 2.0**(1-B); self.beta = 2**m * log2(1+self.tau); self.logB = 2*log2(B)
        self.Lam1 = 2*log2(d) + 2*log2(m) + self.logB + self.beta + kappa
        self.kg = 2*log2(d) + 2*log2(r) + kappa
        self.kb = 2*log2(d) + 2*log2(m) + 2*log2(self.s0) + kappa if self.s0 > 1 else 2*log2(d) + 2*log2(m) + kappa
        self.tstar = (d - self.Lam1)/4
        self.Lam3 = 4 + 2*log2(d) + kappa

    def G(self, j):
        v = 0.0 if j == math.inf else 2.0**(-j)
        return 1 - log2(1 + v + 2*self.p + self.tau)

    def Phi1(self, c):
        return c*(self.d - 4 - self.Lam1) + self.BS/2**self.m

    def Phi2(self, c):
        if self.tstar >= 2:
            return min(c*(self.d - 8 - self.Lam1) + self.G(1), self.G(self.tstar - 1))
        return self.G(1)

    def Jg(self, c):
        return c*(self.d + self.kg) + self.Hp

    def Jb(self, c):
        return c*(self.d + ceil(self.LS) + self.kb)

    def chi(self):
        if self.tstar >= 2:
            return min((self.G(1)-self.Hp)/(8+self.Lam1+self.kg), (self.G(self.tstar-1)-self.Hp)/(self.d+self.kg))
        return (self.G(1)-self.Hp)/(self.d+self.kg)

    def Lam2(self):
        return 2**self.m*self.Hp - self.BS + 4 + self.Lam1 + self.kg

    def Dell(self, c, eps=0.0):
        return self.kg + eps/c + (self.Lam2() + eps/c)/(c*2**self.m - 1)

    def ident(self, c, eps=0.0, gmax=40):
        assert c*2**self.m > 1 and self.Jg(c) + eps < self.Phi2(c)
        u_lo = max(0.75, 2.0**(-(self.Jg(c)+eps)) - self.p - (0 if self.B == math.inf else 2.0**(-self.B)))
        Dl = self.Dell(c, eps)
        I = Dl + self.Lam3
        best = (9e9, None)
        for g in range(1, gmax+1):
            Gam = self.deltaS + Dl + self.Lam3 + 1 + 2*log2(self.m) + 2*log2(self.s0) + g + 2*log2(g) + self.kappa
            j = 0
            while not (j - 2*log2(j+1) > Gam):
                j += 1
            gam = sqrt(j*LN2/(2*self.s0))
            e = 1 - u_lo + gam + 2.0**(-g)
            if e < best[0]:
                best = (e, g)
        return dict(u=u_lo, ell=Dl, I=I, LminusK=self.deltaS + I, e=best[0], g=best[1])

    def memoriser(self, c, eps=0.0):
        """Theorem (iii): returns (applies?, lower bound on e)."""
        assert c*2**self.m < 1
        rho = c*(ceil(self.LS) - self.LS + self.deltaS + 4 + self.Lam1 + self.kb) + eps
        lev1 = self.Jb(c) + eps < self.Phi2(c)
        cond = rho < (1 - c*2**self.m)*self.BS/2**self.m
        if not (lev1 and cond):
            return False, None
        RB = rho/(1 - c*2**self.m)
        e = 2.0**(-RB/self.p) - (0 if self.B == math.inf else 2.0**(-self.B))
        return True, e

    def thr_iv(self):
        return self.Hp/(ceil(self.LS) + self.kb + 4 + self.Lam1)


def bisect(f, lo, hi, it=200):
    flo = f(lo)
    for _ in range(it):
        mid = (lo+hi)/2
        if (f(mid) > 0) == (flo > 0):
            lo = mid; flo = f(mid)
        else:
            hi = mid
    return (lo+hi)/2


def main():
    out = []
    P = out.append
    # --- Hanni's calculation (rem:teacher:hanni)
    p = 2.0**-10
    P("== Hanni Version 2 ==")
    P(f"H(2^-10)={H(p):.5f}  p*log(1/p)={p*10:.5f}")
    rate_model = (1-H(p))/110; rate_err = H(p)/9990
    P(f"rate model (1-H)/110={rate_model:.4e}  rate errors H/9990={rate_err:.4e}  ratio={rate_model/rate_err:.1f}")
    P(f"lambda=1 switch n = 9990/H(p) = {9990/H(p):.1f}")
    # Version 1 three hypotheses: coin (0,R=?), simple(100), simple+errors(200) slopes 100 and 10
    P("Version 1: slopes 100 (coin->simple) and 10 (simple->simple+err): simple selected iff lambda in (10,100)")

    # --- L_S
    I0 = Inst(100, 20, 10)
    P(f"L_S(2^20,1024) exact = {I0.LS:.3f}; lgamma version {log2binom(2**20,1024):.3f}")
    P(f"2^m H(p) = {2**20*H(p):.3f}; bounds [2^mH - log(2^m+1), 2^mH] = [{2**20*H(p)-log2(2**20+1):.3f}, {2**20*H(p):.3f}]")

    # --- crossover G_1 = H(p) at B = inf
    f = lambda q: (1 - log2(1.5 + 2*q)) - H(q)
    P(f"crossover G1=H(p): p = {bisect(f, 1e-6, 0.2):.5f}")

    # --- windows
    P("== Window at Hanni's sizes (B=inf) ==")
    for kap in (0, 30):
        I = Inst(100, 20, 10, kappa=kap)
        ch = I.chi()
        P(f"kappa={kap}: Lam1={I.Lam1:.3f} kg={I.kg:.3f} kb={I.kb:.3f} t*={I.tstar:.3f} c_hi={ch:.4e} 2^-m={2**-20:.4e} ratio={ch*2**20:.1f}")
        # check closed form vs bisection on Jg <= Phi2
        g = lambda c: I.Jg(c) - I.Phi2(c)
        cb = bisect(g, 1e-9, 0.5)
        P(f"   bisection c_hi={cb:.6e}; Delta(c_hi)?; Phi1 vs Phi2 at 1e-4: {I.Phi1(1e-4):.5f} {I.Phi2(1e-4):.5f}")

    # --- identification table
    P("== Identification at c=1e-4 (B=inf, eps=0, g optimised 1..40) ==")
    for kap in (0, 30):
        for dS in (0, 20):
            I = Inst(100, 20, 10, kappa=kap, deltaS=dS)
            r = I.ident(1e-4)
            P(f"kappa={kap} deltaS={dS}: u>={r['u']:.4f} ell<=d+{r['ell']:.2f} I<={r['I']:.2f} LS-K<={r['LminusK']:.2f} e<={r['e']:.4f} (g={r['g']})")
    # also c=1e-3 kappa=0
    I = Inst(100, 20, 10)
    r = I.ident(1e-3)
    P(f"c=1e-3 kappa=0: u>={r['u']:.4f} e<={r['e']:.4f}")
    # m=24
    for kap in (0, 30):
        I = Inst(100, 24, 10, kappa=kap)
        r = I.ident(1e-4)
        P(f"m=24 kappa={kap}: L_S={I.LS:.1f} c_hi={I.chi():.4e} e<={r['e']:.4f} (g={r['g']})")

    # --- memoriser regime
    P("== Memoriser regime (iii) near 2^-m, deltaS=0 ==")
    for kap in (0, 30):
        I = Inst(100, 20, 10, kappa=kap)
        row = []
        for x in (0.5, 0.8, 0.9, 0.94, 0.97, 0.99):
            ok, e = I.memoriser(x*2**-20)
            row.append(f"{x}:{'n/a' if not ok else f'{e:.3f}'}")
        # threshold where condition stops
        fcond = lambda x: (x*2**-20*(ceil(I.LS)-I.LS+I.deltaS+4+I.Lam1+I.kb)) - (1-x)*I.BS/2**20
        xc = bisect(fcond, 0.5, 0.99999)
        # e>=1/2 threshold
        def fe(x):
            ok, e = I.memoriser(x*2**-20)
            return (e if ok else 0) - 0.5
        xe = bisect(fe, 0.5, xc - 1e-9)
        P(f"kappa={kap}: {'  '.join(row)}; (iii) applies iff c < {xc:.5f}*2^-m; e>=1/2 iff c <= {xe:.4f}*2^-m; (iv) threshold = {I.thr_iv()*2**20:.5f}*2^-m")

    # --- full truth table d=m=20
    P("== Full truth table d=m=20, p=2^-10 ==")
    for kap in (0, 30):
        I = Inst(20, 20, 10, kappa=kap)
        N = 2**20
        P(f"kappa={kap}: t*={I.tstar:.3f} c_hi={I.chi():.6f} N*c_hi={N*I.chi():.1f}  L_E={I.LS:.2f}")
        for dS in (0, 20):
            J = Inst(20, 20, 10, kappa=kap, deltaS=dS)
            for lam in (2, 105):
                c = lam/N
                r = J.ident(c)
                P(f"   deltaE={dS} lambda={lam}: u>={r['u']:.4f} ell<=d+{r['ell']:.2f} I<={r['I']:.2f} e<={r['e']:.4f} (g={r['g']})")
    P(f"T5 heuristic (1-H(p))/d at d=20: {(1-H(p))/20:.4f}")

    # --- sampled data
    P("== Finite sample (Cor sampled), B=30, delta=0.01, kappa=0, deltaS=0, g=7 ==")
    def sampled(c, n, B=30, delta=0.01, kap=0, g=7):
        I = Inst(100, 20, 10, kappa=kap, B=B)
        A = 10.0
        eps1 = A*sqrt(log(2/delta)/(2*n))
        Jpig = I.Jg(c)  # J_c(pi_g) <= J_g(c); the paper uses J_c(pi_g); take the bound
        Lhat = (Jpig + eps1)/c
        epsn = eps1 + B*sqrt((Lhat*LN2 + log(2/delta))/(2*n))
        ok = I.Jg(c) + epsn < I.Phi2(c)
        u_lo = max(0.75, 2.0**(-(I.Jg(c)+epsn)) - I.p - 2.0**(-B))
        Dl = I.Dell(c, epsn)
        Gam = I.deltaS + Dl + I.Lam3 + 1 + 2*log2(I.m) + 2*log2(I.s0) + g + 2*log2(g) + I.kappa
        j = 0
        while not (j - 2*log2(j+1) > Gam):
            j += 1
        e = 1 - u_lo + sqrt(j*LN2/(2*I.s0)) + 2.0**(-g)
        return epsn/c, u_lo, Dl, e, ok, Lhat, eps1, epsn
    for (c, n) in ((1e-4, 1e11), (1e-4, 1e13), (1e-3, 1e11), (1e-4, 1e9)):
        x = sampled(c, n)
        P(f"c={c:g} n={n:g}: eps_n/c={x[0]:.2f} u>={x[1]:.4f} ell<=d+{x[2]:.2f} e<={x[3]:.3f} cond J_g+eps_n<Phi2: {x[4]}")

    # --- concentration example
    P("== Concentration ==")
    I = Inst(100, 20, 10)
    c, eps, n = 1e-4, 1e-3, 1e6
    Jg = I.Jg(c)
    P(f"J_g(1e-4)={Jg:.5f}; exponent -n*eps + (J_g+eps)/c = {-n*eps + (Jg+eps)/c:.2f}")
    # eps' at n=1e13, B=30, delta=0.01
    I30 = Inst(100, 20, 10, B=30)
    n = 1e13; delta = 0.01; B = 30
    eps1 = 10*sqrt(log(2/delta)/(2*n))
    Lp = (I30.Jg(c) + eps1 + eps)/c
    epsp = eps + eps1 + B*sqrt((Lp*LN2 + log(2/delta))/(2*n))
    P(f"L'={Lp:.2f} eps'={epsp:.5e} cond J_g+eps'<Phi2: {I30.Jg(c)+epsp < I30.Phi2(c)}  (note J_g at B=30 uses kappa_g which has no B term: {I30.Jg(c):.5f})")

    # --- Version 1
    P("== Version 1: d=100 m=10 r=6 ==")
    for kap in (0, 5, 10, 20, 30):
        I = Inst(100, 10, 6, kappa=kap)
        P(f"kappa={kap}: L_S={I.LS:.2f} H={I.Hp:.4f} c_hi={I.chi():.4e} lambda window at n=1e4: ({2**-10*1e4:.2f}, {I.chi()*1e4:.1f}]")
    I = Inst(100, 10, 6)
    for c in (1.5e-3, 2.5e-3, 4e-3, 5.5e-3):
        Dl = I.Dell(c); u_lo = max(0.75, 2.0**(-I.Jg(c)) - I.p)
        u_raw = 2.0**(-I.Jg(c)) - I.p
        r = I.ident(c)
        P(f"  c={c:g}: ell<=d+{Dl:.1f} I<={Dl+I.Lam3:.1f} u_raw={u_raw:.3f} e<={r['e']:.3f}")
    P(f"  threshold (iv) = {I.thr_iv():.4e}")
    n = 1e4
    lowB = 6*sqrt((I.d - 4 - I.Lam1)*LN2/(2*n))
    P(f"  finite-sample excess lower bound 6*sqrt((d-4-Lam1(inf))ln2/2n) = {lowB:.3f}")
    # margin Phi2 - Jg maximum over window and B
    best = 0
    for B in [6, 7, 8, 10, 12, 15, 20, 30, 50, math.inf]:
        J = Inst(100, 10, 6, B=B)
        if J.chi() <= 2**-10:
            continue
        for k in range(1, 2001):
            c = 2**-10 + (J.chi() - 2**-10)*k/2000
            best = max(best, J.Phi2(c) - J.Jg(c))
    P(f"  max margin Phi2-Jg over window and B: {best:.3f}")
    # d=13 full table instance
    for kap in (0, 10, 30):
        J = Inst(13, 10, 6, kappa=kap)
        P(f"  d=13 m=10 r=6 kappa={kap}: c_hi={J.chi():.4e}, lambda window (N=2^13): ({2**-10*2**13:.0f}, {J.chi()*2**13:.1f}]")

    return "\n".join(out)

if __name__ == "__main__":
    print(main())
