"""q1 (referee, second run): independent recomputation of the numbers quoted in steeper/notes.md.

Written from the statements in the notes, not from the track's scripts:
  * L_S computed from exact big-integer binomials;
  * c_hi found by bisection on {c : J_g(c) <= M_2(c)} (not from the closed form);
  * the error-label bound of Thm 2(ii)(e) minimised over g = 1..40 (the theorem holds for every g);
  * sensitivity to the machine constant kappa and to the deficiency delta_S;
  * Hanni's two versions, Prop 2.8 exponent, Prop 2.9(b), Prop 2.11 verdicts, Thm 2(iv) threshold,
    and Prop 2.13 rates re-derived from an explicit teacher/option model.
Deterministic (no randomness). Output: q1_constants.out
"""
from math import comb, log2, log, sqrt, inf, ceil

def H(q):
    return 0.0 if q <= 0 or q >= 1 else -(q*log2(q) + (1-q)*log2(1-q))

def log2_bigint(n):
    """log2 of a positive Python int, accurate to ~1e-12 relative."""
    b = n.bit_length()
    if b <= 1000:
        return log2(n)
    shift = b - 900
    return log2(n >> shift) + shift

_LS_cache = {}
def LS_exact(m, s0):
    key = (m, s0)
    if key not in _LS_cache:
        _LS_cache[key] = log2_bigint(comb(2**m, s0))
    return _LS_cache[key]

class T2:
    """Constants of Setting 2.0 / Theorem 2 (notes Sec. 2.2-2.4)."""
    def __init__(s, d, m, r, B=inf, kappa=0.0, deltaS=0.0):
        s.d, s.m, s.r, s.B, s.kap, s.dS = d, m, r, B, kappa, deltaS
        s.p = 2.0**-r
        s.s0 = 2**(m - r)
        s.LS = LS_exact(m, s.s0)
        s.BS = s.LS - deltaS
        s.tau = 0.0 if B == inf else 2.0**(1 - B)
        s.beta = 0.0 if B == inf else (2**m)*log2(1 + s.tau)
        s.Lam1 = 2*log2(d) + 2*log2(m) + (0.0 if B == inf else 2*log2(B)) + s.beta + kappa
        s.kg = 2*log2(d) + 2*log2(r) + kappa
        s.kb = 2*log2(d) + 2*log2(m) + 2*log2(s.s0) + kappa
        s.Hp = H(s.p)
        s.tstar = (d - s.Lam1)/4
    def G(s, j):
        return 1 - log2(1 + 2.0**(-j) + 2*s.p + s.tau)
    def M2(s, c):
        if s.tstar >= 2:
            return min(c*(s.d - 8 - s.Lam1) + s.G(1), s.G(s.tstar - 1))
        return s.G(1)
    def Jg(s, c):
        return c*(s.d + s.kg) + s.Hp
    def Jb(s, c):
        return c*(s.d + ceil(s.LS) + s.kb)
    def chi_bisect(s):
        f = lambda c: s.Jg(c) <= s.M2(c)
        lo, hi = 1e-15, 1.0
        if not f(lo):
            return 0.0
        for _ in range(200):
            mid = (lo*hi)**0.5 if hi/lo > 4 else (lo + hi)/2
            if f(mid): lo = mid
            else: hi = mid
        return lo
    def ident(s, c, eta=0.0, gmax=40):
        m = s.m
        Lam2 = (2**m)*s.Hp - s.BS + 4 + s.Lam1 + s.kg
        Lam3 = 4 + 2*log2(s.d) + s.kap
        u = 2.0**(-(s.Jg(c) + eta)) - s.p - (0.0 if s.B == inf else 2.0**(-s.B))
        Rlo = s.Hp - (c*Lam2 + eta)/(c*2**m - 1)
        Dl = s.kg + eta/c + (Lam2 + eta/c)/(c*2**m - 1)
        best = (inf, None, None)
        for g in range(1, gmax + 1):
            Gam = s.dS + Dl + Lam3 + 1 + 2*log2(m) + 2*log2(s.s0) + g + 2*log2(g) + s.kap
            j = 0
            while not (j - 2*log2(j + 1) > Gam):
                j += 1
            gam = sqrt(j*log(2)/(2*s.s0))
            e = 1 - u + gam + 2.0**(-g)
            if e < best[0]:
                best = (e, g, gam)
        return dict(u=u, Rgap=s.Hp - Rlo, Dl=Dl, info=Dl + Lam3, e=best[0], g=best[1], gam=best[2],
                    margin=s.M2(c) - s.Jg(c) - eta)

out = []
P = lambda *a: out.append(" ".join(str(x) for x in a))

