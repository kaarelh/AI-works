# A5: Metamath-style (implicit substitution) encoding of induction, modeled on set.mm's finds/nnind:
#   H1: |- x = 0 -> (ph <-> ps)    H2: |- x = y -> (ph <-> ch)    H3: |- x = Sy -> (ph <-> th)
#   H4: |- ps                       H5: |- ch -> th                   ==>   |- ph
# (set.mm also has H4': x = A -> (ph <-> ta) and concludes A e. om -> ta; dropped here.)
from common import *
import random, itertools
rng = random.Random(5)
def mm(ph, ps, ch, th, X=x, Y=y):
    return ('st', IMP(eq(X, Z), IFF(ph, ps)), IMP(eq(X, Y), IFF(ph, ch)), IMP(eq(X, S(Y)), IFF(ph, th)), ps, IMP(ch, th), ph)
def mm_canon(ph, X=x, Y=y):
    assert not occurs(Y, ph)
    return mm(ph, subst(ph, X, Z), subst(ph, X, Y), subst(ph, X, S(Y)), X, Y)
SIG_MM = mm(MV('ph'), MV('ps'), MV('ch'), MV('th'))
SIG_MM_M = mm(MV('ph'), MV('ps'), MV('ch'), MV('th'), MV('X'), MV('Y'))
# motives over x and a parameter u (y must not occur in ph)
U = motives_upto(5, ('x', 'u'))
def cond(phis): return len({p[0] for p in phis}) > 1 and any('x' in free_vars(p) for p in phis)
bad = 0; tot = 0
for i in range(len(U)):
    for j in range(i + 1, len(U)):
        L = lgg_list([mm_canon(U[i]), mm_canon(U[j])]); tot += 1
        assert match(SIG_MM, L) is not None
        if equiv(L, SIG_MM) != cond([U[i], U[j]]): bad += 1
print(f'(1) MM encoding, x,y fixed, all {tot} pairs of canonical instances: lgg == pattern <=> (roots differ & one non-vacuous): mismatches = {bad}')
# x, y metavariables: induction variable from {x,n}, eigenvariable from {y,k}
UP = []
for p in motives_upto(5, ('x', 'u')):
    for X_, Y_ in ((x, y), (n, k), (x, k), (n, y)):
        ph = subst(p, x, X_)
        UP.append((ph, X_, Y_))
def cond_m(S_):
    return (len({p[0] for p, _, _ in S_}) > 1 and any(X_[0] in free_vars(p) for p, X_, _ in S_)
            and len({X_ for _, X_, _ in S_}) > 1 and len({Y_ for _, _, Y_ in S_}) > 1)
bad = 0
for _ in range(40000):
    S_ = rng.sample(UP, 2)
    if equiv(lgg_list([mm_canon(*q) for q in S_]), SIG_MM_M) != cond_m(S_): bad += 1
print('(1b) x,y metavariables, 40000 random pairs: lgg == pattern <=> (roots differ & non-vacuous & both variable columns vary): mismatches =', bad)

# (2) guards: the freshness family v notin FV(M), v in {X,Y}, M in {ph,ps,ch,th}, plus X != Y.
def parts(s):
    th = match(SIG_MM_M, s); return th
GUARDS = {f'{v} notin FV({M})': (lambda th, v=v, M=M: th[v][0] not in free_vars(th[M]))
          for v in ('X', 'Y') for M in ('ph', 'ps', 'ch', 'th')}
GUARDS['X != Y'] = lambda th: th['X'] != th['Y']
data = [mm_canon(p) for p in rng.sample(U, 40)]
learned = [g for g, f in GUARDS.items() if all(f(parts(s)) for s in data)]
print('\n(2) guards true on 40 canonical data (= learned guards, lem:setting:guard):', learned)
print('    set.mm finds DV ($d x ps, x ch, x th, y ph, x y) are all learned; spurious learned guard(s):',
      [g for g in learned if g not in ('X notin FV(ps)', 'X notin FV(ch)', 'X notin FV(th)', 'Y notin FV(ph)', 'X != Y')])
