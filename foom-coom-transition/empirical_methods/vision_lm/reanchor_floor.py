"""Project the already fitted 2019 floor curve to a declared forecast date.

No additional observations or historical parameter fitting occur here. Both
anchors independently impose the user's k0 as their starting marginal gain.
"""
from pathlib import Path
from datetime import date
import json,csv,math
import numpy as np
from scipy.optimize import brentq

HERE=Path(__file__).resolve().parent
FORECAST_DATE='2026-09-12'
LAST_OBSERVATION='2019-05-28'

def project_current(r):
    best_frac=r['vision_floor_diagnostics']['best_floor_fraction_of_last_observation']
    best=next(q for q in r['vision_floor_profile'] if q['floor_fraction_of_last_observed_compute']==best_frac)
    # Backward-compatible reading of the original key, which referred to 2019.
    f_last=best.get('fitted_floor_fraction_of_anchor_compute',best['fitted_floor_fraction_of_current_compute'])
    elapsed=(date.fromisoformat(FORECAST_DATE)-date.fromisoformat(LAST_OBSERVATION)).days/365.25
    s=best['calendar_exponent_s']
    f=f_last/(f_last+(1-f_last)*math.exp(-s*elapsed))
    N=r['normalization']['N'];k0=r['normalization']['k0']
    out={'forecast_anchor':FORECAST_DATE,'last_observed_anchor':LAST_OBSERVATION,
        'anchor_status':'calendar projection of fitted historical curve; not a new observation',
        'elapsed_years':elapsed,'historical_calendar_exponent_s':s,
        'historical_floor_fraction_of_anchor_compute':f_last,
        'projected_floor_fraction_of_anchor_compute':f,
        'k0_reimposed_at_anchor':k0,'projections':{}}
    for name,g in r['proxy_growth_per_year'].items():
        p=s/math.log(g);x0=p*(1-f)/k0
        def logk(logx):
            logz=np.logaddexp(0,logx-math.log(x0))
            return math.log(k0)-(p+1)*logz-np.logaddexp(math.log(f),math.log(1-f)-p*logz)
        threshold=brentq(lambda lx:logk(lx)+math.log(N),math.log(1/k0),2*math.log(N))
        stop=brentq(lambda lx:logk(lx)+math.log(N)+math.log1p(-math.exp(lx)/N),math.log(1/k0),math.log(N)-1e-8)
        out['projections'][name]={'p':p,'x0':x0,'log10_stop_flops':stop/math.log(10),
            'stop_flops':math.exp(stop),'log10_exact_threshold_flops':threshold/math.log(10),
            'exact_1e120_threshold_flops':math.exp(threshold)}
    return out

if __name__=='__main__':
    r=json.loads((HERE/'results.json').read_text())
    for q in r['vision_floor_profile']:
        q['forecast_anchor']=LAST_OBSERVATION
        if 'fitted_floor_fraction_of_current_compute' in q:
            q['fitted_floor_fraction_of_anchor_compute']=q['fitted_floor_fraction_of_current_compute']
    current=project_current(r)
    r['vision_floor_projected_current_anchor']=current
    (HERE/'results.json').write_text(json.dumps(r,indent=2))
    rows=[]
    for item in r['vision']+r['language_models']:
        for name,v in item['projections'].items():
            rows.append(dict(method=item['method'],proxy=name,s=item['s_ln_efficiency_per_year'],**v,
                forecast_anchor='normalized current; stationary power shape'))
    best_frac=r['vision_floor_diagnostics']['best_floor_fraction_of_last_observation']
    best=next(q for q in r['vision_floor_profile'] if q['floor_fraction_of_last_observed_compute']==best_frac)
    for anchor,item,label in [(LAST_OBSERVATION,best,'vision_best_fitted_floor_last_observation_2019'),
                              (FORECAST_DATE,current,'vision_best_fitted_floor_projected_current_2026')]:
        for name,v in item['projections'].items():
            rows.append(dict(method=label,proxy=name,s=current['historical_calendar_exponent_s'],
                p=v['p'],stop_flops=10**v['log10_stop_flops'],stop_fraction=10**(v['log10_stop_flops']-120),
                exact_1e120_threshold_flops=10**v['log10_exact_threshold_flops'],
                marginal_at_stop_over_1e_minus_120=1,forecast_anchor=anchor))
    with (HERE/'all_answers.csv').open('w') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    print(json.dumps(current,indent=2))
