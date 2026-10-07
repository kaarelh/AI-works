# u2: slot accounting in the raw DT deg encoding (sentences, closure-normal form), exact version-space computation.
# For data D (some of Q's ground axioms + raw induction instances), a bound k and a query q:
#   q is NOT accepted by the cautious k-union verifier  iff  D can be covered by <= k "ok" blocks, where
#   ok(B) <=> some minimal covering template of B (optionally: with no refuted instance) does not contain q.
# ok is downward closed, so the minimal number kappa(q) of ok blocks is a set-cover number computed by DP over
# subsets.  Theory (Theorem 3, slot accounting): kappa(q) = c + chi for a query with an unseen main connective,
# where c = non-absorbing cover number of the ground part and chi = number of motive roots in the data.
import sys, itertools, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World
from practice import Q, X

W = World('arith', B=3)
MOT = {'=': [eq(add(X, Z), X), eq(mul(S(Z), X), X)], 'not': [NOT(eq(S(X), Z)), NOT(eq(S(X), X))],
       'all': [ALL(eq(add(V(0), X), add(X, V(0)))), ALL(IMP(eq(X, V(0)), eq(V(0), X)))],
       'imp': [IMP(eq(X, Z), eq(add(X, X), X)), IMP(eq(S(X), Z), eq(Z, S(Z)))]}
QUERY = {'or': canon_params(Ind(OR(eq(X, Z), NOT(eq(X, Z))))), 'ex': canon_params(Ind(EX(eq(X, S(V(0)))))),
         'and': canon_params(Ind(AND(eq(add(X, Z), X), eq(add(Z, Z), Z))))}

def kappa(D, q, negatives):
    n = len(D)
    ok = {}
    for r in range(1, n + 1):
        for B in itertools.combinations(range(n), r):
            # downward closure shortcut
            Ts = mincov([D[i] for i in B])
            good = False
            for T in Ts:
                if covers(T, q): continue
                if negatives and W.refute_template(T) is not None: continue
                good = True; break
            ok[frozenset(B)] = good
    full = frozenset(range(n))
    best = {frozenset(): 0}
    # DP over subsets in order of size
    from functools import lru_cache
    @lru_cache(maxsize=None)
    def cover(S):
        if not S: return 0
        S = frozenset(S)
        first = min(S)
        rest = sorted(S - {first})
        b = 10 ** 9
        for r in range(len(rest) + 1):
            for extra in itertools.combinations(rest, r):
                Bk = frozenset((first,) + extra)
                if ok[Bk]:
                    b = min(b, 1 + cover(S - Bk))
        return b
    return cover(full)

def ground_cover(G, negatives):
    """c: min number of blocks covering G with a minimal template that does not contain T_ind (non-absorbing)
    [and, with negatives, is unrefuted]"""
    n = len(G)
    best = n
    def good(B):
        for T in mincov([G[i] for i in B]):
            if subsumes(T, T_IND): continue
            if negatives and W.refute_template(T) is not None: continue
            return True
        return False
    @__import__('functools').lru_cache(maxsize=None)
    def cover(S):
        if not S: return 0
        first = min(S); rest = sorted(set(S) - {first}); b = 10 ** 9
        for r in range(len(rest) + 1):
            for extra in itertools.combinations(rest, r):
                Bk = (first,) + extra
                if good(Bk): b = min(b, 1 + cover(frozenset(set(S) - set(Bk))))
        return b
    return cover(frozenset(range(n)))

print('non-absorbing cover number c of all seven Q axioms, raw DT deg encoding:')
G7 = [Q[k] for k in sorted(Q)]
print('  positive data only: c =', ground_cover(G7, False))
print('  with refutation (Delta_0 + forall-E): c =', ground_cover(G7, True))
NEG3 = [eq(Z, S(Z)), eq(add(P('a1'), Z), Z), eq(mul(P('a1'), Z), S(Z))]
def ground_cover_N(G, N):
    n = len(G)
    def good(B):
        return any(not subsumes(T, T_IND) and not any(covers(T, x) for x in N) for T in mincov([G[i] for i in B]))
    import functools
    @functools.lru_cache(maxsize=None)
    def cover(S):
        if not S: return 0
        first = min(S); rest = sorted(set(S) - {first}); b = 10 ** 9
        for r in range(len(rest) + 1):
            for extra in itertools.combinations(rest, r):
                Bk = (first,) + extra
                if good(Bk): b = min(b, 1 + cover(frozenset(set(S) - set(Bk))))
        return b
    return cover(frozenset(range(n)))
print('  with the three negatives {0=S0, a1+0=0, a1*0=S0} only: c =', ground_cover_N(G7, NEG3))

configs = [(['Q1', 'Q3', 'Q5', 'Q7'], ['=', 'not']), (['Q1', 'Q3', 'Q5', 'Q7'], ['=', 'all', 'imp']),
           (['Q2', 'Q3', 'Q4'], ['=', 'not', 'all']), (['Q3', 'Q5'], ['=', 'not'])]
for qs, roots in configs:
    G = [Q[k] for k in qs]
    D = G + [canon_params(Ind(m)) for r in roots for m in MOT[r]]
    for neg in (False, True):
        c = ground_cover(G, neg)
        chi = len(roots)
        for qn, q in QUERY.items():
            kap = kappa(D, q, neg)
            print('G=%-18s roots=%-16s negatives=%-5s c=%d chi=%d  query root %-3s: kappa=%d  (theory c+chi=%d)'
                  % (','.join(qs), ','.join(roots), neg, c, chi, qn, kap, c + chi))
print('Reading: the cautious k-union verifier accepts the query iff k < kappa.')
