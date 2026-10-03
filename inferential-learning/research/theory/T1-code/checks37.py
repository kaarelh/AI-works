# Added during verification (referee script): Thm 3.7(i) sequences and Prop 3.5 Bell(n) forced escalations.
import sys, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import *
# Thm 3.7(i): verify the explicit sequence is elastic for H_k (each step escapes the k-union witness R')
def gpow(a): 
    t=('c',)
    for _ in range(a): t=('g',t)
    return t
def check_37i(k,n):
    pts=list(itertools.product(range(n+1),repeat=k))
    pts.sort(key=lambda a:-sum(a))
    seq=[('p',)+tuple(gpow(x) for x in a) for a in pts]
    ok=True
    for i,a in enumerate(pts):
        # witness R' = union_j inst(p(x1,..,g^{a_j+1}(x_j),..,xk))
        schemas=[]
        for j in range(k):
            args=[('?','x%d'%l) for l in range(k)]
            t=('?','x%d'%j)
            for _ in range(a[j]+1): t=('g',t)
            args[j]=t
            schemas.append(('p',)+tuple(args))
        inR=lambda s: any(is_instance(s,sc) for sc in schemas)
        if inR(seq[i]) or not all(inR(s) for s in seq[:i]): ok=False; print('fail',k,n,a)
    size=max(size_(s) for s in seq)
    return ok,len(seq),size
def size_(t): return 1+sum(size_(a) for a in t[1:])
for k,n in [(2,1),(2,2),(2,3),(3,1),(3,2)]:
    ok,m,sz=check_37i(k,n)
    N=sz
    print('k',k,'n',n,'ok',ok,'len',m,'max size',sz,'floor((N-1)/k)^k with N=maxsize:',((N-1)//k)**k)
# Prop 3.5: brute force n=3 : VS over all schemas f(t1..tn), t_i in {a,b1..bn,vars} plus x
def set_partitions(s):
    s=list(s)
    if not s: yield []; return
    first=s[0]
    for p in set_partitions(s[1:]):
        for i in range(len(p)):
            yield p[:i]+[[first]+p[i]]+p[i+1:]
        yield [[first]]+p
for n in [2,3,4]:
    consts=['a']+['b%d'%i for i in range(1,n+1)]
    # enumerate schemas: each arg a constant or a variable (canonical var pattern)
    schemas=[('?','X')]
    for choice in itertools.product(consts+['V%d'%i for i in range(n)],repeat=n):
        schemas.append(('f',)+tuple(('?',c) if c.startswith('V') else (c,) for c in choice))
    P0=[('f',)+tuple(('a',) for _ in range(n))]
    parts=list(set_partitions(range(n)))
    # linear extension of refinement, finest first: sort by number of blocks desc
    parts.sort(key=lambda p:-len(p))
    def s_of(p):
        blk={}
        for bi,B in enumerate(sorted(p,key=min)):
            for j in B: blk[j]=bi+1
        return ('f',)+tuple(('b%d'%blk[j],) for j in range(n))
    neg=[]; esc=0
    for p in parts:
        q=s_of(p)
        VS=[sc for sc in schemas if all(is_instance(x,sc) for x in P0) and not any(is_instance(x,sc) for x in neg)]
        inUnion=any(is_instance(q,sc) for sc in VS)
        inInter=all(is_instance(q,sc) for sc in VS)
        assert not inInter
        if inUnion: esc+=1
        neg.append(q)
    from math import comb
    print('Prop3.5 n',n,'partitions',len(parts),'forced escalations',esc)
