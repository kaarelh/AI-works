"""rd1: independent referee checks for sub-track "decay" (research/tracks/imitation/decay/notes.md).

Written by the decay referee, 2026-10-14. Deterministic (no random numbers). Python 3.11, NumPy, SciPy.
Output: rd1_referee.out (same folder). This script does not import or reuse the author's d1/d2 code.

Parts
 (A) Two-program class {coin (length 1), f (length 1+k)} on X = {0,1,2}, Y = {0,1}: every per-query sample of
     size n = 1..6 is enumerated (exact rational arithmetic). For each c it compares the cn-MAP set with the
     MAP sets of three fixed priors: the degenerate prior delta_coin (not full support), the uniform prior
     (1,1) and the prior (1, 2^-20). Tests the unqualified sentence of the draft remark
     "no fixed prior gives the cn-MAPs at every n" against notes Prop 2.2(ii), which assumes full support.
 (B) Example 4.3 of the notes, recomputed independently (scipy L-BFGS on F, bisection on the classifier):
     the closed form omega* over a grid of (eps, q); the small-omega bound eps^2 q / ln((2-3q)/q) < omega*;
     the case eps^2 > 1 - 2q (no switch at any omega); and a closed form for the AdamW box threshold,
     lam_box = 2 eps / ln((2-3q)/q), derived by the referee (minimiser of L under |theta|_inf <= 1/lam).
 (C) Teacher window and c*: the referee's observation that Theorem (ii)(b) of Paper 2 (thm:teacher:main)
     gives R_B > 0 for every minimiser of J_c once c > c_+ := H(p)/(B_S - 4 - Lambda_1 - kappa_g), hence
     A_c ∩ E = ∅ and c > c* (prop:recovery:beyond(c)). Computes c_+ / 2^-m at the example's sizes.
"""
import math
from fractions import Fraction
from itertools import product

import numpy as np
from scipy.optimize import brentq, minimize, minimize_scalar

print("=" * 100)
print("(A) Two programs: which fixed priors reproduce the cn-MAP sets on every sample (n = 1..6)?")
print("=" * 100)
k = 10
f = {0: 0, 1: 1, 2: 1}
pairs = [(x, y) for x in range(3) for y in range(2)]
priors = {"delta_coin (w(f)=0)": (Fraction(1), Fraction(0)),
          "uniform (1,1)": (Fraction(1), Fraction(1)),
          "(1, 2^-20)": (Fraction(1), Fraction(1, 2**20))}


def map_set(vals):
    """vals: dict name -> comparable score (larger is better), None for -inf; returns argmax set."""
    finite = {a: v for a, v in vals.items() if v is not None}
    if not finite:
        return frozenset()
    m = max(finite.values())
    return frozenset(a for a, v in finite.items() if v == m)


for c in [Fraction(1, 20), Fraction(1, 5)]:
    counts = {p: [0, 0] for p in priors}
    n_samples = 0
    for n in range(1, 7):
        for h in product(pairs, repeat=n):
            n_samples += 1
            consistent = all(f[x] == y for x, y in h)
            # J_cn = c n l + L; MAP = argmin J, i.e. argmax of -J. Exact: coin L = n bits, f L = 0 or inf.
            J = {"coin": c * n * 1 + n, "f": (c * n * (1 + k)) if consistent else None}
            cn_map = map_set({a: (-v if v is not None else None) for a, v in J.items()})
            for pname, (wc, wf) in priors.items():
                score = {"coin": wc * Fraction(1, 2**n) if wc > 0 else None,
                         "f": (wf * 1 if (consistent and wf > 0) else None)}
                wmap = map_set(score)
                counts[pname][0 if wmap == cn_map else 1] += 1
    print(f"c = {c} (c k = {c * k}): {n_samples} samples")
    for pname, (agree, disagree) in counts.items():
        print(f"   fixed prior {pname:<22}: MAP set equal to the cn-MAP set on {agree}, different on {disagree}")
print("Reading: for c k > 1 the prior delta_coin (no full support) reproduces the cn-MAPs on every sample;")
print("for c k < 1 the full-support prior (1,1) does, consistent with Prop 2.2 (no sample satisfies (a),(b) there).")

print()
print("=" * 100)
print("(B) Example 4.3 recomputed: omega*, small-omega bound, no-switch case, AdamW box threshold")
print("=" * 100)


