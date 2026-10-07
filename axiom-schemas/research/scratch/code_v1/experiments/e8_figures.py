"""E8: figures from the saved results of E1 and E2 (E5 draws its own figure).
Colors: the validated reference categorical palette (slots 1-4), plus marker/line-style secondary encoding.
"""
import json
import os
from common import RESULTS

C = ['#2a78d6', '#eb6834', '#1baf7a', '#eda100']


def fig_e1(plt):
    d = json.load(open(os.path.join(RESULTS, 'e1_universal.json')))
    heads = {'mixed': {'S': 0.65, '0': 0.1, '+': 0.05, '*': 0.05, 'param': 0.15},
             'numerals': {'S': 7 / 8, '0': 1 / 8}}
    fig, ax = plt.subplots(figsize=(5.2, 3.4))
    Ns = list(range(1, 31))
    for i, mode in enumerate(('mixed', 'numerals')):
        cnt = {int(k): v for k, v in d[mode + ':x+0=x']['dt'].items()}
        tot = sum(cnt.values())
        emp = [sum(v for k, v in cnt.items() if k <= N) / tot for N in Ns]
        pred = [1 - sum(p ** N for p in heads[mode].values()) for N in Ns]
        ax.plot(Ns, pred, '-', color=C[i], linewidth=1.8, label='%s: predicted' % mode)
        ax.plot(Ns, emp, 'o', color=C[i], markersize=4, markerfacecolor='white', markeredgewidth=1.4,
                label='%s: observed (2000 runs)' % mode)
    ax.set_xlabel('number of instances N')
    ax.set_ylabel('P(learner exact after N)')
    ax.set_ylim(0, 1.02)
    ax.set_title('Learning x+0=x from instances t+0=t', fontsize=10)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.legend(frameon=False, fontsize=8, loc='lower right')
    fig.tight_layout()
    fig.savefig(os.path.join(RESULTS, 'e1_anchor_cdf.png'), dpi=150)


def fig_e2(plt):
    d = json.load(open(os.path.join(RESULTS, 'e2_schemas.json')))
    rows = d['exact']
    fig, ax = plt.subplots(figsize=(5.2, 3.4))
    markers = ['o', 's', '^', 'D']
    for i, name in enumerate(('Sep', 'Rep', 'EInd', 'Ind')):
        pts = [(r[1], int(r[2].split('/')[0]) / int(r[2].split('/')[1])) for r in rows if r[0] == name]
        xs, ys = zip(*pts)
        ax.plot(xs, ys, '-', color=C[i], marker=markers[i], markersize=4, linewidth=1.8, label=name)
    ax.set_xlabel('number of tagged instances N')
    ax.set_ylabel('fraction of runs exact (DT°_F)')
    ax.set_ylim(0, 1.05)
    ax.set_title('Tagged DT°_F learner, 30 runs per N', fontsize=10)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.legend(frameon=False, fontsize=8, loc='lower right')
    fig.tight_layout()
    fig.savefig(os.path.join(RESULTS, 'e2_exactness.png'), dpi=150)


def main():
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    fig_e1(plt)
    fig_e2(plt)
    print('figures written to', RESULTS)


if __name__ == '__main__':
    main()
