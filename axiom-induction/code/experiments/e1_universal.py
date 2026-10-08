"""E1: posterior dynamics for forall x phi(x) from data about phi.

For each phi (given as a template P = phi(?t)) and each data generator:
  sch    L0 citations of the instance schema phi(?t) (closed terms from Q);
  all    the L1 chain grammar (K=1, c_stop=0.5, elim terms closed) from H_all = {forall x phi};
  allq   the same with elim terms that may contain the parameter w0 (open instances = quantified
         theorems in closure-normal form);
  open   the L1 chain (K=1, open elim terms) from H_open = {phi(?t), ?t open} (Gen gives forall-forms);
  allq2  the L1 chain with K=2 from H_all (elim with an open term, then Gen: explicit quantified theorems
         such as forall y phi(Sy));
the posterior over the pool (hand alternatives + Min of data subsets + skeleton clusters + Mem(D_n)) is
computed under L0, under L1 (the generator's chain: well specified), and for 'sch' data also under L1sel
(the L1 chain observed only through closed quantifier-free outputs).

Reported per n: posterior mass by class, MAP theory, P(T |-_1 forall x phi | D), the mean over three
held-out closed instances of P(T |-_1 phi(t*) | D), and log2 posterior odds H_sch : H_all.
Data-derived theories whose L1 coefficients would need the brute-force fallback are left out of the
pool (listed in the json as 'excluded'); the same pool is used for L0 and L1.

Command: python3 e1_universal.py  (seeds 0-4; about 10-20 minutes on 4 cores)
"""
import math
import random
import sys
import time
from multiprocessing import Pool

from common import (save, md_table, fmt, parse, pp, Component, Theory, forall_of, min_theories,
                    skeleton_theories, classify_vs, e1_hand_pool, dedupe, has_star, num, ZERO, S)
from bai.grammar import Grammar
from bai.lik import Chain, SelChain, class_prob_qf, l1_exact_supported
from bai.gens import cite_data, chain_data
from bai.posterior import evaluate, Deriver, support_mass
from dtrc.templates import instantiate

PHIS = {'x+0=x': '?t+0=?t', '0+x=x': '0+?t=?t', '~(Sx=0)': '~S?t=0'}
GENS = ['sch', 'all', 'allq', 'open', 'allq2']
NS = [1, 2, 4, 8, 16, 32, 64, 128, 256]
SEEDS = [0, 1, 2, 3, 4]
C_STOP = 0.5
HELD = [num(9), ('+', num(2), num(3)), ('*', S(ZERO), num(4))]
CLASSES = ['H_all', 'H_sch', 'H_open', 'H_all+sch', 'mem', 'over-general', 'over-specific', 'fragmented',
           'spare', 'skeleton', 'other']


def chains(Q):
    return {'closed1': Chain(Q, Q, K=1, c_stop=C_STOP, qe_open=False),
            'open1': Chain(Q, Q, K=1, c_stop=C_STOP, qe_open=True),
            'open2': Chain(Q, Q, K=2, c_stop=C_STOP, qe_open=True)}


def make_data(P, g, n, seed, Q, ch):
    A = forall_of(P)
    if g == 'sch':
        return cite_data(Theory([Component(P)], 'g'), [1.0], Q, n, seed)
    if g == 'all':
        return chain_data(Theory([A], 'g'), [1.0], ch['closed1'], n, seed)
    if g == 'allq':
        return chain_data(Theory([A], 'g'), [1.0], ch['open1'], n, seed)
    if g == 'open':
        return chain_data(Theory([Component(P, {'t': 'open'})], 'g'), [1.0], ch['open1'], n, seed)
    if g == 'allq2':
        return chain_data(Theory([A], 'g'), [1.0], ch['open2'], n, seed)
    raise ValueError(g)


def build_pool(P, data, seed, star=True):
    pool = e1_hand_pool(P, star=star)
    rng = random.Random(1000 + seed)
    for i, T in enumerate(min_theories(data[:64], rng)):
        cls = classify_vs(T, P)
        if cls == 'H_sch':
            continue
        if not star and has_star(Theory([T], 'x')):
            continue
        pool.append(Theory([T], 'min%d:%s' % (i, pp(T)), {'cls': cls}))
    for k, temps in skeleton_theories(data[:64]):
        th = Theory(temps, 'skel%d' % k, {'cls': 'skeleton'})
        if not star and has_star(th):
            continue
        pool.append(th)
    pool = dedupe(pool)
    K = 1 if star else 2
    kept = [th for th in pool if l1_exact_supported(th, K)]
    return kept, [th.name for th in pool if not l1_exact_supported(th, K)]


