import random, sys, itertools
m=int(sys.argv[1]); iters=int(sys.argv[2]); seed=int(sys.argv[3]); HT=int(sys.argv[4])
rng=random.Random(seed)
U=(1<<m)-1
def closure_family(gens):
    fam={U}
    for g in gens: fam.add(g)
    changed=True
    while changed:
        changed=False
        L=list(fam)
        for a in L:
            for b in L:
                c=a&b
                if c not in fam: fam.add(c); changed=True
    return fam
def height(fam):
    fam=sorted(fam,key=lambda x:bin(x).count('1'))
    H={}
    for c in fam:
        H[c]=0
        for d in fam:
            if d!=c and d & ~c==0:
                H[c]=max(H[c],H[d]+1)
    return max(H.values())
def E2(fam):
    maxs_cache={}
    def maxavoid(s):
        if s in maxs_cache: return maxs_cache[s]
        C=[c for c in fam if not (c>>s)&1]
        M=[c for c in C if not any(c!=d and c & ~d==0 for d in C)]
        maxs_cache[s]=M; return M
    memo={}
    def R(P):
        if P in memo: return memo[P]
        best=0
        for s in range(m):
            if (P>>s)&1: continue
            M=maxavoid(s)
            if any(P & ~(a|b)==0 for a in M for b in M):
                best=max(best,1+R(P|1<<s))
        memo[P]=best; return best
    return R(0)

cur=[rng.randrange(1,U) for _ in range(6)]
def score(g):
    fam=closure_family(g); h=height(fam)
    if h>HT: return -1,h
    return E2(fam),h
cs,ch=score(cur); bestv=cs
for it in range(iters):
    g=list(cur)
    r=rng.random()
    if r<0.4 and len(g)>1: g.pop(rng.randrange(len(g)))
    elif r<0.7: g.append(rng.randrange(1,U))
    else: g[rng.randrange(len(g))]^=1<<rng.randrange(m)
    s_,h_=score(g)
    if s_>=cs or rng.random()<0.02:
        cur,cs=g,s_
        if cs>bestv:
            bestv=cs; print('E2',cs,'h',h_,[bin(x) for x in sorted(closure_family(cur))],flush=True)
print('best',bestv)
