"""E2: unlabelled PA mixture (Q's 7 axioms + induction instances) under the citation likelihood L0.

Generator (well specified): component i ~ w with w = 0.05 for each Q axiom and 0.65 for T_Ind (fixed
weights); induction motives from the default Grammar Q (formula with one hole, no parameter).

Pool at n (causal; revised after the referee, M1): the fixed hand theories (T*, frag-complete, frag-atoms,
T* - Q_i, spare slots, IndSwap, over-general induction variants, bare ?P, Q-lumped), plus the data-derived
theories built from D_b for every build point b in {8, 16, 32, 64} with b <= n (frag-observed@b, skeleton
clusters, DTRC with refutation, Q + Min of random data subsets), plus Trim(T, D_n) for every pool theory T
(the components that some datum of D_n cites; Trim(T*, D_n) is the referee's SeenQ(D_n)), plus Mem(D_n).
Every member uses only data already seen.  Posterior by exact enumeration over the pool, Dirichlet(0.5).

For comparison the pre-referee ("legacy") pool is also evaluated at n <= 64: its data-derived members are
built from the first 16, 40 and 64 data, and it has no trimmed theories.

Reported: posterior mass on T*, on theories tagged deductively equivalent to T*, strictly weaker (sound),
unsound, unknown (pa_common.pa_classify), the MAP, and the verifier view at citation depth (K = 0): mass
deriving held-out induction instances (drawn outside the training stream) and false probe sentences; the
number of seeds in which a delta = 0.05 verifier accepts a false probe.

Command: python3 e2_pa.py   (seeds 0-24)
"""
import time
from multiprocessing import Pool

from common import save, md_table, fmt, pp, Theory
from pa_common import (build_pa_pool, causal_pa_pool, t_star, W_TRUE, pa_heldout, ROOTS, motive_root, QSENT,
                       pa_classify)
from bai.grammar import Grammar
from bai.gens import cite_data
from bai.posterior import evaluate, Deriver, support_mass

NS = [8, 16, 32, 64, 128, 256, 512]
NS_LEGACY = [8, 16, 32, 64]
SEEDS = list(range(25))
EQ = ['yes', 'weaker', 'no', 'unknown']
BITS_NAMES = ['T*', 'frag-complete', 'spare-nested(T_and)', 'spare-true(0+x=x)', 'spare-false(0=1)', 'Q-lumped',
              'bare?P', 'Ind-any-base', 'Ind-any-antecedent', 'Mem']
DELTA = 0.05


def tag_of(name, v):
    if name == 'Mem':
        return 'weaker'          # Q axioms + finitely many induction instances: inside some I-Sigma_k
    return v['theory'].tags.get('equiv', 'unknown')


def summarise(res_all, ns, Q, seed, der, data):
    inst, false = pa_heldout(Q, seed, exclude=data)
    rows = []
    for n, res in zip(ns, res_all):
        names = [k for k in res if not k.startswith('_')]
        eq = {e: 0.0 for e in EQ}
        cls = {}
        for k in names:
            v = res[k]
            eq[tag_of(k, v)] += v['post']
            c = 'mem' if k == 'Mem' else v['theory'].tags.get('cls', 'other')
            cls[c] = cls.get(c, 0.0) + v['post']
        mp = max(names, key=lambda k: res[k]['post'])
        pi = sum(support_mass(res, [], der, s) for s in inst) / len(inst)
        pfs = [support_mass(res, [], der, s) for s in false]
        pf = max(pfs)
        bits = {k: -(res[k]['lp'] + res[k]['lm']) / 0.6931471805599453 for k in names
                if res[k]['lm'] > -1e300 and (k in BITS_NAMES or k.startswith('T*+T_') or k.startswith('frag')
                                                    or k.startswith('trim:frag'))}
        # SeenQ(D_n) = Trim(T*, D_n) (the referee's competitor): under which name it is in the pool, its mass
        tstar = res['T*']['theory']
        used = [c for c in tstar.comps if any(c.logcoef0(d, Q) != float('-inf') for d in data[:n])]
        skey = frozenset(c.key for c in used)
        sname = next((k for k in names if res[k]['theory'].key == skey), None)
        seenq = {'name': sname, 'post': res[sname]['post'] if sname else 0.0,
                 'bits_minus_lump': ((res[sname]['lp'] + res[sname]['lm'] - res['Q-lumped']['lp'] - res['Q-lumped']['lm'])
                                     / -0.6931471805599453 if sname and 'Q-lumped' in res else None),
                 'n_Q_seen': sum(1 for c in used if c.T in QSENT)}
        rows.append({'n': n, 'T*': res['T*']['post'], 'eq': eq, 'cls': cls, 'map': mp, 'seenq': seenq,
                     'map_tag': tag_of(mp, res[mp]), 'map_post': res[mp]['post'], 'P_inst': pi,
                     'P_false_max': pf, 'false_accepted': [pp(false[i]) for i, x in enumerate(pfs) if x >= 1 - DELTA],
                     'pool_size': len(names),
                     'post': {k: res[k]['post'] for k in names if res[k]['post'] > 1e-6},
                     'bits': bits,
                     'bounded': res['_bounded']['max_post'] if '_bounded' in res else 0.0})
    return rows


