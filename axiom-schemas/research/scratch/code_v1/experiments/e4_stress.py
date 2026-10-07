"""E4: stress sets for DTRC.
 (a) near-miss targets (pairs of true schemas with similar shapes; one nested pair) in PA and ZF;
 (b) injected mistakes (false or non-target sentences) in PA-mix and ZF-mix;
 (c) unequal frequencies (rare targets).
"""
import random
import time
from collections import Counter
from common import (save, md_table, pp, Oracle, TemplateRefuter, DTRC, clustering_scores, per_target,
                    probe_dtrc, by_label, targets_of, exact_for)
from dtrc.syntax import canon_params
from dtrc.datasets import (near_miss_pa, near_miss_zf, NEAR_PA, NEAR_ZF, pa_mix, zf_mix, heldout_pa, heldout_zf)
from dtrc.schemas import pa_targets, zf_targets
from dtrc.templates import match

SEEDS = [0, 1, 2]


def composition(m, data):
    lab = {}
    for s, l in data:
        lab.setdefault(canon_params(s), l)
    out = []
    for c in sorted(m.clusters, key=lambda c: -len(c.data)):
        cnt = Counter(lab.get(d, '?') for d in c.data)
        out.append(dict(cnt))
    return out


def run_near(lang, seed):
    data = near_miss_pa(seed) if lang == 'PA' else near_miss_zf(seed)
    targets = NEAR_PA if lang == 'PA' else NEAR_ZF
    R = TemplateRefuter(lang)
    t = time.time()
    m = DTRC(R).fit([s for s, _ in data])
    dt = time.time() - t
    comp = composition(m, data)
    exact = {k: any(c.acc and exact_for(c.acc, T) for c in m.clusters) for k, T in targets.items()}
    pr = probe_dtrc(m, targets, lang, random.Random(seed), 20, Oracle(lang))
    cs = clustering_scores(m, data, targets)
    return dict(cs, comp=comp, exact=exact, probes=pr, time=round(dt, 2), calls=R.oracle.calls)


def run_mistakes(lang, seed, budget=80):
    if lang == 'PA':
        data = pa_mix(seed, mistakes=8, true_nontargets=3)
        targets, held = pa_targets(), heldout_pa(seed)
    else:
        data = zf_mix(seed, mistakes=6)
        targets, held = zf_targets(), heldout_zf(seed)
    R = TemplateRefuter(lang, budget=budget)
    t = time.time()
    m = DTRC(R).fit([s for s, _ in data])
    dt = time.time() - t
    lab = {}
    for s, l in data:
        lab.setdefault(canon_params(s), l)
    mistakes = [s for s, l in lab.items() if l.startswith('MISTAKE')]
    discarded = set(m.discarded)
    fate = Counter()
    for s in mistakes:
        if s in discarded:
            fate['discarded (refuted)'] += 1
            continue
        c = [c for c in m.clusters if s in c.data][0]
        if len(c.data) == 1:
            fate['singleton cluster'] += 1
        else:
            others = Counter(lab[d] for d in c.data if d != s)
            fate['merged into ' + '+'.join(sorted(others))] += 1
    pt = per_target(m, targets, held)
    pr = probe_dtrc(m, targets, lang, random.Random(seed), 20, Oracle(lang))
    cs = clustering_scores(m, data, targets)
    return dict(cs, fate=dict(fate), exact=sum(v['exact'] for v in pt.values()), n_targets=len(targets),
                held=sum(v['heldout_accepted'] for v in pt.values()),
                held_tot=sum(v['heldout_total'] for v in pt.values()), probes=pr,
                kinds=Counter(l for s, l in lab.items() if l.startswith('MISTAKE')), time=round(dt, 2),
                calls=R.oracle.calls)


def run_unequal(lang, seed):
    if lang == 'PA':
        data = pa_mix(seed, n_ind=60, n_univ=(20, 3, 1))
        targets, held = pa_targets(), heldout_pa(seed)
    else:
        data = zf_mix(seed, n_sep=30, n_rep=4, n_eind=1)
        targets, held = zf_targets(), heldout_zf(seed)
    R = TemplateRefuter(lang)
    t = time.time()
    m = DTRC(R).fit([s for s, _ in data])
    dt = time.time() - t
    pt = per_target(m, targets, held)
    pr = probe_dtrc(m, targets, lang, random.Random(seed), 20, Oracle(lang))
    cs = clustering_scores(m, data, targets)
    counts = Counter(l for s, l in data)
    return dict(cs, per_target={k: (counts.get(k, 0), v['exact'], v['heldout_accepted'], v['heldout_total'])
                                for k, v in pt.items()}, probes=pr, time=round(dt, 2))


