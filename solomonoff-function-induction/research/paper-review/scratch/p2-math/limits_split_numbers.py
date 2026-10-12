#!/usr/bin/env python3
"""Independent recomputation of the numbers of Paper 2, Sections 5-7 (limits, split, algstat) and
Appendices D-F, from the formulas printed in the paper. Deterministic."""
from math import log2, log, sqrt, ceil, inf, lgamma, floor

def H(p):
    if p <= 0 or p >= 1: return 0.0
    return -p*log2(p) - (1-p)*log2(1-p)
def log2binom(n, k):
    v = (lgamma(n+1) - lgamma(k+1) - lgamma(n-k+1))/log(2)
    # guard: lgamma round-off must not push an integer value over the ceiling
    return round(v) if abs(v - round(v)) < 1e-9 else v
def jmin(Gam):
    j = 0
    while not (j - 2*log2(j+1) > Gam): j += 1
    return j
def bisect(f, lo, hi, it=200):
    for _ in range(it):
        mid = (lo+hi)/2
        if f(mid): lo = mid
        else: hi = mid
    return lo

d, m, r = 100, 20, 10
p = 2.0**-r; s0 = 2**(m-r); LS = log2binom(2**m, s0); Hp = H(p)

print("="*78)
print("(1) prop:limits:plain")
for kap in (0.0,):
    kb = 2*log2(d) + 2*log2(m) + 2*log2(s0) + kap
    exc = d + ceil(LS) + kb + kap
    nerr = p*2**d
    print(f"  exceptions <= {exc:.1f}; error inputs {nerr:.4e}; fraction {exc/nerr:.3e}")
    kb_r = 2*log2(d) + 2*log2(m) + 2*log2(r) + kap
    print(f"  with s0 given through r: l(pi_b) <= d + ceil(L_S) + {kb_r:.2f}")
def eplain(n, lam, B=30, delta=0.01, kap=0.0):
    kb = 2*log2(d) + 2*log2(m) + 2*log2(s0) + kap
    Lhat = d + ceil(LS) + kb
    RB = lam*Lhat/n + B*sqrt((Lhat*log(2) + log(2/delta))/(2*n))
    return max(0.0, 2**(-RB/p) - 2.0**-B)
for n in (1e12, 1e13, 1e15, 1e17):
    print(f"  lambda=1 n={n:g}: e >= {eplain(n,1):.3f}")
for n in (1e12, 1e13, 1e15, 1e17):
    print(f"  lambda=sqrt n, n={n:g}: e >= {eplain(n,sqrt(n)):.3f}")
for n in (1e13, 1e17, 1e20, 2.0**100):
    print(f"  lambda=n^0.9, n={n:.3g}: e >= {eplain(n, n**0.9):.3f}  (lambda/n = {n**-0.1:.2e})")
# fixed instance, n = 2^d full table, lambda_n = n^0.9: c = 2^-10 lies inside the window (2^-20, 8.06e-3]
print(f"  at n = 2^100 and lambda = n^0.9: c = lambda/n = {2.0**(-10):.3e}, inside Theorem 4.? window (2^-20, 8.06e-3]")

print("="*78)
print("(2) Rate blindness lemma: d_0(kappa) table and 3-hypothesis margins")
def d0(mm, rr, kap, s0override=None):
    Hh = H(2.0**-rr); q = (1-Hh)/Hh
    ss0 = s0override if s0override else 2**(mm-rr)
    LSs = log2binom(2**mm, ss0)
    a = 2 + 4*q
    b = 4 + 2*log2(mm) + 2*kap + q*(ceil(LSs) + 4*log2(mm) + 2*log2(ss0) + 2*kap + 4)
    F = lambda dd: dd - a*log2(dd) - b
    dd = 1
    while F(dd) < 0: dd += 1
    # check directly against (star)
    def star(dd):
        Lam1 = 2*log2(dd) + 2*log2(mm) + kap; kbb = 2*log2(dd) + 2*log2(mm) + 2*log2(ss0) + kap
        den = dd - 4 - Lam1 - kap
        return den > 0 and Hh/(ceil(LSs) + kbb + 4 + Lam1) >= (1-Hh)/den
    return dd, b >= a/log(2), star(dd), star(dd-1)
rules = [("m=3,p=1/8", 3, 3, None), ("m=4,p=1/16", 4, 4, None), ("m=6,p=1/64", 6, 6, None),
         ("m=7,p=1/128", 7, 7, None), ("m=6,p=1/8 (8 prefixes)", 6, 3, None)]
for name, mm, rr, so in rules:
    row = []
    for kap in (0, 10, 20, 30, 50, 100):
        dd, ok, s1, s2 = d0(mm, rr, kap, so)
        row.append(f"{dd}{'' if (ok and s1 and not s2) else '!'}")
    print(f"  {name:24s}: " + " ".join(row))
