"""E9 (v2): empirical check of *refutation separation* (S) between targets.

(P) pairs of single data: for target pairs i != j, draw a in inst(T_i) \\ inst(T_j), b in inst(T_j) \\ inst(T_i)
    and test every member of Min^al({a,b}).  With an ideal refuter, (S) for all data sets reduces to these
    pairs (notes, Lemma E3(a)/Cor. E8).
(S) small sets |A|,|B| in {1,2} (as in v1), for the budgeted refuter, which is not monotone.
For each target set we report: merges tested and refuted, the number of DISTINCT minimal templates involved
(referee F3: v1 hid that thousands of merges reduce to a handful of templates), the most frequent templates,
and which refuter pass found each refutation (top/bot, one-hot, parallel/diagonal, data-guided).
Target sets: PA-mix and ZF-mix targets, the near-miss sets of E4, and the hard ZF set (v2).
"""
import random
import time
import itertools
from collections import Counter
from common import save, md_table, pp, TemplateRefuter
from dtrc.syntax import canon_params
from dtrc.templates import match, canon
from dtrc.mincover import aligned_min
from dtrc.schemas import pa_targets, zf_targets
from dtrc.datasets import NEAR_PA, NEAR_ZF, HARD_ZF, schema_instance


def draw(name, targets, lang, rng, other):
    for _ in range(50):
        s = schema_instance(targets[name], lang, rng)
        if match(targets[other], s) is None:
            return s
    return None


def run(lang, targets, reps, rng, R, sizes):
    names = list(targets)
    rows = []
    fails = []
    tcount = Counter()
    tstatus = {}
    tested = refuted = 0
    for a, b in itertools.combinations(names, 2):
        n_sep = n_tot = 0
        for _ in range(reps):
            ka = 1 if sizes == 'pairs' else rng.randint(1, 2)
            kb = 1 if sizes == 'pairs' else rng.randint(1, 2)
            A = [draw(a, targets, lang, rng, b) for _ in range(ka)]
            B = [draw(b, targets, lang, rng, a) for _ in range(kb)]
            if None in A or None in B:
                continue
            D = list(dict.fromkeys(A + B))
            n_tot += 1
            mins, _ = aligned_min(D)
            surv = []
            for T in mins:
                c = canon(T)
                tcount[c] += 1
                r = R.refuted(T, D)
                tstatus[c] = (r, R.phase(T), R.witness(T))
                if not r:
                    surv.append(T)
            if not surv:
                n_sep += 1
            elif len(fails) < 12:
                fails.append((a, b, [pp(d) for d in D], [pp(T) for T in surv]))
        rows.append((a, b, n_sep, n_tot))
        tested += n_tot
        refuted += n_sep
    return rows, fails, tcount, tstatus, tested, refuted


SETS = (('PA-mix targets', 'PA', pa_targets, 40), ('ZF-mix targets', 'ZF', zf_targets, 15),
        ('PA near-miss targets', 'PA', lambda: NEAR_PA, 40), ('ZF near-miss targets', 'ZF', lambda: NEAR_ZF, 15),
        ('ZF hard targets (v2)', 'ZF', lambda: HARD_ZF, 12))


def main():
    t0 = time.time()
    text = '# E9 (v2): refutation separation between targets\n\nCommand: `python3 experiments/e9_separation.py`.\n\n'
    text += ('Min is the alignment-complete Min^al. "pairs" = one datum per target (the case to which (S) '
             'reduces for an ideal refuter); "sets" = |A|,|B| in {1,2} (v1 protocol). Data that are instances '
             'of both targets of the pair are excluded. Refuter: budget 80 per template (v2 search order).\n\n')
    out = {}
    for label, lang, tf, reps in SETS:
        targets = tf()
        text += '## %s\n\n' % label
        text += 'Targets: ' + ', '.join('%s = `%s`' % (k, pp(v)) for k, v in targets.items()) + '\n\n'
        out[label] = {}
        summary = []
        for sizes in ('pairs', 'sets'):
            R = TemplateRefuter(lang)
            rng = random.Random(len(label) * 7 + (0 if sizes == 'pairs' else 1))
            rows, fails, tcount, tstatus, tested, refd = run(lang, targets, reps, rng, R, sizes)
            phases = Counter(tstatus[c][1] for c in tcount if tstatus[c][0])
            unref = [c for c in tcount if not tstatus[c][0]]
            summary.append([sizes, tested, refd, '%.1f%%' % (100.0 * refd / max(1, tested)), len(tcount),
                            len(unref), ', '.join('%s %d' % kv for kv in sorted(phases.items())),
                            R.oracle.calls])
            out[label][sizes] = {'rows': rows, 'fails': fails, 'templates': {pp(c): (n, tstatus[c][0], tstatus[c][1])
                                                                              for c, n in tcount.items()}}
            if sizes == 'pairs':
                top = tcount.most_common(8)
                text += 'Most frequent minimal templates (pairs of single data): count, refuted?, refuter pass, witness:\n\n'
                text += md_table(['template', 'count', 'refuted', 'pass', 'refuting instance'],
                                 [[('`%s`' % pp(c)).replace('|', '\\|'), n, tstatus[c][0], tstatus[c][1] or '-',
                                   ('`%s`' % pp(tstatus[c][2])).replace('|', '\\|') if tstatus[c][2] else '-']
                                  for c, n in top]) + '\n'
            bad = [r for r in rows if r[2] < r[3]]
            if bad:
                text += 'Target pairs with an unrefuted merge (%s): %s\n\n' % (
                    sizes, '; '.join('%s/%s %d of %d separated' % r for r in bad))
            if fails:
                text += 'Examples of unrefuted cross-target merges (%s; data; surviving minimal templates):\n\n' % sizes
                for (a, b, D, S) in fails[:5]:
                    text += ('* %s / %s: data `%s`; surviving `%s`\n' % (a, b, ' ; '.join(D), ' ; '.join(S))).replace('|', '\\|')
                text += '\n'
        text += md_table(['protocol', 'merges tested', 'refuted', 'rate', 'distinct minimal templates',
                          'distinct unrefuted', 'refutations by pass (distinct templates)', 'oracle calls'], summary)
        text += '\n'
    text += 'Wall time: %.1fs\n' % (time.time() - t0)
    save('e9_separation', text, out)
    print(text)


if __name__ == '__main__':
    main()
