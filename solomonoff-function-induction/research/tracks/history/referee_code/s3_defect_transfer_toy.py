"""s3 (referee, second report): the identity behind issue M4 of referee.md, on an exact toy.

Claim (proved in referee.md, M4).  If the inputs follow a computable deterministic policy delta
(x_i = delta(h_{i-1})), then nu := 1[x_i = delta(h_{i-1}) for all i] * xi(y||x) is a
lower-semicomputable semimeasure on block sequences, so by Lemma B, M(code(h_n)) >=
2^{-K(delta)-c} xi(y||x).  With Thm 4.6(a) this gives, on every delta-consistent sequence,

    L_M^x - K(delta) - c  <=  L_xi - L_M^y  <=  L_M^x + c.

So "L_xi <= L_M^y + O(1) on every sequence" (the notes' open Q3, unnormalised M) holds for
computable delta iff M's loss on the delta-determined input blocks stays bounded.  With
delta = "copy the previous label" (x_{i+1} = y_i) the input blocks are exactly the
Lattimore-Hutter-Gavane pattern (every other symbol repeats the one before it).

This toy shows that the two structural facts used above do not by themselves keep L_M^x
bounded.  Raw bits, X = Y = {0,1}, delta(empty) = 0 and delta(h) = last label.
  mu  = 1[delta] * Uniform(labels)            (a proper measure)
  nu  = a component that predicts a fixed label string a perfectly but keeps only half of
        its mass at every input step (semimeasure defect 1/2 per input)
  M   = (mu + nu) / 2,  xi_toy = Uniform(labels).
Both facts hold: M >= (1/2) * 1[delta] * xi_toy, and the joint M(h_n) <= xi_toy(y||x) on
delta-consistent sequences.  Along y = a we compute, in exact rationals, L_M^x, L_M^y, L_joint,
L_xi, and the fully normalised conditionals.  The toy says nothing about whether the universal
M behaves like this; that is LHG's question.
Seed 2718 (draws the label string a).  Output: s3_defect_transfer_toy.out
"""
from fractions import Fraction as Fr
from math import log2
import random

SEED = 2718
random.seed(SEED)
n = 40
a = [random.randint(0, 1) for _ in range(n)]
HALF = Fr(1, 2)


def mu_cond(kind, sym, hist):
    if kind == "x":
        want = 0 if not hist else hist[-1][1]
        return Fr(1) if sym == want else Fr(0)
    return HALF


def nu_cond(kind, sym, hist, i):
    if kind == "x":
        want = 0 if not hist else hist[-1][1]
        return HALF if sym == want else Fr(0)  # defect 1/2 at every input step
    return Fr(1) if sym == a[i] else Fr(0)


wm, wn = HALF, HALF
pm, pn = Fr(1), Fr(1)  # mu(h), nu(h)
Lx = Ly = Lxi = 0.0
Lx_norm = Ly_norm = 0.0
hist = []
check_dom = True
for i in range(n):
    x = 0 if not hist else hist[-1][1]
    y = a[i]
    M_h = wm * pm + wn * pn
    # input step
    pm_x = pm * mu_cond("x", x, hist)
    pn_x = pn * nu_cond("x", x, hist, i)
    M_hx = wm * pm_x + wn * pn_x
    M_h_other = wm * pm * mu_cond("x", 1 - x, hist) + wn * pn * nu_cond("x", 1 - x, hist, i)
    Lx += -log2(M_hx / M_h)
    Lx_norm += -log2(M_hx / (M_hx + M_h_other))
    # label step
    pm_xy = pm_x * mu_cond("y", y, hist)
    pn_xy = pn_x * nu_cond("y", y, hist, i)
    M_hxy = wm * pm_xy + wn * pn_xy
    M_hx_other = wm * pm_x * mu_cond("y", 1 - y, hist) + wn * pn_x * nu_cond("y", 1 - y, hist, i)
    Ly += -log2(M_hxy / M_hx)
    Ly_norm += -log2(M_hxy / (M_hxy + M_hx_other))
    Lxi += 1.0
    pm, pn = pm_xy, pn_xy
    hist.append((x, y))
    # domination facts on the realised prefix
    xi_val = Fr(1, 2 ** (i + 1))
    check_dom &= (wm * pm + wn * pn) <= xi_val            # joint dominated by xi_toy
    check_dom &= (wm * pm + wn * pn) >= HALF * xi_val     # M >= (1/2) 1[delta] xi_toy

Ljoint = -log2(wm * pm + wn * pn)
assert abs((Lx + Ly) - Ljoint) < 1e-9
assert check_dom
print(f"n = {n} rounds, labels a drawn with seed {SEED}")
print(f"L_M^x (unnormalised input loss)      = {Lx:8.3f}  (= n log2(4/3) = {n*log2(4/3):.3f})")
print(f"L_M^y (unnormalised label loss)      = {Ly:8.3f}  (= n log2(3/2) = {n*log2(3/2):.3f})")
print(f"L_joint = L_M^x + L_M^y              = {Ljoint:8.3f}")
print(f"L_xi_toy (uniform labels)            = {Lxi:8.3f}")
print(f"L_xi - L_M^y                          = {Lxi - Ly:8.3f}  vs  L_M^x = {Lx:.3f}  (identity: equal up to log2(1/w_mu) = 1)")
print(f"fully normalised: input loss {Lx_norm:.3f}, label loss {Ly_norm:.3f}")
print("domination facts M >= (1/2) 1[delta] xi_toy and M(h) <= xi_toy(y||x) hold on every prefix:", check_dom)
print("RESULT: both L_M^x and L_xi - L_M^y grow linearly and agree, as the identity requires.  The two")
print("        domination facts available in the universal case do not force L_M^x to stay bounded.")