P("=" * 78)
P("[A] Hanni's numbers")
# Version 1: points (bits, total loss relative to coin): coin (0,0), simple (100,-100*100), simple+err (200, -10000-1000)
pts = {"coin": (0, 0.0), "simple": (100, -10000.0), "simple+errors": (200, -11000.0)}
sel = {}
for lam in [0.5, 1, 9.9, 10.1, 50, 99.9, 100.1, 300]:
    sel[lam] = min(pts, key=lambda k: lam*pts[k][0] + pts[k][1])
P("  Version 1 selections:", sel)
p = 2.0**-10
for extra in [0, 10]:
    lg, lb = 100 + extra, 10100
    rm = (1 - H(p))/lg
    re_ = H(p)/(lb - lg)
    Nsw = (lb - lg)/H(p)
    P(f"  Version 2, flip-rate bits={extra}: window c in ({re_:.4e}, {rm:.4e}), ratio {rm/re_:.0f}; lambda=1 switch at N={Nsw:.4e}")
P(f"  H(2^-10)={H(p):.6f}, p log(1/p)={p*10:.6f}, ratio={p*10/H(p):.4f}")
for (m, s0) in [(20, 1024), (24, 16384)]:
    P(f"  L_S(m={m}, |S|={s0}) = {LS_exact(m, s0):.3f} bits (exact big-int binomial); 2^m H(p) = {2**m*H(s0/2**m):.3f}")

P("=" * 78)
P("[B] crossover G_1 = H(p) (B = inf): bisection")
lo, hi = 1e-6, 0.2
for _ in range(200):
    mid = (lo + hi)/2
    if 1 - log2(1.5 + 2*mid) > H(mid): lo = mid
    else: hi = mid
P(f"  G_1 > H(p) iff p < {lo:.5f}")

P("=" * 78)
P("[C] Theorem 2 window by bisection, kappa in {0, 10, 30}; full table lambda = c 2^d")
for kap in [0.0, 10.0, 30.0]:
    for (d, m) in [(20, 20), (100, 20), (100, 24)]:
        t = T2(d, m, 10, kappa=kap)
        ch = t.chi_bisect()
        line = f"  kappa={kap:4.0f} d={d:3d} m={m}: L_S={t.LS:.1f} Lam1={t.Lam1:.2f} t*={t.tstar:.2f} window c in ({2.0**-m:.4e}, {ch:.4e}]"
        if d == m:
            line += f"; full table lambda in (1, {ch*2**d:.5g}]"
        P(line)

P("=" * 78)
P("[D] identification (Thm 2(ii), Cor 2.5), g optimised; delta_S in {0, 20}")
cases = [(20, 20, 2*2.0**-20, "Cor 2.5 lambda=2"), (20, 20, 105*2.0**-20, "Cor 2.5 lambda=105"),
         (100, 20, 1e-4, "Thm 2 c=1e-4"), (100, 20, 1e-3, "Thm 2 c=1e-3"), (100, 24, 1e-5, "Thm 2 m=24 c=1e-5")]
for kap in [0.0, 30.0]:
    for dS in [0.0, 20.0]:
        for (d, m, c, lab) in cases:
            t = T2(d, m, 10, kappa=kap, deltaS=dS)
            r = t.ident(c)
            P(f"  kappa={kap:3.0f} dS={dS:3.0f} {lab:20s}: u>={r['u']:.4f} len<=d+{r['Dl']:.1f} info<={r['info']:.1f} "
              f"e<={r['e']:.3f} (g={r['g']}, gamma={r['gam']:.3f}) margin={r['margin']:.3f}")

P("=" * 78)
P("[E] Cor 2.7 (finite sample) and Prop 2.9(b): d=100, m=20, B=30, delta=0.01, kappa=0")
t = T2(100, 20, 10, B=30.0)
dl = 0.01
for (c, N) in [(1e-4, 1e11), (1e-4, 1e13), (1e-3, 1e11)]:
    e1 = 10*sqrt(log(2/dl)/(2*N))
    Lhat = (t.Jg(c) + e1)/c
    eps = e1 + 30*sqrt((Lhat*log(2) + log(2/dl))/(2*N))
    r = t.ident(c, eps)
    P(f"  c={c:.0e} N={N:.0e}: eps/c={eps/c:.2f} bits; u>={r['u']:.4f}; len<=d+{r['Dl']:.1f}; e<={r['e']:.3f}; margin ok {r['margin']>0}")
lb_len = 100 + ceil(t.LS) + t.kb
for N in [1e13, 1e15]:
    RB = lb_len/N + 30*sqrt((lb_len*log(2) + log(2/dl))/(2*N))
    P(f"  Prop 2.9(b) lambda=1, N={N:.0e}: R_B<={RB:.3e}, e>={2**(-RB/t.p) - 2.0**-30:.3f}")

