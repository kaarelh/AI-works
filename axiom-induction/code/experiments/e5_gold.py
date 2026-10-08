"""E5: Gold-type questions for the Bayesian learner.

(a) Spare slots.  Data from H_sch = {phi(?t)} (L0 citations, default Q).  Exact log2 Bayes factors of
    T + spare against T, for spare = a false ground sentence (0=S0, never cited), a disjoint true schema
    (?u*0=0, never matched), and the nested template phi(S?z) (whose instances are also instances of
    phi(?t), so data can be attributed to either).  Prediction for an unused component (Dirichlet alpha):
    log BF = log[Gamma(2a)Gamma(a+n)/(Gamma(a)Gamma(2a+n))] - (extra prior bits) ~ -a log n - bits.
(b) L_infinity versus L_k.  Numerals only: Q_num gives S^j 0 probability (1-s) s^j, s = 1/2.
    L_k = {phi(S^j 0) : j < k} (k ground sentences, Dirichlet weights), k = 1..40, and
    L_inf = {phi(?t)} with Q_num.  Prior 2^-bits.  Data i.i.d. from L_5 (uniform over its 5 sentences) or
    from L_inf.  Posterior mass on L_5, L_inf and the MAP, against n.
(c) Gold's adversarial text for L_inf against the MAP learner over {L_1, ..., L_60, L_inf}: stage i
    presents the elements of L_i round-robin until the MAP is L_i; the stage lengths are reported.  The
    text is a text for L_inf (every phi(S^j 0) appears), and the MAP changes at every stage.

Command: python3 e5_gold.py
"""
import math
import random
import time

from common import save, md_table, fmt, parse, pp, Component, Theory, num
from bai.grammar import Grammar, LN2
from bai.lik import dirichlet_marginal, logcoefs0
from bai.gens import cite_data
from bai.pool import specialise
from dtrc.templates import instantiate

SEEDS = list(range(10))
DRAWS_A2 = 1000
NS_A = [1, 4, 16, 64, 256, 1024, 4096]
ALPHA = 0.5


def part_a():
    Q = Grammar()
    P = parse('?t+0=?t')
    base = Theory([Component(P)], 'T')
    spares = {'false sentence 0=S0': Theory([Component(P), parse('0=S0')], 'T+false'),
              'disjoint schema ?u*0=0': Theory([Component(P), parse('?u*0=0')], 'T+disjoint'),
              'nested phi(S?z)': Theory([Component(P), specialise(P, 't', ('S', ('M', 'z', ())))], 'T+nested')}
    out = {k: {n: [] for n in NS_A} for k in spares}
    prior_diff = {k: th.bits() - base.bits() for k, th in spares.items()}
    for seed in SEEDS:
        data = cite_data(base, [1.0], Q, max(NS_A), seed)
        cb = [logcoefs0(base, d, Q) for d in data]
        for k, th in spares.items():
            cs = [logcoefs0(th, d, Q) for d in data]
            for n in NS_A:
                lbf = (dirichlet_marginal(cs[:n], 2, ALPHA) - dirichlet_marginal(cb[:n], 1, ALPHA)) / LN2
                out[k][n].append(lbf)
    rows = []
    lg = math.lgamma
    for k in spares:
        for n in NS_A:
            v = out[k][n]
            pred = (lg(2 * ALPHA) + lg(ALPHA + n) - lg(ALPHA) - lg(2 * ALPHA + n)) / LN2
            rows.append([k, n, fmt(sum(v) / len(v), 2), fmt(min(v), 2), fmt(max(v), 2), fmt(pred, 2),
                         fmt(sum(v) / len(v) - prior_diff[k], 2)])
    # slope of the mean log BF against log2 n between n = 256 and 4096
    slopes = {}
    for k in spares:
        a = sum(out[k][256]) / len(SEEDS)
        b = sum(out[k][4096]) / len(SEEDS)
        slopes[k] = (b - a) / (math.log2(4096) - math.log2(256))
    return rows, slopes, prior_diff, out