def main():
    t0 = time.time()
    out = {}
    text = '# E4: stress sets\n\nCommand: `python3 experiments/e4_stress.py`; seeds %s.\n\n' % SEEDS
    # (a) near-miss
    text += '## (a) Near-miss targets\n\n'
    text += 'PA targets: ' + ', '.join('%s = `%s`' % (k, pp(v)) for k, v in NEAR_PA.items()) + '\n\n'
    text += 'ZF targets: ' + ', '.join('%s = `%s`' % (k, pp(v)) for k, v in NEAR_ZF.items()) + '\n\n'
    rows = []
    for lang in ('PA', 'ZF'):
        for seed in SEEDS:
            r = run_near(lang, seed)
            out['near_%s_%d' % (lang, seed)] = r
            merged = [c for c in r['comp'] if len(c) > 1]
            rows.append([lang, seed, r['ARI'], len(r['comp']), sum(r['exact'].values()), len(r['exact']),
                         '; '.join('+'.join('%s:%d' % kv for kv in sorted(c.items())) for c in merged) or 'none',
                         ', '.join(k for k, v in r['exact'].items() if not v) or '-',
                         '%d/%d/%d' % (r['probes']['probes'], r['probes']['nontarget'], r['probes']['refuted']),
                         r['calls'], r['time']])
    text += md_table(['lang', 'seed', 'ARI', 'clusters', 'exact', 'targets', 'mixed clusters (label:count)',
                      'not exact', 'probes/non-target/refuted', 'oracle calls', 'time'], rows)
    # (b) mistakes
    text += '\n## (b) Injected mistakes\n\n'
    text += ('PA: 8 mistakes (wrong step clause phi(x)->phi(x); wrong base phi(S0); conclusion Ax phi(Sx) '
             '(true, non-instance); n+0=0) + 3 true non-target sentences. ZF: 6 mistakes (Separation with b '
             'free in phi; Ax(phi->phi)->Ax phi; complement comprehension).\n\n')
    rows = []
    for budget in (80, 400):
        for lang in ('PA', 'ZF'):
            for seed in SEEDS:
                r = run_mistakes(lang, seed, budget)
                out['mist_%s_%d_%d' % (lang, seed, budget)] = r
                rows.append([budget, lang, seed, r['ARI'], '%d/%d' % (r['exact'], r['n_targets']),
                             '%d/%d' % (r['held'], r['held_tot']),
                             '; '.join('%s: %d' % kv for kv in sorted(r['fate'].items())),
                             '%d/%d/%d' % (r['probes']['probes'], r['probes']['nontarget'], r['probes']['refuted']),
                             r['calls'], r['time']])
    text += md_table(['refuter budget', 'lang', 'seed', 'ARI (clean data)', 'exact targets', 'held-out accepted',
                      'fate of mistakes', 'probes/non-target/refuted', 'oracle calls', 'time'], rows)
    # (c) unequal frequencies
    text += '\n## (c) Unequal frequencies\n\n'
    text += 'PA: Ind 60, x+0=x 20, x*0=0 3, 0+x=x 1, Q axioms 1 each. ZF: Sep 30, Rep 4, EInd 1, axioms 1 each.\n\n'
    rows = []
    for lang in ('PA', 'ZF'):
        for seed in SEEDS:
            r = run_unequal(lang, seed)
            out['uneq_%s_%d' % (lang, seed)] = r
            rare = {k: v for k, v in r['per_target'].items() if v[0] != 1 or not v[1]}
            rows.append([lang, seed, r['ARI'], '; '.join('%s n=%d %s %d/%d' % (k, v[0], 'E' if v[1] else '-',
                                                                         v[2], v[3]) for k, v in rare.items()),
                         '%d/%d/%d' % (r['probes']['probes'], r['probes']['nontarget'], r['probes']['refuted']),
                         r['time']])
    text += md_table(['lang', 'seed', 'ARI', 'schemas: n, exact?, held-out accepted', 'probes/non-target/refuted',
                      'time'], rows)
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e4_stress', text, out)
    print(text)


if __name__ == '__main__':
    main()
