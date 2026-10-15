#!/usr/bin/env python3
"""Referee check q4 (final referee of the imitation drafts, 2026-10-14).

Independent code; seeded with numpy.random.default_rng(9104) for the random tests.  log = log2.

(A) Symbolic algebra (SymPy) of every rearrangement in the drafts' proofs:
    A1 the division at the end of lem:imit:closeness;
    A2 the kink-lemma substitutions giving thm:imit:main (i), (ii) and the bound on Phi;
    A3 the insertion of (ii) and (iii) into the closeness lemma giving (iv), and the comparison 2 <= 2a/(a-1);
    A4 the memoriser threshold H/(ceil L + a_rho + kappa) >= 2^-m (1 + (a_rho + 1 + kappa)/(2^m H))^-1;
    A5 the cell count: from H (l0 - lu) < (log|Y| - H)(ceil L + a_rho + kappa) and ceil L <= 2^m H + 1
       to 2^m > (l0 - lu)/(log|Y| - H) - (a_rho + 1 + kappa)/H; plus 10^6 random numeric instances.
(B) The type-class bounds 2^m H - |Sigma| log(2^m + 1) <= L_beta <= 2^m H on random exact types.
(C) E_x D_half(nu_H || P*) = H(rho) in the feature case (exact, random instances, any number of inputs per cell).
(D) The numbers quoted in sec:imit (kappa = 0, delta_beta = 0, eps = 0): the fair-coin and parity persons at
    m = 20, c = 2^-19 and c = 1e-4; and their sensitivity to kappa and delta_beta.
(E) The cell count example: l0 = 1e6, H(rho) = 1/2, |Y| = 2, l(pi_u) = 0, kappa = 0, for every m from 1 to 200; and
    whether H(rho) = 1/2 is attainable with masses rho(b) 2^m integer.
"""
from math import log2, lgamma, log, ceil, comb

import numpy as np
import sympy as sp

rng = np.random.default_rng(9104)

# ------------------------------------------------------------------------------------------------ (A)
print("(A) symbolic algebra")
m_, H_, R_, Db, I_, d_, S_, E_, k_, a_, eps, l0, G_, lpi = sp.symbols(
    'm H R Dbar I delta S E kappa a epsilon ell0 G ellpi', real=True)
M = 2 ** m_
# A1: 2^m H - S - delta - I <= 2^(m-1)(H + R) - 2^(m-1) Dbar + 1 + E + kappa   ==>  Dbar <= R - H + 2(I+delta+S+E+kappa+1)/2^m
lhs = M * H_ - S_ - d_ - I_
rhs = M / 2 * (H_ + R_) - M / 2 * Db + 1 + E_ + k_
solved = sp.simplify((rhs - lhs) * 2 / M)          # >= 0 ; equals  (R - H - Dbar) + 2(I+delta+S+E+kappa+1)/2^m
target = (R_ - H_ + 2 * (I_ + d_ + S_ + E_ + k_ + 1) / M) - Db
print(f"  A1 division: (rhs - lhs)*2/2^m - [R - H + 2(I+delta+S+E+kappa+1)/2^m - Dbar] = {sp.simplify(solved - target)}")
# A2: c = a tau, tau = 2^-m, g = G tau
tau = 1 / M
c = a_ * tau
g = G_ * tau
lenb = sp.simplify((g + eps) / (c - tau) - (G_ + M * eps) / (a_ - 1))
lob = sp.simplify((c * g + tau * eps) / (c - tau) - (a_ * G_ + M * eps) / ((a_ - 1) * M))
Delta = g + (c - tau) * l0
phib = sp.simplify((G_ * tau + c * l0) - Delta)
print(f"  A2 (i): (g+eps)/(c-tau) - (G+2^m eps)/(a-1) = {lenb};  (ii) left: (cg+tau eps)/(c-tau) - (aG+2^m eps)/((a-1)2^m) = {lob}")
print(f"     Phi: (G/2^m + c l0) - Delta(c) = {phib}  (= tau*l0 >= 0)")
# A3: insertion.  bracket = l0 + (G + 2^m eps)/(a-1) + delta + S + E + 2 kappa with G = l0 + delta + S + kappa
Gdef = l0 + d_ + S_ + k_
bracket = l0 + (Gdef + M * eps) / (a_ - 1) + d_ + S_ + E_ + 2 * k_
proof_bound = c * l0 + eps + 2 * bracket / M
exact_form = c * l0 + 2 * a_ / (a_ - 1) * Gdef / M + 2 * (E_ + k_) / M + (a_ + 1) / (a_ - 1) * eps
stated = c * l0 + 2 * a_ / (a_ - 1) * (Gdef + E_ + k_) / M + (a_ + 1) / (a_ - 1) * eps
print(f"  A3 proof bound - [c l0 + 2a/(a-1) G/2^m + 2(E+kappa)/2^m + (a+1)/(a-1) eps] = {sp.simplify(proof_bound - exact_form)}")
print(f"     stated - exact form = {sp.factor(sp.simplify(stated - exact_form))}  (>= 0 for a > 1, E + kappa >= 0)")
# A4
Lc, ar = sp.symbols('Lceil a_rho', positive=True)
Hp = sp.symbols('Hp', positive=True)
thr_low = 1 / M / (1 + (ar + 1 + k_) / (M * Hp))
print(f"  A4 threshold with ceil L = 2^m H + 1: H/(2^m H + 1 + a_rho + kappa) - lower bound = "
      f"{sp.simplify(Hp / (M * Hp + 1 + ar + k_) - thr_low)}  (and H/(ceil L + ...) only grows as ceil L decreases)")
