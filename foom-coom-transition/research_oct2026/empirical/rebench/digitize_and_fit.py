#!/usr/bin/env python3
"""Reproduce a curve-digitization validation from frozen, CC-BY METR PNG.
Requires numpy, scipy, Pillow, matplotlib. No network needed.
"""
from pathlib import Path
import csv, json, hashlib, math, os, sys

ROOT=Path(__file__).resolve().parent
# Keep dependency caches within this assigned output folder, even if imported.
sys.dont_write_bytecode=True
for env_name,subdir in [('MPLCONFIGDIR','matplotlib'),('XDG_CACHE_HOME','xdg')]:
 cache_dir=ROOT/'.cache'/subdir
 cache_dir.mkdir(parents=True,exist_ok=True)
 os.environ[env_name]=str(cache_dir)

import numpy as np
from PIL import Image
from scipy.optimize import minimize_scalar
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

SRC=ROOT/'source/returns-to-expenditure_mobile_1.png'
# Pixel anchors read from grid centers in original 1880 x 1735 PNG.
X_TICKS=np.array([307.5,803.5,1298.0,1792.5])
Y_TICKS=np.array([1494.0,1349.0,1203.0,1057.5,912.5,766.5,620.5,474.5,329.5])
X_SLOPE,X_INTERCEPT=np.polyfit([1,2,3,4],X_TICKS,1)
Y_SLOPE,Y_INTERCEPT=np.polyfit(np.arange(9)*.2,Y_TICKS,1)
# Legend RGB values and circle centers are manually audited against the source.
SERIES={
 'Opus 4.8':{'rgb':[167,65,29], 'end':[1793,401.5], 'upper':1.6},
 'GPT 5.5':{'rgb':[10,59,144], 'end':[1671,801.5], 'upper':1.05},
 'Opus 4.5':{'rgb':[213,117,85], 'end':[1454,1239.5], 'upper':.4},
 'GPT 5.2':{'rgb':[57,128,195], 'end':[1575,1125.5], 'upper':.55},
 'Opus 4.1':{'rgb':[227,154,113], 'end':[1485,1333], 'upper':.26},
 'GPT 5':{'rgb':[120,168,216], 'end':[1641,1494], 'upper':.01},
}
MODELS=['no_more_progress','last_observation','constant_marginal','logarithmic','power_gain','exponential_ceiling','hyperbolic_ceiling']

def dollar_to_x(d): return X_INTERCEPT+X_SLOPE*np.log10(d)
def x_to_dollar(x): return 10**((x-X_INTERCEPT)/X_SLOPE)
def pixel_to_pct(y): return np.maximum(0,(np.asarray(y)-Y_INTERCEPT)/Y_SLOPE)

def digitize():
 im=np.asarray(Image.open(SRC).convert('RGB')).astype(int)
 curves={}
 for name,meta in SERIES.items():
  mask=np.all(im==meta['rgb'],axis=2)
  ymin=max(280, int(Y_INTERCEPT+Y_SLOPE*meta['upper']))
  mask[:ymin]=False;mask[1500:]=False;mask[:550,:400]=False
  pairs=[]
  for x in range(800,meta['end'][0]+1):
   ys=np.flatnonzero(mask[:,x])
   groups=[s for s in np.split(ys,np.flatnonzero(np.diff(ys)>1)+1) if len(s)>=3]
   if not groups: continue
   s=groups[0] # topmost; false antialias matches are mostly singleton pixels
   y=float(np.median(s)) if len(s)<=12 else float(s[0]+2)
   pairs.append((x,y))
  if name=='GPT 5': # explicitly null; its early zero line is occluded by Opus 4.1
   pairs=[(x,1494.) for x in range(800,meta['end'][0]+1)]
  pairs=np.array(pairs,float)
  # Endpoint circle-center measurement avoids treating marker radius as gain.
  pairs[-1]=meta['end']
  curves[name]=pairs
 return curves

