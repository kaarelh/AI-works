"""E3: misspecification.  The data generator differs from every model in the pool, but all data are
theorems of the target (instances of phi(?t), or Q axioms and induction instances).

(a) phi = x+0=x; model Q = default Grammar; likelihoods L0 and L1 (closed elim, K = 1).  Generators:
    heavy     terms with heavy-tailed sizes: a zeta(1.5) numeral (k <= 400) w.p. 0.7, else S^k(t1 o t2)
              with zeta k and Q-terms t1, t2;
    numerals  numerals only, k ~ Geometric(0.2) (a different instantiation grammar);
    small     Q-terms selected to have at most 4 symbols (selected theorems);
    skewQ     a different PCFG: weights 0: .5, S: .1, +: .2, *: .2.
    Pool: the E1 hand pool, numeral splits N_m = {phi(S^j 0): j < m} + {phi(S^m ?z)} (m = 1..16; after the
    referee, m12, the family is extended until the MAP is interior), the nested chains C_1 = {phi(?t),
    phi(S?z)} (= spare_nested) and C_2 = {phi(?t), phi(S?z), phi(SS?z)} (C_3 and beyond need more than three
    overlapping components, beyond the exact dense DP), Min of subsets of D_b and skeleton clusters of D_b for
    build points b <= n (causal), Mem(D_n).  Theories are tagged by their instance set relative
    to inst(phi(?t)): same, subset (incomplete), superset (adds instances), or forall-type.
(b) PA mixture, L0; same weights as E2.  Generators: dtrc-motive (motives from the dtrc pa_motive
    generator, no parameters), root-skew (motive root drawn from {imp .5, and .2, = .2, ex .1}, the rest
    from Q), deep (a PCFG with more connectives), atomic (after the referee, M4: motive a(x) = b(x) w.p. 0.6
    or a(x) < b(x) w.p. 0.4, a and b Q-terms with one hole).  Pool: the causal E2 pool (with Trim(T, D_n) and
    Mem(D_n)) plus T* + T_f for every root f (nested fragments: deductively equivalent to T*).

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
from bai.pool import specialise, CausalPool
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
    if name in ('H_sch', 'frag1', 'frag2', 'spare_nested', 'C_2'):
        return 'same'
    if name in ('H_open', 'spare_false', 'spare_schema') or cls == 'over-general':
        return 'superset'
    if name.startswith('H_all'):
        return 'forall'
    if cls == 'over-specific' or name.startswith('N_'):
        return 'subset'
    if name.startswith(('min', 'skel')):
        # data-derived: classify by instance set relative to inst(P) (closed guards throughout)
        from dtrc.templates import geq, equiv
        if all(geq(P, c.T) for c in th.comps):
            return 'same' if any(equiv(c.T, P) for c in th.comps) else 'subset'
        if any(geq(c.T, P) and not equiv(c.T, P) for c in th.comps):
            return 'superset'
    return th.tags.get('rel', 'other')


NMAX = 16
BUILD_POINTS = [8, 32, 64]


def Sn(t, k):
    for _ in range(k):
        t = S(t)
    return t


def pool_a(data, seed):
    """the E3(a) causal pool (a function n -> list of theories); only theories with exact L1 are kept"""
    hand = e1_hand_pool(P)
    for m in range(1, NMAX + 1):
        temps = [instantiate(P, {'t': num(j)}) for j in range(m)]
        temps.append(specialise(P, 't', Sn(('M', 'z', ()), m)))
        hand.append(Theory(temps, 'N_%d' % m, {'cls': 'over-specific'}))
    hand.append(Theory([Component(P)] + [specialise(P, 't', Sn(('M', 'z', ()), j)) for j in (1, 2)], 'C_2',
                       {'cls': 'nested', 'rel': 'same'}))
    hand = [th for th in dedupe(hand) if l1_exact_supported(th, 1)]

    def builder(Db, b):
        out = []
        rng = random.Random((77 + seed) * 1000 + b)
        for i, T in enumerate(min_theories(Db, rng)):
            cls = classify_vs(T, P)
            if cls == 'H_sch':
                continue
            th = Theory([T], 'min%d@%d:%s' % (i, b, pp(T)), {'cls': cls})
            th.tags['rel'] = {'over-general': 'superset', 'over-specific': 'subset'}.get(cls, 'other')
            out.append(th)
        for k, temps in skeleton_theories(Db):
            out.append(Theory(temps, 'skel%d@%d' % (k, b), {'cls': 'skeleton', 'rel': 'other'}))
        return out
    return CausalPool(hand, builder, BUILD_POINTS, data, keep=lambda th: l1_exact_supported(th, 1))


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
        names = [k for k in res if not k.startswith('_')]
        rel = {}
        seen_data = set(data[:n])

        def relk(k):
            th = res[k]['theory']
            memo = (th.name.startswith(('min', 'skel')) and all(c.ground for c in th.comps)
                    and all(c.T in seen_data for c in th.comps))
            return 'mem' if (k == 'Mem' or memo) else inst_rel(th)
        for k in names:
            r = relk(k)
            rel[r] = rel.get(r, 0.0) + res[k]['post']
        mp = max(names, key=lambda k: res[k]['post'])
        b = {k: -(res[k]['lp'] + res[k]['lm']) / LN2 for k in names if res[k]['lm'] > -1e300}
        rows.append({'n': n, 'H_sch': res['H_sch']['post'], 'rel': rel, 'map': mp, 'map_post': res[mp]['post'],
                     'map_rel': relk(mp),
                     'P_forall': support_mass(res, [], der, A),
                     'P_inst': sum(support_mass(res, [], der, h) for h in held) / len(held),
                     'P_inst_each': [support_mass(res, [], der, h) for h in held],
                     'gain_map_vs_sch_bits': (b['H_sch'] - b[mp]) if 'H_sch' in b and mp in b else None,
                     'bits_sel': {k: v for k, v in b.items() if k in ('H_sch', 'spare_nested', 'C_2', 'Mem', 'frag1')
                                  or k.startswith('N_')},
                     'bounded': res['_bounded']['max_post'] if '_bounded' in res else 0.0})
    return {'gen': gname, 'lik': lname, 'seed': seed, 'rows': rows, 'time': round(time.time() - t0, 1),
            'data_head': [pp(d)[:60] for d in data[:6]], 'excluded': sorted(set(pool.excluded)),
            'deriver_inexact': der.chain.inexact, 'lik_inexact': getattr(lik, 'inexact', 0)}


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
        if name == 'atomic':
            f = '=' if rng.random() < 0.6 else '<'
            return (f, Q.sample_term(rng, 1, 0, False), Q.sample_term(rng, 1, 0, False))
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
    from pa_common import ROOTS, T_frag, QSENT, pa_classify
    from dtrc.schemas import T_IND
    import e2_pa
    extra = [Theory(QSENT + [T_IND, T_frag(f)], 'T*+T_%s' % f, {'cls': 'spare'}) for f in ROOTS]
    gen = pa_gen(gname)
    out = e2_pa.run(seed, gen=lambda sd: gen(sd, max(ns)), ns=ns, extra_fixed=extra, legacy=False)
    out['gen'] = gname
    return out


GENS_A = ['heavy', 'numerals', 'small', 'skewQ']
GENS_B = ['dtrc-motive', 'root-skew', 'deep', 'atomic']


def main():
    t0 = time.time()
    NS_A = [8, 32, 128, 512, 1024]
    jobs_a = [(g, l, s, NS_A if l == 'L0' else NS_A[:-1]) for g in GENS_A for l in ['L0', 'L1'] for s in SEEDS]
    NS_B = [16, 64, 256, 1024, 2048]
    jobs_b = [(g, s, NS_B) for g in GENS_B for s in SEEDS]
    with Pool(4) as p:
        rb = p.map(run_b, jobs_b, chunksize=1)
        ra = p.map(run_a, jobs_a, chunksize=1)
    txt = ['# E3: misspecification\n',
           'Command: `cd code/experiments && python3 e3_misspec.py`. Seeds %s. Dirichlet alpha = 0.5; prior '
           '2^-bits; derivability |-_1 (part a), citation |-_0 (part b). Causal pools (data-derived theories '
           'built only from data already seen). Wall time %.0f s.\n' % (SEEDS, time.time() - t0)]
    txt.append('\n## (a) phi = x+0=x, data = instances with a misspecified term law\n\n'
               'Columns: posterior mass of H_sch, of theories with the same instance set as phi(?t) (H_sch, frag1, '
               'frag2, spare_nested = C_1, C_2), of subset theories (incomplete: overspec, N_m, over-specific Min), '
               'of superset theories (over-general, spare_false, spare_schema, H_open), of forall-type theories '
               '(H_all, H_all+sch, H_all+open), of Mem; P(|-inst) = mean mass deriving 3 held-out closed instances '
               '(9+0=9, (2+3)+0=2+3, (1*4)+0=1*4); "gain" = code length of H_sch minus that of the MAP (bits); '
               'MAP (count) with its instance-set relation.\n')
    for g in GENS_A:
        for l in ['L0', 'L1']:
            rs = [r for r in ra if r['gen'] == g and r['lik'] == l]
            ns = [x['n'] for x in rs[0]['rows']]
            rows = []
            for i, n in enumerate(ns):
                def m(f):
                    return sum(f(r['rows'][i]) for r in rs) / len(rs)
                maps = {}
                for r in rs:
                    k = '%s [%s]' % (r['rows'][i]['map'][:20], r['rows'][i]['map_rel'])
                    maps[k] = maps.get(k, 0) + 1
                gains = [r['rows'][i]['gain_map_vs_sch_bits'] for r in rs if r['rows'][i]['gain_map_vs_sch_bits'] is not None]
                rows.append([n, fmt(m(lambda x: x['H_sch'])), fmt(m(lambda x: x['rel'].get('same', 0))),
                             fmt(m(lambda x: x['rel'].get('subset', 0))), fmt(m(lambda x: x['rel'].get('superset', 0))),
                             fmt(m(lambda x: x['rel'].get('forall', 0))), fmt(m(lambda x: x['rel'].get('mem', 0))),
                             fmt(m(lambda x: x['rel'].get('other', 0))),
                             fmt(m(lambda x: x['P_inst'])), fmt(m(lambda x: x['P_forall'])),
                             ('%s (%s to %s)' % (fmt(sum(gains) / len(gains), 1), fmt(min(gains), 1), fmt(max(gains), 1)))
                             if gains else '-',
                             '; '.join('%s x%d' % (k, v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:3])])
            txt.append('\n### generator %s, %s (data: %s ...)\n\n' % (g, l, ', '.join(rs[0]['data_head'][:3])))
            txt.append('Excluded for lack of exact L1: %s. Fallback counters, summed over seeds: likelihood %d, '
                       'derivability oracle %d.\n\n' % (sorted(set(x for r in rs for x in r['excluded'])) or 'none',
                                                      sum(r['lik_inexact'] for r in rs),
                                                      sum(r['deriver_inexact'] for r in rs)))
            txt.append(md_table(['n', 'H_sch', 'same inst.', 'subset', 'superset', 'forall-type', 'Mem', 'other',
                                 'P(|-inst)', 'P(|-forall)', 'gain (bits): mean (range)', 'MAP (count)'], rows))
            fam = ['spare_nested', 'C_2'] if g == 'heavy' else (['N_%d' % k for k in (4, 8, 9, 10, 11, 12, 13, 16)]
                                                                 if g == 'numerals' else [])
            if fam:
                frows = []
                for i, n in enumerate(ns):
                    row = [n]
                    for k in fam:
                        v = [r['rows'][i]['bits_sel'][k] - r['rows'][i]['bits_sel']['H_sch'] for r in rs
                             if k in r['rows'][i]['bits_sel'] and 'H_sch' in r['rows'][i]['bits_sel']]
                        row.append(fmt(sum(v) / len(v), 1) if v else '-')
                    frows.append(row)
                txt.append('\nCode length minus that of H_sch (bits, mean over seeds; spare_nested = C_1):\n\n')
                txt.append(md_table(['n'] + fam, frows))
    txt.append('\n## (b) PA mixture with a misspecified motive law (L0)\n\n'
               'Columns as in E2: masses by the tags of pa_common.pa_classify (equivalent to T*, sound and strictly '
               'weaker, unsound, unknown); the pool includes the nested fragments T* + T_f (equivalent to T*).\n')
    for g in GENS_B:
        rs = [r for r in rb if r['gen'] == g]
        ns = [x['n'] for x in rs[0]['rows']]
        rows = []
        for i, n in enumerate(ns):
            def m(f):
                return sum(f(r['rows'][i]) for r in rs) / len(rs)
            maps = {}
            for r in rs:
                k = '%s [%s]' % (r['rows'][i]['map'][:24], r['rows'][i]['map_tag'])
                maps[k] = maps.get(k, 0) + 1
            rows.append([n, fmt(m(lambda x: x['T*'])), fmt(m(lambda x: x['eq']['yes'])),
                         fmt(m(lambda x: x['eq']['weaker'])), fmt(m(lambda x: x['eq']['no'])),
                         fmt(m(lambda x: x['eq']['unknown'])),
                         fmt(max(r['rows'][i]['eq']['no'] for r in rs)),
                         fmt(m(lambda x: x['P_inst'])), fmt(m(lambda x: x['P_false_max'])),
                         '; '.join('%s x%d' % (k, v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:3])])
        txt.append('\n### generator %s\n\n' % g)
        txt.append(md_table(['n', 'T*', 'equiv. to T*', 'weaker', 'unsound (mean)', 'unknown', 'unsound (max over seeds)',
                             'P(|-held-out Ind)', 'max P(|-false)', 'MAP [tag] (count)'], rows))
        names = ['frag-complete', 'trim:frag-complete', 'T*+T_imp', 'T*+T_and', 'T*+T_ex', 'T*+T_=', 'frag-atoms', 'Mem']
        brow = []
        for r in rs:
            b = r['rows'][-1]['bits']
            brow.append([r['seed']] + [fmt(b[k] - b['T*'], 1) if k in b and 'T*' in b else '-' for k in names])
        txt.append('\nCode length minus that of T* at n = %d (bits; negative = preferred to T*; "-" = not in the pool '
                   'at that n or infinite):\n\n' % ns[-1])
        txt.append(md_table(['seed'] + names, brow))
    save('e3_misspec', '\n'.join(txt), {'a': ra, 'b': rb})


if __name__ == '__main__':
    main()
