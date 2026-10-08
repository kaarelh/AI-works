"""E2: unlabelled PA mixture (Q's 7 axioms + induction instances) under the citation likelihood L0.

Generator (well specified): component i ~ w with w = 0.05 for each Q axiom and 0.65 for T_Ind; induction
motives from the default Grammar Q (formula with one hole, no parameter).  Pool: T*, frag-complete (T_Ind
split by the root of the motive into 9 templates), frag-observed64 (only the roots seen in the first 64
data), frag-atoms, spare slots (nested T_and, a true sentence, a false sentence), IndSwap (deductively
equivalent, never cited), over-general induction variants, bare ?P, a Q-lumped theory, skeleton
clusters (k = 4, 6, 8), DTRC with refutation on the first 16 and 40 data, Q + Min of random data
subsets, and Mem(D_n).  Posterior by exact enumeration over the pool, Dirichlet(0.5) weights.

Reported: posterior mass on T*, on the theories tagged deductively equivalent to T*, by class, the MAP
theory, and the verifier view at citation depth (K=0): mass deriving held-out induction instances and
false probe sentences.

Command: python3 e2_pa.py   (seeds 0-4)
"""
import sys
import time
from multiprocessing import Pool

from common import save, md_table, fmt, pp, Theory
from pa_common import build_pa_pool, t_star, W_TRUE, pa_heldout, ROOTS, motive_root
from bai.grammar import Grammar
from bai.gens import cite_data
from bai.posterior import evaluate, Deriver, support_mass

NS = [8, 16, 32, 64, 128, 256, 512]
SEEDS = [0, 1, 2, 3, 4]
CLASSES = ['true', 'fragmented', 'spare', 'equivalent-uncited', 'over-general', 'over-specific', 'sub-T*',
           'skeleton', 'dtrc', 'min', 'mem']


def summarise(pool, res_all, ns, Q, seed, der):
    inst, false = pa_heldout(Q, seed)
    rows = []
    for n, res in zip(ns, res_all):
        cm = {c: 0.0 for c in CLASSES}
        eq = 0.0
        uns = 0.0
        for th in pool:
            p = res[th.name]['post']
            cm[th.tags.get('cls', 'other')] = cm.get(th.tags.get('cls', 'other'), 0.0) + p
            if th.tags.get('equiv') == 'yes':
                eq += p
            if th.tags.get('sound') is False:
                uns += p
        cm['mem'] += res['Mem']['post']
        mp = max(res, key=lambda k: res[k]['post'])
        pi = sum(support_mass(res, pool, der, s) for s in inst) / len(inst)
        pf = max(support_mass(res, pool, der, s) for s in false)
        rows.append({'n': n, 'T*': res['T*']['post'], 'equiv': eq, 'unsound': uns, 'mass': cm, 'map': mp,
                     'map_post': res[mp]['post'], 'P_inst': pi, 'P_false_max': pf,
                     'post': {k: v['post'] for k, v in res.items() if v['post'] > 1e-6},
                     'bits': {k: -(v['lp'] + v['lm']) / 0.6931471805599453 for k, v in res.items()
                              if v['lm'] > -1e300}})
    return rows


def first_seen(data):
    """index (1-based) of the first datum of each Q axiom and the first induction instance"""
    from pa_common import QSENT
    out = {}
    for j, d in enumerate(data):
        for i, q in enumerate(QSENT):
            if d == q and 'Q%d' % (i + 1) not in out:
                out['Q%d' % (i + 1)] = j + 1
        if motive_root(d) and 'Ind' not in out:
            out['Ind'] = j + 1
    return out


def run(seed, gen=None, ns=NS, label='E2'):
    t0 = time.time()
    Q = Grammar()
    data = gen(seed) if gen else cite_data(t_star(), W_TRUE, Q, max(ns), seed)
    pool = build_pa_pool(data, seed)
    res_all = evaluate(pool, data, ns, 'L0', Q=Q, alpha=0.5)
    der = Deriver(K=0, Q=Q)
    rows = summarise(pool, res_all, ns, Q, seed, der)
    roots = {}
    for d in data:
        r = motive_root(d)
        if r:
            roots[r] = roots.get(r, 0) + 1
    return {'seed': seed, 'rows': rows, 'first_seen': first_seen(data), 'pool': [(th.name, th.tags.get('cls'), th.tags.get('equiv'),
                                                   th.tags.get('sound'), round(th.bits(), 1), len(th.comps))
                                                  for th in pool],
            'roots': roots, 'time': round(time.time() - t0, 1)}


