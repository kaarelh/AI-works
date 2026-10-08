"""Reproducible propagation of an explicitly subjective, pre-specified prior."""
from pathlib import Path
import sys, json, math, csv, hashlib
import numpy as np
from scipy.special import ndtri
from scipy.stats import qmc
from scipy.optimize import brentq
sys.dont_write_bytecode = True
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[1]
sys.path.insert(0,str(ROOT/'forecast_revision'))
from math_model import CeilingModel, ExponentialCeilingModel, ContinuumCeilingModel, log_expm1
from taper_model import LogHeadroomTaper
S=json.loads((BASE/'prior.json').read_text())
LN10=math.log(10)

def weighted_quantile(x,w,q):
    ii=np.argsort(x); xx=np.asarray(x)[ii]; ww=np.asarray(w)[ii]
    return np.interp(q,np.cumsum(ww)/sum(ww),xx).tolist()

def summarize(rows,weights):
    # Three completion subfamilies are represented explicitly, at equal weights.
    x=np.array([r['log10_x'] for r in rows]); fam=np.array([r['family'] for r in rows])
    w=np.zeros(len(rows))
    for f,v in weights.items():
        mask=fam==f; w[mask]=v/sum(mask)
    assert abs(sum(w)-1)<1e-10
    return {'quantile_probabilities':[.05,.1,.25,.5,.75,.9,.95],
            'log10_quantiles':weighted_quantile(x,w,[.05,.1,.25,.5,.75,.9,.95]),
            'probability_at_least_1pct_N':float(sum(w[x>=118])),
            'probability_at_least_10pct_N':float(sum(w[x>=119])),
            'cdf_log10':{str(t):float(sum(w[x<=t])) for t in [30,40,60,80,90,100,110,115,118,119]},
            'mean_log10_x':float(x@w)}

def logistic_stop(h,k):
    # a=H/[1+(H-1)exp(-r*x)], r=k0*H/(H-1).
    # Solve in v=r*x with logs, so neither H nor exp(v) overflows.
    lhm1=log_expm1(h*LN10); lr=k*LN10+h*LN10-lhm1
    def fn(v):
        lx=math.log(v)-lr if v else -math.inf
        lk=lr+lhm1-v-float(np.logaddexp(0,lhm1-v))
        return float(np.logaddexp(lx,-lk))-120*LN10
    hi=1.
    while fn(hi)<0:hi*=2
    v=brentq(fn,0,hi,xtol=1e-11)
    return (math.log(v)-lr)/LN10,(h*LN10-float(np.logaddexp(0,lhm1-v)))/LN10

def draw_rows(maxh,n_power=10,ablate_slow=False,minh=6):
    u=qmc.Sobol(d=7,scramble=True,seed=20261002).random_base2(n_power)
    u=np.clip(u,1e-12,1-1e-12); rows=[]
    families=['single','heterogeneous','exponential_cost','exponential_efficiency','capped_raw_power','taper','continuum','open_ended']
    for f in families:
        for i,uu in enumerate(u):
            h=minh+(maxh-minh)*uu[0]; k=-29+1.25*ndtri(uu[1]); q=.7*math.exp(.6*ndtri(uu[2]))
            pars={}; a=None
            if f=='single':
                p=.5*math.exp(math.log(3)*ndtri(uu[2])); m=CeilingModel(p,h,log10_k0=k); pars={'p':p}
            elif f=='heterogeneous':
                pf=.5*4**uu[2]; ps=.03*10**uu[3]; amp=10**(-12+10*uu[4])
                m=CeilingModel(pf if ablate_slow else [pf,ps],h,None if ablate_slow else [1-amp,amp],log10_k0=k)
                pars={'p_fast':pf,'p_slow':ps,'amplitude':amp}
            elif f=='exponential_cost':m=ExponentialCeilingModel(h,log10_k0=k)
            elif f=='continuum':m=ContinuumCeilingModel(h,log10_k0=k)
            elif f=='exponential_efficiency':x,a=logistic_stop(h,k)
            elif f in ['capped_raw_power','open_ended']:
                x_free=120+math.log10(q/(1+q))+math.log10(1-10**(-k-120))
                x_cap=math.log10(q)-k+log_expm1(h*LN10/q)/LN10
                x=min(x_free,x_cap) if f=='capped_raw_power' else x_free
                a=q*float(np.logaddexp(0,(k+x)*LN10-math.log(q)))/LN10
                pars={'q':q}
            elif f=='taper':
                r0=.4*9**uu[2]; p=.3*(1/.3)**uu[3]
                ans=LogHeadroomTaper(h,r0,p,log10_k0=k).solve()
                x=ans['log10_stop']; a=ans['log10_a_stop']; pars={'r0':r0,'p':p,'nu':ans['nu']}
            if f in ['single','heterogeneous','exponential_cost','continuum']:
                ans=m.solve(scan=False); x=ans['log10_optimal_x'];a=ans['log10_a_at_optimum']
            assert math.isfinite(x) and x<120 and math.isfinite(a)
            fam='rapid' if f in ['exponential_cost','exponential_efficiency','capped_raw_power'] else f
            rows.append({'family':fam,'subfamily':f,'draw':i,'Hmax':maxh,'log10_H':h,'log10_k0':k,'log10_x':x,'log10_a':a,**pars})
        print(f'Computed {maxh}: {f}',flush=True)
    return rows

def main():
    allrows=[]; out={'prior':S,'prior_sha256':hashlib.sha256((BASE/'prior.json').read_bytes()).hexdigest(),'sensitivities':{}}
    for hmax in [16,60,120]:
        rows=draw_rows(hmax); allrows+=rows
        out['sensitivities'][str(hmax)]={name:summarize(rows,w) for name,w in S['weights'].items()}
        if hmax==60:
            out['families']={f:np.quantile([r['log10_x'] for r in rows if r['subfamily']==f],[.05,.5,.95]).tolist() for f in sorted(set(r['subfamily'] for r in rows))}
    # Reuse same draws and just replace guaranteed slow components.
    central=[r for r in allrows if r['Hmax']==60]
    ablated=[]
    for row in central:
        r=dict(row)
        if r['family']=='heterogeneous':
            ans=CeilingModel(r['p_fast'],r['log10_H'],log10_k0=r['log10_k0']).solve(scan=False)
            r['log10_x']=ans['log10_optimal_x'];r['log10_a']=ans['log10_a_at_optimum']
        ablated.append(r)
    out['no_guaranteed_slow_residual']=summarize(ablated,S['weights']['central'])
    fields=list(dict.fromkeys(k for r in allrows for k in r))
    with (BASE/'draws.csv').open('w') as f:
        w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(allrows)
    (BASE/'results.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(out['sensitivities'],indent=2))
if __name__=='__main__':main()
