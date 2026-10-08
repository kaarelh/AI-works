#!/usr/bin/env python3
"""Consolidate finalized fits without rerunning them; retain complete source JSONs.

CSV is a flat comparison. JSON also preserves every underlying source record,
including individual bootstrap samples, diagnostics, and source provenance.
"""
import csv,json,math,hashlib
from collections import Counter
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
N=1e120;K0=10**-27.5
DOCS={};ROWS=[]
def read(rel):
 d=json.loads((ROOT/rel).read_text());DOCS[rel]=d;return d

def number(logx):return 10**logx if logx is not None and logx<308 else None

def add(family,method,closure,anchor,source_file,source_pointer='',**kw):
 r=dict(id=f'method_{len(ROWS)+1:04d}',family=family,method=method,closure=closure,anchor=anchor,N=N,k0=K0,
        row_type='point_fit',status='',stop_flops=None,log10_stop_flops=None,stop_fraction_N=None,
        remaining_flops=None,log10_remaining_flops=None,exact_threshold_flops=None,log10_exact_threshold_flops=None,
        exact_threshold_status=None,divergence_flops=None,log10_divergence_flops=None,b=None,p=None,
        research_compute_growth_proxy=None,hardware_efficiency_growth=None,probability_finite_stop=None,
        probability_positive_slope=None,conditional_stop_flops_q05=None,conditional_stop_flops_q50=None,
        conditional_stop_flops_q95=None,conditional_threshold_flops_q05=None,conditional_threshold_flops_q50=None,
        conditional_threshold_flops_q95=None,source_file=source_file,source_pointer=source_pointer,notes='')
 r.update(kw)
 for val,log in [('stop_flops','log10_stop_flops'),('exact_threshold_flops','log10_exact_threshold_flops'),('divergence_flops','log10_divergence_flops')]:
  if r[val] is None and r[log] is not None:r[val]=number(r[log])
  if r[log] is None and r[val] is not None and r[val]>0:r[log]=math.log10(r[val])
 if r['stop_flops'] is not None:
  if r['stop_fraction_N'] is None:r['stop_fraction_N']=r['stop_flops']/N
  if r['remaining_flops'] is None and r['log10_remaining_flops'] is not None:r['remaining_flops']=number(r['log10_remaining_flops'])
  if r['remaining_flops'] is None and N-r['stop_flops']>0:r['remaining_flops']=N-r['stop_flops']
  if r['log10_remaining_flops'] is None and r['remaining_flops'] is not None:r['log10_remaining_flops']=math.log10(r['remaining_flops'])
 if r['exact_threshold_status'] is None and r['log10_exact_threshold_flops'] is not None:
  r['exact_threshold_status']='within_budget' if r['log10_exact_threshold_flops']<=120 else 'beyond_budget'
 ROWS.append(r);return r

def toy_fields(t):
 status=t.get('status','');b=t['b']
 s='finite_optimum' if b>=0 else 'no_finite_maximizer'
 return dict(status=s,b=b,stop_flops=t.get('stop_flops'),remaining_flops=t.get('remaining_at_stop'),
  exact_threshold_flops=t.get('threshold_flops'),divergence_flops=t.get('divergence_flops'),
  exact_threshold_status=('never' if b<=0 else None),notes=status)

def conditionals(vals,prefix='conditional_stop_flops',scale=N):
 return {prefix+'_q'+q:float(v*scale) for q,v in zip(['05','50','95'],vals)}

# Stockfish: each attempted fit under both interpretations, including failed tails.
s=read('stockfish/stopping_results.json');fit=read('stockfish/fit_results.json');read('stockfish/provenance.json')
for i,r in enumerate(s['fits']):
 for cl in ['raw_proxy','recursive_proxy']:
  args=dict(family='stockfish_tests',method=r['name'],closure=cl,anchor=s['current_anchor'],source_file='stockfish/stopping_results.json',source_pointer=f'/fits/{i}/{cl}')
  if r.get('status')=='tail_unidentified':
   args['source_pointer']=f'/fits/{i}'
   add(**args,status='tail_unidentified',exact_threshold_status='unidentified',notes=r['reason']);continue
  t=r[cl];b=None;p=r.get('power_exponent')
  if p is not None:b=1/p if cl=='raw_proxy' else 1/p-1
  if r['name']=='exponential':b=0 if cl=='raw_proxy' else -1
  kw=dict(status=t['status'],b=b,p=p,stop_flops=t.get('optimal_research_flops'),log10_stop_flops=t.get('log10_optimal_research_flops'),
   log10_remaining_flops=t.get('log10_remaining_flops'),notes='; '.join(str(t[k]) for k in ['reason','rounding','approximation'] if k in t))
  ex=t.get('exact_1e_minus120_threshold',{})
  kw.update(exact_threshold_flops=ex.get('flops'),log10_exact_threshold_flops=ex.get('log10_flops'),exact_threshold_status=ex.get('status'))
  div=t.get('research_singularity',{});kw.update(divergence_flops=div.get('flops'),log10_divergence_flops=div.get('log10_flops'))
  if t['status']=='no_finite_maximizer':kw['exact_threshold_status']='never'
  add(**args,**kw)