def sample(curves,density=16,xshift=0):
 rows=[]
 for name,pairs in curves.items():
  end=float(x_to_dollar(SERIES[name]['end'][0]))
  budgets=100*10**(np.arange(0,int(np.floor(np.log10(end/100)*density))+1)/density)
  budgets=np.r_[budgets,end] if abs(budgets[-1]-end)>1 else budgets
  for d in budgets:
   xp=float(dollar_to_x(d))
   i=np.argmin(abs(pairs[:,0]-(xp+xshift)))
   y=pairs[i,1]
   if d==end: y=SERIES[name]['end'][1]
   pct=float(pixel_to_pct(y))
   if pct<.002: pct=0. # less than ~1.5 vertical pixels: displayed zero
   rows.append(dict(model=name,expenditure_usd=float(d),speedup_pct=pct,
                    x_pixel=float(pairs[i,0]),y_pixel=float(y),
                    split='train' if d<=1000.0001 else 'holdout'))
 return rows

def basis(model,x,param=None):
 t=np.maximum(x-100,0)
 if model=='constant_marginal': return t/1000
 if model=='logarithmic': return np.log(x/100)
 if model=='power_gain': return np.expm1(param*np.log(x/100))
 if model=='exponential_ceiling': return -np.expm1(-t/param)
 if model=='hyperbolic_ceiling': return t/(param+t)
 return np.zeros_like(x)

def fit(model,x,y):
 if model=='no_more_progress': return {'amplitude':0.,'parameter':None,'train_sse':float(y@y),'boundary':False}
 def fit_at(p):
  b=basis(model,x,p); amp=max(0,float(b@y/max(b@b,1e-100)))
  return float(np.sum((y-amp*b)**2)),amp
 if model in ['constant_marginal','logarithmic']:
  loss,amp=fit_at(None);return {'amplitude':amp,'parameter':None,'train_sse':loss,'boundary':False}
 lo,hi=(.02,3.) if model=='power_gain' else (-2.,20.)
 def objective(z): return fit_at(z if model=='power_gain' else np.exp(z))[0]
 grid=np.linspace(lo,hi,300); vals=np.array([objective(z) for z in grid]);i=int(vals.argmin())
 opt=minimize_scalar(objective,bounds=(grid[max(0,i-1)],grid[min(len(grid)-1,i+1)]),method='bounded')
 z=min([(opt.x,objective(opt.x)),(lo,objective(lo)),(hi,objective(hi))],key=lambda a:a[1])[0]
 param=z if model=='power_gain' else float(np.exp(z))
 loss,amp=fit_at(param)
 return {'amplitude':amp,'parameter':float(param),'train_sse':loss,'boundary':bool(abs(z-lo)<.001 or abs(z-hi)<.001)}

def analyze(rows):
 results=[]
 for name in SERIES:
  subset=[r for r in rows if r['model']==name]
  x=np.array([r['expenditure_usd'] for r in subset]); yy=np.array([r['speedup_pct'] for r in subset]);base=float(yy[0]); y=yy-base;tr=x<=1000.0001
  for model in MODELS:
   if model=='last_observation':
    short={'amplitude':float(y[tr][-1]),'parameter':None,'train_sse':None,'boundary':False};full={'amplitude':float(y[-1]),'parameter':None,'train_sse':None,'boundary':False};pred=np.full_like(y,base+short['amplitude'])
   else:
    short=fit(model,x[tr],y[tr]); full=fit(model,x,y)
    pred=base+short['amplitude']*basis(model,x,short['parameter'])
   record={'agent':name,'curve':model,'n_grid_train':int(tr.sum()),'n_grid_holdout':int((~tr).sum()),
     'baseline_speedup_pct':base,'train':short,'all_budget_fit':full,
     'train_rmse_pp':float(np.sqrt(np.mean((pred[tr]-yy[tr])**2))),
     'holdout_rmse_pp':float(np.sqrt(np.mean((pred[~tr]-yy[~tr])**2))),
     'observed_endpoint_pct':subset[-1]['speedup_pct'],'endpoint_usd':float(x[-1]),
     'predicted_endpoint_pct':float(pred[-1])}
   results.append(record)
 return results

def write_csv(path,rows):
 with path.open('w') as f:
  w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)

