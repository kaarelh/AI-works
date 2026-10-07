# u5: end-to-end DTRC on unlabelled ZF data (closure-normal form, de Bruijn), set-theory world =
# HF counterexamples (Delta_0 absoluteness) + pure logic (+ designated true sentences).
# Part A: standard forms (Union/Power with <->): separation holds; clusters = targets; schemas anchored.
# Part B: weak (bounding) forms of Union and Power: their merge (the universal-set schema) is unrefutable by
#         logic + HF, so DTRC makes a residual unsound merge; designating one instance accepted by the learned
#         Separation cluster (Russell's instance) restores separation (bootstrapped coherence).
import sys, random, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC
from practice import *

def report(A, data, targets):
    lab = {}
    for k, s in data: lab.setdefault(s, set()).add(k)
    pure = True
    for C, Ts in zip(A.clusters, A.templates):
        labs = set().union(*[lab[s] for s in C])
        pure &= len(labs) == 1
        tag = ','.join(sorted(labs))
        line = '   cluster %-14s size=%3d  #unrefuted min templates=%d' % (tag, len(C), len(Ts))
        if len(labs) == 1 and tag in targets and Ts:
            line += '  exact(all >= target)=%s  sound(some <= target)=%s' % (
                all(subsumes(T, targets[tag]) for T in Ts), any(subsumes(targets[tag], T) for T in Ts))
        print(line)
        if len(labs) > 1 or tag not in ZF_SCHEMAS:
            for T in Ts[:1]: print('        ', pp(T)[:110])
    return pure

print('== Part A: standard ZF forms ==')
for seed in (1, 2, 3):
    rng = random.Random(seed)
    data = zf_data(45, rng)
    rng.shuffle(data)
    W = World('set', hf=3, budget=500, seed=seed)
    A = DTRC(W)
    t0 = time.time()
    A.run([s for _, s in data])
    print('seed %d: n=%d clusters=%d coherence tests=%d refutation searches=%d time=%.1fs'
          % (seed, len(data), len(A.clusters), A.tests, W.calls, time.time() - t0))
    pure = report(A, data, ZF_SCHEMAS)
    print('   all clusters pure:', pure)
rng = random.Random(77)
held = {k: [schema_instance(k, rng) for _ in range(60)] for k in ZF_SCHEMAS}
for k, xs in held.items():
    print('held-out %s instances accepted: %d/%d' % (k, sum(A.accepts(s) for s in xs), len(xs)))
# near misses: Separation without the guard (naive comprehension instances), Replacement without uniqueness clause
naive = [canon_params(EX(ALL(IFF(mem(V(0), V(1)), plug(rand_set_formula(rng, 1), [V(0)]))))) for _ in range(30)]
print('naive-comprehension instances accepted: %d/%d' % (sum(A.accepts(s) for s in naive), len(naive)))

print()
print('== Part B: weak forms of Union and Power ==')
single = dict(ZF); del single['Union']; del single['Power']; single.update(ZFW)
rng = random.Random(4)
data = zf_data(45, rng, single=single)
rng.shuffle(data)
W = World('set', hf=3, budget=500, seed=4)
A = DTRC(W)
A.run([s for _, s in data])
print('logic + HF only: clusters=%d' % len(A.clusters))
report(A, data, ZF_SCHEMAS)
univ = EX(ALL(IMP(eq(P('a1'), P('a1')), mem(V(0), V(1)))))
print('accepts the universal-set sentence  ∃x∀y(a1=a1 → y∈x):', A.accepts(canon_params(univ)))
# bootstrapped coherence: designate the closure of the Russell instance of the learned Separation cluster
russell_sep = canon_params(instantiate(SEP, {'Fphi': NOT(mem(H(0), H(0)))}))
print('Russell instance of Separation accepted by the learned clusters:', A.accepts(russell_sep))
def closure(s):
    ps = params(s)
    t = s
    for i, p in enumerate(reversed(ps)):
        # abstract parameter p as a new outermost binder
        def R(u, j):
            if u == ('p', p): return ('v', j)
            if u[0] == 'v': return u if u[1] < j else ('v', u[1] + 1)
            if u[0] in BINDERS: return (u[0], R(u[1], j + 1))
            ks = kids(u)
            return u if not ks else rebuild(u, [R(k, j) for k in ks])
        t = ALL(R(t, 0))
    return t
W2 = World('set', hf=3, budget=500, seed=4, designated=[closure(russell_sep)])
A2 = DTRC(W2)
A2.run([s for _, s in data])
print('with the designated (learned) Russell instance of Separation: clusters=%d' % len(A2.clusters))
report(A2, data, ZF_SCHEMAS)
print('accepts the universal-set sentence:', A2.accepts(canon_params(univ)))
