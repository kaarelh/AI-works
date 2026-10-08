"""GPT-6 (Codex), 2026-09-13.

Propagate an explicit SUBJECTIVE scenario prior through exact stopping models.
This is not a likelihood fit or an empirical posterior over cosmic outcomes.
"""
from pathlib import Path
import csv, json, math, hashlib
import numpy as np
from scipy.special import ndtri
from scipy.stats import qmc
from math_model import CeilingModel, ExponentialCeilingModel, ContinuumCeilingModel

BASE=Path(__file__).resolve().parent
SPEC=json.loads((BASE/'forecast_prior.json').read_text())
N=1e120;K0=10**-27.5

def wquant(x,w,qs):
    positive=np.asarray(w)>0
    x=np.asarray(x)[positive];w=np.asarray(w)[positive]
    ix=np.argsort(x);xx=x[ix];ww=w[ix]
    cc=np.cumsum(ww)/np.sum(ww)
    return np.interp(qs,cc,xx).tolist()

def summarize(rows,weights):
    xx=np.array([r['log10_x_stop'] for r in rows])
    fam=np.array([r['family'] for r in rows])
    w=np.zeros(len(rows))
    for f,v in weights.items():
        m=fam==f
        assert m.any()
        w[m]=v/m.sum()
    assert abs(w.sum()-1)<1e-10
    return {
        'log10_x_quantiles_05_10_25_50_75_90_95':wquant(xx,w,[.05,.1,.25,.5,.75,.9,.95]),
        'mean_log10_x':float(w@xx),
        'mean_stop_fraction_N':float(w@10**(xx-120)),
        'cdf':{str(z):float(w[xx<=z].sum()) for z in [30,60,74,90,100,110,115,118,119]},
        'probability_fraction_at_least_1pct':float(w[xx>=118].sum()),
        'probability_fraction_at_least_10pct':float(w[xx>=119].sum()),
        'probability_fraction_at_least_50pct':float(w[xx>=math.log10(.5*N)].sum()),
    }

def main():
    # Sobol common draws make parameter sensitivities comparable.
    n_power=10
    u=qmc.Sobol(d=5,scramble=True,seed=20260913).random_base2(n_power)
    u=np.clip(u,1e-12,1-1e-12)
    records=[];all_summary={};baseline=None
    families=list(SPEC['family_weights']['central'])
    for maxh in [3,12,30,120]:
        rows=[]
        for fam in families:
            for idx,uu in enumerate(u):
                h=1+(maxh-1)*uu[0]
                pars={}
                if fam=='single_power_gap':
                    p=.5*math.exp(math.log(3)*ndtri(uu[1]))
                    m=CeilingModel(p,h);pars={'p':p}
                elif fam=='heterogeneous_gaps':
                    pf=.5*4**uu[1];ps=.03*10**uu[2];amp=10**(-12+10*uu[3])
                    m=CeilingModel([pf,ps],h,[1-amp,amp]);pars={'p_fast':pf,'p_slow':ps,'slow_amplitude':amp}
                elif fam=='rapid_ceiling':
                    m=ExponentialCeilingModel(h)
                elif fam=='continuous_slow_gaps':
                    m=ContinuumCeilingModel(h)
                elif fam=='scale_free_within_budget':
                    p=math.exp(.5*ndtri(uu[1]));x=p/(1+p)*(N-1/K0)
                    rr={'log10_optimal_x':math.log10(x),'log10_exact_threshold_x':math.log10(p*(N-1/K0)),
                        'log10_a_at_optimum':p*math.log10(1+K0*x/p)}
                    pars={'raw_p':p}
                else:raise ValueError(fam)
                if fam!='scale_free_within_budget':rr=m.solve(scan=False)
                rows.append({'family':fam,'draw':idx,'log10_H_max':maxh,'log10_H':h if fam!='scale_free_within_budget' else None,
                             'log10_x_stop':rr['log10_optimal_x'],'log10_x_exact':rr['log10_exact_threshold_x'],
                             'log10_a_stop':rr['log10_a_at_optimum'],**pars})
            print('Completed H max',maxh,fam,flush=True)
        records.extend(rows)
        all_summary[str(maxh)]={name:summarize(rows,w) for name,w in SPEC['family_weights'].items()}
        if maxh==12:baseline=rows
    family_summary={}
    for fam in families:
        rs=[r for r in baseline if r['family']==fam]
        xx=np.array([r['log10_x_stop'] for r in rs])
        family_summary[fam]={'log10_x_quantiles_05_50_95':np.quantile(xx,[.05,.5,.95]).tolist()}
    # A repeated-root audit covers extreme and middle draws from each family.
    # Source mathematical tests independently verify dx/dF and k.
    out={'author':'GPT-6 (Codex)','date':'2026-09-13',
         'status':'Subjective scenario mixture; probabilities are elicited judgments, not empirical confidence.',
         'prior_sha256':hashlib.sha256((BASE/'forecast_prior.json').read_bytes()).hexdigest(),
         'samples_per_family':len(u),'normalization':SPEC['normalization'],
         'family_summary_baseline_Hmax12':family_summary,'headroom_and_weight_sensitivity':all_summary,
         'prior':SPEC}
    (BASE/'forecast_results.json').write_text(json.dumps(out,indent=2)+'\n')
    fields=list(dict.fromkeys(k for r in records for k in r))
    with (BASE/'forecast_draws.csv').open('w') as f:
        ww=csv.DictWriter(f,fieldnames=fields);ww.writeheader();ww.writerows(records)
    print(json.dumps({'family_summary':family_summary,'central':all_summary['12']},indent=2))

if __name__=='__main__':main()
