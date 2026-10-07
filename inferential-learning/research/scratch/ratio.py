import numpy as np
from scipy.optimize import brentq
exec(open('leg.py').read().split('# bound-certified')[0])
for sig in [1/np.sqrt(2),0.7,0.8,0.9,1.0]:
    phi=2*np.arcsin(sig)
    for tol in [0.05,0.01]:
        rb=brentq(lambda r: bound(1/r,sig)-tol,1.2,1e7)
        f=lambda r: abs(ratio_exact(r,phi)-1)-tol
        rs=np.geomspace(1.2,rb,4000); vals=[f(x) for x in rs]; last=1.2
        for i in range(len(rs)-1):
            if vals[i]>0 and vals[i+1]<=0: last=brentq(f,rs[i],rs[i+1])
        print(f"sigma={sig:.4f} tol={tol}: bound r={rb:.1f}, exact r={last:.2f}, factor {rb/last:.1f}")
