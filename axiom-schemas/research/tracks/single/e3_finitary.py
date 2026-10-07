# e3: Theorems B and C against the INDEPENDENT bounded enumerator.
#   For random data sets D (instances of random DT° templates, also non-anchors):
#   (B) minimal covering templates from Sat(D) (theory) == minimal ones from brute-force enumeration
#       (when the enumeration bound contains all of Sat-minimal templates)
#   (C) Feat(D) membership == intersection of all enumerated covering templates, on a query pool
#       made of instances of every minimal template (rich + random bodies) and of the target
#   (G3) lgg-existence criterion == (|Min| == 1)
# usage: python3 e3_finitary.py NCASES SEED
import sys, random, time, signal

class Timeout(Exception):
    pass
def _alarm(sig, frm):
    raise Timeout()
signal.signal(signal.SIGALRM, _alarm)
from dtcore import *
from dtfeat import Prefix
from dtenum import enumerate_covering, minimal_elements
from dtrandom import rand_template, rand_theta, rich_thetas, arities

NC = int(sys.argv[1]) if len(sys.argv) > 1 else 100
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 7
MODE = sys.argv[3] if len(sys.argv) > 3 else 'random'   # 'low': low-diversity data (many coincidences)
rng = random.Random(SEED)
stats = {}
def bump(k, v=1):
    stats[k] = stats.get(k, 0) + v
ex = {}
t0 = time.time()
for case in range(NC):
    if case % 10 == 0:
        print('progress', case, dict(stats), '%.0fs' % (time.time() - t0), flush=True)
    T = rand_template(rng)
    N = rng.choice([2, 2, 3])
    if MODE == 'low':
        def low(nm, n):
            if msort(nm) == 'T':
                return rng.choice([Z, PA] + [H(m) for m in range(n)] + [S(H(m)) for m in range(n)])
            return rng.choice([eq(Z, Z), NOT(eq(Z, Z))] + [eq(H(m), Z) for m in range(n)] + [eq(H(m), H(m)) for m in range(n)])
        ths = [{nm: low(nm, n) for nm, n in arities(T).items()} for _ in range(N)]
    else:
        ths = [rand_theta(rng, T) for _ in range(N)]
    D = [instantiate(T, th) for th in ths]
    if len(set(D)) < 2:
        continue
    P = Prefix(D)
    signal.alarm(60)
    try:
        mins_sat, reps = P.minimal(limit=400)
        signal.alarm(0)
    except Timeout:
        bump('skip_timeout_sat')
        continue
    if len(reps) > 400:
        bump('skip_big_sat')
        continue
    smax = max(size(m) for m in mins_sat)
    if smax > 21:
        bump('skip_big_min')
        continue
    amax = max([size(a) for m in mins_sat for o in occurrences(m) for a in o[2]] + [1])
    ars = {}
    for m in mins_sat:
        for o in occurrences(m):
            ars[(msort(o[1]), len(o[2]))] = 1
    arT = tuple(sorted({0} | {n for (s, n) in ars if s == 'T'}))
    arF = tuple(sorted({0} | {n for (s, n) in ars if s == 'F'}))
    if amax > 3 or max(arT + arF) > 2:
        bump('skip_bounds')
        continue
    t1 = time.time()
    signal.alarm(90)
    try:
        E = enumerate_covering(D, smax, amax=amax, arities_T=arT, arities_F=arF,
                               consts=('0', 'pa'), funcs=(('S', 1), ('add', 2)))
        signal.alarm(0)
    except Timeout:
        bump('skip_timeout_enum')
        continue
    mins_enum, _ = minimal_elements(E)
    bump('cases')
    # (B): compare minimal sets up to equivalence
    same = (len(mins_enum) == len(mins_sat) and
            all(any(equivalent(a, b) for b in mins_sat) for a in mins_enum))
    bump('B_agree' if same else 'B_DISAGREE')
    if not same:
        ex.setdefault('B', (D, mins_sat, mins_enum))
    bump('min_count_%d' % len(mins_sat))
    # sanity: every enumerated covering template is above some Sat-minimal one
    above = all(any(subsumes(U, m) for m in mins_sat) for U in E)
    bump('every_cover_above_min' if above else 'COVER_NOT_ABOVE_MIN')
    if MODE == 'low' and len(E) > 1500:
        bump('skip_big_enum')
        continue
    # (C): query pool
    pool = []
    for m in mins_sat + [T]:
        for th in rich_thetas(m)[:80]:
            pool.append(instantiate(m, th))
        for _ in range(20):
            pool.append(instantiate(m, rand_theta(rng, m)))
    if MODE == 'low':          # keep low-diversity cases fast
        rng.shuffle(pool)
        pool = pool[:300]
    agree = 0
    for q in pool:
        a = P.accepts(q)
        b = all(covers(U, q) for U in E)
        if a == b:
            agree += 1
        else:
            bump('C_DISAGREE')
            ex.setdefault('C', (D, q, a, b))
    bump('C_queries', len(pool))
    bump('C_agree', agree)
    nacc = sum(1 for q in pool if P.accepts(q))
    bump('C_accepted', nacc)
    # (G3)
    ok, why = P.lgg_exists()
    if ok != (len(mins_sat) == 1):
        bump('G3_DISAGREE')
        ex.setdefault('G3', (D, ok, len(mins_sat)))
    else:
        bump('G3_agree')
    if ok:
        L = P.lgg()
        if not (len(mins_sat) == 1 and equivalent(L, mins_sat[0])):
            bump('G3_LGG_WRONG')
print('NC', NC, 'seed', SEED, 'mode', MODE, 'time %.1fs' % (time.time() - t0))
for k in sorted(stats):
    print('  %-30s %d' % (k, stats[k]))
for k, v in ex.items():
    print('example', k, [pp(d) for d in v[0]], v[1:])