# Vision, language models and all 11 floor profiles x 3 input-growth proxies.
v=read('vision_lm/results.json');vb=read('vision_lm/bootstrap_results.json')
def vision_projection(family,method,r,j,anchor,pointer,profile=None):
 for proxy,t in r['projections'].items():
  p=t['p'];floor=(profile is not None and profile>0)
  add(family,method,'raw_proxy_power' if not floor else 'raw_proxy_compute_floor',anchor,
   'vision_lm/results.json',pointer+'/projections/'+proxy,status='finite_optimum',p=p,b=None if floor else 1/p,
   research_compute_growth_proxy=v['proxy_growth_per_year'][proxy],stop_flops=t.get('stop_flops'),log10_stop_flops=t.get('log10_stop_flops'),
   exact_threshold_flops=t.get('exact_1e120_threshold_flops'),log10_exact_threshold_flops=t.get('log10_exact_threshold_flops'),
   notes=f'Proxy: {proxy}. '+(f'Fixed floor profile fraction of final observed compute={profile}; finite ceiling is a sensitivity assumption.' if profile is not None else 'Calendar-to-input conversion assumes exponential research input, allocation/utilization stability and benchmark transfer.'))
for key,family in [('vision','vision_training'),('language_models','language_model_training')]:
 for j,r in enumerate(v[key]):
  end=v['dates']['vision' if key=='vision' else 'LM'][-1]
  if r['method']=='vision_OLS_first3':end='historical third observation; pure power result invariant to anchor after k0 reset'
  if r['method']=='LM_nonlinear_pre2020_training_only':end='pre-2020 training subset; pure power result invariant to anchor after k0 reset'
  vision_projection(family,r['method'],r,j,end,f'/{key}/{j}')
for j,r in enumerate(v['vision_floor_profile']):
 f=r['floor_fraction_of_last_observed_compute']
 vision_projection('vision_floor_profile',f'floor_fraction_{f:.12g}',r,j,r['forecast_anchor'],f'/vision_floor_profile/{j}',profile=f)
r=v['vision_floor_projected_current_anchor']
vision_projection('vision_floor_projected_anchor','best_historical_floor_reanchored_2026',r,0,r['forecast_anchor'],'/vision_floor_projected_current_anchor',profile=r['historical_floor_fraction_of_anchor_compute'])
for r in ROWS:
 if r['family']=='vision_floor_projected_anchor':r['notes']+=' 2026 anchor is projected from the 2019 curve, not observed; k0 reset at projected anchor.'
# Preserve all 200 samples in source_documents; CSV has their three summary laws.
ss=np.array([r['s'] for r in vb['samples'] if r.get('success')]);positive=ss>0
for proxy,G in v['proxy_growth_per_year'].items():
 pp=ss[positive]/math.log(G)
 add('language_model_bootstrap','paper_cluster_bootstrap_200','raw_proxy_power',v['dates']['LM'][-1],
  'vision_lm/bootstrap_results.json','/samples',row_type='conditional_bootstrap_summary',status='conditional_bootstrap_summary',
  probability_positive_slope=float(positive.mean()),research_compute_growth_proxy=G,
  **conditionals(np.quantile(pp/(1+pp),[.05,.5,.95])),
  **conditionals(np.quantile(pp,[.05,.5,.95]),'conditional_threshold_flops'),
  notes='No unconditional point stop in this row. Quantiles conditional on positive successful bootstrap slope; full 200 source records preserved. This bootstrap is not an independent fitted method.')

# Published plug-ins: Jones plus median-r and naive-r cumulative closures.
pub=read('published_domains/published_results.json');post=read('published_domains/posterior_qmc_results.json');read('published_domains/source_manifest.json')
for j,r in enumerate(pub['published']):
 for key,cl in [('jones_plugin_from_separate_medians','full_Jones_universal_feedback_separate_medians'),('cumulative_effort_surrogate_from_median_r','cumulative_effort_universal_feedback_median_r'),('cumulative_effort_surrogate_from_naive_r','cumulative_effort_universal_feedback_naive_r')]:
  kw=toy_fields(r[key]);kw['notes']+='; '+r['note']
  add('published_domain_plugin',f'{r["year"]}_{r["domain"]}',cl,'historical domain endpoint; k0 reset',
   'published_domains/published_results.json',f'/published/{j}/{key}',**kw)
