#!/usr/bin/env python3
"""Reproduce pinned AIFM median parameter cases and toy-model translations.

Run: python reproduce.py (after obtaining the pinned checkout; see ../REPRODUCE.md)
This writes only beside this file and uses the unmodified MIT-licensed checkout.
"""
import csv
import hashlib
import json
import logging
import math
import os
from pathlib import Path
import platform
import subprocess
import sys

BASE = Path(__file__).resolve().parent
REPO = BASE / "aifm-public"
EXPECTED_COMMIT = "1c40ecdb246c25980515441a66571931c5604e11"
if not REPO.is_dir():
    raise SystemExit("Missing pinned aifm-public checkout. See ../REPRODUCE.md.")
recorded_provenance = json.loads((BASE / "provenance.json").read_text())
actual_commit = subprocess.check_output(["git", "-C", str(REPO), "rev-parse", "HEAD"], text=True).strip()
if actual_commit != EXPECTED_COMMIT:
    raise SystemExit(f"Expected AIFM commit {EXPECTED_COMMIT}; got {actual_commit}.")
for source_path, expected_hash in recorded_provenance["source_hashes"].items():
    actual_hash = hashlib.sha256((REPO / source_path).read_bytes()).hexdigest()
    if actual_hash != expected_hash:
        raise SystemExit(f"Pinned-source hash mismatch: {source_path}")
sys.path.insert(0, str(REPO))
os.chdir(REPO)
import numpy as np
import scipy
from scipy.integrate import quad
from scipy.optimize import least_squares
from scipy.stats import norm
import yaml
from progress_model import Parameters, ProgressModel, load_time_series_data, TasteDistribution

logging.basicConfig(filename=BASE / "reproduction.log", level=logging.WARNING, force=True)

def config_inherited(path):
    c = yaml.safe_load(path.read_text())
    if 'parent' in c:
        parent = config_inherited(path.parent / c['parent'])
        parent['parameters'].update(c.get('parameters', {}))
        return parent
    return c

def central(spec):
    d = spec['dist']
    if d == 'fixed':
        v=spec['value']
        if isinstance(v,str):
            try:return float(v)
            except ValueError:pass
        return v
    if d == 'choice': return spec['values'][np.argmax(spec.get('p', [1]*len(spec['values'])))]
    if d in ('lognormal', 'shifted_lognormal'):
        return math.sqrt(float(spec['ci80'][0]) * float(spec['ci80'][1])) + float(spec.get('shift', 0))
    if d == 'normal': return sum(map(float,spec['ci80'])) / 2
    if d == 'beta':
        from scipy.stats import beta
        return float(beta.ppf(0.5, spec['alpha'], spec['beta']))
    raise ValueError(spec)

def clean(x):
    if isinstance(x, dict): return {k:clean(v) for k,v in x.items()}
    if isinstance(x, (list, tuple, np.ndarray)): return [clean(v) for v in x]
    if isinstance(x, np.generic): return x.item()
    if isinstance(x, float) and not math.isfinite(x): return None
    return x

def run_case(name, overrides):
    p = Parameters(**overrides)
    initial_taste_slope = p.ai_research_taste_slope
    model = ProgressModel(p, load_time_series_data('inputs/input_data.csv'))
    model.compute_progress_trajectory([2017.0, 2060.0])
    r = model.results
    keys = ['r_software','beta_software','anchor_progress_rate','m_over_beta',
            'sie_uplift_doubling_ratio','ai_research_taste_slope_per_effective_oom',
            'ai_research_taste_slope_per_anchor_progress_year','slope_times_log_f',
            'top_taste_num_sds','f_multiplier_per_sd',
            'exp_capacity_params','milestones','td_correction']
    out = {k: clean(r.get(k)) for k in keys}
    out['case'] = name
    out['initial_taste_slope_sd_per_anchor_year'] = initial_taste_slope
    out['overrides'] = clean(overrides)
    out['converted_taste_slope'] = p.ai_research_taste_slope
    out['ces'] = {k:getattr(p,k) for k in ['rho_experiment_capacity','alpha_experiment_capacity','experiment_compute_exponent']}
    out['taste_distribution'] = {k: getattr(p.taste_distribution,k) for k in ['mu','sigma','taste_limit','baseline_mean','median_to_top_gap']}
    out['taste_at_sd'] = {str(z):p.taste_distribution.get_taste_at_sd(z) for z in [0,3.090232306167813,6.180464612335626,9.270696918503439,20,40,100]}
    out['taste_tail_power_in_effective_compute_at_smoothing_half'] = p.taste_distribution.sigma*p.ai_research_taste_slope/(math.log(p.taste_distribution.taste_limit)*math.log(10))
    out['effective_compute_ooms_from_ac_to_99percent_taste_cap'] = (p.taste_distribution.get_sd_of_taste(0.99*p.taste_distribution.taste_limit)-p.ai_research_taste_at_coding_automation_anchor_sd)/p.ai_research_taste_slope
    out['human_only_2024_oom_rate'] = model.human_only_results['reference_sw_progress_rate']
    out['reconstruction_info'] = clean(model._uplift_reconstruction_info)
    out['anchor_stats_used'] = clean(model._anchor_stats_used)
    out['toy_shared_power_singularity_raw_flop'] = 1e29*p.r_software/(p.r_software-1) if p.r_software>1 else None
    beta = 1/p.r_software
    m = p.ai_research_taste_slope*math.log10(p.median_to_top_taste_multiplier)/norm.ppf(p.top_percentile)
    out['analytic_m'] = m
    out['training_lag_asymptotic_uplift_doubling_ratio'] = 2**((beta/m-1)/(beta+1))
    # Independent quadrature of human taste normalization and top/median ratio.
    td=p.taste_distribution
    out['independent_human_mean'] = quad(lambda z:td._transform(td.mu+td.sigma*z)*norm.pdf(z),-10,10,epsabs=1e-11)[0]
    out['independent_top_median_ratio'] = td.get_taste_at_sd(norm.ppf(p.top_percentile))/td.get_taste_at_sd(0)
    assert abs(out['independent_human_mean']-1)<1e-8
    assert abs(out['independent_top_median_ratio']/p.median_to_top_taste_multiplier-1)<1e-8
    assert abs(out['m_over_beta']-m/beta)<1e-10
    return clean(out)