def main():
 curves=digitize();rows=sample(curves);res=analyze(rows)
 write_csv(ROOT/'digitized_points.csv',rows)
 write_csv(ROOT/'digitized_pixel_trace.csv',[{'model':n,'x_pixel':float(p[0]),'y_pixel':float(p[1]),'expenditure_usd':float(x_to_dollar(p[0])),'speedup_pct':float(pixel_to_pct(p[1]))} for n,v in curves.items() for p in v])
 sensitivity={}
 for label,density,shift in [('x_minus2',16,-2),('x_plus2',16,2),('grid8_per_decade',8,0),('grid32_per_decade',32,0)]:
  sensitivity[label]=analyze(sample(curves,density,shift))
 summary=[]
 for m in MODELS:
  rr=[r for r in res if r['curve']==m]
  summary.append({'curve':m,'mean_agent_holdout_rmse':float(np.mean([r['holdout_rmse_pp'] for r in rr])),
   'four_positive_models_mean_holdout_rmse':float(np.mean([r['holdout_rmse_pp'] for r in rr if r['agent'] not in ['Opus 4.1','GPT 5']]))})
 out={'source_sha256':hashlib.sha256(SRC.read_bytes()).hexdigest(),'date':'2026-10-02',
  'units':'USD; published speedup percentage points; fitted response is published speedup percentage points',
  'axis_calibration':{'x_slope':X_SLOPE,'x_intercept':X_INTERCEPT,'y_slope':Y_SLOPE,'y_intercept':Y_INTERCEPT,'x_tick_pixels':X_TICKS.tolist(),'y_tick_pixels':Y_TICKS.tolist()},
  'series':SERIES,'fits':res,'summary':summary,'sensitivity':sensitivity,
  'uncertainty':'No replicate or statistical sampling confidence interval is estimated. Grid points reuse six dependent trajectories; pixel shifts/grid changes are deterministic robustness checks.',
  'forecast':'No estimate of cosmic tail or raw FLOP stopping point is justified.'}
 (ROOT/'results.json').write_text(json.dumps(out,indent=2))
 write_csv(ROOT/'fit_comparison.csv',[{'agent':r['agent'],'curve':r['curve'],'train_rmse_pp':r['train_rmse_pp'],'holdout_rmse_pp':r['holdout_rmse_pp'],'full_amplitude':r['all_budget_fit']['amplitude'],'full_parameter':r['all_budget_fit']['parameter'],'boundary':r['all_budget_fit']['boundary'],'endpoint_usd':r['endpoint_usd'],'observed_endpoint_pct':r['observed_endpoint_pct']} for r in res])
 fig,axs=plt.subplots(2,3,figsize=(13,7.3),sharex=True)
 styles={'constant_marginal':'--','logarithmic':'-','power_gain':'-.','exponential_ceiling':':','hyperbolic_ceiling':'--','no_more_progress':':','last_observation':'-.'}
 for ax,name in zip(axs.ravel(),SERIES):
  rr=[r for r in rows if r['model']==name];x=np.array([r['expenditure_usd'] for r in rr]);y=np.array([r['speedup_pct'] for r in rr]);
  ax.plot(x,y,'k.-',label='Digitized revalidated curve',zorder=5)
  xx=np.geomspace(100,max(x),200)
  for r in [r for r in res if r['agent']==name]:
   f=r['train'];bb=np.ones_like(xx) if r['curve']=='last_observation' else basis(r['curve'],xx,f['parameter']);ax.plot(xx,y[0]+f['amplitude']*bb,styles[r['curve']],label=r['curve'].replace('_',' '),alpha=.8)
  ax.axvline(1000,color='grey',lw=1);ax.set_xscale('log');ax.set_title(name);ax.set_ylim(-.025,max(y)*1.5+.06);ax.grid(alpha=.16)
 for ax in axs[1]:ax.set_xlabel('Cumulative run expenditure (USD, log scale)')
 for ax in axs[:,0]:ax.set_ylabel('Published cumulative speedup (%)')
 handles,labels=axs[0,0].get_legend_handles_labels();fig.legend(handles,labels,loc='lower center',ncol=4,fontsize=8)
 fig.suptitle('NanoGPT: fit through $1,000; later expenditure held out\nSix published agent runs, July 2026. Digitized source curves; no independent-point uncertainty.',fontsize=12)
 fig.tight_layout(rect=(0,.1,1,.93));fig.savefig(ROOT/'holdout_comparison.png',dpi=180);plt.close(fig)
 print(json.dumps(summary,indent=2))
 print('endpoints',[(n,[r for r in rows if r['model']==n][-1]['expenditure_usd'],[r for r in rows if r['model']==n][-1]['speedup_pct']) for n in SERIES])
 print('best holdout',[(n,min([r for r in res if r['agent']==n],key=lambda r:r['holdout_rmse_pp'])['curve']) for n in SERIES])

if __name__=='__main__':main()
