# C3: anchors for raw induction in the determinate class DT and the wider class SO°.
# For every singleton and every pair of pool motives, enumerate ALL SO° templates of size <= SMAX
# (args of size <= 3, arity <= 2) covering the data, and classify each covering template:
#   good  : T >= T_ind (subsumption), hence inst(T) contains every induction instance;
#   bad   : T misses some held-out genuine induction instance (an explicit counterexample to "anchor");
#   undet : neither (reported; expected 0).
# Predictions: DT-anchor iff (R) & (N)  [Theorem C3];  SO°-anchor iff (R) & (B)  [Conjecture C7].
import sys, time, itertools
from multiprocessing import Pool
from so_core import *
from so_enum import enumerate_covering
from so_pool import *

SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 14

def analyse(names):
    ms = [POOL[n] for n in names]
    D = [Ind(m) for m in ms]
    F = enumerate_covering(D, SMAX, amax=3, maxar=2)
    res = {'names': names, 'ncov': len(F), 'ndet': 0, 'det_bad': [], 'so_bad': [], 'undet': 0}
    for T in F:
        det = is_determinate(T)
        res['ndet'] += det
        if subsumes(T, T_IND): continue
        miss = next((h for h in HELD if not covers(T, h)), None)
        if miss is None:
            res['undet'] += 1; continue
        (res['det_bad'] if det else res['so_bad']).append((size(T), pp(T), pp(miss)))
    res['det_bad'].sort(); res['so_bad'].sort()
    res['n_det_bad'] = len(res['det_bad']); res['n_so_bad'] = len(res['so_bad'])
    res['det_bad'] = res['det_bad'][:1]; res['so_bad'] = res['so_bad'][:1]
    res['R'], res['N'], res['B'] = pred_R(ms), pred_N(ms), pred_B(ms)
    return res

if __name__ == '__main__':
    t0 = time.time()
    names = list(POOL)
    jobs = [(n,) for n in names] + list(itertools.combinations(names, 2))
    with Pool(4) as p:
        out = p.map(analyse, jobs, chunksize=4)
    print('SMAX = %d; %d singletons, %d pairs; %.0f s' % (SMAX, len(names), len(jobs) - len(names), time.time() - t0))
    print('undetermined templates (neither >= T_ind nor missing a held-out instance):', sum(r['undet'] for r in out))
    # singletons
    sing = [r for r in out if len(r['names']) == 1]
    print('\n== singletons: anchors in DT: %d / %d, in SO°: %d / %d'
          % (sum(r['n_det_bad'] == 0 for r in sing), len(sing), sum(r['n_det_bad'] + r['n_so_bad'] == 0 for r in sing), len(sing)))
    for r in sing:
        b = r['det_bad'][0] if r['det_bad'] else None
        print('   %-16s smallest determinate bad template: %s' % (r['names'][0], ('%d %s  (misses %s)' % b) if b else 'none'))
    # pairs
    pairs = [r for r in out if len(r['names']) == 2]
    print('\n== pairs ==')
    from collections import Counter
    tab = Counter()
    agreeDT = agreeSO = 0
    for r in pairs:
        dt_anchor = r['n_det_bad'] == 0
        so_anchor = r['n_det_bad'] + r['n_so_bad'] == 0
        tab[(r['R'], r['N'], r['B'], dt_anchor, so_anchor)] += 1
        agreeDT += dt_anchor == (r['R'] and r['N'])
        agreeSO += so_anchor == (r['R'] and r['B'])
    print('DT-anchor  == (R)&(N): %d / %d pairs' % (agreeDT, len(pairs)))
    print('SO°-anchor == (R)&(B): %d / %d pairs' % (agreeSO, len(pairs)))
    print('(R,N,B, DT-anchor, SO-anchor): count')
    for k, v in sorted(tab.items()): print('   ', k, v)
    print('\nexamples of smallest bad templates per failure type:')
    shown = set()
    for r in sorted(pairs, key=lambda r: (r['R'], r['N'], r['B'])):
        key = (r['R'], r['N'], r['B'])
        if key in shown: continue
        shown.add(key)
        print('  pair %s  R=%s N=%s B=%s' % (r['names'], r['R'], r['N'], r['B']))
        if r['det_bad']: print('     determinate bad    : %d %s  (misses %s)' % r['det_bad'][0])
        if r['so_bad']: print('     non-determinate bad: %d %s  (misses %s)' % r['so_bad'][0])
    # extra: all (R)&(N) pairs failing (B) -- the determinacy counterexamples
    print('\n(R)&(N) pairs that are not SO°-anchors (all fail (B)):')
    for r in pairs:
        if r['R'] and r['N'] and r['n_so_bad'] > 0:
            print('   %-28s B=%s  #bad=%4d  smallest: %d %s (misses %s)' % (str(r['names']), r['B'], r['n_so_bad'], *r['so_bad'][0]))
    print('total covering templates enumerated:', sum(r['ncov'] for r in out))
