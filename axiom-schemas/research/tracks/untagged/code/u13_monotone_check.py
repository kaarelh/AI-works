# u13: effect of the v2 global negative cache (referee U5 / section 3.5).  The referee's independent enumerator
# (../referee_code/ref_enum.py, not written by the author) lists ALL covering DT deg templates of size <= 14 of ZF cross
# pairs (2 samples per schema) and of UnionW-PowerW.  With the v1 template-specific search, 120 ZF cross templates were
# reported unrefuted although each lies above refuted naive comprehension (contains Russell's instance).  With the v2
# world (global negative set), each enumerated template is tested after the minimal ones, so refutation is monotone.
import sys, random, itertools, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
sys.path.insert(1, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code')
from dtlib import *
from dtrc import World
from practice import *
from ref_enum import enum_cover

SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 14
rng = random.Random(5)
samples = {k: [ZF[k]] for k in ZF}
for k in ZF_SCHEMAS:
    samples[k] = [schema_instance(k, rng) for _ in range(2)]
Wz = World('set', hf=3, budget=600)
tot_cov = tot_unref = tot_notabove = 0
t0 = time.time()
for a, b in itertools.combinations(list(samples), 2):
    for x in samples[a]:
        for y in samples[b]:
            mins = mincov([x, y])
            for T in mins: Wz.refute_template(T)          # minimal templates first (as DTRC does)
            for T in enum_cover([x, y], SMAX, 'set'):
                tot_cov += 1
                if Wz.refute_template(T) is None: tot_unref += 1
                if not any(subsumes(T, m) for m in mins): tot_notabove += 1
print('ZF cross pairs (size <= %d): enumerated covering templates %d; unrefuted (v2 world) %d; not above mincov %d; '
      '|N| = %d; %.0fs' % (SMAX, tot_cov, tot_unref, tot_notabove, len(Wz.neg), time.time() - t0))
x, y = ZFW['UnionW'], ZFW['PowerW']
cov = enum_cover([x, y], SMAX, 'set')
unref = [T for T in cov if Wz.refute_template(T) is None]
U = mincov([x, y])
print('UnionW-PowerW: enumerated %d, unrefuted %d, all unrefuted above the universal-set schema %s: %s'
      % (len(cov), len(unref), [pp(T) for T in U], all(any(subsumes(T, m) for m in U) for T in unref)))
