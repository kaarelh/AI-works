"""Check Prop X6 against the E1 results: under L1 on sch data, log2 odds H_sch:H_all = prior difference + n;
under L1sel they equal the prior difference at every n.  Reads code/results/e1_universal.json.
Command: python3 check_x6.py"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
d = json.load(open(os.path.join(HERE, '..', '..', '..', '..', 'code', 'results', 'e1_universal.json')))
NS = [1, 2, 4, 8, 16, 32, 64, 128, 256]
worst_l1, worst_sel, nruns = 0.0, 0.0, 0
for r in d['results']:
    if r['gen'] != 'sch':
        continue
    nruns += 1
    l1 = [row['lo_sch_all'] for row in r['liks']['L1']['rows']]
    sel = [row['lo_sch_all'] for row in r['liks']['L1sel']['rows']]
    prior = sel[0]
    for n, x, y in zip(NS, l1, sel):
        worst_l1 = max(worst_l1, abs(x - (prior + n)))
        worst_sel = max(worst_sel, abs(y - prior))
print('runs', nruns, '| max |lo_L1 - (prior + n)| =', worst_l1, '| max |lo_L1sel - prior| =', worst_sel)
