#!/usr/bin/env python3
"""Offline fits of NanoGPT record frontiers. No research-FLOP claim is made.

Run with Python 3.11+, numpy, scipy and matplotlib. Writes only beside itself.
"""
from pathlib import Path
import os
BASE=Path(__file__).resolve().parent
os.environ.setdefault('MPLCONFIGDIR',str(BASE/'.mplconfig'))
os.environ.setdefault('XDG_CACHE_HOME',str(BASE/'.cache'))
import csv, datetime as dt, json, re, hashlib
import numpy as np
from scipy.optimize import least_squares, minimize_scalar
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

SHA='4ea6b937337a4889b8cfe3f38a93d120048d8f71'
MODELS=('exponential','shifted_power','exponential_floor')

def dump_csv(name, rows):
    with (BASE/name).open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)

def parse():
    prs={p['number']:p for p in json.loads((BASE/'pr_metadata.json').read_text())}
    source=(BASE/'README.upstream.md').read_text().split('## World record history')[1].split('## Rules')[0]
    rows=[]
    for l in source.splitlines():
        if not re.match(r'^\d+\s*\|',l): continue
        parts=[x.strip() for x in l.split('|')]
        number,time_s,desc,date,links,contributors=parts
        minutes=float(time_s.split()[0]); assert 'minutes' in time_s
        date=dt.datetime.strptime(date,'%m/%d/%y').date().isoformat()
        pr=re.search(r'/pull/(\d+)',links)
        pr=int(pr.group(1)) if pr else None
        meta=prs.get(pr,{})
        merged=meta.get('merged_at')
        accepted=merged[:10] if merged else date
        log=re.search(r'\[log\]\(([^)]*)\)',links)
        is_retime='21st record' in desc
        rows.append(dict(record=int(number),source_date=date,accepted_proxy_date=accepted,
            acceptance_basis='github_merged_at' if merged else 'source_date_no_merged_pr',
            seconds=60*minutes,is_retime=is_retime,description=desc,
            pr_number=pr or '',pr_created_at=meta.get('created_at',''),
            pr_merged_at=merged or '',
            log_url=f'https://github.com/KellerJordan/modded-nanogpt/blob/{SHA}/{log.group(1)}' if log else '',
            source_url=f'https://github.com/KellerJordan/modded-nanogpt/blob/{SHA}/README.md'))
    assert len(rows)==94 and sum(not r['is_retime'] for r in rows)==92
    assert abs(rows[-1]['seconds']-39.9)<1e-8
    dump_csv('records.csv',rows)
    main=[r for r in rows if r['record']>=22 or (r['record']==21 and r['source_date']=='2025-05-24')]
    assert len(main)==72
    dump_csv('main_records.csv',main)
    dates=[dict(record=r['record'],source_date=r['source_date'],
                accepted_proxy_date=r['accepted_proxy_date'],
                lag_days=(dt.date.fromisoformat(r['accepted_proxy_date'])-dt.date.fromisoformat(r['source_date'])).days,
                basis=r['acceptance_basis']) for r in main]
    dump_csv('date_audit.csv',dates)
    return rows,main

def frontier(rows,date_key):
    # Same-day rows collapse to the smallest cost; dominated late acceptances drop.
    bydate={}
    for row in rows:
        date=row[date_key]
        if date not in bydate or row['seconds']<bydate[date]['seconds']: bydate[date]=row
    best=np.inf; out=[]
    for date,row in sorted(bydate.items()):
        if row['seconds']<best:
            best=row['seconds'];out.append(dict(date=date,seconds=best,record=row['record']))
    return out