def make(eps, q):
    def F(th, om):
        a = eps * th[0] + th[1]
        b = eps * th[0] - th[1]
        return (1 - q) * np.logaddexp(0, -a) + q * np.logaddexp(0, -b) + 0.5 * om * (th @ th)

    def G(th, om):
        a = eps * th[0] + th[1]
        b = eps * th[0] - th[1]
        sa, sb = 1 / (1 + np.exp(a)), 1 / (1 + np.exp(b))  # sigma(-a), sigma(-b)
        return np.array([-eps * ((1 - q) * sa + q * sb) + om * th[0], -(1 - q) * sa + q * sb + om * th[1]])

    def argminF(om):
        r = minimize(F, x0=np.array([1.0, 1.0]), args=(om,), jac=G, method="L-BFGS-B",
                     options={"ftol": 1e-15, "gtol": 1e-13, "maxiter": 100000})
        return r.x

    return F, G, argminF


rows = []
for eps, q in [(0.1, 0.2), (0.05, 0.1), (0.3, 0.25), (0.2, 0.05), (0.5, 0.3), (0.6, 0.3), (0.8, 0.2), (0.7, 0.3)]:
    F, G, argminF = make(eps, q)
    assume = eps**2 < 1 - 2 * q
    A0 = math.log((2 - 3 * q) / q)
    if assume:
        s = q * (1 + eps**2) / (2 * (1 - q) * (1 - eps**2))
        astar = math.log(1 / s - 1)
        om_star = 2 * q * eps**2 / ((1 - eps**2) * astar)
        bfun = lambda om: (lambda t: eps * t[0] - t[1])(argminF(om))
        lo, hi = om_star / 50, om_star * 50
        om_num = brentq(bfun, lo, hi, xtol=1e-14, rtol=1e-12)
        small = eps**2 * q / A0
        print(f"eps={eps}, q={q}: omega* closed form {om_star:.6e}, numerical root of b {om_num:.6e} "
              f"(rel. diff {abs(om_num - om_star) / om_star:.1e}); small-omega bound {small:.4e} < omega*: {small < om_star}")
    else:
        bs = [eps * t[0] - t[1] for t in (argminF(om) for om in np.logspace(-5, 3, 33))]
        print(f"eps={eps}, q={q}: assumption eps^2 < 1-2q fails ({eps**2:.2f} >= {1 - 2 * q:.2f}); "
              f"min over 33 omegas in [1e-5,1e3] of b = eps*th1 - th2: {min(bs):.4e} (> 0 means error 0 at every omega)")
    # AdamW box threshold: theta1 = 1/lam (dL/dtheta1 < 0); error iff the optimal theta2 >= eps/lam.
    lam_closed = 2 * eps / A0

    def box_b(lam):
        B = 1 / lam
        r = minimize_scalar(lambda t2: F(np.array([B, t2]), 0.0), bounds=(-B, B), method="bounded",
                            options={"xatol": 1e-12})
        return eps * B - r.x

    lam_num = brentq(box_b, lam_closed / 20, min(lam_closed * 20, 50.0), xtol=1e-13)
    print(f"   box (AdamW limit) threshold: closed form 2 eps/ln((2-3q)/q) = {lam_closed:.6f}, numerical {lam_num:.6f}")

print()
print("=" * 100)
print("(C) Teacher window: c > c* proved for c in (max(2^-m, c_+), c_hi), c_+ = H(p)/(B_S - 4 - Lambda_1 - kappa_g)")
print("=" * 100)
d, m, r = 100, 20, 10
p = 2.0**-r
Hp = -p * math.log2(p) - (1 - p) * math.log2(1 - p)
LS = math.log2(math.comb(2**m, 1024))
print(f"d = {d}, m = {m}, p = 2^-{r}, H(p) = {Hp:.6f}, L_S = {LS:.2f}, 2^-m = {2.0**-m:.4e}")
for kappa in [0, 30]:
    for dS in [0, 20]:
        BS = LS - dS
        Lam1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa  # B = infinity
        kg = 2 * math.log2(d) + 2 * math.log2(r) + kappa
        cplus = Hp / (BS - 4 - Lam1 - kg)
        print(f"  kappa = {kappa:>2}, delta_S = {dS:>2}: c_+ = {cplus:.5e} = {cplus / 2.0**-m:.5f} * 2^-m")
print("Paper 2 (rem:teacher:numbers) gives the window (9.54e-7, 8.06e-3] at kappa = 0 and (9.54e-7, 3.65e-3] at kappa = 30.")