def run(args):
    phi_name, g, seed = args
    t0 = time.time()
    Q = Grammar()
    ch = chains(Q)
    P = parse(PHIS[phi_name])
    data = make_data(P, g, max(NS), seed, Q, ch)
    star = g != 'allq2'
    pool, excluded = build_pool(P, data, seed, star=star)
    liks = {'L0': 'L0'}
    if g in ('sch', 'all'):
        liks['L1'] = ch['closed1']
    elif g in ('allq', 'open'):
        liks['L1'] = ch['open1']
    else:
        liks['L1'] = ch['open2']
    if g == 'sch':
        liks['L1sel'] = SelChain(ch['closed1'])
    der = Deriver(K=1, Q=Q)
    A = forall_of(P)
    held = [instantiate(P, {'t': t}) for t in HELD]
    out = {'phi': phi_name, 'gen': g, 'seed': seed, 'n_pool': len(pool) + 1, 'liks': {}, 'excluded': excluded}
    for lname, lik in liks.items():
        pl = pool
        if lname == 'L1sel':
            pl = []
            for th in pool:
                try:
                    for c in th.comps:
                        class_prob_qf(c, ch['closed1'])
                    pl.append(th)
                except ValueError:
                    pass
        res_all = evaluate(pl, data, NS, lik, Q=Q, alpha=0.5)
        rows = []
        for n, res in zip(NS, res_all):
            cls_mass = {c: 0.0 for c in CLASSES}
            for th in pl:
                cls_mass[th.tags.get('cls', 'other')] += res[th.name]['post']
            cls_mass['mem'] += res['Mem']['post']
            mp = max(res, key=lambda k: res[k]['post'])
            pf = support_mass(res, pl, der, A)
            pi = sum(support_mass(res, pl, der, h) for h in held) / len(held)

            def lo(a, b):
                if a in res and b in res:
                    x, y = res[a]['lp'] + res[a]['lm'], res[b]['lp'] + res[b]['lm']
                    if x == -math.inf and y == -math.inf:
                        return None
                    if x == -math.inf:
                        return -math.inf
                    if y == -math.inf:
                        return math.inf
                    return (x - y) / math.log(2)
                return None
            bnd = res.get('_bounded')
            rows.append({'n': n, 'mass': cls_mass, 'map': mp, 'map_post': res[mp]['post'], 'P_forall': pf,
                         'bounded': (bnd['names'], bnd['max_post']) if bnd else None,
                         'P_inst': pi, 'lo_sch_all': lo('H_sch', 'H_all'), 'lo_open_all': lo('H_open', 'H_all'),
                         'post': {k: v['post'] for k, v in res.items() if v['post'] > 1e-6}})
        out['liks'][lname] = {'pool_size': len(pl) + 1, 'rows': rows}
    out['inexact'] = {k: getattr(v, 'inexact', 0) for k, v in ch.items()}
    out['data_head'] = [pp(d) for d in data[:12]]
    out['frac_forall_data'] = sum(1 for d in data if d[0] == 'all') / len(data)
    out['frac_param_data'] = sum(1 for d in data if 'w0' in str(d)) / len(data)
    out['time'] = round(time.time() - t0, 1)
    return out


def main():
    jobs = [(p, g, s) for p in PHIS for g in GENS for s in SEEDS]
    if len(sys.argv) > 1 and sys.argv[1] == 'quick':
        jobs = [(p, g, 0) for p in ['x+0=x'] for g in GENS]
    t0 = time.time()
    with Pool(4) as pool:
        results = pool.map(run, jobs, chunksize=1)
    report(results, time.time() - t0)


