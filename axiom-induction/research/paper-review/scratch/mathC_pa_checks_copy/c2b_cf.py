# c2b_cf.py -- the comparison of c2_mdl.py under a shared context-free instantiation grammar with one nonterminal
# per sort (mode CF: one KT distribution per sort, shared by all templates).  Seeds as in c2_mdl.py; output in
# c2b_cf.out.  Prior charged for every listed template (corrected after the referee, issue m1); H_used is the split
# into the roots that occur (index alphabet restricted to them).
import sys, random
from c2_mdl import codelength, pa_data, g2_data, g3_data, ROOTS, SPLIT, TBITS
from dtlib import size
lines = []
NS = [int(a) for a in sys.argv[1:]] or [1000, 4000, 16000, 64000, 256000]
for gen_name, gen in (('G1 natural (u7)', lambda n, r: pa_data(n, r, p_ind=0.5)),
                      ('G2 well specified for DPC (u7)', g2_data),
                      ('G3 natural, roots {=,imp,all} only', g3_data)):
    lines.append('usage law: ' + gen_name)
    for n in NS:
        data = gen(n, random.Random(n))
        present = sorted({s[2][1][0] for k, s in data if not k.startswith('Q')})
        unused_prior = TBITS * sum(size(SPLIT[f]) for f in ROOTS if f not in present)
        Lt, tt = codelength(data, 'true', 'CF')
        Lr, tr = codelength(data, 'root', 'CF')
        Lu, tu = codelength(data, 'used', 'CF') if len(present) < len(ROOTS) else (Lr, tr)
        lines.append('  n=%6d  CF: H_root %+9.1f (%+.3f per datum; template part %+d)   H_used %+9.1f (%+.3f per '
                     'datum; template part %+d)   [u7 bookkeeping for H_root: %+9.1f]'
                     % (n, Lr - Lt, (Lr - Lt) / n, tr - tt, Lu - Lt, (Lu - Lt) / n, tu - tt, Lr - Lt - unused_prior))
        print(lines[-1], flush=True)
open('c2b_cf.out', 'w').write('\n'.join(lines) + '\n')
