# Referee C, r5: C9 -- higher-order PATTERN anti-unification (in the style of Baumgartner-Kutsia-
# Levy-Villaret: at a disagreement under binders, a generalization variable applied to the bound
# variables that occur free in either side; identical anti-unification problems share their
# variable (the 'merge' rule; here no permutations are needed)).  Own implementation.
import itertools
from rc_core import *
from rc_pool import pool, pR, pN

def occurs(t, k):
    if t == ('v', k): return True
    return any(occurs(c, k) for c in children(t))

def au(s, t, D, store):
    if s == t: return s
    if s[0] == t[0] and s[0] not in ('v',) and len(children(s)) == len(children(t)):
        nD = D + 1 if s[0] in BIND else D
        return remake(s, [au(a, b, nD, store) for a, b in zip(children(s), children(t))])
    ys = tuple(V(k) for k in range(D) if occurs(s, k) or occurs(t, k))
    key = (s, t, ys)
    if key not in store:
        sort = 'F' if s[0] in FORMH else 'T'
        store[key] = ('X%d' if sort == 'F' else 'g%d') % len(store)
    return ('M', store[key], ys)

def lgg_list(ss):
    # fold pairwise is not the n-ary lgg in general; do it n-ary by tupling columns
    def go(cols, D, store):
        c0 = cols[0]
        if all(c == c0 for c in cols): return c0
        if all(c[0] == c0[0] and len(children(c)) == len(children(c0)) for c in cols) and c0[0] != 'v':
            nD = D + 1 if c0[0] in BIND else D
            ch = [children(c) for c in cols]
            return remake(c0, [go([x[i] for x in ch], nD, store) for i in range(len(ch[0]))])
        ys = tuple(V(k) for k in range(D) if any(occurs(c, k) for c in cols))
        key = (tuple(cols), ys)
        if key not in store:
            store[key] = ('X%d' if c0[0] in FORMH else 'g%d') % len(store)
        return ('M', store[key], ys)
    return go(list(ss), 0, {})

x = V(0)
T12 = IMP(AND(MV('A'), ALL(IMP(MV('P', x), MV('Q', x)))), ALL(MV('P', x)))
P = pool(seed=11, n=30)
names = list(P)
res = {}
for a, b in itertools.combinations(names, 2):
    ms = [P[a], P[b]]
    if not (pR(ms) and pN(ms)): continue
    L = lgg_list([Ind(m) for m in ms])
    res[(a, b)] = geq(L, T12) and geq(T12, L)
print('pattern lgg of (R)&(N) pairs equals T12 (up to renaming): %d / %d' % (sum(res.values()), len(res)))
L = lgg_list([Ind(EQ(X, X)), Ind(NOT(EQ(X, Z())))])
print('pattern lgg of {Ind(x=x), Ind(~x=0)}:', pp(L), ' is a pattern template (DT, all occurrences patterns):', is_DT(L))
bad = instantiate(T12, {'A': EQ(Z(), Z()), 'P': EQ(HOLE(0), Z()), 'Q': EQ(HOLE(0), Z())})
print('false instance of T12:', pp(bad), ' induction instance?', det_match(T_IND, bad) is not None)
