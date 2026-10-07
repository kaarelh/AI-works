from math import log2, log, comb, sqrt
import itertools, random
import numpy as np
def H(p): return 0 if p in (0,1) else -(p*log2(p)+(1-p)*log2(1-p))
# 1. exact first-term crossover 1-log2(1+2p) = H(p)
lo,hi=0.01,0.3
for _ in range(100):
    m=(lo+hi)/2
    if 1-log2(1+2*m)>H(m): lo=m
    else: hi=m
print("exact first-term crossover p =",lo, " linearized 0.14215")
for p in [0.142,0.15,0.155,0.16]:
    print(p, 1-log2(1+2*p), H(p))
# 2. Hoeffding w/o replacement counting check, exact small n
random.seed(1)
worst=0
for trial in range(300):
    n=random.choice([12,14,16]); m=random.randint(1,n//4)
    sig=[random.uniform(-1,1) if random.random()<0.7 else random.choice([-1,1]) for _ in range(n)]
    mu=sum(sig)/n
    devs=[abs(sum(sig[i] for i in S)/m-mu) for S in itertools.combinations(range(n),m)]
    tot=len(devs)
    for eta in [0.05,0.1,0.2,0.4,0.8,1.2,1.6]:
        cnt=sum(1 for d in devs if d>=eta)
        bound=2*np.exp(-m*eta**2/2)*tot
        if cnt>bound+1e-9: print("VIOL",n,m,eta,cnt,bound)
        worst=max(worst,cnt/bound if bound>0 else 0)
print("Hoeffding w/o replacement: max count/bound =",worst)
