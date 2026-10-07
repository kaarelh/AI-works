# A1: exact anchor characterization for Sub-encoded induction (x fixed, x metavariable),
# checked exhaustively on all pairs and on random triples/quadruples of a motive universe,
# plus the subtle failure modes (premise order, conjunct order, vacuity, one root, one variable).
from common import *
import random
rng = random.Random(1)
U = motives_upto(5, ('x', 'y'))
print('motive universe size:', len(U), ' (formulas of size <= 5 over eq/lt, not/and/imp, all; vars x,y)')

def cond_fixed(phis):
    return len({p[0] for p in phis}) > 1 and any('x' in free_vars(p) for p in phis)
def cond_meta(pairs):
    phis = [p for p, v in pairs]
    return (len({p[0] for p in phis}) > 1 and any(v[0] in free_vars(p) for p, v in pairs)
            and len({v for p, v in pairs}) > 1)

# ---- x fixed: all pairs ----
bad = 0; tot = 0; n_anchor = 0
for i in range(len(U)):
    for j in range(i + 1, len(U)):
        D = [ind(U[i]), ind(U[j])]
        L = lgg_list(D)
        ok = equiv(L, SIGMA_X)
        assert match(L, SIGMA_X) is not None or True
        # lgg is always at most as general as sigma (D are instances of sigma)
        assert match(SIGMA_X, L) is not None, 'lgg not below sigma?!'
        tot += 1; n_anchor += ok
        if ok != cond_fixed([U[i], U[j]]): bad += 1
print(f'x fixed, all {tot} pairs: lgg == sigma_x  <=>  (roots differ & some motive has x free): mismatches = {bad}; anchors = {n_anchor}')

# ---- x fixed: random triples and quadruples ----
for r in (3, 4):
    bad = 0
    for _ in range(20000):
        phis = rng.sample(U, r)
        ok = equiv(lgg_list([ind(p) for p in phis]), SIGMA_X)
        if ok != cond_fixed(phis): bad += 1
    print(f'x fixed, 20000 random {r}-sets: mismatches = {bad}')

# ---- x metavariable: genuine instances may induct on x or on y ----
UP = [(p, v) for p in U for v in (x, y)]
bad = 0; tot = 0
for _ in range(60000):
    a, b = rng.sample(UP, 2)
    L = lgg_list([ind(*a), ind(*b)])
    assert match(SIGMA_M, L) is not None
    ok = equiv(L, SIGMA_M); tot += 1
    if ok != cond_meta([a, b]): bad += 1
print(f'x metavariable, {tot} random pairs: lgg == sigma  <=>  (roots differ & some non-vacuous & induction variables differ): mismatches = {bad}')
bad = 0
for _ in range(20000):
    S3 = rng.sample(UP, 3)
    if equiv(lgg_list([ind(*q) for q in S3]), SIGMA_M) != cond_meta(S3): bad += 1
print(f'x metavariable, 20000 random triples: mismatches = {bad}')

# ---- minimal anchors ----
phi1 = eq(add(x, Z), x); phi2 = NOT(eq(S(x), Z))
print('\nanchor {ind(x+0=x), ind(~Sx=0)}: lgg == sigma_x:', equiv(lgg_list([ind(phi1), ind(phi2)]), SIGMA_X))
print('one instance is never an anchor (lgg is ground):', vars_of(lgg_list([ind(phi1)])) == set())
print('x meta: {ind(x+0=x on x), ind(~Sy=0 on y)} -> lgg == sigma:', equiv(lgg_list([ind(phi1, x), ind(NOT(eq(S(y), Z)), y)]), SIGMA_M))
print('x meta, both on x: lgg == sigma_x (x stays a constant):', equiv(lgg_list([ind(phi1, x), ind(phi2, x)]), SIGMA_X))
# vacuous partner is fine as long as one instance is non-vacuous
print('anchor with a vacuous partner {ind(x+0=x), ind(~0=S0)}:', equiv(lgg_list([ind(phi1), ind(NOT(eq(Z, S(Z))))]), SIGMA_X))