def grid_monthly(rows):
    first=dt.date.fromisoformat(rows[0]['date']);last=dt.date.fromisoformat(rows[-1]['date'])
    out=[];year,month=first.year,first.month
    while True:
        following=dt.date(year+int(month==12),month%12+1,1)
        day=following-dt.timedelta(days=1)
        if day>last: break
        eligible=[r for r in rows if r['date']<=day.isoformat()]
        if eligible: out.append(dict(date=day.isoformat(),seconds=eligible[-1]['seconds'],record=eligible[-1]['record']))
        year,month=following.year,following.month
    # Include actual final record date, clearly identified in the exported series.
    if not out or out[-1]['date']!=rows[-1]['date']:out.append(rows[-1])
    return out

def pred(model,p,x):
    if model=='exponential': return p[0]-p[1]*x
    if model=='shifted_power': return p[0]-p[2]*np.log1p(x/np.exp(p[1]))
    return np.logaddexp(p[0],p[1]-np.exp(p[2])*x)

def fit(model,x,cost):
    y=np.log(cost); b=float(y.max());lower=float(y.min())
    starts=[]
    if model=='shifted_power':
        # Conditional on the shift, log C is linear in intercept and exponent.
        # Profile that one nonlinear parameter rather than solve a nearly singular
        # three-parameter least-squares problem near the exponential limit.
        lo,hi=np.log(1/365.25),np.log(1000)
        def profiled(lt):
            z=np.log1p(x/np.exp(lt))
            slope=float(np.dot(z-z.mean(),y-y.mean())/np.dot(z-z.mean(),z-z.mean()))
            exponent=float(np.clip(-slope,.00001,1000))
            intercept=float(np.mean(y+exponent*z))
            residual=intercept-exponent*z-y
            return float(np.dot(residual,residual)),[intercept,lt,exponent]
        grid=np.linspace(lo,hi,151)
        j=int(np.argmin([profiled(z)[0] for z in grid]))
        rs=minimize_scalar(lambda lt:profiled(lt)[0],bounds=(grid[max(0,j-1)],grid[min(len(grid)-1,j+1)]),method='bounded',options={'xatol':1e-11})
        sse,p=min([profiled(lo),profiled(hi),profiled(rs.x)],key=lambda a:a[0])
        n=len(x);k=3;K=k+1  # Gaussian residual variance is estimated from SSE.
        return dict(model=model,parameters=p,natural_parameters=dict(intercept_seconds=float(np.exp(p[0])),shift_years=float(np.exp(p[1])),power=float(p[2])),
            train_n=n,train_log_rmse=float(np.sqrt(sse/n)),sse=sse,
            curve_parameter_count=k,aicc_parameter_count=K,
            aicc=float(n*np.log(max(sse/n,1e-30))+2*K+2*K*(K+1)/(n-K-1)) if n>K+1 else None,
            optimizer_success=bool(rs.success),bound_hits=([1] if min(p[1]-lo,hi-p[1])<1e-4 else [])+([2] if p[2]>=999.999 else []))
    if model=='exponential':
        bounds=([lower-8,0],[b+8,30]); starts=[[b,.3],[b,2]]
    elif model=='shifted_power':
        bounds=([lower-8,np.log(1/365.25),.00001],[b+8,np.log(1000),1000])
        for tau in [.01,.1,1,10,100]:
            for p in [.2,1,3,10]:starts.append([b,np.log(tau),p])
    else:
        bounds=([lower-25,lower-10,np.log(.00001)],[lower-1e-8,b+8,np.log(50)])
        for frac in [.001,.1,.5,.9]:
            for rate in [.2,1,4]:starts.append([lower+np.log(frac),b,np.log(rate)])
    results=[least_squares(lambda p:pred(model,p,x)-y,start,bounds=bounds,
                 max_nfev=3000,ftol=1e-10,xtol=1e-10,gtol=1e-10) for start in starts]
    best=min(results,key=lambda r:np.dot(r.fun,r.fun))
    p=best.x;sse=float(np.dot(best.fun,best.fun));n=len(x);k=len(p);K=k+1
    bound_hits=[i for i,(v,lo,hi) in enumerate(zip(p,*bounds)) if min(v-lo,hi-v)<1e-4]
    natural={'intercept_seconds':float(np.exp(p[0])),'log_gain_per_year':float(p[1])} if model=='exponential' else (
       {'intercept_seconds':float(np.exp(p[0])),'shift_years':float(np.exp(p[1])),'power':float(p[2])} if model=='shifted_power' else
       {'floor_seconds':float(np.exp(p[0])),'initial_gap_seconds':float(np.exp(p[1])),'gap_decay_per_year':float(np.exp(p[2]))})
    return dict(model=model,parameters=p.tolist(),natural_parameters=natural,
        train_n=n,train_log_rmse=float(np.sqrt(sse/n)),sse=sse,
        curve_parameter_count=k,aicc_parameter_count=K,
        aicc=float(n*np.log(max(sse/n,1e-30))+2*K+2*K*(K+1)/(n-K-1)) if n>K+1 else None,
        optimizer_success=bool(best.success),bound_hits=bound_hits)

