# C2: the generalizations of the induction template, and the size threshold for soundness of the
# bounded-size cautious verifier.
#  (a) all SO° templates (size <= 14, args of size <= 3, arity <= 2) covering the anchor pair
#      {Ind(x=x), Ind(~x=0)}; the determinate ones are exactly the "frame generalizations" predicted by
#      Theorem C3's proof, and every one of them is >= T_ind (so contains all of Ind).
#  (b) closure threshold: Ind is the intersection of the DT_s templates containing it iff s >= 12;
#      for s <= 11 the false sentence s* lies in every such template.
import itertools, time
from so_core import *
from so_enum import enumerate_covering
from so_pool import *

t0 = time.time()
D = [Ind(eq(X, X)), Ind(NOT(eq(X, Z)))]
SMAX = 14
F = enumerate_covering(D, SMAX, amax=3, maxar=2)
DT = sorted([T for T in F if is_determinate(T)], key=lambda T: (size(T), pp(T)))
ND = [T for T in F if not is_determinate(T)]
print('(a) SO° templates of size <= %d covering {Ind(x=x), Ind(~x=0)}: %d (determinate %d, non-determinate %d)'
      % (SMAX, len(F), len(DT), len(ND)))

# ---- predicted frame generalizations (proof of Theorem C3)
def predicted():
    A = lambda n: M(n)
    out = set()
    # prefix choices: root flex | imp(U, V);  U: flex | and(a, s);  s: flex | all(W);  W: flex | imp(b, c);  V: flex | all(d)
    for Uc in ('flex', 'and'):
        for sc in (('flex', 'all') if Uc == 'and' else (None,)):
            for Wc in (('flex', 'imp') if sc == 'all' else (None,)):
                for Vc in ('flex', 'all'):
                    motive_slots = []
                    if Uc == 'and': motive_slots.append('a')
                    if Wc == 'imp': motive_slots += ['b', 'c']
                    if Vc == 'all': motive_slots.append('d')
                    # set partitions of motive slots
                    def parts(lst):
                        if not lst: yield []; return
                        first, rest = lst[0], lst[1:]
                        for p in parts(rest):
                            yield [[first]] + p
                            for i in range(len(p)):
                                yield p[:i] + [[first] + p[i]] + p[i + 1:]
                    for p in parts(motive_slots):
                        good = True
                        for cl in p:
                            hasbd = ('b' in cl) or ('d' in cl)
                            if 'a' in cl and not hasbd and len(cl) > 1: good = False
                            if 'c' in cl and not hasbd and len(cl) > 1: good = False
                        if not good: continue
                        fill = {}
                        for i, cl in enumerate(p):
                            hasbd = ('b' in cl) or ('d' in cl)
                            nm = 'Q%d' % i
                            for sl in cl:
                                if sl == 'a': fill['a'] = M(nm, Z) if hasbd else M('A' + nm)
                                if sl in ('b', 'd'): fill[sl] = M(nm, V(0))
                                if sl == 'c': fill['c'] = M(nm, S(V(0))) if hasbd else M(nm, V(0))
                        if Wc == 'imp': W = IMP(fill['b'], fill['c'])
                        else: W = M('W', V(0))
                        sfill = ALL(W) if sc == 'all' else M('Bs')
                        U = AND(fill['a'], sfill) if Uc == 'and' else M('Bu')
                        Vt = ALL(fill['d']) if Vc == 'all' else M('Bv')
                        out.add(canon(IMP(U, Vt)))
    out.add(canon(M('Broot')))
    return out
PRED = predicted()
print('predicted frame generalizations (Theorem C3):', len(PRED), '| equal to the enumerated determinate set:',
      PRED == set(DT))
print('every determinate covering template is >= T_ind (subsumption check):', all(subsumes(T, T_IND) for T in DT))
for T in DT: print('   %2d  %s' % (size(T), pp(T)))

# ---- non-determinate covering templates: do they contain all held-out instances / are they >= T_ind?
bad = [T for T in ND if not covers_all(T, HELD)]
sub = sum(1 for T in ND if subsumes(T, T_IND))
print('non-determinate covering templates: %d; >= T_ind: %d; missing some held-out instance: %d'
      % (len(ND), sub, len(bad)))
for T in sorted(bad, key=size)[:5]: print('   bad:', size(T), pp(T))

# ---- (b) closure threshold
print('\n(b) intersection of the DT_s templates containing Ind')
qf = {k: m for k, m in POOL.items() if not k.startswith('Ay')}
cands = set()
for bk, b in qf.items():
    for dk, d in qf.items():
        for a in {plug(b, [Z]), plug(d, [Z]), eq(Z, Z)}:
            for c in {plug(b, [S(X)]), plug(d, [S(X)])}:
                s = frame(a, b, c, d)
                if not covers(T_IND, s): cands.add(s)
cands = sorted(cands, key=lambda s: (size(s), pp(s)))
print('candidate non-induction frame sentences:', len(cands))
sstar = frame(eq(Z, Z), eq(X, X), eq(S(X), S(X)), eq(X, Z))
for s_ in range(1, SMAX + 1):
    Gs = [T for T in DT if size(T) <= s_]
    surv = [c for c in cands if all(covers(T, c) for T in Gs)]
    false_surv = [c for c in surv if truth(c) is False]
    print('  s=%2d: |DT_s templates containing Ind| = %2d; surviving candidates %4d (false: %4d); s* survives: %s'
          % (s_, len(Gs), len(surv), len(false_surv), all(covers(T, sstar) for T in Gs)))
    if s_ == 11:
        print('        smallest false survivors at s=11:', [pp(c) for c in false_surv[:3]])

print('\n   s* =', pp(sstar), ' true in N:', truth(sstar))
three = [IMP(AND(M('P', Z), M('B')), ALL(M('P', V(0)))),
         IMP(AND(M('A'), ALL(IMP(M('P', V(0)), M('P', S(V(0)))))), M('C')),
         IMP(AND(M('A'), ALL(IMP(M('P', V(0)), M('Q', V(0))))), ALL(M('P', V(0))))]
for T in three:
    print('   %2d %-55s covers s*: %s' % (size(T), pp(T), covers(T, sstar)))

# non-determinate templates of size <= 11 that cover every held-out instance: do they contain s*?
nd11 = [T for T in ND if size(T) <= 11 and covers_all(T, HELD)]
print('non-determinate SO° templates of size <= 11 covering all held-out instances: %d; all contain s*: %s'
      % (len(nd11), all(covers(T, sstar) for T in nd11)))
print('time %.1f s' % (time.time() - t0))
