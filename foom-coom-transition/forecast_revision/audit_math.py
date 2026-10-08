"""Independent 80-digit, direct-arithmetic audit of saved scenario roots.

Does not call math_model.py. Solves x+1/k=N by Decimal bisection, directly
evaluating raw cost and its derivative rather than their log implementations.
"""
from decimal import Decimal as D, localcontext
from pathlib import Path
import csv
import json

HERE = Path(__file__).resolve().parent


def j_series(t):
    if not t:
        return D(0)
    term = t
    total = term
    for n in range(2, 10000):
        term *= t * (n - 1) / D(n*n)
        total += term
        if term < total * D('1e-85'):
            return total
    raise RuntimeError('Series failed to converge')


def solve(row):
    with localcontext() as ctx:
        ctx.prec = 80
        N = D(10)**120
        k0 = D(10)**D('-27.5')
        fam = row['family']
        if fam == 'scale_free_within_budget':
            p = D(row['raw_p'])
            x = (p*N-p/k0)/(p+1)
            return float(x.log10())
        f = D(10)**(-D(row['log10_H']))
        w = 1-f
        if fam == 'single_power_gap':
            ps, ws = [D(row['p'])], [w]
        elif fam == 'heterogeneous_gaps':
            amp = D(row['slow_amplitude'])
            ps, ws = [D(row['p_fast']), D(row['p_slow'])], [w*(1-amp), w*amp]
        if fam in ['single_power_gap', 'heterogeneous_gaps']:
            F0 = sum(p*weight for p, weight in zip(ps,ws))/k0
        elif fam == 'rapid_ceiling':
            F0 = w/k0
        elif fam == 'continuous_slow_gaps':
            F0 = w/(2*k0)
        else:
            raise ValueError(fam)
        def state(t):
            if not t:
                return D(0), k0
            if fam in ['single_power_gap','heterogeneous_gaps']:
                z = t.exp()
                C = f+sum(weight*(-p*t).exp() for p,weight in zip(ps,ws))
                minusCp = sum(p*weight*(-(p+1)*t).exp() for p,weight in zip(ps,ws))/F0
                integral = f*(z-1)
                for p,weight in zip(ps,ws):
                    integ = t if p==1 else (((1-p)*t).exp()-1)/(1-p)
                    integral += weight*integ
                x = F0*integral
            elif fam == 'rapid_ceiling':
                e = (-t).exp()
                C = f+w*e
                minusCp = w*e/F0
                x = F0*(f*t+w*(1-e))
            else:
                e = (-t).exp()
                C = f+w*(1-e)/t
                minusCp = w*(1-(1+t)*e)/(F0*t*t*t.exp())
                x = F0*(f*(t.exp()-1)+w*j_series(t))
            return x, minusCp/(C*C)
        lo,hi = D(0),D(1)
        while True:
            x,k = state(hi)
            if x+1/k>=N:
                break
            hi*=2
        for _ in range(230):
            mid=(lo+hi)/2
            x,k=state(mid)
            if x+1/k<N:
                lo=mid
            else:
                hi=mid
        x,k=state((lo+hi)/2)
        return float(x.log10())


def main():
    rows=list(csv.DictReader((HERE/'forecast_draws.csv').open()))
    families=sorted(set(r['family'] for r in rows))
    results=[]
    for family in families:
        subset=[r for r in rows if r['family']==family and r['log10_H_max']=='12']
        subset.sort(key=lambda r: float(r['log10_x_stop']))
        for idx in [0,len(subset)//2,len(subset)-1]:
            r=subset[idx]
            independent=solve(r)
            difference=independent-float(r['log10_x_stop'])
            assert abs(difference)<1e-9
            results.append({'family':family,'draw':r['draw'],
                            'reported_log10_x':float(r['log10_x_stop']),
                            'independent_decimal_log10_x':independent,
                            'difference_log10_x':difference})
    output={'audit':'Independent 80-digit direct arithmetic; 230 bisection steps',
            'count':len(results),'max_abs_log10_error':max(abs(r['difference_log10_x']) for r in results),
            'results':results}
    (HERE/'math_audit.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(output,indent=2))


if __name__=='__main__':
    main()
