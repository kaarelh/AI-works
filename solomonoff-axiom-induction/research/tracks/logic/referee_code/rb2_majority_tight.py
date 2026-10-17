"""rb2_majority_tight.py -- referee B (thread `logic`): is eps = 1/(r+1) in Prop 2.3(a) (majority
vote at a density point) the exact threshold?  Written independently of the developer's c2.

No randomness.  Output: rb2_majority_tight.out (stdout).  Needs scipy (HiGHS LP).

Finite model of the proof of Prop 2.3(a), inside one cylinder [w] (Pr = Pr_w):
  sentences 1..n; a hypergraph H of minimal inconsistent sets (an antichain); a "tape type" is
  either inconsistent (proves everything) or a consistent set of sentences (contains no edge).
  A violation of the majority argument at eps is a distribution with
     Pr(consistent tapes) > 1 - eps          (so E = all consistent tapes, D = their common theorems)
     T := {phi : Pr(O_phi) > 1 - eps} contains an edge of H   (T inconsistent).
  (D is contained in T automatically; taking E as large as possible is w.l.o.g.)

Part A (exact, Fractions).  For a single edge of size r (r = 1..12): the explicit distribution
  "inconsistent mass a; for each i, mass (1-a)/r on the type 'edge minus phi_i'" violates the
  argument iff 1 - r eps < a < eps, which is possible iff eps > 1/(r+1).  Checked exactly at
  eps = 1/(r+1) + 1/10^4 (violation exists) and, for the same family, at eps = 1/(r+1) (none).
Part B (LP, all antichains on 4 sentences).  For each antichain H (168 of them, including the empty
  one) and each edge h, maximise the slack t subject to
     a <= eps - t,  Pr(O_phi) >= 1 - eps + t for phi in h,  sum of masses = 1,  masses >= 0,
  over ALL distributions on the consistent types.  A violation exists iff t* > 0.  Tested at
  eps = 1/(s+1) (expect none) and eps = 1/(s+1) + 10^-3 (expect one), s = the largest edge size;
  this confirms that the critical eps of H is exactly 1/(s_max + 1), so the record's
  eps = 1/(r+1) is sharp for the argument (the theorem itself does not depend on it).
Part C (Prop 2.4, truth version).  Pr(X) > 1/2 and threshold 1/2 is safe; the exact family
  "X mass 1/2 + eta, a false sentence proved by the complement of X" shows that any threshold
  theta < 1/2 - eta fails, so the 1/2 + 1/2 pairing in the proof is also sharp.
"""
import itertools
from fractions import Fraction

import numpy as np
from scipy.optimize import linprog


def part_a():
    print("== A: explicit extremal family, single edge of size r ==")
    allok = True
    for r in range(1, 13):
        base = Fraction(1, r + 1)
        res = {}
        for label, eps in (("1/(r+1)", base), ("1/(r+1)+1e-4", base + Fraction(1, 10 ** 4))):
            lo, hi = 1 - r * eps, eps
            found = False
            if lo < hi:
                a = (lo + hi) / 2 if lo >= 0 else hi / 2
                # masses
                p = (1 - a) / r
                pr_cons = 1 - a
                pr_O = a + (r - 1) * p          # each edge member is proved by r-1 of the r types
                found = pr_cons > 1 - eps and pr_O > 1 - eps
            # exhaustive confirmation over a on a fine grid (exact), for the boundary case
            if label == "1/(r+1)":
                for num in range(0, 2001):
                    a = Fraction(num, 2000)
                    p = (1 - a) / r
                    if (1 - a) > 1 - eps and a + (r - 1) * p > 1 - eps:
                        found = True
            res[label] = found
        ok = (not res["1/(r+1)"]) and res["1/(r+1)+1e-4"]
        allok &= ok
        print(f"  r={r:2d}: violation at eps=1/(r+1): {res['1/(r+1)']}; at eps=1/(r+1)+1e-4: {res['1/(r+1)+1e-4']}")
    print(f"  pattern 'none at 1/(r+1), one just above' for r=1..12: {allok}")


