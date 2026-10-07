# Track "cases", Part 2(e): anchors of the ZF schemas in DT-degree (and SO-degree for the small frames).
# Claim (Theorem E, notes.md): D is an anchor  <=>  (R) the bodies' main symbols are not all equal, and
# (N_i) for every argument i of P some body has argument i free.
#   Phase A: on all singletons and pairs of each pool, all 7 schemas: if (R) holds, the reduced DT enumeration
#            (exact for anchor-hood, Lemmas E1-E4); if (R) fails, the most specific covering DT template on the
#            maximal common prefix (st_enum.most_specific_own) is checked to be not >= T* (certifies non-anchor).
#   Phase B: full data-directed enumeration (DT and SO, arity <= 3) on the pairs WITH (R) for Sep, SepJ, EInd,
#            as a cross-check of the reduction and of the SO-degree claim.  Each enumeration stops at the first
#            covering template that is not >= T* (enough to refute anchor-hood; complete for anchors) and has a
#            time limit of LIMIT seconds; timed-out runs are reported, not counted.
import sys, itertools, time, signal
from multiprocessing import Pool
from st_core import *
from st_pool import pool_for
from st_enum import enumerate_dt_reduced, enumerate_covering, most_specific_own

LIMIT = 10

class TimeOut(Exception): pass
def _alarm(sig, frm): raise TimeOut()

def jobA(arg):
    nm, keys = arg
    P = pool_for(nm); T = SCHEMAS[nm]['T']; n = len(SCHEMAS[nm]['args'])
    bodies = [P[k] for k in keys]
    D = [instance(nm, b) for b in bodies]
    R = pred_R(bodies); N = pred_N(bodies, n)
    if R:
        r = enumerate_dt_reduced(D, T)
        return dict(nm=nm, keys=keys, R=R, N=tuple(N), pred=R and all(N), red=r[2] is None, nred=r[0],
                    bad=pp(r[2]) if r[2] else None)
    # (R) fails: certify non-anchor by the most specific covering DT template on the maximal common prefix
    Tm = most_specific_own(D)
    assert all(covers(Tm, s) for s in D) and is_determinate(Tm)
    ok = subsumes(Tm, T)
    return dict(nm=nm, keys=keys, R=R, N=tuple(N), pred=False, red=ok, nred=1, bad=None if ok else pp(Tm))

def jobB(arg):
    nm, keys = arg
    signal.signal(signal.SIGALRM, _alarm)
    P = pool_for(nm); T = SCHEMAS[nm]['T']; n = len(SCHEMAS[nm]['args'])
    bodies = [P[k] for k in keys]
    D = [instance(nm, b) for b in bodies]
    out = dict(nm=nm, keys=keys, pred=pred_R(bodies) and all(pred_N(bodies, n)))
    for mode in ('DT', 'SO'):
        signal.alarm(LIMIT)
        try:
            f = enumerate_covering(D, mode, 3, T, stop_at_bad=True)
            signal.alarm(0)
            out[mode] = (f[2] is None, f[0])
        except TimeOut:
            out[mode] = None
    return out

if __name__ == '__main__':
    t0 = time.time()
    jobs = []
    for nm in SCHEMAS:
        ks = list(pool_for(nm))
        jobs += [(nm, (k,)) for k in ks] + [(nm, pr) for pr in itertools.combinations(ks, 2)]
    with Pool(4) as pool:
        res = list(pool.imap_unordered(jobA, jobs, chunksize=8))
    print('Phase A (reduced DT-degree enumeration), %.1fs' % (time.time() - t0))
    for nm in SCHEMAS:
        rs = [r for r in res if r['nm'] == nm]
        sing = [r for r in rs if len(r['keys']) == 1]
        prs = [r for r in rs if len(r['keys']) == 2]
        print('%-6s T* = %s' % (nm, pp(SCHEMAS[nm]['T'])))
        print('   singletons: %d, anchors among them: %d' % (len(sing), sum(r['red'] for r in sing)))
        agree = sum(r['red'] == r['pred'] for r in prs)
        rp = [r for r in prs if r['R']]
        print('   pairs: %d (with (R): %d); anchor <=> (R)&(N): agree on %d; anchors %d; reduced templates per (R)-pair %d..%d'
              % (len(prs), len(rp), agree, sum(r['red'] for r in prs), min(r['nred'] for r in rp), max(r['nred'] for r in rp)))
        cats = {}
        for r in prs:
            key = (r['R'],) + r['N']
            cats.setdefault(key, [0, 0]); cats[key][0] += 1; cats[key][1] += r['red']
        print('   (R, N_%s) -> [pairs, anchors]:' % (SCHEMAS[nm]['args'],), {k: v for k, v in sorted(cats.items())})
        for r in [r for r in prs if not r['red']][:2]:
            print('     non-anchor %s: R=%s N=%s  bad covering template: %s' % (r['keys'], r['R'], r['N'], r['bad']))
    sys.stdout.flush()
    t1 = time.time()
    jobsB = []
    for nm in ('Sep', 'SepJ', 'EInd'):
        P = pool_for(nm)
        for pr in itertools.combinations(list(P), 2):
            if pred_R([P[k] for k in pr]): jobsB.append((nm, pr))
    with Pool(4) as pool:
        resB = list(pool.imap_unordered(jobB, jobsB))
    print('\nPhase B (full data-directed enumeration, arity <= 3, limit %ds per run), %.1fs' % (LIMIT, time.time() - t1))
    for nm in ('Sep', 'SepJ', 'EInd'):
        rs = [r for r in resB if r['nm'] == nm]
        for mode in ('DT', 'SO'):
            done = [r for r in rs if r[mode] is not None]
            agree = sum(r[mode][0] == r['pred'] for r in done)
            an = [r[mode][1] for r in done if r['pred']]
            print('   %-5s %s: pairs with (R) %d, finished %d, anchor <=> (R)&(N) on %d/%d; covering templates per anchor pair %s'
                  % (nm, mode, len(rs), len(done), agree, len(done), ('%d..%d' % (min(an), max(an))) if an else '-'))
    print('total %.1fs' % (time.time() - t0))
