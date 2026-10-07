exec(open('p62.py').read().split("tol=0.05\n")[0])
from scipy.optimize import brentq
sig=2**-0.5
for t in [0.05,0.01,0.002,0.0004]:
    rr=brentq(lambda r: bound(r,sig)-t, 1.2, 1e8)
    rs=np.exp(np.linspace(np.log(1.0001), np.log(rr*2), 4000)); errs=np.array([abs(ratio(r,sig)-1) for r in rs]); idx=np.where(errs>t)[0]
    rb=brentq(lambda r: abs(ratio(r,sig)-1)-t, rs[idx[-1]], rs[idx[-1]+1])
    print(f"tol={t}: sigma=1/sqrt2 rigorous {rr:.1f}a exact {rb:.3f}a ratio {rr/rb:.1f}")
