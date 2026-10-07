"""Referee check R8: overlap between training data and held-out sets in E3 (same generators and seeds)."""
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import canon_params
from dtrc.datasets import pa_mix, zf_mix, heldout_pa, heldout_zf
for mix in ('PA', 'ZF'):
    for seed in range(5):
        data = pa_mix(seed) if mix == 'PA' else zf_mix(seed)
        held = heldout_pa(seed) if mix == 'PA' else heldout_zf(seed)
        train = set(canon_params(s) for s, _ in data)
        row = []
        for k, qs in held.items():
            if len(qs) > 1:
                ov = sum(1 for q in qs if canon_params(q) in train)
                row.append('%s %d/%d' % (k, ov, len(qs)))
        print(mix, seed, '; '.join(row))