def antichains(n):
    subsets = [frozenset(c) for k in range(1, n + 1) for c in itertools.combinations(range(n), k)]
    out = []

    def rec(i, chosen):
        if i == len(subsets):
            out.append(list(chosen))
            return
        rec(i + 1, chosen)
        s = subsets[i]
        if all(not (s <= c or c <= s) for c in chosen):
            chosen.append(s)
            rec(i + 1, chosen)
            chosen.pop()

    rec(0, [])
    return out


def max_slack(n, H, h, eps):
    types = [frozenset(c) for k in range(0, n + 1) for c in itertools.combinations(range(n), k)
             if not any(e <= frozenset(c) for e in H)]
    m = len(types)
    # variables: p_0..p_{m-1} (consistent types), a (inconsistent), t ; maximise t
    nv = m + 2
    c = np.zeros(nv)
    c[-1] = -1.0
    A_ub, b_ub = [], []
    row = np.zeros(nv); row[m] = 1; row[-1] = 1          # a + t <= eps
    A_ub.append(row); b_ub.append(float(eps))
    for phi in h:                                        # -(a + sum_{S∋phi} p_S) + t <= -(1-eps)
        row = np.zeros(nv); row[m] = -1; row[-1] = 1
        for i, S in enumerate(types):
            if phi in S:
                row[i] = -1
        A_ub.append(row); b_ub.append(-(1 - float(eps)))
    A_eq = np.zeros((1, nv)); A_eq[0, :m + 1] = 1
    bounds = [(0, None)] * (m + 1) + [(None, 1)]
    r = linprog(c, A_ub=np.array(A_ub), b_ub=np.array(b_ub), A_eq=A_eq, b_eq=[1.0], bounds=bounds,
                method="highs")
    assert r.status == 0, r.message
    return -r.fun


def part_b(n=4):
    print(f"== B: LP over all distributions, all antichains on {n} sentences ==")
    ACs = antichains(n)
    print(f"  antichains (hypergraphs of minimal inconsistent sets): {len(ACs)}")
    bad_safe = bad_tight = 0
    nonempty = 0
    worst_safe = -1.0
    for H in ACs:
        if not H:
            continue
        nonempty += 1
        smax = max(len(e) for e in H)
        eps_safe = Fraction(1, smax + 1)
        eps_over = eps_safe + Fraction(1, 1000)
        t_safe = max(max_slack(n, H, h, eps_safe) for h in H)
        t_over = max(max_slack(n, H, h, eps_over) for h in H)
        worst_safe = max(worst_safe, t_safe)
        if t_safe > 1e-9:
            bad_safe += 1
        if not t_over > 1e-9:
            bad_tight += 1
    print(f"  nonempty antichains: {nonempty}")
    print(f"  violations at eps = 1/(s_max+1): {bad_safe} (max slack {worst_safe:.2e}, i.e. 0 up to LP tolerance)")
    print(f"  antichains with NO violation at eps = 1/(s_max+1) + 1e-3: {bad_tight}")


def part_c():
    print("== C: Prop 2.4 (truth constraint), sharpness of the 1/2 + 1/2 pairing ==")
    for eta in (Fraction(1, 10), Fraction(1, 100), Fraction(1, 1000)):
        prX = Fraction(1, 2) + eta          # tapes with true theories proving D
        prOfalse = 1 - prX                   # complement proves a false sentence
        thr_ok = Fraction(1, 2)
        safe = not (prOfalse > thr_ok)
        theta = Fraction(1, 2) - 2 * eta
        fails = prOfalse > theta
        print(f"  eta={eta}: Pr(X) = {prX}; false sentence has Pr(O) = {prOfalse}; "
              f"threshold 1/2 excludes it: {safe}; threshold {theta} includes it: {fails}")


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    print("done")
