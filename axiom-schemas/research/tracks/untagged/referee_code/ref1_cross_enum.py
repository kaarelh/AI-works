# Referee check 1: separation of PA and ZF cross pairs verified WITHOUT mincov.
# For each cross pair, enumerate (independently) all DT° covering templates up to a size bound and check that
# each one is refuted by the author's (sound) refuters; also check that each lies above some mincov template.
import sys, random, itertools, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code'); sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code')
from dtlib import *
from dtrc import World
from practice import *
from ref_enum import enum_cover

SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 12
def check(name, x, y, W, lang):
    t0 = time.time()
    cov = enum_cover([x, y], SMAX, lang)
    mins = mincov([x, y])
    unref = []
    notabove = []
    for T in cov:
        if not (covers(T, x) and covers(T, y)):
            print('   !! enumerated template does not cover per dtlib:', pp(T)); continue
        if W.refute_template(T) is None: unref.append(T)
        if not any(subsumes(T, m) for m in mins): notabove.append(T)
    print('%-14s enumerated covering (size<=%d): %4d   unrefuted: %d   not above a mincov template: %d   (%.1fs)'
          % (name, SMAX, len(cov), len(unref), len(notabove), time.time() - t0))
    for T in unref[:4]: print('      UNREFUTED:', pp(T))
    for T in notabove[:4]: print('      NOT ABOVE MINCOV:', pp(T))
    return len(unref), len(notabove)

print('== PA: Q1..Q7 + 4 induction samples ==')
W = World('arith', B=3)
ind_samples = [canon_params(Ind(m)) for m in [eq(add(X, Z), X), NOT(eq(S(X), Z)), IMP(eq(X, Z), eq(add(X, X), X)),
                                               ALL(eq(add(V(0), X), add(X, V(0))))]]
tot = [0, 0]
names = sorted(Q)
for a, b in itertools.combinations(names, 2):
    r = check(a + '-' + b, Q[a], Q[b], W, 'arith'); tot[0] += r[0]; tot[1] += r[1]
for a in names:
    for j, s in enumerate(ind_samples):
        r = check(a + '-Ind%d' % j, Q[a], s, W, 'arith'); tot[0] += r[0]; tot[1] += r[1]
print('PA totals: unrefuted covering templates', tot[0], ' not above mincov', tot[1])

print('== ZF: 6 axioms + 3 schemas (2 samples per schema) ==')
rng = random.Random(5)
samples = {k: [ZF[k]] for k in ZF}
for k in ZF_SCHEMAS:
    samples[k] = [schema_instance(k, rng) for _ in range(2)]
Wz = World('set', hf=3, budget=600)
tot = [0, 0]
for a, b in itertools.combinations(list(samples), 2):
    for i, x in enumerate(samples[a]):
        for j, y in enumerate(samples[b]):
            r = check('%s%d-%s%d' % (a, i, b, j), x, y, Wz, 'set'); tot[0] += r[0]; tot[1] += r[1]
print('ZF totals: unrefuted covering templates', tot[0], ' not above mincov', tot[1])
print('== weak forms ==')
check('UnionW-PowerW', ZFW['UnionW'], ZFW['PowerW'], Wz, 'set')
