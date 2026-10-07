# e9: untagged learning of two DT° schemas at once (Prop F.5 and F.6).
# Target: Ind ∪ eps-Ind (k' = 2), class H_2(DT°) (unions of at most 2 templates), data = 3 instances of
# each schema, unlabeled and mixed.  For each schema the data are not covered by 2 failure sets (three
# different main connectives, all motives use their argument), so by Prop F.5 D is an anchor in H_2.
# The union cautious verifier is computed through Prop F.6 (all partitions into <= 2 blocks, each block
# by the feature verifier of Thm C).  With k = 1 (one template for everything) the verifier is shown too.
import itertools
from dtcore import *
from dtfeat import Prefix
X = H(0)

ind_motives = [eq(X, X), NOT(eq(X, Z)), ALL(eq(V(0), X))]
ein_motives = [mem(X, PA), NOT(mem(X, X)), EX(mem(V(0), X))]
D = [Ind(m) for m in ind_motives] + [instantiate(T_EIND, {'P': m}) for m in ein_motives]


def partitions(items, k):
    """set partitions of items into at most k nonempty blocks"""
    if not items:
        yield []
        return
    first, rest = items[0], items[1:]
    for p in partitions(rest, k):
        for i in range(len(p)):
            yield p[:i] + [[first] + p[i]] + p[i + 1:]
        if len(p) < k:
            yield [[first]] + p


cache = {}
def acc_block(block, q):
    key = tuple(sorted(map(repr, block)))
    if key not in cache:
        cache[key] = Prefix(block)
    return cache[key].accepts(q)


def acc_union(D, q, k):
    return all(any(acc_block(B, q) for B in P) for P in partitions(list(D), k))


queries = {
    'Ind(x+0=x)': Ind(eq(add(X, Z), X)),
    'Ind(Ey. y=Sx)': Ind(EX(eq(V(0), S(X)))),
    'Ind(x=0 -> 0=x)': Ind(IMP(eq(X, Z), eq(Z, X))),
    'eps-Ind(x in b & b in x)': instantiate(T_EIND, {'P': AND(mem(X, PB), mem(PB, X))}),
    'eps-Ind(Ay. y in x)': instantiate(T_EIND, {'P': ALL(mem(V(0), X))}),
    'false s* = (0=0 & Ax(x=x -> Sx=Sx)) -> Ax x=0': IMP(AND(eq(Z, Z), ALL(IMP(eq(V(0), V(0)), eq(S(V(0)), S(V(0)))))), ALL(eq(V(0), Z))),
    'mixed: (a in a & Ax(Ay(y in x -> x=x) -> x=x)) -> Ax x=x': IMP(AND(mem(PA, PA), ALL(IMP(ALL(IMP(mem(V(0), V(1)), eq(V(1), V(1)))), eq(V(0), V(0))))), ALL(eq(V(0), V(0)))),
    'eps-Ind-shaped, wrong P(x) slot': IMP(ALL(IMP(ALL(IMP(mem(V(0), V(1)), mem(V(0), PA))), mem(PA, V(0)))), ALL(mem(V(0), PA))),
}
print('data (unlabeled):')
for d in D:
    print('   ', pp(d))
for k in (1, 2, 3):
    print('k = %d:' % k)
    for name, q in queries.items():
        print('    %-58s %s' % (name, acc_union(D, q, k)))
