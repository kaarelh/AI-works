"""E3 (Q3): DTRC on untagged mixtures (PA-mix, ZF-mix) vs baselines.

PA-mix(seed): Q's 7 axioms (closed sentences) + 30 induction instances with random motives (parameters
allowed) + instances of x+0=x (8), x*0=0 (6), 0+x=x (4) (numerals, closed terms, parameters).
ZF-mix(seed): Ext, Pair, Union, Power, Inf, Found + 12 Separation + 10 Replacement + 10 epsilon-induction
instances with random small formulas (bounded quantifiers, parameters).
Learners:
  DTRC (refutation clustering + per-cluster cautious DT°_F verifier);
  skeleton clustering without refutation, stopped at k = number of targets, + per-cluster DT°_F verifier;
  tagged DT°_F (gold labels; reference);
  first-order lgg per gold tag (named / de Bruijn); pattern lgg per gold tag.
Metrics: ARI / purity (data that are instances of exactly one target), exact targets, held-out acceptance,
probes (sampled accepted sentences that are instances of no target / refuted by the oracle), oracle calls,
wall time.
"""
import random
import sys
import time
from common import (save, md_table, pp, Oracle, TemplateRefuter, DTRC, tagged_learner, clustering_scores,
                    per_target, probe_dtrc, probe_hyp, by_label, FOLgg, pattern_lgg, sample_instances,
                    exact_for, targets_of)
from dtrc.datasets import pa_mix, zf_mix, heldout_pa, heldout_zf
from dtrc.schemas import pa_targets, zf_targets
from dtrc.templates import match, equiv

SEEDS = [0, 1, 2, 3, 4]


def run_mix(mix, seed):
    lang = 'PA' if mix == 'PA' else 'ZF'
    data = pa_mix(seed) if mix == 'PA' else zf_mix(seed)
    targets = pa_targets() if lang == 'PA' else zf_targets()
    held = heldout_pa(seed) if lang == 'PA' else heldout_zf(seed)
    oracle = Oracle(lang)
    res = {}
    # DTRC
    t = time.time()
    R = TemplateRefuter(lang)
    m = DTRC(R).fit([s for s, _ in data])
    dt = time.time() - t
    cs = clustering_scores(m, data, targets)
    pt = per_target(m, targets, held)
    pr = probe_dtrc(m, targets, lang, random.Random(seed), 20, oracle)
    res['DTRC'] = dict(cs, exact=sum(v['exact'] for v in pt.values()), n_targets=len(targets),
                       held=sum(v['heldout_accepted'] for v in pt.values()),
                       held_tot=sum(v['heldout_total'] for v in pt.values()), clusters=len(m.clusters),
                       probes=pr['probes'], nontarget=pr['nontarget'], refuted=pr['refuted'],
                       oracle_calls=R.oracle.calls, time=round(dt, 2), per_target=pt, ex=pr['examples'])
    # skeleton clustering, no refutation, k known
    t = time.time()
    k = len(targets)
    m2 = DTRC(None, use_refutation=False, k_stop=k).fit([s for s, _ in data])
    dt = time.time() - t
    cs2 = clustering_scores(m2, data, targets)
    pt2 = per_target(m2, targets, held)
    pr2 = probe_dtrc(m2, targets, lang, random.Random(seed), 20, oracle)
    res['skeleton(k)'] = dict(cs2, exact=sum(v['exact'] for v in pt2.values()), n_targets=k,
                              held=sum(v['heldout_accepted'] for v in pt2.values()),
                              held_tot=sum(v['heldout_total'] for v in pt2.values()), clusters=len(m2.clusters),
                              probes=pr2['probes'], nontarget=pr2['nontarget'], refuted=pr2['refuted'],
                              oracle_calls=0, time=round(dt, 2), ex=pr2['examples'])
    # tagged references and per-tag baselines
    tags = by_label(data)
    tl = tagged_learner(tags, refuter=TemplateRefuter(lang))
    ex_tag = sum(1 for name, T in targets.items() if name in tl and exact_for(tl[name]['acc'], T))
    res['tagged DT°_F'] = dict(ARI='-', purity='-', exact=ex_tag, n_targets=len(targets), clusters=len(tags),
                               held='-', held_tot='-', probes='-', nontarget='-', refuted='-', oracle_calls='-',
                               time='-')
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
            for q in held.get(tag, []):
                held_tot += 1
                held_ok += int(L.accepts(q))
        res['fo-lgg/tag ' + enc] = dict(ARI='-', purity='-', exact='-', n_targets=len(targets), clusters=len(tags),
                                        held=held_ok, held_tot=held_tot, probes=P, nontarget=NT, refuted=RF,
                                        oracle_calls='-', time='-', ex=exs[:2])
    P = NT = RF = 0
    exact_pat = 0
    held_ok = held_tot = 0
    exs = []
    for tag, D in tags.items():
        PL = pattern_lgg(D)
        if tag in targets and equiv(PL, targets[tag]):
            exact_pat += 1
        r = probe_hyp(lambda: sample_instances(PL, lang, random.Random(seed), 20, D), targets, lang, oracle)
        P += r['probes']
        NT += r['nontarget']
        RF += r['refuted']
        exs += r['examples']
        for q in held.get(tag, []):
            held_tot += 1
            held_ok += int(match(PL, q) is not None)
    res['pattern-lgg/tag'] = dict(ARI='-', purity='-', exact=exact_pat, n_targets=len(targets), clusters=len(tags),
                                  held=held_ok, held_tot=held_tot, probes=P, nontarget=NT, refuted=RF,
                                  oracle_calls='-', time='-', ex=exs[:2])
    return res


def main():
    t0 = time.time()
    allres = {}
    text = '# E3: DTRC on untagged mixtures (Q3)\n\n'
    text += 'Command: `python3 experiments/e3_mix.py`; seeds %s.\n\n' % SEEDS
    for mix in ('PA', 'ZF'):
        rows = []
        allres[mix] = {}
        for seed in SEEDS:
            res = run_mix(mix, seed)
            allres[mix][seed] = res
            for learner, r in res.items():
                rows.append([seed, learner, r.get('ARI'), r.get('purity'), r.get('clusters'),
                             '%s/%s' % (r.get('exact'), r.get('n_targets')),
                             '%s/%s' % (r.get('held'), r.get('held_tot')), r.get('probes'), r.get('nontarget'),
                             r.get('refuted'), r.get('oracle_calls'), r.get('time')])
        text += '## %s-mix\n\n' % mix
        text += md_table(['seed', 'learner', 'ARI', 'purity', 'clusters', 'exact targets', 'held-out accepted',
                          'probes', 'non-target', 'refuted', 'oracle calls', 'time (s)'], rows)
        # per-target exactness of DTRC
        names = list(allres[mix][SEEDS[0]]['DTRC']['per_target'])
        prow = []
        for nm in names:
            prow.append([nm] + ['%s (%d/%d)' % ('E' if allres[mix][s]['DTRC']['per_target'][nm]['exact'] else '-',
                                              allres[mix][s]['DTRC']['per_target'][nm]['heldout_accepted'],
                                              allres[mix][s]['DTRC']['per_target'][nm]['heldout_total'])
                                for s in SEEDS])
        text += '\nDTRC per target (E = exact; held-out accepted/total), seeds %s:\n\n' % SEEDS
        text += md_table(['target'] + ['seed %d' % s for s in SEEDS], prow)
        exs = []
        for s in SEEDS:
            for learner, r in allres[mix][s].items():
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
