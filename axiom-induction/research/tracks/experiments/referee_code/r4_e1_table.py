"""Referee check R4: recompute the E1 summary table of the notes (section 3) from the raw json, and check Prop X6
against prior code lengths computed independently (ref_core.prior_bits), not against the L1sel run.
Command: python3 r4_e1_table.py  (writes r4_e1_table.out)"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
import ref_core as R  # noqa: E402

J = json.load(open(os.path.join(HERE, '..', '..', '..', '..', 'code', 'results', 'e1_universal.json')))
NS = [1, 2, 4, 8, 16, 32, 64, 128, 256]
GEN_TH = {'sch': 'H_sch', 'all': 'H_all', 'allq': 'H_all', 'open': 'H_open', 'allq2': 'H_all'}
lines = []


def out(s):
    print(s)
    lines.append(s)


rs = J['results']
out('generator | lik | mean generator mass at n=4,8,32,256 | MAPs at 256 | mean P(|-forall) at 256 | worst first n '
    'with generator mass >= 0.99 from then on | min P(|-inst) at n>=8 | max Mem at n=8 | max over-general at n=8')
for g in ['sch', 'all', 'allq', 'open', 'allq2']:
    for lik in ['L0', 'L1', 'L1sel']:
        runs = [r for r in rs if r['gen'] == g and lik in r['liks']]
        if not runs:
            continue
        gt = GEN_TH[g]
        means = []
        for n in (4, 8, 32, 256):
            i = NS.index(n)
            means.append(sum(r['liks'][lik]['rows'][i]['post'].get(gt, 0.0) for r in runs) / len(runs))
        maps = sorted(set(r['liks'][lik]['rows'][-1]['map'] for r in runs))
        pf = sum(r['liks'][lik]['rows'][-1]['P_forall'] for r in runs) / len(runs)
        first = []
        for r in runs:
            rows = r['liks'][lik]['rows']
            f = None
            for i in range(len(NS)):
                if all(rows[j]['post'].get(gt, 0.0) >= 0.99 for j in range(i, len(NS))):
                    f = NS[i]
                    break
            first.append(f)
        worst = 'never' if any(f is None for f in first) else max(first)
        pinst = min(r['liks'][lik]['rows'][i]['P_inst'] for r in runs for i in range(3, len(NS)))
        mem8 = max(r['liks'][lik]['rows'][3]['mass']['mem'] for r in runs)
        og8 = max(r['liks'][lik]['rows'][3]['mass']['over-general'] for r in runs)
        out('%-5s | %-5s | %s | %s | %.3g | %s | %.4f | %.2g | %.2g' % (
            g, lik, ', '.join('%.3f' % m for m in means), ', '.join(x[:20] for x in maps), pf, worst, pinst, mem8, og8))

# Prop X6 against independent prior bits: log2 odds H_sch:H_all = [bits(H_all) - bits(H_sch)] + n (L1), + 0 (L1sel)
PHI = {'x+0=x': ('?t+0=?t', 'forall x. x+0=x'), '0+x=x': ('0+?t=?t', 'forall x. 0+x=x'),
       '~(Sx=0)': ('~S?t=0', 'forall x. ~Sx=0')}
w1 = w2 = 0.0
for r in rs:
    if r['gen'] != 'sch':
        continue
    a, b = PHI[r['phi']]
    pd = R.theory_bits([R.parse(b)]) - R.theory_bits([R.parse(a)])
    for i, n in enumerate(NS):
        w1 = max(w1, abs(r['liks']['L1']['rows'][i]['lo_sch_all'] - (pd + n)))
        w2 = max(w2, abs(r['liks']['L1sel']['rows'][i]['lo_sch_all'] - pd))
out('Prop X6 vs independent prior bits: max |lo_L1 - (bits(H_all) - bits(H_sch) + n)| = %.2e; '
    'max |lo_L1sel - (bits(H_all) - bits(H_sch))| = %.2e' % (w1, w2))
for k, (a, b) in PHI.items():
    pd = R.theory_bits([R.parse(b)]) - R.theory_bits([R.parse(a)])
    out('  %s: prior bits difference %.3f; prior share of H_all among {H_all, H_sch}: %.3f' % (k, pd, 1 / (1 + 2 ** pd)))
# L1sel P(|-forall) limit
for k in PHI:
    v = [r['liks']['L1sel']['rows'][-1]['P_forall'] for r in rs if r['gen'] == 'sch' and r['phi'] == k]
    out('  L1sel P(|-forall) at n=256, %s: %s' % (k, ', '.join('%.3f' % x for x in v)))
with open(os.path.join(HERE, 'r4_e1_table.out'), 'w') as f:
    f.write('\n'.join(lines) + '\n')
