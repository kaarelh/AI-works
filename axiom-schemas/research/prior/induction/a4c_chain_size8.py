# A4b: longest genuine-only escalation chain from ind(x+0=x) in larger motive universes (lower bounds on the
# worst case for an honest prover restricted to genuine instances; upper bound is the tuple gap 17).
import sys
sys.argv=['x']
exec(open('a4_cost.py').read().split('# --- genuine-only prover')[0].split("print('mu(sigma_x)")[0])
from common import *
import random, time
def tup(phi, v=x): return ('tri', phi, subst(phi, v, Z), subst(phi, v, S(v)))
phi0 = eq(add(x, Z), x)
src = open('a4_cost.py').read()
exec(src[src.index('def longest_chain'):src.index('for maxsz, conns')])
for maxsz, vars_ in ((8, ("x",)), (8, ("x", "y"))):
    t = time.time()
    Uc = [p for p in motives_upto(maxsz, vars_, conns=('not', 'and', 'imp'), quants=('all',)) if p != phi0]
    try:
        l, seq, nst = longest_chain(phi0, Uc, limit_states=200000)
        print(f'universe size<= {maxsz}, vars {vars_}: {len(Uc)} motives; longest genuine chain = {l} ({nst} states, {time.time()-t:.0f}s)')
        print('   witness:', [show(p) for p in seq])
    except RuntimeError as e:
        print(f'universe size<= {maxsz}, vars {vars_}: {len(Uc)} motives: aborted ({e})')
