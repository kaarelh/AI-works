# Referee C, r4: C4 (26 frame generalizations) and C6.2 (Ind is DT_s-closed iff s >= 12), independent.
import random, itertools
from rc_core import *
from rc_enum import enum_covering
from rc_pool import pool, rand_motive

D = [Ind(EQ(X, X)), Ind(NOT(EQ(X, Z())))]
Ts = sorted([T for T in enum_covering(D, 14, amax=3, ar_F=(0, 1, 2), ar_T=(0, 1)) if is_DT(T)], key=size)
print('DT covering templates of the anchor pair (size <= 14):', len(Ts), ' all >= T_ind:', all(geq(T, T_IND) for T in Ts))
from collections import Counter
print('size histogram:', sorted(Counter(size(T) for T in Ts).items()))
x = V(0)
sstar = IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(x, x), EQ(S(x), S(x))))), ALL(EQ(x, Z())))
s0star = IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(Z(), Z()), EQ(Z(), Z())))), ALL(EQ(x, Z())))
for s in range(7, 15):
    mem = [T for T in Ts if size(T) <= s]
    print('s=%2d: |DT_s members containing Ind| = %2d; s* accepted: %s; s0* accepted: %s' %
          (s, len(mem), all(covers(T, sstar) for T in mem), all(covers(T, s0star) for T in mem)))

# random frame sentences built from random motives: alpha & Ax(beta -> gamma) -> Ax delta with
# alpha in {m1(0)}, beta = m2(x), gamma in {m3(Sx)}, delta = m4(x), where the m_i are drawn so that
# coincidences are frequent (small pool)
rng = random.Random(9)
P = list(pool(seed=4, n=10).values())
small = [EQ(X, X), EQ(X, Z()), EQ(Z(), Z()), EQ(S(X), S(X)), NOT(EQ(X, Z())), EQ(Z(), X), EQ(ADD(X, Z()), X)]
cands = set()
for _ in range(20000):
    ms = [rng.choice(small) for _ in range(4)]
    a = plug(ms[0], [rng.choice([Z(), S(Z())])], 0)
    b = plug(ms[1], [x], 1)
    c = plug(ms[2], [rng.choice([S(x), x, Z()])], 1)
    d = plug(ms[3], [x], 1)
    cands.add(IMP(AND(a, ALL(IMP(b, c))), ALL(d)))
cands = list(cands)
isind = {s: det_match(T_IND, s) is not None for s in cands}
print('random frame sentences: %d (%d are induction instances)' % (len(cands), sum(isind.values())))
for s in range(7, 15):
    mem = [T for T in Ts if size(T) <= s]
    acc = [w for w in cands if all(covers(T, w) for T in mem)]
    print('s=%2d: accepted %4d, of which non-induction %4d' % (s, len(acc), sum(1 for w in acc if not isind[w])))
T8 = IMP(AND(MV('P', Z()), MV('B')), ALL(MV('P', x)))
T11 = IMP(AND(MV('A'), ALL(IMP(MV('P', x), MV('P', S(x))))), MV('C'))
T12 = IMP(AND(MV('A'), ALL(IMP(MV('P', x), MV('Q', x)))), ALL(MV('P', x)))
print('sizes T8,T11,T12:', size(T8), size(T11), size(T12), ' in enumerated list:',
      [any(geq(T, U) and geq(U, T) for U in Ts) for T in (T8, T11, T12)])
print('T8 & T11 & T12 accept exactly the induction instances among the candidates:',
      all((covers(T8, w) and covers(T11, w) and covers(T12, w)) == isind[w] for w in cands))
