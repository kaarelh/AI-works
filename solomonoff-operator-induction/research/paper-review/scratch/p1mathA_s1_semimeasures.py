"""Independent checks for Paper 1, Section 2 (setting) and Appendix A.

Reviewer p1-math-A. Exact rational arithmetic where possible. Deterministic (seed 12345).
Checks:
  (1) Example ex:setting:weaknotrpf (a): weak, Moebius sum = -1.
  (2) nu_tri: weak (27 one-point inequalities), E1,E2,E3 pairwise inconsistent, total mass 3/2;
      P1 (uniform on (0,1,0),(1,0,1),(1,0,0)) >= (2/3) nu_tri on the support, equality on the E_i;
      LP: the best constant c with P(F >= D) >= c nu_tri(D) over ALL laws of random partial
      functions on {a,b,c} with labels {0,1} is 2/3.
  (3) nu_tri^{(x)2}: weak; number of one-point inequalities (paper: 1458); P1^{(x)2} min ratio (2/3)^2.
  (4) Moebius characterisation (prop:setting:mobius) on random laws: Moebius sums equal
      P(F >= D, F|_T = bot) for all D, T.
  (5) prop:setting:normalise(b) example: normalised 2/3 vs 1/2, semimeasure 1/4.
  (6) prop:setting:twopoint: (iii) law; (star) <=> order independence on random positive laws;
      the (b) law violates (star) with the stated numbers.
  (7) prop:setting:predictor / prop:setting:order: telescoping and order independence of the
      semimeasure loss for a random-partial-function law on 4 inputs, all orders; normalised loss spread.
  (8) ex:setting:swap: F(x) = x XOR omega_{1:|x|} extends the swap data with probability 2^-d.
"""
from fractions import Fraction as Fr
from itertools import product, permutations, combinations
import random, math

random.seed(12345)
BOT = None

def datasets(inputs, labels):
    """all partial functions from a subset of inputs to labels, as frozensets of pairs"""
    out = []
    for vals in product([BOT] + list(labels), repeat=len(inputs)):
        out.append(frozenset((x, v) for x, v in zip(inputs, vals) if v is not BOT))
    return out

def is_weak(nu, inputs, labels):
    cnt = 0
    ok = nu(frozenset()) <= 1
    for D in datasets(inputs, labels):
        dom = {x for x, _ in D}
        for x in inputs:
            if x in dom:
                continue
            cnt += 1
            s = sum(nu(D | {(x, y)}) for y in labels)
            if s > nu(D):
                ok = False
    return ok, cnt

def moebius(nu, D, T, labels):
    s = 0
    T = list(T)
    for vals in product([BOT] + list(labels), repeat=len(T)):
        E = frozenset((t, v) for t, v in zip(T, vals) if v is not BOT)
        s += (-1) ** len(E) * nu(D | E)
    return s

print("(1) two-input example")
nu_a = {frozenset(): Fr(1), frozenset({('a', 0)}): Fr(1), frozenset({('b', 0)}): Fr(1)}
f1 = lambda D: nu_a.get(D, Fr(0))
ok, cnt = is_weak(f1, ['a', 'b'], [0, 1])
print("   weak:", ok, "inequalities:", cnt, " Moebius_{a,b}(empty) =", moebius(f1, frozenset(), ['a', 'b'], [0, 1]))

print("(2) nu_tri")
E1 = frozenset({('a', 0), ('b', 1)}); E2 = frozenset({('b', 0), ('c', 1)}); E3 = frozenset({('c', 0), ('a', 1)})
tri = {frozenset(): Fr(1)}
for x in 'abc':
    for y in (0, 1):
        tri[frozenset({(x, y)})] = Fr(1, 2)
for E in (E1, E2, E3):
    tri[E] = Fr(1, 2)
ftri = lambda D: tri.get(D, Fr(0))
ok, cnt = is_weak(ftri, list('abc'), [0, 1])
print("   weak:", ok, " number of one-point inequalities:", cnt)
def consistent(D1, D2):
    d = dict(D1)
    return all(d.get(x, y) == y for x, y in D2)
print("   E_i pairwise inconsistent:", not consistent(E1, E2) and not consistent(E1, E3) and not consistent(E2, E3),
      " total mass:", ftri(E1) + ftri(E2) + ftri(E3))
P1 = [(0, 1, 0), (1, 0, 1), (1, 0, 0)]
def law_contain(law, D, inputs):
    # law: dict outcome-tuple -> prob; outcome entries may be BOT
    idx = {x: i for i, x in enumerate(inputs)}
    return sum(p for o, p in law.items() if all(o[idx[x]] == y for x, y in D))
