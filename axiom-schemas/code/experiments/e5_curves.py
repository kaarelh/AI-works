"""E5 (v2): examples to exactness, DTRC (untagged) vs the tagged DT°_F cautious verifier (with and without
refutation filtering), on streams drawn i.i.d. from a mixture.
v2: the universal axioms are observed through numerals only (stream 'PA', the task's regime); 'PA-mixed' uses
the v1 instance distribution.  Extra learners: DTRC+share (sharing pass) and the tagged learner with
membership labels (each datum under every target it instantiates).  The PA rows of different targets share
seeds and are not independent replicates.

PA stream: each Q axiom w.p. 0.02, induction 0.50, x+0=x 0.16, x*0=0 0.12, 0+x=x 0.08.
ZF stream: each of the 6 single axioms w.p. 0.03, Separation 0.30, Replacement 0.27, epsilon-induction 0.25.
For N in a grid we run the learners on the first N items; a target is exact when some cluster's (tag's)
acceptance set equals its instance set.  One refuter cache per (mix, seed) is shared across N.
"""
import random
import time
from collections import defaultdict
from common import save, md_table, TemplateRefuter, DTRC, tagged_learner, by_label, exact_for, RESULTS, membership_tags
from dtrc.syntax import parse, canon_params
from dtrc.schemas import (Q_AXIOMS, ZF_AXIOMS, U_AXIOMS, Ind, Sep, Rep, EInd, pa_targets, zf_targets)
from dtrc.datasets import pa_motive, universal_instance, zf_body

GRID = [5, 10, 20, 30, 50, 80, 120]
SEEDS = [0, 1, 2, 3, 4]
MIXES = ['PA', 'PA-mixed', 'ZF']
LEARNERS = ('dtrc', 'dtrc_share', 'tagged_ref', 'tagged', 'tagged_member')
TITLES = {'PA': 'PA, universal axioms through numerals only (main)', 'PA-mixed': 'PA, v1 instance distribution',
          'ZF': 'ZF'}


def stream(mix, seed, n):
    rng = random.Random(seed * 31337 + (2 if mix == 'ZF' else 1))
    dist = 'mixed' if mix == 'PA-mixed' else 'numerals'
    out = []
    if mix.startswith('PA'):
        kinds = [(k, 0.02) for k in Q_AXIOMS] + [('Ind', 0.5), ('U_add0', 0.16), ('U_mul0', 0.12), ('U_0add', 0.08)]
    else:
        kinds = [(k, 0.03) for k in ZF_AXIOMS] + [('Sep', 0.30), ('Rep', 0.27), ('EInd', 0.25)]
    names = [k for k, _ in kinds]
    w = [p for _, p in kinds]
    for _ in range(n):
        k = rng.choices(names, w)[0]
        if k in Q_AXIOMS:
            s = parse(Q_AXIOMS[k])
        elif k in ZF_AXIOMS:
            s = parse(ZF_AXIOMS[k])
        elif k == 'Ind':
            s = Ind(pa_motive(rng))
        elif k in U_AXIOMS:
            s = universal_instance(rng, U_AXIOMS[k], dist=dist)
        elif k == 'Sep':
            s = Sep(zf_body(rng, 2, [0]))
        elif k == 'Rep':
            s = Rep(zf_body(rng, 3, [0, 1]))
        else:
            s = EInd(zf_body(rng, 1, [0]))
        out.append((s, k))
    return out


