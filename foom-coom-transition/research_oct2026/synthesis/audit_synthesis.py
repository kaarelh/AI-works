"""Independent October synthesis audit: positive-series Decimal integration.

Does not overwrite the forecast or its outputs. Decimal's 100-digit arithmetic
and an analytically expanded positive series replace the taper's quadrature.
"""
from pathlib import Path
from decimal import Decimal, localcontext
import json, math, csv, hashlib, sys
import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from taper_model import LogHeadroomTaper
from forecast import logistic_stop

D = Decimal

def decimal_taper(logh, r0, p, logk=-29):
    with localcontext() as ctx:
        ctx.prec = 100
        ten = D(10); ln10 = ten.ln()
        L = D(str(logh))*ln10
        b = D(str(p))*L
        nu = b/D(str(r0)); a = nu-1
        k0 = ten**D(str(logk)); N=ten**120
        def state(u):
            # exp[b*exp(-v)] is expanded with positive coefficients.
            # Integrals of exp[(nu-1-n)*v] have exact elementary forms.
            if not u:
                return D(0), k0
            eu = (-u).exp(); en=(a*u).exp()
            w=D(1); total=D(0); n=0
            while True:
                den=a-n
                integral=(en-1)/den if den else u
                term=w*integral
                total+=term
                if n>int(b)+30 and term<total*D('1e-95'):
                    break
                n+=1
                assert n<2000
                w*=b/n; en*=eu
            x=L/k0*(-b).exp()*total
            k=k0*(b*(1-eu)-nu*u).exp()
            return x,k
        lo=D(0); hi=D(1)
        while sum((state(hi)[0],1/state(hi)[1]))<N:
            hi*=2
        for _ in range(100):
            mid=(lo+hi)/2
            x,k=state(mid)
            if x+1/k<N:lo=mid
            else:hi=mid
        u=(lo+hi)/2; x,k=state(u)
        return {'log10_x':float(x.ln()/ln10), 'u':float(u),
                'relative_equation_residual':float((x+1/k)/N-1)}

def decimal_logistic(logh, logk):
    with localcontext() as ctx:
        ctx.prec=110
        ten=D(10); H=ten**D(str(logh)); k=ten**D(str(logk))
        r=k*H/(H-1); N=ten**120
        # In v=r*x, stationarity is v+1+exp(v)/(H-1)=r*N.
        lo=D(0); hi=((H-1)*r*N).ln()+1
        for _ in range(120):
            mid=(lo+hi)/2
            if mid+1+mid.exp()/(H-1)<r*N:lo=mid
            else:hi=mid
        v=(lo+hi)/2
        return float((v/r).log10())

def exact_cap(logh, logk, q):
    with localcontext() as ctx:
        ctx.prec=110
        q=D(str(q)); H=D(10)**D(str(logh)); k=D(10)**D(str(logk))
        N=D(10)**120
        xf=q/(1+q)*(N-1/k)
        xc=q/k*((H.ln()/q).exp()-1)
        return float(min(xf,xc).log10()), 'cap' if xc<xf else 'interior'

def weighted_summary(rows, weights):
    counts={f:sum(r['family']==f for r in rows) for f in weights}
    pairs=sorted((float(r['log10_x']),weights[r['family']]/counts[r['family']])
                 for r in rows if r['family'] in weights)
    x=np.array([v[0] for v in pairs]); w=np.array([v[1] for v in pairs])
    assert abs(sum(w)-1)<1e-12
    return {'log10_median':float(np.interp(.5,np.cumsum(w)/sum(w),x)),
            'probability_at_least_1pct_N':float(sum(w[x>=118])),
            'probability_at_least_10pct_N':float(sum(w[x>=119]))}

def main():
    cases=[]
    # Includes near the smallest nu in the specified support, a central case,
    # large headroom, and a large-nu/early-coordinate extreme.
    for h,r,p,k in [(6,3.6,.3,-29),(11,1.2,.3,-29),
                      (60,1.2,1,-29),(120,.4,1,-33)]:
        ref=decimal_taper(h,r,p,k)
        actual=LogHeadroomTaper(h,r,p,log10_k0=k).solve()
        error=actual['log10_stop']-ref['log10_x']
        assert abs(error)<1e-8
        cases.append({'family':'taper','log10_H':h,'r0':r,'p':p,'log10_k0':k,
                      'decimal_reference':ref,'log10_difference':error})
    for h,k in [(6,-25),(33,-29),(120,-33)]:
        ref=decimal_logistic(h,k)
        value,_=logistic_stop(h,k)
        assert abs(value-ref)<1e-8
        cases.append({'family':'exponential_efficiency','log10_H':h,'log10_k0':k,
                      'decimal_log10_reference':ref,'log10_difference':value-ref})
    rows=list(csv.DictReader((HERE/'draws.csv').open()))
    prior=json.loads((HERE/'prior.json').read_text())
    results=json.loads((HERE/'results.json').read_text())
    assert results['prior_sha256']==hashlib.sha256((HERE/'prior.json').read_bytes()).hexdigest()
    assert results['prior']==prior
    for weights in prior['weights'].values():assert abs(sum(weights.values())-1)<1e-14
    for weights in [prior['rapid_completion']['conditional_weights']]:
        assert abs(sum(weights.values())-1)<1e-14
    for h in [16,60,120]:
        group=[r for r in rows if int(r['Hmax'])==h]
        assert len(group)==8192
        for subfamily in set(r['subfamily'] for r in group):
            assert sum(r['subfamily']==subfamily for r in group)==1024
        for name,weights in prior['weights'].items():
            ours=weighted_summary(group,weights)
            theirs=results['sensitivities'][str(h)][name]
            assert abs(ours['log10_median']-theirs['log10_quantiles'][3])<1e-9
            for key in ['probability_at_least_1pct_N','probability_at_least_10pct_N']:
                assert abs(ours[key]-theirs[key])<1e-12
    caps=[r for r in rows if r['subfamily']=='capped_raw_power']
    picks=[min(caps,key=lambda r:float(r['log10_x'])),
           min(caps,key=lambda r:abs(float(r['log10_x'])-85)),
           max(caps,key=lambda r:float(r['log10_x']))]
    for row in picks:
        h,k,q=map(float,(row['log10_H'],row['log10_k0'],row['q']))
        ref,location=exact_cap(h,k,q)
        error=float(row['log10_x'])-ref
        assert abs(error)<1e-8
        cases.append({'family':'capped_raw_power','log10_H':h,'log10_k0':k,'q':q,
                      'location':location,'decimal_log10_reference':ref,'log10_difference':error})
    central=[r for r in rows if int(r['Hmax'])==60]
    without={f:w/.95 for f,w in prior['weights']['central'].items() if f!='continuum'}
    out={'checks':'100-digit independent series and elementary Decimal references; saved-row weighting audit',
         'cases':cases,'no_continuum_reweighted':weighted_summary(central,without),
         'max_abs_log10_error':max(abs(r['log10_difference']) for r in cases),
         'number_of_saved_rows':len(rows),'prior_hash_verified':True,
         'all_nine_weighted_summary_checks_passed':True}
    (HERE/'audit_results.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(out,indent=2))

if __name__=='__main__':main()
