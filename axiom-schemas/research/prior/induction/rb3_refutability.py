# Referee: which unsound lggs of raw induction pairs have an UNBLOCKED refutation from closed q.f. truths
# (W) and trusted first-order logic, relative to the empty position?
# Sufficient test (certifies an unblocked refutation): an instance  A & Ax(B -> C) -> Ax B  with A a true closed
# q.f. sentence, B, C literals with  Ax(B -> C)  true in every algebra extending N (decided by ground congruence
# closure, rb_cc.py; then it is FOL-derivable from W-true closed literals, so forward propagation gives it value 1),
# and Ax B false in N (AE at the least counterexample gives a W-false closed literal).
# Second part: K_0 = (z1+0=z1) & Ax(z1+x=z2 -> z1+Sx=Sz2) -> Ax(z1+x=z2) is consistent with Th_qf(N):
# for every closed t and term u(x), the step fails at a fresh element of some extension of N, unless u is
# literally t+x after evaluating closed subterms (then the instance is true in every extension of N).
import itertools, random, sys
from rb_core import *
from rb_cc import step_valid_over_N, satisfiable, to_node, _gsub

exec(open('rb2_algorithm.py').read().split("stats = Counter()")[0])   # reuse enumerator, NAMED, closed_collapse

POOLT = [ZERO, S(ZERO), S(S(ZERO)), X, S(X), ADD(ZERO, X), ADD(X, ZERO), MUL(ZERO, X), ADD(S(ZERO), MUL(ZERO, X))]
POOLF = [EQ(ZERO, ZERO), EQ(ZERO, S(ZERO)), EQ(X, ZERO), EQ(X, X), NEG(EQ(X, ZERO)), EQ(S(X), ZERO)]
def certified_unblocked(L, cap=40000):
    srt = sorts(L); names = sorted(srt)
    choices = [POOLT if next(iter(srt[n])) == 'T' else POOLF for n in names]
    for k, combo in enumerate(itertools.product(*choices)):
        if k > cap: break
        s = apply(L, dict(zip(names, combo)))
        if not is_sentence(s): continue
        A, B, C = s[1][1], s[1][2][2][1], s[1][2][2][2]
        if fv(A) or not quantfree(A): continue
        try:
            if not holds(A): continue
            if holds(ALL(X, B)): continue
        except Unsupported:
            continue
        v = step_valid_over_N(B, C)
        if v: return s
    return None
def quantfree(f):
    if len(f) == 1: return True
    if f[0] in 'AE': return False
    return all(quantfree(a) for a in f[1:])

counts = Counter(); left = []
for f1, f2 in itertools.combinations(allf, 2):
    if X not in fv(f1) and X not in fv(f2): continue
    L = antiunify([IND(f1), IND(f2)])
    if any(inst_of(I, L) for I in NAMED) or closed_collapse(L) is not None: continue
    fi = false_instance(L, cap=20000)
    if fi is None: continue
    c = certified_unblocked(L)
    if c is not None:
        counts['certified unblocked refutation (CC)'] += 1
    else:
        counts['no certified refutation found'] += 1
        left.append((show(f1), show(f2), show(normalize(L)), show(fi)))
print('unsound pairs with neither named instance nor closed collapse:', sum(counts.values()))
for k, v in counts.items(): print('  %4d  %s' % (v, k))
for e in left[:30]: print('   ', e)

# ---------------- K_0: per-instance witness of step failure (computational check of the hand proof) ----------------
def terms_upto(n):
    T = {1: [ZERO, X]}
    for s in range(2, n + 1):
        lst = [S(t) for t in T[s - 1]]
        for a in range(1, s - 1):
            for p in T[a]:
                for q in T[s - 1 - a]: lst += [ADD(p, q), MUL(p, q)]
        T[s] = lst
    return [t for s in T for t in T[s]]
U = terms_upto(6)
bad = 0; trivial = 0; tot = 0
for k in range(4):
    t = numeral(k)
    for u in U:
        tot += 1
        g = ('g',)
        lhs, rhs = to_node(_gsub(ADD(t, X))), to_node(_gsub(u))
        if lhs == rhs: trivial += 1; continue
        s1, s2 = to_node(_gsub(ADD(t, S(X)))), to_node(_gsub(S(u)))
        if not satisfiable([(lhs, rhs)], [(s1, s2)]): bad += 1; print('   step VALID for t=%d u=%s' % (k, show(u)))
print('K_0: closed t in {0..3}, all terms u(x) of size <= 6: %d instances, %d with u == t+x after closed '
      'evaluation, %d where the step holds in every extension of N' % (tot, trivial, bad))
# multi-generator sanity: several instances at once (distinct generators) are jointly satisfiable
print('(joint satisfiability across instances is by the free amalgamation argument in the report)')
