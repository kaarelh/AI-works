# r7_table_vs_output.py -- referee for track "pa": compare the section-4 table of notes.md ("Computed: Q + Ind
# practice", L - L_true in bits, no negatives) with the track's own saved output checks/c4_bdtrc.out, which the
# referee reproduced byte for byte by re-running c4_bdtrc.py on a copy.  Output: r7_table_vs_output.out.
import os, re
HERE = os.path.dirname(os.path.abspath(__file__))
NOTES = {   # transcribed from notes.md section 4 (n = 10, 30, 100, 1000, 3000)
    'root': [776.4, 773.6, 772.7, 769.9, 768.3],
    'spare': [15.9, 16.6, 17.4, 19.0, 19.8],
    'mem': [1792, 5393, 15901, 133905, 399840],
    'over': [550, 1501, 3833, 27257, 82196],
    'lumpQ': [-174.7, -42.0, 319, 6440, 19412],
    'bare': [584, 2149, 6068, 46311, 137534],
}
NS = [10, 30, 100, 1000, 3000]
txt = open(os.path.join(HERE, '..', 'checks', 'c4_bdtrc.out')).read().split('\n')
vals, n, block = {}, None, None
for line in txt:
    mm = re.match(r'\s+n=\s*(\d+)\s+(no negatives|negatives)', line)
    if mm:
        n, block = int(mm.group(1)), mm.group(2); continue
    mm = re.match(r'\s+(\w+)\s.*L-L_true\s+([-+\d.inf]+) bits', line)
    if mm and block == 'no negatives' and n in NS:
        vals.setdefault(mm.group(1), {})[n] = float(mm.group(2))
out = ['candidate  n     notes.md   c4_bdtrc.out   difference']
bad = 0
for k, row in NOTES.items():
    for nn, v in zip(NS, row):
        o = vals[k][nn]
        tol = 0.6 if abs(v) < 1000 else 1.0
        flag = '' if abs(o - v) <= tol else '   <-- MISMATCH'
        bad += bool(flag)
        out.append('%-8s %5d %10.1f %12.1f %12.1f%s' % (k, nn, v, o, o - v, flag))
out.append('%d of %d table entries do not match the saved output' % (bad, sum(len(r) for r in NOTES.values())))
open(os.path.join(HERE, 'r7_table_vs_output.out'), 'w').write('\n'.join(out) + '\n')
print('\n'.join(out))