lawP1 = {o: Fr(1, 3) for o in P1}
ratios = {D: law_contain(lawP1, D, 'abc') / v for D, v in tri.items()}
print("   min over support of P1/nu_tri:", min(ratios.values()), " (on E_i:", [ratios[E] for E in (E1, E2, E3)], ")")
print("   P1 singletons:", {tuple(sorted(D)): str(law_contain(lawP1, D, 'abc')) for D in tri if len(D) == 1})
# LP over all laws on Y_bot^3
try:
    from scipy.optimize import linprog
    outs = list(product([BOT, 0, 1], repeat=3))
    supp = [D for D in tri]
    # variables: p_o (27), c ; maximise c  -> minimise -c
    nv = len(outs) + 1
    A_ub, b_ub = [], []
    for D in supp:
        row = [0.0] * nv
        for i, o in enumerate(outs):
            if all(o['abc'.index(x)] == y for x, y in D):
                row[i] = -1.0
        row[-1] = float(tri[D])
        A_ub.append(row); b_ub.append(0.0)
    A_eq = [[1.0] * len(outs) + [0.0]]
    res = linprog([0.0] * len(outs) + [-1.0], A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=[1.0],
                  bounds=[(0, None)] * nv, method='highs')
    print("   LP optimum c* over all random-partial-function laws:", round(-res.fun, 12), "(paper: 2/3)")
except Exception as e:
    print("   LP skipped:", e)

print("(3) nu_tri^{(x)2} on blocks {a,b,c},{d,e,f}")
inputs6 = list('abcdef')
ren = {'d': 'a', 'e': 'b', 'f': 'c'}
def ftri2(D):
    D1 = frozenset((x, y) for x, y in D if x in 'abc')
    D2 = frozenset((ren[x], y) for x, y in D if x in 'def')
    return ftri(D1) * ftri(D2)
ok, cnt = is_weak(ftri2, inputs6, [0, 1])
print("   weak:", ok, " number of one-point inequalities:", cnt, "(paper: 1458)")
law2 = {o1 + o2: Fr(1, 9) for o1 in P1 for o2 in P1}
mn = None
for D in datasets(inputs6, [0, 1]):
    v = ftri2(D)
    if v > 0:
        r = law_contain(law2, D, inputs6) / v
        mn = r if mn is None else min(mn, r)
print("   min over support of P1^(x)2 / nu_tri^(x)2:", mn, "(=(2/3)^2:", mn == Fr(4, 9), ")")

print("(4) Moebius characterisation on random laws (3 inputs, labels {0,1})")
bad = 0; tests = 0
for trial in range(30):
    outs = list(product([BOT, 0, 1], repeat=3))
    w = [random.randint(0, 5) for _ in outs]
    tot = sum(w)
    law = {o: Fr(wi, tot) for o, wi in zip(outs, w)}
    nuP = lambda D, law=law: law_contain(law, D, 'abc')
    for D in datasets(list('abc'), [0, 1]):
        dom = {x for x, _ in D}
        rest = [x for x in 'abc' if x not in dom]
        for r in range(len(rest) + 1):
            for T in combinations(rest, r):
                lhs = moebius(nuP, D, T, [0, 1])
                rhs = sum(p for o, p in law.items() if all(o['abc'.index(x)] == y for x, y in D)
                          and all(o['abc'.index(t)] is BOT for t in T))
                tests += 1
                if lhs != rhs:
                    bad += 1
print("   identities checked:", tests, " failures:", bad)

print("(5) prop:setting:normalise(b) example")
lawb = {(0, 0): Fr(1, 4), (0, BOT): Fr(1, 4), (1, 1): Fr(1, 4), (BOT, BOT): Fr(1, 4)}
def norm_prob(law, order, labels_target, labels=(0, 1)):
    # order: list of indices; labels_target: dict index->label ; returns product of normalised conditionals and raw
    D = {}
    norm = Fr(1); raw = Fr(1)
    def cont(Dd):
        return sum(p for o, p in law.items() if all(o[i] == y for i, y in Dd.items()))
    for i in order:
        y = labels_target[i]
        base = cont(D)
        Z = sum(cont({**D, i: yy}) for yy in labels)
        num = cont({**D, i: y})
        norm *= num / Z
        raw *= num / base
        D[i] = y
    return norm, raw
