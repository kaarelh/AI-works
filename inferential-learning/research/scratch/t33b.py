from math import log2, log
import itertools
# Does the STATED Delta_0 per-region term survive if one uses the exact bounds
#   K-part  c*(d - s(t))^+ , s(t)=2t+2log2(t+1)   and   R-part pi*(1-log2(1+2^{1-t}))  (t>=1)
# i.e. is  min_t phi(t) >= min(cd,pi) - 4c - pi*2^{1-d/4} ?
def s(t): return 2*t+2*log2(t+1)
worst=0; worst_case=None
for d in list(range(1,64))+[80,100,200,400]:
    for pi in [1e-3,1e-2,0.05,0.1,0.3,0.5,1.0]:
        for e in range(-60,10):
            c=2**(e/4)
            target=min(c*d,pi)-4*c-pi*2**(1-d/4)
            m=c*d
            for t in range(1,2*d+20):
                v=c*max(0,d-s(t))+pi*(1-log2(1+2**(1-t)))
                m=min(m,v)
            if m<target-1e-12:
                gap=target-m
                if gap>worst: worst=gap; worst_case=(d,pi,c,m,target)
print("exact-s(t) route: worst violation of stated per-region bound:",worst,worst_case)
# And with the proof's own route s(t)<=4t (weaker K-bound) but exact R-bound:
worst=0; wc=None
for d in list(range(1,64))+[80,100,200]:
    for pi in [1e-3,1e-2,0.1,0.5,1.0]:
        for e in range(-60,10):
            c=2**(e/4)
            target=min(c*d,pi)-4*c-pi*2**(1-d/4)
            m=c*d
            for t in range(1,2*d+20):
                v=c*max(0,d-4*t)+pi*(1-log2(1+2**(1-t)))
                m=min(m,v)
            if m<target-1e-12 and target-m>worst: worst=target-m; wc=(d,pi,c,m,target)
print("proof route (s<=4t): worst violation:",worst,wc)
