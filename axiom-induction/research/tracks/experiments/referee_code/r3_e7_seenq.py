"""Referee check R3: E7's prior variants (lambda, tau) on the E2 data with SeenQ(D_n) = {Q axioms seen} + T_Ind added
to the pool (see r2_e2_seenq.py).  Reports per variant: unsound mass at n = 8, 16, 32 (mean over seeds) and the
number of seeds whose MAP at n = 8 is unsound, for the track's pool and for the pool + SeenQ.  Seeds 0-4 (the
track's) and 0-24.  Command: python3 r3_e7_seenq.py  (writes r3_e7_seenq.out)"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
import common  # noqa: E402,F401
from pa_common import build_pa_pool, t_star, W_TRUE, QSENT  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.gens import cite_data  # noqa: E402
from bai.posterior import evaluate  # noqa: E402
from bai.theory import Theory  # noqa: E402
from dtrc.schemas import T_IND  # noqa: E402
import ref_core as R  # noqa: E402

NS = [8, 16, 32]
VARIANTS = [(1.0, 0.0), (1.0, 1.0), (1.0, 4.0), (2.0, 0.0), (0.5, 0.0)]


def run(seed):
    Q = Grammar()
    data = cite_data(t_star(), W_TRUE, Q, 64, seed)      # the pool uses the first 64 data, as in E2/E7
    pool = build_pa_pool(data, seed)
    unsound = {th.name for th in pool if th.tags.get('sound') is False}
    out = {}
    for lam, tau in VARIANTS:
        res_all = evaluate(pool, data, NS, 'L0', Q=Q, alpha=0.5, lam=lam, tau=tau)
        rows = []
        for n, res in zip(NS, res_all):
            seen = []
            for d in data[:n]:
                if d in QSENT and d not in seen:
                    seen.append(d)
            sq = Theory(seen + [T_IND], 'SeenQ')
            keys = {th.key for th in pool}
            scores = {k: v['lp'] + v['lm'] for k, v in res.items() if not k.startswith('_')}
            s0 = dict(scores)
            if sq.key not in keys:
                # score SeenQ: independent L0 + Dirichlet (ref_core), track's prior form for (lam, tau)
                coefs = []
                for d in data[:n]:
                    c = {}
                    for i, T in enumerate(seen + [T_IND]):
                        v = R.l0(T, {}, d, R.Q())
                        if v != R.NEG:
                            c[i] = v
                    coefs.append(c)
                lp = sq.log_prior(lam, tau)
                scores['SeenQ'] = lp + R.dir_marg(coefs, len(seen) + 1, 0.5)
            res_pair = []
            for sc in (s0, scores):
                z = R.lse(list(sc.values()))
                post = {k: math.exp(v - z) for k, v in sc.items()}
                uns = sum(post[k] for k in post if k in unsound)
                mp = max(post, key=post.get)
                res_pair.append((uns, mp in unsound))
            rows.append(res_pair)
        out[(lam, tau)] = rows
    return seed, out


def main():
    from multiprocessing import Pool
    with Pool(4) as p:
        res = p.map(run, range(25), chunksize=1)
    lines = ['R3: E7 prior variants with and without SeenQ(D_n) in the pool (unsound mass mean over seeds; '
             '#seeds with an unsound MAP)']
    for label, seeds in [('seeds 0-4', range(5)), ('seeds 0-24', range(25))]:
        lines.append('== ' + label)
        for v in VARIANTS:
            parts = []
            for i, n in enumerate(NS):
                u0 = sum(dict(res)[s][v][i][0][0] for s in seeds) / len(seeds)
                u1 = sum(dict(res)[s][v][i][1][0] for s in seeds) / len(seeds)
                m0 = sum(dict(res)[s][v][i][0][1] for s in seeds)
                m1 = sum(dict(res)[s][v][i][1][1] for s in seeds)
                parts.append('n=%d: unsound %.3f -> %.3f, unsound MAP %d -> %d' % (n, u0, u1, m0, m1))
            lines.append('(lam, tau) = %s | %s' % (v, ' | '.join(parts)))
    print('\n'.join(lines))
    with open(os.path.join(HERE, 'r3_e7_seenq.out'), 'w') as f:
        f.write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main()
