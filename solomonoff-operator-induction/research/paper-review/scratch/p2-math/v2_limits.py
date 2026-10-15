"""Independent re-computation of the numbers of Paper 2, Section 5 (limits) and its appendix,
from the paper's definitions. Deterministic."""
import math
from math import log2, sqrt, ceil, log
import importlib.util, os, sys

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("v1", os.path.join(here, "v1_teacher.py"))
v1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(v1)
H, Inst, bisect, log2binom_exact = v1.H, v1.Inst, v1.bisect, v1.log2binom_exact
LN2 = math.log(2)

out = []
P = out.append

# ---- prop:limits:plain (a)
I = Inst(100, 20, 10)
exc = 100 + ceil(I.LS) + I.kb + 0
nerr = 2**90
P(f"(a) exceptions <= {exc:.1f}; error inputs {nerr:.4e}; fraction {exc/nerr:.3e}")

# ---- (b) schedules, B=30, delta=0.01, kappa=0
def eb(lam, n, B=30, delta=0.01):
    Lhat = 100 + ceil(I.LS) + I.kb
    RB = lam*Lhat/n + B*sqrt((Lhat*LN2 + log(2/delta))/(2*n))
    return max(0.0, 2.0**(-RB/I.p) - 2.0**(-B))
for n in (1e12, 1e13, 1e15, 1e17):
    P(f"(b) lambda=1 n={n:g}: e>={eb(1,n):.3f};  lambda=sqrt(n): e>={eb(sqrt(n),n):.3f};  lambda=n^0.9: e>={eb(n**0.9,n):.3f}")

# ---- rate blindness, three-hypothesis margins at d=100 (kappa=0, lengths = upper bounds)
for m in (6, 7, 8):
    r = m  # single m-bit prefix: s0=1, p=2^-m
    J = Inst(100, m, r)
    lg = 100 + J.kg; lb = 100 + ceil(J.LS) + J.kb
    lhs = J.Hp/(lb-lg); rhs = (1-J.Hp)/(lg-0)
    margin = J.Hp/rhs - (lb-lg)
    P(f"rate-blind (i) single {m}-bit prefix: L_S={J.LS:.2f} lb-lg={lb-lg:.2f}; lhs={lhs:.4e} rhs={rhs:.4e}; never selected={lhs>=rhs}; margin={margin:.2f} bits")

# ---- Lemma robust: d0(kappa)
def d0(m, r, kap):
    Hh = H(2.0**-r); q = (1-Hh)/Hh
    s0 = 2**(m-r)
    LS = log2binom_exact(2**m, s0)
    a = 2 + 4*q
    b = 4 + 2*log2(m) + 2*kap + q*(ceil(LS) + 4*log2(m) + 2*log2(s0) + 2*kap + 4)
    F = lambda d: d - a*log2(d) - b
    assert b >= a/LN2
    d = 1
    while F(d) < 0:
        d += 1
    # direct check of (*) at d0 and d0-1 with the paper's (*)
    def star(d):
        Lam1 = 2*log2(d) + 2*log2(m) + kap
        kb = 2*log2(d) + 2*log2(m) + 2*log2(s0) + kap
        den2 = d - 4 - Lam1 - kap
        return den2 > 0 and Hh/(ceil(LS)+kb+4+Lam1) >= (1-Hh)/den2
    return d, star(d), star(d-1)
rows = [(3,3,"m=3,p=1/8"), (4,4,"m=4,p=1/16"), (6,6,"m=6,p=1/64"), (7,7,"m=7,p=1/128"), (6,3,"m=6,p=1/8")]
for (m, r, name) in rows:
    vals = []
    for kap in (0, 10, 20, 30, 50, 100):
        dd, s1, s0_ = d0(m, r, kap)
        vals.append(f"{dd}{'' if (s1 and not s0_) else '!'}")
    P(f"d0 {name}: " + " ".join(vals))
# 3-bit rule at d=100 for kappa 10, 20
for kap in (10, 20):
    m, r = 3, 3
    Hh = H(1/8); LS = 3.0; s0 = 1
    d = 100
    Lam1 = 2*log2(d) + 2*log2(m) + kap; kb = 2*log2(d) + 2*log2(m) + kap
    P(f"3-bit rule at d=100 kappa={kap}: (*) holds: {Hh/(ceil(LS)+kb+4+Lam1) >= (1-Hh)/(d-4-Lam1-kap)}")
# memoriser regime single 6-bit prefix at c=1e-4
J = Inst(100, 6, 6)
ok, e = J.memoriser(1e-4)
P(f"single 6-bit prefix, c=1e-4: (iii) applies {ok}, e>={e:.3f}")

