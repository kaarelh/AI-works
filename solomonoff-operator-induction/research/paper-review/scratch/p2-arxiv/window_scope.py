"""Independent check (arXiv review of Paper 2): over which part of the window (2^-m, c_hi] of
thm:teacher:main do the identification bounds (ii)(a),(c),(d),(e) say something non-vacuous?
Formulas transcribed from paper-steeper/sections/teacher.tex (def:teacher:instance, thm:teacher:main),
B = infinity, epsilon = 0, delta_S = 0, kappa in {0, 30}. Deterministic; no seed.
Purpose: test the abstract's sentence 'every near-optimal private-randomness hypothesis knows the parity
and gives the erroneous labels little probability' for c in the window, and the window size vs kappa."""
from math import log2, log, sqrt, lgamma, inf
d, m, r = 100, 20, 10
p = 2.0 ** -r
s0 = int(p * 2 ** m)
LS = (lgamma(2 ** m + 1) - lgamma(s0 + 1) - lgamma(2 ** m - s0 + 1)) / log(2)
H = lambda q: -q * log2(q) - (1 - q) * log2(1 - q)
Hp = H(p)
def consts(kappa, dS=0.0):
    L1 = 2 * log2(d) + 2 * log2(m) + kappa               # Lambda_1, B = inf
    kg = 2 * log2(d) + 2 * log2(r) + kappa               # kappa_g
    BS = LS - dS
    L2 = 2 ** m * Hp - BS + 4 + L1 + kg                  # Lambda_2 (exact form)
    L3 = 4 + 2 * log2(d) + kappa                         # Lambda_3
    return L1, kg, BS, L2, L3
G = lambda j: 1 - log2(1 + 2.0 ** -j + 2 * p)            # G_j with tau_B = 0
def c_hi(kappa):
    L1, kg, *_ = consts(kappa)
    ts = (d - L1) / 4
    if ts >= 2:
        return min((G(1) - Hp) / (8 + L1 + kg), (G(ts - 1) - Hp) / (d + kg))
    return (G(1) - Hp) / (d + kg)
def bounds(c, kappa, dS=0.0):
    L1, kg, BS, L2, L3 = consts(kappa, dS)
    Jg = c * (d + kg) + Hp
    u = max(0.75, 2 ** -Jg - p)
    Dl = kg + L2 / (c * 2 ** m - 1)
    I = Dl + L3
    best = inf
    for g in range(1, 41):
        Gam = dS + Dl + L3 + 1 + 2 * log2(m) + 2 * log2(s0) + g + 2 * log2(g) + kappa
        j = 0
        while j - 2 * log2(j + 1) <= Gam:
            j += 1
        gam = sqrt(j * log(2) / (2 * s0))
        best = min(best, 1 - u + gam + 2.0 ** -g)
    return u, Dl, I, best
print(f"L_S = {LS:.3f} bits, H(p) = {Hp:.6f}, 2^m H(p) - L_S = {2**m*Hp-LS:.2f}")
for kappa in (0, 30):
    ch = c_hi(kappa); lo = 2.0 ** -m
    print(f"\nkappa={kappa}: window ({lo:.3e}, {ch:.3e}], ratio {ch/lo:.0f}")
    u, Dl, I, e = bounds(1e-4, kappa)
    print(f"  at c=1e-4: u>={u:.3f}, l<=d+{Dl:.1f}, I<={I:.1f}, e<={e:.3f}   (paper Table 2(a): see tab:teacher:numbers)")
    grid = [lo * (ch / lo) ** (k / 400) for k in range(1, 401)]
    rows = [(c,) + bounds(c, kappa) for c in grid]
    vac_I = [c for c, u, Dl, I, e in rows if I >= LS]
    e_half = [c for c, u, Dl, I, e in rows if e <= 0.5]
    e_quarter = [c for c, u, Dl, I, e in rows if e <= 0.25]
    e_vac = [c for c, u, Dl, I, e in rows if e >= 1]
    fr = lambda xs: (log(max(xs) / min(xs)) / log(ch / lo)) if xs else 0.0
    print(f"  I-bound >= L_S (vacuous) for c up to {max(vac_I) if vac_I else 'none':}")
    print(f"  e-bound >= 1 (vacuous) on {len(e_vac)}/400 grid points; e<=0.5 for c in [{min(e_half):.3e}, {max(e_half):.3e}] "
          f"= {100*(log(max(e_half)/min(e_half))/log(ch/lo)):.0f}% of the log-width; e<=0.25 on {100*fr(e_quarter):.0f}%")
    print(f"  min e-bound over window: {min(e for *_, e in rows):.3f}")
# window size as a function of the machine constant (lower end 2^-m does not depend on kappa)
print("\nkappa  c_hi        ratio c_hi*2^m")
for kappa in (0, 10, 30, 50, 100, 200, 300, 400, 1000, 10000, 100000, 400000, 450000):
    ch = c_hi(kappa); print(f"{kappa:6d} {ch:.4e} {ch*2**m:12.1f}")
