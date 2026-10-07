# Referee check of the hand examples: Prop D.4, D.5, Example D.6, Prop G.2, Prop F.3, Thm D on Ind/ZF.
import time
from rc_core import *
from rc_enum import *
from rc_anchor import *
z0, z1 = ('z', 0), ('z', 1)
x, y = V(1), V(0)   # under Ax Ay: x = #1, y = #0

def report(name, Tstar, bodies, kmax=5, amax=2):
    D = [inst(Tstar, th) for th in bodies]
    print(name, '  T* =', pp(Tstar))
    for d in D: print('     datum', pp(d))
    ev, wit = events(Tstar, D)
    print('   events', ev, ' U-witnesses', [(w[0], w[1]) for w in wit])
    ft, q = feat_truth(Tstar, D)
    print('   feature-anchor:', ft, ' violating instance:', pp(q) if q else None)
    t0 = time.time()
    Ts = enumerate_covering(D, kmax=kmax, amax=amax)
    mins = minimal_elements(Ts)
    print('   brute force (kmax=%d amax=%d): %d covering templates, minimal:' % (kmax, amax, len(Ts)), [pp(T) for T in mins], '%.1fs' % (time.time()-t0))
    if q is not None:
        miss = [pp(T) for T in mins if match(T, q) is None]
        print('   minimal templates missing the violating instance:', miss)
    return D

# Prop D.4
T4 = AND(ALL(ALL(EQ(S(M('f', x, y)), Z))), ALL(ALL(EQ(M('f', x, S(y)), Z))))
report('Prop D.4', T4, [{'f': z0}, {'f': z1}, {'f': S(z0)}])
# Prop D.5
T5 = ALL(EQ(Z, M('f', V(0))))
report('Prop D.5', T5, [{'f': Z}, {'f': z0}])
# Example D.6
T6 = AND(ALL(ALL(EQ(M('f', x, y), Z))), ALL(EQ(V(0), Z)))
report('Ex D.6', T6, [{'f': z0}, {'f': z1}])

# Prop G.2: D_n
def Cn(n):
    f = EQ(Z, Z)
    for _ in range(n - 1): f = AND(f, EQ(Z, Z))
    return f
for n in [1, 2]:
    D = [AND(ALL(EQ(V(0), V(0))), Cn(n)), AND(ALL(EQ(Z, Z)), Cn(n))]
    t0 = time.time()
    Ts = enumerate_covering(D, kmax=2 + 2 * n + 1, amax=1)
    mins = minimal_elements(Ts)
    info = DataInfo(D)
    print('Prop G.2 n=%d: |D| total size %d, %d covering templates, |Min| = %d (claim 4^n = %d), %.1fs' % (n, sum(size(d) for d in D), len(Ts), len(mins), 4**n, time.time()-t0))
    # Acc(D_n) = D_n: test some candidates
    cands = [AND(ALL(EQ(t, t)), Cn(n)) for t in [V(0), Z, S(V(0)), S(Z), ADD(V(0), Z), ('a',)]]
    print('    feature verifier accepts:', [pp(c) for c in cands if info.has_features(c)])
    print('    brute-force intersection accepts:', [pp(c) for c in cands if all(match(T, c) is not None for T in Ts)])

# Prop F.3 infinite thickness
s = AND(ALL(EQ(Z, Z)), EQ(Z, Z))
for t in [Z, S(Z), ('a',), ADD(Z, Z)]:
    T = AND(ALL(M('P', V(0))), M('P', t))
    w = inst(T, {'P': EQ(z0, z0)})
    print('F.3: t=%s  s in inst: %s ; witness %s in inst(T_t) only: %s' % (pp(t), match(T, s) is not None, pp(w),
          [match(AND(ALL(M('P', V(0))), M('P', t2)), w) is not None for t2 in [Z, S(Z), ('a',), ADD(Z, Z)]]))