def report(results, wall):
    txt = ['# E1: forall x phi from data about phi\n']
    txt.append('Command: `cd code/experiments && python3 e1_universal.py`. Seeds %s. n in %s. '
               'Q = default Grammar (bai/grammar.py); L1 chain: c_stop = %.1f, c_elim = c_gen = c_mp = 1; '
               'Dirichlet alpha = 0.5; prior 2^-bits (TemplateCode), lambda = 1, no time factor. '
               'Wall time %.0f s.\n' % (SEEDS, NS, C_STOP, wall))
    txt.append('Generators: sch = L0 citations of phi(?t) (closed terms); all = L1 chain (K=1) from '
               '{forall x phi}, closed elim terms; allq = the same with open elim terms; open = L1 chain (K=1) '
               'from {phi(?t) open}; allq2 = L1 chain with K=2 from {forall x phi}, open elim terms. '
               'The L1 likelihood is the generator\'s own chain (well specified); for allq2 the pool has no '
               'bare formula metavariables (K=2 is only computed exactly without them). '
               'L1sel (sch data only) is the closed-elim K=1 chain observed through closed quantifier-free '
               'outputs; its pool is restricted to theories whose class probability is computed exactly '
               '(bai.lik.class_prob_qf).\n')
    txt.append('Columns: posterior mass of H_all = {forall x phi}, H_sch = {phi(?t) closed}, H_open = '
               '{phi(?t) open}, H_all+sch, Mem(D_n), over-general, over-specific and fragmented theories '
               '(summed over the pool); P(|-forall) = posterior mass of theories T with T |-_1 forall x phi '
               '(chain derivations of length <= 1); P(|-inst) = the same for held-out closed instances '
               '(mean over 3); lo = log2 posterior odds H_sch : H_all. Means over seeds.\n')
    summary = {}
    for phi in PHIS:
        for g in GENS:
            rs = [r for r in results if r['phi'] == phi and r['gen'] == g]
            if not rs:
                continue
            txt.append('\n## phi = %s, generator %s\n' % (phi, g))
            txt.append('Pool size (incl. Mem) %s (data-derived theories left out for lack of exact L1: %s); '
                       'fraction of data with explicit forall: %.2f; with the '
                       'parameter: %.2f; L1 inexact counters %s.\n' % (
                           rs[0]['liks']['L0']['pool_size'], sum(len(r['excluded']) for r in rs),
                           sum(r['frac_forall_data'] for r in rs) / len(rs),
                           sum(r['frac_param_data'] for r in rs) / len(rs),
                           [r['inexact'] for r in rs][0]))
            for lname in rs[0]['liks']:
                bmax = max([r['liks'][lname]['rows'][i]['bounded'][1] for r in rs
                            for i in range(len(NS)) if r['liks'][lname]['rows'][i]['bounded']] or [0.0])
                bnames = sorted(set(x for r in rs for row in r['liks'][lname]['rows'] if row['bounded']
                                    for x in row['bounded'][0]))
                rows = []
                for i, n in enumerate(NS):
                    def m(c):
                        return sum(r['liks'][lname]['rows'][i]['mass'][c] for r in rs) / len(rs)
                    pf = sum(r['liks'][lname]['rows'][i]['P_forall'] for r in rs) / len(rs)
                    pi = sum(r['liks'][lname]['rows'][i]['P_inst'] for r in rs) / len(rs)
                    los = [r['liks'][lname]['rows'][i]['lo_sch_all'] for r in rs]
                    los = [x for x in los if x is not None]
                    if los and all(abs(x) != math.inf for x in los):
                        lo = fmt(sum(los) / len(los), 1)
                    elif los:
                        lo = 'inf' if all(x == math.inf for x in los) else ('-inf' if all(x == -math.inf for x in los) else 'mixed')
                    else:
                        lo = '-'
                    maps = sorted(set(r['liks'][lname]['rows'][i]['map'] for r in rs))
                    rows.append([n, fmt(m('H_all')), fmt(m('H_sch')), fmt(m('H_open')), fmt(m('H_all+sch')),
                                 fmt(m('mem')), fmt(m('over-general')), fmt(m('over-specific')),
                                 fmt(m('fragmented') + m('skeleton') + m('spare') + m('other')), fmt(pf), fmt(pi), lo,
                                 ', '.join(x[:24] for x in maps[:3])])
                txt.append('\n**%s**%s\n\n' % (lname, '' if not bnames else
                           ' (exact Dirichlet DP too large for %s: marginal bounded; the largest posterior mass '
                           'these could have at any n is %s)' % (', '.join(bnames), fmt(bmax))))
                txt.append(md_table(['n', 'H_all', 'H_sch', 'H_open', 'H_all+sch', 'Mem', 'over-gen', 'over-spec',
                                     'frag/skel/spare/other', 'P(|-forall)', 'P(|-inst)', 'lo sch:all', 'MAP'], rows))
                summary['%s|%s|%s' % (phi, g, lname)] = rows[-1]
    save('e1_universal', '\n'.join(txt), {'results': results, 'summary': summary})


if __name__ == '__main__':
    main()
