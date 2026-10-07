import sys, itertools
n=int(sys.argv[1]); k=int(sys.argv[2])
pts=list(itertools.product([0,1],repeat=n)); m=len(pts)
idx={p:i for i,p in enumerate(pts)}
# subcubes: each coord in {0,1,*}
fam=set()
for pat in itertools.product([0,1,None],repeat=n):
    mask=0
    for i,p in enumerate(pts):
        if all(c is None or c==x for c,x in zip(pat,p)): mask|=1<<i
    fam.add(mask)
fam.add(0)
fam=list(fam)
maxav={}
for s in range(m):
    C=[c for c in fam if not (c>>s)&1]
    maxav[s]=[c for c in C if not any(c!=d and c&~d==0 for d in C)]
def covers(P,M,k):
    if k==1: return any(P&~a==0 for a in M)
    return any(covers(P&~a,M,k-1) for a in M)
memo={}
def R(P):
    if P in memo: return memo[P]
    best=0
    for s in range(m):
        if (P>>s)&1: continue
        if covers(P,maxav[s],k): best=max(best,1+R(P|1<<s))
    memo[P]=best; return best
print('n',n,'k',k,'E',R(0),'universe',m)
