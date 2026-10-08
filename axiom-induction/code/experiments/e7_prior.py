"""E7: prior variants on the E2 data (PA mixture, L0): the time factor and a steeper simplicity penalty.

Prior: pi(T) proportional to 2^(-lam * bits(T)) * (1 + |T|)^(-tau), |T| = total template size.  The time
factor charges tau * log2(1 + |T|) bits; deciding axiomhood in DT° is a linear-time match against each
template, so this is the log of the membership-test time (brief H6).  lam > 1 is the steeper simplicity
penalty of inferential-learning T5.  Same data, pools and seeds as E2.

Command: python3 e7_prior.py
"""
import time
from multiprocessing import Pool

from common import save, md_table, fmt
from pa_common import build_pa_pool, t_star, W_TRUE
from bai.grammar import Grammar
from bai.gens import cite_data
from bai.posterior import evaluate

NS = [8, 16, 32, 64, 128, 512]
SEEDS = [0, 1, 2, 3, 4]
VARIANTS = [(1.0, 0.0), (1.0, 1.0), (1.0, 4.0), (2.0, 0.0), (0.5, 0.0)]


def run(seed):
    Q = Grammar()
    data = cite_data(t_star(), W_TRUE, Q, max(NS), seed)
    pool = build_pa_pool(data, seed)
    out = {}
    for lam, tau in VARIANTS:
        res_all = evaluate(pool, data, NS, 'L0', Q=Q, alpha=0.5, lam=lam, tau=tau)
        rows = []
        for n, res in zip(NS, res_all):
            uns = sum(res[th.name]['post'] for th in pool if th.tags.get('sound') is False)
            eq = sum(res[th.name]['post'] for th in pool if th.tags.get('equiv') == 'yes')
            mp = max(res, key=lambda k: res[k]['post'])
            rows.append({'n': n, 'T*': res['T*']['post'], 'equiv': eq, 'unsound': uns, 'map': mp})
        out['%s|%s' % (lam, tau)] = rows
    sizes = {th.name: th.size() for th in pool}
    return {'seed': seed, 'out': out, 'sizes': sizes}


def main():
    t0 = time.time()
    with Pool(4) as p:
        results = p.map(run, SEEDS)
    txt = ['# E7: prior variants (time factor, steeper simplicity penalty) on the E2 data\n',
           'Command: `cd code/experiments && python3 e7_prior.py`. Seeds %s. Wall time %.0f s. Template sizes '
           '(symbols) of some theories, seed 0: %s.\n' % (SEEDS, time.time() - t0,
                                                          {k: v for k, v in results[0]['sizes'].items()
                                                           if k in ('T*', 'Q-lumped', 'bare?P', 'frag-complete',
                                                                    'Ind-any-antecedent')})]
    rows = []
    for lam, tau in VARIANTS:
        key = '%s|%s' % (lam, tau)
        for i, n in enumerate(NS):
            def m(f):
                return sum(f(r['out'][key][i]) for r in results) / len(results)
            maps = {}
            for r in results:
                maps[r['out'][key][i]['map']] = maps.get(r['out'][key][i]['map'], 0) + 1
            rows.append([lam, tau, n, fmt(m(lambda x: x['T*'])), fmt(m(lambda x: x['equiv'])),
                         fmt(m(lambda x: x['unsound'])),
                         '; '.join('%s x%d' % (k[:20], v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:3])])
    txt.append(md_table(['lambda', 'tau', 'n', 'T*', 'equiv. to T*', 'unsound', 'MAP (count)'], rows))
    save('e7_prior', '\n'.join(txt), {'results': results})


if __name__ == '__main__':
    main()
