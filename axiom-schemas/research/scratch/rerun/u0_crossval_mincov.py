# u0: cross-validate dtlib.mincov (slot/derivation analysis, no size bound) against the prior track's
# brute-force data-directed enumerator (prior/induction/so_enum.py, complete within size/argument bounds).
# Property checked (hypothesis W restricted to the enumerated fragment): every covering template found by the
# brute force lies above (is subsumed-by-generality) some template returned by mincov, and every mincov
# template covers the data and is determinate.
import sys, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/prior/induction')
import so_core as P
import so_enum as E
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
import dtlib as L

OPS = {'eq': '=', 'add': '+', 'mul': '*', 'not': 'not', 'and': 'and', 'or': 'or', 'imp': 'imp',
       'all': 'all', 'ex': 'ex', 'S': 'S', '0': '0'}
def conv(t):
    h = t[0]
    if h in ('v', 'h'): return t
    if h == 'M':
        nm = t[1]
        nm2 = ('F' + nm) if nm[0].isupper() else ('t' + nm)
        return ('M', nm2) + tuple(conv(a) for a in t[2:])
    if h == '0': return ('0',)
    return (OPS[h],) + tuple(conv(k) for k in P.kids(t))

pairs = [('x=x', '~x=0'), ('x=x', 'x+0=x'), ('x=x', '0=x'), ('x=0', 'Sx=0'), ('0+x=x', 'x+0=x'),
         ('x=x', 'Sx=S0'), ('~x=0', '~Sx=0'), ('0=0', '~0=S0')]
POOL = {'x=x': P.eq(P.X, P.X), '0=x': P.eq(P.Z, P.X), 'x=0': P.eq(P.X, P.Z), 'Sx=0': P.eq(P.S(P.X), P.Z),
        'x+0=x': P.eq(P.add(P.X, P.Z), P.X), '~x=0': P.NOT(P.eq(P.X, P.Z)), '0+x=x': P.eq(P.add(P.Z, P.X), P.X),
        'Sx=S0': P.eq(P.S(P.X), P.S(P.Z)), '~Sx=0': P.NOT(P.eq(P.S(P.X), P.Z)), '0=0': P.eq(P.Z, P.Z),
        '~0=S0': P.NOT(P.eq(P.Z, P.S(P.Z)))}
SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 16
tot_bad = 0
for a, b in pairs:
    t0 = time.time()
    Dp = [P.Ind(POOL[a]), P.Ind(POOL[b])]
    Dl = [conv(d) for d in Dp]
    mine = L.mincov(Dl)
    assert all(L.covers_all(T, Dl) for T in mine)
    assert all(L.is_determinate(T) for T in mine)
    cov = E.enumerate_covering(Dp, SMAX, amax=2)
    cov = [conv(T) for T in cov if P.is_determinate(T)]
    bad = [T for T in cov if not any(L.subsumes(T, m) for m in mine)]
    tot_bad += len(bad)
    print('%-6s | %-6s  mincov=%d  bruteforce DT covering (size<=%d)=%d  not above a mincov template: %d  (%.1fs)'
          % (a, b, len(mine), SMAX, len(cov), len(bad), time.time() - t0))
    for m in mine: print('      min:', L.pp(m), ' size', L.size(m))
    for T in bad[:3]: print('      UNCOVERED:', L.pp(T))
print('TOTAL counterexamples to completeness:', tot_bad)