for j,r in enumerate(pub['growth_refits']):
 for key,cl in [('cumulative_effort_full_feedback','cumulative_effort_universal_feedback'),('cumulative_effort_cognitive_only_feedback','cumulative_effort_cognitive_only_feedback')]:
  kw=toy_fields(r[key]);kw['notes']+='; g_A=ln(3) assumed; 2022/2024/2025 compute and 2023–2025 staff data. Full Jones b not identified by growth ratios. epsilon_K='+str(r['epsilon_K'])
  add('openai_growth_proxy',r['method']+'_epsilonK_'+str(r['epsilon_K']),cl,'2025 growth-data endpoint; k0 reset',
   'published_domains/published_results.json',f'/growth_refits/{j}/{key}',**kw)
r=pub['original_rounded_growth_ratio'];add('openai_growth_proxy','original_rounded_growth_inputs','cumulative_effort_universal_feedback','2025 rounded-input sensitivity; k0 reset',
 'published_domains/published_results.json','/original_rounded_growth_ratio',**toy_fields(r['full_feedback_surrogate']))
r=pub['growth_uncertainty'];add('openai_growth_uncertainty','source_assumption_distribution','cumulative_effort_universal_feedback','2025 growth-data endpoint; k0 reset',
 'published_domains/published_results.json','/growth_uncertainty',row_type='conditional_assumption_sensitivity',status='conditional_assumption_sensitivity',
 probability_finite_stop=r['probability_finite_stop_under_cumulative_surrogate'],**conditionals(r['conditional_finite_stop_fraction_quantiles']),
 notes=r['method']+'; conditional finite stop only, not an unconditional forecast. Joint source sensitivity fields preserved.')
for name,replicates in post.items():
 for j,r in enumerate(replicates):
  add('published_joint_posterior',name+'_seed_'+str(r['seed']),'full_Jones_universal_feedback','historical domain endpoint; k0 reset',
   'published_domains/posterior_qmc_results.json',f'/{name}/{j}',row_type='conditional_posterior_summary',status='conditional_posterior_summary',
   probability_finite_stop=r['probability_finite_stop'],**conditionals(r['conditional_stop_fraction_quantiles']),
   **conditionals(r['conditional_threshold_over_N_quantiles'],'conditional_threshold_flops'),
   notes='Conditional on beta>lambda; ordinary stop/threshold columns intentionally blank. Model/prior-specific probabilities, not calibrated universal-fooming probabilities. Numerical diagnostics preserved in source JSON.')

# Inference: all 60 H/G variants, including negative trends; three unavailable fits.
inf=read('inference/inference_results.json');read('inference/source_manifest.json');ifits={r['id']:r for r in inf['fits']}
for j,r in enumerate(inf['projections']):
 f=ifits[r['fit_id']];positive=r['p']>0
 kw=dict(status='finite_optimum' if positive else 'nonpositive_improvement_incompatible_k0',p=r['p'],b=1/r['p'] if positive else None,
   stop_flops=r.get('x_stop'),exact_threshold_flops=r.get('x_exact'),hardware_efficiency_growth=r['hardware_efficiency_growth'],
   research_compute_growth_proxy=r['research_compute_growth_proxy'],probability_positive_slope=r.get('bootstrap_positive_fraction'),
   notes=r['status']+'; primary date-cleaned sample, hardware-adjusted inference price, not measured FLOPs. Bootstrap intervals conditional on positive slope and fixed selected sample; explicit same-base-model variants clustered together.')
 if r.get('conditional_bootstrap_stop_90pct'):kw.update(conditionals(r['conditional_bootstrap_stop_90pct'],scale=1))
 add('inference_cost',r['fit_id'],'raw_proxy_power',f['date_end'],'inference/inference_results.json',f'/projections/{j}',**kw)
for j,r in enumerate(inf['fits']):
 if r['status']!='fit':
  add('inference_cost',r['id'],'not_fitted',r['date_end'],'inference/inference_results.json',f'/fits/{j}',status='insufficient_data',notes=r['status']+f'; n={r["n"]}. No H/G projections fitted.')
