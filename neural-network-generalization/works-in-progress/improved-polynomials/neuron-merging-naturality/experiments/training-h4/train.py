#!/usr/bin/env python3
"""Exploratory, fixed-protocol ordinary training from the theorem's mean-field Gaussian initialization."""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
os.environ['OMP_NUM_THREADS'] = '1'
os.environ['MKL_NUM_THREADS'] = '1'

import argparse
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime, timezone
from fractions import Fraction
import hashlib
import itertools
import json
from pathlib import Path
import platform
import time

import numpy as np

ROOT = Path(__file__).resolve().parent


def configurations():
    result = []
    for index, (task, width, optimizer, seed) in enumerate(itertools.product(
            ['majority5', 'parity3'], [32, 64], ['adam', 'sgd'], [0, 1])):
        result.append(dict(
            id=f'{index:03d}-{task}-H4-N{width}-{optimizer}-s{seed}',
            dimension=8, hidden_depth=4, width=width, task=task,
            optimizer=optimizer, seed=seed, steps=4000, train_count=128,
            learning_rate=.003 if optimizer == 'adam' else .05,
            weight_decay=1e-6, initialization_seed=1000 + seed,
            split_seed=2000 + seed,
        ))
    return result


def data(c):
    x = np.array(list(itertools.product([-1., 1.], repeat=c['dimension'])))
    if c['task'] == 'majority5':
        y = np.sign(np.sum(x[:, :5], axis=1))
    else:
        y = np.prod(x[:, :3], axis=1)
    order = np.random.default_rng(c['split_seed']).permutation(len(x))
    return x, y, order[:c['train_count']], order[c['train_count']:]


def initialize(c):
    rng = np.random.default_rng(c['initialization_seed'])
    d, n, h = c['dimension'], c['width'], c['hidden_depth']
    w = [rng.normal(size=(d+1, n))/np.sqrt(d)]
    w.extend(rng.normal(size=(n, n))/np.sqrt(n) for _ in range(h-1))
    w.append(rng.normal(size=n)/n)
    return w


def forward(w, x):
    h = np.column_stack((x, np.ones(len(x))))
    states = [h]
    activations = []
    for a in w[:-1]:
        h = np.tanh(h @ a)
        states.append(h)
        activations.append(h)
    return h @ w[-1], states, activations


def metrics(z, y):
    margin = y*z
    return dict(count=len(y), mse=float(np.mean((z-y)**2)),
                sign_errors=int(np.sum(margin <= 0)),
                accuracy=float(np.mean(margin > 0)),
                minimum_signed_margin=float(np.min(margin)),
                fraction_margin_above_half=float(np.mean(margin > .5)),
                all_margins_above_half=bool(np.all(margin > .5)),
                minimum_absolute_output=float(np.min(np.abs(z))))


