# Hill-climb for counterexamples to Conj 3.8 (k=2): intersection-closed family of height h with 2-union elasticity > C(h+1,2)
import random, sys, itertools
from math import comb
m=int(sys.argv[1]); HT=int(sys.argv[2]); iters=int(sys.argv[3]); seed=int(sys.argv[4]); init=sys.argv[5] if len(sys.argv)>5 else 'rand'
rng=random.Random(seed); U=(1<<m)-1
def closure_family(gens):
    fam={U}|set(gens); frontier=list(fam)
    while frontier:
        new=[]
        L=list(fam)
        for a in frontier:
            for b in L:
                c=a&b
                if c not in fam: fam.add(c); new.append(c)
        frontier=new
    return fam
def height(fam):
    fs=sorted(fam,key=lambda x:bin(x).count('1')); H={}
    for c in fs:
        best=0
        for d in fs:
            if d!=c and d&~c==0:
                v=H[d]+1
                if v>best: best=v
        H[c]=best
    return H[U]
def E2(fam):
    maxav={}
    for s in range(m):
        C=[c for c in fam if not (c>>s)&1]
        maxav[s]=[c for c in C if not any(c!=d and c&~d==0 for d in C)]
    memo={}
    def R(P):
        if P in memo: return memo[P]
        best=0
        for s in range(m):
            if (P>>s)&1: continue
            M=maxav[s]
            if any(P&~(a|b)==0 for a in M for b in M):
                v=1+R(P|1<<s)
                if v>best: best=v
                if best==m-bin(P).count('1'): break
        memo[P]=best; return best
    return R(0)
def score(g):
    fam=closure_family(g); h=height(fam)
    if h>HT: return -1,h
    return E2(fam),h
# seed: K_t structure on pairs, plus extra points
if init=='K':
    t=HT+1
    pairs=list(itertools.combinations(range(t),2))
    assert len(pairs)<=m
    gens=[]
    for i in range(t):
        g=0
        for j,p in enumerate(pairs):
            if i not in p: g|=1<<j
        # extra points (indices >= len(pairs)) put randomly
        for x in range(len(pairs),m):
            if rng.random()<0.5: g|=1<<x
        gens.append(g)
    cur=gens
else:
    cur=[rng.randrange(1,U) for _ in range(rng.randint(3,8))]
cs,ch=score(cur); bestv=cs; print('init',cs,ch,flush=True)
for it in range(iters):
    g=list(cur); r=rng.random()
    if r<0.25 and len(g)>1: g.pop(rng.randrange(len(g)))
    elif r<0.5: g.append(rng.randrange(1,U))
    elif r<0.75: g[rng.randrange(len(g))]^=1<<rng.randrange(m)
    else:
        i=rng.randrange(len(g)); g[i]=g[i]&rng.randrange(1,U) | (rng.randrange(1,U)&rng.randrange(1,U))
    s_,h_=score(g)
    if s_>=cs or rng.random()<0.03:
        cur,cs=g,s_
        if cs>bestv:
            bestv=cs; print('E2',cs,'h',h_,'conj',comb(h_+1,2),flush=True)
            if cs>comb(h_+1,2): print('COUNTEREXAMPLE',[bin(x) for x in sorted(closure_family(cur))]); break
print('best',bestv)
