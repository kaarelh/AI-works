"""Where does the largest mass on an invalid query sit in E4(B)?

Re-runs the E4(B) streams (seeds 0-99, both likelihoods) for n <= 32, recomputes the largest posterior mass ever
given to theories that derive one of the invalid queries, checks it against `code/results/e4_ville.json` (whose
runs go to n = 256), and reports at which n and on which query and theories the maximum occurs.
Also, for E4(C1), compares the first acceptance with the first mistaken datum of each stream, and
confirms that the query list of E4 has 8 distinct sentences (1+0=0 and S0+0=0 are the same sentence).
Run: python3 check_e4_where.py  (writes check_e4_where.out)
"""
import json
import os
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
CODE = os.path.normpath(os.path.join(HERE, '../../../../code'))
sys.path.insert(0, CODE)
sys.path.insert(0, os.path.join(CODE, 'experiments'))
from e4_ville import QUERIES, P, ALPHA, e1_hand_pool, l1_exact_supported, dedupe, cite_data, pp  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.lik import Chain  # noqa: E402
from bai.posterior import evaluate, Deriver, support_mass  # noqa: E402

out = []
Q = Grammar()
d = json.load(open(os.path.join(CODE, 'results/e4_ville.json')))
target = {(r['lik'], r['seed']): r['max_invalid_mass'] for r in d['raw'] if r['setting'] == 'B'}
pool = dedupe([th for th in e1_hand_pool(P) if l1_exact_supported(th, 1)])
Tstar = [th for th in pool if th.name == 'H_sch'][0]
der = Deriver(K=1, Q=Q)
invalid = [q for q in QUERIES if not der.derives(Tstar, q)]
out.append('queries in the list: %d, distinct: %d, not derivable from T*: %d' % (
    len(QUERIES), len(set(QUERIES)), len(set(invalid))))
NMAX = 32
agree, worst = 0, 0.0
n_at, q_at, carriers = Counter(), Counter(), Counter()
for lik_name in ('L0', 'L1'):
    lik = 'L0' if lik_name == 'L0' else Chain(Q, Q, K=1, c_stop=0.5, qe_open=False)
    for seed in range(100):
        data = cite_data(Tstar, [1.0], Q, NMAX, seed)
        ns = list(range(1, NMAX + 1))
        res = evaluate(pool, data, ns, lik, Q=Q, alpha=ALPHA)
        best = (0.0, None)
        for n, r in zip(ns, res):
            for q in invalid:
                m = support_mass(r, [], der, q)
                if m > best[0]:
                    best = (m, (n, q, r))
        m, (n, q, r) = best
        dev = abs(m - target[(lik_name, seed)])
        worst = max(worst, dev)
        agree += dev < 1e-9
        n_at[n] += 1
        q_at[pp(q)] += 1
        for k, v in r.items():
            if not k.startswith('_') and der.derives(v['theory'], q):
                carriers[(lik_name, k)] += v['post'] / 100
out.append('maximum over n <= %d equals the maximum over n <= 256 of the E4 run in %d of 200 streams '
           '(largest deviation %.1e)' % (NMAX, agree, worst))
out.append('n at which the maximum occurs (count of 200): %s' % sorted(n_at.items()))
out.append('query carrying the maximum: %s' % dict(q_at))
out.append('mean mass at the maximum, by theory: %s' % ', '.join(
    '%s %s %.3f' % (l, k, v) for (l, k), v in sorted(carriers.items(), key=lambda kv: -kv[1]) if v > 0.005))
# C1: first win against the first mistake datum (streams regenerated exactly as in e4_ville.pool_trial)
import random  # noqa: E402
from dtrc.templates import instantiate  # noqa: E402
from common import parse  # noqa: E402
gaps = Counter()
for r in d['raw']:
    if r['setting'] != 'C1' or not r['first_win']:
        continue
    rng = random.Random(r['seed'])
    data = []
    for dd in cite_data(Tstar, [1.0], Q, 256, r['seed']):
        if rng.random() < 0.1:
            dd = instantiate(parse('?t+0=S?t'), {'t': Q.sample_term(rng)})
        data.append(dd)
    first_mistake = next(i + 1 for i, x in enumerate(data) if x[0] == '=' and x[1][0] == '+' and x[1][2] == ('0',)
                         and x[2] == ('S', x[1][1]))
    gaps[(r['lik'], r['first_win'][0] - first_mistake)] += 1
out.append('E4(C1): first win minus position of the first mistake datum, (likelihood, lag): count: %s'
           % sorted(gaps.items()))
open(os.path.join(HERE, 'check_e4_where.out'), 'w').write('\n'.join(out) + '\n')
print('\n'.join(out))
