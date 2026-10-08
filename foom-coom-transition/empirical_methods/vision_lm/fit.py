"""Independent empirical fits. Run with python fit.py.

Inputs downloaded 2026-09-11; see README.md for source URLs and definitions.
This does not estimate research FLOPs. The time-to-input conversion is explicit.
"""
from pathlib import Path
import json, math
import numpy as np
import pandas as pd
from scipy.optimize import least_squares, minimize_scalar, brentq
from scipy.stats import linregress, theilslopes

HERE=Path(__file__).resolve().parent
N=1e120
K0=10**-27.5
PROXIES={'aggregate_AI_compute_3.4x':3.4, 'frontier_training_compute_5x':5.0,
         'historically_overlapping_notable_training_compute_4.1x':4.1}

def projections(s):
    out={}
    for name,g in PROXIES.items():
        p=s/math.log(g)
        if p<=0:
            out[name]={'p':p,'status':'no positive improvement inferred'}
            continue
        out[name]={'p':p,'stop_flops':p/(1+p)*(N-1/K0),
                   'stop_fraction':p/(1+p), 'exact_1e120_threshold_flops':p*(N-1/K0),
                   'marginal_at_stop_over_1e_minus_120':1+p}
    return out

vision=pd.read_csv(HERE/'efficiency_sota.csv')
vision=vision[vision.Metric=='AlexNet'].copy()
vision['date']=pd.to_datetime(vision['Publication Date'])
t=(vision.date-vision.date.min()).dt.total_seconds().to_numpy()/(365.25*86400)
c=vision['Compute (teraflops-s/days)'].to_numpy()
y=np.log(c[0]/c)
vision['t_years']=t;vision['log_efficiency']=y
vision.to_csv(HERE/'vision_processed.csv',index=False)
fits=[]
for label,ix in [('vision_OLS_all',np.arange(len(t))),('vision_OLS_first3',np.arange(3)),
                 ('vision_OLS_last3',np.arange(3,6))]:
    f=linregress(t[ix],y[ix]); err=y[ix]-f.intercept-f.slope*t[ix]
    fits.append({'method':label,'n':len(ix),'s_ln_efficiency_per_year':f.slope,
                 'efficiency_multiplier_per_year':math.exp(f.slope), 'R_squared':f.rvalue**2,
                 'rmse_log_efficiency':float(np.sqrt(np.mean(err**2))),
                 'projections':projections(f.slope)})
rob=theilslopes(y,t)
fits.append({'method':'vision_Theil_Sen_all','n':len(t),
             's_ln_efficiency_per_year':rob.slope,'slope_interval_95':[rob.low_slope,rob.high_slope],
             'efficiency_multiplier_per_year':math.exp(rob.slope),'projections':projections(rob.slope)})
first=linregress(t[:3],y[:3])
vision_holdout={'train_first3_test_last3_log_rmse':float(np.sqrt(np.mean((y[3:]-first.intercept-first.slope*t[3:])**2))),
                'predicted_last_efficiency':float(np.exp(first.intercept+first.slope*t[-1])),
                'actual_last_efficiency':float(np.exp(y[-1]))}

# Profile physically nonnegative compute floors. Free A and s at every floor.
# Floor=0 is nested exponential. Relative floor is C_floor/current observed C.
def fit_floor(floor):
    def resid(q):return np.log(floor+np.exp(q[0]-q[1]*t))-np.log(c)
    f=least_squares(resid,[math.log(c[0]),.5],bounds=([-20,0],[20,20]))
    return f,float(np.sum(f.fun**2))