def first_seen(data):
    """index (1-based) of the first datum of each Q axiom and the first induction instance"""
    out = {}
    for j, d in enumerate(data):
        for i, q in enumerate(QSENT):
            if d == q and 'Q%d' % (i + 1) not in out:
                out['Q%d' % (i + 1)] = j + 1
        if motive_root(d) and 'Ind' not in out:
            out['Ind'] = j + 1
    return out


def run(seed, gen=None, ns=NS, extra_fixed=(), legacy=True, lam=1.0, tau=0.0):
    t0 = time.time()
    Q = Grammar()
    data = gen(seed) if gen else cite_data(t_star(), W_TRUE, Q, max(ns), seed)
    cpool = causal_pa_pool(data, seed, extra_fixed=extra_fixed)
    res_all = evaluate(cpool, data, ns, 'L0', Q=Q, alpha=0.5, trim=True, tagger=pa_classify, lam=lam, tau=tau)
    der = Deriver(K=0, Q=Q)
    rows = summarise(res_all, ns, Q, seed, der, data)
    out = {'seed': seed, 'rows': rows, 'first_seen': first_seen(data), 'time': None}
    if legacy:
        nl = [n for n in ns if n <= 64]
        lpool = build_pa_pool(data, seed)
        lres = evaluate(lpool, data, nl, 'L0', Q=Q, alpha=0.5, lam=lam, tau=tau)
        out['legacy'] = summarise(lres, nl, Q, seed, der, data)
    roots = {}
    for d in data:
        r = motive_root(d)
        if r:
            roots[r] = roots.get(r, 0) + 1
    out['roots'] = roots
    out['pool_example'] = [(th.name, th.tags.get('cls'), th.tags.get('equiv'), th.tags.get('sound'),
                            round(th.bits(), 1), len(th.comps)) for th in cpool(max(ns))]
    out['time'] = round(time.time() - t0, 1)
    return out


def accept_table(results, ns, key='rows'):
    """per n: number of seeds in which a delta = 0.05 verifier accepts some false probe"""
    out = []
    for i, n in enumerate(ns):
        k = sum(1 for r in results if r[key][i]['P_false_max'] >= 1 - DELTA)
        out.append(k)
    return out


