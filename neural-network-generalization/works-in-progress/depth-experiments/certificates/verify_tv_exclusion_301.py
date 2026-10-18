#!/usr/bin/env python3
"""Exact dual exclusion for the separately declared model301 TV diagnostic.

The saved LP only proposes multipliers. All lower-bound arithmetic below is
exact, and every stationarity error is bounded over the full variable box.
"""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
import hashlib
import json
from fractions import Fraction
from pathlib import Path
import numpy as np
from exact_svd_bound import dyadic_integer_matrix, rational_record

ROOT = Path(__file__).resolve().parent
model = next((ROOT.parent / 'experiment/models').glob('301-*.npz'))
weights = np.load(model)['w0'].astype(float)
saved = np.load(ROOT / 'tv-zero-diagnostic-301.npz')
lam = saved['lp_equality_marginals']
mu = np.minimum(saved['lp_inequality_marginals'], 0.)
d = weights.shape[0] - 1
coords = np.indices((28, 28))
border = ((coords[0] < 2) | (coords[0] >= 26)
          | (coords[1] < 2) | (coords[1] >= 26)).reshape(-1)
edges = [(i*28+j, (i+1)*28+j) for i in range(27) for j in range(28)]
edges += [(i*28+j, i*28+j+1) for i in range(28) for j in range(27)]
assert len(mu) == 2*len(edges)+1
wi, dw = dyadic_integer_matrix(weights)
li, dl = dyadic_integer_matrix(lam)
products = [Fraction(int(v), dw*dl) for v in wi @ li]
mf = [Fraction.from_float(float(v)) for v in mu]
assert all(v <= 0 for v in mf)
rx = [-v-mf[-1] for v in products[:-1]]
rt = []
for k, (i, j) in enumerate(edges):
    q = mf[2*k]-mf[2*k+1]
    rx[i] -= q
    rx[j] += q
    rt.append(1+mf[2*k]+mf[2*k+1])
constant = -products[-1]+mf[-1]*Fraction(-3*d, 5)
box = sum((-v if fixed else -abs(v) for v, fixed in zip(rx, border)), Fraction(0))
box += sum((2*min(v, Fraction(0)) for v in rt), Fraction(0))
lower = (constant+box)/2
lnorm = sum((abs(Fraction.from_float(float(v))) for v in lam), Fraction(0))
epsilon = 2*(lower-150)/lnorm
out = {
    'model': model.stem,
    'model_sha256': hashlib.sha256(model.read_bytes()).hexdigest(),
    'scope': 'Every exact real image with black outer two-pixel border, pixels in [0,1], mean ink <= 1/5, and zero first-layer affine preactivations.',
    'exact_tv_lower_bound': rational_record(lower),
    'tv_lower_bound_approx': float(lower),
    'zero_state_tv_exceeds_150': bool(lower > 150),
    'dual_constant_exact': rational_record(constant),
    'box_residual_correction_exact': rational_record(box),
    'equality_multiplier_l1_exact': rational_record(lnorm),
    'near_zero_extension': 'For max-absolute first preactivation <= e, total variation >= lower_bound - (lambda_l1/2)*e.',
    'epsilon_for_tv150_exact': rational_record(epsilon),
    'epsilon_for_tv150_approx': float(epsilon),
    'method': 'Arbitrary exact dyadic equality multipliers and nonpositive inequality multipliers; exact residual minimized over the entire pixel/TV-variable box. No solver accuracy or optimality is trusted.',
    'qualification': 'Excludes this zero/near-zero first-state route from the smooth image region. It does not prove neural-network stability on that region. Exact rational arithmetic, not Lean.'
}
np.savez_compressed(ROOT / 'tv-exclusion-dual-301.npz',
                    equality_multipliers=lam, inequality_multipliers=mu)
(ROOT / 'tv-exclusion-301-exact.json').write_text(json.dumps(out, indent=2)+'\n')
print(json.dumps(out, indent=2))
