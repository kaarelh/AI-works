"""Forethought arithmetic and explicitly assumed toy-model translations.
Run from any cwd using Python with numpy/scipy. No network or file writes outside this folder.
"""
from pathlib import Path
import json, math, warnings
import numpy as np
from scipy.integrate import quad
from scipy.optimize import brentq
from scipy.special import digamma, logsumexp

ROOT=Path(__file__).resolve().parent
LN10=math.log(10); LN2=math.log(2)
LOGK0=-29*LN10; LOGN=120*LN10; LOGR=LOGN+LOGK0

def continuous(h, p=.3, r0=1.2, nu_override=None):
    """h=ln H, p parallel labor exponent (NOT cost-gap exponent)."""
    nu=p*h/r0 if nu_override is None else nu_override
    def ln_scaled_x(w):
        if w==0:return -math.inf
        if w<1e-10:return math.log(h*w)
        def f(v):return -p*h*(-math.expm1(-v))+(nu-1)*v
        peak=max(0,f(w))
        # Breaks help resolve the early boundary layer and late steep endpoint.
        rawcuts=sorted(set([0., w]+[v for v in (0.01,.1,1.,10.,100.,w-10,w-1,w-.1) if 0<v<w]))
        cuts=[rawcuts[0]]
        for cut in rawcuts[1:]:
            if cut-cuts[-1]>1e-12*max(1,w):cuts.append(cut)
        if cuts[-1]!=w:cuts[-1]=w
        val=sum(quad(lambda v:math.exp(f(v)-peak),l,u,epsabs=1e-13,epsrel=3e-11)[0] for l,u in zip(cuts[:-1],cuts[1:]))
        return math.log(h)+peak+math.log(val)
    def ln_rate(w):return p*h*(-math.expm1(-w))-nu*w # k/k0
    def objective_deriv(w):
        lx=ln_scaled_x(w)
        if lx>=LOGR:return -1e300
        return ln_rate(w)+LOGR+math.log1p(-math.exp(lx-LOGR))
    high=1.
    while objective_deriv(high)>0:high*=2
    w=brentq(objective_deriv,0.,high,xtol=5e-13,rtol=5e-15)
    lx=ln_scaled_x(w)
    # Independent positive-term analytic expansion of the same integral.
    terms=[]
    for n in range(max(200,int(4*p*h))):
        b=nu-1-n;bw=b*w
        if abs(bw)<1e-8: li=math.log(w)+(bw/2 if bw else 0)
        elif b>0: li=(bw+math.log1p(-math.exp(-bw)))-math.log(b)
        else: li=math.log(-math.expm1(bw))-math.log(-b)
        terms.append(n*math.log(p*h)-math.lgamma(n+1)+li)
    independent_lx=math.log(h)-p*h+float(logsumexp(terms))
    assert abs(independent_lx-lx)<2e-8,(independent_lx,lx)
    # Independently solve the simpler k=1/N crossing.
    wh=1.
    while ln_rate(wh)+LOGR>0:wh*=2
    wa=brentq(lambda v:ln_rate(v)+LOGR,0,wh,xtol=5e-13,rtol=5e-15)
    return dict(log10_H=h/LN10,p=p,r0=r0,nu=nu,gap_exponent=(1/(nu-1) if nu>1 else None),w_star=w,log10_x=(lx-LOGK0)/LN10,x_over_N=math.exp(lx-LOGR),log10_a=h*(-math.expm1(-w))/LN10,remaining_log_headroom=h*math.exp(-w)/LN10,log10_k=(LOGK0+ln_rate(w))/LN10,stop_residual=objective_deriv(w),independent_integral_log_error=independent_lx-lx,threshold_log10_x=(ln_scaled_x(wa)-LOGK0)/LN10)

def discrete(M=88,p=.3,r0=1.2,substeps=1):
    """Literal published recurrence extended past 48/72-month display cutoff.
    Split each original doubling into substeps; set initial dx=delta/k0.
    r is reduced before updating next step time, as in repository code.
    Optimize endpoints and (piecewise exponential) interiors with N-x exact.
    This is a numerical extrapolation, not Forethought's forecast.
    """
    m=M*substeps; delta=LN2/substeps
    i=np.arange(m,dtype=float)
    harmonic_diff=digamma(m)-digamma(m-i)
    logdx=math.log(delta)-LOGK0+p*delta*(m/r0*harmonic_diff-i)
    total_logx=float(np.logaddexp.reduce(logdx))
    lx=-math.inf; u=0.; best=(LOGN,0.,0.)
    for j,ldx in enumerate(logdx):
        frac=math.exp(lx-LOGN) if lx<LOGN else 1.
        if frac>=1:break
        # For interval j: log a=u+delta * (x-x_before)/dx.
        k=math.exp(math.log(delta)-ldx)
        x0=math.exp(lx) if lx!=-math.inf else 0.
        dx=math.exp(ldx) if ldx<710 else math.inf
        x1=min(x0+dx,math.exp(LOGN))
        xo=math.exp(LOGN)-1/k if k>math.exp(-LOGN) else x0
        xo=min(max(xo,x0),x1)
        for x in (x0,x1,xo):
            if x>=math.exp(LOGN):continue
            ua=u+delta*(x-x0)/dx
            util=ua+LOGN+math.log1p(-x/math.exp(LOGN))
            if util>best[0]:best=(util,x,ua)
        lx=float(np.logaddexp(lx,ldx));u+=delta
    # If full ceiling is affordable, inspect it explicitly.
    if total_logx<LOGN:
        x=math.exp(total_logx);ua=M*LN2
        util=ua+LOGN+math.log1p(-x/math.exp(LOGN))
        if util>best[0]:best=(util,x,ua)
    return dict(substeps=substeps,delta_log2=1/substeps,log10_cap_x=total_logx/LN10,log10_opt_x=math.log10(best[1]) if best[1]>0 else None,log10_a=best[2]/LN10)

