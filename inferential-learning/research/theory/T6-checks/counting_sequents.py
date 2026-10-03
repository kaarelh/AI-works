"""T6 check 6: the counting-sequent characterization of probabilistic coherence (Thm 3.2).
For random agendas (closed under negation) over 3 atoms and random credences: if the LP says incoherent,
extract a Farkas certificate, convert it into an integer counting sequent 'in every world at least m of the
multiset Phi are true', verify it exactly, and check that sum_{phi in Phi} P(phi) < m."""
import itertools, random
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog

random.seed(11)
nat = 3
worlds = list(itertools.product([0, 1], repeat=nat))
W = len(worlds)
n_incoh = 0; n_ok = 0
for trial in range(400):
    base = random.sample(range(1, (1 << W) - 1), 3)          # formulas as truth tables (bitmask over worlds)
    agenda = []
    for f in base:
        agenda += [f, ((1 << W) - 1) ^ f]                      # close under negation
    truth = np.array([[(f >> w) & 1 for f in agenda] for w in range(W)], dtype=float)
    p = []
    for k in range(0, len(agenda), 2):
        a = Fraction(random.randint(0, 10), 10); p += [a, 1 - a]   # negation-coherent (CCS) credences
    pf = np.array([float(v) for v in p])
    # LP: min lam.p - c  s.t.  lam.v - c >= 0 for all worlds v ; -1 <= lam <= 1, c free in [-10, 10]
    nA = len(agenda)
    cobj = np.concatenate([pf, [-1.0]])
    A_ub = -np.hstack([truth, -np.ones((W, 1))]); b_ub = np.zeros(W)
    r = linprog(cobj, A_ub=A_ub, b_ub=b_ub, bounds=[(-1, 1)] * nA + [(-10, 10)], method="highs")
    if r.fun > -1e-9:
        continue
    n_incoh += 1
    lam = [Fraction(v).limit_denominator(60) for v in r.x[:nA]]; c = Fraction(r.x[nA]).limit_denominator(60)
    # make integer
    from math import lcm
    D = 1
    for v in lam + [c]: D = lcm(D, v.denominator)
    lam = [int(v * D) for v in lam]; c = int(c * D)
    # Phi: lam_i copies of agenda[i] if lam_i>0; |lam_i| copies of the negation if lam_i<0 (shifts c)
    Phi = []; m = c
    for i, li in enumerate(lam):
        if li > 0: Phi += [i] * li
        elif li < 0:
            neg = i ^ 1                                       # index of the negation in agenda
            Phi += [neg] * (-li); m += -li
    valid = all(sum((agenda[i] >> w) & 1 for i in Phi) >= m for w in range(W))
    violated = sum(p[i] for i in Phi) < m
    assert valid and violated, (lam, c)
    n_ok += 1
print("incoherent (yet negation-coherent) credence functions found: %d; counting-sequent certificates verified: %d"
      % (n_incoh, n_ok))
