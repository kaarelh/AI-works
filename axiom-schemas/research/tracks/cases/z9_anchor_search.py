# Track "cases", revision (referee F4): Thm E on the large frames with the bounded single-group search
# (dt_search.py), independent of the reduced enumerator of z2_anchors.py; in particular ReplJ anchor pairs,
# which z2b_fullcheck.py did not finish.  Usage: python3 z9_anchor_search.py SCHEMA NPAIRS GMAX AMAX
# Usage extended: python3 z9_anchor_search.py SCHEMA NPAIRS GMAX AMAX A3MAX (arity bound for groups of size 3).
# Probes: 12 genuine instances of the schema (bodies from the pool with all roots and argument patterns).
import sys, random, itertools, time
from st_core import *
from st_pool import pool_for
from dt_search import search

nm = sys.argv[1] if len(sys.argv) > 1 else 'ReplJ'
npairs = int(sys.argv[2]) if len(sys.argv) > 2 else 8
gmax = int(sys.argv[3]) if len(sys.argv) > 3 else 3
amax = int(sys.argv[4]) if len(sys.argv) > 4 else 2
a3max = int(sys.argv[5]) if len(sys.argv) > 5 else 1
P = pool_for(nm); n = len(SCHEMAS[nm]['args']); ks = list(P)
rng = random.Random(17)
probes = [instance(nm, P[k]) for k in ks if k not in ()][:12]
pairs = list(itertools.combinations(ks, 2)); rng.shuffle(pairs)
anchors = [c for c in pairs if pred_R([P[c[0]], P[c[1]]]) and all(pred_N([P[c[0]], P[c[1]]], n))]
non = [c for c in pairs if not (pred_R([P[c[0]], P[c[1]]]) and all(pred_N([P[c[0]], P[c[1]]], n)))]
sel = anchors[:npairs] + non[:npairs]
t0 = time.time()
agree = 0
for c in sel:
    bs = [P[c[0]], P[c[1]]]
    D = [instance(nm, b) for b in bs]
    pred = pred_R(bs) and all(pred_N(bs, n))
    # the probes must not be data
    pr = [q for q in probes if q not in D]
    for degree in ('DT', 'SO'):
        ncov, wit = search(D, pr, [Par('a')], gmax=gmax, amax=amax, degree=degree, a3max=a3max)
        got = not wit
        if degree == 'DT': agree += got == pred
        print('  %-6s %-24s pred anchor %-5s | %s: covering single-group templates seen %5d, anchor %-5s %s'
              % (nm, '%s, %s' % c, pred, degree, ncov, got, '' if got == pred else '  <-- DISAGREE'), flush=True)
print('%s: DT agreement %d/%d; time %.0fs (gmax %d, amax %d, arity bound for groups of size 3: %d)' % (nm, agree, len(sel), time.time() - t0, gmax, amax, a3max))