# 3-bit rule at d=100: kappa <= 10 holds, >= 20 fails?
for kap in (0, 10, 20):
    mm, rr = 3, 3; Hh = H(1/8); ss0 = 1; LSs = log2binom(8, 1)
    Lam1 = 2*log2(100) + 2*log2(mm) + kap; kbb = 2*log2(100) + 2*log2(mm) + 0 + kap
    print(f"  3-bit rule, d=100, kappa={kap}: (star) {Hh/(ceil(LSs)+kbb+4+Lam1) >= (1-Hh)/(100-4-Lam1-kap)}")
# three-hypothesis margins at d=100, kappa=0 for single 6-, 7-, 8-bit prefixes
for mm in (6, 7, 8):
    Hh = H(2.0**-mm); LSs = log2binom(2**mm, 1)
    lg = 100 + 2*log2(100) + 2*log2(mm)
    lb = 100 + ceil(LSs) + 2*log2(100) + 2*log2(mm) + 0
    # condition H/(lb-lg) >= (1-H)/(lg - 0); margin in bits: how much can lb-lg grow
    margin = Hh*lg/(1-Hh) - (lb - lg)
    print(f"  single {mm}-bit prefix: 3-hyp margin {margin:.2f} bits ({'never selected' if margin >= 0 else 'window'})")

print("="*78)
print("(3) Error envelopes")
def envelope(j, kap=0.0, c=None, dS2=0.0):
    s1 = 2**(m-j); s2 = s0 - s1
    p1 = s1/2**m; p2 = s2/(2**m - s1)
    Re = (1-p1)*H(p2)
    k1 = 2*log2(j+1) + kap
    ke = 2*log2(d) + 2*log2(m) + 2*log2(s2+1) + kap
    Lam1 = 2*log2(d) + 2*log2(m) + kap
    cenv = (Hp - Re)/(k1 + ke + 4 + Lam1)
    L2 = log2binom(2**m - s1, s2)
    return dict(s1=s1, s2=s2, p1=p1, p2=p2, Re=Re, k1=k1, ke=ke, Lam1=Lam1, cenv=cenv, L2=L2)
chi = {0.0: 8.06180e-03, 10.0: None, 30.0: 3.65897e-03}
for j in (11, 13):
    for kap in (0.0, 10.0, 30.0):
        E = envelope(j, kap)
        share = log(E['cenv']*2**m)/log(chi[kap]*2**m) if chi.get(kap) else float('nan')
        print(f"  j={j} kappa={kap:.0f}: s1={E['s1']} s2={E['s2']} log binom={E['L2']:.1f} H-Re={Hp-E['Re']:.5f} c_env={E['cenv']:.3e} share={share:.3f}")
    print(f"     deficiency vs L_S: {LS - E['L2']:.0f} bits")
def e1(j, c, kap=0.0, dS2=0.0, KS1_mode='k1+2logm'):
    E = envelope(j, kap)
    zeta = c*(E['k1'] + E['ke'] + 4 + E['Lam1'])
    B2 = E['L2'] - dS2
    # K(S_1) <= K(S_1 | m) + K(m) <= k1 + 2 log m (+kappa)
    KS1 = E['k1'] + 2*log2(m) + kap if KS1_mode == 'k1+2logm' else E['k1']
    R1 = (zeta + (1-E['p1'])*H(E['p2']) - min(c, 2.0**-m)*max(0.0, B2 - KS1))/E['p1']
    return 2**-R1, R1
for j in (11, 13):
    vals = [e1(j, c)[0] for c in (1.01*2.0**-m, 2e-6, 5e-6, 1e-5, 3e-5)]
    vals2 = [e1(j, c, KS1_mode='k1')[0] for c in (1.01*2.0**-m, 2e-6, 5e-6, 1e-5, 3e-5)]
    print(f"  j={j}: e1 >= " + ", ".join(f"{v:.3f}" for v in vals) + "   [with K(S1)=k1: " + ", ".join(f"{v:.3f}" for v in vals2) + "]")
    print(f"        dS2=20 at 1.01*2^-m: {e1(j, 1.01*2.0**-m, dS2=20)[0]:.3f}")
# condition J_e < Phi2 on (0, c_env]
Lam1 = 2*log2(d) + 2*log2(m); kg = 2*log2(d) + 2*log2(r)
G = lambda jj: 1 - log2(1 + (0 if jj == inf else 2.0**-jj) + 2*p)
tstar = (d - Lam1)/4
Phi2 = lambda c: min(c*(d-8-Lam1) + G(1), G(tstar-1))
for j in (11, 13):
    E = envelope(j)
    Je = lambda c: c*(d + E['k1'] + E['ke']) + E['Re']
    print(f"  j={j}: J_e(c_env) < Phi2(c_env): {Je(E['cenv']) < Phi2(E['cenv'])}")
# three-hypothesis illustration for j = 11 (generic lengths)
E = envelope(11)
lg = d + kg; le = d + E['k1'] + E['ke']
print(f"  j=11 three-hypothesis: envelope beats good model for c < {(Hp - E['Re'])/(le - lg):.3e}")

