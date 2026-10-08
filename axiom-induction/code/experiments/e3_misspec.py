"""E3: misspecification.  The data generator differs from every model in the pool, but all data are
theorems of the target (instances of phi(?t), or Q axioms and induction instances).

(a) phi = x+0=x; model Q = default Grammar; likelihoods L0 and L1 (closed elim, K = 1).  Generators:
    heavy     terms with heavy-tailed sizes: a zeta(1.5) numeral (k <= 400) w.p. 0.7, else S^k(t1 o t2)
              with zeta k and Q-terms t1, t2;
    numerals  numerals only, k ~ Geometric(0.2) (a different instantiation grammar);
    small     Q-terms selected to have at most 4 symbols (selected theorems);
    skewQ     a different PCFG: weights 0: .5, S: .1, +: .2, *: .2.
    Pool: the E1 hand pool, numeral splits N_m = {phi(S^j 0): j < m} + {phi(S^m ?z)} (m = 1..4),
    Min of data subsets, skeleton clusters, Mem(D_n).  Theories are tagged by their instance set relative
    to inst(phi(?t)): same, subset (incomplete), superset (adds instances), or forall-type.
(b) PA mixture, L0; same weights as E2.  Generators: dtrc-motive (motives from the dtrc pa_motive
    generator, no parameters), root-skew (motive root drawn from {imp .5, and .2, = .2, ex .1}, the rest
    from Q), deep (a PCFG with more connectives).  Pool: the E2 pool plus T* + T_f for every root f
    (nested fragments: deductively equivalent to T*).

Command: python3 e3_misspec.py
"""
import math
import random
import time
from multiprocessing import Pool

from common import (save, md_table, fmt, parse, pp, Component, Theory, num, ZERO, S, e1_hand_pool, dedupe,
                    min_theories, skeleton_theories, classify_vs)
from bai.grammar import Grammar, LN2
from bai.lik import Chain, l1_exact_supported
from bai.gens import heavy_term, schema_data_with_terms, cite_sample
from bai.posterior import evaluate, Deriver, support_mass
from bai.pool import specialise
from dtrc.templates import instantiate
from dtrc.syntax import canon_params, size

SEEDS = [0, 1, 2, 3, 4]
P = parse('?t+0=?t')
HELD = [num(9), ('+', num(2), num(3)), ('*', S(ZERO), num(4))]


# ------------------------------------------------------------------------------------ (a)
def term_gen(name):
    Q = Grammar()
    if name == 'heavy':
        return lambda r: heavy_term(r)
    if name == 'numerals':
        def f(r):
            k = 0
            while r.random() < 0.8:
                k += 1
            return num(k)
        return f
    if name == 'small':
        def f(r):
            while True:
                t = Q.sample_term(r)
                if size(t) <= 4:
                    return t
        return f
    if name == 'skewQ':
        Q2 = Grammar(term_w={'0': 0.5, 'S': 0.1, '+': 0.2, '*': 0.2})
        return lambda r: Q2.sample_term(r)
    raise ValueError(name)


def inst_rel(th):
    cls = th.tags.get('cls')
    name = th.name
    if name in ('H_sch', 'frag1', 'frag2', 'spare_nested'):
        return 'same'
    if name in ('H_open', 'spare_false', 'spare_schema') or cls == 'over-general':
        return 'superset'
    if name.startswith('H_all'):
        return 'forall'
    if cls == 'over-specific' or name.startswith('N_'):
        return 'subset'
    return th.tags.get('rel', 'other')


def pool_a(data, seed):
    pool = e1_hand_pool(P)
    for m in range(1, 5):
        temps = [instantiate(P, {'t': num(j)}) for j in range(m)]
        pat = ('M', 'z', ())
        for _ in range(m):
            pat = ('S', pat)
        temps.append(specialise(P, 't', pat))
        pool.append(Theory(temps, 'N_%d' % m, {'cls': 'over-specific'}))
    rng = random.Random(77 + seed)
    for i, T in enumerate(min_theories(data[:64], rng)):
        cls = classify_vs(T, P)
        if cls == 'H_sch':
            continue
        th = Theory([T], 'min%d:%s' % (i, pp(T)), {'cls': cls})
        th.tags['rel'] = {'over-general': 'superset', 'over-specific': 'subset'}.get(cls, 'other')
        pool.append(th)
    for k, temps in skeleton_theories(data[:64]):
        pool.append(Theory(temps, 'skel%d' % k, {'cls': 'skeleton', 'rel': 'other'}))
    pool = dedupe(pool)
    return [th for th in pool if l1_exact_supported(th, 1)]


