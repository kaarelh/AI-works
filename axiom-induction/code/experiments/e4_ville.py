"""E4: the threshold verifier against an adaptive prover; empirical soundness versus the Ville bound.

Verifier: accept s iff the posterior mass of {T : T |-_1 s} is >= 1 - delta.  A prover wins if some s
with T* |/-_1 s is ever accepted (T* = the data generator's theory).  The bound (adapted from
inferential-learning, Thm caution:ville(b); research notes Prop. X5): if the data are i.i.d. from the
model of T*, P(win) <= delta / w([T*]) uniformly over provers and times, where [T*] is the set of pool
theories with the same data law as T*.

(A) Tight two-hypothesis construction (inferential-learning Prop. caution:tight, in theory form):
    T* = {phi(?t)} with numerals only and P(t = 0) = 1 - u; T' = {phi(0), 0=S0}; prior w* on T*.
    delta = w* delta'.  The prover queries 0=S0 every round.  Reported: the exact win probability
    (1-u)^t*, a closed-form Monte Carlo of the game (1e5 streams), the full pipeline (evaluate + Deriver +
    threshold) on 400 seeded streams where t* <= 200, and the bound delta'.
(A') The same with misspecified (selected) data: only phi(0) is ever shown.
(B) Pool, well specified: the E1 pool for phi = x+0=x (hand alternatives + Mem), data L0 citations of
    phi(?t); likelihoods L0 and L1 (closed elim, K = 1); prior 2^-bits normalised over the pool.  The
    prover queries, every round, a fixed list of statements underivable from T*.
(C) Pool, misspecified: (C1) 10% of the data replaced by false near misses t+0=St (mistakes); the pool also
    contains {phi(?t), ?t+0=S?t}; (C2) heavy-tailed terms; (C3) selection (only phi(0)) with the decoy T'
    added to the pool.

Command: python3 e4_ville.py
"""
import math
import random
import time
from multiprocessing import Pool

from common import save, md_table, fmt, parse, pp, Component, Theory, num, ZERO, S, e1_hand_pool, dedupe
from bai.grammar import Grammar, LN2
from bai.lik import Chain, l1_exact_supported
from bai.gens import cite_data, heavy_term, schema_data_with_terms
from bai.posterior import evaluate, Deriver, support_mass
from dtrc.templates import instantiate

ALPHA = 0.5
P = parse('?t+0=?t')
BAD = parse('0=S0')


# ------------------------------------------------------------------------------------ (A)
def tight_exact(u, wstar, deltap, nmax=100000):
    """exact win probability (1-u)^t*, t* = first n at which pi(T*|phi(0)^n) <= delta"""
    delta = wstar * deltap
    lg = math.lgamma
    for n in range(1, nmax):
        lL1 = lg(2 * ALPHA) + lg(ALPHA + n) - lg(ALPHA) - lg(2 * ALPHA + n)
        lLs = n * math.log(1 - u)
        # pi(T*|D) = w* Ls / (w* Ls + (1-w*) L1)
        x = math.log(wstar) + lLs
        y = math.log(1 - wstar) + lL1
        post = 1.0 / (1.0 + math.exp(y - x))
        if post <= delta:
            return n, (1 - u) ** n
    return None, 0.0


def tight_pipeline(args):
    """win count of the full pipeline (evaluate + Deriver + threshold) over `trials` seeded data streams"""
    u, wstar, deltap, trials, seed0, selected = args
    Qu = Grammar(term_w={'0': 1 - u, 'S': u})
    Ts = Theory([Component(P)], 'T*', {'log_prior': math.log(wstar)})
    Tp = Theory([instantiate(P, {'t': ZERO}), BAD], "T'", {'log_prior': math.log(1 - wstar)})
    delta = wstar * deltap
    tstar, _ = tight_exact(u, wstar, deltap)
    horizon = tstar + 5
    der = Deriver(K=1, Q=Qu)
    wins = 0
    for tr in range(trials):
        if selected:
            data = [instantiate(P, {'t': ZERO})] * horizon
        else:
            data = cite_data(Ts, [1.0], Qu, horizon, seed0 + tr)
        ns = list(range(1, horizon + 1))
        res_all = evaluate([Ts, Tp], data, ns, 'L0', Q=Qu, alpha=ALPHA, with_mem=False)
        if any(support_mass(r, [], der, BAD) >= 1 - delta for r in res_all):
            wins += 1
    return wins


