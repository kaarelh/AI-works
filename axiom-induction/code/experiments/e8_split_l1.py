"""E8: does a derivation likelihood change the MDL split finding?  A schema against its root split under the
chain derivation likelihood L1 with latent citations (added after the referee, M5).

Theories (phi(t) = t+0=t, psi(t) = 0+t=t):
  whole = {phi(?t), psi(?t), phi(?t) -> psi(?t)}
  split = {phi(0), phi(S?z), phi(?a+?b), phi(?a*?b), psi(?t), phi(?t) -> psi(?t)}   (phi split by the root of t)
Under L1 (K = 1, c_stop = 1/2) a citation of phi(t) either stops (datum phi(t)) or applies MP with the cited
conditional (datum psi(t)); psi(t) can also be cited directly, so the component behind a psi-datum is latent.
The split's components have disjoint instance sets whose union is inst(phi(?t)); the conditional is not split.

Generators (chain data from `whole` with fixed weights (0.5, 0.25, 0.25)):
  wellspec  bodies from the model's Q (default Grammar);
  skew      bodies from skewQ (term root law 0: .5, S: .1, +: .2, *: .2; the model's Q is the default).
Likelihoods: L1 (the generating chain with the default Q: well specified for wellspec) and L0 (citation).
Reported: (i) the exact tie at matched fixed weights: the split with weights w_phi * q_r (q_r = Q's root
probabilities) has the same probability as the whole on every datum, under L1 (max |difference| of log
probabilities over all data); (ii) the log2 Bayes factor split : whole with Dirichlet(1/2) weights, mean over
seeds, at n = 16 ... 4096, without the prior (the prior adds a constant in favour of the whole).
Predictions (track model Prop 5.6, L0 Prop 5.4): wellspec: -((4-1)/2) log2 n + O(1), i.e. -1.5 bits per doubling
of n; skew: linear growth.

Command: python3 e8_split_l1.py
"""
import math
import time
from multiprocessing import Pool

from common import save, md_table, fmt, parse, pp, Component, Theory
from bai.grammar import Grammar, LN2
from bai.lik import Chain, dirichlet_marginal, logcoefs0
from bai.gens import chain_data
from bai.pool import specialise, term_patterns

NS = [16, 64, 256, 1024, 4096]
SEEDS = list(range(10))
W = [0.5, 0.25, 0.25]
P = parse('?t+0=?t')
PSI = parse('0+?t=?t')
MPC = parse('?t+0=?t -> 0+?t=?t')


def theories():
    whole = Theory([P, PSI, MPC], 'whole')
    split = Theory([specialise(P, 't', p) for p in term_patterns(1)] + [PSI, MPC], 'split')
    return whole, split


def root_probs(Q):
    """Q's root probabilities for a closed term (context without variables or parameter)"""
    z = sum(Q.term_w.values())
    return {h: w / z for h, w in Q.term_w.items()}


def run(args):
    gen, seed = args
    t0 = time.time()
    Q = Grammar()
    Qs = Grammar(term_w={'0': 0.5, 'S': 0.1, '+': 0.2, '*': 0.2})
    whole, split = theories()
    gch = Chain(Q if gen == 'wellspec' else Qs, Q if gen == 'wellspec' else Qs, K=1, c_stop=0.5, qe_open=False)
    data = chain_data(whole, W, gch, max(NS), seed)
    ch = Chain(Q, Q, K=1, c_stop=0.5, qe_open=False)
    out = {'gen': gen, 'seed': seed}
    # (i) exact tie at matched fixed weights under L1
    q = root_probs(Q)
    wsplit = []
    for c in split.comps:
        if c.T == whole.comps[1].T:
            wsplit.append(W[1])
        elif c.T == whole.comps[2].T:
            wsplit.append(W[2])
        else:
            wsplit.append(W[0] * q[c.T[2][0]])      # phi(f(..)) = (f(..)+0 = f(..)): root of the right side
    assert abs(sum(wsplit) - 1) < 1e-12, wsplit
    worst = 0.0
    for d in data[:2000]:
        cw = ch.logcoefs(whole, d)
        cs = ch.logcoefs(split, d)
        pw = sum(W[i] * math.exp(v) for i, v in cw.items())
        ps = sum(wsplit[i] * math.exp(v) for i, v in cs.items())
        if pw > 0 or ps > 0:
            worst = max(worst, abs(math.log(pw) - math.log(ps)))
    out['tie_maxdiff'] = worst
    from dtrc.templates import match
    out['frac'] = {'phi': sum(1 for d in data if match(P, d) is not None) / len(data),
                   'psi': sum(1 for d in data if match(PSI, d) is not None) / len(data),
                   'imp': sum(1 for d in data if d[0] == 'imp') / len(data)}
    # (ii) Bayes factors with Dirichlet weights
    for lname in ('L1', 'L0'):
        if lname == 'L1':
            cw = [ch.logcoefs(whole, d) for d in data]
            cs = [ch.logcoefs(split, d) for d in data]
        else:
            cw = [logcoefs0(whole, d, Q) for d in data]
            cs = [logcoefs0(split, d, Q) for d in data]
        out[lname] = [(dirichlet_marginal(cs[:n], len(split.comps), 0.5)
                       - dirichlet_marginal(cw[:n], len(whole.comps), 0.5)) / LN2 for n in NS]
    out['prior_diff_bits'] = split.bits() - whole.bits()
    out['time'] = round(time.time() - t0, 1)
    return out


