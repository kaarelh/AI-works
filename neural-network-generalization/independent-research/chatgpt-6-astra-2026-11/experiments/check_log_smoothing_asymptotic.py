"""Numerically checks the two explicit 1D integrals sandwiching the kernel.
No two-dimensional kernel quadrature or Monte Carlo is needed here.
The floating-point integrals are diagnostic, not interval certificates.
"""
import json,math
from pathlib import Path
import mpmath as mp
ROOT=Path(__file__).resolve().parents[1]
mp.mp.dps=80
rows=[]
for A in (.25,.5,1.,2.):
    for r in (32,64,128,256,512,1024,2048):
        L=mp.mpf(str(A))*mp.log(r);a=L/r
        cutoff=mp.ceil(mp.sqrt(100/a)/mp.pi)*mp.pi
        intervals=int(cutoff/mp.pi)
        sm=lambda t: (1-mp.exp(-2*a*t*t)*mp.cos(2*t))/2
        f=lambda t: sm(t)**(mp.mpf(r)/2)/(mp.pi*t*t) if t else mp.mpf(0)
        # Split every peak into its own quadrature interval.
        I=mp.fsum(mp.quad(f,[k*mp.pi,(k+mp.mpf('.5'))*mp.pi,(k+1)*mp.pi]) for k in range(intervals))
        I+=mp.power(2,-mp.mpf(r)/2)/(mp.pi*cutoff)
        vf=mp.sqrt(L)
        terms=[]
        for k in range(r+1):
            t=mp.mpf(2*k-r)
            smooth=vf*mp.exp(-t*t/(2*L))/mp.sqrt(2*mp.pi)+t*mp.erfc(-t/(vf*mp.sqrt(2)))/2
            terms.append(mp.mpf(math.comb(r,k))*(-1)**(r-k)*smooth)
        mu=abs(mp.fsum(terms)/mp.power(2,r))
        asym=mp.mpf(32)/mp.pi**5*mp.power(r,-1-mp.mpf(str(A))*mp.pi**2/4)
        assert I+mp.mpf('1e-60')>=mu
        row=dict(A=A,r=r,sigma=float(mp.sqrt(a)),mu=str(mu),upper_root=str(I),
            lower_to_asymptotic=float(mu*mu/asym),upper_to_asymptotic=float(I*I/asym),
            sandwich_ratio=float(I*I/(mu*mu)))
        rows.append(row);print(json.dumps(row),flush=True)
(ROOT/'results/log_smoothing_asymptotic.json').write_text(json.dumps(dict(status='PASS',rows=rows,
    precision_decimal_digits=mp.mp.dps,qualification='Non-interval high-precision diagnostics.'),indent=2)+'\n')
