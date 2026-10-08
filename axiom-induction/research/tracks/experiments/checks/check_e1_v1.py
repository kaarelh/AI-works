"""Compare the final E1 results with the first version's (code/results/v1/e1_universal.json).

Reports the largest change of the posterior of any hand theory (all n, and n >= 8, per likelihood), the largest
change of P(T |-_1 forall x phi) for n >= 16, and whether any generator-mass entry of the notes' E1 table (means at
n = 4, 8, 32, 256, three decimals) differs. Deterministic; writes check_e1_v1.out.
"""
import json
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.normpath(os.path.join(HERE, '../../../../code/results')) + '/'
d = json.load(open(R + 'e1_universal.json'))
d1 = json.load(open(R + 'v1/e1_universal.json'))
HAND = ['H_all', 'H_sch', 'H_open', 'H_all+sch', 'H_all+open', 'overspec{0,S}', 'frag1', 'frag2', 'spare_nested',
        'spare_false', 'spare_schema', 'bare?P']
GEN = {'sch': 'H_sch', 'all': 'H_all', 'allq': 'H_all', 'open': 'H_open', 'allq2': 'H_all'}
out = []
w = defaultdict(lambda: (0.0, None))
wf = 0.0
cells = defaultdict(lambda: [0.0, 0.0, 0])
for r, r1 in zip(d['results'], d1['results']):
    assert (r['phi'], r['gen'], r['seed']) == (r1['phi'], r1['gen'], r1['seed'])
    for l in r['liks']:
        for a, b in zip(r['liks'][l]['rows'], r1['liks'][l]['rows']):
            assert a['n'] == b['n']
            for k in HAND:
                x, y = a['post'].get(k, 0.0), b['post'].get(k, 0.0)
                key = (l, 'n >= 8' if a['n'] >= 8 else 'n <= 4')
                if abs(x - y) > w[key][0]:
                    w[key] = (abs(x - y), (r['phi'], r['gen'], 'seed %d' % r['seed'], 'n = %d' % a['n'], k,
                                           'now %.4f' % x, 'v1 %.4f' % y))
            if a['n'] >= 16:
                wf = max(wf, abs(a['P_forall'] - b['P_forall']))
            if a['n'] in (4, 8, 32, 256):
                c = cells[(r['gen'], l, a['n'])]
                c[0] += a['post'].get(GEN[r['gen']], 0.0)
                c[1] += b['post'].get(GEN[r['gen']], 0.0)
                c[2] += 1
for k in sorted(w):
    out.append('largest change of a hand-theory posterior, %s, %s: %.2g  %s' % (k[0], k[1], w[k][0], w[k][1]))
out.append('largest change of P(T |-_1 forall x phi), n >= 16: %.2g' % wf)
diff = [(k, round(v[0] / v[2], 3), round(v[1] / v[2], 3)) for k, v in sorted(cells.items())
        if round(v[0] / v[2], 3) != round(v[1] / v[2], 3)]
out.append('generator-mass table entries (gen, lik, n) that differ at three decimals: %s' % (diff or 'none'))
open(os.path.join(HERE, 'check_e1_v1.out'), 'w').write('\n'.join(out) + '\n')
print('\n'.join(out))