def report(name, title, intro, results, ns, wall):
    txt = ['# %s\n' % title, intro, 'Wall time %.0f s.\n' % wall]
    txt.append('\n## Pool (seed %d)\n' % results[0]['seed'])
    txt.append(md_table(['theory', 'class', 'equivalent to T*', 'sound', 'bits', 'components'],
                        [list(x) for x in results[0]['pool']] + [['Mem(D_n)', 'mem', 'no', True, '-', 'n distinct']]))
    txt.append('\nMotive roots in the data (seed %d, all n): %s\n' % (results[0]['seed'], results[0]['roots']))
    txt.append('\nFirst occurrence (datum index) of each axiom, per seed: %s\n' % '; '.join(
        'seed %d: %s' % (r['seed'], r['first_seen']) for r in results))
    rows = []
    for i, n in enumerate(ns):
        def m(f):
            return sum(f(r['rows'][i]) for r in results) / len(results)
        maps = {}
        for r in results:
            maps[r['rows'][i]['map']] = maps.get(r['rows'][i]['map'], 0) + 1
        rows.append([n, fmt(m(lambda x: x['T*'])), fmt(m(lambda x: x['equiv'])),
                     fmt(m(lambda x: x['mass']['fragmented'])), fmt(m(lambda x: x['mass']['spare'])),
                     fmt(m(lambda x: x['mass']['over-general'])), fmt(m(lambda x: x['mass']['over-specific'])),
                     fmt(m(lambda x: x['mass']['sub-T*'])),
                     fmt(m(lambda x: x['mass']['skeleton'] + x['mass']['dtrc'] + x['mass']['min'])),
                     fmt(m(lambda x: x['mass']['mem'])), fmt(m(lambda x: x['unsound'])),
                     fmt(m(lambda x: x['P_inst'])), fmt(m(lambda x: x['P_false_max'])),
                     '; '.join('%s x%d' % (k[:22], v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1]))])
    txt.append('\n## Posterior mass (means over seeds %s)\n\n' % [r['seed'] for r in results])
    txt.append(md_table(['n', 'T*', 'equiv. to T* (incl. T*)', 'fragmented', 'spare', 'over-general',
                         'over-specific', 'sub-T* (unseen Q axioms dropped)', 'other skeleton/DTRC/min', 'Mem', 'unsound', 'P(|-held-out Ind)',
                         'max P(|-false)', 'MAP (count over seeds)'], rows))
    # mean code-length differences to T* at every n
    names = ['frag-complete', 'spare-nested(T_and)', 'spare-true(0+x=x)', 'spare-false(0=1)', 'Q-lumped', 'bare?P']
    rows = []
    for i, n in enumerate(ns):
        row = [n]
        for k in names:
            vals = [r['rows'][i]['bits'][k] - r['rows'][i]['bits']['T*'] for r in results
                    if k in r['rows'][i]['bits'] and 'T*' in r['rows'][i]['bits']]
            row.append(fmt(sum(vals) / len(vals), 1) if len(vals) == len(results) else
                       ('%s (%d/%d finite)' % (fmt(sum(vals) / len(vals), 1), len(vals), len(results)) if vals else 'inf'))
        rows.append(row)
    txt.append('\n## Code length minus that of T* (bits; mean over seeds; negative = preferred to T*)\n\n')
    txt.append(md_table(['n'] + names, rows))
    # per-seed code lengths at the largest n for the main competitors
    txt.append('\n## Code lengths at n = %d (bits; -log2 prior - log2 marginal likelihood), per seed\n\n' % ns[-1])
    names = ['T*', 'frag-complete', 'frag-observed64', 'spare-nested(T_and)', 'spare-true(0+x=x)',
             'spare-false(0=1)', 'Mem']
    rows = []
    for r in results:
        b = r['rows'][-1]['bits']
        base = b.get('T*')
        rows.append([r['seed']] + [fmt(b[k] - base, 1) if k in b and base is not None else 'inf' for k in names])
    txt.append('Difference to T* (positive = worse than T*):\n\n')
    txt.append(md_table(['seed'] + names, rows))
    save(name, '\n'.join(txt), {'results': results})


def main():
    t0 = time.time()
    with Pool(4) as p:
        results = p.map(run, SEEDS, chunksize=1)
    intro = ('Command: `cd code/experiments && python3 e2_pa.py`. Seeds %s; n in %s. Generator: L0 citations '
             'from T* = Q1..Q7 + T_Ind with weights 0.05 (each Q axiom) and 0.65 (T_Ind); motives from the '
             'default Grammar (one hole, no parameter). Likelihood L0 with the same Q (well specified), '
             'Dirichlet alpha = 0.5, prior 2^-bits. Verifier view at citation depth (K = 0): '
             '"P(|-held-out Ind)" is the mean posterior mass of theories that cite each of 6 held-out '
             'induction instances; "max P(|-false)" the largest mass deriving one of 5 false probes (0=S0, Ax x+0=0, induction with a wrong base, Ax Sx=x, Ax Ay y=x).\n'
             % (SEEDS, NS))
    report('e2_pa', 'E2: unlabelled PA mixture, posterior over the pool', intro, results, NS, time.time() - t0)


if __name__ == '__main__':
    main()
