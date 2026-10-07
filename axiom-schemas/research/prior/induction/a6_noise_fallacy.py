# A6: noise (trimmed lgg) and the systematic 'step by 2' fallacy, Sub-encoded.
from common import *
import random, itertools
rng = random.Random(6)
U = motives_upto(5, ('x', 'y'))
good = [ind(eq(add(x, Z), x)), ind(NOT(eq(S(x), Z))), ind(lt(x, S(x))), ind(ALL(y, eq(add(x, y), add(y, x)))),
        ind(IMP(eq(x, Z), eq(add(x, x), Z)))]
print('genuine data lgg == sigma_x:', equiv(lgg_list(good), SIGMA_X))

def find_false(L, extra_terms=(), tries=20000, seed=0):
    """instance of L with W-true Sub premises and a false (bounded) conclusion"""
    r = random.Random(seed); vs = sorted(vars_of(L))
    pv = L[1][1][1]
    for _ in range(tries):
        P = r.choice(U)
        th = {pv: P}
        for v in vs:
            if v == pv: continue
            th[v] = r.choice([subst(P, x, Z), subst(P, x, S(x)), subst(P, x, S(Z)), subst(P, x, S(S(x))),
                              subst(P, x, S(S(Z))), r.choice(U), Z, S(Z), x, S(x), S(S(x))] + list(extra_terms))
        def ap(t):
            if is_var(t): return th[t[1]]
            return (t[0],) + tuple(ap(a) for a in t[1:])
        s = ap(L)
        if not is_formula(s[-1]) or not sub_premises_true(s): continue
        if not ev_closure(s[-1], B=12, Bfree=4): return s
    return None

# (1) one shape-breaking error under the induction tag collapses the rule
step2 = ind2(NOT(eq(x, S(Z))))
L = lgg_list(good + [step2])
print('\n(1) genuine + one step-by-2 instance under the induction tag: lgg =', show(canon(L)))
fi = find_false(L)
print('    false instance with W-true Sub premises:', show(fi) if fi else None)
# a mismatched record: conclusion uses a different A than the Sub premise
mism = ('st', ('Sub', eq(x, Z), x, Z, eq(Z, Z)), ('Sub', eq(x, Z), x, S(x), eq(S(x), Z)),
        IMP(AND(lt(Z, S(Z)), ALL(x, IMP(eq(x, Z), eq(S(x), Z)))), ALL(x, eq(x, Z))))
L2 = lgg_list(good + [mism])
print('    genuine + one record whose conclusion A differs from the Sub premise A: lgg =', show(canon(L2)))
fi = find_false(L2, seed=1)
print('    false instance with W-true Sub premises:', show(fi) if fi else None)
# an improper but shape-consistent record (wrong A, used consistently) is an instance of sigma: no collapse
impr = ind_raw(eq(x, Z), x, eq(Z, S(Z)), eq(S(x), Z))
print('    genuine + one improper instance of sigma (W-false Sub premise): lgg == sigma_x:', equiv(lgg_list(good + [impr]), SIGMA_X),
      '; W filters it:', not sub_premises_true(impr))

# (2) trimmed version space with budget e: accepted set = intersection over |E|=e of inst(lgg(D\E))
def trimmed_ok(D, e, target):
    ls = [lgg_list([d for i, d in enumerate(D) if i not in E]) for E in itertools.combinations(range(len(D)), e)]
    below = all(match(l, target) is not None for l in ls)            # every trimmed lgg generalizes target
    some_eq = any(equiv(l, target) for l in ls)
    return below and some_eq                                           # then the intersection is exactly inst(target)
print('\n(2) trimmed, e=1, data = 5 genuine + 1 step-by-2: accepted set == inst(sigma_x):', trimmed_ok(good + [step2], 1, SIGMA_X))
print('    trimmed, e=1, data = 5 genuine + 2 errors:', trimmed_ok(good + [step2, mism], 1, SIGMA_X),
      '; e=2:', trimmed_ok(good + [step2, mism], 2, SIGMA_X))
# robust genericity needs > e witnesses: with e=1 and only one non-eq motive among the genuine data it fails
few = [ind(eq(add(x, Z), x)), ind(eq(add(Z, x), x)), ind(NOT(eq(S(x), Z)))]
step2eq = ind2(eq(add(x, Z), S(x)))
print('    e=1, genuine roots (eq,eq,not) + step-by-2 with motive root not: exact?', trimmed_ok(few + [step2], 1, SIGMA_X),
      '(robust genericity fails, but it is only sufficient)')