print("   a first:", norm_prob(lawb, [0, 1], {0: 0, 1: 0}), " b first:", norm_prob(lawb, [1, 0], {0: 0, 1: 0}))
# (star) numbers
PB_given_a0 = Fr(lawb[(0, 0)], lawb[(0, 0)] + lawb[(0, BOT)])
PA = lawb[(0, 0)] + lawb[(0, BOT)] + lawb[(1, 1)]
PAB = lawb[(0, 0)] + lawb[(1, 1)]
print("   P(B|F(a)=0) =", PB_given_a0, " P(B|A) =", PAB / PA, "(paper: 1/2 vs 2/3)")

print("(6) two-point criterion")
law3 = {(0, 0): Fr(1, 4), (1, 1): Fr(1, 8), (1, BOT): Fr(1, 8), (BOT, 1): Fr(1, 8), (BOT, BOT): Fr(3, 8)}
print("   law (iii) sums to", sum(law3.values()))
oi = all(norm_prob(law3, [0, 1], {0: a, 1: b})[0] == norm_prob(law3, [1, 0], {0: a, 1: b})[0]
         for a in (0, 1) for b in (0, 1))
def star(law, labels=(0, 1)):
    def P(pred):
        return sum(p for o, p in law.items() if pred(o))
    PA = P(lambda o: o[0] is not BOT); PB = P(lambda o: o[1] is not BOT)
    PAB = P(lambda o: o[0] is not BOT and o[1] is not BOT)
    ok = True
    for al in labels:
        pa = P(lambda o: o[0] == al)
        if pa > 0 and P(lambda o: o[0] == al and o[1] is not BOT) / pa != PAB / PA:
            ok = False
    for be in labels:
        pb = P(lambda o: o[1] == be)
        if pb > 0 and P(lambda o: o[1] == be and o[0] is not BOT) / pb != PAB / PB:
            ok = False
    return ok
print("   (iii): criterion", star(law3), " order independent", oi, "(paper: False, True)")
agree = 0; n = 0; crit_true = 0
for trial in range(300):
    outs = list(product([BOT, 0, 1], repeat=2))
    w = {o: random.randint(1, 9) for o in outs}
    tot = sum(w.values())
    law = {o: Fr(v, tot) for o, v in w.items()}
    oi = all(norm_prob(law, [0, 1], {0: a, 1: b})[0] == norm_prob(law, [1, 0], {0: a, 1: b})[0]
             for a in (0, 1) for b in (0, 1))
    s = star(law)
    crit_true += s
    agree += (oi == s); n += 1
print("   random positive laws: (star)==order-independence in", agree, "of", n, "; (star) true in", crit_true)
# laws constructed to satisfy (star): F(a) defined indep. of F(b)'s value given defined... take product law
agree2 = 0
for trial in range(100):
    pa = [Fr(random.randint(1, 9)) for _ in range(3)]; pb = [Fr(random.randint(1, 9)) for _ in range(3)]
    sa, sb = sum(pa), sum(pb)
    law = {(x, y): (pa[i] / sa) * (pb[j] / sb) for i, x in enumerate([BOT, 0, 1]) for j, y in enumerate([BOT, 0, 1])}
    oi = all(norm_prob(law, [0, 1], {0: a, 1: b})[0] == norm_prob(law, [1, 0], {0: a, 1: b})[0]
             for a in (0, 1) for b in (0, 1))
    agree2 += (oi and star(law))
print("   independent (product) laws: (star) and order independence both hold in", agree2, "of 100")

print("(7) order independence of the semimeasure loss vs normalised loss (4 inputs, random law)")
inputs4 = [0, 1, 2, 3]
outs = list(product([BOT, 0, 1], repeat=4))
w = [random.randint(1, 4) for _ in outs]
tot = sum(w)
law = {o: Fr(wi, tot) for o, wi in zip(outs, w)}
target = {0: 1, 1: 0, 2: 1, 3: 1}
raws, norms = set(), []
for order in permutations(inputs4):
    nm, rw = norm_prob(law, list(order), target)
    raws.add(rw); norms.append(nm)
full = sum(p for o, p in law.items() if all(o[i] == target[i] for i in inputs4))
print("   semimeasure products over 24 orders:", len(raws), "distinct value(s); equals nu(D):", raws == {full})
print("   normalised products: min %.6f max %.6f ; all >= raw: %s" % (float(min(norms)), float(max(norms)), all(x >= full for x in norms)))

print("(8) swap data, F(x) = x XOR omega_{1:|x|}")
okall = True
for d in range(1, 6):
    for x1 in range(2 ** d):
        for x2 in range(2 ** d):
            if x1 == x2:
                continue
            cnt = sum(1 for om in range(2 ** d) if (x1 ^ om) == x2 and (x2 ^ om) == x1)
            if cnt != 1:
                okall = False
print("   probability exactly 2^-d for all pairs, d<=5:", okall)
