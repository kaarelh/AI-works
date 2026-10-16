#!/usr/bin/env python3
"""rb2_updates.py -- referee B, thread `fundamentals`: updating rules and consistency-requiring variants.

Laws are focal laws of toy universal theory machines (rb_common), with positive mass on the empty
theory and on the inconsistent theory, over k = 3 atoms.  Sentences are syntax trees.

R2.1  Prop 2.2(a): Bel_D(chi) = Bel_0(psi_D & chi) / Bel_0(psi_D)  (geometric conditioning), exact.
R2.2  Prop 2.2(b): total monotonicity (inclusion-exclusion up to 5 sentences) of Bel_0 and Bel_D.
R2.3  Prop 2.2(c): bracketing Bel_D <= P_D <= Pl_D for P_D the law of an explicit Lindenbaum completion
      along a fixed enumeration of sentences (the construction of the proof, not a shortcut).
R2.4  Prop 2.3: CR predictor = Dempster's rule of conditioning; M^nc(D) = Pl_0(psi_D).
R2.5  Prop 7.1(a) identity; (b) M^nc >= eps_empty; (c) CR posterior odds between survivors unchanged.
R2.6  Prop 7.2(a): Bel^nc_D(phi^b) <= 1 - eps_empty / M^nc(D) whenever B + D^pm does not prove phi^b.
R2.7  Prop 7.3: graded CR weak, >= M, charges entailed data (drop >= eps/4), and the exact packaging gap
      M_half({p&q}) - M_half({p,q}) = (1/4) * mass(consistent with p&q, proves neither p nor q).
R2.8  Prop 7.4: the decomposition of the CR predictor.
R2.9  Containment-functional test (P1 Def 3.4, Moebius inversion on two inputs): M_A is one (Prop 2.1(g));
      the graded weight of the empty theory, nu_half_empty, is weak but NOT a containment functional.
Seed 20261016.  Output: rb2_updates.out.
"""
import itertools
import os
import random
from fractions import Fraction as Fr

import rb_common as C
from rb_common import At, Not, And, Or, Imp, Iff, TOP, BOT, lit

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


def rand_formula(k, depth):
    if depth == 0 or rng.random() < 0.3:
        return At(rng.randrange(k))
    op = rng.choice(['not', 'and', 'or', 'imp', 'iff'])
    if op == 'not':
        return Not(rand_formula(k, depth - 1))
    return (op, rand_formula(k, depth - 1), rand_formula(k, depth - 1))


def rand_law(L, k):
    """focal law of a toy universal machine: empty machine, {bot}, a few deterministic theories and
    random machines with coins, at random prefix-free codes (rejection-free: fixed code tree)."""
    machines = [[], [('', BOT)]]
    for _ in range(3):
        machines.append([('', rand_formula(k, 2)) for _ in range(rng.randint(1, 2))])
    for _ in range(3):
        G = []
        for _ in range(rng.randint(1, 4)):
            n = rng.randint(0, 2)
            G.append((''.join(rng.choice('01') for _ in range(n)), rand_formula(k, 2)))
        machines.append(G)
    codes = ['00', '010', '011', '100', '1010', '1011', '110', '11100']
    order = list(range(len(codes)))
    rng.shuffle(order)
    codes = [codes[i] for i in order]
    return C.mixture_law(L, machines, codes)


def rand_data(L, k, n):
    v = rng.randrange(L.nv)
    D, seen = [], set()
    while len(D) < n:
        f = rand_formula(k, 2)
        if f in seen:
            continue
        seen.add(f)
        D.append((f, 1 if v in L.mod(f) else 0))
    return D


def eps_empty(L, law):
    return law.get(L.ALL, Fr(0))


