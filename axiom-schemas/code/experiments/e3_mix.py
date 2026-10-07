"""E3 (Q3): DTRC on untagged mixtures (PA-mix, ZF-mix) vs baselines.  v2 (after the referee's report).

PA-mix(seed): Q's 7 axioms (closed sentences) + 30 induction instances with random motives (parameters
allowed) + instances of x+0=x (8), x*0=0 (6), 0+x=x (4).
  regime 'numerals' (main; as the task specifies): the universal axioms are observed through numeral
  instances n+0=n, n*0=0, 0+n=n (n uniform in 0..7) only;
  regime 'mixed' (v1): numerals w.p. 0.6, random closed terms 0.25, the parameter form w0+0=w0 0.15.
ZF-mix(seed): Ext, Pair, Union, Power, Inf, Found + 12 Separation + 10 Replacement + 10 epsilon-induction
instances with random small formulas (bounded quantifiers, parameters).
Learners:
  DTRC (alignment-complete Min, refutation clustering + per-cluster cautious DT°_F verifier);
  DTRC+share (the same plus the sharing pass: a datum also joins every other cluster it coheres with);
  skeleton clustering without refutation, stopped at k = number of targets;
  tagged DT°_F + refutation, with the gold labels (the label each datum was generated from);
  tagged DT°_F + refutation, with membership labels (each datum under every target it instantiates);
  first-order lgg per gold tag (named / de Bruijn); pattern lgg per gold tag (genuine = term-level;
  formula-level = the v1 baseline).
Metrics: ARI / purity (data that are instances of exactly one target); exactness split into schema-level
(targets with metavariables) and single axioms (exact = the singleton cluster accepts exactly the axiom);
held-out acceptance on schema targets (held-out sets disjoint from the training data); probes (sampled
accepted sentences that are instances of no target / refuted by the oracle; the refuted count is a lower
bound on unsoundness); oracle calls; wall time.
"""
import random
import sys
import time
from common import (save, md_table, pp, Oracle, TemplateRefuter, DTRC, tagged_learner, clustering_scores,
                    per_target, probe_dtrc, probe_hyp, by_label, FOLgg, pattern_lgg, pattern_lgg_formula,
                    sample_instances, exact_for, targets_of, is_schema, membership_tags, exact_split)
from dtrc.syntax import canon_params
from dtrc.datasets import pa_mix, zf_mix, heldout_pa, heldout_zf
from dtrc.schemas import pa_targets, zf_targets
from dtrc.templates import match, equiv

SEEDS = [0, 1, 2, 3, 4]
REGIMES = [('PA', 'numerals'), ('PA', 'mixed'), ('ZF', '-')]


def dtrc_row(m, R, data, targets, held, seed, lang, oracle, dt):
    cs = clustering_scores(m, data, targets)
    pt = per_target(m, targets, held)
    exact = {k: v['exact'] for k, v in pt.items()}
    se, ns, ae, na = exact_split(exact, targets)
    hs = [k for k in targets if is_schema(targets[k])]
    pr = probe_dtrc(m, targets, lang, random.Random(seed), 20, oracle)
    return dict(cs, schema_exact=se, n_schema=ns, ax_exact=ae, n_ax=na, exact=exact,
                held=sum(pt[k]['heldout_accepted'] for k in hs), held_tot=sum(pt[k]['heldout_total'] for k in hs),
                clusters=len(m.clusters), probes=pr['probes'], nontarget=pr['nontarget'], refuted=pr['refuted'],
                oracle_calls=(R.oracle.calls if R else 0), time=round(dt, 2), ex=pr['examples'],
                per_target=pt, align_differs=m.stats.get('align_differs', 0),
                align_truncated=m.stats.get('align_truncated', 0), shared=m.stats.get('shared', 0),
                min_truncated=m.stats.get('min_truncated', 0))


