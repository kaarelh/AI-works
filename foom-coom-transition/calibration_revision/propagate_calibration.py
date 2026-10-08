"""GPT-6 (Codex) — 2026-09-13. Recalibrate existing exact stopping draws.

This changes the initial research productivity, preserving the previous tail
prior and individual parameter draws. No empirical likelihood is asserted.
"""
from pathlib import Path
import csv
import hashlib
import json
import math
import sys
import numpy as np
from scipy.special import ndtri
from scipy.stats import qmc

BASE = Path(__file__).resolve().parent
OLD = BASE.parent / 'forecast_revision'
if not OLD.exists():
    OLD = BASE.parent / 'forecast-revision'
sys.path.insert(0, str(OLD))
from math_model import CeilingModel, ExponentialCeilingModel, ContinuumCeilingModel
from make_forecast import summarize


def run_row(row, lk):
    fam = row['family']
    h = float(row['log10_H']) if row['log10_H'] else None
    if fam == 'single_power_gap':
        model = CeilingModel(float(row['p']), h, log10_k0=lk)
    elif fam == 'heterogeneous_gaps':
        amp = float(row['slow_amplitude'])
        model = CeilingModel([float(row['p_fast']), float(row['p_slow'])],
                             h, [1-amp, amp], log10_k0=lk)
    elif fam == 'rapid_ceiling':
        model = ExponentialCeilingModel(h, log10_k0=lk)
    elif fam == 'continuous_slow_gaps':
        model = ContinuumCeilingModel(h, log10_k0=lk)
    elif fam == 'scale_free_within_budget':
        p = float(row['raw_p'])
        x = p / (1+p) * (1e120 - 10**(-lk))
        ans = {'log10_optimal_x': math.log10(x),
               'log10_exact_threshold_x': math.log10(p*(1e120 - 10**(-lk))),
               'log10_a_at_optimum': p*math.log10(1 + 10**lk*x/p),
               'economic_root_log_residual': 0}
    else:
        raise ValueError(fam)
    if fam != 'scale_free_within_budget':
        ans = model.solve(scan=False)
    return {**row, 'log10_k0': lk, 'log10_x_stop': ans['log10_optimal_x'],
            'log10_x_exact': ans['log10_exact_threshold_x'],
            'log10_a_stop': ans['log10_a_at_optimum'],
            'root_log_residual': ans['economic_root_log_residual']}


def main():
    spec = json.loads((BASE/'calibration_prior.json').read_text())
    prior = json.loads((OLD/'forecast_prior.json').read_text())
    with (OLD/'forecast_draws.csv').open() as f:
        oldrows = [r for r in csv.DictReader(f) if float(r['log10_H_max']) == 12]
    families = list(prior['family_weights']['central'])
    fixed = {}
    records = []
    max_reproduction_error = 0
    max_residual = 0
    for lk in spec['fixed_log10_k0_sensitivity']:
        rows = [run_row(r, lk) for r in oldrows]
        max_residual = max(max_residual, max(abs(r['root_log_residual']) for r in rows))
        if lk == -27.5:
            max_reproduction_error = max(abs(r['log10_x_stop'] - float(o['log10_x_stop']))
                                         for r, o in zip(rows, oldrows))
        fixed[str(lk)] = {name: summarize(rows, w) for name, w in prior['family_weights'].items()}
        for r in rows:
            r['calibration'] = f'fixed_{lk}'
        records.extend(rows)
        print('Completed fixed log10 k0', lk, flush=True)
    # Each family receives an independent permutation of the same quantile set,
    # preventing the calibration from acquiring a spurious correlation with the
    # Sobol tail draws used by the original forecast.
    n = len(oldrows)//len(families)
    u = qmc.Sobol(d=1, scramble=True, seed=spec['seed']).random_base2(int(math.log2(n)))[:,0]
    ls = spec['normalization']['log10_k0_median'] + spec['normalization']['log10_k0_sd']*ndtri(u)
    rng = np.random.default_rng(spec['seed'])
    per_family = {fam: rng.permutation(ls) for fam in families}
    uncertain = [run_row(r, float(per_family[r['family']][int(r['draw'])])) for r in oldrows]
    for r in uncertain:
        r['calibration'] = 'uncertain'
    records.extend(uncertain)
    max_residual = max(max_residual, max(abs(r['root_log_residual']) for r in uncertain))
    examples = []
    for p in [.1, .25, .5, 1., 2.]:
        out = {'p': p, 'log10_H': 12}
        for lk in [-27.5, -29]:
            out[str(lk)] = CeilingModel(p, 12, log10_k0=lk).solve(scan=False)['log10_optimal_x']
        examples.append(out)
    assert max_reproduction_error < 1e-10, max_reproduction_error
    assert max_residual < 1e-8, max_residual
    results = {
        'author': 'GPT-6 (Codex)', 'date': '2026-09-13',
        'status': 'Subjective scenario forecasts; preserve previous tail prior, change normalization only.',
        'calibration_prior': spec,
        'calibration_prior_sha256': hashlib.sha256((BASE/'calibration_prior.json').read_bytes()).hexdigest(),
        'tail_prior_sha256': hashlib.sha256((OLD/'forecast_prior.json').read_bytes()).hexdigest(),
        'fixed_calibration': fixed,
        'uncertain_calibration': {name: summarize(uncertain,w) for name,w in prior['family_weights'].items()},
        'single_gap_examples': examples,
        'audit': {'number_of_solved_scenarios': len(records),
                  'max_baseline_reproduction_log10_error': max_reproduction_error,
                  'max_absolute_economic_root_natural_log_residual': max_residual},
    }
    (BASE/'calibration_results.json').write_text(json.dumps(results, indent=2)+'\n')
    with (BASE/'calibration_draws.csv').open('w') as f:
        w = csv.DictWriter(f, fieldnames=list(records[0])); w.writeheader(); w.writerows(records)
    print(json.dumps({k: results[k] for k in ['uncertain_calibration','single_gap_examples','audit']}, indent=2))


if __name__ == '__main__':
    main()
