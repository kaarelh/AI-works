#!/usr/bin/env python3
"""rb8_referee_claims.py -- referee B, thread `fundamentals`: exact checks of the referee's own new claims.

R8.1  Graded CR is not a containment functional (sharpens Prop 7.3): on the two inputs (phi, not phi), the Moebius
      mass of (undefined, undefined) of nu_half (any law of consistent theories) equals
          -1/2 * mass{consistent theories deciding neither phi nor not phi} < 0,
      and the same Moebius mass of the PR weight M is >= 0 (it is a containment functional, Prop 2.1(g)).
R8.2  CR order dependence with a linear gap (extends rb4 R4.4).  Pairs i = 1..n, b_i := a_i v e_{i,j},
      e_{i,1..J} pairwise incompatible on fresh atoms.  With H := A u D (Dempster-conditioned random theory),
      per pair:  ratio := P(order a_i first)/P(order b_i first) = 1 + N_i/(Bel'(b_i) T'_i) >= 1 + N_i, with
          N_i = Bel'(a_i) rho'_i - delta'_i T'_i >= Bel'(a_i) eps' - delta'_i,
      delta'_{i,j} pairwise disjoint in j (sum <= 1); choosing j_i = argmin_j delta'_{i,j} adaptively gives
      N_i >= Bel'(a_i) eps' - 1/J.  Exact on toy laws containing a theory proving all a_i and adversarial theories
      proving a_i v e_{i,j}.
Seed 20261016.  Output: rb8_referee_claims.out.
"""
import itertools
import math
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
    machines = [[], [('', BOT)]]
    for _ in range(4):
        machines.append([('', rand_formula(k, 2)) for _ in range(rng.randint(1, 2))])
    machines.append([(w, lit(At(len(w) - 1), int(w[-1]))) for r in range(1, k + 1)
                     for w in (''.join(b) for b in itertools.product('01', repeat=r))])
    codes = ['00', '010', '011', '100', '101', '110', '1110']
    perm = list(range(len(codes)))
    rng.shuffle(perm)
    return C.mixture_law(L, machines, [codes[i] for i in perm])


def moebius_two(nu, x1, x2):
    """Moebius masses P(F(x1)=s, F(x2)=t), s,t in {0,1,None}, from a functional nu on data lists."""
    def v(D):
        return nu([(f, y) for (f, y) in D])
    P = {}
    for s in (0, 1):
        for t in (0, 1):
            P[(s, t)] = v([(x1, s), (x2, t)])
    for s in (0, 1):
        P[(s, None)] = v([(x1, s)]) - P[(s, 0)] - P[(s, 1)]
    for t in (0, 1):
        P[(None, t)] = v([(x2, t)]) - P[(0, t)] - P[(1, t)]
    P[(None, None)] = v([]) - sum(P[key] for key in P)
    return P


def r8_1():
    k = 3
    L = C.Logic(k)
    worst_id = Fr(0)
    neg_half = 0
    neg_M = 0
    n = 0
    for trial in range(120):
        law = rand_law(L, k)
        phi = rand_formula(k, 2)
        undecided = sum((x for F, x in law.items() if F and not L.decides(F, phi)), Fr(0))
        Ph = moebius_two(lambda D: C.Mhalf(L, law, D), phi, Not(phi))
        PM = moebius_two(lambda D: C.M(L, law, D), phi, Not(phi))
        n += 1
        worst_id = max(worst_id, abs(Ph[(None, None)] + undecided / 2))
        neg_half += Ph[(None, None)] < 0
        neg_M += min(PM.values()) < 0
    out(f"R8.1 {n} random laws (k = 3), inputs (phi, not phi): max |Moebius_half(undef,undef) + undecided/2| = {worst_id}; "
        f"negative for M_half in {neg_half} of {n} (all laws have the empty theory, so undecided > 0 unless phi is "
        f"valid or unsatisfiable); negative Moebius mass for M in {neg_M} of {n}")


