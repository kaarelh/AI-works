# Referee: second sufficient test for the 46 leftover unsound lggs of rb3_refutability.py.
# Try to make the step clause provable by REFLEXIVITY: unify the two sides of the C-slot equation (first-order
# unification over the metavariables; x is a constant), then instantiate the remaining metavariables from a pool
# so that A is a true closed q.f. sentence and Ax B is false in N.  Refutation: refl |- c=c, ->I, AI, &I with
# the W-leaf A, ->E with the instance, AE at the counterexample: W-false. Descent unblocked (all trusted, from
# W-true leaves).  Also rerun the congruence-closure test with a larger pool.
import itertools
from rb_core import *
from rb_cc import step_valid_over_N
exec(open('rb2_algorithm.py').read().split("stats = Counter()")[0])

def unify(a, b, s):
    a, b = walk(a, s), walk(b, s)
    if a == b: return s
    if ismv(a): return None if occurs(a, b, s) else {**s, a[1]: b}
    if ismv(b): return unify(b, a, s)
    if a[0] != b[0] or len(a) != len(b): return None
    for p, q in zip(a[1:], b[1:]):
        s = unify(p, q, s)
        if s is None: return None
    return s
def walk(t, s):
    while ismv(t) and t[1] in s: t = s[t[1]]
    return t
def occurs(v, t, s):
    t = walk(t, s)
    if t == v: return True
    return (not ismv(t)) and any(occurs(v, a, s) for a in t[1:])
def resolve(t, s):
    t = walk(t, s)
    return t if ismv(t) else (t[0],) + tuple(resolve(a, s) for a in t[1:])

POOLT = [ZERO, S(ZERO), S(S(ZERO)), X, S(X), ADD(ZERO, X), ADD(X, ZERO), MUL(ZERO, X), MUL(X, ZERO), ADD(X, X),
         MUL(X, X), ADD(ZERO, S(X)), ADD(S(X), ZERO), MUL(ZERO, S(X)), MUL(S(X), ZERO), ADD(S(ZERO), X), MUL(S(ZERO), X),
         ADD(S(ZERO), MUL(ZERO, X))]
POOLF = [EQ(ZERO, ZERO), EQ(ZERO, S(ZERO)), EQ(X, ZERO), EQ(X, X), NEG(EQ(X, ZERO))]
def search(L):
    C = L[1][2][2][2]
    cands = [L]
    if C[0] == '=':
        th = unify(C[1], C[2], {})
        if th is not None: cands.insert(0, resolve(L, th))
    for L2 in cands:
        srt = sorts(L2); names = sorted(srt)
        choices = [POOLT if next(iter(srt[n])) == 'T' else POOLF for n in names]
        for k, combo in enumerate(itertools.product(*choices)):
            if k > 200000: break
            s = apply(L2, dict(zip(names, combo)))
            if not is_sentence(s): continue
            A, B, Cc = s[1][1], s[1][2][2][1], s[1][2][2][2]
            if fv(A): continue
            try:
                if not holds(A) or holds(ALL(X, B)): continue
            except Unsupported: continue
            if (Cc[0] == '=' and Cc[1] == Cc[2]) or step_valid_over_N(B, Cc):
                return s
    return None

left = []
for f1, f2 in itertools.combinations(allf, 2):
    if X not in fv(f1) and X not in fv(f2): continue
    L = antiunify([IND(f1), IND(f2)])
    if any(inst_of(I, L) for I in NAMED) or closed_collapse(L) is not None: continue
    if false_instance(L, cap=20000) is None: continue
    left.append((f1, f2, L))
found = 0; still = []
for f1, f2, L in left:
    s = search(L)
    if s is not None: found += 1
    else: still.append((show(f1), show(f2), show(normalize(L))))
print('unsound lggs with neither named instance nor closed collapse: %d; unblocked refutation certified (refl/CC, larger pool): %d; none found: %d'
      % (len(left), found, len(still)))
for e in still: print('   ', e)
