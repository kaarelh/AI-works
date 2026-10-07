# Referee C, r7: (a) C5(a) with an independent first-order lgg on the richer pool;
# (b) C8.1 non-unitarity with the independent enumerator; (c) C10 trimmed verifier, one mistake.
import itertools
from rc_core import *
from rc_enum import enum_covering
from rc_pool import pool, pR, pN

# (a) first-order Sub-encoding, x a constant; bound variables named by level; own n-ary lgg
def named(t, D=1):
    h = t[0]
    if h == 'h': return ('x',)
    if h == 'v': return ('b%d' % t[1],)          # relative level inside the motive
    if h == '0': return ('0',)
    return (h,) + tuple(named(c, D) for c in children(t))
def fo_sub(t, r):
    if t == ('x',): return r
    if len(t) == 1: return t
    return (t[0],) + tuple(fo_sub(c, r) for c in t[1:])
def step(m):
    phi = named(m); a = fo_sub(phi, ('0',)); b = fo_sub(phi, ('S', ('x',)))
    return ('st', ('Sub', phi, ('x',), ('0',), a), ('Sub', phi, ('x',), ('S', ('x',)), b),
            ('imp', ('and', a, ('all', ('x',), ('imp', phi, b))), ('all', ('x',), phi)))
def lgg(cols, store):
    c0 = cols[0]
    if all(c == c0 for c in cols): return c0
    if all(c[0] == c0[0] and len(c) == len(c0) for c in cols):
        return (c0[0],) + tuple(lgg([c[i] for c in cols], store) for i in range(1, len(c0)))
    k = tuple(cols)
    if k not in store: store[k] = ('?%d' % len(store),)
    return store[k]
def same_upto_renaming(s, t, m=None):
    m = {} if m is None else m
    if s[0].startswith('?') or t[0].startswith('?'):
        if not (s[0].startswith('?') and t[0].startswith('?')): return False
        if s[0] in m: return m[s[0]] == t[0]
        if t[0] in m.values(): return False
        m[s[0]] = t[0]; return True
    return s[0] == t[0] and len(s) == len(t) and all(same_upto_renaming(a, b, m) for a, b in zip(s[1:], t[1:]))
TARGET = ('st', ('Sub', ('?P',), ('x',), ('0',), ('?A',)), ('Sub', ('?P',), ('x',), ('S', ('x',)), ('?B',)),
          ('imp', ('and', ('?A',), ('all', ('x',), ('imp', ('?P',), ('?B',)))), ('all', ('x',), ('?P',))))
P = pool(seed=11, n=30)
for k in (2, 3):
    agree = tot = rec = 0
    for combo in itertools.combinations(list(P), k):
        if k == 3 and tot >= 6000: break
        ms = [P[c] for c in combo]
        L = lgg([step(m) for m in ms], {})
        r = same_upto_renaming(L, TARGET)
        agree += (r == (pR(ms) and pN(ms))); tot += 1; rec += r
    print('(a) %d-subsets: %d, Sub-lgg recovers: %d, agrees with (R)&(N): %d/%d' % (k, tot, rec, agree, tot))

# (b) C8.1
x = V(0)
s1 = AND(ALL(EQ(x, Z())), AND(ALL(EQ(x, x)), EQ(Z(), Z())))
s2 = AND(ALL(NOT(EQ(x, Z()))), AND(ALL(NOT(EQ(x, x))), NOT(EQ(Z(), Z()))))
Ts = [T for T in enum_covering([s1, s2], 14, amax=3, ar_F=(0, 1, 2), ar_T=(0, 1)) if is_DT(T)]
mins = [T for T in Ts if not any(geq(T, U) and not geq(U, T) for U in Ts)]
G1 = AND(ALL(MV('P', x)), AND(ALL(MV('Q', x)), MV('P', Z())))
G2 = AND(ALL(MV('P', x)), AND(ALL(MV('Q', x)), MV('Q', Z())))
print('(b) DT covering templates: %d; minimal: %s; all >= G1 or G2: %s' %
      (len(Ts), [pp(T) for T in mins], all(geq(T, G1) or geq(T, G2) for T in Ts)))
w1 = AND(ALL(EQ(x, Z())), AND(ALL(EQ(x, S(Z()))), EQ(Z(), Z())))
w2 = AND(ALL(EQ(x, S(Z()))), AND(ALL(EQ(x, Z())), EQ(Z(), Z())))
print('    w1 in G1,G2: %s %s ; w2 in G1,G2: %s %s' % (covers(G1, w1), covers(G2, w1), covers(G1, w2), covers(G2, w2)))

# (c) C10 with e = 1: clean data e-robustly diverse, plus the false non-instance s*
sstar = IMP(AND(EQ(Z(), Z()), ALL(IMP(EQ(x, x), EQ(S(x), S(x))))), ALL(EQ(x, Z())))
clean = [Ind(EQ(X, X)), Ind(NOT(EQ(X, Z()))), Ind(OR(EQ(X, Z()), NOT(EQ(X, Z())))), Ind(ALL(EQ(MUL(X, V(0)), MUL(V(0), X))))]
D = clean + [sstar]
allgood = True; n = 0
for drop in range(len(D)):
    Dp = D[:drop] + D[drop + 1:]
    for T in enum_covering(Dp, 14, amax=2, ar_F=(0, 1), ar_T=(0, 1)):
        if is_DT(T):
            n += 1
            # must contain Ind (>= T_ind), since the clean part of Dp still has (R),(N)
            allgood &= geq(T, T_IND)
print('(c) trimmed (e=1) DT version space, %d templates (size<=14): all >= T_ind: %s; T_ind misses only s*: %s'
      % (n, allgood, [covers(T_IND, d) for d in D]))
