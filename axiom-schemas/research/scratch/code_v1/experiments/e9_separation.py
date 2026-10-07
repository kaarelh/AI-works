"""E9: empirical check of the *refutation separation* hypothesis of the DTRC correctness theorem:
for targets i != j and small A subset inst(T_i), B subset inst(T_j) (|A|,|B| in {1,2}), is every minimal
covering DT°_F template of A u B refuted by the budgeted refuter?  40 (PA) or 15 (ZF) random (A,B) per target pair
(unordered pairs reported).  Data that are instances of both targets are excluded.
"""
import random
import time
import itertools
from common import save, md_table, pp, TemplateRefuter
from dtrc.syntax import parse, canon_params
from dtrc.templates import match
from dtrc.mincover import MinCover
from dtrc.schemas import pa_targets, zf_targets, Q_AXIOMS, ZF_AXIOMS, U_AXIOMS, T_IND, T_SEP, T_REP, T_EIND
from dtrc.datasets import pa_motive, zf_body, universal_instance, NEAR_PA, NEAR_ZF
from dtrc.templates import instantiate


def gen_for(name, T, lang, rng):
    from dtrc.templates import metas
    ms = metas(T)
    if not ms:
        return T
    if 't' in ms:
        return universal_instance(rng, T)
    ar = ms['P']
    if lang == 'PA':
        return canon_params(instantiate(T, {'P': pa_motive(rng)}))
    need = [0] if ar <= 2 else [0, 1]
    return canon_params(instantiate(T, {'P': zf_body(rng, ar, need)}))


def run(lang, targets, reps, rng, R):
    names = list(targets)
    rows = []
    fails = []
    for a, b in itertools.combinations(names, 2):
        if not (targets[a][2] if False else True):
            pass
        n_sep = n_tot = 0
        for _ in range(reps):
            A = [gen_for(a, targets[a], lang, rng) for _ in range(rng.randint(1, 2))]
            B = [gen_for(b, targets[b], lang, rng) for _ in range(rng.randint(1, 2))]
            D = list(dict.fromkeys(A + B))
            if any(match(targets[b], s) is not None for s in A) or any(match(targets[a], s) is not None for s in B):
                continue
            n_tot += 1
            mins = MinCover(D).minimal()
            surv = [T for T in mins if not R.refuted(T, D)]
            if not surv:
                n_sep += 1
            elif len(fails) < 12:
                fails.append((a, b, [pp(d) for d in D], [pp(T) for T in surv]))
        rows.append((a, b, n_sep, n_tot))
    return rows, fails


def main():
    t0 = time.time()
    text = '# E9: refutation separation between targets\n\nCommand: `python3 experiments/e9_separation.py`.\n\n'
    out = {}
    for label, lang, targets, reps in (('PA-mix targets', 'PA', pa_targets(), 40),
                                       ('ZF-mix targets', 'ZF', zf_targets(), 15),
                                       ('PA near-miss targets', 'PA', NEAR_PA, 40),
                                       ('ZF near-miss targets', 'ZF', NEAR_ZF, 15)):
        R = TemplateRefuter(lang)
        rng = random.Random(len(label))
        rows, fails = run(lang, targets, reps, rng, R)
        tot = sum(r[3] for r in rows)
        sep = sum(r[2] for r in rows)
        bad = [r for r in rows if r[2] < r[3]]
        text += '## %s\n\n' % label
        text += ('%d target pairs, %d random cross-target merges tested, %d refuted (%.1f%%). Pairs with an '
                 'unrefuted merge:\n\n' % (len(rows), tot, sep, 100.0 * sep / max(1, tot)))
        text += md_table(['target a', 'target b', 'separated', 'tested'], [list(r) for r in bad]) if bad else 'none\n'
        if fails:
            text += '\nExamples of unrefuted cross-target merges (data; surviving minimal templates):\n\n'
            for (a, b, D, S) in fails[:6]:
                text += '* %s / %s: data `%s`; surviving `%s`\n' % (a, b, ' ; '.join(D), ' ; '.join(S))
        text += '\nRefuter: %s\n\n' % R.stats()
        out[label] = {'rows': rows, 'fails': fails}
    text += 'Wall time: %.1fs\n' % (time.time() - t0)
    save('e9_separation', text, out)
    print(text)


if __name__ == '__main__':
    main()
