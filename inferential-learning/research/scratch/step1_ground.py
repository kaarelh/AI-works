# Thm 4.1 Step 1 (noisy mode), all tags ground rules, c = max c_i = 0 (T1 Thm 5.3 convention, as in T7 §1.2).
# Claimed: Pr(G^c) <= sum_i (1+c_i) e^{-2N Delta^2} <= (1+c) K e^{-2N Delta^2} <= delta.
# A ground tag has TWO failure events (invalid count > e_i ; valid count <= e_i), so the union bound is 2K e^{..}.
# Exact per-tag failure (multinomial: invalid, valid, other-tag), compare with delta.
import math
from math import comb
def pmf_trinom(N,pa,pb):
    # returns dict over (na,nb)
    pass
worst=0
for K in (1,2,3):
  for a in (0.05,0.1,0.2,0.3,0.4):
    for delta in (0.9,0.5,0.2,0.05):
      pi=1/K; alpha=pi*a; beta=pi*(1-a); Delta=(beta-alpha)/2
      N=math.ceil(math.log(K/delta)/(2*Delta**2)); e=math.floor((alpha+Delta)*N)
      if N>3000: continue
      # per-tag exact failure: P(inv>e or val<=e), inv,val from trinomial(N; alpha,beta,1-pi)
      fail=0.0
      lgN=math.lgamma(N+1)
      for ni in range(N+1):
        for nv in range(N+1-ni):
          if ni>e or nv<=e:
            no=N-ni-nv
            lp=lgN-math.lgamma(ni+1)-math.lgamma(nv+1)-math.lgamma(no+1)
            lp+= (ni*math.log(alpha) if ni else 0)+(nv*math.log(beta) if nv else 0)+((no*math.log(1-pi)) if no else 0) if pi<1 else (ni*math.log(alpha) if ni else 0)+(nv*math.log(beta) if nv else 0)
            if pi==1 and no>0: continue
            fail+=math.exp(lp)
      tot=min(1,K*fail)  # union over tags (upper bound on Pr(G^c)); independent-ish
      claimed=K*math.exp(-2*N*Delta**2)
      worst=max(worst,tot/delta)
      print('K=%d a=%.2f delta=%.2f N=%4d e=%3d  per-tag fail=%.4f  K*fail=%.4f  claimed bound (1+0)K e^-2NDelta^2=%.4f  correct union bound 2K e^..=%.4f'%(K,a,delta,N,e,fail,tot,claimed,2*claimed))
print('max (K*fail)/delta =',worst)
