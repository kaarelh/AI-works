# Referee check: Theorem C (Acc = Feat) and Theorem D ((R*)(N)(U) <=> anchor) on random DT° targets,
# against an independent bounded brute-force enumeration of covering templates.
# usage: python3 t3_random.py SEED NCASES
import sys, time, random, signal, itertools
from collections import Counter
from rc_core import *
from rc_enum import enumerate_covering
from rc_random import *
from rc_anchor import *

class TO(Exception): pass
def handler(s, f): raise TO()
signal.signal(signal.SIGALRM, handler)

seed = int(sys.argv[1]); ncases = int(sys.argv[2])
rng = random.Random(seed)
TYPES = ['f1', 'f2', 'c0', 'P1', 'P2', 'Q0']   # name encodes sort; arity from digit
stats = Counter()
examples = []
t_start = time.time()
case = 0
while case < ncases:
    k = rng.choice([1, 1, 2])
    chosen = rng.sample(TYPES, k)
    metas_ = {}
    for i, t in enumerate(chosen):
        nm = (t[0] + str(i)) if True else t
        metas_[nm] = int(t[1])
    T = random_template(rng, metas_)
    if T is None:
        continue
    N = rng.choice([2, 2, 3])
    ths = [{nm: rbody(rng, nm, ar, d=rng.choice([0, 1, 2])) for nm, ar in metas_.items()} for _ in range(N)]
    D = [inst(T, th) for th in ths]
    if len(set(D)) < N:
        stats['skip_dup'] += 1
        continue
    case += 1
    ev, wit = events(T, D)
    pred = ev['R*'] and ev['N'] and ev['U']
    ft, q = feat_truth(T, D, extra_rng=rng, n_random=30)
    stats['pred=%s feat=%s' % (pred, ft)] += 1
    if pred != ft:
        examples.append(('PRED!=FEAT', pp(T), [pp(d) for d in D], ev, pp(q) if q else None))
    for cand, val in [('RND', ev['R'] and ev['N'] and ev['D']), ('R*ND', ev['R*'] and ev['N'] and ev['D']),
                      ('R*NUpat', ev['R*'] and ev['N'] and ev['Upat'])]:
        if val != ft:
            stats['cand %s wrong' % cand] += 1
    # brute force with bounds large enough to contain T_0 and all T_phi
    info = DataInfo(D)
    kmax = len(info.slots) + 1
    amax = max([len(info.Y[s]) for s in info.slots] + [0])
    if kmax > 7 or amax > 3:
        stats['enum_skipped_bounds'] += 1
        continue
    signal.alarm(60)
    try:
        t0 = time.time()
        Ts = enumerate_covering(D, kmax=kmax, amax=amax)
        signal.alarm(0)
    except TO:
        stats['enum_timeout'] += 1
        continue
    except RuntimeError:
        signal.alarm(0)
        stats['enum_too_many'] += 1
        continue
    # query pool: adversarial instances of T*, random instances of T*, random instances of covering templates
    pool = set(D)
    mt = metas(T)
    names = list(mt)
    for combo in itertools.product(*[candidate_bodies(nm, len(mt[nm][0][1])) for nm in names]):
        pool.add(inst(T, dict(zip(names, combo))))
    for _ in range(30):
        pool.add(inst(T, {nm: rbody(rng, nm, len(mt[nm][0][1])) for nm in names}))
    sample = Ts if len(Ts) <= 150 else rng.sample(Ts, 150)
    for U in sample:
        mu = metas(U)
        for _ in range(2):
            th = {}
            for nm in mu:
                ar = len(mu[nm][0][1])
                th[nm] = rng.choice(candidate_bodies(nm, ar)) if rng.random() < 0.5 else rbody(rng, nm, ar)
            pool.add(inst(U, th))
    pool = list(pool)
    signal.alarm(120)
    try:
        accE = [True] * len(pool)
        for U in Ts:
            for i, qq in enumerate(pool):
                if accE[i] and match(U, qq) is None:
                    accE[i] = False
        signal.alarm(0)
    except TO:
        stats['pool_timeout'] += 1
        continue
    accF = [info.has_features(qq) for qq in pool]
    nbad1 = sum(1 for a, b in zip(accF, accE) if a and not b)   # Feat accepts, some covering template rejects: refutes Thm C
    nbad2 = sum(1 for a, b in zip(accF, accE) if b and not a)   # Feat rejects, all enumerated accept: bound artifact or enumerator bug
    stats['thmC_queries'] += len(pool)
    stats['thmC_accepted'] += sum(accF)
    if nbad1 or nbad2:
        stats['thmC_DISAGREE_cases'] += 1
        examples.append(('THM C DISAGREE', pp(T), [pp(d) for d in D], nbad1, nbad2))
    else:
        stats['thmC_agree_cases'] += 1
    # enum anchor truth: all candidate instances of T* accepted by every enumerated covering template?
    inst_idx = [i for i, qq in enumerate(pool) if match(T, qq) is not None]
    enum_anchor = all(accE[i] for i in inst_idx)
    stats['enum_decided'] += 1
    if enum_anchor != pred:
        stats['PRED!=ENUM'] += 1
        examples.append(('PRED!=ENUM', pp(T), [pp(d) for d in D], ev))
    else:
        stats['pred=enum'] += 1
print('seed', seed, 'cases', ncases, 'time %.0fs' % (time.time() - t_start))
for k_, v in sorted(stats.items()):
    print('  %-28s %d' % (k_, v))
for e in examples[:10]:
    print('EXAMPLE', e)