# A5 cell count
lu, LY = sp.symbols('lu logY', real=True)
ineq_lhs = Hp * (l0 - lu)
ineq_rhs_max = (LY - Hp) * (M * Hp + 1 + ar + k_)
diff = sp.simplify(ineq_rhs_max / (Hp * (LY - Hp)) - (l0 - lu) / (LY - Hp) - (M - ((l0 - lu) / (LY - Hp) - (ar + 1 + k_) / Hp)))
print(f"  A5 cell count: [(logY-H)(2^m H+1+a+k)/(H(logY-H)) - (l0-lu)/(logY-H)] - [2^m - ((l0-lu)/(logY-H) - (a+1+k)/H)] = {diff}")
bad = 0
for t in range(10 ** 6 // 10):
    mm = int(rng.integers(1, 40))
    nS = int(rng.integers(2, 5))
    Hh = rng.uniform(0.01, log2(nS) - 0.01)
    logY = log2(nS) + rng.uniform(0, 2)
    lo = rng.uniform(1, 1e4)
    luu = rng.uniform(0, lo)
    kap = rng.uniform(0, 50)
    arho = 2 * log2(mm + 1) + 2 * log2(nS + 1) + nS * (mm + 1)
    Lce = rng.uniform(0, 2 ** mm * Hh + 1)          # any ceil L_beta <= 2^m H + 1
    lo_thr = Hh / (Lce + arho + kap)
    hi_thr = (logY - Hh) / (lo - luu)
    if lo_thr < hi_thr:                              # a window [lo_thr, hi_thr) exists
        if not (2 ** mm > (lo - luu) / (logY - Hh) - (arho + 1 + kap) / Hh):
            bad += 1
print(f"  A5 random: 100,000 draws, windows that violate the stated necessary condition: {bad}")

# ------------------------------------------------------------------------------------------------ (B)
print()
print("(B) type-class bounds")
worst_lo, worst_hi = np.inf, -np.inf
for t in range(20000):
    mm = int(rng.integers(1, 25))
    W = 2 ** mm
    nS = int(rng.integers(1, min(6, W) + 1))
    cuts = np.sort(rng.choice(np.arange(1, W), size=nS - 1, replace=False)) if nS > 1 else np.array([], int)
    counts = np.diff(np.concatenate([[0], cuts, [W]]))
    Hh = -sum(cc / W * log2(cc / W) for cc in counts)
    L = (lgamma(W + 1) - sum(lgamma(cc + 1) for cc in counts)) / log(2)
    worst_lo = min(worst_lo, L - (W * Hh - nS * log2(W + 1)))
    worst_hi = max(worst_hi, L - W * Hh)
print(f"  min(L - (2^m H - |Sigma| log(2^m+1))) = {worst_lo:.4f} (>= 0);  max(L - 2^m H) = {worst_hi:.2e} (<= 0)")

# ------------------------------------------------------------------------------------------------ (C)
print()
print("(C) the best predictor's divergence from the person in the feature case")
worst = 0.0
for t in range(300):
    mm = int(rng.integers(1, 6))
    W = 2 ** mm
    nS = int(rng.integers(2, min(4, W) + 1))
    cuts = np.sort(rng.choice(np.arange(1, W), size=nS - 1, replace=False))
    counts = np.diff(np.concatenate([[0], cuts, [W]]))
    rho = counts / W
    beta = rng.permutation(np.repeat(np.arange(nS), counts))
    nY = nS + int(rng.integers(0, 3))
    tot = 0.0
    for w in range(W):
        k = int(rng.integers(1, 4))
        mw = rng.dirichlet(np.ones(k))
        for x in range(k):
            hx = rng.permutation(nY)[:nS]
            nu = np.zeros(nY)
            nu[hx] = rho
            Ps = np.zeros(nY)
            Ps[hx[beta[w]]] = 1.0
            tot += mw[x] / W * (-2 * log2(np.sum(np.sqrt(nu * Ps))))
    Hh = -float(np.sum(rho * np.log2(rho)))
    worst = max(worst, abs(tot - Hh))
print(f"  300 random feature-case instances: max |E_x D_half(nu_H||P*) - H(rho)| = {worst:.2e}")

# ------------------------------------------------------------------------------------------------ (D)
print()
print("(D) quoted numbers (kappa = 0, delta_beta = 0, eps = 0 unless stated)")


def bound_iv(l0v, m, nS, Hh, c, kappa=0.0, delta=0.0, epsv=0.0):
    W = 2 ** m
    a = c * W
    G = l0v + delta + nS * log2(W + 1) + kappa
    E = 2 * log2(2 ** (m - 1) * (2 * Hh + c * l0v + epsv) + 1)
    return c * l0v + 2 * a / (a - 1) * (G + E + kappa) / W + (a + 1) / (a - 1) * epsv


def Hb(p):
    return -p * log2(p) - (1 - p) * log2(1 - p)


arho20 = 2 * log2(21) + 2 * log2(3) + 2 * 21
l0_par = 100 + 2 * log2(100) + 2 * log2(10)        # Paper 2's kappa_g convention: d + 2 log d + 2 log r, p = 2^-r
l0_par_F5 = 100 + 2 * log2(101) + 2 * log2(11)     # with the doubling code (F5), 2 log(j+1)
Hpar = Hb(2 ** -10)
print(f"  a_rho at m = 20, |Sigma| = 2: {arho20:.4f}  (draft: < 54)")
print(f"  parity person l0 bound: d + 2 log d + 2 log 10 = {l0_par:.4f} (draft: < 120); with 2 log(j+1) codes: {l0_par_F5:.4f}")
print(f"  H(2^-10) = {Hpar:.6f} (draft: 0.0112)")
b1 = bound_iv(arho20, 20, 2, 1.0, 2 ** -19)
b2 = bound_iv(l0_par, 20, 2, Hpar, 2 ** -19)
b2b = bound_iv(l0_par_F5, 20, 2, Hpar, 2 ** -19)
b3 = bound_iv(l0_par, 20, 2, Hpar, 1e-4)
print(f"  fair coin, c = 2^-19: bound (iv) = {b1:.4e}  (draft: 6.2e-4), Hellinger gap <= {b1 * log(2) / 2:.3e}")
print(f"  parity,    c = 2^-19: bound (iv) = {b2:.4e}  (draft: 9.5e-4; with l0 = {l0_par_F5:.2f}: {b2b:.4e});"
      f" ratio to H = {b2 / Hpar:.3f}")
print(f"  parity,    c = 1e-4 : bound (iv) = {b3:.4e}  > H = {Hpar:.4e}: {b3 > Hpar}")
print("  sensitivity of the c = 2^-19 bounds (ratio to H(rho)):")
for kap in (0, 30, 300, 1000):
    for dl in (0, 20):
        r1 = bound_iv(arho20, 20, 2, 1.0, 2 ** -19, kappa=kap, delta=dl) / 1.0
        r2 = bound_iv(l0_par, 20, 2, Hpar, 2 ** -19, kappa=kap, delta=dl) / Hpar
        print(f"    kappa = {kap:5d}, delta_beta = {dl:3d}: fair coin {r1:.4f}, parity {r2:.4f}")
# where does the parity bound cross H?  scan c
cs = np.logspace(-6.2, -3, 4000)
vals = np.array([bound_iv(l0_par, 20, 2, Hpar, cc) if cc * 2 ** 20 > 1 else np.inf for cc in cs])
inside = cs[vals < Hpar]
print(f"  parity person: bound (iv) < H(rho) exactly for c in about [{inside.min():.3e}, {inside.max():.3e}]"
      f" (2^-20 = {2 ** -20:.3e}; H/l0 = {Hpar / l0_par:.3e})")
vals_half = cs[vals < Hpar / 2]
print(f"                 bound (iv) < H(rho)/2 for c in about [{vals_half.min():.3e}, {vals_half.max():.3e}]")
vals1 = np.array([bound_iv(arho20, 20, 2, 1.0, cc) if cc * 2 ** 20 > 1 else np.inf for cc in cs])
print(f"  fair-coin person: bound (iv) < H(rho) = 1 for c in about [{cs[vals1 < 1].min():.3e}, {cs[vals1 < 1].max():.3e}]")

# ------------------------------------------------------------------------------------------------ (E)
print()
print("(E) the cell count example")
need_min = np.inf
for mm in range(1, 201):
    arho = 2 * log2(mm + 1) + 2 * log2(3) + 2 * (mm + 1)
    need = 1e6 / (1 - 0.5) - (arho + 1) / 0.5
    need_min = min(need_min, need)
print(f"  l0 = 1e6, H = 1/2, |Y| = 2, l(pi_u) = 0, kappa = 0: min over m <= 200 of the required 2^m = {need_min:.6e}"
      f" (> 1.99e6: {need_min > 1.99e6})")
mm = 21
W = 2 ** mm
ks = np.arange(1, W // 2)
p = ks / W
Hs = -(p * np.log2(p) + (1 - p) * np.log2(1 - p))
k_best = int(ks[np.argmin(np.abs(Hs - 0.5))])
print(f"  H(rho) = 1/2 exactly is not attainable with rho(b) 2^m integer (it would need rho = (1/2, 1/2)):"
      f" at m = 21 the closest is p = {k_best}/2^21, H = {Hs[k_best - 1]:.9f}")