print('    e=1, genuine roots (eq,eq,not) + step-by-2 with motive root eq : exact?', trimmed_ok(few + [step2eq], 1, SIGMA_X),
      '(removing the single non-eq witness leaves an all-eq set: the trimmed lgg does not generalize sigma)')

# (3) the fallacy under its own tag is identified by the same anchor conditions
F = [ind2(eq(add(x, Z), x)), ind2(NOT(eq(S(x), Z)))]
print('\n(3) two step-by-2 instances (different roots, non-vacuous): lgg == sigma2:', equiv(lgg_list(F), SIGMA2_X))
P = NOT(eq(x, S(Z))); s = ind2(P)
print('    instance with P := ~(x = S0):', show(s))
print('    Sub premises W-true:', sub_premises_true(s), '; antecedent true:', ev_closure(s[-1][1], B=30),
      '; conclusion (forall x P) true:', ev_closure(s[-1][2], B=30))

# (4) the audit: descent on an explicit refutation, under three evaluation regimes
def is_delta0_closed(f):
    if not is_formula(f) or free_vars(f): return False
    def qf(g):
        if g[0] in QUANT: return False
        if g[0] in ATOM_P: return True
        return all(qf(a) for a in g[1:])
    return qf(f)
def W(j):
    if j[0] == 'Sub': return 1 if W_sub(*j[1:]) else 0
    if is_delta0_closed(j): return 1 if ev(j, {}) else 0
    return None
A = subst(P, x, Z); B = subst(P, x, S(S(x)))
Q1 = ALL(x, NOT(eq(S(x), Z))); Q2 = ALL(x, ALL(y, IMP(eq(S(x), S(y)), eq(x, y))))
ANT = AND(A, ALL(x, IMP(P, B))); CONC = s[-1]
def refutation(regime):
    kindQ = {'learned': 'learned', 'asserted': 'asserted', 'trusted': 'trusted'}[regime]
    return [  # (judgment, kind, label, premises)
        (s[1], 'leafW', None, []), (s[2], 'leafW', None, []),
        (CONC, 'learned', 'step-by-2', [0, 1]),
        (Q1, kindQ, 'Q1', []), (Q2, kindQ, 'Q2', []),
        (ANT, 'trusted', 'FOL (Q1,Q2 |= A & forall x(P->B))', [3, 4]),
        (ALL(x, P), 'trusted', 'MP', [2, 5]),
        (subst(P, x, S(Z)), 'trusted', 'forall-E', [6])]
def descend(R):
    val = [W(j) for j, *_ in R]
    for i, (j, kind, lab, pr) in enumerate(R):
        if kind == 'asserted': val[i] = 1
    changed = True
    while changed:
        changed = False
        for i, (j, kind, lab, pr) in enumerate(R):
            if kind == 'trusted' and val[i] is None and all(val[p] == 1 for p in pr): val[i] = 1; changed = True
            if kind == 'trusted' and val[i] == 0:
                unk = [p for p in pr if val[p] != 1]
                if len(unk) == 1 and val[unk[0]] is None: val[unk[0]] = 0; changed = True
    assert val[-1] == 0, 'conclusion not W-false'
    i = len(R) - 1; bag = {lab for j, kind, lab, pr in R if kind == 'learned'}
    while True:
        j, kind, lab, pr = R[i]
        if kind == 'learned' and all(val[p] == 1 for p in pr): return ('blame', lab, val)
        zero = [p for p in pr if val[p] == 0]
        if zero: i = zero[0]; continue
        return ('blocked', sorted(bag), val)
for regime in ('learned', 'asserted', 'trusted'):
    res = descend(refutation(regime))
    print(f'\n(4) Q axioms {regime:8s}: descent ->', res[0], res[1])
    print('    values:', res[2])
print('    (WS) for the position <Q1,Q2 |- >: Q1, Q2 true in N (bounded):', ev_closure(Q1, B=30), ev_closure(Q2, B=30))
# the genuine two-base-case variant is sound: P(0) & P(1) & forall x(P(x) -> P(SSx)) -> forall x P
s2b = IMP(AND(AND(A, subst(P, x, S(Z))), ALL(x, IMP(P, B))), ALL(x, P))
print('\n(5) with the extra premise P(S0) the instance is sound (antecedent false here):', ev_closure(s2b, B=30))