def run_a(args):
    gname, lname, seed, ns = args
    t0 = time.time()
    Q = Grammar()
    data = schema_data_with_terms(P, term_gen(gname), max(ns), seed)
    pool = pool_a(data, seed)
    lik = 'L0' if lname == 'L0' else Chain(Q, Q, K=1, c_stop=0.5, qe_open=False)
    res_all = evaluate(pool, data, ns, lik, Q=Q, alpha=0.5)
    der = Deriver(K=1, Q=Q)
    A = parse('forall x. x+0=x')
    held = [instantiate(P, {'t': t}) for t in HELD]
    rows = []
    for n, res in zip(ns, res_all):
        rel = {}
        for th in pool:
            k = inst_rel(th)
            rel[k] = rel.get(k, 0.0) + res[th.name]['post']
        rel['mem'] = res['Mem']['post']
        mp = max(res, key=lambda k: res[k]['post'])
        b = {k: -(v['lp'] + v['lm']) / LN2 for k, v in res.items() if v['lm'] > -1e300}
        rows.append({'n': n, 'H_sch': res['H_sch']['post'], 'rel': rel, 'map': mp, 'map_post': res[mp]['post'],
                     'P_forall': support_mass(res, pool, der, A),
                     'P_inst': sum(support_mass(res, pool, der, h) for h in held) / len(held),
                     'gain_map_vs_sch_bits': (b['H_sch'] - b[mp]) if 'H_sch' in b and mp in b else None})
    return {'gen': gname, 'lik': lname, 'seed': seed, 'rows': rows, 'time': round(time.time() - t0, 1),
            'data_head': [pp(d)[:60] for d in data[:6]]}


# ------------------------------------------------------------------------------------ (b)
def pa_gen(name):
    from pa_common import t_star, W_TRUE, QSENT
    from dtrc.schemas import T_IND
    from dtrc.datasets import pa_motive
    Q = Grammar()
    if name == 'deep':
        Qm = Grammar(form_w={'=': .3, '<': .15, 'not': .1, 'and': .12, 'or': .08, 'imp': .12, 'iff': .03,
                             'all': .05, 'ex': .05})
    else:
        Qm = Q

    def motive(rng):
        if name == 'dtrc-motive':
            return pa_motive(rng, p_param=0.0)
        if name == 'root-skew':
            r = rng.random()
            f = 'imp' if r < .5 else ('and' if r < .7 else ('=' if r < .9 else 'ex'))
            if f == '=':
                return ('=', Q.sample_term(rng, 1, 0, False), Q.sample_term(rng, 1, 0, False))
            if f == 'ex':
                return ('ex', Q.sample_form(rng, 1, 1, False))
            return (f, Q.sample_form(rng, 1, 0, False), Q.sample_form(rng, 1, 0, False))
        return Qm.sample_form(rng, 1, 0, False)

    def gen(seed, n):
        rng = random.Random(seed)
        out = []
        for _ in range(n):
            r = rng.random() * sum(W_TRUE)
            if r < 0.35:
                out.append(QSENT[min(int(r / 0.05), 6)])
            else:
                out.append(canon_params(instantiate(T_IND, {'P': motive(rng)})))
        return out
    return gen


def run_b(args):
    gname, seed, ns = args
    t0 = time.time()
    from pa_common import build_pa_pool, ROOTS, T_frag, QSENT
    from dtrc.schemas import T_IND
    import e2_pa
    Q = Grammar()
    data = pa_gen(gname)(seed, max(ns))
    pool = build_pa_pool(data, seed)
    for f in ROOTS:
        pool.append(Theory(QSENT + [T_IND, T_frag(f)], 'T*+T_%s' % f,
                           {'cls': 'spare', 'equiv': 'yes', 'sound': True}))
    pool = dedupe(pool)
    res_all = evaluate(pool, data, ns, 'L0', Q=Q, alpha=0.5)
    der = Deriver(K=0, Q=Q)
    rows = e2_pa.summarise(pool, res_all, ns, Q, seed, der)
    return {'gen': gname, 'seed': seed, 'rows': rows, 'time': round(time.time() - t0, 1),
            'roots': {}, 'pool': [(th.name, th.tags.get('cls'), th.tags.get('equiv'), th.tags.get('sound'),
                                   round(th.bits(), 1), len(th.comps)) for th in pool],
            'first_seen': e2_pa.first_seen(data)}