def report(name, title, intro, results, ns, wall, legacy=True):
    S = len(results)
    txt = ['# %s\n' % title, intro, 'Wall time %.0f s.\n' % wall]
    txt.append('\n## Pool at the largest n (seed %d; trimmed theories and Mem(D_n) are added at each n)\n' %
               results[0]['seed'])
    txt.append(md_table(['theory', 'class', 'equivalent to T*', 'sound', 'bits', 'components'],
                        [list(x) for x in results[0]['pool_example']]))
    txt.append('\nMotive roots in the data (seed %d, all n): %s\n' % (results[0]['seed'], results[0]['roots']))
    txt.append('\nFirst occurrence (datum index) of each axiom, seeds 0-4: %s\n' % '; '.join(
        'seed %d: %s' % (r['seed'], r['first_seen']) for r in results[:5]))
    rows = []
    for i, n in enumerate(ns):
        def m(f):
            return sum(f(r['rows'][i]) for r in results) / S
        maps = {}
        for r in results:
            k = '%s [%s]' % (r['rows'][i]['map'][:22], r['rows'][i]['map_tag'])
            maps[k] = maps.get(k, 0) + 1
        rows.append([n, fmt(m(lambda x: x['T*'])), fmt(m(lambda x: x['eq']['yes'])), fmt(m(lambda x: x['eq']['weaker'])),
                     fmt(m(lambda x: x['eq']['no'])), fmt(m(lambda x: x['eq']['unknown'])),
                     fmt(m(lambda x: x['cls'].get('mem', 0.0))),
                     fmt(m(lambda x: x['P_inst'])), fmt(m(lambda x: x['P_false_max'])),
                     '%d/%d' % (sum(1 for r in results if r['rows'][i]['P_false_max'] >= 1 - DELTA), S),
                     '; '.join('%s x%d' % (k, v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:4])])
    txt.append('\n## Posterior mass (means over %d seeds), causal pool\n\n' % S)
    txt.append('Columns: T*; tagged deductively equivalent to T* (incl. T*); sound and strictly weaker; unsound; '
               'unknown; Mem(D_n); mean mass citing a held-out induction instance; mean of the largest mass citing a '
               'false probe; seeds in which a delta = 0.05 verifier accepts a false probe; MAP [tag] (count).\n\n')
    txt.append(md_table(['n', 'T*', 'equiv.', 'weaker', 'unsound', 'unknown', 'Mem', 'P(|-held-out Ind)',
                         'max P(|-false)', 'accepting seeds', 'MAP (count)'], rows))
    rows = []
    for i, n in enumerate(ns):
        sq = [r['rows'][i]['seenq'] for r in results]
        d = [x['bits_minus_lump'] for x in sq if x['bits_minus_lump'] is not None]
        nm = {}
        for x in sq:
            nm[x['name']] = nm.get(x['name'], 0) + 1
        rows.append([n, fmt(sum(x['n_Q_seen'] for x in sq) / S, 2), fmt(sum(x['post'] for x in sq) / S),
                     ('%s (%s to %s)' % (fmt(sum(d) / len(d), 1), fmt(min(d), 1), fmt(max(d), 1))) if d else '-',
                     '; '.join('%s x%d' % (k, v) for k, v in sorted(nm.items(), key=lambda kv: -kv[1])[:4])])
    txt.append('\n## SeenQ(D_n) = Trim(T*, D_n): the Q axioms cited in D_n plus T_Ind\n\nColumns: mean number of '
               'Q axioms seen; mean posterior of SeenQ; code length of SeenQ minus that of Q-lumped (bits; negative = '
               'SeenQ preferred; mean and range over seeds); the name under which SeenQ is in the pool (a data-derived '
               'or hand theory with the same components keeps its own name).\n\n')
    txt.append(md_table(['n', 'Q axioms seen', 'posterior of SeenQ', 'SeenQ - Q-lumped (bits)', 'name in the pool (count)'],
                        rows))
    if legacy and 'legacy' in results[0]:
        nl = [x['n'] for x in results[0]['legacy']]
        rows = []
        for i, n in enumerate(nl):
            rows.append([n, '%d/%d' % (sum(1 for r in results if r['legacy'][i]['P_false_max'] >= 1 - DELTA), S),
                         '%d/%d' % (sum(1 for r in results if r['rows'][i]['P_false_max'] >= 1 - DELTA), S),
                         fmt(sum(r['legacy'][i]['eq']['no'] for r in results) / S),
                         fmt(sum(r['rows'][i]['eq']['no'] for r in results) / S),
                         '%d/%d' % (sum(1 for r in results if r['legacy'][i]['map_tag'] == 'no'), S),
                         '%d/%d' % (sum(1 for r in results if r['rows'][i]['map_tag'] == 'no'), S)])
        anyl = sum(1 for r in results if any(x['P_false_max'] >= 1 - DELTA for x in r['legacy']))
        anyc = sum(1 for r in results if any(x['P_false_max'] >= 1 - DELTA for x in r['rows'][:len(nl)]))
        rows.append(['some n <= 64', '%d/%d' % (anyl, S), '%d/%d' % (anyc, S), '', '', '', ''])
        txt.append('\n## Legacy pool (data-derived theories from the first 16, 40, 64 data; no trimmed theories) '
                   'against the causal pool\n\n')
        txt.append(md_table(['n', 'accepting seeds, legacy', 'accepting seeds, causal', 'unsound mass, legacy (mean)',
                             'unsound mass, causal (mean)', 'unsound MAP, legacy', 'unsound MAP, causal'], rows))
        sub = [r for r in results if r['seed'] < 5]
        if sub:
            txt.append('\nSeeds 0-4 only: accepting at some n <= 64: legacy %s, causal %s.\n' % (
                [r['seed'] for r in sub if any(x['P_false_max'] >= 1 - DELTA for x in r['legacy'])],
                [r['seed'] for r in sub if any(x['P_false_max'] >= 1 - DELTA for x in r['rows'][:len(nl)])]))
    # per-seed detail where a false probe is accepted
    txt.append('\n## Seeds and n at which a delta = 0.05 verifier accepts a false probe (causal pool)\n\n')
    det = []
    for r in results:
        for x in r['rows']:
            if x['P_false_max'] >= 1 - DELTA:
                det.append([r['seed'], x['n'], x['map'][:30], fmt(x['map_post']), ', '.join(x['false_accepted'])[:80]])
    txt.append(md_table(['seed', 'n', 'MAP', 'its mass', 'accepted false probes'], det) if det else 'none\n')
    # code-length differences to T*
    rows = []
    for i, n in enumerate(ns):
        row = [n]
        for k in BITS_NAMES[1:]:
            vals = [r['rows'][i]['bits'][k] - r['rows'][i]['bits']['T*'] for r in results
                    if k in r['rows'][i]['bits'] and 'T*' in r['rows'][i]['bits']]
            row.append(fmt(sum(vals) / len(vals), 1) + ('' if len(vals) == S else ' (%d/%d)' % (len(vals), S))
                       if vals else 'inf')
        rows.append(row)
    txt.append('\n## Code length minus that of T* (bits; mean over the seeds where both are finite; negative = '
               'preferred to T*)\n\n')
    txt.append(md_table(['n'] + BITS_NAMES[1:], rows))
    save(name, '\n'.join(txt), {'results': results})


def main():
    t0 = time.time()
    with Pool(4) as p:
        results = p.map(run, SEEDS, chunksize=1)
    intro = ('Command: `cd code/experiments && python3 e2_pa.py`. Seeds %d-%d; n in %s. Generator: L0 citations '
             'from T* = Q1..Q7 + T_Ind with fixed weights 0.05 (each Q axiom) and 0.65 (T_Ind); motives from the '
             'default Grammar (one hole, no parameter). Likelihood L0 with the same Q (well specified), '
             'Dirichlet alpha = 0.5, prior 2^-bits. Causal pool (build points 8, 16, 32, 64) with Trim(T, D_n) '
             'and Mem(D_n). Verifier view at citation depth (K = 0): "P(|-held-out Ind)" is the mean posterior '
             'mass of theories that cite each of 6 held-out induction instances (not in the training stream); '
             '"max P(|-false)" the largest mass deriving one of 5 false probes (0=S0, Ax x+0=0, induction with a '
             'wrong base, Ax Sx=x, Ax Ay y=x).\n' % (SEEDS[0], SEEDS[-1], NS))
    report('e2_pa', 'E2: unlabelled PA mixture, posterior over the pool', intro, results, NS, time.time() - t0)


if __name__ == '__main__':
    main()
