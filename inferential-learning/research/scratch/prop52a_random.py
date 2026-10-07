# Random test of Prop 5.2(a) "TTL passes": A subset of Sigma u F_res(Sigma) for every Sigma clean at every depth.
import random, itertools
exec(open('prop32_random.py').read().split('viol=0; trials=0')[0])
random.seed(11)
def unclean(B,POS): return any(ref(set(B),p) is not None for p in POS)
tested=0; fails=0
for trial in range(1500):
    POS=[]
    while len(POS)<random.randint(1,3):
        A=frozenset(rnd(2) for _ in range(random.randint(1,4))); D=frozenset(rnd(2) for _ in range(random.randint(0,2)))
        if good((A,D)): POS.append((A,D))
    B=set(SP); B0=None
    while True:
        rr=None
        for p in POS:
            r=ref(B,p)
            if r is not None: rr=(p,r); break
        if rr is None: break
        p,(j,steps)=rr; out=descend(p,j,steps)
        if out=='blocked': B0=set(B); break
        n,P,c=out; B-={x for x in B if any(pp==P and cc==c for pp,cc in apply(x,set(P)))}
    if B0 is None: Aout=set(B)
    else:
        subs=[frozenset(c) for k in range(1,len(B0)+1) for c in itertools.combinations(sorted(B0),k)]
        conf=[c for c in subs if unclean(c,POS)]
        mins=[c for c in conf if not any(o<c for o in conf)]
        Aout=B0-(set().union(*mins) if mins else set())
    for k in range(0,len(SP)+1):
        for S in itertools.combinations(SP,k):
            S=set(S)
            if unclean(S,POS): continue
            for x in Aout-S:
                if unclean(S|{x},POS): fails+=1; print('fails',S,x,Aout)
            tested+=1
print('clean targets tested',tested,'failures',fails)