def main():
    t0 = time.time()
    res = {}
    rows = []
    for mix in MIXES:
        lang = 'ZF' if mix == 'ZF' else 'PA'
        targets = pa_targets() if lang == 'PA' else zf_targets()
        res[mix] = defaultdict(dict)
        for seed in SEEDS:
            full = stream(mix, seed, max(GRID))
            R = TemplateRefuter(lang)
            for N in GRID:
                data = full[:N]
                calls0 = R.oracle.calls
                t = time.time()
                m = DTRC(R).fit([s for s, _ in data])
                dt = time.time() - t
                ex_dtrc = {k: any(c.acc and exact_for(c.acc, T) for c in m.clusters) for k, T in targets.items()}
                calls1 = R.oracle.calls
                ms = DTRC(R, share=True).fit([s for s, _ in data])
                ex_share = {k: any(c.acc and exact_for(c.acc, T) for c in ms.clusters) for k, T in targets.items()}
                tags = by_label(data)
                tl_ref = tagged_learner(tags, refuter=R)
                tl_raw = tagged_learner(tags)
                tl_mem = tagged_learner(membership_tags(data, targets), refuter=R)
                ex_tr = {k: (k in tl_ref and exact_for(tl_ref[k]['acc'], T)) for k, T in targets.items()}
                ex_t = {k: (k in tl_raw and exact_for(tl_raw[k]['acc'], T)) for k, T in targets.items()}
                ex_m = {k: (k in tl_mem and exact_for(tl_mem[k]['acc'], T)) for k, T in targets.items()}
                res[mix][seed][N] = {'dtrc': ex_dtrc, 'dtrc_share': ex_share, 'tagged_ref': ex_tr, 'tagged': ex_t,
                                     'tagged_member': ex_m, 'time': dt,
                                     'calls': calls1 - calls0, 'clusters': len(m.clusters)}
    # aggregate
    text = '# E5: examples to exactness (DTRC vs tagged)\n\n'
    text += 'Command: `python3 experiments/e5_curves.py`; seeds %s; grid N = %s.\n\n' % (SEEDS, GRID)
    plotdata = {}
    for mix in MIXES:
        targets = zf_targets() if mix == 'ZF' else pa_targets()
        rows = []
        plotdata[mix] = {}
        for learner in LEARNERS:
            means = []
            for N in GRID:
                v = [sum(res[mix][s][N][learner].values()) for s in SEEDS]
                means.append(sum(v) / len(v))
            plotdata[mix][learner] = means
            rows.append([learner] + ['%.1f' % x for x in means])
        rows.append(['time DTRC (s)'] + ['%.1f' % (sum(res[mix][s][N]['time'] for s in SEEDS) / len(SEEDS))
                                          for N in GRID])
        rows.append(['oracle calls DTRC'] + ['%d' % (sum(res[mix][s][N]['calls'] for s in SEEDS) / len(SEEDS))
                                             for N in GRID])
        text += '## %s (mean number of exact targets out of %d)\n\n' % (TITLES[mix], len(targets))
        text += md_table(['learner'] + ['N=%d' % N for N in GRID], rows)
        # first N from which exact (stably) per target
        prow = []
        for k in targets:
            cells = []
            for learner in LEARNERS:
                firsts = []
                for s in SEEDS:
                    f = None
                    for i, N in enumerate(GRID):
                        if all(res[mix][s][M][learner][k] for M in GRID[i:]):
                            f = N
                            break
                    firsts.append(f if f is not None else '>%d' % GRID[-1])
                cells.append(','.join(str(x) for x in firsts))
            prow.append([k] + cells)
        text += '\nFirst grid N from which the target stays exact (per seed):\n\n'
        text += md_table(['target', 'DTRC', 'DTRC+share', 'tagged + refutation', 'tagged', 'tagged (membership)'], prow)
        text += '\n'
    text += 'Wall time: %.1fs\n' % (time.time() - t0)
    save('e5_curves', text, {'grid': GRID, 'plot': plotdata})
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        fig, axes = plt.subplots(1, 3, figsize=(12.5, 3.6))
        styles = {'dtrc': ('DTRC (untagged)', '#2a78d6', '-', 'o'),
                  'dtrc_share': ('DTRC + sharing pass', '#7a4fd0', '-.', 'D'),
                  'tagged_ref': ('tagged + refutation (gold labels)', '#eb6834', '--', 's'),
                  'tagged_member': ('tagged (membership labels)', '#1baf7a', ':', '^')}
        for ax, mix in zip(axes, MIXES):
            nt = len(zf_targets() if mix == 'ZF' else pa_targets())
            for learner, (lab, col, ls, mk) in styles.items():
                ax.plot(GRID, plotdata[mix][learner], ls, color=col, marker=mk, label=lab, linewidth=1.8,
                        markersize=4)
            ax.set_xscale('log')
            ax.set_xticks(GRID)
            ax.set_xticklabels([str(g) for g in GRID])
            ax.set_ylim(0, nt + 0.5)
            ax.axhline(nt, color='#bbbbbb', linewidth=0.8)
            ax.set_title('%s (%d targets)' % (TITLES[mix], nt), fontsize=9)
            ax.set_xlabel('number of examples N')
            ax.spines['top'].set_visible(False)
            ax.spines['right'].set_visible(False)
        axes[0].set_ylabel('targets learned exactly (mean of %d seeds)' % len(SEEDS))
        axes[2].legend(frameon=False, fontsize=8, loc='lower right')
        fig.tight_layout()
        fig.savefig(RESULTS + '/e5_curves.png', dpi=150)
    except ImportError:
        pass
    print(text)


if __name__ == '__main__':
    main()
