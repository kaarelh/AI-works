# Referee check 3: (a) does any asserted template (unrefuted minimal template of a final cluster) cover a sentence
# that the same run's oracle refuted while testing some other template?  (template-specific budgeted search makes
# the implemented refutation non-monotone in <=).  (b) are asserted templates refuted at a 10x larger budget?
# (c) truth check of accepted held-out sentences for PA (quantifier-free fragment evaluated directly).
import sys, random
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun')
from dtlib import *
from dtrc import World, DTRC
from practice import *

def audit(A, W, Wbig, label):
    refuted = [v[0] for v in W.cache.values() if v is not None]
    hits = 0
    for C, Ts in zip(A.clusters, A.templates):
        for T in Ts:
            cov = [r for r in refuted if covers(T, r)]
            if cov:
                hits += 1
                print('   [%s] asserted template %s covers refuted %s' % (label, pp(T)[:70], pp(cov[0])[:60]))
    big = 0
    for C, Ts in zip(A.clusters, A.templates):
        for T in Ts:
            r = Wbig.refute_template(T)
            if r is not None:
                big += 1
                print('   [%s] asserted template %s refuted at large budget by %s [%s]' % (label, pp(T)[:70], pp(r[0])[:60], r[1][:20]))
    print('%s: refuted sentences found=%d; asserted templates covering one=%d; refuted at large budget=%d'
          % (label, len(refuted), hits, big))

for seed in (1, 2, 3):
    rng = random.Random(seed)
    data = pa_data(40, rng); rng.shuffle(data)
    W = World('arith', B=3, budget=1500, seed=seed)
    A = DTRC(W); A.run([s for _, s in data])
    Wb = World('arith', B=4, budget=15000, seed=seed + 100); Wb.logic_budget = 600
    audit(A, W, Wb, 'PA seed %d' % seed)
for seed in (1, 2, 3):
    rng = random.Random(seed)
    data = zf_data(45, rng); rng.shuffle(data)
    W = World('set', hf=3, budget=500, seed=seed)
    A = DTRC(W); A.run([s for _, s in data])
    Wb = World('set', hf=3, budget=3000, seed=seed + 100); Wb.logic_budget = 200
    audit(A, W, Wb, 'ZF seed %d' % seed)
# u8 main run
M1 = [eq(add(a1, Z), S(a1)), eq(mul(a1, Z), a1),
      IMP(AND(eq(Z, Z), ALL(IMP(eq(S(V(0)), V(0)), eq(S(S(V(0))), S(V(0)))))), ALL(eq(S(V(0)), V(0))))]
J0star = IMP(AND(eq(add(Z, Z), Z), ALL(IMP(eq(add(Z, V(0)), Z), eq(add(Z, S(V(0))), S(Z))))), ALL(eq(add(Z, V(0)), Z)))
indS_neg = IMP(AND(NOT(eq(S(Z), Z)), ALL(IMP(NOT(eq(V(0), Z)), NOT(eq(S(V(0)), Z))))), ALL(NOT(eq(V(0), Z))))
M3 = [eq(add(Z, a1), a1), NOT(eq(S(a1), a1))]
rng = random.Random(11)
clean = pa_data(60, rng)
data = clean + [('M1', m) for m in M1] + [('M2', m) for m in [J0star, indS_neg]] + [('M3', m) for m in M3]
rng.shuffle(data)
W = World('arith', B=3, budget=1500)
A = DTRC(W); A.run([s for _, s in data])
Wb = World('arith', B=4, budget=15000, seed=7); Wb.logic_budget = 600
audit(A, W, Wb, 'u8 noisy PA')
