# e5: specializations of the anchor theorem (Corollaries D1-D3), checked on random data.
#   FO patterns (all metavariables 0-ary):  (R*)&(N)&(U°)  <=>  (R)&(D)          [Plotkin-Reynolds]
#   single formula metavariable (Ind, ZF Separation, Replacement, eps-induction):
#                                           (R*)&(N)&(U°)  <=>  (R)&(N)
#   and in every case the anchor status computed from the feature characterization agrees
#   (anchor: all feature templates >= T*;  non-anchor: some T* instance outside Feat(D)).
import sys, random, itertools
from dtcore import *
from dtfeat import Prefix
from dtwitness import events, anchor_by_features
from dtrandom import rand_term, rand_formula_body, rich_thetas, rand_theta

rng = random.Random(11)
stats = {}
def bump(k):
    stats[k] = stats.get(k, 0) + 1


def truth(T, D, extra_pool):
    ok, bad = anchor_by_features(T, D)
    P = Prefix(D)
    pool = [instantiate(T, th) for th in rich_thetas(T)] + extra_pool
    out = [q for q in pool if not P.accepts(q)]
    if ok and not out:
        return True
    if out:
        return False
    return None


# ---------------------------------------------------------------- first-order patterns
def rand_fo_template(rng):
    specs = rng.sample([('c', 'T'), ('d', 'T'), ('A', 'F'), ('B', 'F')], rng.choice([1, 2, 2, 3]))
    parts = []
    for nm, srt in specs:
        for _ in range(rng.randint(1, 2)):
            nb = rng.choice([0, 1])
            if srt == 'T':
                f = eq(M(nm), rand_term(rng, nb, 2)) if rng.random() < 0.5 else eq(S(M(nm)), rand_term(rng, nb, 1))
            else:
                f = M(nm) if rng.random() < 0.6 else NOT(M(nm))
            parts.append(ALL(f) if nb else f)
    rng.shuffle(parts)
    T = parts[0]
    for g in parts[1:]:
        T = AND(T, g)
    return T

for _ in range(600):
    T = rand_fo_template(rng)
    ars = {o[1] for o in occurrences(T)}
    N = rng.choice([2, 2, 3])
    ths = []
    for _ in range(N):
        th = {}
        for nm in ars:
            if msort(nm) == 'T':
                th[nm] = rng.choice([Z, PA, S(Z), add(Z, PA), S(PA)])
            else:
                th[nm] = rng.choice([eq(Z, Z), eq(PA, Z), NOT(eq(Z, Z)), ALL(eq(V(0), Z)), AND(eq(Z, Z), eq(Z, PA))])
        ths.append(th)
    ev, D = events(T, ths)
    if len(set(D)) < 2:
        continue
    plot = ev['R'] and ev['D']
    bump('FO cases')
    bump('FO pred==(R)&(D): %s' % (ev['pred'] == plot))
    tr = truth(T, D, [])
    bump('FO truth==pred: %s' % (tr == ev['pred'] if tr is not None else 'undetermined'))

# ---------------------------------------------------------------- one formula metavariable
def zf_atom(rng, n, depth=0):
    leaves = [H(m) for m in range(n)] + [PA, PB] + [V(k) for k in range(depth)]
    return (mem if rng.random() < 0.7 else eq)(rng.choice(leaves), rng.choice(leaves))

def zf_body(rng, n, size=4, depth=0):
    r = rng.random()
    if size <= 1 or r < 0.4:
        return zf_atom(rng, n, depth)
    if r < 0.55:
        return NOT(zf_body(rng, n, size - 1, depth))
    if r < 0.75:
        return (AND if rng.random() < 0.5 else OR)(zf_body(rng, n, size // 2, depth), zf_body(rng, n, size // 2, depth))
    return (ALL if rng.random() < 0.5 else EX)(zf_body(rng, n, size - 1, depth + 1))

def motive(rng, n, zf=False):
    """random formula body with holes < n"""
    return zf_body(rng, n) if zf else rand_formula_body(rng, n)

TEMPL = [('Ind', T_IND, 1), ('Separation', T_SEP, 2), ('Replacement', T_REP, 3), ('eps-Ind', T_EIND, 1)]
for name, T, n in TEMPL:
    for _ in range(500):
        N = rng.choice([1, 2, 2, 3])
        ths = [{'P': motive(rng, n, name != 'Ind')} for _ in range(N)]
        ev, D = events(T, ths)
        if len(set(D)) < len(D):
            continue
        bump('%s cases' % name)
        rn = ev['R'] and ev['N']
        bump('%s pred==(R)&(N): %s' % (name, ev['pred'] == rn))
        extra = [instantiate(T, {'P': motive(rng, n, name != 'Ind')}) for _ in range(40)]
        tr = truth(T, D, extra)
        bump('%s truth==pred: %s' % (name, tr == ev['pred'] if tr is not None else 'undetermined'))
        if ev['pred']:
            bump('%s anchors' % name)
            bump('%s anchor sizes: %d' % (name, N))

for k in sorted(stats):
    print('  %-50s %d' % (k, stats[k]))
