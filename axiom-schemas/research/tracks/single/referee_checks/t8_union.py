# Referee check of e9 / Prop F.6: untagged union verifier over H_k(DT°) via partitions + feature verifier,
# and (independently of Thm C) via brute-force covering templates for each block.
import itertools
from rc_core import *
from rc_enum import enumerate_covering
x = ('z', 0)
EIND = IMP(ALL(IMP(ALL(IMP(IN(V(0), V(1)), M('P', V(0)))), M('P', V(0)))), ALL(M('P', V(0))))
def EInd(b): return inst(EIND, {'P': b})
a, b_ = ('a',), ('b',)
D = [Ind(EQ(x, x)), Ind(NOT(EQ(x, Z))), Ind(ALL(EQ(V(0), x))),
     EInd(IN(x, a)), EInd(NOT(IN(x, x))), EInd(EX(IN(V(0), x)))]
s_star = IMP(AND(EQ(Z, Z), ALL(IMP(EQ(V(0), V(0)), EQ(S(V(0)), S(V(0)))))), ALL(EQ(V(0), Z)))
queries = {'Ind(x+0=x)': Ind(EQ(ADD(x, Z), x)), 'Ind(Ey y=Sx)': Ind(EX(EQ(V(0), S(x)))),
           'Ind(x=0->0=x)': Ind(IMP(EQ(x, Z), EQ(Z, x))), 'EInd(x in b & b in x)': EInd(AND(IN(x, b_), IN(b_, x))),
           'EInd(Ay y in x)': EInd(ALL(IN(V(0), x))), 's*': s_star,
           'mixed': IMP(AND(ALL(IMP(ALL(IMP(IN(V(0), V(1)), EQ(V(0), V(0)))), EQ(V(0), V(0)))), EQ(Z, Z)), ALL(EQ(V(0), V(0)))),
           'EInd-shaped non-instance': IMP(ALL(IMP(ALL(IMP(IN(V(0), V(1)), IN(V(0), a))), IN(Z, a))), ALL(IN(V(0), a)))}
def partitions(items, k):
    if not items:
        yield []
        return
    first, rest = items[0], items[1:]
    for p in partitions(rest, k):
        for i in range(len(p)):
            yield p[:i] + [[first] + p[i]] + p[i + 1:]
        if len(p) < k:
            yield p + [[first]]
cache = {}
def acc_block(B, q):
    key = tuple(sorted(B))
    if key not in cache:
        cache[key] = DataInfo([D[i] for i in key])
    return cache[key].has_features(q)
for k in [1, 2, 3]:
    res = {}
    for name, q in queries.items():
        res[name] = all(any(acc_block(B, q) for B in P) for P in partitions(list(range(len(D))), k))
    print('k=%d accepts:' % k, [n for n, v in res.items() if v])
    print('     rejects:', [n for n, v in res.items() if not v])
