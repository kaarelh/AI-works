# A4d: longest genuine-only escalation chain from one example, for several starting motives
# (universe: motives of size <= 7 over x,y with not/and/imp/all), compared with 3m+k (tuple bound) and 2m.
from common import *
import time
def tup(phi, v=x): return ('tri', phi, subst(phi, v, Z), subst(phi, v, S(v)))
src = open('a4_cost.py').read()
exec(src[src.index('def longest_chain'):src.index('for maxsz, conns')])
def nfree(f, v='x', bound=False):
    if is_objvar(f): return int(f[0] == v and not bound)
    if len(f) == 1: return 0
    if f[0] in QUANT: return nfree(f[2], v, bound or f[1][0] == v)
    return sum(nfree(a, v, bound) for a in f[1:])
Ubig = motives_upto(7, ('x', 'y'), conns=('not', 'and', 'imp'), quants=('all',))
starts = [eq(x, Z), eq(Z, Z), eq(x, x), lt(x, S(x)), eq(S(x), x), eq(add(x, Z), x), NOT(eq(S(x), Z)), eq(add(x, y), add(y, x)),
          eq(add(Z, Z), Z), eq(add(x, x), x), NOT(eq(x, Z)), eq(S(S(x)), Z)]
for p0 in starts:
    t = time.time()
    Uc = [p for p in Ubig if p != p0]
    l, seq, nst = longest_chain(p0, Uc, limit_states=300000)
    m, kk = size(p0), nfree(p0)
    print(f'{show(p0):28s} m={m} k={kk}: longest genuine chain = {l:2d}   (3m+k = {3*m+kk}, 2m = {2*m})  [{nst} states, {time.time()-t:.0f}s]')