print("="*78)
print("(4) Guard erosion")
nst, eG = 64, 0.05
probs = [1 - eG + eG/nst] + [eG/nst]*(nst-1)
HG = -sum(q*log2(q) for q in probs)
g_ = log2(nst) - HG; DG = log2(nst/eG) - log2(nst-1)
for (muG, munG, ks, kG) in ((0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)):
    rs = (muG*g_ - munG*log2(1/eG))/ks; rG = munG*DG/kG
    cross = (ks*rs + kG*rG)/(ks + kG)
    print(f"  muG={muG} mu~G={munG}: H_G={HG:.4f} g={g_:.4f} Delta_G={DG:.4f} rho_sigma={rs:.4e} rho_G={rG:.4e} ratio={rs/rG:.1f} crossing={cross:.4e}")

print("="*78)
print("(5) rem:limits:method: 1 - log(3/2 - p) > H(p) iff p < ...")
print(f"  {bisect(lambda q: 1 - log2(1.5 - q) > H(q), 1e-6, 0.4):.4f};  1 - log(1+2p) > H(p) iff p < {bisect(lambda q: 1 - log2(1 + 2*q) > H(q), 1e-6, 0.4):.4f}")
print(f"  deviation term order sqrt(H(p) ln2/(2p)) at p=2^-10: {sqrt(Hp*log(2)/(2*p)):.3f}")

print("="*78)
print("(6) Split: stream-prefix cost 2 log(t_D+1) and hashing cost")
def stream_cost(dd, n, beta):
    iD = ceil(log2(6*n/beta)); tD = ceil(log2(2*dd + 2 + 2*log2(iD + 1)))
    return iD, tD, 2*log2(tD + 1)
def hash_cost(dd, n, rr):
    return 2*log2(n+1) + 2*log2(dd+1) + 2*log2(rr+1)
for (dd, n, beta, rr) in ((20, 1e3, 1/3, 2), (100, 1e6, 1/3, 2), (100, 1e6, 2.0**-10, 10), (1000, 1e12, 1e-3, None), (10**6, 1e15, 1/3, None)):
    iD, tD, cst = stream_cost(dd, n, beta)
    print(f"  d={dd} n={n:g} beta={beta:.3g}: i_D={iD} t_D={tD} cost={cst:.2f}; hashing (r={rr}): {hash_cost(dd, n, rr) if rr else float('nan'):.1f}")
for rr in (2, 3, 10):
    print(f"   hashing at d=1000 n=1e12 r={rr}: {hash_cost(1000, 1e12, rr):.1f}; d=1e6 n=1e15 r={rr}: {hash_cost(10**6, 1e15, rr):.1f}")
print(f"  Bern(1/3): i_n <= ceil(log(18 n)), e.g. n=1e6: {ceil(log2(18e6))}")

print("="*78)
print("(7) Algstat table: Prop (iv) with t=2 and (a) first admissible g [paper/script], (b) g maximising the upper end")
def s_(t): return 2*t + 2*log2(t+1)
def algrow(kap, dd, aa, bb, mode):
    n = 2**dd; pp = aa/2**bb; s0_ = aa*2**(dd-bb)
    LE = log2binom(n, s0_)
    Lam1 = 4*log2(dd) + kap
    kg_ = 2*log2(dd) + 2*log2(aa+1) + 2*log2(bb+1) + kap
    kb_ = 4*log2(dd) + 2*log2(s0_) + kap
    clo = 2*log2(dd) + kg_ + log2(n+1) + kap
    best = None
    for g in range(1, 60):
        Gam = dd + 1 + 2*log2(dd) + 2*log2(s0_) + g + 2*log2(g) + kap
        gam = sqrt(jmin(Gam)*log(2)/(2*s0_))
        t = 2
        Ft = 1 - log2(1 + (1-2*pp)*2.0**-t + 2*pp*(2*gam + 2.0**(1-g)))
        cup = n*Ft - dd - ceil(LE) - kb_ - 2*kap
        if cup > clo:
            if mode == 'first':
                return dd - s_(t) - Lam1, kg_, clo, cup, g, Ft - H(pp)
            if best is None or cup > best[3]:
                best = (dd - s_(t) - Lam1, kg_, clo, cup, g, Ft - H(pp))
    return best
for kap in (0.0, 30.0):
    for dd in (20, 30, 60, 100):
        cells = []
        for (aa, bb) in ((1, 3), (3, 4), (7, 5), (15, 6)):
            f = algrow(kap, dd, aa, bb, 'first'); b = algrow(kap, dd, aa, bb, 'best')
            cells.append(f"p={aa}/{2**bb}: lb=d{f[0]-dd:+.1f} ub=d+{f[1]:.1f} b in [{f[2]:.0f},{f[3]:.2g}) g={f[4]} F-H={f[5]:.3f} | best g={b[4]}: [{b[2]:.0f},{b[3]:.2g}) F-H={b[5]:.3f}")
        print(f"  kappa={kap:.0f} d={dd}:")
        for cc in cells: print("     " + cc)