def nested_bf_quadrature(n, nS, qS, alpha=ALPHA):
    """log2 Bayes factor of {phi(?t), phi(S?z)} against {phi(?t)} given n data of which nS have an S-rooted
    term: under the two-component theory a datum has probability Q(t) (w1 + w2/qS) if S-rooted and
    Q(t) w1 otherwise (Q(S t') = qS Q(t')), so BF = E_{w2 ~ Beta(a,a)} [(1 - w2 + w2/qS)^nS (1 - w2)^(n-nS)].
    Computed by quadrature in log space on a grid refined near w2 = 0."""
    import numpy as np
    from scipy.special import gammaln, betaln
    # substitution w2 = u^(1/alpha) removes the endpoint singularity of the Beta density at 0
    m = 200001
    u = np.linspace(0.0, 1.0, m)[1:-1]
    w = u ** (1.0 / alpha)
    # Beta(a,a) density dw = w^(a-1)(1-w)^(a-1)/B dw; with w = u^(1/a): w^(a-1) dw = (1/a) du
    logf = nS * np.log1p(w * (1.0 / qS - 1.0)) + (n - nS) * np.log1p(-w) + (alpha - 1) * np.log1p(-w) \
        - np.log(alpha) - betaln(alpha, alpha)
    mx = logf.max()
    val = mx + np.log(np.trapezoid(np.exp(logf - mx), u))
    return float(val / np.log(2))


def part_a2():
    """nested spare slot at large n by quadrature; nS ~ Binomial(n, qS) per seed"""
    import numpy as np
    Q = Grammar()
    qS = math.exp(Q.logq_term(('S', ('0',))) - Q.logq_term(('0',)))      # root probability of S
    rows = []
    rng = np.random.default_rng(0)
    ns = [10 ** k for k in range(2, 9)]
    means, ses = [], []
    for n in ns:
        vals = np.array([nested_bf_quadrature(n, int(rng.binomial(n, qS)), qS) for _ in range(DRAWS_A2)])
        means.append(float(vals.mean()))
        ses.append(float(vals.std(ddof=1) / math.sqrt(len(vals))))
        rows.append([n, fmt(float(vals.mean()), 3), fmt(ses[-1], 3), fmt(float(vals.min()), 2), fmt(float(vals.max()), 2)])
    # cross-check: quadrature against the exact Dirichlet DP of part (a) on two seeded data sets (n = 500)
    from bai.lik import dirichlet_marginal, logcoefs0
    P = parse('?t+0=?t')
    base = Theory([Component(P)], 'T')
    th = Theory([Component(P), specialise(P, 't', ('S', ('M', 'z', ())))], 'T+nested')
    check = []
    for seed in (3, 4):
        data = cite_data(base, [1.0], Q, 500, seed)
        nS = sum(1 for d in data if d[1][1][0] == 'S')
        ex = (dirichlet_marginal([logcoefs0(th, d, Q) for d in data], 2, ALPHA)
              - dirichlet_marginal([logcoefs0(base, d, Q) for d in data], 1, ALPHA)) / LN2
        check.append((seed, round(ex, 5), round(nested_bf_quadrature(500, nS, qS), 5)))
    def ls_slope(idx):
        xs = [math.log2(ns[i]) for i in idx]
        ys = [means[i] for i in idx]
        mx = sum(xs) / len(xs)
        sxx = sum((x - mx) ** 2 for x in xs)
        cs = [(x - mx) / sxx for x in xs]
        b = sum(c * y for c, y in zip(cs, ys))
        se = math.sqrt(sum((c * ses[i]) ** 2 for c, i in zip(cs, idx)))
        return round(float(b), 4), round(float(se), 4)
    slopes = {'per decade (per log2 n)': [round(float((means[i + 1] - means[i]) / math.log2(10)), 3)
                                          for i in range(len(ns) - 1)],
              'least-squares slope against log2 n, n = 1e2..1e8 (slope, s.e. from the draws)': ls_slope(range(len(ns))),
              'least-squares slope, n = 1e4..1e8': ls_slope(range(2, len(ns))),
              'check (seed, exact DP, quadrature) at n=500': check}
    return rows, qS, slopes


def chain_theories(phi, kmax, Qnum):
    Ls = []
    for k in range(1, kmax + 1):
        Ls.append(Theory([instantiate(phi, {'t': num(j)}) for j in range(k)], 'L_%d' % k))
    Linf = Theory([Component(phi)], 'L_inf')
    return Ls, Linf


