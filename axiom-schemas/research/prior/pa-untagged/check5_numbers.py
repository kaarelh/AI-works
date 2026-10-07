# (4) Illustrative sample sizes, tagged vs untagged, with the paper's constants (ILLUSTRATIVE ONLY).
import math
from math import comb, log, log2, exp
def first_N(f,delta):
    N=1
    while f(N)>delta: N+=1
    return N
delta=0.05; k=8; kp=8
piG=0.1; pi=0.3            # 7 Q axioms at 0.1 each, induction 0.3
# ARTIFICIAL rich usage: induction variable fixed ('x', v=3 metavariables P,A,B), phi-root uniform over r=9 roots
r=9; v=3
rho=min(4/9,1.0)           # best split of 9 uniform roots; pair events (D) have prob 1 (non-vacuous inductions)
c=2*v+comb(v,2)
tag=lambda N: 7*exp(-N*piG)+c*exp(-N*pi*rho)
print('tagged (Thm imitation:coupon):        N =',first_N(tag,delta))
# untagged, exact threshold k-1 with the finite-support union bound (M = r positive-mass failure sets)
def unt(N,K):
    s=7*(1-piG)**N
    for j in range(0,K+1):
        s+=comb(r,j)*(1-pi*(r-j)/r)**N
    return s
print('untagged, union bound, k-1=7 slots:   N =',first_N(lambda N:unt(N,k-1),delta))
print('untagged, union bound, k=8 slots:     N =',first_N(lambda N:unt(N,k),delta), '(paper\'s k instead of k-1)')
# paper Thm imitation:untagged(b): eps-net bound on the number of induction samples
def epsnet(K,zeta):
    d=2*K*log2(4*K*(v*v+1))
    return (8*d/zeta)*log2(13/zeta)+(4/zeta)*log2(2*kp/delta), d
for K,lab in [(k,'paper (k=8, zeta_8=1/9)'),(k-1,'refined (k-1=7, zeta_7=2/9)')]:
    zeta=(r-K)/r
    n,d=epsnet(K,zeta)
    print(f'untagged eps-net {lab}: d={d:.1f}, n_ind >= {n:,.0f}  (~N={n/pi:,.0f} total steps at pi=0.3)')
# REALISTIC usage: phi roots {eq,imp,all,and,not}: 5 <= k-1 failure sets cover all usage -> zeta=0, never exact
print('realistic roots (5 used) or <=7 induction-variable names: zeta_7 = 0 -> no finite N (blocking member of VS exists)')
