# u6: (A) learning forall x phi from instances = sound cross merges of ground "targets";
#     (B) refutation blocks generalization from instances of a false universal;
#     (C) non-transitivity of pairwise coherence; whole-cluster tests vs single linkage.
import sys, random, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC
from practice import QS, rand_closed

W = World('arith', B=3, budget=1500)
print('== (A) numeral instances of three universal axioms, each instance treated as a separate ground target ==')
rng = random.Random(3)
data = []
for k in ['Q3s', 'Q5s', 'Q4s']:
    for n in range(4):
        th = {'tx': num(n), 'ty': num((n * 2) % 3)}
        data.append((k, instantiate(QS[k], th)))
rng.shuffle(data)
A = DTRC(W)
A.run([s for _, s in data])
lab = {s: k for k, s in data}
for C, Ts in zip(A.clusters, A.templates):
    print('  cluster', sorted(set(lab[s] for s in C)), 'size', len(C), '->', [pp(T) for T in Ts])
for q in [eq(add(P('a1'), Z), P('a1')), eq(mul(P('a1'), Z), Z), eq(add(num(7), Z), num(7)), eq(add(P('a1'), S(P('a2'))), S(add(P('a1'), P('a2'))))]:
    print('  accepts %-28s %s' % (pp(q), A.accepts(q)))
print('  (a1 is a parameter: closure-normal form, so a1+0=a1 is the universal axiom forall x (x+0=x))')

print()
print('== (B) instances of a false universal: 0*0=0, S0*S0=S0 (n*n=n holds for n=0,1) ==')
D = [eq(mul(Z, Z), Z), eq(mul(S(Z), S(Z)), S(Z))]
for T in mincov(D):
    print('  minimal template', pp(T), ' refutation:', W.refute_template(T))
A = DTRC(W); A.run(D)
print('  DTRC clusters:', [len(C) for C in A.clusters], '  accepts 2*2=2?', A.accepts(eq(mul(num(2), num(2)), num(2))))
print('== (B2) instances of a true universal: 0*0=0*0... e.g. not(n*n = 2): ==')
D = [NOT(eq(mul(num(n), num(n)), num(2))) for n in range(3)]
for T in mincov(D):
    print('  minimal template', pp(T), ' refutation:', W.refute_template(T))
A = DTRC(W); A.run(D)
print('  DTRC clusters:', [len(C) for C in A.clusters], '  accepts the universal not(a1*a1=2)?', A.accepts(NOT(eq(mul(P('a1'), P('a1')), num(2)))))

print()
print('== (C) non-transitivity: a = 0+0=0, b = S0+0=S0, c = 0+S0=S0 ==')
a, b, c = eq(add(Z, Z), Z), eq(add(S(Z), Z), S(Z)), eq(add(Z, S(Z)), S(Z))
Wc = World('arith', B=3)
Ac = DTRC(Wc)
for X, nm in [([a, b], 'ab'), ([a, c], 'ac'), ([b, c], 'bc'), ([a, b, c], 'abc')]:
    T = Ac.coherent(X)
    print('  %-3s coherent: %-5s  minimal templates: %s' % (nm, T is not None, [pp(U) + (' [refuted: %s]' % pp(Wc.refute_template(U)[0]) if Wc.refute_template(U) else ' [unrefuted]') for U in mincov(X)]))
for order in ([a, b, c], [a, c, b], [b, c, a], [c, b, a]):
    A = DTRC(Wc); A.run(order)
    print('  DTRC order', [pp(x) for x in order], '->', [sorted(pp(x) for x in C) for C in A.clusters])
print('  single linkage on the pairwise graph merges {a,b,c} into one cluster, whose minimal templates are all refuted.')