cases=[('python_default', {})]
for who in ['daniel','eli','brendan']:
    conf=config_inherited(REPO / f'config/sampling_config_q2_{who}.yaml')
    cases.append((f'{who}_q2_config_central', {k:central(v) for k,v in conf['parameters'].items()}))
eli=dict(cases[2][1]);eli.update(ai_research_taste_slope=2.1,median_to_top_taste_multiplier=3.698147512646408)
cases.append(('eli_frontend_stale_taste_sensitivity',eli))
for rate in [0.4,2.5]:
    cases.append((f'daniel_software_rate_{rate}_oom_per_year',dict(cases[1][1],software_progress_rate_at_reference_year=rate)))

outputs=[]
for name,overrides in cases:
    print('Running',name,flush=True)
    outputs.append(run_case(name,overrides))
    (BASE/'calibrations.json').write_text(json.dumps(outputs,indent=2)+'\n')

keys=['case','r_software','beta_software','anchor_progress_rate','analytic_m','m_over_beta','sie_uplift_doubling_ratio','training_lag_asymptotic_uplift_doubling_ratio','toy_shared_power_singularity_raw_flop']
with (BASE/'calibrations.csv').open('w') as f:
    w=csv.DictWriter(f,fieldnames=keys);w.writeheader();w.writerows({k:o[k] for k in keys} for o in outputs)

# Taste headroom sensitivity: each entry is model judgment, not observed efficiency.
headroom=[]
for spread in [1.8,3.7,4,4.346640106136302,12.25]:
    for gaps in [2,4,8,16,32,64]:
        headroom.append({'spread':spread,'extra_median_to_top_gaps':gaps,'log10_taste_cap':(1+gaps)*math.log10(spread)})
(BASE/'headroom_sensitivity.json').write_text(json.dumps(headroom,indent=2)+'\n')

# An independent exact trajectory for the unsaturated training-lag model:
# E'=R^r and R'=E^m. With K=(r+1)/(m+1), R=(K E^(m+1))^(1/(r+1))
# is an invariant solution. Numerical quadrature of dt/dE verifies ratios.
lag_tests=[]
for r,m in [(2.4,0.5),(2.4,0.8),(1.0,2.0),(0.5,3.0)]:
    b=r*(m+1)/(r+1);K=(r+1)/(m+1)
    bounds=[2**(j/m) for j in range(4)]
    dts=[quad(lambda E:(K*E**(m+1))**(-r/(r+1)),a,b)[0] for a,b in zip(bounds,bounds[1:])]
    got=dts[1]/dts[0];want=2**((1/r/m-1)/(1/r+1))
    assert abs(got-want)<1e-10
    lag_tests.append(dict(r=r,m=m,doubling_ratio_numeric=got,doubling_ratio_analytic=want,legacy_ratio=2**(1/r/m-1)))
(BASE/'lag_doubling_check.json').write_text(json.dumps(lag_tests,indent=2)+'\n')

files=['progress_model/config.py','progress_model/parameters.py','progress_model/taste_distribution.py','progress_model/_impl.py','progress_model/progress_rate.py','progress_model/ces_functions.py','inputs/input_data.csv','constants/parameters.ts','config/sampling_config.yaml','config/sampling_config_daniel.yaml','config/sampling_config_q2_daniel.yaml','config/sampling_config_q2_eli.yaml','config/sampling_config_q2_brendan.yaml']
provenance=dict(retrieval_date='2026-10-02',commit=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),commit_date=subprocess.check_output(['git','show','-s','--format=%cI'],text=True).strip(),python=platform.python_version(),numpy=np.__version__,scipy=scipy.__version__,pyyaml=yaml.__version__,source_hashes={p:hashlib.sha256((REPO/p).read_bytes()).hexdigest() for p in files})
# Article snapshots are optional and omitted from the public package.
# Preserve the historical hashes rather than pretending to re-read absent files.
provenance['archived_document_hashes'] = dict(recorded_provenance.get('archived_document_hashes', {}))
for name in ['supplementary_materials.txt', 'site_snapshot.html', 'explanations_text.txt']:
    if (BASE / name).is_file():
        provenance['archived_document_hashes'][name] = hashlib.sha256((BASE / name).read_bytes()).hexdigest()
(BASE/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
print(json.dumps([{k:o[k] for k in keys} for o in outputs],indent=2))
