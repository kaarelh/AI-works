# u10: ZFC = ZF + the Axiom of Choice (referee 'missing' item 4).  AC is a single ground axiom in closure-normal form:
#   AC(a): [forall y (y in a -> exists z z in y)  &  forall y forall w ((y in a & w in a & not y=w) -> not exists z (z in y & z in w))]
#          -> exists c forall y (y in a -> exists z (z in y & z in c & forall u ((u in y & u in c) -> u = z)))
# (a) cross merges of AC with each of the 9 ZF targets (2 samples per schema): minimal covering templates and refutation;
# (b) DTRC end to end on unlabelled ZFC data (10 targets), 3 seeds, held-out schema instances.
import sys, random, itertools, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC, separation_check
from practice import *

ante1 = ALL(IMP(mem(V(0), a1), EX(mem(V(0), V(1)))))
ante2 = ALL(ALL(IMP(AND(AND(mem(V(1), a1), mem(V(0), a1)), NOT(eq(V(1), V(0)))),
                    NOT(EX(AND(mem(V(0), V(2)), mem(V(0), V(1))))))))
cons = EX(ALL(IMP(mem(V(0), a1),
                  EX(AND(AND(mem(V(0), V(1)), mem(V(0), V(2))),
                         ALL(IMP(AND(mem(V(0), V(2)), mem(V(0), V(3))), eq(V(0), V(1)))))))))
AC = canon_params(IMP(AND(ante1, ante2), cons))
print('AC =', pp(AC))
W0 = World('set', hf=3, budget=600)
print('AC refuted by the oracle (must not be, AC is true in V):', W0.refute_sentence(AC))

print()
print('== (a) cross merges AC - ZF targets ==')
rng = random.Random(5)
samples = {k: [ZF[k]] for k in ZF}
for k in ZF_SCHEMAS:
    samples[k] = [schema_instance(k, rng) for _ in range(2)]
W = World('set', hf=3, budget=600)
allref = True
for k, xs in samples.items():
    for j, x in enumerate(xs):
        Ts = mincov([AC, x])
        for T in Ts:
            r = W.refute_template(T)
            allref &= r is not None
            print('AC-%-6s #min=%d  %-48s %s' % (k + str(j), len(Ts), pp(T)[:48],
                  ('REFUTED: ' + pp(r[0])[:44] + ' [' + r[1].split(' ')[0] + ']') if r else 'NOT REFUTED'))
print('all AC cross templates refuted:', allref)

print()
print('== (b) DTRC on unlabelled ZFC data ==')
ZFC = dict(ZF); ZFC['AC'] = AC
for seed in (1, 2, 3):
    rng = random.Random(seed)
    data = zf_data(50, rng, single=ZFC)
    rng.shuffle(data)
    lab = {}
    for k, s in data: lab.setdefault(s, set()).add(k)
    W = World('set', hf=3, budget=500, seed=seed)
    A = DTRC(W)
    t0 = time.time()
    A.run([s for _, s in data])
    pure = all(len(set().union(*[lab[s] for s in C])) == 1 for C in A.clusters)
    tags = sorted(','.join(sorted(set().union(*[lab[s] for s in C]))) for C in A.clusters)
    exact = []
    for C, Ts in zip(A.clusters, A.templates):
        labs = set().union(*[lab[s] for s in C])
        if len(labs) == 1 and list(labs)[0] in ZF_SCHEMAS:
            Tk = ZF_SCHEMAS[list(labs)[0]]
            exact.append((list(labs)[0], len(C), all(subsumes(T, Tk) for T in Ts) and len(Ts) > 0))
    npairs, ntpl, unref = separation_check(W, lab)
    print('seed %d: n=%d distinct=%d clusters=%d pure=%s passes=%d |N|=%d tests=%d time=%.0fs' %
          (seed, len(data), len(lab), len(A.clusters), pure, A.rounds, len(W.neg), A.tests, time.time() - t0))
    print('   clusters:', tags)
    print('   schema clusters (name, size, exact):', exact)
    print('   RS on D: %d cross pairs, %d minimal templates, unrefuted %d; re-audit inconsistent: %d' %
          (npairs, ntpl, len(unref), len(A.audit())))
    print('   accepts AC:', A.accepts(AC))
rng = random.Random(77)
held = {k: [schema_instance(k, rng) for _ in range(60)] for k in ZF_SCHEMAS}
for k, xs in held.items():
    print('held-out %s instances accepted (last learner): %d/%d' % (k, sum(A.accepts(s) for s in xs), len(xs)))