def main():
    k = 3
    L = C.Logic(k)
    worst = {x: Fr(0) for x in ["21", "22", "23", "24a", "24b", "25a", "25c", "26", "27a", "27d", "28"]}
    cnt = {x: 0 for x in ["n", "25b", "26n", "27b", "27c", "27cn"]}
    enum = [At(i) for i in range(k)] + [rand_formula(k, 2) for _ in range(6)]   # Lindenbaum enumeration
    for trial in range(120):
        law = rand_law(L, k)
        eps = eps_empty(L, law)
        D = rand_data(L, k, rng.randint(0, 3))
        MD = C.M(L, law, D)
        if MD == 0:
            continue
        cnt["n"] += 1
        psi = And(*[lit(f, y) for (f, y) in D])
        chis = [rand_formula(k, 2) for _ in range(5)]
        # R2.1
        for chi in chis:
            g = C.bel0(L, law, And(psi, chi)) / C.bel0(L, law, psi)
            worst["21"] = max(worst["21"], abs(g - C.bel(L, law, D, chi)))
        # R2.2 total monotonicity, for Bel_0 and Bel_D
        for belf in (lambda c: C.bel0(L, law, c), lambda c: C.bel(L, law, D, c)):
            for r in range(2, 6):
                cs = chis[:r]
                rhs = Fr(0)
                for s in range(1, r + 1):
                    for I in itertools.combinations(range(r), s):
                        rhs += (-1) ** (s + 1) * belf(And(*[cs[i] for i in I]))
                worst["22"] = max(worst["22"], rhs - belf(Or(*cs)))
        # R2.3 explicit Lindenbaum completion along `enum`, law under the posterior
        P = {}
        p = C.psi_mod(L, D)
        Z = sum((x for F, x in law.items() if F and F <= p), Fr(0))
        for F, x in law.items():
            if not F or not F <= p:
                continue
            T = F
            for s in enum:
                T = (T & L.mod(s)) if (T & L.mod(s)) else (T & L.mod(Not(s)))
            assert len(T) == 1          # complete: the atoms come first in the enumeration
            v = next(iter(T))
            P[v] = P.get(v, Fr(0)) + x / Z
        for chi in chis:
            Pc = sum((w for v, w in P.items() if v in L.mod(chi)), Fr(0))
            b = C.bel(L, law, D, chi)
            pl = 1 - C.bel(L, law, D, Not(chi))
            worst["23"] = max(worst["23"], b - Pc, Pc - pl)
        # R2.4 Dempster
        top = C.bel0(L, law, TOP)
        for chi in chis:
            dem = (C.bel0(L, law, Or(chi, Not(psi))) - C.bel0(L, law, Not(psi))) / (top - C.bel0(L, law, Not(psi)))
            worst["24a"] = max(worst["24a"], abs(dem - C.bel_nc(L, law, D, chi)))
        worst["24b"] = max(worst["24b"], abs(C.Mnc(L, law, D) - (top - C.bel0(L, law, Not(psi)))))
        # R2.5
        phi = rand_formula(k, 2)
        if all(phi != f for f, _ in D):
            s = C.Mnc(L, law, D + [(phi, 1)]) + C.Mnc(L, law, D + [(phi, 0)])
            und = sum((x for F, x in law.items() if (F & p) and not L.decides(F & p, phi)), Fr(0))
            worst["25a"] = max(worst["25a"], abs(s - C.Mnc(L, law, D) - und))
        cnt["25b"] += int(C.Mnc(L, law, D) >= eps)
        surv = [(F, x) for F, x in law.items() if F & p]
        if len(surv) >= 2:
            (F1, x1), (F2, x2) = surv[0], surv[1]
            Znc = C.Mnc(L, law, D)
            worst["25c"] = max(worst["25c"], abs((x1 / Znc) / (x2 / Znc) - x1 / x2))
        # R2.6
        for chi in chis:
            for b in (0, 1):
                if not p <= L.mod(lit(chi, b)) and (p & L.mod(lit(chi, b))):
                    cnt["26n"] += 1
                    worst["26"] = max(worst["26"], C.bel_nc(L, law, D, lit(chi, b)) - (1 - eps / C.Mnc(L, law, D)))
        # R2.7
        if all(phi != f for f, _ in D):
            sh = C.Mhalf(L, law, D + [(phi, 1)]) + C.Mhalf(L, law, D + [(phi, 0)]) - C.Mhalf(L, law, D)
            worst["27a"] = max(worst["27a"], sh)
        cnt["27b"] += int(C.Mhalf(L, law, D) >= MD)
        pp, qq = At(0), At(1)
        a1 = C.Mhalf(L, law, [(pp, 1)])
        a2 = C.Mhalf(L, law, [(pp, 1), (Or(pp, qq), 1)])
        cnt["27cn"] += 1
        cnt["27c"] += int(a1 - a2 >= eps / 4)
        one = C.Mhalf(L, law, [(And(pp, qq), 1)])
        two = C.Mhalf(L, law, [(pp, 1), (qq, 1)])
        neither = sum((x for F, x in law.items() if (F & L.mod(And(pp, qq))) and not L.proves(F, pp)
                       and not L.proves(F, qq)), Fr(0))
        worst["27d"] = max(worst["27d"], abs((one - two) - neither / 4))
        # R2.8
        for chi in chis:
            lhs = C.Mnc(L, law, D) * C.bel_nc(L, law, D, chi)
            weak = sum((x for F, x in law.items() if (F & p) and not F <= p and (F & p) <= L.mod(chi)), Fr(0))
            worst["28"] = max(worst["28"], abs(lhs - (MD * C.bel(L, law, D, chi) + weak)))
    out(f"seed {SEED}")
    out(f"{cnt['n']} random (law, D) pairs with M(D) > 0 (k = 3 atoms; laws of toy universal machines)")
    out(f"R2.1 geometric conditioning: max |error| = {worst['21']}")
    out(f"R2.2 total monotonicity, 2..5 sentences, Bel_0 and Bel_D: max of (incl.-excl. sum - Bel(union)) = {worst['22']}  [<= 0]")
    out(f"R2.3 Lindenbaum completion law P_D: max of (Bel - P, P - Pl) = {worst['23']}  [<= 0]")
    out(f"R2.4 Dempster formula for Bel^nc: max |error| = {worst['24a']};  M^nc = Pl_0(psi): max |error| = {worst['24b']}")
    out(f"R2.5 (a) plausibility identity max |error| = {worst['25a']};  (b) M^nc >= eps_empty in {cnt['25b']} of {cnt['n']};"
        f"  (c) survivor odds change: {worst['25c']}")
    out(f"R2.6 per-datum CR bound: max of Bel^nc - (1 - eps/M^nc) = {float(worst['26']):.4f} over {cnt['26n']} non-entailed queries  [<= 0]")
    out(f"R2.7 graded: weak (max excess {worst['27a']}); >= M in {cnt['27b']} of {cnt['n']}; entailed datum drops by >= eps/4 in "
        f"{cnt['27c']} of {cnt['27cn']}; packaging gap == mass(neither)/4: max |error| = {worst['27d']}")
    out(f"R2.8 decomposition of the CR predictor: max |error| = {worst['28']}")

    # R2.9 containment functional test on two inputs
    out("R2.9 Moebius inversion on two inputs (x1, x2), labels {0,1}, P(alpha, beta) over {0,1,bot}^2")

    def mobius(nu, x1, x2):
        Pm = {}
        for a in (0, 1):
            for b in (0, 1):
                Pm[(a, b)] = nu([(x1, a), (x2, b)])
        for a in (0, 1):
            Pm[(a, None)] = nu([(x1, a)]) - Pm[(a, 0)] - Pm[(a, 1)]
            Pm[(None, a)] = nu([(x2, a)]) - Pm[(0, a)] - Pm[(1, a)]
        Pm[(None, None)] = nu([]) - sum(v for key, v in Pm.items())
        return Pm

    pp = At(0)
    nh_empty = lambda D: C.Mhalf(L, {L.ALL: Fr(1)}, D)
    Pm = mobius(nh_empty, pp, Not(pp))
    out(f"     nu_half of the empty theory on (p, not p): Moebius masses {dict((str(a), str(b)) for a, b in Pm.items())};"
        f" min = {min(Pm.values())}  (a containment functional needs all >= 0)")
    negM = 0
    negH = 0
    tests = 0
    for trial in range(100):
        law = rand_law(L, k)
        x1, x2 = rand_formula(k, 2), rand_formula(k, 2)
        if x1 == x2:
            continue
        tests += 1
        PM = mobius(lambda D: C.M(L, law, D), x1, x2)
        PH = mobius(lambda D: C.Mhalf(L, law, D), x1, x2)
        negM += int(min(PM.values()) < 0)
        negH += int(min(PH.values()) < 0)
    out(f"     random laws and sentence pairs: negative Moebius mass for M in {negM} of {tests}; for M_half in {negH} of {tests}")
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb2_updates.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
