#!/usr/bin/env python3
"""Read-only exact readout-energy inventory of preexisting checkpoints."""
from collections import Counter
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import re

import numpy as np

ROOTS = {
    'round2': Path('/workspace/depth-research-round2-2026-10-17/experiment'),
    'public_round3': Path('/workspace/nnbayes-better-polynomials/neural-network-generalization/works-in-progress/depth-experiments'),
}
OUT = Path(__file__).resolve().parent


def audit():
    rows = []
    extras = []
    for cohort, root in ROOTS.items():
        for path in sorted(root.rglob('*.npz')):
            with np.load(path, allow_pickle=False) as data:
                keys = sorted((k for k in data.files if re.fullmatch(r'w[0-9]+', k)),
                              key=lambda k: int(k[1:]))
                if not keys:
                    continue
                weights = [np.asarray(data[k]) for k in keys]
                assert keys == [f'w{i}' for i in range(len(keys))], str(path)
                v = weights[-1]
                assert v.ndim == 1, str(path)
                n = len(v)
                assert weights[0].shape[1] == n
                assert all(w.shape == (n, n) for w in weights[1:-1])
                assert all(np.isfinite(w).all() for w in weights)
                ev = n * sum((Fraction(float(x)) ** 2 for x in v), Fraction())
                trivial = ev >= n - 1
                floor_q = min(n, (1 + ev).numerator // (1 + ev).denominator)
                row = {
                    'cohort': cohort,
                    'path': str(path),
                    'relative_path': str(path.relative_to(root)),
                    'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                    'dimension': weights[0].shape[0] - 1,
                    'width': n,
                    'hidden_depth': len(weights) - 1,
                    'weight_keys': keys,
                    'weight_dtype': str(v.dtype),
                    'readout_energy_float': float(ev),
                    'readout_energy_numerator': str(ev.numerator),
                    'readout_energy_denominator': str(ev.denominator),
                    'q_allowed_max_exact': floor_q,
                    'q_equals_width_is_allowed_exact': trivial,
                    'distance_to_vacuity_threshold': float(ev - (n-1)),
                    'other_arrays': {k: list(data[k].shape) for k in data.files if k not in keys},
                }
                if 'models' in path.parts:
                    record_path = path.parent.parent / 'records' / (path.stem + '.json')
                    if record_path.exists():
                        rec = json.loads(record_path.read_text())
                        row['config'] = rec.get('config', {})
                        for field in ('train_errors', 'test_errors', 'test_accuracy',
                                      'train_count', 'test_count', 'all_cube_errors'):
                            if field in rec:
                                row[field] = rec[field]
                    rows.append(row)
                else:
                    extras.append(row)
    summaries = {}
    for cohort in ROOTS:
        selected = [r for r in rows if r['cohort'] == cohort]
        summaries[cohort] = {
            'trained_checkpoints': len(selected),
            'trivial_population_condition': sum(r['q_equals_width_is_allowed_exact'] for r in selected),
            'nontrivial_population_condition': sum(not r['q_equals_width_is_allowed_exact'] for r in selected),
            'dimension_counts': dict(Counter(r['dimension'] for r in selected)),
            'width_counts': dict(Counter(r['width'] for r in selected)),
            'hidden_depth_counts': dict(Counter(r['hidden_depth'] for r in selected)),
        }
    output = {
        'scope': 'Original stored weights; exact rational arithmetic on readout coordinates, no rescaling or retraining.',
        'definition': 'Ev = N * sum_i(v_i^2); q=N is allowed iff Ev>=N-1. Singleton populations make every P_s identity, so the population-score discrepancy is exactly zero.',
        'orientation': 'Stored first layer shape (d+1,N), later layers (N,N), readout (N,); forward propagation uses row-batched h @ W. This is the transpose convention of the theorem.',
        'summaries': summaries,
        'trained_models': rows,
        'untrained_teacher_files': extras,
    }
    (OUT / 'inventory.json').write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps(summaries, indent=2))
    print('Additional untrained teachers:', len(extras))
    print('Closest threshold distance:', min(abs(r['distance_to_vacuity_threshold']) for r in rows))


if __name__ == '__main__':
    audit()