def main():
    t0 = time.time()
    jobs = [(g, s) for g in ('wellspec', 'skew') for s in SEEDS]
    with Pool(4) as p:
        res = p.map(run, jobs, chunksize=1)
    txt = ['# E8: a schema against its root split under the chain derivation likelihood (L1) and under L0\n',
           'Command: `cd code/experiments && python3 e8_split_l1.py`. Seeds %s. Wall time %.0f s.\n' % (SEEDS, time.time() - t0),
           'whole = {phi(?t), psi(?t), phi(?t) -> psi(?t)} with phi(t) = t+0=t, psi(t) = 0+t=t; split = phi split by '
           'the root of t (4 templates) + psi(?t) + the conditional. Data: the L1 chain (K = 1, c_stop = 1/2) from '
           'whole with fixed weights %s; bodies from Q (wellspec) or from skewQ (skew). Prior difference split - '
           'whole: %.1f bits (not included below).\n' % (W, res[0]['prior_diff_bits'])]
    txt.append('\n(i) Exact tie at matched fixed weights (split weights w_phi q_r), L1: max |log P_split(d) - log '
               'P_whole(d)| over the first 2000 data of every run: %.2e.\n' % max(r['tie_maxdiff'] for r in res))
    for g in ('wellspec', 'skew'):
        rs = [r for r in res if r['gen'] == g]
        txt.append('\n## %s (data fractions: phi-instances %.2f, psi-instances %.2f, conditionals %.2f)\n\n' % (
            g, sum(r['frac']['phi'] for r in rs) / len(rs), sum(r['frac']['psi'] for r in rs) / len(rs),
            sum(r['frac']['imp'] for r in rs) / len(rs)))
        rows = []
        for i, n in enumerate(NS):
            row = [n]
            for lname in ('L1', 'L0'):
                v = [r[lname][i] for r in rs]
                row.append('%s (%s to %s)' % (fmt(sum(v) / len(v), 2), fmt(min(v), 1), fmt(max(v), 1)))
            rows.append(row)
        sl = []
        for lname in ('L1', 'L0'):
            a = sum(r[lname][-2] for r in rs) / len(rs)
            b = sum(r[lname][-1] for r in rs) / len(rs)
            sl.append((b - a) / 2.0)
        txt.append(md_table(['n', 'log2 BF split:whole, L1 (mean, range)', 'L0'], rows))
        txt.append('\nMean change per doubling of n between n = 1024 and 4096: L1 %.2f bits, L0 %.2f bits.\n' % tuple(sl))
        if g == 'skew':
            txt.append('Mean gain per datum at n = 4096: L1 %.4f bits, L0 %.4f bits.\n' % (
                sum(r['L1'][-1] for r in rs) / len(rs) / NS[-1], sum(r['L0'][-1] for r in rs) / len(rs) / NS[-1]))
    save('e8_split_l1', '\n'.join(txt), {'results': res})


if __name__ == '__main__':
    main()