def run_fitset(name,rows):
    dates=np.array([r['date'] for r in rows]);cost=np.array([r['seconds'] for r in rows])
    origin=dt.date.fromisoformat(dates[0])
    x=np.array([(dt.date.fromisoformat(d)-origin).days/365.25 for d in dates])
    fits=[]
    for cutoff in ['2025-12-31','2026-03-31','2026-06-30','full']:
        train=dates<=cutoff if cutoff!='full' else np.ones(len(x),dtype=bool)
        if sum(train)<6: continue
        for model in MODELS:
            r=fit(model,x[train],cost[train]);yhat=pred(model,r['parameters'],x)
            hold=~train
            r.update(series=name,origin_date=origin.isoformat(),cutoff=cutoff,
                holdout_n=int(sum(hold)),final_date=str(dates[-1]),final_observed_seconds=float(cost[-1]),
                final_predicted_seconds=float(np.exp(yhat[-1])),
                holdout_log_rmse=float(np.sqrt(np.mean((yhat[hold]-np.log(cost[hold]))**2))) if any(hold) else None,
                holdout_mean_log_error=float(np.mean(yhat[hold]-np.log(cost[hold]))) if any(hold) else None)
            fits.append(r)
    return fits,x,cost

def floor_profile(rows):
    dates=[dt.date.fromisoformat(r['date']) for r in rows];origin=dates[0]
    x=np.array([(d-origin).days/365.25 for d in dates]);c=np.array([r['seconds'] for r in rows]);out=[]
    for frac in [0,.05,.1,.2,.3,.4,.5,.6,.7,.8,.9,.95,.99]:
        floor=frac*min(c)
        def fn(p):
            return np.log(floor+np.exp(p[0]-np.exp(p[1])*x))-np.log(c)
        rs=[least_squares(fn,[np.log(max(c)-floor),np.log(r)],max_nfev=3000) for r in [.2,1,4]]
        r=min(rs,key=lambda r:sum(r.fun**2))
        out.append(dict(floor_fraction_of_latest_cost=frac,floor_seconds=floor,
               sse=float(sum(r.fun**2)),log_rmse=float(np.sqrt(np.mean(r.fun**2))),
               fitted_decay_per_year=float(np.exp(r.x[1]))))
    best=min(r['sse'] for r in out)
    for r in out:r['sse_minus_best_profile']=r['sse']-best
    return out