def run_mix(mix, seed, regime):
    lang = mix
    data = pa_mix(seed, univ_dist=regime) if mix == 'PA' else zf_mix(seed)
    targets = pa_targets() if lang == 'PA' else zf_targets()
    train = [canon_params(s) for s, _ in data]
    held = heldout_pa(seed, exclude=train) if lang == 'PA' else heldout_zf(seed, exclude=train)
    oracle = Oracle(lang)
    res = {}
    for name, kw in (('DTRC', {}), ('DTRC+share', {'share': True})):
        t = time.time()
        R = TemplateRefuter(lang)
        m = DTRC(R, **kw).fit([s for s, _ in data])
        res[name] = dtrc_row(m, R, data, targets, held, seed, lang, oracle, time.time() - t)
    t = time.time()
    m2 = DTRC(None, use_refutation=False, k_stop=len(targets)).fit([s for s, _ in data])
    res['skeleton(k)'] = dtrc_row(m2, None, data, targets, held, seed, lang, oracle, time.time() - t)
    # tagged references
    for name, tags in (('tagged (gold labels)', by_label(data)), ('tagged (membership)', membership_tags(data, targets))):
        tl = tagged_learner(tags, refuter=TemplateRefuter(lang))
        exact = {k: (k in tl and exact_for(tl[k]['acc'], T)) for k, T in targets.items()}
        se, ns, ae, na = exact_split(exact, targets)
        res[name] = dict(schema_exact=se, n_schema=ns, ax_exact=ae, n_ax=na, exact=exact)
    # per-tag baselines (gold labels)
    tags = by_label(data)
    hs = [k for k in targets if is_schema(targets[k])]
    for enc in ('named', 'debruijn'):
        P = NT = RF = 0
        held_ok = held_tot = 0
        exs = []
        for tag, D in tags.items():
            L = FOLgg(D, enc)
            r = probe_hyp(lambda: L.sample(random.Random(seed), 20, lang), targets, lang, oracle)
            P += r['probes']
            NT += r['nontarget']
            RF += r['refuted']
            exs += r['examples']
            if tag in hs:
                for q in held.get(tag, []):
                    held_tot += 1
                    held_ok += int(L.accepts(q))
        res['fo-lgg/tag ' + enc] = dict(held=held_ok, held_tot=held_tot, probes=P, nontarget=NT, refuted=RF,
                                        ex=exs[:2])
    for name, fn in (('pattern-lgg/tag (genuine)', pattern_lgg), ('pattern-lgg/tag (formula-level, v1)', pattern_lgg_formula)):
        P = NT = RF = 0
        exact_pat = 0
        held_ok = held_tot = 0
        exs = []
        for tag, D in tags.items():
            PL = fn(D)
            if tag in hs and equiv(PL, targets[tag]):
                exact_pat += 1
            r = probe_hyp(lambda: sample_instances(PL, lang, random.Random(seed), 20, D), targets, lang, oracle)
            P += r['probes']
            NT += r['nontarget']
            RF += r['refuted']
            exs += r['examples']
            if tag in hs:
                for q in held.get(tag, []):
                    held_tot += 1
                    held_ok += int(match(PL, q) is not None)
        res[name] = dict(schema_exact=exact_pat, n_schema=len(hs), held=held_ok, held_tot=held_tot, probes=P,
                         nontarget=NT, refuted=RF, ex=exs[:2])
    return res


def fmt(r, k, k2=None):
    if k2:
        return '%s/%s' % (r.get(k, '-'), r.get(k2, '-')) if k in r else '-'
    return r.get(k, '-')


