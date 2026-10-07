import itertools, random, math
from functools import lru_cache
# Steps universe U={0..u-1}; hypotheses = frozensets (bitmasks). Worst-case adversary: may present any detection
# P subset of R_hat with P not subset of some surviving R (so a consistent target remains), and any OH coalition choice.
def subsets(mask):
    s=mask
    while True:
        yield s
        if s==0: break
        s=(s-1)&mask
def maxdet(H,w):
    H=tuple(H)
    @lru_cache(None)
    def f(VS):  # VS bitmask over indices of H; returns max number of detections (adversary chooses S and P)
        idx=[i for i in range(len(H)) if VS>>i&1]
        tot=sum(w[i] for i in idx)
        best=0
        for r in range(1,len(idx)+1):
            for S in itertools.combinations(idx,r):
                if sum(w[i] for i in S) < tot/2 - 1e-12: continue
                Rhat=(1<<30)-1
                for i in S: Rhat&=H[i]
                for P in subsets(Rhat):
                    dele=[i for i in idx if (H[i]&P)==P]
                    rem=VS
                    for i in dele: rem&=~(1<<i)
                    if rem==0: continue  # no consistent target left -> illegal
                    best=max(best,1+f(rem))
        return best
    return f((1<<len(H))-1)
random.seed(1)
viol=0
for trial in range(300):
    u=random.randint(2,4); n=random.randint(2,5)
    H=list({random.randrange(1<<u) for _ in range(n)})
    if len(H)<2: continue
    w=[random.random() for _ in H]; s=sum(w); w=[x/s for x in w]
    d=maxdet(H,w)
    # bound per target: target survives -> D <= log2(1/w(R*)); adversary chooses target, so compare with log2(1/min w) over ... 
    # stronger: check for each possible final target. Simplify: D <= log2(1/min_i w_i)
    if d > math.log2(1/min(w))+1e-9: viol+=1; print("VIOL",H,w,d)
print("Thm2.2 random checks done, violations:",viol)

# Prop 2.3 equivalence check: for random VS (finite), random Rhat, random weights:
# (1) every finite P subset Rhat deletes >= half ; (2) exists S with w(S)>=half and Rhat subset of cap S
bad=0
for trial in range(3000):
    u=random.randint(1,4); n=random.randint(1,5)
    H=[random.randrange(1<<u) for _ in range(n)]
    w=[random.random() for _ in H]; tot=sum(w)
    Rhat=random.randrange(1<<u)
    c1=all(sum(w[i] for i in range(n) if (H[i]&P)==P) >= tot/2-1e-12 for P in subsets(Rhat))
    c2=any(sum(w[i] for i in S)>=tot/2-1e-12 and all((H[i]&Rhat)==Rhat for i in S)
           for r in range(1,n+1) for S in itertools.combinations(range(n),r))
    if c1!=c2: bad+=1; print("MISMATCH",H,w,Rhat,c1,c2)
print("Prop2.3 mismatches:",bad)
