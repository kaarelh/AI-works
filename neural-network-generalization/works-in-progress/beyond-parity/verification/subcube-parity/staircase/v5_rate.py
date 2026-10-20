# claim 7: m=floor(d/2), restrict to |W|>=w0 with exact e_r(m): LB=(e/2)Pr[|W|>=w0]. Is -log LB = O(r^2/d) already at r ~ C sqrt d?
import math
from scipy.stats import binom
for C0 in [2,4]:
    for d in [401,1601,6401,25601,102401,409601]:
        r=int(C0*math.sqrt(d)); r-= (r%2==0)
        m=d//2; e=binom.cdf((m-r-1)//2,m,0.5)
        w0=1+math.sqrt(2*(m-1)*math.log(2/e)); N=d-m
        pW=2*binom.sf(math.ceil((N+w0)/2)-1,N,0.5)
        LB=e/2*pW
        print(f"C0={C0} d={d} r={r}: e_r(m)={e:.3e} w0/r={w0/r:.2f} LB={LB:.3e} -logLB/(r^2/d)={-math.log(LB)/(r*r/d):.2f}")
