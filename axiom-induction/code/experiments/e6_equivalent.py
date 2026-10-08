"""E6: deductively equivalent axiomatisations under the derivation likelihood.

Theories (commutativity of +):
  A_xy  = {forall x forall y  x+y=y+x}           A_yx = {forall y forall x  x+y=y+x}
  S_ab  = {?a+?b=?b+?a}  (closed instance schema)  M_x  = {forall x  x+?b=?b+x}   M_y = {forall y  ?a+y=y+?a}
  A_xy+A_yx, A_xy+S_ab, and Mem(D_n).
A_xy and A_yx are logically equivalent; with Gen and open elim terms all five generate the same theorems,
but with closed elim terms (used here) their derivation laws differ in the partially instantiated
outputs (forall y t+y=y+t versus forall x x+t=t+x).
Generators: the L1 chain (K = 2, c_stop = 0.5, closed elim terms) from A_xy, from M_x, and L0 citations of
S_ab.  Likelihoods: L1 (the same chain) and L1sel (the chain observed only through closed quantifier-free
outputs; the data are the generator's outputs filtered to that class).

Command: python3 e6_equivalent.py
"""
import math
import time
from multiprocessing import Pool

from common import save, md_table, fmt, parse, pp, Component, Theory
from bai.grammar import Grammar
from bai.lik import Chain, SelChain, quantifier_free
from bai.gens import cite_data, chain_data
from bai.posterior import evaluate

NS = [1, 2, 4, 8, 16, 32, 64, 128, 256]
SEEDS = [0, 1, 2, 3, 4]


def theories():
    return [Theory([parse('forall x. forall y. x+y=y+x')], 'A_xy'),
            Theory([parse('forall y. forall x. x+y=y+x')], 'A_yx'),
            Theory([parse('?a+?b=?b+?a')], 'S_ab'),
            Theory([parse('forall x. x+?b=?b+x')], 'M_x'),
            Theory([parse('forall y. ?a+y=y+?a')], 'M_y'),
            Theory([parse('forall x. forall y. x+y=y+x'), parse('forall y. forall x. x+y=y+x')], 'A_xy+A_yx'),
            Theory([parse('forall x. forall y. x+y=y+x'), parse('?a+?b=?b+?a')], 'A_xy+S_ab')]


def run(args):
    gen, seed = args
    Q = Grammar()
    ch = Chain(Q, Q, K=2, c_stop=0.5, qe_open=False)
    pool = theories()
    g = {th.name: th for th in pool}
    N = max(NS)
    if gen == 'S_ab':
        raw = cite_data(g['S_ab'], [1.0], Q, 12 * N, seed)
    else:
        raw = chain_data(g[gen], [1.0], ch, 12 * N, seed)
    out = {'gen': gen, 'seed': seed}
    data_full = raw[:N]
    # L1sel data: the generator's outputs filtered to closed quantifier-free sentences (same stream)
    data_sel = [d for d in raw if quantifier_free(d) and 'w0' not in str(d)][:N]
    assert len(data_sel) == N, len(data_sel)
    for lname, lik, data in [('L1', ch, data_full), ('L1sel', SelChain(ch), data_sel)]:
        res = evaluate(pool, data, NS, lik, Q=Q, alpha=0.5)
        out[lname] = [{k: v['post'] for k, v in r.items()} for r in res]
    out['bits'] = {th.name: round(th.bits(), 2) for th in pool}
    out['frac_qf'] = sum(1 for d in data_full if quantifier_free(d)) / len(data_full)
    return out


def main():
    t0 = time.time()
    jobs = [(g, s) for g in ['A_xy', 'M_x', 'S_ab'] for s in SEEDS]
    with Pool(4) as p:
        results = p.map(run, jobs, chunksize=1)
    names = [th.name for th in theories()] + ['Mem']
    txt = ['# E6: equivalent axiomatisations under the derivation likelihood\n',
           'Command: `cd code/experiments && python3 e6_equivalent.py`. Seeds %s. Chain: K = 2, c_stop = 0.5, '
           'closed elim terms; Dirichlet alpha = 0.5; prior 2^-bits. Wall time %.0f s.\n' % (SEEDS, time.time() - t0)]
    txt.append('Prior bits: %s\n' % results[0]['bits'])
    for gen in ['A_xy', 'M_x', 'S_ab']:
        rs = [r for r in results if r['gen'] == gen]
        txt.append('\n## Data from %s (fraction of closed quantifier-free outputs: %.2f)\n' %
                   (gen, sum(r['frac_qf'] for r in rs) / len(rs)))
        for lname in ['L1', 'L1sel']:
            rows = []
            for i, n in enumerate(NS):
                rows.append([n] + [fmt(sum(r[lname][i].get(k, 0.0) for r in rs) / len(rs)) for k in names])
            txt.append('\n**%s** (mean posterior over seeds)\n\n' % lname)
            txt.append(md_table(['n'] + names, rows))
    save('e6_equivalent', '\n'.join(txt), {'results': results})


if __name__ == '__main__':
    main()
