# 2-union elasticity of the flats of the graphic matroid M(K_v) (intersection-closed, height v-1)
import itertools, sys
from functools import lru_cache
def set_partitions(s):
    s=list(s)
    if not s: yield []; return
    first=s[0]
    for p in set_partitions(s[1:]):
        for i in range(len(p)):
            yield p[:i]+[[first]+p[i]]+p[i+1:]
        yield [[first]]+p
def run(v,k):
    E=list(itertools.combinations(range(v),2)); m=len(E); idx={e:i for i,e in enumerate(E)}
    fam=set()
    for p in set_partitions(range(v)):
        mask=0
        for B in p:
            for e in itertools.combinations(sorted(B),2): mask|=1<<idx[e]
        fam.add(mask)
    fam=list(fam)
    # height
    fs=sorted(fam,key=lambda x:bin(x).count('1')); H={}
    for c in fs:
        H[c]=0
        for d in fs:
            if d!=c and d&~c==0: H[c]=max(H[c],H[d]+1)
    h=max(H.values())
    maxav={}
    for s in range(m):
        C=[c for c in fam if not (c>>s)&1]
        maxav[s]=[c for c in C if not any(c!=d and c&~d==0 for d in C)]
    def covers(P,M,k):
        if P==0: return True
        if k==0: return False
        return any(covers(P&~a,M,k-1) for a in M if P&a)
    memo={}
    def R(P):
        if P in memo: return memo[P]
        best=0
        for s in range(m):
            if (P>>s)&1: continue
            if covers(P,maxav[s],k): best=max(best,1+R(P|1<<s))
        memo[P]=best; return best
    from math import comb
    print('K_%d: points %d, height %d, k=%d, elasticity %d, conj C(h+k-1,k)=%d'%(v,m,h,k,R(0),comb(h+k-1,k)),flush=True)
for v in [3,4,5,6]:
    run(v,2)
run(4,3); run(5,3)