f0,sse0=fit_floor(0)
best_floor_opt=minimize_scalar(lambda frac:fit_floor(frac*c[-1])[1],bounds=(0,1),method='bounded')
best_floor_frac=float(best_floor_opt.x)
profile=[]
for frac in [0, .001, .01, .03, .1, best_floor_frac, .2, .3, .5, .7,.9]:
    f,sse=fit_floor(frac*c[-1]);s=float(f.x[1]);row={'floor_fraction_of_last_observed_compute':frac,
        'calendar_exponent_s':s, 'sse_log_compute':sse,'delta_profile_deviance':len(t)*math.log(sse/sse0)}
    if frac==0:row['projections']=projections(s)
    else:
        # At forecast start, fit C(t_last), not last noisy observation.
        Cnow=frac*c[-1]+math.exp(f.x[0]-s*t[-1]);floor_rel=frac*c[-1]/Cnow
        row['fitted_floor_fraction_of_current_compute']=floor_rel
        results={}
        for name,g in PROXIES.items():
            p=s/math.log(g); x0=p*(1-floor_rel)/K0
            logx0=math.log(x0)
            def log_k(logx):
                logz=np.logaddexp(0,logx-logx0)
                return math.log(K0)-(p+1)*logz-np.logaddexp(math.log(floor_rel),math.log(1-floor_rel)-p*logz)
            logth=brentq(lambda lx:log_k(lx)+math.log(N),math.log(1/K0),math.log(N)*2)
            # threshold is far below N; optimize condition differs negligibly there.
            logstop=brentq(lambda lx:log_k(lx)+math.log(N)+math.log1p(-math.exp(lx)/N),math.log(1/K0),math.log(N)-1e-8)
            results[name]={'p':p,'log10_stop_flops':logstop/math.log(10),
                'log10_exact_threshold_flops':logth/math.log(10)}
        row['projections']=results
    profile.append(row)

# Out-of-sample comparison of the nested exponential and floor model.
floor_loo=[]
for omit in range(len(t)):
    keep=np.arange(len(t))!=omit
    def fit_subset(frac):
        floor=frac*min(c[keep])
        f=least_squares(lambda q:np.log(floor+np.exp(q[0]-q[1]*t[keep]))-np.log(c[keep]),
            [math.log(c[0]),.5],bounds=([-20,0],[20,20]))
        return f,float(np.sum(f.fun**2))
    floorfrac=minimize_scalar(lambda frac:fit_subset(frac)[1],bounds=(0,1),method='bounded').x
    ef,_=fit_subset(0);ff,_=fit_subset(floorfrac)
    floor_loo.append({'omitted':omit,
        'exponential_log_error':float(ef.x[0]-ef.x[1]*t[omit]-math.log(c[omit])),
        'floor_log_error':float(math.log(floorfrac*min(c[keep])+math.exp(ff.x[0]-ff.x[1]*t[omit]))-math.log(c[omit]))})
floor_diagnostics={'best_floor_fraction_of_last_observation':best_floor_frac,
    'delta_AIC_vs_no_floor':float(len(t)*math.log(best_floor_opt.fun/sse0)+2),
    'LOO_exponential_log_rmse':float(np.sqrt(np.mean([r['exponential_log_error']**2 for r in floor_loo]))),
    'LOO_floor_log_rmse':float(np.sqrt(np.mean([r['floor_log_error']**2 for r in floor_loo])))}

# Language models: independent cleaning, using each benchmark's own perplexity.
# This differs from a verbatim rerun of the published notebook.
raw=pd.read_csv(HERE/'lm_data_analysis.csv')
cols={'Parameters':'param','Dataset Size':'data','Publication date':'date','System':'system'}
d=raw.rename(columns=cols)
for col in ['param','data','Include?','Outlier?','uncertain']:
    d[col]=pd.to_numeric(d[col],errors='coerce')
d['date']=pd.to_datetime(d.date,format='%Y/%m/%d',errors='coerce')
d=d[(d.param>0)&(d.data>0)&(d['Include?']==1)&(d['Outlier?']!=1)&(d.uncertain==0)&d.date.notna()].copy()
d=d[~d.system.isin(['GPT3-6.7B + muP','LLaMA-65B (LoRA finetuned)','LLaMA-13B (LoRA finetuned)','LLaMA-7B (LoRA finetuned)'])]
d.loc[d.system=='Gopher (280B)','param']=280e9
d.loc[d.system=='Gopher (7.1B)','param']=7.1e9
long=[]
for b,col in enumerate(['Perplexity (WT103)','Perplexity (WT2)','Perplexity (PTB)']):
    e=d.copy();e['ppl']=pd.to_numeric(e[col],errors='coerce');e['benchmark']=b
    e=e[e.ppl>1];long.append(e)
