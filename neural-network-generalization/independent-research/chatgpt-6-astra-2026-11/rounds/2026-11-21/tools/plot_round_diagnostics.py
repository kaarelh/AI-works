"""Scientific figures for the completed numerical diagnostics.

All importance discrepancies are restricted-proposal diagnostics, not certified
full-posterior TV distances. Figures do not participate in the mathematical proofs.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
from pathlib import Path
import numpy as np
os.environ.setdefault('MPLCONFIGDIR',str(Path(__file__).resolve().parents[1]/'tmp/matplotlib'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'figures';OUT.mkdir(exist_ok=True)
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,
                     'savefig.bbox':'tight','pdf.fonttype':42,'ps.fonttype':42})
snapshot=ROOT/'report/live_validation.json'
uncertainty={r['file']:r for r in json.loads(snapshot.read_text())['running_results']} if snapshot.exists() else {}
def diagnostic_errorbar(ax,r,key,color,marker='o',size=6):
 point=uncertainty.get(key,{})
 interval=point.get('conditional_bootstrap_95_interval') if point.get('proposals')==r['proposals'] else None
 value=r['restricted_weight_discrepancy']
 low_ess=r.get('effective_importance_samples',0)<100
 kwargs=dict(marker=marker,ms=size,color=color,markerfacecolor='white' if low_ess else color,
             markeredgewidth=1.3,linestyle='none',capsize=2)
 if interval is not None and interval[0]<=value<=interval[1]:
  ax.errorbar(r['width'],value,yerr=[[value-interval[0]],[interval[1]-value]],**kwargs)
 else:ax.plot(r['width'],value,**kwargs)
colors={'square':'#156b9a','logistic':'#cf6433'}
fig,axes=plt.subplots(1,2,figsize=(10.5,4.1),layout='constrained')
for loss in ['square','logistic']:
 rows=[json.loads(p.read_text()) for p in (ROOT/'results/full_label_campaign').glob(loss+'_N*_rep*.json')]
 rows=[r for r in rows if r.get('accepted',0)>=20]
 for r in rows:axes[0].scatter(r['width'],r['restricted_weight_discrepancy'],color=colors[loss],s=23,alpha=.65)
 long=ROOT/f'results/long_{loss}_N16777216.json'
 if long.exists():
  r=json.loads(long.read_text());diagnostic_errorbar(axes[0],r,str(long.relative_to(ROOT)),colors[loss],marker='D')
 limit=json.loads((ROOT/f'results/gaussian_weight_{loss}.json').read_text())
 C=limit.get('C0',limit.get('C0_estimate'))
 if C is None:
  candidates=[(k,v) for k,v in limit.items() if k.startswith('C0')]
  C=candidates[0][1]
 n=np.geomspace(2**15,2**24,150);axes[0].plot(n,C/np.sqrt(n),color=colors[loss],label=loss+' limit')
axes[0].set(xscale='log',yscale='log',xlabel='Width N',ylabel='Restricted importance discrepancy',title='ReLU: half-power scaling')
axes[0].legend(frameon=False)
rows=[json.loads(p.read_text()) for p in (ROOT/'results/softplus_campaign').glob('square_N*.json')]
rows=[r for r in rows if r.get('accepted',0)>=20]
for r in rows:
 diagnostic_errorbar(axes[1],r,f"results/softplus_campaign/square_N{r['width']}.json",'#597e39',marker='D' if r['status']!='complete' else 'o')
lim=json.loads((ROOT/'results/softplus_gaussian_weight_square.json').read_text())
C=lim['C0_conditional_limit'];n=np.geomspace(2**16,2**24,150)
axes[1].plot(n,C/n**.25,color='#597e39',label='quarter-power limit')
axes[1].set(xscale='log',yscale='log',xlabel='Width N',ylabel='Restricted importance discrepancy',title='Softplus: quarter-power scaling')
axes[1].plot([],[],marker='o',markerfacecolor='white',markeredgecolor='#597e39',linestyle='none',label='open: importance ESS < 100')
axes[1].plot([],[],marker='D',color='#777777',linestyle='none',label='diamond: time-capped run')
axes[1].legend(frameon=False,fontsize=8)
fig.suptitle('Restricted-proposal diagnostics; empirical bootstrap bars, no full-posterior TV certificate',fontsize=11)
fig.savefig(OUT/'proposal_scaling.png',dpi=180);fig.savefig(OUT/'proposal_scaling.pdf');plt.close(fig)

fig,axes=plt.subplots(1,2,figsize=(10.5,4.1),layout='constrained')
const=json.loads((ROOT/'results/smoothing_covariance_constant.json').read_text())['correction_constant']
ray=np.array([600,512/3,24,0,8/3,0,24])
analysis=json.loads((ROOT/'results/smoothing_covariance_analysis.json').read_text())['rows']
betas=np.array([r['beta'] for r in analysis]);eigs=np.array([r['scaled_covariance_difference'] for r in analysis])
ses=np.array([r['conditional_jackknife_se'] for r in analysis])
for j,color in zip([0,1,2,4,6],['#156b9a','#cf6433','#597e39','#8e62aa','#bc9a2f']):
 axes[0].errorbar(betas,eigs[:,j]/ray[j],yerr=1.96*ses[:,j]/ray[j],marker='o',ms=4,lw=1,color=color,label=f'degree {j}')
axes[0].axhline(const,color='black',ls='--',lw=1,label='positive-integral limit')
axes[0].set(xscale='log',xlabel='Softplus sharpness beta',ylabel='beta × covariance difference / ray eigenvalue',title='Six-bit critical covariance correction')
axes[0].legend(frameon=False,ncol=2,fontsize=8)
mark=json.loads((ROOT/'results/logarithmic_mark_correction.json').read_text())
rows=mark['comparisons']
for eta,color in zip([.2,.5,1.],['#156b9a','#cf6433','#597e39']):
 group=[r for r in rows if r['a']==1 and r['eta']==eta]
 axes[1].plot([r['logN'] for r in group],[r['scaled_mark_discrepancy'] for r in group],marker='o',ms=4,color=color,label=f'amplitude / N = {eta}')
axes[1].axhline(mark['estimated_mark_tv_coefficient'],color='black',ls='--',lw=1,label='Gaussian quartic limit')
axes[1].set(xscale='log',xlabel='log N (one-neuron integration only)',ylabel='(log N) sqrt(amplitude / N) discrepancy',title='Logarithmic local-mark correction')
axes[1].legend(frameon=False,fontsize=8)
axes[1].set_xticks([32,64,128,256,512],labels=['32','64','128','256','512'])
axes[1].xaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())
fig.suptitle('Critical-neuron integrations (Monte Carlo diagnostics)',fontsize=12)
fig.savefig(OUT/'smoothing_corrections.png',dpi=180);fig.savefig(OUT/'smoothing_corrections.pdf');plt.close(fig)
print('Wrote diagnostic figures to',OUT)

fig,axes=plt.subplots(1,2,figsize=(10.5,4.1),layout='constrained')
for ax,filename,title in zip(axes,['smoothing_degree_order_checks.json','tangent_degree_order_checks.json'],['Random-feature kernel','Both-layer initialization tangent kernel']):
 record=json.loads((ROOT/'results'/filename).read_text())
 row=next(r for r in record['dimensions'] if r['dimension']==12)
 for scale,color in zip(row['scales'],['#b33d48','#ce7935','#b2a02d','#568849','#327b9c','#634b92']):
  label='ReLU' if scale['beta'] is None else f"beta = {scale['beta']:g}"
  ax.plot(range(2,13),scale['upper_degree_tails'][1:],marker='o',ms=3,lw=1.3,color=color,label=label)
 ax.set(yscale='log',xlabel='Minimum Fourier degree k',ylabel='Fraction of variance in degrees ≥ k',title=title)
 ax.set_xticks([2,4,6,8,10,12]);ax.legend(frameon=False,fontsize=8,ncol=2)
fig.suptitle('Sharpening shifts normalized variance toward higher degrees (d = 12)',fontsize=12)
fig.savefig(OUT/'normalized_spectral_order.png',dpi=180);fig.savefig(OUT/'normalized_spectral_order.pdf');plt.close(fig)

narrow_path=ROOT/'results/cosine_width_one_posterior.json'
wide_path=ROOT/'results/cosine_gaussian_sequential.json'
if narrow_path.exists() and wide_path.exists():
 narrow=next((j for j in json.loads(narrow_path.read_text())['jobs'] if j['dimension']==5 and j['sigma']==1 and j['status']=='complete'),None)
 wide=next((j for j in json.loads(wide_path.read_text())['jobs'] if j['dimension']==5 and j['sigma']==1),None)
 if narrow and wide:
  fig,ax=plt.subplots(figsize=(9.2,4.4),layout='constrained')
  for job,label,color in [(narrow,'Width one: exact readout integration','#156b9a'),(wide,'Infinite-width Gaussian limit','#8e62aa')]:
   rows=[r for r in job['rows'] if 'correct_probability' in r and not r.get('inconclusive_low_ess',True)]
   ax.errorbar([r['observed'] for r in rows],[r['correct_probability'] for r in rows],
      yerr=[1.96*(r['correct_probability_empirical_se'] or 0) for r in rows],marker='o',ms=3.5,lw=1.2,color=color,label=label)
  ax.axhline(.5,color='#555555',ls='--',lw=1,label='Majority threshold')
  ax.set(xlabel='Number of preceding lexicographic labels',ylabel='Next-label correct probability',ylim=(0,1.025),xlim=(.5,31.5),
         title='Five-bit parity, common Gaussian scale 1, observed margin 1/2')
  ax.legend(frameon=False,fontsize=9,loc='lower left')
  fig.suptitle('Narrow network and Gaussian limit: independent posterior integrations',fontsize=12)
  fig.savefig(OUT/'cosine_width_comparison.png',dpi=180);fig.savefig(OUT/'cosine_width_comparison.pdf');plt.close(fig)

# Deterministic kernel interpolation is a separate experiment from the Bayesian
# positive-margin numerical integrations above.
record=ROOT/'results/degree_kernel_recursion_checks.json'
if record.exists():
 data=json.loads(record.read_text());fig,ax=plt.subplots(figsize=(10.5,4.2),layout='constrained')
 for d,color in [(3,'#597e39'),(5,'#156b9a'),(7,'#8e62aa')]:
  row=next(r for r in data['relu_cases'] if r['dimension']==d);values=row.get('signed_predictions')
  if values is not None:ax.plot(np.arange(1,len(values)+1)/2**d,values,color=color,lw=1,marker='o',ms=2,label=f'd = {d}: {len(values)} wrong signs')
 ax.axhline(0,color='#555555',ls='--',lw=1)
 ax.set(xlabel='Fraction of cube already observed',ylabel='Next prediction multiplied by true parity',title='Gaussian ReLU kernel: lexicographic minimum-norm interpolation')
 ax.legend(frameon=False);fig.suptitle('Exact output observations; fixed hidden features (not margin conditioning)',fontsize=11)
 fig.savefig(OUT/'kernel_lexicographic_margins.png',dpi=180);fig.savefig(OUT/'kernel_lexicographic_margins.pdf');plt.close(fig)
