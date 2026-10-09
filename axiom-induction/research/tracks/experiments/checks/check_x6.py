"""Check Prop X6 against the E1 results, with the prior taken from an independent implementation (referee m1).

Under L1 on sch data, log2 odds H_sch : H_all = [bits(H_all) - bits(H_sch)] + n log2(1/(1 - c_stop)); under L1sel
they equal the prior difference at every n.  The prior bits are computed by the referee's independent prior code
(referee_code/ref_core.py, written from the notes, not from the track's code), not read off the L1sel output as
in the first version of this check.  Reads code/results/e1_universal.json.
Command: python3 check_x6.py   (writes check_x6.out)"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'referee_code'))
import ref_core as R  # noqa: E402

d = json.load(open(os.path.join(HERE, '..', '..', '..', '..', 'code', 'results', 'e1_universal.json')))
NS = [1, 2, 4, 8, 16, 32, 64, 128, 256]
PHIS = {'x+0=x': '?t+0=?t', '0+x=x': '0+?t=?t', '~(Sx=0)': '~S?t=0'}
FORALL = {'x+0=x': 'forall x. x+0=x', '0+x=x': 'forall x. 0+x=x', '~(Sx=0)': 'forall x. ~Sx=0'}
C_STOP = 0.5
lines = []
worst_l1, worst_sel, nruns = 0.0, 0.0, 0
for phi in PHIS:
    prior = R.theory_bits([R.parse(FORALL[phi])]) - R.theory_bits([R.parse(PHIS[phi])])
    lines.append('%s: independent prior difference bits(H_all) - bits(H_sch) = %.6f' % (phi, prior))
    for r in d['results']:
        if r['gen'] != 'sch' or r['phi'] != phi:
            continue
        nruns += 1
        l1 = [row['lo_sch_all'] for row in r['liks']['L1']['rows']]
        sel = [row['lo_sch_all'] for row in r['liks']['L1sel']['rows']]
        for n, x, y in zip(NS, l1, sel):
            worst_l1 = max(worst_l1, abs(x - (prior + n * math.log2(1 / (1 - C_STOP)))))
            worst_sel = max(worst_sel, abs(y - prior))
lines.append('runs %d | max |lo_L1 - (prior + n)| = %.2e | max |lo_L1sel - prior| = %.2e' % (nruns, worst_l1, worst_sel))
print('\n'.join(lines))
with open(os.path.join(HERE, 'check_x6.out'), 'w') as f:
    f.write('\n'.join(lines) + '\n')
