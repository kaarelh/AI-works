# A4: cost of staying sound before identification (escalations), from one example.
from common import *
import random, sys
sys.setrecursionlimit(10000)
rng = random.Random(4)
print('mu(sigma_x) =', mu(SIGMA_X), ' |sigma_x| =', size(SIGMA_X), '; mu(sigma) (x meta) =', mu(SIGMA_M))
# |ind(phi)| = 15 + 8m + 2k  (m = |phi|, k = number of free occurrences of x)
def nfree(f, v='x', bound=False):
    if is_objvar(f): return int(f[0] == v and not bound)
    if len(f) == 1: return 0
    if f[0] in QUANT: return nfree(f[2], v, bound or f[1][0] == v)
    return sum(nfree(a, v, bound) for a in f[1:])
U = motives_upto(5, ('x', 'y'))
ok = all(size(ind(p)) == 15 + 8 * size(p) + 2 * nfree(p) for p in U)
print('|ind(phi)| == 15 + 8m + 2k on the whole universe:', ok)
phi0 = eq(add(x, Z), x); m0, k0 = size(phi0), nfree(phi0)
s0 = ind(phi0)
print(f'example phi0 = x+0=x: m={m0}, k={k0}, mu(s0) = {mu(s0)}; paper bound mu(s0)-mu(sigma_x) = {mu(s0)-mu(SIGMA_X)} (= 8m+2k-5 = {8*m0+2*k0-5})')
print(f'                          tuple bound sum|theta x| = 3m+k = {3*m0+k0}; x metavariable: paper {mu(s0)-mu(SIGMA_M)}, tuple {3*m0+k0+1}')

# --- order isomorphism between sigma-lggs and tuple-lggs (checked on random chains) ---
def tup(phi, v=x): return ('tri', phi, subst(phi, v, Z), subst(phi, v, S(v)))
def tup_of_lgg(L):  # read eta off the lgg of sigma_x-instances
    return ('tri', L[1][1], L[1][4], L[2][4])
bad = 0
for _ in range(3000):
    phis = rng.sample(U, 4)
    Ls = [lgg_list([ind(p) for p in phis[:i]]) for i in range(1, 5)]
    Ts = [lgg_list([tup(p) for p in phis[:i]]) for i in range(1, 5)]
    for i in range(3):
        strict_s = not equiv(Ls[i], Ls[i + 1]); strict_t = not equiv(Ts[i], Ts[i + 1])
        if strict_s != strict_t or not equiv(tup_of_lgg(Ls[i + 1]), Ts[i + 1]): bad += 1
print('sigma-lgg chain strict <=> tuple-lgg chain strict, and tuple(lgg) == lgg(tuples): mismatches =', bad)

# --- tightness of the tuple bound when honest queries may be improper instances of sigma ---
fresh = iter(C('v%d' % i) for i in range(1000))
def one_step_generalizations_chain(T):
    """a chain T=g0 < g1 < ... < g_M = tri(z1,z2,z3) of length mu(T)-1, generalizing one symbol at a time
    (leaves first, then internal nodes bottom-up)."""
    chain = [T]; cur = T; cnt = [0]
    def positions(t, p=()):
        yield p, t
        if not is_var(t):
            for i, a in enumerate(t[1:], 1): yield from positions(a, p + (i,))
    def replace(t, p, new):
        if not p: return new
        return (t[0],) + tuple(replace(a, p[1:], new) if i == p[0] else a for i, a in enumerate(t[1:], 1))
    while True:
        cand = None
        for p, t in positions(cur):
            if len(p) == 0: continue
            if not is_var(t) and all(is_var(a) for a in t[1:]):     # leaf constant or node with variable children
                cand = p; break
        if cand is None: break
        cnt[0] += 1
        cur = replace(cur, cand, MV('g%d' % cnt[0])); chain.append(cur)
    return chain
T0 = tup(phi0)
chain = one_step_generalizations_chain(T0)
print(f'\ntuple chain from {show(T0)}: length {len(chain)-1}; mu drops by exactly 1 each step:',
      all(mu(chain[i]) - mu(chain[i + 1]) == 1 for i in range(len(chain) - 1)))
def ground_fresh(g):
    th = {}
    def ap(t):
        if is_var(t):
            if t[1] not in th: th[t[1]] = next(fresh)
            return th[t[1]]
        return (t[0],) + tuple(ap(a) for a in t[1:])
    return ap(g)
data = [s0]; esc = 0; allvalid = True; improper = 0
for g in chain[1:]:
    q_t = ground_fresh(g); q = ind_raw(q_t[1], x, q_t[2], q_t[3])
    allvalid &= is_instance(q, SIGMA_X); improper += (not sub_premises_true(q))
    L = lgg_list(data)
    if not is_instance(q, L): esc += 1
    data.append(q)
    assert equiv(tup_of_lgg(lgg_list(data)), g), 'lgg is not the next chain element'
print(f'honest prover (queries in inst(sigma_x), {improper} of them improper): escalations forced = {esc}; final lgg == sigma_x:',
      equiv(lgg_list(data), SIGMA_X), '; all queries valid:', allvalid)

# --- genuine-only prover: longest chain of strictly increasing lggs within a motive universe ---
def longest_chain(start_phi, universe, limit_states=400000):
    memo = {}
    tus = [tup(p) for p in universe]
    def rec(g):
        key = canon(g)
        if key in memo: return memo[key]
        best = (0, None)
        for t, p in zip(tus, universe):
            if is_instance(t, g): continue
            g2 = lgg_list([g, t])
            l, _ = rec(g2)
            if l + 1 > best[0]: best = (l + 1, p)
        memo[key] = best
        if len(memo) > limit_states: raise RuntimeError('too many states')
        return best
    L = rec(tup(start_phi))
    # reconstruct
    g = tup(start_phi); seq = []
    while True:
        l, p = memo[canon(g)]
        if p is None: break
        seq.append(p); g = lgg_list([g, tup(p)])
    return L[0], seq, len(memo)
for maxsz, conns in ((4, ('not', 'and', 'imp')), (5, ('not',)), (5, ('not', 'and', 'imp'))):
    Uc = motives_upto(maxsz, ('x', 'y'), conns=conns)
    Uc = [p for p in Uc if p != phi0]
    l, seq, nst = longest_chain(phi0, Uc)
    print(f'genuine-only, universe = motives of size <= {maxsz} with {conns} + all ({len(Uc)} motives): longest chain from ind(x+0=x) = {l} ({nst} states)')
    print('   witness queries (motives):', [show(p) for p in seq])
