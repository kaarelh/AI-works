# Track "cases", Part 2(d): Separation (and Collection) as named first-order schemas with freshness guards.
# Guard family PHI = { fresh(v, Z) : v a variable name bound by the frame, Z a formula metavariable of the lgg }.
# Most specific guarded generalisation (lem:setting:guard): lgg(D) plus every guard true on all data.
# Checks: (1) the Russell instance  Az Ey Ax (x in y <-> x in z & ~x in y)  is an instance of the unguarded lgg
#             and violates fresh(y, A), which every genuine datum satisfies, so it is never accepted;
#         (2) the learned guard set equals the target guard set {fresh(y,A)} iff (N_x) and (N_z) hold
#             (Coll: {fresh(Y,A)} iff N_x, N_y, N_A), i.e. guard learning has the same witness events as DT-degree.
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, match, show
from st_core import *
from st_pool import pool_for

def free_names(t, bound=frozenset()):
    if len(t) == 1: return set() if t[0] in bound else {t[0]}
    if t[0] == '?': return set()
    if t[0] in BINDERS: return free_names(t[2], bound | {t[1][0]})
    out = set()
    for k in t[1:]: out |= free_names(k, bound)
    return out

def frame_bound_names(nm):
    out = set()
    def go(f):
        if isinstance(f, str): return
        if f[0] in BINDERS: out.add(f[1])
        for k in f[1:]:
            if not isinstance(k, str): go(k)
    go(NAMED_FRAMES[nm]); return out

def learned_guards(nm, data):
    L = lgg_list(data)
    sv = ['s%d' % i for i in range(n_slots(nm))]
    F = named_frame_term(nm, sv)
    m = match(F, L)
    metas_ = sorted({m[s][1] for s in sv})
    guards = set()
    for Zm in metas_:
        for v in frame_bound_names(nm):
            if all(v not in free_names(match(L, d)[Zm]) for d in data):
                guards.add((v, Zm))
    return L, guards, metas_

def accepts(L, guards, s):
    th = match(L, s)
    if th is None: return False
    return all(v not in free_names(th[Zm]) for v, Zm in guards)

TARGET = {'Sep': {'y'}, 'Coll': {'Y'}, 'ReplU': {'Y'}}
for nm in ('Sep', 'Coll', 'ReplU'):
    P = pool_for(nm); n = len(SCHEMAS[nm]['args'])
    tot = exact = agree = russell_rej = 0
    for k1, k2 in itertools.combinations(P, 2):
        bs = [P[k1], P[k2]]
        if not pred_R(bs): continue
        data = [named_instance(nm, b) for b in bs]
        L, G, ms = learned_guards(nm, data)
        tot += 1
        is_exact = {v for v, _ in G} == TARGET[nm]
        exact += is_exact
        agree += is_exact == all(pred_N(bs, n))
        if nm == 'Sep':
            A = ms[0]
            russell = named_instance('Sep', NOT(IN(H(0), Par('y'))))   # phi(x,z) := ~ x in y, y captured
            assert match(L, russell) is not None
            russell_rej += not accepts(L, G, russell)
        else:
            bad = named_instance(nm, EQ(H(1), Par('Y')))   # phi(x,y,A) := (y = Y): capture of Y in the consequent
            assert match(L, bad) is not None
            russell_rej += not accepts(L, G, bad)
    print('%-5s pairs with (R): %d; learned guards == target guards %s: %d; (exact) <=> all N_i: %d/%d; '
          'capture instance rejected: %d/%d' % (nm, tot, TARGET[nm], exact, agree, tot, russell_rej, tot))
# a worked example
P = pool_for('Sep')
for pair in (('x∈z', '¬x=a'), ('x∈a', '¬x=a'), ('a∈b', 'Aw(w=w)')):
    data = [named_instance('Sep', P[k]) for k in pair]
    L, G, ms = learned_guards('Sep', data)
    print('  Sep data %s: lgg %s ; learned guards %s' % (pair, show(L), sorted('fresh(%s,%s)' % g for g in G)))
