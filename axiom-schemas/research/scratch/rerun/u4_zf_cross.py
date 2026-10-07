# u4: ZF cross merges.  Targets: Ext, Pair, Union, Power, Inf, Found (single axioms, closure-normal form),
# Sep, Rep, EInd (schemas).  For each pair of targets, minimal covering DT deg templates of cross pairs of data and
# the first refuted instance found, with the method: HF counterexample (Delta_0 absoluteness), pure logic
# (Herbrand/DPLL), or coherence with designated true sentences.
import sys, random, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World
from practice import *

rng = random.Random(5)
samples = {k: [ZF[k]] for k in ZF}
for k in ZF_SCHEMAS:
    samples[k] = [schema_instance(k, rng) for _ in range(2)]
W = World('set', hf=3, budget=600)
names = list(ZF) + list(ZF_SCHEMAS)
summary = {}
for a, b in itertools.combinations(names, 2):
    res = []
    for x in samples[a][:1]:
        for y in samples[b][:1]:
            for T in mincov([x, y]):
                r = W.refute_template(T)
                res.append((T, r))
    meth = sorted(set((r[1].split(' ')[0] if r else 'NONE') for _, r in res))
    summary[(a, b)] = meth
    T, r = res[0]
    print('%-5s %-5s #min=%d  %-50s  %s' % (a, b, len(res), pp(T)[:50],
          ('REFUTED: ' + pp(r[0])[:45] + ' [' + r[1].split(' ')[0] + ']') if r else 'NOT REFUTED'))
print()
print('pairs with an unrefuted minimal template:', [k for k, m in summary.items() if 'NONE' in m])

print()
print('== within-target pairs of schema instances: minimal templates below the schema, refuted? ==')
for k, Tk in ZF_SCHEMAS.items():
    xs = [schema_instance(k, rng) for _ in range(3)]
    Ts = mincov(xs)
    print(k, '#min=%d' % len(Ts), ' some <= schema:', any(subsumes(Tk, T) for T in Ts),
          ' all >= schema (anchor):', all(subsumes(T, Tk) for T in Ts),
          ' unrefuted <=schema:', [W.refute_template(T) is None for T in Ts if subsumes(Tk, T)])

print()
print('== comprehension-shaped axioms: Union and Power (iff forms) -> naive comprehension ==')
for T in mincov([ZF['Union'], ZF['Power']]):
    print('  ', pp(T), '  ->', W.refute_template(T))
print('== weak (bounding) forms: UnionW, PowerW ==')
Ws = World('set', hf=3, budget=600)
for T in mincov([ZFW['UnionW'], ZFW['PowerW']]):
    print('  ', pp(T))
    print('     logic + HF only:', Ws.refute_template(T))
    sepR = ALL(EX(ALL(IFF(mem(V(0), V(1)), AND(mem(V(0), V(2)), NOT(mem(V(0), V(0))))))))   # closure of a Sep instance
    Wd = World('set', hf=3, budget=600, designated=[sepR])
    print('     + designated Separation instance (Russell set of a):', Wd.refute_template(T))
    Wf = World('set', hf=3, budget=600, designated=[ALL(NOT(mem(V(0), V(0))))])
    print('     + designated Pi_1 truth  forall x not x in x:', Wf.refute_template(T))
