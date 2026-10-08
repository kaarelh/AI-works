"""Headroom/tail sensitivity in the user's common-multiplier toy model.

Own mathematical scenarios; headroom values are NOT fitted physical limits.
Finite cost-gap law C(F)=1/H+(1-1/H)*(1+F/F0)^(-p).
dF/dx=1/C, k=-C'/C^2, F0=p*(1-1/H)/k0.
Uses log coordinates so H can exceed 1e100 without numerical cancellation.
"""
from pathlib import Path
import json, math, csv
import numpy as np
from scipy.optimize import brentq

OUT=Path(__file__).resolve().parent
LN10=math.log(10)
LN_N=120*LN10
LN_K=-29*LN10

def logexpm1(t):
    if t==0:return -math.inf
    return t+math.log1p(-math.exp(-t)) if t>1 else math.log(math.expm1(t))

def evaluate(t,log10H,p):
    L=log10H*LN10
    logw=math.log1p(-math.exp(-L))
    logF0=math.log(p)+logw-LN_K
    if p==1:
        li=math.log(t) if t else -math.inf
    elif p<1:
        li=logexpm1((1-p)*t)-math.log(1-p)
    else:
        li=math.log(-math.expm1((1-p)*t))-math.log(p-1) if t else -math.inf
    logx=logF0+np.logaddexp(-L+logexpm1(t),logw+li)
    logC=np.logaddexp(-L,logw-p*t)
    logk=LN_K-(p+1)*t-2*logC
    return float(logx),float(logk),float(-logC)

def solve(log10H,p):
    hi=1
    while evaluate(hi,log10H,p)[0]<LN_N:hi*=2
    tN=brentq(lambda t:evaluate(t,log10H,p)[0]-LN_N,0,hi,xtol=1e-12)
    def f(t):
        lx,lk,_=evaluate(t,log10H,p)
        if lx>=LN_N:return -1000.
        frac=math.exp(lx-LN_N)
        return lk+LN_N+math.log1p(-frac)
    t=brentq(f,0,tN,xtol=1e-12)
    lx,lk,la=evaluate(t,log10H,p)
    ans=dict(log10_H=log10H,p=p,log10_x=lx/LN10,x_over_N=math.exp(lx-LN_N),
             log10_a_at_stop=la/LN10,log10_k_at_stop=lk/LN10,residual_log_optimality=f(t))
    assert abs(f(t))<1e-8,ans
    return ans

def main():
    values=[solve(H,p) for H in [3,12,26.49063961843035,60,120] for p in [.05,.1,.25,.5,1,2]]
    # Textbook raw-input power case, independent of a ceiling assumption.
    powers=[dict(q=q,x_over_N=q/(1+q),log10_x=120+math.log10(q/(1+q))) for q in [.01,.1,1,10]]
    # Constructive non-identification with EXACTLY equal a(0), k(0), and a(infinity).
    # k(x)=k0 exp(-x/L), L=ln(H)/k0; or k0(1+x/L)^(-s), L=(s-1)ln(H)/k0.
    # Both integrate to ln(H). They define valid common-multiplier models, with
    # F(x)=integral a(x)dx enforcing dF/dx=a identically.
    matched=[]
    H=12
    for s in [None,1.01,1.1,1.25,1.5,2,3,10]:
        logL=math.log(H*LN10)-LN_K+(math.log(s-1) if s else 0)
        def objective(logx):
            if logx>=LN_N:return -1000.
            logk=(LN_K-s*np.logaddexp(0,logx-logL)) if s else LN_K-math.exp(logx-logL)
            return logk+LN_N+math.log1p(-math.exp(logx-LN_N))
        lx=brentq(objective,-10,LN_N)
        matched.append(dict(law='exponential marginal' if s is None else 'power marginal',
                            s=s,log10_H=H,log10_x=lx/LN10,x_over_N=math.exp(lx-LN_N)))
    (OUT/'headroom_sensitivity.json').write_text(json.dumps({'N':1e120,'k0':1e-29,'law':'effective-research power cost gap','rows':values,'raw_power_laws':powers,'identical_headroom_counterexample':matched},indent=2)+'\n')
    with (OUT/'headroom_sensitivity.csv').open('w') as f:
        w=csv.DictWriter(f,fieldnames=list(values[0]));w.writeheader();w.writerows(values)
    for v in values:print(f"H=10^{v['log10_H']:.2f}, p={v['p']:.2g}, log10(x*)={v['log10_x']:.4f}, fraction={v['x_over_N']:.5g}")
    print(json.dumps(matched,indent=2))

if __name__=='__main__':main()