def posterior_chain(Ls, Linf, data, Qnum, ns):
    """posterior over {L_k} + L_inf at each n (incremental counts for the ground theories)"""
    res = []
    lps = {th.name: -th.bits() * LN2 for th in Ls + [Linf]}
    # L_inf: per-datum log Q
    linf = [Linf.comps[0].logcoef0(d, Qnum) for d in data]
    idx = {}
    for th in Ls:
        idx[th.name] = {c.T: i for i, c in enumerate(th.comps)}
    lg = math.lgamma
    for n in ns:
        post = {}
        post['L_inf'] = lps['L_inf'] + sum(linf[:n])
        for th in Ls:
            m = len(th.comps)
            counts = [0] * m
            ok = True
            for d in data[:n]:
                i = idx[th.name].get(d)
                if i is None:
                    ok = False
                    break
                counts[i] += 1
            if not ok:
                continue
            lm = lg(m * ALPHA) - lg(m * ALPHA + n) + sum(lg(ALPHA + c) - lg(ALPHA) for c in counts)
            post[th.name] = lps[th.name] + lm
        z = max(post.values())
        tot = sum(math.exp(v - z) for v in post.values())
        res.append({k: math.exp(v - z) / tot for k, v in post.items()})
    return res


def part_b():
    s = 0.5
    Qnum = Grammar(term_w={'0': 1 - s, 'S': s})
    phi = parse('?t+0=?t')
    Ls, Linf = chain_theories(phi, 40, Qnum)
    ns = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048]
    rows = {}
    for src in ['L_5', 'L_inf']:
        acc = {n: {'L_5': 0.0, 'L_inf': 0.0, 'map': {}} for n in ns}
        for seed in SEEDS:
            rng = random.Random(seed)
            if src == 'L_5':
                data = [instantiate(phi, {'t': num(rng.randrange(5))}) for _ in range(max(ns))]
            else:
                data = cite_data(Linf, [1.0], Qnum, max(ns), seed)
            res = posterior_chain(Ls, Linf, data, Qnum, ns)
            for n, r in zip(ns, res):
                acc[n]['L_5'] += r.get('L_5', 0.0) / len(SEEDS)
                acc[n]['L_inf'] += r.get('L_inf', 0.0) / len(SEEDS)
                mp = max(r, key=r.get)
                acc[n]['map'][mp] = acc[n]['map'].get(mp, 0) + 1
        rows[src] = [[n, fmt(acc[n]['L_5']), fmt(acc[n]['L_inf']),
                      ', '.join('%s x%d' % kv for kv in sorted(acc[n]['map'].items(), key=lambda kv: -kv[1]))]
                     for n in ns]
    bits = {th.name: round(th.bits(), 1) for th in Ls[:8] + [Linf]}
    return rows, bits


def part_c(stages=14, cap=200000):
    s = 0.5
    Qnum = Grammar(term_w={'0': 1 - s, 'S': s})
    phi = parse('?t+0=?t')
    Ls, Linf = chain_theories(phi, 60, Qnum)
    lps = {th.name: -th.bits() * LN2 for th in Ls + [Linf]}
    lg = math.lgamma
    data_counts = {}
    n = 0
    linf_sum = 0.0
    lengths = []
    for i in range(1, stages + 1):
        start = n
        j = 0
        while True:
            d = instantiate(phi, {'t': num(j % i)})
            j += 1
            n += 1
            data_counts[d] = data_counts.get(d, 0) + 1
            linf_sum += Linf.comps[0].logcoef0(d, Qnum)
            # MAP over theories consistent with the data
            best, bestv = 'L_inf', lps['L_inf'] + linf_sum
            maxj = max(int(pp(x).split('+')[0]) if pp(x).split('+')[0].isdigit() else 0 for x in data_counts)
            for th in Ls:
                m = len(th.comps)
                if m <= maxj and not all(x in {c.T for c in th.comps} for x in data_counts):
                    continue
                cset = {c.T for c in th.comps}
                if not all(x in cset for x in data_counts):
                    continue
                lm = lg(m * ALPHA) - lg(m * ALPHA + n) + sum(lg(ALPHA + data_counts.get(c.T, 0)) - lg(ALPHA)
                                                              for c in th.comps)
                v = lps[th.name] + lm
                if v > bestv:
                    best, bestv = th.name, v
            if best == 'L_%d' % i or n - start > cap:
                break
        lengths.append([i, n - start, n, best])
    return lengths