P("=" * 78)
P("[F] Prop 2.8 example exponent -N eta + (J_g + eta)/c, J_g = c(d + kappa_g) + H(p), kappa=0")
t = T2(100, 20, 10)
c, eta, N = 1e-4, 1e-3, 1e6
P(f"  J_g={t.Jg(c):.5f}; exponent = {-N*eta + (t.Jg(c) + eta)/c:.1f}  (notes quote -776)")
P(f"  with length exactly d=100 (kappa_g=0): exponent = {-N*eta + (c*100 + t.Hp + eta)/c:.1f}")

P("=" * 78)
P("[G] Thm 2(iv) threshold vs 2^-m (kappa=0, B=inf)")
for (d, m) in [(100, 20), (100, 24), (20, 20)]:
    t = T2(d, m, 10)
    thr = t.Hp/(ceil(t.LS) + t.kb + 4 + t.Lam1)
    P(f"  d={d} m={m}: threshold {thr:.6e} vs 2^-m {2.0**-m:.6e}, ratio {thr*2**m:.5f}")

P("=" * 78)
P("[H] Prop 2.11 verdicts versus kappa (d, m, r): (i) uses the upper-bound lengths as if exact")
for (d, m, r) in [(100, 3, 3), (100, 6, 6), (100, 7, 7), (1000, 6, 6), (300, 3, 3), (3000, 6, 6)]:
    row = []
    for kap in [0.0, 10.0, 20.0, 30.0]:
        t = T2(d, m, r, kappa=kap)
        lhs = t.Hp/(ceil(t.LS) + t.kb + 4 + t.Lam1)
        rhs = (1 - t.Hp)/(d - 4 - t.Lam1 - kap)
        ok2 = (d - 4 - t.Lam1 - kap > 0) and lhs >= rhs
        lg = d + t.kg; lb = d + ceil(t.LS) + t.kb
        ok1 = t.Hp/(lb - lg) >= (1 - t.Hp)/(lg - kap)
        row.append(f"k={kap:.0f}:(i){'Y' if ok1 else 'n'}/(ii){'Y' if ok2 else 'n'}")
    P(f"  d={d:5d} m={m} p=2^-{r}: " + "  ".join(row))

P("=" * 78)
P("[I] Prop 2.13 (guard erosion) re-derived from an explicit teacher model")
# Region where sigma is applicable. G-contexts (freq piG): teacher plays sigma w.p. 1-eta+eta/M, each other
# step eta/M (teacher noise eta). notG-contexts (freq pinG): teacher plays one fixed non-sigma step.
# Options: none = uniform over M; unguarded = sigma-model (1-eta+eta/M on sigma, eta/M elsewhere) everywhere;
# guarded = sigma-model on G, uniform over the M-1 non-sigma steps on notG.
M, eta = 64, 0.05
ph = 1 - eta + eta/M
def xent_sigma_model_on_G():
    return -(ph*log2(ph) + (M - 1)*(eta/M)*log2(eta/M))
for (piG, pinG, ks, kG) in [(0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)]:
    R_none = (piG + pinG)*log2(M)
    R_ung = piG*xent_sigma_model_on_G() + pinG*(-log2(eta/M))
    R_gua = piG*xent_sigma_model_on_G() + pinG*log2(M - 1)
    rho_s = (R_none - R_ung)/ks
    rho_G = (R_ung - R_gua)/kG
    # selection path by brute force over c
    path = []
    cgrid = [10**(-7 + 6*i/60000) for i in range(60001)]
    for cc in cgrid:
        J = {"none": R_none, "unguarded": cc*ks + R_ung, "guarded": cc*(ks + kG) + R_gua}
        s = min(J, key=J.get)
        if not path or path[-1][1] != s:
            path.append((cc, s))
    P(f"  piG={piG} pinG={pinG}: rho_sigma={rho_s:.4e} rho_G={rho_G:.4e}; path: " +
      ", ".join(f"{s} from c={cc:.4e}" for cc, s in path))
    if rho_G >= rho_s:
        avg = (R_none - R_gua)/(ks + kG)
        P(f"     guarded->none switch at average rate {avg:.4e}")

P("=" * 78)
P("[J] Example 3.4 threshold formula: lambda* = (-log U(D) + log nu(D)) / (k - l_U)")
P("  with the c4 numbers -log U = 2234.0, -log nu = 2218.0, k=24.2, l_U=12: lambda* =",
  f"{(2234.0 - 2218.0)/(24.2 - 12.0):.3f}  (notes: 1.315; difference from the rounding of the quoted inputs)")

open(__file__.replace(".py", ".out"), "w").write("\n".join(out) + "\n")
print("\n".join(out))
