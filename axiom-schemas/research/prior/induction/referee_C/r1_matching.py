# Referee C, r1: matching claims (C1) with independent code.
#  (a) T_ind: unique matcher, P = motive, on the rich pool (incl. v, E, *, rebinding)
#  (b) DT° templates: total number of SO°-matchers (projection/imitation, all solutions) is 1
#      whenever the template is determinate (random templates from random generalizations)
#  (c) 2^k matchers for P(0); (P(0)&B)->C against Ind(0+x=x)
#  (d) determinate matching with NESTED arguments (outside SO°) : read-off + check agrees with
#      instantiation for random bodies
import random, itertools, time
from rc_core import *
from rc_pool import *

P = pool(seed=7, n=60)
ok = all(det_match(T_IND, Ind(m)) == {'P': m} for m in P.values())
cnt = all(len(bodies([(c, a, D) for (n, a, c, D) in occ])) == 1
          for m in P.values() for occ in [[]] if rigid_walk(T_IND, Ind(m), 0, occ))
print('(a) %d motives: det_match(T_ind) returns P = motive: %s; exactly one SO-matcher: %s' % (len(P), ok, cnt))

# non-instances must be rejected
bad = [IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(V(0), V(0)), EQ(S(V(0)), S(V(0)))))), ALL(EQ(V(0), Z()))),   # s*
       IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(V(0), Z()), EQ(V(0), Z())))), ALL(EQ(V(0), Z())))]           # T12 false instance
print('    s*, T12-false-instance in inst(T_ind):', [det_match(T_IND, b) is not None for b in bad])

# (b) random DT° templates obtained by generalizing random sentences, count all matchers
rng = random.Random(3)
def generalize(s, rng, D=0, pr=0.25, names=None):
    """randomly replace subformulas/subterms by metavariable occurrences with pattern or ground args"""
    if names is None: names = {}
    h = s[0]
    if h in ('v', '0'): return s
    if rng.random() < pr:
        sort = 'F' if h in FORMH else 'T'
        # choose args: distinct bound variables in scope that occur, plus maybe a ground term
        occ_vars = sorted({k for k in range(D) if contains_var(s, k)})
        args = [V(k) for k in occ_vars]
        nm = ('Q%d' if sort == 'F' else 'g%d') % len(names)
        names[nm] = 1
        return ('M', nm, tuple(args))
    nD = D + 1 if h in BIND else D
    return remake(s, [generalize(c, rng, nD, pr, names) for c in children(s)])

def contains_var(t, k):
    if t == ('v', k): return True
    return any(contains_var(c, k) for c in children(t))

tested = uniq = 0
for trial in range(3000):
    m = rng.choice(list(P.values()))
    s = Ind(m)
    T = generalize(s, rng)
    if not mvars(T): continue
    # add a derived (non-pattern) occurrence by replacing another subformula by M(ground) if it matches
    assert is_DT(T) and det_match(T, s) is not None
    occ = []
    rigid_walk(T, s, 0, occ)
    by = {}
    for (n, a, c, D) in occ: by.setdefault(n, []).append((c, a, D))
    tot = 1
    for v in by.values(): tot *= len(bodies(v))
    tested += 1; uniq += (tot == 1)
print('(b) %d random determinate generalizations of pool instances: matcher count 1 in %d' % (tested, uniq))

# (b') T_ind-like determinate templates with derived occurrences: count matchers on instances
derived = [T_IND,
           IMP(AND(MV('P', Z()), MV('B')), ALL(MV('P', V(0)))),
           IMP(AND(MV('A'), ALL(IMP(MV('P', V(0)), MV('P', S(V(0)))))), MV('C')),
           IMP(AND(MV('A'), ALL(IMP(MV('P', V(0)), MV('Q', V(0))))), ALL(MV('P', V(0))))]
allone = all(len(bodies(v)) == 1
             for T in derived for m in P.values() for occ in [[]] if rigid_walk(T, Ind(m), 0, occ)
             for v in [[(c, a, D) for (n, a, c, D) in occ if n == nm] for nm in set(mvars(T))])
print("(b') T_ind, T8, T11, T12 on all pool instances: every metavariable has exactly one body:", allone)

# (c) exponential matcher counts for a non-determinate occurrence
for k in (2, 4, 6, 8, 10):
    s = Z()
    sent = EQ(Z(), Z())
    for _ in range(k // 2 - 1): sent = AND(sent, EQ(Z(), Z()))
    occ = []
    assert rigid_walk(MV('P', Z()), sent, 0, occ)
    print('(c) P(0) vs sentence with %2d zeros: %d matchers' % (k, len(bodies([(c, a, D) for (n, a, c, D) in occ]))))
T = IMP(AND(MV('P', Z()), MV('B')), MV('C'))
occ = []; rigid_walk(T, Ind(EQ(ADD(Z(), X), X)), 0, occ)
print('    (P(0)&B)->C vs Ind(0+x=x): matchers for P =', len(bodies([(c, a, D) for (n, a, c, D) in occ if n == 'P'])))

# (d) nested arguments: F(F(Sx)) etc.  Instantiate with random bodies and re-match.
def rbody_term(rng, d=2):
    if d == 0 or rng.random() < 0.3: return rng.choice([X, Z(), X])
    return rng.choice([S(rbody_term(rng, d - 1)), ADD(rbody_term(rng, d - 1), rbody_term(rng, d - 1))])
F = lambda t: MV('f', t)
nested = [IMP(AND(EQ(F(Z()), Z()), ALL(IMP(EQ(F(V(0)), V(0)), EQ(F(F(S(V(0)))), S(V(0)))))), ALL(EQ(F(V(0)), V(0)))),
          AND(ALL(EQ(F(V(0)), F(V(0)))), EQ(F(F(Z())), F(F(Z()))))]
okn = True
for T in nested:
    assert is_DT(T) and not is_SO(T)
    for _ in range(300):
        th = {'f': rbody_term(rng)}
        s = instantiate(T, th)
        okn &= det_match(T, s) == th
print('(d) nested determinate templates: read-off matcher reproduces the generating body in all trials:', okn)

# (e) timing of det_match on T_ind (non-lazy implementation; just a sanity check of near-linearity)
for n in (10, 100, 1000, 10000):
    m = EQ(X, X)
    for _ in range(n): m = AND(m, EQ(S(X), ADD(X, S(Z()))))
    s = Ind(m)
    t0 = time.time(); r = det_match(T_IND, s); dt = time.time() - t0
    print('(e) motive size %6d instance size %7d: matched %s in %.4f s' % (size(m), size(s), r is not None, dt))