sens=read('inference/data_quality_sensitivity.json')
for j,r in enumerate(sens['fits']):
 t=r['with_flagged_rows_projection'];positive=t['p']>0
 add('inference_source_date_sensitivity',r['fit_id']+'_retain_flagged_dates','raw_proxy_power',ifits[r['fit_id']]['date_end'],
  'inference/data_quality_sensitivity.json',f'/fits/{j}/with_flagged_rows_projection',
  status='finite_optimum' if positive else 'nonpositive_improvement_incompatible_k0',p=t['p'],b=1/t['p'] if positive else None,
  stop_flops=t.get('x_stop'),exact_threshold_flops=t.get('x_exact'),hardware_efficiency_growth=r['hardware_H'],research_compute_growth_proxy=r['research_G'],
  notes='Sensitivity deliberately retains independently verified date contradictions; not the corrected primary fit. Point estimates only; no uncertainty interval attached. '+sens['scope'])

# Record the attempted input proxy without inventing a fit or numerical answer.
CPU_READY=False
CPU_UNAVAILABLE=False
if (ROOT/'cpu_years/status.json').exists():
 cpu=read('cpu_years/status.json')
 assert cpu['observations']==0 and not cpu['fitted_methods'] and not cpu['predictions']
 CPU_UNAVAILABLE=True
 add('stockfish_cpu_years_unavailable','CPU_years_proxy_attempt','not_fitted',
  'unavailable: no observations received','cpu_years/status.json','/status',
  row_type='unavailable_data_attempt',status=cpu['status'],exact_threshold_status='not_fitted',
  notes=cpu['blocker']+' Source server unavailability was not established. No fit or FLOP prediction; no further download attempted.')

# Algebra validation for every ordinary constant-b point law.
checks=0
for r in ROWS:
 b=r['b']
 if b is None or r['row_type']!='point_fit':continue
 if b>0:
  expected=(N-1/K0)/(1+b)
  assert math.isclose(r['stop_flops'],expected,rel_tol=2e-12),(r['id'],'stop',r['stop_flops'],expected)
  expected=(N-1/K0)/b
  assert math.isclose(r['exact_threshold_flops'],expected,rel_tol=2e-12),(r['id'],'threshold')
 elif b==0:
  assert r['status']=='finite_optimum' and r['log10_remaining_flops'] is not None
  assert math.isclose(r['log10_remaining_flops'],27.5,abs_tol=1e-12)
 else:
  assert r['status']=='no_finite_maximizer'
  assert math.isclose(r['divergence_flops'],-1/(K0*b),rel_tol=2e-12),(r['id'],'divergence')
 checks+=1
assert len([r for r in ROWS if r['family']=='vision_floor_profile'])==33
assert len([r for r in ROWS if r['family']=='published_joint_posterior'])==14
assert len([r for r in ROWS if r['family']=='inference_cost'])==63
assert all(r['stop_flops'] is None for r in ROWS if r['row_type'].startswith('conditional_'))
assert all(not isinstance(v,float) or math.isfinite(v) for r in ROWS for v in r.values())
for r in ROWS:
 source=DOCS[r['source_file']]
 for part in r['source_pointer'].strip('/').split('/'):
  part=part.replace('~1','/').replace('~0','~')
  source=source[int(part)] if isinstance(source,list) else source[part]
meta=dict(created='2026-09-12',N=N,k0=K0,row_count=len(ROWS),family_counts=dict(Counter(r['family'] for r in ROWS)),
 status_counts=dict(Counter(r['status'] for r in ROWS)),ordinary_b_law_rows_validated=checks,cpu_years_included=CPU_READY,
 cpu_years_unavailable_attempt_included=CPU_UNAVAILABLE,
 source_sha256={f:hashlib.sha256((ROOT/f).read_bytes()).hexdigest() for f in DOCS},
 caveats=['Rows are correlated method/proxy/closure sensitivities, not independent evidence.',
 'Blank point stop for conditional distributions is deliberate: see conditional quantile columns and finite-stop probability.',
 'All absolute FLOPs use the user-supplied k0, not an empirically measured universal research efficiency.',
 'A stop rounded to N requires reading log10_remaining_flops; do not infer zero remaining budget.',
 'Complete source JSON documents retain bootstrap samples, fit metrics, source records, and diagnostics.'])
(ROOT/'all_methods.json').write_text(json.dumps(dict(metadata=meta,records=ROWS,source_documents=DOCS),indent=2,allow_nan=False)+'\n')
with (ROOT/'all_methods.csv').open('w',newline='') as out:
 writer=csv.DictWriter(out,fieldnames=list(ROWS[0]));writer.writeheader();writer.writerows(ROWS)
print(json.dumps(meta,indent=2))
