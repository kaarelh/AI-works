"""Independent checks for Paper 2: envelope e1 under the simplified bound, the per-input pricing
example (minimax value), stream-prefix and hashing costs, and the algorithmic-statistics table
(prop:algstat:parity (iv)), including whether the tabulated g is optimal for the range of b."""
import math, itertools
from math import log2, sqrt, ceil, log
import importlib.util, os
import numpy as np
from scipy.optimize import minimize

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("v1", os.path.join(here, "v1_teacher.py"))
v1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(v1)
H, Inst, bisect, log2binom_exact = v1.H, v1.Inst, v1.bisect, v1.log2binom_exact
LN2 = math.log(2)
out = []; P = out.append

# ---- envelope e1 with the simplified bound for c >= 2^-m and K(S1) <= 2log(j+1)+2log m
d, m = 100, 20
for j in (11, 13):
    s1 = 2**(m-j); s2 = 1024 - s1; p1 = s1/2**m
    I = Inst(100, 20, 10)
    k1 = 2*log2(j+1)
    ke = 2*log2(d) + 2*log2(m) + 2*log2(s2+1)
    KS1 = 2*log2(j+1) + 2*log2(m)
    for d2 in (0, 20):
        row = []
        for c in (1.01*2**-m, 2e-6, 5e-6, 1e-5, 3e-5):
            zeta = c*(k1 + ke + 4 + I.Lam1)
            R1 = (zeta + (d2 + log2(2**m+1) + KS1)/2**m)/p1
            row.append(f"{2.0**(-R1):.3f}")
        P(f"envelope j={j} delta2={d2} simplified bound: e1 >= " + ", ".join(row))

# ---- per-input pricing example: F={(a,a),(a,b),(b,a),(c,a)}
F = [("a","a"),("a","b"),("b","a"),("c","a")]
def val(q):
    q = np.clip(q, 1e-15, None); q = q/q.sum()
    Q1 = {}; Q2 = {}
    for w, f in zip(q, F):
        Q1[f[0]] = Q1.get(f[0], 0) + w; Q2[f[1]] = Q2.get(f[1], 0) + w
    h = lambda D: -sum(v*log2(v) for v in D.values() if v > 0)
    return h(Q1) + h(Q2)
best = 0
for a in np.linspace(0, 1, 41):
    for b in np.linspace(0, 1-a, 21):
        for c in np.linspace(0, 1-a-b, 21):
            dd = 1-a-b-c
            v = val(np.array([a,b,c,dd]))
            if v > best:
                best, arg = v, (a,b,c,dd)
res = minimize(lambda x: -val(np.abs(x)), np.array(arg)+1e-3, method="Nelder-Mead", options=dict(xatol=1e-12, fatol=1e-14, maxiter=20000))
P(f"pricing example: max_Q sum H(Q_x) = {-res.fun:.4f} at Q={np.round(np.abs(res.x)/np.abs(res.x).sum(),4)}; log3+log2={log2(3)+1:.4f}")
# primal: min over nu of max_f loss; nu1 on {a,b,c}, nu2 on {a,b}
def primal(x):
    n1 = np.exp(x[:3]); n1 /= n1.sum(); n2 = np.exp(x[3:]); n2 /= n2.sum()
    idx1 = {"a":0,"b":1,"c":2}; idx2 = {"a":0,"b":1}
    return max(-log2(n1[idx1[f[0]]]) - log2(n2[idx2[f[1]]]) for f in F)
bestp = min((minimize(primal, np.random.default_rng(s).normal(size=5), method="Nelder-Mead", options=dict(maxiter=20000, xatol=1e-12, fatol=1e-14)).fun for s in range(20)))
P(f"pricing example: min_nu max_f loss = {bestp:.4f}")

# ---- stream-prefix costs and hashing costs
def stream(dd, n, beta):
    iD = ceil(log2(6*n/beta)); tD = ceil(log2(2*dd + 2 + 2*log2(iD+1)))
    return iD, tD, 2*log2(tD+1)
def hashc(dd, n, r):
    return 2*log2(n+1) + 2*log2(dd+1) + 2*log2(r+1)