def tight_fast(u, wstar, deltap, trials, seed):
    """Monte Carlo of the same game using the closed form: the prover wins iff the first t* data are
    phi(0) (T' dies at the first other datum, and before t* the posterior of T* exceeds delta)"""
    tstar, _ = tight_exact(u, wstar, deltap)
    rng = random.Random(seed)
    wins = 0
    for _ in range(trials):
        if all(rng.random() < 1 - u for _ in range(tstar)):
            wins += 1
    return wins


def part_a():
    settings = [(0.05, 0.01, 0.01), (0.01, 0.001, 0.05), (0.5, 0.01, 0.01), (0.1, 0.1, 0.1), (0.2, 0.05, 0.2)]
    rows = []
    jobs = []
    for (u, w, dp) in settings:
        ts, _ = tight_exact(u, w, dp)
        if ts <= 200:
            jobs.append((u, w, dp, 400, 0, False))
        jobs.append((u, w, dp, 20, 0, True))
    with Pool(4) as p:
        wins = p.map(tight_pipeline, jobs, chunksize=1)
    pipe = {(j[0], j[1], j[2], j[5]): (wn, j[3]) for j, wn in zip(jobs, wins)}
    for (u, w, dp) in settings:
        ts, ex = tight_exact(u, w, dp)
        nf = 100000
        wf = tight_fast(u, w, dp, nf, 1)
        rate = wf / nf
        pw = pipe.get((u, w, dp, False))
        rows.append(['well specified', u, w, dp, fmt(w * dp, 5), ts,
                     '%d/%d = %s' % (wf, nf, fmt(rate, 5)),
                     ('%d/%d' % pw) if pw else 'not run (t* > 200)', fmt(ex, 5), dp])
        ps = pipe[(u, w, dp, True)]
        rows.append(['selected: phi(0) only', u, w, dp, fmt(w * dp, 5), ts, '-', '%d/%d' % ps, '1', dp])
    return rows


# ------------------------------------------------------------------------------------ (B), (C)
# note: '1+0=0' and 'S0+0=0' parse to the same sentence, so the list has 8 distinct queries (results unaffected;
# research/tracks/experiments/checks/check_e4_where.out)
QUERIES = [parse('forall x. x+0=x'), parse('1+0=0'), parse('0+0=1'), parse('S0+0=0'), BAD, parse('2+0=3'),
           parse('7+0=8'), parse('(1+1)+0=S(1+1)'), parse('0=0')]


def pool_trial(args):
    setting, lik_name, seed, nmax = args
    Q = Grammar()
    base = [th for th in e1_hand_pool(P) if l1_exact_supported(th, 1)]
    extra = []
    if setting == 'C1':
        extra.append(Theory([Component(P), parse('?t+0=S?t')], 'sch+mistake-schema', {'cls': 'mistake'}))
    if setting == 'C3':
        extra.append(Theory([instantiate(P, {'t': ZERO}), BAD], "T'", {'cls': 'decoy'}))
    pool = dedupe(base + extra)
    Tstar = [th for th in pool if th.name == 'H_sch'][0]
    rng = random.Random(seed)
    if setting in ('B',):
        data = cite_data(Tstar, [1.0], Q, nmax, seed)
    elif setting == 'C1':
        data = []
        for d in cite_data(Tstar, [1.0], Q, nmax, seed):
            if rng.random() < 0.1:
                t = Q.sample_term(rng)
                d = (instantiate(parse('?t+0=S?t'), {'t': t}))
            data.append(d)
    elif setting == 'C2':
        data = schema_data_with_terms(P, lambda r: heavy_term(r), nmax, seed)
    elif setting == 'C3':
        data = [instantiate(P, {'t': ZERO})] * nmax
    lik = 'L0' if lik_name == 'L0' else Chain(Q, Q, K=1, c_stop=0.5, qe_open=False)
    ns = list(range(1, nmax + 1))          # every n is checked (referee m6; the first version checked 88 values)
    res_all = evaluate(pool, data, ns, lik, Q=Q, alpha=ALPHA)
    der = Deriver(K=1, Q=Q)
    # w* = prior mass of T* when the prior is normalised over the fixed pool plus the whole family of
    # memorisation theories {Mem(S)}: the theory code is prefix-free, so that family has total prior <= 1
    # (notes Prop X8(b)); this makes the bound valid although Mem(D_n) depends on the data
    lps = {th.name: th.log_prior() for th in pool}
    wstar = math.exp(lps['H_sch']) / (sum(math.exp(v) for v in lps.values()) + 1.0)
    invalid = [q for q in QUERIES if not der.derives(Tstar, q)]
    first_win = None
    max_mass = 0.0
    for n, r in zip(ns, res_all):
        for q in invalid:
            m = support_mass(r, [], der, q)
            max_mass = max(max_mass, m)
            if m >= 1 - 0.05 * wstar and first_win is None:
                first_win = (n, pp(q))
    final = res_all[-1]
    mp = max((k for k in final if not k.startswith('_')), key=lambda k: final[k]['post'])
    return {'setting': setting, 'lik': lik_name, 'seed': seed, 'wstar': wstar, 'first_win': first_win,
            'max_invalid_mass': max_mass, 'map': mp, 'map_post': final[mp]['post'],
            'n_invalid_queries': len(invalid), 'deriver_inexact': der.chain.inexact,
            'lik_inexact': getattr(lik, 'inexact', 0),
            'bounded': max((r['_bounded']['max_post'] for r in res_all if '_bounded' in r), default=0.0)}


