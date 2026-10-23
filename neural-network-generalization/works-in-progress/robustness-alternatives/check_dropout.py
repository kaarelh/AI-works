#!/usr/bin/env python3
"""Small frozen-checkpoint diagnostic; no training, no repository edits."""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
os.environ['OMP_NUM_THREADS'] = '1'
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1] / 'improved-polynomials/neuron-merging-naturality/experiments/training-h23'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, default=Path(__file__).with_name('dropout-diagnostic.recomputed.json'))
OUT = parser.parse_args().output
BASELINE = json.loads(Path(__file__).with_name('dropout-diagnostic.json').read_text())
EXPECTED = {row['id']: row['checkpoint_sha256'] for row in BASELINE['models']}
REPS = 100

def energy(w, d):
    n = len(w[-1])
    return float(d/n*np.sum(w[0]**2) + sum(np.sum(a*a) for a in w[1:-1]) + n*np.sum(w[-1]**2))

records = []
for model_id in sorted(EXPECTED):
    path = ROOT / 'models' / (model_id + '.npz')
    assert hashlib.sha256(path.read_bytes()).hexdigest() == EXPECTED[model_id], f'Checkpoint changed: {model_id}'
    meta = json.loads((ROOT/'records'/(path.stem+'.json')).read_text())
    c = meta['config']
    d, h, n = c['dimension'], c['hidden_depth'], c['width']
    x = (2*((np.arange(2**d)[:,None] >> np.arange(d-1,-1,-1)) & 1)-1).astype(float)
    with np.load(path) as a:
        w = [a[f'w{i}'].copy() for i in range(h+1)]
        target = a['target'].copy()
    hidden1 = np.tanh(np.column_stack((x, np.ones(len(x)))) @ w[0])
    z = hidden1
    for a in w[1:-1]: z = np.tanh(z @ a)
    z = z @ w[-1]
    clean = np.clip(z, -.5, .5)
    kappa = energy(w,d)
    ev = float(n*np.sum(w[-1]**2))
    r = ev/float(np.max(np.abs(z)))**2
    retained = sorted(set([n, n-1, max(1,3*n//4), max(1,n//2), max(1,n//4), min(n,max(1,int(np.ceil(r))))]))
    rng = np.random.default_rng(915000+int(path.stem[:3]))
    rows = []
    for m in retained:
        success = 0
        changes, disagreements, errors, energies = [],[],[],[]
        for trial in range(REPS):
            inds = [np.sort(rng.choice(n,m,replace=False)) for _ in range(h)]
            hh = hidden1[:,inds[0]]
            wc = [w[0][:,inds[0]]]
            for s in range(1,h):
                mat = (n/m)*w[s][np.ix_(inds[s-1],inds[s])]
                wc.append(mat)
                hh = np.tanh(hh @ mat)
            readout = (n/m)*w[-1][inds[-1]]
            wc.append(readout)
            zz = hh @ readout
            change = float(np.max(np.abs(np.clip(zz,-.5,.5)-clean)))
            changes.append(change)
            success += int(change <= 1/16)
            disagreements.append(float(np.mean(np.sign(zz) != np.sign(z))))
            errors.append(float(np.mean(np.sign(zz) != target)))
            energies.append(energy(wc,d))
        rows.append({'retained':m,'masks':REPS,'uniform_clipped_successes':success,
                     'mean_max_clipped_change':float(np.mean(changes)),
                     'mean_sign_disagreement_with_original':float(np.mean(disagreements)),
                     'mean_target_sign_error':float(np.mean(errors)),
                     'mean_compressed_energy_ratio':float(np.mean(energies)/kappa)})
    records.append({'id':path.stem,'checkpoint_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                    'd':d,'H':h,'N':n,'optimizer':c['optimizer'],'trained_with_dropout':False,
                    'clean_sign_error':float(np.mean(np.sign(z)!=target)),
                    'clean_min_abs_output':float(np.min(np.abs(z))),
                    'kappa':kappa,'readout_energy':ev,'normalized_readout_R':r,'curves':rows})
result={'scope':'Exploratory float64 Monte Carlo on all 2^9 Boolean inputs of twelve existing Adam-trained checkpoints, no new training. Exact theorem calibration is deliberately not used because A0 makes m=N here. No full support certificate or population-level empirical conclusion is claimed.',
        'masks_per_retention':REPS,'models':records}
OUT.write_text(json.dumps(result,indent=2)+'\n')
for rec in records:
    print(rec['id'], 'R', round(rec['normalized_readout_R'],2),
          [(r['retained'],r['uniform_clipped_successes'],round(r['mean_sign_disagreement_with_original'],3)) for r in rec['curves']])