def main():
    t0 = time.time()
    rows_a, slopes, prior_diff, raw = part_a()
    rows_a2, qS, slopes_a2 = part_a2()
    rows_b, bits_b = part_b()
    rows_c = part_c()
    txt = ['# E5: spare slots, L_inf versus L_k, and Gold\'s text\n',
           'Command: `cd code/experiments && python3 e5_gold.py`. Seeds %s. Dirichlet alpha = %.1f. '
           'Wall time %.0f s.\n' % (SEEDS, ALPHA, time.time() - t0)]
    txt.append('\n## (a) Spare slots: log2 Bayes factor of T + spare against T = {x+0=x schema}\n\n'
               'Data: L0 citations of phi(?t), default Q. "pred. (Dirichlet only)" is the exact Dirichlet factor '
               'for a never-used component, log2[Gamma(2a)Gamma(a+n)/(Gamma(a)Gamma(2a+n))]; the log BF of an '
               'unused spare equals it exactly (likelihoods agree on every datum). The prior bits are not '
               'included in the Bayes factor; the posterior odds add -(extra prior bits): %s.\n\n'
               % {k: round(v, 1) for k, v in prior_diff.items()})
    txt.append(md_table(['spare', 'n', 'mean log2 BF', 'min', 'max', 'pred. (Dirichlet only)',
                         'posterior log2 odds (mean)'], rows_a))
    txt.append('\nSlope of the mean log2 BF against log2 n between n = 256 and 4096: %s\n'
               % {k: round(v, 3) for k, v in slopes.items()})
    txt.append('\n## (a2) Nested spare slot at large n (quadrature)\n\n'
               'Under {phi(?t), phi(S?z)} a datum phi(t) has probability Q(t)(w1 + w2/qS) if t is S-rooted and '
               'Q(t) w1 otherwise, with qS = %.3f the root probability of S; so the Bayes factor against {phi(?t)} '
               'depends only on n and the number nS of S-rooted data: BF = E[(1 - w2 + w2/qS)^nS (1 - w2)^(n - nS)], '
               'w2 ~ Beta(1/2, 1/2). nS ~ Binomial(n, qS), %d draws per n (numpy seed 0); log2 BF by quadrature '
               '(substitution w2 = u^2, 2e5-point trapezoid rule). The cross-check against the exact DP is listed '
               'with the slopes below. The standard errors of the slopes are propagated from the per-n standard '
               'errors of the means (independent draws per n).\n\n' % (qS, DRAWS_A2))
    txt.append(md_table(['n', 'mean log2 BF', 's.e. of the mean', 'min', 'max'], rows_a2))
    txt.append('\nSlopes of the mean log2 BF against log2 n: %s\n' % slopes_a2)
    for src, rows in rows_b.items():
        txt.append('\n## (b) Data from %s: posterior over {L_1..L_40, L_inf}\n\n' % src)
        txt.append('Q_num: P(S^j 0) = 2^-(j+1). Prior bits: %s.\n\n' % bits_b)
        txt.append(md_table(['n', 'mass L_5', 'mass L_inf', 'MAP (count over seeds)'], rows))
    txt.append('\n## (c) Gold\'s text for L_inf against the MAP learner over {L_1..L_60, L_inf}\n\n'
               'Stage i presents phi(0), ..., phi(S^(i-1) 0) round-robin until the MAP is L_i.\n\n')
    txt.append(md_table(['stage i', 'data in stage', 'total data', 'MAP at end of stage'], rows_c))
    save('e5_gold', '\n'.join(txt), {'a': rows_a, 'a2': rows_a2, 'a2_slopes': slopes_a2, 'a_raw': {k: {str(n): v for n, v in d.items()} for k, d in raw.items()},
                                     'slopes': slopes, 'b': rows_b, 'c': rows_c})


if __name__ == '__main__':
    main()