def r8_2():
    for (n, J) in ((2, 3), (3, 3), (2, 4)):
        k = n + n * (J - 1)
        L = C.Logic(k)
        a = [At(i) for i in range(n)]
        r = [[At(n + i * (J - 1) + t) for t in range(J - 1)] for i in range(n)]

        def e(i, j):     # j in 0..J-1, pairwise incompatible, each consistent with not a_i
            if j < J - 1:
                return And(*([Not(r[i][t]) for t in range(j)] + [r[i][j]]))
            return And(*[Not(r[i][t]) for t in range(J - 1)])

        ok_id = ok_bound = ok_gap = 0
        worst_gap_margin = None
        NT = 8
        for trial in range(NT):
            machines = [[], [('', BOT)], [('', And(*a))]]
            # adversarial short theories proving a_i v e_{i,j} without a_i
            for _ in range(3):
                i = rng.randrange(n)
                j = rng.randrange(J)
                machines.append([('', Or(a[i], e(i, j)))])
            machines.append([('', rand_formula(k, 2))])
            codes = ['000', '001', '010', '011', '100', '101', '110', '1110']
            perm = list(range(len(machines)))
            rng.shuffle(perm)
            law = C.mixture_law(L, machines, [codes[p] for p in perm])
            # sequential pairs with adaptive choice of j_i
            D = []
            seqA, seqB = [], []
            lb = 0.0
            id_ok = True
            bound_ok = True
            for i in range(n):
                # Dempster-conditioned law of H = A u D (consistent part), normalised
                p = C.psi_mod(L, D)
                H = {}
                for F, x in law.items():
                    G = F & p
                    if G:
                        H[G] = H.get(G, Fr(0)) + x
                Z = sum(H.values())
                Hn = {G: x / Z for G, x in H.items()}
                eps = Hn.get(p, Fr(0))      # theories adding nothing to the data: H = D
                deltas = []
                for j in range(J):
                    b = Or(a[i], e(i, j))
                    dl = sum((x for G, x in Hn.items() if L.proves(G, b) and not L.proves(G, a[i])), Fr(0))
                    deltas.append(dl)
                if sum(deltas) > 1:
                    id_ok = False
                j = min(range(J), key=lambda t: deltas[t])
                b = Or(a[i], e(i, j))
                belA = sum((x for G, x in Hn.items() if L.proves(G, a[i])), Fr(0))
                belB = sum((x for G, x in Hn.items() if L.proves(G, b)), Fr(0))
                plB = sum((x for G, x in Hn.items() if G & L.mod(b)), Fr(0))
                T = sum((x for G, x in Hn.items() if (G & L.mod(b)) and (G & L.mod(b)) <= L.mod(a[i])), Fr(0))
                rho = sum((x for G, x in Hn.items() if G & L.mod(And(e(i, j), Not(a[i])))), Fr(0))
                N = belA * plB - belB * T
                if N != belA * rho - deltas[j] * T:
                    id_ok = False
                if N < belA * eps - Fr(1, J) or N < belA * eps - deltas[j]:
                    bound_ok = False
                # direct CR probabilities of the two orders of this pair from the original law (Dempster products)
                pA = C.bel_nc(L, law, D, a[i]) * C.bel_nc(L, law, D + [(a[i], 1)], b)
                pB = C.bel_nc(L, law, D, b) * C.bel_nc(L, law, D + [(b, 1)], a[i])
                if pB == 0 or abs(pA / pB - (1 + N / (belB * T))) > 0:
                    id_ok = False
                lb += math.log2(1 + N) if N > -1 else -math.inf
                seqA += [(a[i], 1), (b, 1)]
                seqB += [(b, 1), (a[i], 1)]
                D += [(a[i], 1), (b, 1)]

            def cr(seq):
                P = Fr(1)
                DD = []
                for (f, y) in seq:
                    P *= C.bel_nc(L, law, DD, lit(f, y))
                    DD.append((f, y))
                return P
            gap = C.lg(cr(seqA)) - C.lg(cr(seqB))
            ok_id += id_ok
            ok_bound += bound_ok
            ok_gap += gap >= lb - 1e-12
            m = gap - lb
            worst_gap_margin = m if worst_gap_margin is None else min(worst_gap_margin, m)
        out(f"R8.2 CR linear gap, n = {n} pairs, J = {J}: identities (disjointness, N = Bel' rho' - delta' T', ratio = "
            f"1 + N/(Bel'(b) T')) exact in {ok_id} of {NT}; N_i >= Bel'(a_i) eps' - 1/J in {ok_bound} of {NT}; "
            f"CR loss(order b first) - loss(order a first) >= sum log(1 + N_i) in {ok_gap} of {NT} "
            f"(min margin {worst_gap_margin:.4f})")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r8_1()
    r8_2()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb8_referee_claims.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
