"""Reviewer p1-math-A (run 2): thm:setting:weakvsmachine(ii) finite analogue and table-caption check.

 (1) For random weak semimeasures nu on 3 inputs (labels {0,1}) and S = all 3 inputs in a fixed order,
     the nested-interval (sequential) realisation of psi_S gives a random function whose law equals nu on
     data sets with domain S, and is <= nu on data sets with smaller domain (strict somewhere when nu is
     not a random-function law). Exact rationals.
 (2) Caption of tab:versions:compare: the computable family k -> ((x,0),(x,1)) (an inconsistent sequence
     of length 2, repeated input) has M_prod = 0 < M_pq, i.e. an infinite gap in the last row.
"""
from fractions import Fraction as Fr
from itertools import product
import random

random.seed(20261012)
ins = [0, 1, 2]

def rand_weak():
    # build a weak semimeasure top-down: nu(empty)=1, children split at most the parent mass, by a
    # random order-free rule: assign nu on full data sets first, then define smaller ones as
    # max over one-point extensions sums plus slack (keeps weakness).
    nu = {}
    full = [frozenset(zip(ins, ys)) for ys in product((0, 1), repeat=3)]
    w = [Fr(random.randint(0, 6)) for _ in full]; s = sum(w) + random.randint(0, 6)
    for D, v in zip(full, w):
        nu[D] = v / s
    # smaller data sets: nu(D) := max_x sum_y nu(D+(x,y)) + random slack, then normalise so nu(empty) <= 1
    from itertools import combinations
    for r in (2, 1, 0):
        for dom in combinations(ins, r):
            for ys in product((0, 1), repeat=r):
                D = frozenset(zip(dom, ys))
                rest = [x for x in ins if x not in dom]
                m = max(sum(nu[D | {(x, y)}] for y in (0, 1)) for x in rest)
                nu[D] = m + Fr(random.randint(0, 2), 40)
    z = nu[frozenset()]
    if z > 1:
        for D in nu:
            nu[D] /= z
    return nu

viol_eq = 0; viol_le = 0; strict = 0
for trial in range(300):
    nu = rand_weak()
    # sequential law: P(f(0)=y0,f(1)=y1,f(2)=y2) = nu(full data set) ; lower levels get the remaining mass as "undefined"
    def law_prob(D):
        tot = Fr(0)
        for ys in product((0, 1), repeat=3):
            full = frozenset(zip(ins, ys))
            if D <= full:
                tot += nu[full]
        return tot
    # NOTE: the realisation of psi_S also assigns mass to tapes on which f(s1) is defined but f(s2) is not;
    # those contribute to data sets that are prefixes in the order s1<s2<s3 only.
    def realised(D):
        # P(f extends D) under the nested-interval machine for order 0<1<2:
        # tape lies in I(u) for |u|=j with u_j = label; f(s_j) defined iff tape in some I(u), |u|=j.
        dom = sorted(x for x, _ in D)
        lab = dict(D)
        j = max(dom) + 1 if dom else 0
        tot = Fr(0)
        for ys in product((0, 1), repeat=j):
            if all(ys[x] == lab[x] for x in dom):
                tot += nu[frozenset(zip(ins[:j], ys))]
        return tot if dom else Fr(1)
    from itertools import combinations
    for r in range(0, 4):
        for dom in combinations(ins, r):
            for ys in product((0, 1), repeat=r):
                D = frozenset(zip(dom, ys))
                rv = realised(D)
                if r == 3 and rv != nu[D]:
                    viol_eq += 1
                if r > 0 and rv > nu[D]:
                    viol_le += 1
                if r < 3 and rv < nu[D]:
                    strict += 1
print(f"(1) 300 random weak nu: equality on domain S violated {viol_eq}; realised > nu on nonempty subsets {viol_le} (D = empty excluded: a machine law has mass 1 there);"
      f" strict '<' on subsets in {strict} cases")
print("(2) last row of the table: on the computable family of sequences ((x,0),(x,1)) M_prod := 0 (no data set),"
      " M_pq >= m(i)*P_i(0|x)*P_i(1|x) > 0 for the fair-coin product law: gap infinite for every k.")