def monte_carlo(n=50000,seed=20261002):
    """Reimplements base multiple_sims.py without UI; original 48 month window."""
    rng=np.random.default_rng(seed)
    boosts=np.exp(rng.uniform(math.log(2),math.log(32),n))
    r0s=np.exp(rng.uniform(math.log(.4),math.log(3.6),n))
    ys=rng.uniform(6,16,n)
    ps=np.exp(rng.uniform(math.log(.15),math.log(.6),n))
    hits=np.zeros(4,dtype=int)
    conditions=[(12,24),(4,26),(12,80),(4,80)]
    for b,r0,y,p in zip(boosts,r0s,ys,ps):
        dt=3/b;t=0.;r=r0;k=r0/(8*y);times=[0.];i=0
        while t<48 and i<8*y and r>0:
            t+=dt;times.append(t);i+=1;r-=k
            if r>0:
                exponent=LN2*p*(1/r-1)
                dt=dt*math.exp(exponent) if exponent<700 else math.inf
        for ci,(period,count) in enumerate(conditions):
            if any(times[j+count]-times[j]<period for j in range(len(times)-count)):hits[ci]+=1
    return {'n':n,'seed':seed,'probabilities':dict(zip(['3_years_in_12mo','3.333_years_in_4mo','10_years_in_12mo','10_years_in_4mo'],(hits/n).tolist())),'note':'4-month 3-year headline is implemented by code as speedup 10, floor(26.666)=26 software doublings =3.25 years; naming of second key is nominal.'}

if __name__=='__main__':
    out={}
    out['arithmetic']={'headroom_factor_product_low':10*3*3*3*3*3*3,'headroom_factor_product_high':1e5*10*300*100*10*30*10,'headroom_low_oom':math.log10(10*3**6),'headroom_high_oom':math.log10(1e5*10*300*100*10*30*10),'initial_asara_speedup':30**(.5*.6)*30**.5,'hardware_limit_ratio':3e19/1e13,'earth_production_ratio':100*3000,'latest_2026_growth_factor_per_doubling':2**.39,'latest_2026_nine_doublings_months':4.5*sum(2**(-.39*i) for i in range(9)),'CES_caps':{str(rho):.5**(1/rho) for rho in [-1,-.5,-.4,-.2,-.15,-.1]}}
    out['continuous_sensitivity']=[]
    for units in ['training_compute','parallel_labor_software']:
        for y,p,r0 in [(6,.3,1.2),(11,.3,1.2),(16,.3,1.2),(11,.15,1.2),(11,.6,1.2),(11,.3,.4),(11,.3,3.6),(6,.15,3.6),(16,.6,.4)]:
            h=y*(LN10 if units=='training_compute' else 8*LN2)
            out['continuous_sensitivity'].append({'units':units,'years_headroom':y,**continuous(h,p,r0)})
    eta=LN10/(8*LN2)
    out['proper_power_reparameterization']={'eta':eta,**continuous(11*LN10,p=.3/eta,r0=1.2)}
    out['both_labor_and_experiments_scale_same_multiplier']={'note':'Heuristic: replace feedback a^.3 by a^.6 but preserve assumed fishing-out schedule nu.',**continuous(88*LN2,p=.6,r0=1.2,nu_override=.3*88*LN2/1.2)}
    out['chinchilla_analogy']=[]
    for d in [1e8,1e9,1e10,1e11,1e12]:
        aa,bb,alpha,beta=406.4,410.7,.34,.28;n=1e14
        loss=aa/n**alpha+bb/d**beta
        nopt=(aa/(loss*beta/(alpha+beta)))**(1/alpha)
        dopt=(bb/(loss*alpha/(alpha+beta)))**(1/beta)
        out['chinchilla_analogy'].append({'N':n,'D':d,'Nopt':nopt,'Dopt':dopt,'log10_compute_gain':math.log10(n*d/nopt/dopt)})
    out['discrete_resolution']=[discrete(substeps=s) for s in [1,10,100,1000]]
    out['base_monte_carlo']=monte_carlo()
    (ROOT/'results.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(out,indent=2))