def plot(series, fits):
    fig,axs=plt.subplots(1,2,figsize=(12,4.7))
    colors={'exponential':'#2f6bcb','shifted_power':'#d87522','exponential_floor':'#379472'}
    for ax,which,cut in zip(axs,['accepted_frontier','accepted_frontier'],['2025-12-31','2026-03-31']):
        rows=series[which];d=[dt.date.fromisoformat(r['date']) for r in rows]
        origin=d[0];x=np.array([(v-origin).days/365.25 for v in d]);c=[r['seconds'] for r in rows]
        ax.step(d,c,where='post',color='black',alpha=.55,label='Accepted-date record frontier')
        ax.scatter(d,c,s=14,color='black',alpha=.7)
        for f in fits:
            if f['series']==which and f['cutoff']==cut:
                ax.plot(d,np.exp(pred(f['model'],f['parameters'],x)),color=colors[f['model']],label=f['model'].replace('_',' '))
        ax.axvline(dt.date.fromisoformat(cut),color='gray',linestyle='--')
        ax.set_yscale('log');ax.set_ylabel('Timed training seconds, 8 H100');ax.set_title('Fitted through '+cut)
        ax.tick_params(axis='x',rotation=30);ax.grid(alpha=.2);ax.set_ylim(30,220)
    axs[0].legend(fontsize=8)
    fig.suptitle('NanoGPT: chronological prediction at fixed 3.28 FineWeb target',fontsize=13)
    fig.tight_layout();fig.savefig(BASE/'holdouts.png',dpi=180);plt.close(fig)

def main():
    records,mainrows=parse()
    series={'accepted_frontier':frontier(mainrows,'accepted_proxy_date'),
            'source_date_frontier':frontier(mainrows,'source_date')}
    series['accepted_monthly']=grid_monthly(series['accepted_frontier'])
    series['accepted_without_final_record']=frontier([r for r in mainrows if r['record']<92],'accepted_proxy_date')
    # Rerun of the final submission reported by maintainer; estimate sensitivity, not corrected truth.
    rerun=[{**r,'seconds':40.6 if r['record']==92 else r['seconds']} for r in mainrows]
    series['accepted_final_40_6_s']=frontier(rerun,'accepted_proxy_date')
    fits=[]
    for name,rows in series.items():
        dump_csv(name+'.csv',rows);part,_,_=run_fitset(name,rows);fits+=part
    profile=floor_profile(series['accepted_frontier']);dump_csv('floor_profile.csv',profile)
    # Early historical floor extrapolation is diagnostic only; timing regimes differ.
    early=[dict(date=r['source_date'],seconds=r['seconds'],record=r['record']) for r in records
           if 3<=r['record']<=21 and not r['is_retime']]
    d=[dt.date.fromisoformat(r['date']) for r in early]
    x=np.array([(v-d[0]).days/365.25 for v in d]);c=np.array([r['seconds'] for r in early])
    earlyfloor=fit('exponential_floor',x,c)
    earlyfloor.update(label='2024-10-04 to 2025-01-26; old timing; diagnostic only',
       later_under_new_rules_seconds=39.9)
    out=dict(source_commit=SHA,observations=len(records),numbered_records=92,
        main_records=len(mainrows),series_sizes={k:len(v) for k,v in series.items()},
        target_loss=3.28,hardware='8 NVIDIA H100 GPUs',
        latest_source_date='2026-08-30',latest_acceptance_date='2026-09-28',
        post_rule_improvement_factor=mainrows[0]['seconds']/mainrows[-1]['seconds'],
        historical_baseline_improvement_factor=2700/39.9,
        fits=fits,full_floor_profile=profile,early_floor_diagnostic=earlyfloor,
        no_cosmic_fit_reason='Neither calendar time nor accepted-record counts measure cumulative effective or raw research FLOPs; finite benchmark cost floors do not identify universal a(F).')
    (BASE/'results.json').write_text(json.dumps(out,indent=2,allow_nan=False)+'\n')
    flat=[]
    for f in fits:
        flat.append({k:f[k] for k in ['series','cutoff','model','train_n','holdout_n','train_log_rmse','holdout_log_rmse','final_observed_seconds','final_predicted_seconds','optimizer_success','bound_hits']})
    dump_csv('fit_summary.csv',flat)
    plot(series,fits)
    print(json.dumps({k:v for k,v in out.items() if k not in ['fits','full_floor_profile']},indent=2))
    for f in fits:
        if f['series']=='accepted_frontier':
            print(f['cutoff'],f['model'],'train=',round(f['train_log_rmse'],4),'holdout=',f['holdout_log_rmse'],f['natural_parameters'])

if __name__=='__main__': main()
