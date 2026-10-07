# Random test of Thm 5.6(b) at d = infinity: audit (descent loop + fallback); for every g in U C(B0)
# a maximal clean M subset of B0 with g notin M exists, and F_res(M) is empty (every x notin M: M+{x} unclean,
# and for x removed by descent, {x} alone is unclean (Lemma 2.5(d))).
import random, itertools
exec(open('prop32_random.py').read().split('viol=0; trials=0')[0])
random.seed(3)
def unclean(B,POS): return any(ref(set(B),p) is not None for p in POS)
tested=0; fails=0; fb=0
for trial in range(1500):
    POS=[]
    while len(POS)<random.randint(1,3):
        A=frozenset(rnd(2) for _ in range(random.randint(1,4))); D=frozenset(rnd(2) for _ in range(random.randint(0,2)))
        if good((A,D)): POS.append((A,D))
    # audit
    B=set(SP); removed_by_descent=set(); B0=None
    while True:
        rr=None
        for p in POS:
            r=ref(B,p)
            if r is not None: rr=(p,r); break
        if rr is None: break
        p,(j,steps)=rr; out=descend(p,j,steps)
        if out=='blocked': B0=set(B); break
        assert out!='conflict'
        n,P,c=out; S={x for x in B if any(pp==P and cc==c for pp,cc in apply(x,set(P)))}
        removed_by_descent|=S; B-=S
        for x in S:
            if not unclean({x},POS): fails+=1; print('{x} clean though removed by descent',x)
    if B0 is None: continue
    fb+=1
    subs=[frozenset(c) for k in range(1,len(B0)+1) for c in itertools.combinations(sorted(B0),k)]
    conf=[c for c in subs if unclean(c,POS)]
    mins=[c for c in conf if not any(o<c for o in conf)]
    U=set().union(*mins) if mins else set()
    cleans=[frozenset()]+[c for c in subs if c not in conf]
    maxcl=[c for c in cleans if not any(c<o for o in cleans)]
    for g in U:
        Ms=[M for M in maxcl if g not in M]
        if not Ms: fails+=1; print('no maximal clean M avoiding',g); continue
        M=Ms[0]
        for x in set(SP)-M:
            if not unclean(set(M)|{x},POS): fails+=1; print('F_res(M) nonempty',M,x)
        tested+=1
    if not set(SIGMA)<=set(B0): fails+=1
print('fallback cases',fb,'(g,M) pairs tested',tested,'failures',fails)
