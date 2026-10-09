"""Referee check R6: are E3's winners artefacts of the edges of the hand-built pool, and does "robust at the level of
theorems" survive a natural motive law?

(a) numerals generator (E3a, L0): the E3 pool has numeral splits N_m only for m <= 4, and N_4 wins.  Add N_5..N_16.
(b) heavy generator (E3a, L0): the winner is {phi(?t), phi(S?z)}.  Add the nested chain C_2 = {phi(?t), phi(S?z),
    phi(SS?z)} (same instance set as phi(?t); 3 overlapping components, so the track's dense DP is exact).
(c) PA mixture (E3b-style, L0) with ATOMIC motives only: root '=' or '<' (probability 0.6 / 0.4), terms from Q with one
    hole.  The pool is the E3(b) pool (build_pa_pool + T* + T_f for every root f), unchanged.  The question: does the
    posterior move to a theory that is deductively equivalent to T*?
Uses the track's pipeline for scoring (the core probabilities were checked independently in r1_core_compare.py).
Seeds 0-4.  Command: python3 r6_e3_extensions.py  (writes r6_e3_extensions.out)"""
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
import common  # noqa: E402,F401
from common import Theory, num, dedupe  # noqa: E402
import e3_misspec as E3  # noqa: E402
from pa_common import build_pa_pool, ROOTS, T_frag, QSENT, W_TRUE  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.posterior import evaluate  # noqa: E402
from bai.pool import specialise  # noqa: E402
from bai.gens import schema_data_with_terms  # noqa: E402
from dtrc.templates import instantiate  # noqa: E402
from dtrc.schemas import T_IND  # noqa: E402
from dtrc.syntax import canon_params  # noqa: E402

P = E3.P
L = []


def out(s):
    print(s, flush=True)
    L.append(s)


def Sn(t, k):
    for _ in range(k):
        t = ('S', t)
    return t


def run_a(seed):
    Q = Grammar()
    ns = [128, 512, 1024]
    data = schema_data_with_terms(P, E3.term_gen('numerals'), max(ns), seed)
    pool = E3.pool_a(data, seed)
    for m in range(5, 17):
        temps = [instantiate(P, {'t': num(j)}) for j in range(m)] + [specialise(P, 't', Sn(('M', 'z', ()), m))]
        pool.append(Theory(temps, 'N_%d' % m, {'cls': 'over-specific'}))
    res = evaluate(pool, data, ns, 'L0', Q=Q, alpha=0.5)
    return [(n, max(r, key=lambda k: r[k]['post']), max(v['post'] for v in r.values())) for n, r in zip(ns, res)]


def run_b(seed):
    Q = Grammar()
    ns = [128, 512, 1024]
    data = schema_data_with_terms(P, E3.term_gen('heavy'), max(ns), seed)
    pool = E3.pool_a(data, seed)
    for J in (2,):          # more than 3 overlapping components is beyond the exact DP of the track
        temps = [specialise(P, 't', Sn(('M', 'z', ()), j)) if j else P for j in range(J + 1)]
        pool.append(Theory(temps, 'C_%d' % J, {'cls': 'same'}))
    res = evaluate(pool, data, ns, 'L0', Q=Q, alpha=0.5)
    return [(n, max(r, key=lambda k: r[k]['post']), max(v['post'] for v in r.values())) for n, r in zip(ns, res)]


def atomic_gen(seed, n):
    Q = Grammar()
    rng = random.Random(seed)
    outd = []
    for _ in range(n):
        r = rng.random() * sum(W_TRUE)
        if r < 0.35:
            outd.append(QSENT[min(int(r / 0.05), 6)])
        else:
            f = '=' if rng.random() < 0.6 else '<'
            body = (f, Q.sample_term(rng, 1, 0, False), Q.sample_term(rng, 1, 0, False))
            outd.append(canon_params(instantiate(T_IND, {'P': body})))
    return outd


def run_c(seed):
    Q = Grammar()
    ns = [16, 64, 256, 1024]
    data = atomic_gen(seed, max(ns))
    pool = build_pa_pool(data, seed)
    for f in ROOTS:
        pool.append(Theory(QSENT + [T_IND, T_frag(f)], 'T*+T_%s' % f, {'cls': 'spare', 'equiv': 'yes', 'sound': True}))
    pool = dedupe(pool)
    res = evaluate(pool, data, ns, 'L0', Q=Q, alpha=0.5)
    rows = []
    for n, r in zip(ns, res):
        mp = max(r, key=lambda k: r[k]['post'])
        tags = {th.name: th.tags for th in pool}
        eq = sum(r[th.name]['post'] for th in pool if th.tags.get('equiv') == 'yes')
        unk = sum(r[th.name]['post'] for th in pool if th.tags.get('equiv') == 'unknown')
        bits = {k: -(v['lp'] + v['lm']) / 0.6931471805599453 for k, v in r.items() if not k.startswith('_') and v['lm'] > -1e300}
        rows.append((n, mp, r[mp]['post'], tags.get(mp, {}).get('equiv', '-'), eq, unk,
                     bits.get('frag-atoms', float('nan')) - bits['T*']))
    return rows


def main():
    from multiprocessing import Pool
    with Pool(4) as p:
        ra = p.map(run_a, range(5))
        rb = p.map(run_b, range(5))
        rc = p.map(run_c, range(5))
    out('(a) numerals generator, L0, pool + N_5..N_16: (n, MAP, its mass) per seed')
    for s, rows in enumerate(ra):
        out('  seed %d: %s' % (s, '; '.join('n=%d %s %.3f' % x for x in rows)))
    out('(b) heavy generator, L0, pool + C_2: (n, MAP, its mass) per seed')
    for s, rows in enumerate(rb):
        out('  seed %d: %s' % (s, '; '.join('n=%d %s %.3f' % x for x in rows)))
    out('(c) PA, atomic motives only, E3(b) pool: (n, MAP, mass, MAP equivalence tag, mass tagged equivalent, mass '
        'tagged unknown, code length frag-atoms - T* in bits)')
    for s, rows in enumerate(rc):
        out('  seed %d: %s' % (s, '; '.join('n=%d %s %.3f [%s] eq %.3f unk %.3f d=%.0f' % x for x in rows)))
    with open(os.path.join(HERE, 'r6_e3_extensions.out'), 'w') as f:
        f.write('\n'.join(L) + '\n')


if __name__ == '__main__':
    main()