# ---- failure modes ----
print('\n-- failure modes --')
def show_short(t): s = show(canon(t)); return s if len(s) < 200 else s[:200] + '...'
def false_instance(L, tries=4000, seed=0):
    """search instances of L with W-true Sub premises whose conclusion is false (bounded semantics)"""
    r = random.Random(seed); vs = sorted(vars_of(L))
    cands = U[:400]
    for _ in range(tries):
        th = {}
        # choose P first, then fill A,B-like metavariables with substitution results or random motives
        P = r.choice(cands)
        for v in vs: th[v] = r.choice([P, subst(P, x, Z), subst(P, x, S(x)), subst(P, x, S(Z)), subst(P, x, S(S(x))), r.choice(cands), Z, S(Z), x, S(x)])
        pv = L[1][1]
        if is_var(pv): th[pv[1]] = P          # the motive position of the first Sub premise
        def ap(t):
            if is_var(t): return th[t[1]]
            return (t[0],) + tuple(ap(a) for a in t[1:])
        s = ap(L)
        if not all(is_formula(f) or f[0] == 'Sub' for f in s[1:]): continue
        if not sub_premises_true(s): continue
        if not is_formula(s[-1]): continue
        try:
            if not ev_closure(s[-1], B=12, Bfree=4): return s
        except Exception: pass
    return None

# (i) all motives with the same main symbol
L = lgg_list([ind(eq(add(x, Z), x)), ind(eq(add(Z, x), x)), ind(eq(S(x), add(x, S(Z))))])
print('(i) same root (eq) only: lgg =', show_short(L))
print('    sound (below sigma):', match(SIGMA_X, L) is not None, '; == sigma:', equiv(L, SIGMA_X))
# (ii) vacuous only
L = lgg_list([ind(eq(Z, Z)), ind(NOT(eq(S(Z), Z)))])
print('(ii) vacuous only: lgg =', show_short(L), '; == sigma:', equiv(L, SIGMA_X))
# (iii) one induction variable only (x meta target): lgg is the x-fixed rule
# (iv) premise order varies: some records list the S-premise first
def ind_swapped(phi, v=x):
    s = ind(phi, v); return ('st', s[2], s[1], s[3])
D = [ind(eq(add(x, Z), x)), ind(NOT(eq(S(x), Z))), ind_swapped(lt(x, S(x))), ind(IMP(eq(x, Z), eq(add(x, x), Z)))]
L = lgg_list(D)
print('(iv) premise order varies: lgg =', show_short(L))
print('     below sigma (sound):', match(SIGMA_X, L) is not None)
fi = false_instance(L)
print('     instance with W-true Sub premises and false conclusion:', show_short(fi) if fi else None)
# (v) conjunct order varies in the conclusion
def ind_conj_swapped(phi, v=x):
    s = ind(phi, v); c = s[3]; ant = c[1]
    return ('st', s[1], s[2], IMP(AND(ant[2], ant[1]), c[2]))
D = [ind(eq(add(x, Z), x)), ind(NOT(eq(S(x), Z))), ind_conj_swapped(lt(x, S(x)))]
L = lgg_list(D)
print('(v) conjunct order varies: lgg =', show_short(L))
fi = false_instance(L)
print('     instance with W-true Sub premises and false conclusion:', show_short(fi) if fi else None)
# (vi) canonicalization (premises sorted by the substituted term, conjuncts in fixed order) repairs (iv),(v)
def canonicalize(step):
    prem = sorted(step[1:-1], key=lambda p: size(p[3]))   # 0 before S(x)
    c = step[-1]; ant = c[1]
    if ant[1][0] == 'all': ant = AND(ant[2], ant[1])
    return ('st',) + tuple(prem) + (IMP(ant, c[2]),)
D = [ind(eq(add(x, Z), x)), ind(NOT(eq(S(x), Z))), ind_swapped(lt(x, S(x))), ind_conj_swapped(IMP(eq(x, Z), eq(add(x, x), Z)))]
print('(vi) after canonicalization: lgg == sigma_x:', equiv(lgg_list([canonicalize(s) for s in D]), SIGMA_X))
