#!/usr/bin/env python3
"""rb4_order.py -- referee B, thread `fundamentals`: reveal-order dependence (Thm 11.1, Prop 7.2(b)) and a
new argument that settles the CR order question that Prop 7.2(b) leaves open for M_A itself.

R4.1  Thm 11.1(a): normalised probabilities of {(a,1),(a v c,1)} in both orders vs the closed form; sign.
R4.2  Thm 11.1(b): linear gap, exact rationals, a toy universal machine containing the coin machine G_ca at
      code p; per-pair ratio >= 1 + v_i, per-y bound sum log(1+v_i), average >= n 2^-|p| / 2.
R4.3  Prop 7.2(b): the explicit law (1/2 empty theory, 1/2 {a}): CR probabilities 1/2 and 1/4.
R4.4  NEW (referee): for the family D_j = {(a,1), (a v e_j,1)}, e_j pairwise incompatible and each consistent
      with not-a, the CR numerator N_j := P(order a first) - P(order a v e_j first), times Z Pl, satisfies
          N_j = Bel_0(a) rho_j - delta_j T_j >= Bel_0(a) eps_empty - delta_j,
      with delta_j := mass{consistent, proves a v e_j, not a} pairwise disjoint in j (sum <= Z), so N_j > 0
      for all but <= 1/(Bel_0(a) eps_empty) indices j.  Checked exactly on random universal-like laws
      (k = 1 + J atoms), including laws built so that N_j < 0 for small j (a single pair is not signed).
R4.5  Symbolic search (sympy), k = 2 atoms, generic positive masses on all 15 focal sets: which two-datum
      data sets have an order difference of constant sign?  CR (Dempster products) and normalised PR.
Seed 20261016.  Output: rb4_order.out.
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

import sympy as sp

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


def full_random_law(L, inc=Fr(1, 10), zero_frac=0.0):
    """random masses on every nonempty model set (some set to 0), plus inconsistent mass."""
    sets = [frozenset(S) for r in range(1, L.nv + 1) for S in itertools.combinations(range(L.nv), r)]
    raw = [Fr(0) if rng.random() < zero_frac else Fr(rng.randint(1, 50)) for _ in sets]
    tot = sum(raw)
    law = {S: (1 - inc) * r / tot for S, r in zip(sets, raw) if r}
    law[frozenset()] = inc
    return law


def norm_prob(L, law, seq):
    P = Fr(1)
    D = []
    for (f, y) in seq:
        if any(g == f for g, _ in D):
            continue
        good = C.M(L, law, D + [(f, y)])
        bad = C.M(L, law, D + [(f, 1 - y)])
        P *= good / (good + bad)
        D.append((f, y))
    return P


def cr_prob(L, law, seq):
    P = Fr(1)
    D = []
    for (f, y) in seq:
        P *= C.bel_nc(L, law, D, lit(f, y))
        D.append((f, y))
    return P


def r4_1():
    L = C.Logic(3)
    a, c = At(0), At(1)
    worst = Fr(0)
    strict = 0
    n = 0
    for trial in range(300):
        law = full_random_law(L, zero_frac=rng.choice([0.0, 0.3, 0.7]))
        if C.M(L, law, [(a, 1)]) == 0:
            continue
        n += 1
        Nab = norm_prob(L, law, [(a, 1), (Or(a, c), 1)])
        Nba = norm_prob(L, law, [(Or(a, c), 1), (a, 1)])

        def cell(x, y):
            def lab(F, f):
                return 1 if L.proves(F, f) else (0 if L.proves(F, Not(f)) else 'i')
            return sum((m for F, m in law.items() if F and lab(F, a) == x and lab(F, Or(a, c)) == y), Fr(0))
        p11, p01, pi1, p00, p0i = cell(1, 1), cell(0, 1), cell('i', 1), cell(0, 0), cell(0, 'i')
        closed = 1 + ((p11 + p01) * p0i + pi1 * (p00 + p0i)) / ((p11 + p01 + pi1 + p00) * (p11 + p01))
        worst = max(worst, abs(Nba / Nab - closed))
        strict += int((Nba > Nab) == (((p11 + p01) * p0i + pi1 * (p00 + p0i)) > 0))
    out(f"R4.1 Thm 11.1(a): {n} random laws (3 atoms, some focal masses zeroed): max |N_ba/N_ab - closed form| = {worst}; "
        f"strict inequality exactly when the numerator is positive in {strict} of {n}")


def r4_2():
    for nn in (2, 3, 4):
        k = 2 * nn
        L = C.Logic(k)
        A = [At(i) for i in range(nn)]
        Cc = [At(nn + i) for i in range(nn)]
        Gca = [(w, lit(A[len(w) - 1], int(w[-1]))) for m in range(1, nn + 1)
               for w in (''.join(b) for b in itertools.product('01', repeat=m))]
        machines = [[], [('', BOT)], Gca, [('', And(*A))], [('', Or(Not(A[0]), Cc[0]))],
                    [(w, lit(Cc[len(w) - 1], int(w[-1]))) for m in range(1, nn + 1)
                     for w in (''.join(b) for b in itertools.product('01', repeat=m))]]
        codes = ['00', '010', '011', '100', '101', '110']
        law = C.mixture_law(L, machines, codes)
        wca = Fr(1, 2 ** len(codes[2]))
        gaps = []
        per_y_ok = True
        per_pair_ok = True
        for y in itertools.product((0, 1), repeat=nn):
            alph = [lit(A[i], y[i]) for i in range(nn)]
            beta = [Or(alph[i], Cc[i]) for i in range(nn)]
            sA, sB = [], []
            for i in range(nn):
                sA += [(alph[i], 1), (beta[i], 1)]
                sB += [(beta[i], 1), (alph[i], 1)]
            gap = C.lg(norm_prob(L, law, sB)) - C.lg(norm_prob(L, law, sA))
            gaps.append(gap)
            lb = 0.0
            D = []
            for i in range(nn):
                p = C.psi_mod(L, D)
                Z = sum((m for F, m in law.items() if F and F <= p), Fr(0))
                v = sum((m for F, m in law.items() if F and F <= p and L.proves(F, Not(alph[i]))
                         and not L.decides(F, Cc[i])), Fr(0)) / Z
                r_ab = norm_prob(L, law, D + [(alph[i], 1), (beta[i], 1)]) / norm_prob(L, law, D)
                r_ba = norm_prob(L, law, D + [(beta[i], 1), (alph[i], 1)]) / norm_prob(L, law, D)
                if r_ba / r_ab < 1 + v:
                    per_pair_ok = False
                lb += C.lg(1 + v)
                D += [(alph[i], 1), (beta[i], 1)]
            if gap < lb - 1e-12:
                per_y_ok = False
        avg = sum(gaps) / len(gaps)
        out(f"R4.2 Thm 11.1(b), n = {nn}: mean gap {avg:.4f} bits (min {min(gaps):.4f}); bound n w_ca / 2 = {nn * float(wca) / 2:.4f}; "
            f"per-pair ratio >= 1 + v_i: {per_pair_ok}; per-y bound: {per_y_ok}")


def r4_3():
    L = C.Logic(2)
    a, c = At(0), At(1)
    law = {L.ALL: Fr(1, 2), L.mod(a): Fr(1, 2)}
    p1 = cr_prob(L, law, [(a, 1), (Or(a, c), 1)])
    p2 = cr_prob(L, law, [(Or(a, c), 1), (a, 1)])
    out(f"R4.3 Prop 7.2(b) explicit law: CR probabilities {p1} and {p2}; PR {C.M(L, law, [(a, 1), (Or(a, c), 1)])} in both orders")


def r4_4():
    J = 6
    k = 1 + J
    L = C.Logic(k)
    a = At(0)
    R = [At(1 + j) for j in range(J)]
    e = [And(*([Not(R[i]) for i in range(j)] + [R[j]])) for j in range(J)]   # pairwise incompatible
    worst_ineq = Fr(-1)
    worst_disj = Fr(-1)
    worst_count = -1e9
    neg_seen = 0
    pos_seen = 0
    ntr = 0
    for trial in range(40):
        machines = [[], [('', BOT)], [('', a)]]
        # adversarial theories: prove a v e_j without proving a (these push N_j negative for those j)
        bad_j = rng.sample(range(J), rng.randint(0, 2))
        for j in bad_j:
            machines.append([('', Or(a, e[j]))])
        # theories proving b -> a without deciding a (the T_j side)
        for j in rng.sample(range(J), 2):
            machines.append([('', Imp(e[j], a))])
        # random coin machine on the R's and a few random theories
        machines.append([(w, lit(R[len(w) - 1], int(w[-1]))) for m in range(1, 4)
                         for w in (''.join(b) for b in itertools.product('01', repeat=m))])
        while len(machines) < 12:
            machines.append([('', rand_formula(k, 2))])
        # code lengths: adversarial theories get short codes
        lens = [3, 4, 5] + [2] * len(bad_j) + [4, 4, 4] + [6] * (12 - 6 - len(bad_j))
        # build a prefix-free code with these lengths (Kraft check)
        if sum(Fr(1, 2 ** l) for l in lens) > 1:
            continue
        order = sorted(range(len(lens)), key=lambda i: lens[i])
        codes = [None] * len(lens)
        nxt = Fr(0)
        for i in order:
            l = lens[i]
            val = int(nxt * 2 ** l)
            codes[i] = format(val, '0{}b'.format(l))
            nxt += Fr(1, 2 ** l)
        law = C.mixture_law(L, machines, codes)
        ntr += 1
        Z = C.consistent_mass(law)
        x1 = C.bel0(L, law, a)
        eps = law.get(L.ALL, Fr(0))
        deltas = []
        bad = 0
        for j in range(J):
            b = Or(a, e[j])
            P1 = cr_prob(L, law, [(a, 1), (b, 1)])
            P2 = cr_prob(L, law, [(b, 1), (a, 1)])
            Pl = C.Mnc(L, law, [(b, 1)])
            Nj = (P1 - P2) * Z * Pl
            delta = sum((m for F, m in law.items() if F and L.proves(F, b) and not L.proves(F, a)), Fr(0))
            rho = sum((m for F, m in law.items() if F and (F & L.mod(And(e[j], Not(a))))), Fr(0))
            T = sum((m for F, m in law.items() if F and (F & L.mod(b)) and L.proves(F, Imp(b, a))), Fr(0))
            exact = x1 * rho - delta * T
            worst_ineq = max(worst_ineq, abs(Nj - exact), (x1 * eps - delta) - Nj)
            deltas.append(delta)
            if Nj <= 0:
                bad += 1
                neg_seen += 1
            else:
                pos_seen += 1
        worst_disj = max(worst_disj, sum(deltas) - Z)
        worst_count = max(worst_count, bad - float(1 / (x1 * eps)))
    out(f"R4.4 CR family D_j = {{(a,1),(a v e_j,1)}}, J = {J}, {ntr} laws with adversarial short theories proving a v e_j:")
    out(f"     identity N_j = Bel_0(a) rho_j - delta_j T_j and N_j >= Bel_0(a) eps - delta_j: max violation {worst_ineq}  [<= 0]")
    out(f"     disjointness: max of sum_j delta_j - Z = {worst_disj}  [<= 0];  max of #(j with N_j <= 0) - 1/(Bel_0(a) eps) = {worst_count:.3f}  [<= 0]")
    out(f"     pairs with N_j <= 0 (order a v e_j first more probable): {neg_seen}; with N_j > 0: {pos_seen}")


def r4_5():
    """symbolic sign search on 4 valuations."""
    nv = 4
    sets = [frozenset(S) for r in range(1, nv + 1) for S in itertools.combinations(range(nv), r)]
    m = {S: sp.Symbol('m_' + ''.join(map(str, sorted(S)))) for S in sets}
    ALL = frozenset(range(nv))

    def Bel(chi):
        return sum((m[S] for S in sets if S <= chi), sp.Integer(0))

    def sub_props():
        return [frozenset(S) for r in range(1, nv) for S in itertools.combinations(range(nv), r)]

    props = sub_props()
    Z = sum(m.values())

    def cr_terms(x, y):
        # P(x then y) numerator/denominator: Bel(x)/Z * T(x,y)/Pl(x)
        Tn = sum((m[S] for S in sets if (S & x) and (S & x) <= y), sp.Integer(0))
        Pl = sum((m[S] for S in sets if S & x), sp.Integer(0))
        return Bel(x) * Tn, Z * Pl

    def norm_terms(x, y):
        # PR normalised: Bel(x)/(Bel(x)+Bel(~x)) * Bel(x&y)/(Bel(x&y)+Bel(x&~y))
        nx = ALL - x
        ny = ALL - y
        num = Bel(x) * Bel(x & y)
        den = (Bel(x) + Bel(nx)) * (Bel(x & y) + Bel(x & ny))
        return num, den

    res = {}
    for name, terms in (("CR", cr_terms), ("normalised PR", norm_terms)):
        signed = []
        mixed = 0
        zero = 0
        for x, y in itertools.combinations(props, 2):
            if not (x & y):
                continue                       # inconsistent data
            n1, d1 = terms(x, y)
            n2, d2 = terms(y, x)
            diff = sp.Poly(sp.expand(n1 * d2 - n2 * d1), *m.values())
            coeffs = diff.coeffs()
            if not coeffs or all(c == 0 for c in coeffs):
                zero += 1
            elif all(c >= 0 for c in coeffs) or all(c <= 0 for c in coeffs):
                signed.append((sorted(x), sorted(y)))
            else:
                mixed += 1
        res[name] = (signed, mixed, zero)
        out(f"R4.5 {name}: two-datum sets {{(x,1),(y,1)}} on 4 valuations (x, y nonempty proper, consistent): "
            f"sign-definite nonzero difference: {len(signed)}; mixed sign: {mixed}; identically zero: {zero}")
        if signed:
            out(f"     examples (model sets of x, y): {signed[:6]}")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r4_1()
    r4_2()
    r4_3()
    r4_4()
    r4_5()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb4_order.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