# ---- error envelopes
P("== envelopes (d=100,m=20,p=2^-10) ==")
d, m = 100, 20
pfull = 2.0**-10
for j in (11, 13):
    s1 = 2**(m-j); s2 = 1024 - s1
    p1 = s1/2**m; p2 = s2/(2**m - s1)
    Re = (1-p1)*H(p2)
    gain = H(pfull) - Re
    L2 = log2binom_exact(2**m - s1, s2)
    k1 = 2*log2(j+1)  # K(S1|m) <= 2log(j+1)+kappa
    res = []
    for kap in (0, 10, 30):
        I = Inst(100, 20, 10, kappa=kap)
        ke = 2*log2(d) + 2*log2(m) + 2*log2(s2+1) + kap
        denom = k1 + ke + 4 + I.Lam1
        cenv = gain/denom
        share = log2(cenv*2**m)/log2(I.chi()*2**m)
        # J_e < Phi2 on (0, c_env]?
        okJ = all((c*(d+k1+ke) + Re) < I.Phi2(c) for c in [cenv*t/50 for t in range(1, 51)])
        res.append((kap, cenv, share, okJ, denom))
    P(f"j={j}: s1={s1} s2={s2} p2={p2:.4e} R_e={Re:.5f} H(p)-R_e={gain:.5f} L2={L2:.1f}; " + "; ".join(f"kappa={k}: c_env={c:.3e} share={s:.3f} Je<Phi2={o} (denom {dn:.1f})" for (k, c, s, o, dn) in res))
    # e1 bounds kappa=0 delta2 in {0,20}
    I = Inst(100, 20, 10)
    ke = 2*log2(d) + 2*log2(m) + 2*log2(s2+1)
    for d2 in (0, 20):
        B2 = L2 - d2
        KS1 = k1  # take K(S1) = 2log(j+1) (kappa=0 illustration)
        row = []
        for c in (1.01*2**-m, 2e-6, 5e-6, 1e-5, 3e-5):
            zeta = c*(k1 + ke + 4 + I.Lam1)
            R1 = (zeta + (1-p1)*H(p2) - min(c, 2**-m)*max(0.0, B2 - KS1))/p1
            row.append(f"c={c:.3g}: e1>={2.0**(-R1):.3f}")
        P(f"   delta2={d2}: " + "; ".join(row))
    P(f"   deficiency vs L_S: {Inst(100,20,10).LS - L2:.0f}")
# three-hypothesis illustration j=11 generic lengths
j = 11; s1 = 512; s2 = 512; p1 = s1/2**m; p2 = s2/(2**m-s1)
Re = (1-p1)*H(p2)
I = Inst(100, 20, 10)
le = d + 2*log2(j+1) + 2*log2(d) + 2*log2(m) + 2*log2(s2+1)
lg = d + I.kg
P(f"three-hyp j=11: l_g=d+{lg-d:.1f} l_e=d+{le-d:.1f}; envelope beats good iff c < {(H(pfull)-Re)/(le-lg):.3e}")
P(f"   with explicit lengths l_g=d+19.9, l_e=d+28.9: c < {(H(pfull)-Re)/(28.9-19.9):.3e}")

# ---- guard erosion
nst, eG = 64, 0.05
pG = [1-eG+eG/nst] + [eG/nst]*(nst-1)
HG = -sum(x*log2(x) for x in pG)
g = log2(nst) - HG
DG = log2(nst/eG) - log2(nst-1)
for (muG, munG, ks, kG) in ((0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)):
    rs = (muG*g - munG*log2(1/eG))/ks
    rG = munG*DG/kG
    avg = (ks*rs + kG*rG)/(ks+kG)
    P(f"guard muG={muG} munG={munG}: H_G={HG:.4f} g={g:.4f} Delta_G={DG:.4f} rho_sigma={rs:.4e} rho_G={rG:.4e} ratio={rs/rG:.1f} avg={avg:.4e}")

# ---- non-identifiability: Hanni's three hypotheses
p = 2.0**-10
def sel(c):
    cands = {"coin": (0, 1.0), "good": (110, H(p)), "mem": (10100, 0.0)}
    return min(cands.items(), key=lambda kv: c*kv[1][0] + kv[1][1])
P("noident held-out losses: " + ", ".join(f"c={c:g}: {sel(c)[0]} R={sel(c)[1][1]:.4f}" for c in (1e-1, 1e-3, 1e-5, 1e-7)))

# ---- rem:limits:method: 1 - log(3/2 - p) vs H(p); 1 - log(1+2p) vs H(p)
f1 = lambda q: (1 - log2(1.5 - q)) - H(q)
f2 = lambda q: (1 - log2(1 + 2*q)) - H(q)
P(f"level-2 sharp floor crossover p={bisect(f1, 1e-4, 0.24):.4f}; Lemma floor large-level crossover p={bisect(f2, 1e-4, 0.24):.4f}")
# deviation term order sqrt(H/p) at Hanni sizes with I ~ L_S
I = Inst(100, 20, 10)
P(f"deviation term with I=L_S: sqrt(L_S ln2/(2 s0)) = {sqrt(I.LS*LN2/(2*I.s0)):.2f}; sqrt(H(p) ln2/(2p)) = {sqrt(H(p)*LN2/(2*p)):.2f}")

print("\n".join(out))