for (dd, n, beta, r) in ((20, 1e3, 1/3, 2), (100, 1e6, 1/3, 2), (100, 1e6, 2**-10, 10), (1000, 1e12, 1e-3, 10), (10**6, 1e15, 1/3, 2)):
    iD, tD, cost = stream(dd, n, beta)
    P(f"stream d={dd} n={n:g} beta={beta:.4g}: i_D={iD} t_D={tD} cost={cost:.2f}; hashing r={r}: {hashc(dd, n, r):.1f}")
# check 2^{2^t} >= (2^{d+1}(i+1))^2 at the chosen t (in logs)
for (dd, n, beta) in ((20, 1e3, 1/3), (100, 1e6, 1/3)):
    iD, tD, _ = stream(dd, n, beta)
    P(f"   d={dd}: 2^tD={2**tD} >= 2d+2+2log(iD+1)={2*dd+2+2*log2(iD+1):.2f}: {2**tD >= 2*dd+2+2*log2(iD+1)}")

# ---- algstat (iv) table
def Fband(dd, p, t, g, kap, dE=0.0):
    N = 2**dd; s0 = round(p*N)
    budget = dE + dd + 1 + 2*log2(dd) + 2*log2(s0) + g + 2*log2(g) + kap
    j = 0
    while not (j - 2*log2(j+1) > budget):
        j += 1
    gam = sqrt(j*LN2/(2*s0))
    return 1 - log2(1 + (1-2*p)*2.0**(-t) + 2*p*(2*gam + 2.0**(1-g)))
def Kp(h, e):
    return 2*log2(h+1) + 2*log2(e+1)
def row(dd, p, h, e, kap, t=2, g=None, dE=0.0):
    N = 2**dd; s0 = round(p*N)
    LE = log2binom_exact(N, s0) if dd <= 20 else v1.log2binom(N, s0)
    kg = 2*log2(dd) + Kp(h, e) + kap
    kb = 4*log2(dd) + 2*log2(s0) + kap
    Lam1 = 4*log2(dd) + kap
    st = 2*t + 2*log2(t+1)
    lo = dE + 2*log2(dd) + kg + log2(N+1) + kap
    def up(gg):
        return N*Fband(dd, p, t, gg, kap, dE) - dd - ceil(LE) - kb - 2*kap
    if g is None:
        # smallest admissible g (F_t > H(p))
        g = next(gg for gg in range(1, 60) if Fband(dd, p, t, gg, kap, dE) > H(p))
    gbest = max(range(1, 60), key=up)
    return dict(lower=st + Lam1, upper=kg, blo=lo, bup=up(g), g=g, gbest=gbest, bup_best=up(gbest), Fg=Fband(dd, p, t, g, kap, dE), H=H(p))
ps = [(1/8, 1, 3), (3/16, 3, 4), (7/32, 7, 5), (15/64, 15, 6)]
for kap in (0, 30):
    for dd in (20, 30, 60, 100):
        rs = [row(dd, p, h, e, kap) for (p, h, e) in ps]
        P(f"kappa={kap} d={dd}: lower d-{rs[0]['lower']:.1f}; upper d+" + "/".join(f"{r['upper']:.1f}" for r in rs)
          + f"; b-range p=1/8: [{rs[0]['blo']:.0f}, {rs[0]['bup']:.3g}) (g={rs[0]['g']}; best g={rs[0]['gbest']} gives {rs[0]['bup_best']:.3g})"
          + f"; p=15/64: [{rs[3]['blo']:.0f}, {rs[3]['bup']:.3g}) (g={rs[3]['g']}; best g={rs[3]['gbest']} gives {rs[3]['bup_best']:.3g})")
# F2 - H range at d>=30
gaps = []
for kap in (0,):
    for dd in (30, 60, 100):
        for (p, h, e) in ps:
            r = row(dd, p, h, e, kap)
            gaps.append(r['Fg'] - r['H'])
P(f"F_2-H(p) at d>=30 (kappa=0, tabulated g): min {min(gaps):.3f} max {max(gaps):.3f}")

# ---- prop:algstat:parity (ii) admissibility at p=1/64 (G1>H)
p = 1/64
G1 = 1 - log2(1.5 + 2*p)
P(f"(ii) p=1/64: G1={G1:.4f} H={H(p):.4f}")

print("\n".join(out))