# a non-canonical genuine instance with y free in ps refutes the spurious guard
ph = eq(add(x, Z), x)
nc = mm(ph, AND(subst(ph, x, Z), eq(y, y)), subst(ph, x, y), subst(ph, x, S(y)))
print('    non-canonical genuine instance ps := ph[0/x] & y=y violates Y notin FV(ps):', not GUARDS['Y notin FV(ps)'](parts(nc)))

# (3) which guard subsets make every instance sound?  explicit counterexamples (premises PA-provable, conclusion false)
def premises_true(s, B=8): return all(ev_closure(f, B=B, Bfree=B) for f in s[1:-1])
ce_yphi = mm(NOT(eq(x, S(S(y)))), NOT(eq(Z, S(S(y)))), NOT(eq(y, S(S(y)))), NOT(eq(S(y), S(S(y)))))
ce_xchth = mm(eq(x, Z), eq(Z, Z), eq(x, Z), eq(x, Z))
for name, s in (('violates only Y notin FV(ph)', ce_yphi), ('violates only X notin FV(ch) and X notin FV(th)', ce_xchth)):
    th_ = parts(s)
    print(f'\n(3) counterexample {name}:', show(s))
    print('    guards violated:', [g for g, f in GUARDS.items() if not f(th_) and g in ('X notin FV(ps)', 'X notin FV(ch)', 'X notin FV(th)', 'Y notin FV(ph)', 'X != Y')])
    print('    premises true (bounded):', premises_true(s), '; conclusion true (bounded):', ev_closure(s[-1], B=8, Bfree=8))
# randomized semantic test of sufficiency of {Y notin ph, X notin ch} and {Y notin ph, X notin th}
QF = [f for f in motives_upto(5, ('x', 'y'), conns=('not',), quants=()) ]
def search(guardset, trials=200000, seed=1):
    r = random.Random(seed)
    for _ in range(trials):
        ph = r.choice(QF)
        if 'y' in free_vars(ph) and 'Y notin FV(ph)' in guardset: continue
        # build ps, ch, th as perturbations of the canonical ones
        def pick(canon_):
            return r.choice([canon_, canon_, r.choice(QF), ph, NOT(canon_)])
        ps, ch, th = pick(subst(ph, x, Z)), pick(subst(ph, x, y)), pick(subst(ph, x, S(y)))
        s = mm(ph, ps, ch, th); t = parts(s)
        if not all(GUARDS[g](t) for g in guardset): continue
        if premises_true(s, B=7) and not ev_closure(ph, B=7, Bfree=5): return s
    return None
for gs in (['Y notin FV(ph)', 'X notin FV(ch)'], ['Y notin FV(ph)', 'X notin FV(th)'],
           ['X notin FV(ps)', 'X notin FV(ch)', 'X notin FV(th)'], ['Y notin FV(ph)', 'X notin FV(ps)']):
    ce = search(gs)
    print(f'(3b) guards {gs}: truth-preservation counterexample in bounded N:', show(ce) if ce else 'none found')

# (4) NF-premise encoding: freshness recorded as decidable premises -> plain first-order pattern
def mm_nf(ph, ps, ch, th):
    return ('st', ('NF', x, ch), ('NF', y, ph)) + mm(ph, ps, ch, th)[1:]
def mm_nf_canon(ph): return mm_nf(ph, subst(ph, x, Z), subst(ph, x, y), subst(ph, x, S(y)))
SIG_NF = mm_nf(MV('ph'), MV('ps'), MV('ch'), MV('th'))
print('\n(4) NF-premise encoding (minimal guard set {x notin FV(ch), y notin FV(ph)} as premises): lgg of an anchor pair == pattern:',
      equiv(lgg_list([mm_nf_canon(eq(add(x, Z), x)), mm_nf_canon(NOT(eq(S(x), Z)))]), SIG_NF))
import math
print('\n(5) coupon constants for the MM pattern (x,y fixed, canonical data): v=4, c=14, rho=0.4 -> N >=',
      math.ceil(math.log(14 / 0.01) / 0.4), '(Thm coupon); exact requirement unchanged (10), since all witness events coincide')
