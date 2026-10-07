import itertools, random
random.seed(1)
NA=3; NV=8; FULL=255; NP=3; OCC=list(range(2*NP))
neg=lambda o:o^1
def rand_hyp():
    M=random.randint(0,FULL); rho={}
    for k in range(NP):
        if random.random()<0.8:
            phi=random.randint(0,FULL); rho[2*k]=phi; rho[2*k+1]=FULL^phi
    return (M,rho)
STEPS=[(frozenset(G),y) for r in range(0,3) for G in itertools.combinations(OCC,r) for y in OCC]
def conj(rho,G):
    m=FULL
    for x in G: m&=rho[x]
    return m
def valid(h,s):
    G,y=s; M,rho=h
    if not (set(G)|{y})<=rho.keys(): return False
    return (M & conj(rho,G) & ~rho[y] & FULL)==0
def rel(h): return frozenset(s for s in STEPS if valid(h,s))
def V(h):
    M,rho=h; dom=sorted(rho)
    return {tuple((x,(rho[x]>>v)&1) for x in dom) for v in range(NV) if (M>>v)&1}
def cohvals(h,R):
    M,rho=h; dom=sorted(rho); out=set()
    for bits in itertools.product([0,1],repeat=len(dom)):
        v=dict(zip(dom,bits))
        if any(v[neg(x)]!=1-v[x] for x in dom): continue
        if all(v[y]==1 for (G,y) in R if all(v[x]==1 for x in G)): out.add(tuple((x,v[x]) for x in dom))
    return out
def coh(h,A): return (h[0] & conj(h[1],A))!=0
bad={'L33i':0,'L33iii':0,'T34a':0,'T34c':0}; n=0
for t in range(1500):
    H=[rand_hyp() for _ in range(5)]
    H=[h for h in H if h[1]]
    if not H: continue
    n+=1
    R={id(h):rel(h) for h in H}
    for h in H:
        if V(h)!=cohvals(h,R[id(h)]): bad['L33i']+=1
        for r in range(0,3):
            for A in itertools.combinations(sorted(h[1]),r):
                if coh(h,A)!=any(not valid(h,(frozenset(A),y)) for y in h[1]): bad['L33iii']+=1
    for h in H:
        for h2 in H:
            if R[id(h)]==R[id(h2)] and V(h)!=V(h2): bad['T34a']+=1
    hs=H[0]; Dst=set(hs[1]); Rst=R[id(hs)]
    Ades=[A for r in range(0,3) for A in itertools.combinations(sorted(Dst),r) if coh(hs,A)]
    for h in H:
        surv = Rst<=R[id(h)]
        Vh=[dict(u) for u in V(h)]
        for u in V(hs):
            if not any(all(x in w and w[x]==b for x,b in u) for w in Vh): surv=False
        for A in Ades:
            if not set(A)<=set(h[1]) or not coh(h,A): surv=False
        inU=all((s in Rst)==(s in R[id(h)]) for s in STEPS if (set(s[0])|{s[1]})<=Dst)
        if surv!=inU: bad['T34c']+=1
print('trials',n,'failures',bad)
