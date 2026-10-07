# Referee check 2: mincov completeness on within-target sets used by the verifier (ZF schemas, K0 pair,
# J*_0 absorption cluster), against the independent enumerator ref_enum.enum_cover.
import sys, random, time
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun')
from dtlib import *
from practice import *
from ref_enum import enum_cover

def check(name, D, smax, lang):
    t0 = time.time()
    cov = enum_cover(D, smax, lang)
    mins = mincov(D)
    bad = [T for T in cov if not all(covers(T, d) for d in D)]
    na = [T for T in cov if not any(subsumes(T, m) for m in mins)]
    print('%-22s |D|=%d  enumerated (size<=%d): %5d  mincov=%d  not-covering(dtlib)=%d  NOT ABOVE MINCOV=%d  (%.1fs)'
          % (name, len(D), smax, len(cov), len(mins), len(bad), len(na), time.time() - t0), flush=True)
    for m in mins[:3]: print('     mincov:', pp(m)[:120])
    for T in na[:5]: print('     NOT ABOVE:', pp(T)[:120])

SM = int(sys.argv[1]) if len(sys.argv) > 1 else 16
rng = random.Random(5)
for k in ('Sep', 'EInd', 'Rep'):
    for trial in range(3):
        xs = [schema_instance(k, rng) for _ in range(2)]
        check('%s pair #%d' % (k, trial), xs, SM if k != 'Rep' else SM + 14, 'set')
mot = lambda n: eq(add(num(n), X), (lambda t: [t := S(t) for _ in range(n)] and t or t)(X))
def motive_n(n):
    t = X
    for _ in range(n): t = S(t)
    return eq(add(num(n), X), t)
K0pair = [canon_params(Ind(motive_n(0))), canon_params(Ind(motive_n(1)))]
check('K0 pair', K0pair, 26, 'arith')
J0star = IMP(AND(eq(add(Z, Z), Z), ALL(IMP(eq(add(Z, V(0)), Z), eq(add(Z, S(V(0))), S(Z))))), ALL(eq(add(Z, V(0)), Z)))
check('J*0 + Ind(n<3)', [canon_params(Ind(motive_n(n))) for n in range(3)] + [J0star], 26, 'arith')
check('Ind(0+x=x) + J*0', [canon_params(Ind(motive_n(0))), J0star], 26, 'arith')