d=pd.concat(long,ignore_index=True)
d=d.sort_values(['Reference','benchmark','ppl']).groupby(['Reference','benchmark']).head(3).copy()
d['time']=(d.date-pd.Timestamp('2012-01-01')).dt.total_seconds()/(365.25*86400)
d['logN']=np.log(d.param/1e7);d['logD']=np.log(d.data/1e6);d['loss']=np.log(d.ppl)
d=d.reset_index(drop=True)
d[['system','Reference','date','param','data','ppl','benchmark','time','logN','logD','loss']].to_csv(HERE/'lm_processed.csv',index=False)

# L = A_b exp(-u*t) N^-a + B_b exp(-v*t) D^-b .
# At optimum N,D with C proportional to ND, ln compute efficiency/year = u/a+v/b.
# Inputs here are dataset size, not a reliable observed total research FLOP stock.
def lm_fit(df,loss='linear',seed=313):
    b=df.benchmark.to_numpy(int); tt=df.time.to_numpy(); nn=df.logN.to_numpy();dd=df.logD.to_numpy()
    def pred(q):return np.exp(q[b]-q[6]*tt-q[7]*nn)+np.exp(q[3+b]-q[8]*tt-q[9]*dd)
    yy=df.loss.to_numpy()
    starts=[np.r_[np.full(6,math.log(2.5)),.04,.1,.04,.1]]
    rng=np.random.default_rng(seed)
    starts.extend([starts[0]+rng.normal(0,.1,10) for _ in range(5)])
    lo=np.r_[np.full(6,-8),-1,.002,-1,.002];hi=np.r_[np.full(6,8),1,2,1,2]
    best=None
    for start in starts:
        f=least_squares(lambda q:pred(q)-yy,np.clip(start,lo+1e-5,hi-1e-5),bounds=(lo,hi),loss=loss,f_scale=.15,max_nfev=2000)
        if best is None or f.cost<best.cost:best=f
    q=best.x;predicted=pred(q);s=q[6]/q[7]+q[8]/q[9]
    return q,{'s_ln_efficiency_per_year':s,'efficiency_multiplier_per_year':math.exp(s),
        'parameters':q.tolist(),'R_squared':float(1-np.sum((predicted-yy)**2)/np.sum((yy-np.mean(yy))**2)),
        'rmse_cross_entropy':float(np.sqrt(np.mean((predicted-yy)**2))),'n':len(df),
        'distinct_papers':int(df.Reference.nunique()),'parameter_bound_hit':bool(np.any(q-lo<1e-4)|np.any(hi-q<1e-4)),
        'projections':projections(s)}

lm=[]
for label,df,loss in [('LM_nonlinear_OLS',d,'linear'),('LM_nonlinear_soft_L1',d,'soft_l1'),
                     ('LM_nonlinear_post2017',d[d.date>=pd.Timestamp('2017-06-01')],'linear')]:
    q,summary=lm_fit(df,loss);summary['method']=label;lm.append(summary)

# Chronological validation by publication date, no shuffled leakage.
train=d[d.date<pd.Timestamp('2020-01-01')];test=d[d.date>=pd.Timestamp('2020-01-01')]
q,summary=lm_fit(train)
b=test.benchmark.to_numpy(int)
pred=np.exp(q[b]-q[6]*test.time-q[7]*test.logN)+np.exp(q[3+b]-q[8]*test.time-q[9]*test.logD)
summary.update(method='LM_nonlinear_pre2020_training_only',
               test_n=len(test),holdout_rmse_cross_entropy=float(np.sqrt(np.mean((pred-test.loss)**2))))
lm.append(summary)

result={'normalization':{'N':N,'k0':K0},'proxy_growth_per_year':PROXIES,
    'vision':fits,'vision_chronological_holdout':vision_holdout,'vision_floor_profile':profile,
    'vision_floor_diagnostics':floor_diagnostics,
    'language_models':lm, 'lm_dataset_size':len(d),
    'dates':{'vision':['2012-06-01','2019-05-28'], 'LM':[str(d.date.min().date()),str(d.date.max().date())]}}
(HERE/'results.json').write_text(json.dumps(result,indent=2))
print(json.dumps({'vision':fits,'holdout':vision_holdout,'LM':lm,'floor_profile':profile},indent=2))