def readout_record(v):
    n = len(v)
    ev = n*sum((Fraction(float(a))**2 for a in v), Fraction())
    return dict(readout_energy=float(ev),
                readout_energy_numerator=str(ev.numerator),
                readout_energy_denominator=str(ev.denominator),
                q_allowed_max_exact=min(n, (1+ev).numerator//(1+ev).denominator),
                q_equals_width_is_allowed_exact=ev >= n-1)


def train(c):
    started = time.monotonic()
    x, y, tr, te = data(c)
    w = initialize(c)
    initial_path = ROOT/'initial-models'/f"{c['id']}.npz"
    np.savez(initial_path, **{f'w{i}':a for i,a in enumerate(w)})
    initial_ev = readout_record(w[-1])
    z = forward(w, x)[0]
    initial_metrics = dict(train=metrics(z[tr], y[tr]), test=metrics(z[te], y[te]))
    moms = [np.zeros_like(a) for a in w]
    variances = [np.zeros_like(a) for a in w]
    history = []
    failure = None
    completed_steps = 0
    for step in range(1, c['steps']+1):
        z, states, activations = forward(w, x[tr])
        dz = (z-y[tr])/len(tr)
        gradients = [None]*len(w)
        gradients[-1] = states[-1].T@dz + c['weight_decay']*w[-1]
        dh = dz[:, None]*w[-1]
        for j in reversed(range(c['hidden_depth'])):
            da = dh*(1-activations[j]**2)
            gradients[j] = states[j].T@da+c['weight_decay']*w[j]
            dh = da@w[j].T
        lr = c['learning_rate']*(1 if step <= .8*c['steps'] else .3)
        for j, g in enumerate(gradients):
            if c['optimizer'] == 'adam':
                moms[j] = .9*moms[j]+.1*g
                variances[j] = .999*variances[j]+.001*g*g
                w[j] -= lr*(moms[j]/(1-.9**step))/(np.sqrt(variances[j]/(1-.999**step))+1e-8)
            else:
                w[j] -= lr*g
        completed_steps = step
        if not all(np.isfinite(a).all() for a in w):
            failure = 'Nonfinite training weights; last attempted iterate retained.'
            break
        if step in {1, 100, 1000, c['steps']}:
            current = forward(w, x)[0]
            history.append(dict(step=step, train=metrics(current[tr], y[tr]),
                                test=metrics(current[te], y[te]),
                                readout_energy=float(c['width']*np.sum(w[-1]**2))))
    model_path = ROOT/'models'/f"{c['id']}.npz"
    np.savez(model_path, **{f'w{i}':a for i,a in enumerate(w)},
             target=y, train_indices=tr, test_indices=te)
    if failure is None:
        z = forward(w, x)[0]
        final_metrics = dict(train=metrics(z[tr], y[tr]), test=metrics(z[te], y[te]),
                             full_cube=metrics(z, y))
        energy = readout_record(w[-1])
    else:
        final_metrics, energy = {}, {}
    result = dict(config=c, initial_energy=initial_ev, initial_metrics=initial_metrics,
                  history=history, completed_steps=completed_steps,
                  failure=failure, final=final_metrics, final_energy=energy,
                  initial_checkpoint_sha256=hashlib.sha256(initial_path.read_bytes()).hexdigest(),
                  final_checkpoint_sha256=hashlib.sha256(model_path.read_bytes()).hexdigest(),
                  elapsed_seconds=time.monotonic()-started,
                  numerical_scope='Training and metrics float64; exact rational readout energy from stored final coordinates.')
    (ROOT/'records'/f"{c['id']}.json").write_text(json.dumps(result, indent=2)+'\n')
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--declare', action='store_true')
    parser.add_argument('--run', action='store_true')
    args = parser.parse_args()
    configs = configurations()
    if args.declare:
        protocol = ROOT/'protocol.json'
        if protocol.exists():
            raise RuntimeError('Protocol already exists; do not silently redeclare.')
        for subdir in ['initial-models', 'models', 'records']:
            (ROOT/subdir).mkdir(parents=True, exist_ok=True)
        protocol.write_text(json.dumps(dict(
            declared_at_utc=datetime.now(timezone.utc).isoformat(),
            status='Exploratory follow-up. Protocol declared before these runs, after examining previous training cohorts.',
            architecture='First augmented-input tanh, no later biases, four hidden layers, scalar linear readout.',
            initialization='Independent centered Gaussian coordinates: first variance 1/d, internal variance 1/N, readout variance 1/N^2. Exact mean-field t=1 family.',
            optimizer='Ordinary full-batch Adam(.9,.999,epsilon1e-8) or vanilla SGD; no layerwise gradient rescaling. MSE/2 plus ordinary weight_decay*sum(weights^2)/2.',
            schedule='4000 steps, learning rate multiplied by .3 in final 20%; no early stopping or outcome-based selection.',
            data='Full d=8 Boolean cube, labels majority of first5 or parity of first3, uniform random 128-point train subset without replacement and complementary test set.',
            retention='All 16 configurations and failures retained; no post-training output rescaling. Initial and final weights saved.',
            compute='At most two worker processes, one BLAS thread each.',
            python=platform.python_version(), numpy=np.__version__, configurations=configs,
        ), indent=2)+'\n')
        print(protocol, flush=True)
    if args.run:
        protocol = json.loads((ROOT/'protocol.json').read_text())
        assert protocol['configurations'] == configs
        existing = list((ROOT/'records').glob('*.json'))
        if existing:
            raise RuntimeError('Existing results found; refuse to overwrite the cohort.')
        results = []
        with ProcessPoolExecutor(max_workers=2) as executor:
            futures = {executor.submit(train,c):c for c in configs}
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
                final = result['final']
                print(result['config']['id'], 'train', final.get('train'),
                      'Ev', result['final_energy'].get('readout_energy'),
                      'seconds', round(result['elapsed_seconds'],2), flush=True)
        results.sort(key=lambda r:r['config']['id'])
        summary = dict(
            configurations=len(results), failures=sum(r['failure'] is not None for r in results),
            zero_training_sign_error=sum(r['final'].get('train',{}).get('sign_errors') == 0 for r in results),
            all_training_margins_above_half=sum(r['final'].get('train',{}).get('all_margins_above_half',False) for r in results),
            trivial_population_condition=sum(r['final_energy'].get('q_equals_width_is_allowed_exact',False) for r in results),
            models=[dict(id=r['config']['id'], final=r['final'], energy=r['final_energy'], elapsed_seconds=r['elapsed_seconds']) for r in results],
        )
        (ROOT/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
        print(json.dumps({k:v for k,v in summary.items() if k!='models'}, indent=2), flush=True)


if __name__ == '__main__':
    main()
