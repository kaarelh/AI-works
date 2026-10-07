# u1: PA cross merges.  For every pair of distinct targets of the practice
#   (a) Q1..Q7 (ground, closure-normal form) + raw induction,
#   (b) the instance schemas Q1s..Q7s of Q's axioms observed through closed-term instances,
# compute the minimal covering DT deg templates of cross pairs of data and search each for a refuted instance
# (Delta_0 evaluation with forall-E; EUF+Diag(N) verification of universals; pure logic).
import sys, random, itertools, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World
from practice import *

rng = random.Random(1)
W = World('arith', B=3)
ind_samples = [canon_params(Ind(m)) for m in [eq(add(X, Z), X), NOT(eq(S(X), Z)), IMP(eq(X, Z), eq(add(X, X), X)),
                                               ALL(eq(add(V(0), X), add(X, V(0))))]]
print('== (a) Q1..Q7 + Ind: minimal covering templates of cross pairs and refutations ==')
names = sorted(Q) + ['Ind']
allref = True
for a, b in itertools.combinations(names, 2):
    if b == 'Ind':
        pairs = [(Q[a], s) for s in ind_samples]
    else:
        pairs = [(Q[a], Q[b])]
    for (x, y) in pairs:
        Ts = mincov([x, y])
        for T in Ts:
            r = W.refute_template(T)
            ok = r is not None
            allref &= ok
            if b != 'Ind' or y is ind_samples[0]:
                print('%-3s %-4s  %-55s  %s' % (a, b, pp(T)[:55], ('REFUTED by ' + pp(r[0])[:48] + '  [' + r[1][:24] + ']') if ok else 'NOT refuted'))
print('every minimal covering template of every tested cross pair refuted:', allref)

print()
print('== (a2) absorption: does every min covering template of {Qi, Ind(phi)} contain T_ind? ==')
for a in sorted(Q):
    res = []
    for s in ind_samples:
        res.append(all(subsumes(T, T_IND) for T in mincov([Q[a], s])))
    print(a, all(res))

print()
print('== (b) instance schemas Q1s..Q7s (closed-term instances): cross pairs ==')
inst = {k: [qs_instance(k, rng) for _ in range(4)] for k in QS}
allref = True
worst = []
for a, b in itertools.combinations(sorted(QS), 2):
    stat = []
    for x in inst[a][:2]:
        for y in inst[b][:2]:
            for T in mincov([x, y]):
                r = W.refute_template(T)
                stat.append(r is not None)
                if r is None: worst.append((a, b, pp(x), pp(y), pp(T)))
    allref &= all(stat)
    print('%-4s %-4s  pairs tested=%d templates refuted=%d/%d' % (a, b, 4, sum(stat), len(stat)))
print('all refuted:', allref)
for w in worst[:10]: print('  UNREFUTED', w)

print()
print('== (b2) within-target merges of instance-schema data: minimal templates and whether they are below the schema ==')
for k in sorted(QS):
    Ts = mincov(inst[k])
    print(k, [pp(T) for T in Ts][:3], ' some <= target:', any(subsumes(QS[k], T) for T in Ts),
          ' all >= target:', all(subsumes(T, QS[k]) for T in Ts), ' refuted:', [W.refute_template(T) is not None for T in Ts])
