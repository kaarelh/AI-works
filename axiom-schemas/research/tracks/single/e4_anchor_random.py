# e4: general anchor theorem (Theorem D) on random DT° targets and random data.
#   pred  = (R*) & (N) & (U°)                                   [theorem]
#   feat  = anchor status from the feature characterization      [Theorem C machinery]
#   enum  = anchor status from INDEPENDENT bounded enumeration of covering DT° templates
#   wrong candidates: (R)&(N)&(D), (R*)&(N)&(D), (R*)&(N)&(U_pat)
# usage: python3 e4_anchor_random.py NCASES SEED ENUM_SMAX_SLACK
import sys, random, time, itertools, signal

class Timeout(Exception):
    pass
def _alarm(sig, frm):
    raise Timeout()
signal.signal(signal.SIGALRM, _alarm)
from dtcore import *
from dtfeat import Prefix
from dtwitness import events, anchor_by_features
from dtenum import enumerate_covering
from dtrandom import rand_template, rand_theta, rich_thetas, arities

NC = int(sys.argv[1]) if len(sys.argv) > 1 else 200
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 1
SLACK = int(sys.argv[3]) if len(sys.argv) > 3 else 2
rng = random.Random(SEED)


def instance_pool(T, k=150):
    pool = [instantiate(T, th) for th in rich_thetas(T)]
    for _ in range(k):
        pool.append(instantiate(T, rand_theta(rng, T)))
    return pool


stats = {}
def bump(k):
    stats[k] = stats.get(k, 0) + 1

examples = {}
t0 = time.time()
for case in range(NC):
    T = rand_template(rng)
    N = rng.choice([2, 2, 3])
    ths = [rand_theta(rng, T) for _ in range(N)]
    ev, D = events(T, ths)
    if len(set(D)) < 2:
        bump('skip_duplicate_data')
        continue
    pool = instance_pool(T)
    P = Prefix(D)
    # feature-based truth
    allgeq, bad = anchor_by_features(T, D)
    outside = [q for q in pool if not P.accepts(q)]
    if allgeq and not outside:
        feat = True
    elif outside:
        feat = False
    else:
        feat = None
    if allgeq and outside:
        bump('BUG_allgeq_but_outside')
    # sanity: data accepted, T* instances in pool accepted iff ...
    assert all(P.accepts(d) for d in D)
    # enumerator-based truth
    smax = size(T) + SLACK
    amax = max([size(a) for o in occurrences(T) for a in o[2]] + [1])
    ars = arities(T)
    arT = tuple(sorted({0, 1} | {n for nm, n in ars.items() if msort(nm) == 'T'}))
    arF = tuple(sorted({0} | {n for nm, n in ars.items() if msort(nm) == 'F'}))
    enum = None
    E = None
    if smax <= 22:
        t1 = time.time()
        signal.alarm(25)
        try:
            E = enumerate_covering(D, smax, amax=min(amax, 2), arities_T=arT, arities_F=arF,
                                   consts=('0', 'pa'), funcs=(('S', 1), ('add', 2)))
            signal.alarm(0)
        except Timeout:
            E = None
            bump('enum_timeout')
    if smax <= 22 and E is not None:
        nonsub = [U for U in E if not subsumes(U, T)]
        if not nonsub:
            enum = True
        else:
            cert = any(not covers(U, q) for U in nonsub for q in pool[:200])
            enum = False if cert else None
        bump('enum_time_%s' % ('lt1s' if time.time() - t1 < 1 else 'ge1s'))
        # Theorem C cross-check on the pool + data perturbations: Feat(D) == intersection of enum
        for q in pool[:60]:
            a1 = P.accepts(q)
            a2 = all(covers(U, q) for U in E)
            if a1 and not a2:
                bump('BUG_feat_accepts_enum_rejects')
                examples.setdefault('BUG_C', (T, ths, q))
            if a2 and not a1:
                bump('enum_accepts_feat_rejects(bounds)')
    pred = ev['pred']
    key = 'pred=%s feat=%s enum=%s' % (pred, feat, enum)
    bump(key)
    if feat is not None and pred != feat:
        examples.setdefault('pred!=feat', (T, ths))
    if enum is not None and pred != enum:
        # is the disagreement an artifact of the enumeration bounds?  (some feature template that is
        # not >= T* would have to fit the bounds: size, arities, argument size)
        fits = []
        for U in bad:
            occU = occurrences(U)
            ok = size(U) <= smax and all(len(o[2]) in (arT if msort(o[1]) == 'T' else arF) for o in occU) \
                and all(size(a) <= min(amax, 2) for o in occU for a in o[2])
            fits.append(ok)
        outside_rich = any(not P.accepts(q) for q in pool)
        if pred is False and enum is True and not any(fits) and (bad or outside_rich):
            bump('pred!=enum: bound artifact (no witnessing feature template fits the bounds)')
        else:
            bump('pred!=enum: UNEXPLAINED')
            examples.setdefault('pred!=enum', (T, ths))
    truth = feat if feat is not None else enum
    if truth is None:
        continue
    cands = {
        'R&N&D': ev['R'] and ev['N'] and ev['D'],
        'R*&N&D': ev['R*'] and ev['N'] and ev['D'],
        'R*&N&Upat': ev['R*'] and ev['N'] and ev['Upat'],
        'R*&N&U': pred,
    }
    for nm, v in cands.items():
        if v != truth:
            bump('cand %s wrong (%s, truth %s)' % (nm, 'says anchor' if v else 'says non-anchor', truth))
            examples.setdefault(nm, (T, ths))
    bump('truth=%s' % truth)

print('cases', NC, 'seed', SEED, 'slack', SLACK, 'time %.1fs' % (time.time() - t0))
for k in sorted(stats):
    print('  %-60s %d' % (k, stats[k]))
for k, v in examples.items():
    T, ths = v[0], v[1]
    print('example', k)
    print('   T* =', pp(T))
    for th in ths:
        print('   theta:', {a: pp(b) for a, b in th.items()}, ' datum:', pp(instantiate(T, th)))
    if len(v) > 2:
        print('   q =', pp(v[2]))
