"""E2 (Q2): learning each schema from its own (tagged) instances: Separation, Replacement (exists-unique
spelled out), epsilon-induction, and PA induction for comparison.

Learners: DT°_F cautious verifier (minimal covering templates), the same with refutation filtering, the
higher-order pattern lgg (v2: the genuine, term-level pattern lgg, and the v1 baseline with formula-level atom
generalisation), and first-order lgg in the named (level) and de Bruijn encodings.
v2: the 30 held-out instances used for first-order completeness exclude the run's training data.
(1) exactness rate vs number N of instances (R seeds per N);
(2) soundness probes: instances sampled from each learned hypothesis (first-order metavariables may be
    filled with formulas mentioning any bound variable in scope, i.e. capture is allowed, as first-order
    instantiation permits); counted: instances of no target, and of those the ones the world oracle refutes.
"""
import random
import time
from common import (save, md_table, pp, Oracle, targets_of, sample_instances, FOLgg, pattern_lgg, probe_hyp,
                    pattern_lgg_formula)
from dtrc.syntax import canon_params
from dtrc.templates import equiv, match
from dtrc.mincover import MinCover, aligned_min
from dtrc.refute import TemplateRefuter
from dtrc.metrics import exact_for
from dtrc.schemas import T_SEP, T_REP, T_EIND, T_IND, Sep, Rep, EInd, Ind, pa_targets, zf_targets
from dtrc.datasets import zf_body, pa_motive

SCHEMAS = {
    'Sep': ('ZF', T_SEP, lambda rng: Sep(zf_body(rng, 2, [0]))),
    'Rep': ('ZF', T_REP, lambda rng: Rep(zf_body(rng, 3, [0, 1]))),
    'EInd': ('ZF', T_EIND, lambda rng: EInd(zf_body(rng, 1, [0]))),
    'Ind': ('PA', T_IND, lambda rng: Ind(pa_motive(rng))),
}
NS = [1, 2, 3, 4, 6, 8]


def main():
    t0 = time.time()
    R = 30
    rows_ex, rows_snd, data = [], [], {}
    refuters = {'ZF': TemplateRefuter('ZF'), 'PA': TemplateRefuter('PA')}
    oracles = {'ZF': Oracle('ZF'), 'PA': Oracle('PA')}
    exhibits = []
    n_differs = [0]
    for name, (lang, T, gen) in SCHEMAS.items():
        targets = zf_targets() if lang == 'ZF' else pa_targets()
        Rf = refuters[lang]
        hrng = random.Random(4242)
        held = list(dict.fromkeys(gen(hrng) for _ in range(30)))
        for N in NS:
            cnt = {'dt': 0, 'dt_ref': 0, 'pat': 0, 'patf': 0, 'fon': 0, 'fod': 0}
            for seed in range(R):
                rng = random.Random(seed * 7919 + N)
                D = list(dict.fromkeys(gen(rng) for _ in range(N)))
                mins, amc = aligned_min(D)
                n_differs[0] += int(bool(amc.differs))
                cnt['dt'] += int(exact_for(mins, T))
                acc = [M for M in mins if not Rf.refuted(M, D)]
                cnt['dt_ref'] += int(exact_for(acc, T))
                PL = pattern_lgg(D)
                cnt['pat'] += int(equiv(PL, T))
                cnt['patf'] += int(equiv(pattern_lgg_formula(D), T))
                hd = [q for q in held if q not in D]
                for enc, key in (('named', 'fon'), ('debruijn', 'fod')):
                    L = FOLgg(D, enc)
                    cnt[key] += int(all(L.accepts(q) for q in hd))
            rows_ex.append([name, N, '%d/%d' % (cnt['dt'], R), '%d/%d' % (cnt['dt_ref'], R),
                            '%d/%d' % (cnt['pat'], R), '%d/%d' % (cnt['patf'], R),
                            '%d/%d' % (cnt['fon'], R), '%d/%d' % (cnt['fod'], R)])
        # soundness probes at a few N
        for N in (2, 6):
            agg = {k: [0, 0, 0] for k in ('DT°_F', 'pattern', 'pattern (formula-level)', 'fo-named', 'fo-deBruijn')}
            for seed in range(8):
                rng = random.Random(seed * 104729 + N)
                D = list(dict.fromkeys(gen(rng) for _ in range(N)))
                mins = MinCover(D).minimal()
                prng = random.Random(seed)
                hyps = {
                    'DT°_F': lambda: [q for q in sample_instances(mins[0], lang, prng, 30, D)
                                      if all(match(M, q) is not None for M in mins)],
                    'pattern': lambda: sample_instances(pattern_lgg(D), lang, prng, 30, D),
                    'pattern (formula-level)': lambda: sample_instances(pattern_lgg_formula(D), lang, prng, 30, D),
                    'fo-named': lambda: FOLgg(D, 'named').sample(prng, 30, lang),
                    'fo-deBruijn': lambda: FOLgg(D, 'debruijn').sample(prng, 30, lang),
                }
                for k, sampler in hyps.items():
                    r = probe_hyp(sampler, targets, lang, oracles[lang])
                    agg[k][0] += r['probes']
                    agg[k][1] += r['nontarget']
                    agg[k][2] += r['refuted']
                    if r['examples'] and not any(e[0] == name and e[1] == k for e in exhibits):
                        exhibits.append((name, k, N, r['examples'][0]))
            for k, (p, nt, rf) in agg.items():
                rows_snd.append([name, N, k, p, nt, rf])
    text = '# E2: learning each ZF schema (and PA induction) from tagged instances (Q2)\n\n'
    text += 'Command: `python3 experiments/e2_schemas.py`; %d seeds per N (exactness), 8 seeds (probes).\n\n' % R
    text += '## Exactness (acceptance set = inst(target))\n\n'
    text += ('DT°_F and pattern columns: exact (acceptance set equals inst(target), syntactic test). First-order '
             'columns: *complete* (accepts all of 30 held-out genuine instances); their soundness is measured by '
             'the probes below.\n\n')
    text += md_table(['schema', 'N', 'DT°_F exact', 'DT°_F + refutation exact', 'pattern lgg (genuine) exact',
                      'pattern lgg (formula-level, v1) exact', 'fo-lgg named complete', 'fo-lgg de Bruijn complete'],
                     rows_ex)
    text += '\n## Soundness probes (30 sampled accepted sentences per hypothesis and seed)\n\n'
    text += md_table(['schema', 'N', 'learner', 'probes', 'instances of no target', 'refuted by oracle'], rows_snd)
    text += '\n## Exhibits: accepted sentences certified false by the oracle\n\n'
    for (name, k, N, ex) in exhibits:
        text += '* %s, %s, N=%d: `%s`\n' % (name, k, N, ex)
    text += '\nRefuter stats: ZF %s; PA %s\n' % (refuters['ZF'].stats(), refuters['PA'].stats())
    text += ('\nMin is the alignment-complete Min^al; it differed from the literal Min on %d of the %d data sets.\n'
             % (n_differs[0], len(SCHEMAS) * len(NS) * R))
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e2_schemas', text, {'exact': rows_ex, 'sound': rows_snd, 'exhibits': exhibits})
    print(text)


if __name__ == '__main__':
    main()
