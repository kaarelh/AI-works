import itertools, random, math
from functools import lru_cache
def subsets(mask):
    s=mask
    while True:
        yield s
        if s==0: break
        s=(s-1)&mask
def maxdet_target(H,w,t):
    @lru_cache(None)
    def f(VS):
        idx=[i for i in range(len(H)) if VS>>i&1]
        tot=sum(w[i] for i in idx); best=0
        for r in range(1,len(idx)+1):
            for S in itertools.combinations(idx,r):
                if sum(w[i] for i in S) < tot/2-1e-12: continue
                Rhat=(1<<30)-1
                for i in S: Rhat&=H[i]
                for P in subsets(Rhat):
                    if (H[t]&P)==P: continue   # Lemma 2.1: detection steps not all in target
                    rem=VS
                    for i in idx:
                        if (H[i]&P)==P: rem&=~(1<<i)
                    best=max(best,1+f(rem))
        return best
    return f((1<<len(H))-1)
random.seed(7); viol=0; tight=0; cnt=0
for trial in range(400):
    u=random.randint(2,4); n=random.randint(2,6)
    H=list({random.randrange(1<<u) for _ in range(n)})
    if len(H)<2: continue
    w=[random.random()**2 for _ in H]; s=sum(w); w=[x/s for x in w]
    for t in range(len(H)):
        d=maxdet_target(tuple(H),tuple(w),t); cnt+=1
        b=math.log2(1/w[t])
        if d>b+1e-9: viol+=1; print("VIOL",H,w,t,d,b)
        if d==math.floor(b+1e-9): tight+=1
print("cases",cnt,"violations",viol,"tight",tight)