def main():
    t0 = time.time()
    NS_A = [8, 32, 128, 512, 1024]
    jobs_a = [(g, l, s, NS_A if l == 'L0' else NS_A[:-1]) for g in ['heavy', 'numerals', 'small', 'skewQ']
              for l in ['L0', 'L1'] for s in SEEDS]
    NS_B = [16, 64, 256, 1024, 2048]
    jobs_b = [(g, s, NS_B) for g in ['dtrc-motive', 'root-skew', 'deep'] for s in SEEDS]
    with Pool(4) as p:
        ra = p.map(run_a, jobs_a, chunksize=1)
        rb = p.map(run_b, jobs_b, chunksize=1)
    txt = ['# E3: misspecification\n',
           'Command: `cd code/experiments && python3 e3_misspec.py`. Seeds %s. Dirichlet alpha = 0.5; prior '
           '2^-bits; derivability |-_1 (part a), citation |-_0 (part b). Wall time %.0f s.\n' % (SEEDS, time.time() - t0)]
    txt.append('\n## (a) phi = x+0=x, data = instances with a misspecified term law\n\n'
               'Columns: posterior mass of H_sch, of theories with the same instance set as phi(?t) (H_sch, frag1, '
               'frag2, spare_nested), of subset theories (incomplete: overspec, N_m, over-specific Min), of superset '
               'theories (over-general, spare_false, spare_schema, H_open), of forall-type theories (H_all, '
               'H_all+sch, H_all+open), of Mem; P(|-inst) = mean mass deriving 3 held-out closed instances; '
               '"gain" = code length of H_sch minus that of the MAP (bits).\n')
    for g in ['heavy', 'numerals', 'small', 'skewQ']:
        for l in ['L0', 'L1']:
            rs = [r for r in ra if r['gen'] == g and r['lik'] == l]
            ns = [x['n'] for x in rs[0]['rows']]
            rows = []
            for i, n in enumerate(ns):
                def m(f):
                    return sum(f(r['rows'][i]) for r in rs) / len(rs)
                maps = {}
                for r in rs:
                    maps[r['rows'][i]['map']] = maps.get(r['rows'][i]['map'], 0) + 1
                gains = [r['rows'][i]['gain_map_vs_sch_bits'] for r in rs if r['rows'][i]['gain_map_vs_sch_bits'] is not None]
                rows.append([n, fmt(m(lambda x: x['H_sch'])), fmt(m(lambda x: x['rel'].get('same', 0))),
                             fmt(m(lambda x: x['rel'].get('subset', 0))), fmt(m(lambda x: x['rel'].get('superset', 0))),
                             fmt(m(lambda x: x['rel'].get('forall', 0))), fmt(m(lambda x: x['rel'].get('mem', 0))),
                             fmt(m(lambda x: x['rel'].get('other', 0))),
                             fmt(m(lambda x: x['P_inst'])), fmt(m(lambda x: x['P_forall'])),
                             fmt(sum(gains) / len(gains), 1) if gains else '-',
                             '; '.join('%s x%d' % (k[:20], v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:3])])
            txt.append('\n### generator %s, %s (data: %s ...)\n\n' % (g, l, ', '.join(rs[0]['data_head'][:3])))
            txt.append(md_table(['n', 'H_sch', 'same inst.', 'subset', 'superset', 'forall-type', 'Mem', 'other',
                                 'P(|-inst)', 'P(|-forall)', 'gain (bits)', 'MAP (count)'], rows))
    txt.append('\n## (b) PA mixture with a misspecified motive law (L0)\n\n'
               'Columns as in E2; "spare" includes the nested fragments T* + T_f (deductively equivalent to T*).\n')
    for g in ['dtrc-motive', 'root-skew', 'deep']:
        rs = [r for r in rb if r['gen'] == g]
        ns = [x['n'] for x in rs[0]['rows']]
        rows = []
        for i, n in enumerate(ns):
            def m(f):
                return sum(f(r['rows'][i]) for r in rs) / len(rs)
            maps = {}
            for r in rs:
                maps[r['rows'][i]['map']] = maps.get(r['rows'][i]['map'], 0) + 1
            rows.append([n, fmt(m(lambda x: x['T*'])), fmt(m(lambda x: x['equiv'])),
                         fmt(m(lambda x: x['mass']['fragmented'])), fmt(m(lambda x: x['mass']['spare'])),
                         fmt(m(lambda x: x['mass']['over-general'])), fmt(m(lambda x: x['mass']['over-specific'])),
                         fmt(m(lambda x: x['mass']['sub-T*'])),
                         fmt(m(lambda x: x['mass']['mem'])), fmt(m(lambda x: x['unsound'])),
                         fmt(m(lambda x: x['P_inst'])), fmt(m(lambda x: x['P_false_max'])),
                         '; '.join('%s x%d' % (k[:22], v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:3])])
        txt.append('\n### generator %s\n\n' % g)
        txt.append(md_table(['n', 'T*', 'equiv. to T*', 'fragmented', 'spare (incl. T*+T_f)', 'over-general',
                             'over-specific', 'sub-T*', 'Mem', 'unsound', 'P(|-held-out Ind)', 'max P(|-false)',
                             'MAP (count)'], rows))
        # code lengths at the largest n relative to T*
        names = ['frag-complete', 'T*+T_imp', 'T*+T_and', 'T*+T_=', 'Mem']
        brow = []
        for r in rs:
            b = r['rows'][-1]['bits']
            brow.append([r['seed']] + [fmt(b[k] - b['T*'], 1) if k in b and 'T*' in b else 'inf' for k in names])
        txt.append('\nCode length minus that of T* at n = %d (bits; negative = preferred to T*):\n\n' % ns[-1])
        txt.append(md_table(['seed'] + names, brow))
    save('e3_misspec', '\n'.join(txt), {'a': ra, 'b': rb})


if __name__ == '__main__':
    main()
