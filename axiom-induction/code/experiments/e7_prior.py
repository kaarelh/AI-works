"""E7: prior variants on the E2 data (PA mixture, L0): the time factor and a steeper simplicity penalty.

Prior: pi(T) proportional to 2^(-lam * bits(T)) * (1 + |T|)^(-tau), |T| = total template size.  The time
factor charges tau * log2(1 + |T|) bits; deciding axiomhood in DT° is a linear-time match against each
template, so this is the log of the membership-test time (brief H6).  lam > 1 is the steeper simplicity
penalty of inferential-learning T5.  Same data, causal pool (with Trim(T, D_n) and Mem(D_n)) and seeds as E2
(revised after the referee, M1: 25 seeds, pool built from data already seen).

Command: python3 e7_prior.py
"""
import time
from multiprocessing import Pool

from common import save, md_table, fmt
from pa_common import causal_pa_pool, t_star, W_TRUE, pa_classify, pa_heldout
from bai.grammar import Grammar
from bai.gens import cite_data
from bai.posterior import evaluate, Deriver, support_mass

NS = [8, 16, 32, 64, 128, 512]
SEEDS = list(range(25))
VARIANTS = [(1.0, 0.0), (1.0, 1.0), (1.0, 4.0), (2.0, 0.0), (0.5, 0.0)]
DELTA = 0.05


def run(seed):
    Q = Grammar()
    data = cite_data(t_star(), W_TRUE, Q, max(NS), seed)
    cpool = causal_pa_pool(data, seed)
    der = Deriver(K=0, Q=Q)
    _, false = pa_heldout(Q, seed, exclude=data)
    out = {}
    for lam, tau in VARIANTS:
        res_all = evaluate(cpool, data, NS, 'L0', Q=Q, alpha=0.5, lam=lam, tau=tau, trim=True, tagger=pa_classify)
        rows = []
        for n, res in zip(NS, res_all):
            names = [k for k in res if not k.startswith('_')]
            tag = {k: ('weaker' if k == 'Mem' else res[k]['theory'].tags.get('equiv', 'unknown')) for k in names}
            uns = sum(res[k]['post'] for k in names if tag[k] == 'no')
            eq = sum(res[k]['post'] for k in names if tag[k] == 'yes')
            mp = max(names, key=lambda k: res[k]['post'])
            pf = max(support_mass(res, [], der, s) for s in false)
            rows.append({'n': n, 'T*': res['T*']['post'], 'equiv': eq, 'unsound': uns, 'map': mp,
                         'map_tag': tag[mp], 'P_false_max': pf})
        out['%s|%s' % (lam, tau)] = rows
    sizes = {th.name: th.size() for th in cpool(max(NS))}
    return {'seed': seed, 'out': out, 'sizes': sizes}


def main():
    t0 = time.time()
    with Pool(4) as p:
        results = p.map(run, SEEDS, chunksize=1)
    S = len(results)
    txt = ['# E7: prior variants (time factor, steeper simplicity penalty) on the E2 data\n',
           'Command: `cd code/experiments && python3 e7_prior.py`. Seeds %d-%d. Causal pool with Trim(T, D_n) and '
           'Mem(D_n), as in E2. Wall time %.0f s. Template sizes (symbols) of some theories, seed 0: %s.\n'
           % (SEEDS[0], SEEDS[-1], time.time() - t0,
              {k: v for k, v in results[0]['sizes'].items()
               if k in ('T*', 'Q-lumped', 'bare?P', 'frag-complete', 'Ind-any-antecedent')})]
    rows = []
    for lam, tau in VARIANTS:
        key = '%s|%s' % (lam, tau)
        for i, n in enumerate(NS):
            def m(f):
                return sum(f(r['out'][key][i]) for r in results) / S
            maps = {}
            for r in results:
                k = r['out'][key][i]['map_tag']
                maps[k] = maps.get(k, 0) + 1
            rows.append([lam, tau, n, fmt(m(lambda x: x['T*'])), fmt(m(lambda x: x['equiv'])),
                         fmt(m(lambda x: x['unsound'])),
                         '%d/%d' % (sum(1 for r in results if r['out'][key][i]['P_false_max'] >= 1 - DELTA), S),
                         '; '.join('%s x%d' % (k, v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1]))])
    txt.append('\nColumns: mean posterior of T*, of theories deductively equivalent to T*, of unsound theories; '
               'seeds in which a delta = 0.05 verifier (citation depth) accepts a false probe; the tag of the MAP '
               '(yes = equivalent to T*, weaker = sound and strictly weaker, no = unsound) counted over seeds.\n\n')
    txt.append(md_table(['lambda', 'tau', 'n', 'T*', 'equiv. to T*', 'unsound', 'accepting seeds', 'MAP tag (count)'],
                        rows))
    # largest change of masses due to the time factor, per seed
    ch = {}
    for tau in (1.0, 4.0):
        d = 0.0
        for r in results:
            for a, b in zip(r['out']['1.0|0.0'], r['out']['1.0|%s' % tau]):
                d = max(d, abs(a['T*'] - b['T*']), abs(a['equiv'] - b['equiv']), abs(a['unsound'] - b['unsound']))
        ch[tau] = d
    txt.append('\nLargest change, over seeds and n, of the mass of T*, of its equivalents or of the unsound '
               'theories caused by the time factor: tau = 1: %s; tau = 4: %s.\n' % (fmt(ch[1.0], 4), fmt(ch[4.0], 4)))
    save('e7_prior', '\n'.join(txt), {'results': results, 'max_change_time_factor': ch})


if __name__ == '__main__':
    main()
