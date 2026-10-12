"""Extra checks: (1) Theorem 2 bounds for the j=13 envelope rule (deficiency ~1,290 bits) above c_env;
(2) finite-sample corollary at n = 1e7, 1e8, 1e9 (is 1e11 really needed?);
(3) Theorem 2 bounds for the j=11 envelope rule (deficiency ~5,350)."""
import math, importlib.util, os
from math import log2, sqrt, log, ceil
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("v1", os.path.join(here, "v1_teacher.py"))
v1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(v1)
Inst, H = v1.Inst, v1.H
LN2 = math.log(2)
LS = v1.log2binom_exact(2**20, 1024)
for (j, L2) in ((13, v1.log2binom_exact(2**20-128, 896)), (11, v1.log2binom_exact(2**20-512, 512))):
    # B_S <= K(S1,S2 | a, K(a)) + O(1) <= L2 + 2log(j+1) + 2log 20 + 2log(s2+1)   (kappa = 0)
    s2 = 1024 - 2**(20-j)
    BS_upper = L2 + 2*log2(j+1) + 2*log2(20) + 2*log2(s2+1)
    dS = LS - BS_upper   # lower bound on the deficiency; the theorem's bounds grow with deltaS, so use this and also +50
    for extra in (0, 50):
        I = Inst(100, 20, 10, deltaS=dS+extra)
        for c in (1.64e-5, 1e-4, 1e-3):
            if c*2**20 > 1 and I.Jg(c) < I.Phi2(c):
                r = I.ident(c, gmax=60)
                Delta = max(0, c*(4+I.Lam1+I.kg) + I.Hp - I.BS/2**20)
                print(f"j={j} deltaS={dS+extra:.0f} c={c:g}: Delta(c)={Delta:.2e} u>={r['u']:.3f} ell<=d+{r['ell']:.1f} I<={r['I']:.1f} e<={r['e']:.3f} (g={r['g']})")
# finite sample at smaller n
def sampled(c, n, B=30, delta=0.01, g=None):
    I = Inst(100, 20, 10, B=B)
    eps1 = 10*sqrt(log(2/delta)/(2*n))
    Lhat = (I.Jg(c) + eps1)/c
    epsn = eps1 + B*sqrt((Lhat*LN2 + log(2/delta))/(2*n))
    ok = I.Jg(c) + epsn < I.Phi2(c)
    if not ok: return None
    u_lo = max(0.75, 2.0**(-(I.Jg(c)+epsn)) - I.p - 2.0**(-B))
    Dl = I.Dell(c, epsn)
    best = 9
    for gg in range(1, 40):
        Gam = Dl + I.Lam3 + 1 + 2*log2(20) + 2*log2(1024) + gg + 2*log2(gg)
        jj = 0
        while not (jj - 2*log2(jj+1) > Gam): jj += 1
        best = min(best, 1 - u_lo + sqrt(jj*LN2/(2*1024)) + 2.0**-gg)
    return epsn/c, u_lo, Dl, Dl + I.Lam3, best
for n in (1e6, 1e7, 1e8, 1e9, 1e10):
    for c in (1e-4, 1e-3):
        x = sampled(c, n)
        print(f"sampled c={c:g} n={n:g}: " + ("condition fails" if x is None else f"eps_n/c={x[0]:.1f} u>={x[1]:.3f} ell<=d+{x[2]:.1f} I<={x[3]:.1f} e<={x[4]:.3f}"))