def main():
    t0 = time.time()
    allres = {}
    text = '# E3: DTRC on untagged mixtures (Q3), v2\n\n'
    text += ('Command: `python3 experiments/e3_mix.py`; seeds %s. Exactness is split into schema-level targets '
             '(with metavariables: Ind and the three ?t-instance schemas; Sep, Rep, EInd) and single ground axioms '
             '(exact = kept as a singleton cluster accepting exactly the axiom). Held-out sets contain schema '
             'instances only and are disjoint from the training data. "refuted" counts accepted non-target '
             'sentences certified false by the oracle: a lower bound on unsoundness.\n\n' % SEEDS)
    for mix, regime in REGIMES:
        key = mix + ('-' + regime if regime != '-' else '')
        allres[key] = {}
        rows = []
        for seed in SEEDS:
            res = run_mix(mix, seed, regime if regime != '-' else 'numerals')
            allres[key][seed] = res
            for learner, r in res.items():
                rows.append([seed, learner, fmt(r, 'ARI'), fmt(r, 'clusters'), fmt(r, 'schema_exact', 'n_schema'),
                             fmt(r, 'ax_exact', 'n_ax'), fmt(r, 'held', 'held_tot'), fmt(r, 'probes'),
                             fmt(r, 'nontarget'), fmt(r, 'refuted'), fmt(r, 'oracle_calls'), fmt(r, 'time')])
        title = {'PA-numerals': 'PA-mix, universal axioms through numerals only (main regime)',
                 'PA-mixed': 'PA-mix, v1 instance distribution (numerals, closed terms, parameter form)',
                 'ZF': 'ZF-mix'}[key]
        text += '## %s\n\n' % title
        # summary over seeds
        learners = list(allres[key][SEEDS[0]])
        srows = []
        for learner in learners:
            rs = [allres[key][s][learner] for s in SEEDS]

            def tot(k):
                return sum(r[k] for r in rs) if all(k in r for r in rs) else None
            srows.append([learner,
                          '%.3f' % (sum(r['ARI'] for r in rs) / len(rs)) if all('ARI' in r for r in rs) else '-',
                          '%s/%s' % (tot('schema_exact'), tot('n_schema')) if tot('schema_exact') is not None else '-',
                          '%s/%s' % (tot('ax_exact'), tot('n_ax')) if tot('ax_exact') is not None else '-',
                          '%s/%s' % (tot('held'), tot('held_tot')) if tot('held') is not None else '-',
                          '%s/%s/%s' % (tot('probes'), tot('nontarget'), tot('refuted')) if tot('probes') is not None else '-'])
        text += 'Totals over the 5 seeds:\n\n'
        text += md_table(['learner', 'mean ARI', 'schema targets exact', 'single axioms exact',
                          'held-out schema instances accepted', 'probes / non-target / refuted'], srows)
        # per-target exactness for schema targets
        names = [k for k, T in (pa_targets() if mix == 'PA' else zf_targets()).items() if is_schema(T)]
        prow = []
        for nm in names:
            cells = [nm]
            for learner in ('DTRC', 'DTRC+share', 'tagged (gold labels)', 'tagged (membership)'):
                cells.append(''.join('E' if allres[key][s][learner]['exact'][nm] else '-' for s in SEEDS))
            prow.append(cells)
        text += '\nSchema targets, exact per seed (E = exact, - = not), seeds %s:\n\n' % SEEDS
        text += md_table(['target', 'DTRC', 'DTRC+share', 'tagged (gold)', 'tagged (membership)'], prow)
        text += '\nPer seed:\n\n'
        text += md_table(['seed', 'learner', 'ARI', 'clusters', 'schema exact', 'axioms exact',
                          'held-out accepted', 'probes', 'non-target', 'refuted', 'oracle calls', 'time (s)'], rows)
        st = [(s, allres[key][s]['DTRC']['align_differs'], allres[key][s]['DTRC']['align_truncated'],
               allres[key][s]['DTRC+share']['shared'], allres[key][s]['DTRC']['min_truncated']) for s in SEEDS]
        text += ('\nMin calls where the alignment-complete Min differs from the literal Min (DTRC), per seed: %s; '
                 'alignment truncations: %s; MinCover truncations: %s; data shared by the sharing pass: %s.\n'
                 % ([x[1] for x in st], [x[2] for x in st], [x[4] for x in st], [x[3] for x in st]))
        exs = []
        for s in SEEDS:
            for learner, r in allres[key][s].items():
                for e in r.get('ex', []) or []:
                    if len(exs) < 8 and not any(x[0] == learner for x in exs):
                        exs.append((learner, s, e))
        text += '\nExamples of accepted sentences refuted by the oracle:\n\n'
        for (l, s, e) in exs:
            text += '* %s (seed %d): `%s`\n' % (l, s, e)
        text += '\n'
    text += 'Wall time: %.1fs\n' % (time.time() - t0)
    save('e3_mix', text, allres)
    print(text)


if __name__ == '__main__':
    main()
