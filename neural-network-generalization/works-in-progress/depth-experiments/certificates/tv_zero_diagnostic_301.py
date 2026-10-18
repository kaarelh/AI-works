#!/usr/bin/env python3
"""Declared postprotocol LP diagnostic for the existing fully fitted model301.

Minimize anisotropic pixel total variation subject to exact zero first-layer
preactivation equations, a black two-pixel border, and mean ink <= 1/5.
LP outputs and rounding residuals are numerical diagnostics, not exact proofs.
No model fitting or adversarial optimization is performed by this script.
"""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
os.environ['OMP_NUM_THREADS'] = '1'
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix, csr_matrix, hstack, vstack

ROOT = Path(__file__).resolve().parent
EXP = ROOT.parent / 'experiment'
sys.path.insert(0, str(EXP))
import attacks
import train


def tv(pixels):
    p = np.asarray(pixels).reshape(-1, 28, 28)
    return (np.abs(np.diff(p, axis=1)).sum(axis=(1, 2))
            + np.abs(np.diff(p, axis=2)).sum(axis=(1, 2)))


def main():
    started = time.monotonic()
    protocol = {
        'declared_utc': datetime.now(timezone.utc).isoformat(),
        'status': 'Postprotocol diagnostic; model301 chosen by the research question before solving.',
        'model': 301,
        'constraints': ['Black outer two-pixel border', 'Pixel ink in [0,1]',
                        'Mean ink <= 1/5', 'Zero first-layer affine preactivations'],
        'objective': 'Minimum anisotropic four-neighbor total variation in pixel ink units',
        'rounding': 'Nearest 8-bit rounding plus 4096 independent unbiased roundings, seed 258301',
        'selection': 'Report nearest rounding and minimum max-absolute first-layer residual among all roundings.',
        'scope': 'Continuous LP diagnostic only; no discrete counterexample or rigorous optimum is inferred.'
    }
    (ROOT / 'tv-zero-diagnostic-301-protocol.json').write_text(json.dumps(protocol, indent=2) + '\n')
    record_path = next((EXP / 'records').glob('301-*.json'))
    record = json.loads(record_path.read_text())
    config = record['config']
    weights = attacks.load_model(config)
    d, n = weights[0].shape[0] - 1, weights[0].shape[1]
    coords = np.indices((28, 28))
    border = ((coords[0] < 2) | (coords[0] >= 26)
              | (coords[1] < 2) | (coords[1] >= 26)).reshape(-1)
    edges = [(i*28+j, (i+1)*28+j) for i in range(27) for j in range(28)]
    edges += [(i*28+j, i*28+j+1) for i in range(28) for j in range(27)]
    m = len(edges)
    rows, cols, values = [], [], []
    for k, (i, j) in enumerate(edges):
        for row, sign in [(2*k, 1), (2*k+1, -1)]:
            rows += [row, row, row]
            cols += [i, j, d+k]
            values += [sign, -sign, -1.]
    a = coo_matrix((values, (rows, cols)), shape=(2*m, d+m)).tocsr()
    a = vstack([a, csr_matrix(np.r_[np.ones(d), np.zeros(m)][None, :])])
    b = np.r_[np.zeros(2*m), -.6*d]
    eq = hstack([csr_matrix(weights[0][:-1].T), csr_matrix((n, m))])
    bounds = [(-1., -1.) if bit else (-1., 1.) for bit in border] + [(0., 2.)]*m
    lp = linprog(np.r_[np.zeros(d), np.ones(m)], A_ub=a, b_ub=b,
                 A_eq=eq, b_eq=-weights[0][-1], bounds=bounds, method='highs')
    result = {'model': config['id'], 'lp_success': bool(lp.success),
              'lp_message': lp.message, 'protocol': protocol,
              'training_all_margins_above_half': record['train']['all_margins_above_half']}
    if lp.success:
        x = lp.x[:d]
        pixel_float = np.clip(127.5*(x+1), 0, 255)
        nearest = np.rint(pixel_float).astype(np.uint8)
        low = np.floor(pixel_float).astype(np.int16)
        rng = np.random.default_rng(258301)
        stochastic = low[None, :] + (rng.random((4096, d)) < (pixel_float-low)).astype(np.int16)
        pixels = np.vstack([nearest, stochastic]).astype(np.uint8)
        xx = (2*pixels.astype(np.float64)-255)/255
        pre = np.c_[xx, np.ones(len(xx))] @ weights[0]
        residual = np.max(np.abs(pre), axis=1)
        best = int(np.argmin(residual))
        output = train.predict(weights, xx)
        def metrics(i):
            return {'index': i, 'max_abs_first_preactivation': float(residual[i]),
                    'first_preactivation_l2': float(np.linalg.norm(pre[i])),
                    'mean_ink': float(np.mean(pixels[i]/255)),
                    'total_variation': float(tv(pixels[i]/255)[0]),
                    'black_border': bool(np.all(pixels[i, border] == 0)),
                    'clean_output': float(output[i])}
        result.update(continuous_minimum_tv_numerical=float(lp.fun/2),
                      continuous_tv=float(tv((x+1)/2)[0]),
                      continuous_mean_ink=float(np.mean((x+1)/2)),
                      continuous_max_abs_first_preactivation=float(np.max(np.abs(np.r_[x, 1]@weights[0]))),
                      continuous_within_tv150=bool(lp.fun/2 <= 150),
                      nearest_rounding=metrics(0), minimum_residual_rounding=metrics(best),
                      all_rounded_tv_range=[float(np.min(tv(pixels/255))), float(np.max(tv(pixels/255)))],
                      rounded_candidates_in_region=int(np.sum((tv(pixels/255) <= 150) & (np.mean(pixels/255, axis=1) <= .2))),
                      qualification='Float64 LP and rounding diagnostics; exact feasibility/optimality and perturbation violations require separate verification.')
        np.savez_compressed(ROOT / 'tv-zero-diagnostic-301.npz',
                            continuous_input=x, nearest_pixels=nearest,
                            minimum_residual_pixels=pixels[best], all_pixels=pixels,
                            all_outputs=output, all_residuals=residual,
                            lp_inequality_marginals=lp.ineqlin.marginals,
                            lp_equality_marginals=lp.eqlin.marginals)
    result['elapsed_seconds'] = time.monotonic() - started
    (ROOT / 'tv-zero-diagnostic-301.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2), flush=True)


if __name__ == '__main__':
    main()
