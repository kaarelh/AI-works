"""GPT-6 (Codex) - 2026-10-02.

An independent continuous translation of a local-return taper, NOT a
reproduction of a source's discrete doubling algorithm or cosmic forecast.
Uses the same raw/effective feedback as the parent model by defining da/dF=k(a).
"""
from pathlib import Path
import json
import math
from scipy.integrate import quad
from scipy.optimize import brentq
import numpy as np

LN10=math.log(10)

class LogHeadroomTaper:
    """d ln k/d ln a = p*(1-1/r), r=r0*(1-ln(a)/ln(H)).

    y=ln(a), u=-ln(1-y/L), L=ln(H).
    k=k0*exp(p*y)*(1-y/L)**nu, nu=p*L/r0.
    x=(L/k0)*integral exp((nu-1)*v-p*L*(1-exp(-v))) dv.
    The integral is scaled by its maximal log integrand to prevent overflow.
    """
    def __init__(self, log10_H, r0, p, log10_k0=-29, log10_N=120):
        assert log10_H>0 and r0>0 and p>0
        self.L=log10_H*LN10
        self.p=p; self.r0=r0; self.nu=p*self.L/r0
        self.lk0=log10_k0*LN10; self.lN=log10_N*LN10

    def state(self,u):
        if u==0:return -math.inf,self.lk0,0.
        pl=self.p*self.L
        def h(v):return (self.nu-1)*v-pl*(-math.expm1(-v))
        # h''=pl exp(-v)>0, hence maximum on endpoints.
        shift=max(0.,h(u))
        val,err=quad(lambda v: math.exp(h(v)-shift),0,u,epsabs=1e-11,epsrel=1e-10,limit=120)
        if val<=0:raise ValueError('Integral underflow')
        lx=math.log(self.L)-self.lk0+shift+math.log(val)
        y=self.L*(-math.expm1(-u))
        lk=self.lk0+self.p*y-self.nu*u
        return lx,lk,y

    def solve(self):
        def fn(u):
            lx,lk,_=self.state(u)
            return float(np.logaddexp(lx,-lk))-self.lN
        hi=1.
        while fn(hi)<0:hi*=2
        u=brentq(fn,0,hi,xtol=1e-11,rtol=1e-12)
        lx,lk,y=self.state(u)
        return dict(log10_H=self.L/LN10,r0=self.r0,p=self.p,nu=self.nu,
            implied_power_gap_exponent=1/(self.nu-1) if self.nu>1 else None,
            log10_stop=lx/LN10,stop_fraction=math.exp(lx-self.lN),
            log10_a_stop=y/LN10,log10_k_stop=lk/LN10,log_gap_fraction=-u,
            economic_log_residual=fn(u))

def main():
    cases=[]
    for logh in [6,11,16,30,60,120]:
        for r0 in [.4,1.2,3.6]:
            for p in [.3,1.]:
                ans=LogHeadroomTaper(logh,r0,p).solve()
                assert abs(ans['economic_log_residual'])<1e-8
                cases.append(ans)
    # Check shared feedback and local slopes by independent finite differences.
    for m in [LogHeadroomTaper(11,1.2,.3),LogHeadroomTaper(6,3.6,.3)]:
        for u in [.01,1.,10.]:
            e=1e-5
            xm,_,ym=m.state(u-e);xp,_,yp=m.state(u+e)
            lx,lk,y=m.state(u)
            dx_du=(math.exp(xp)-math.exp(xm))/(2*e)
            dy_du=(yp-ym)/(2*e)
            assert abs(math.log(dy_du/dx_du)-lk)<1e-7
            # dF/dx=a follows when dF=exp(y) dx; da/dF=k identically.
    out=dict(author='GPT-6 (Codex)',date='2026-10-02',
        interpretation='Independent continuous taper sensitivity; not an identified empirical tail.',
        definition='r(y)=r0(1-y/lnH); dlnk/dy=p(1-1/r(y)); raw compute flow held fixed.',
        cases=cases)
    target=Path(__file__).with_name('taper_results.json')
    target.write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps([r for r in cases if r['r0']==1.2],indent=2))

if __name__=='__main__':main()