def part_bc(trials=100, nmax=256):
    jobs = []
    for setting in ['B', 'C1', 'C2', 'C3']:
        for lik in ['L0', 'L1']:
            for s in range(trials):
                jobs.append((setting, lik, s, nmax))
    with Pool(4) as p:
        out = p.map(pool_trial, jobs, chunksize=4)
    rows = []
    for setting in ['B', 'C1', 'C2', 'C3']:
        for lik in ['L0', 'L1']:
            rs = [r for r in out if r['setting'] == setting and r['lik'] == lik]
            wins = sum(1 for r in rs if r['first_win'])
            maps = {}
            for r in rs:
                maps[r['map']] = maps.get(r['map'], 0) + 1
            ex = [r['first_win'] for r in rs if r['first_win']][:2]
            rows.append([setting, lik, fmt(rs[0]['wstar'], 4), '%d/%d' % (wins, len(rs)), 0.05,
                         '%d / %d' % (sum(r['deriver_inexact'] for r in rs), sum(r['lik_inexact'] for r in rs)),
                         fmt(max(r['max_invalid_mass'] for r in rs), 4),
                         '; '.join('%s x%d' % (k[:26], v) for k, v in sorted(maps.items(), key=lambda kv: -kv[1])[:3]),
                         '; '.join('n=%d %s' % e for e in ex)])
    return rows, out


def main():
    t0 = time.time()
    rows_a = part_a()
    rows_bc, raw = part_bc()
    txt = ['# E4: adaptive prover against the threshold verifier\n',
           'Command: `cd code/experiments && python3 e4_ville.py`. Dirichlet alpha = %.1f; derivability |-_1 '
           '(chain derivations of length <= 1). Wall time %.0f s.\n' % (ALPHA, time.time() - t0)]
    txt.append('\n## (A) Tight construction: T* = {phi(?t)}, P(t=0) = 1-u (numerals), T\' = {phi(0), 0=S0}\n\n'
               'delta = w* delta\'. The prover queries 0=S0 in every round. Win = some round accepts it. '
               'The bound is delta\' (= delta / w*). "exact" = (1-u)^t* with t* the first n at which '
               'pi(T*|phi(0)^n) <= delta (with the Dirichlet factor of T\').\n\n')
    txt.append(md_table(['data', 'u', 'w*', "delta'", 'delta', 't*', 'MC win rate (closed form, 1e5 streams)',
                         'full pipeline wins', 'exact', 'bound'], rows_a))
    txt.append('\n## (B, C) Pool experiments (phi = x+0=x; T* = H_sch; delta = 0.05 w*, so the bound is 0.05)\n\n'
               'B: well specified (L0 citations of phi(?t)). C1: 10%% of the data replaced by false near misses '
               't+0=St; the pool also contains {phi(?t), ?t+0=S?t}. C2: heavy-tailed terms (zeta numerals, s = 1.5). '
               'C3: only phi(0) is shown; the decoy T\' = {phi(0), 0=S0} is in the pool. The prover queries every '
               'round all statements of a fixed list that T* does not derive: %s. Every n = 1..256 is checked. '
               '"max mass" = the largest posterior mass ever given to the theories deriving one invalid query.\n\n'
               % ', '.join(pp(q) for q in QUERIES))
    txt.append(md_table(['setting', 'likelihood', 'w* = prior of T*', 'prover wins', 'bound',
                         'fallback counts (oracle / likelihood)', 'max mass on an invalid query',
                         'MAP at n=256 (count)', 'first wins (examples)'], rows_bc))
    save('e4_ville', '\n'.join(txt), {'A': rows_a, 'BC': rows_bc, 'raw': raw})


if __name__ == '__main__':
    main()
