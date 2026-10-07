import sys, random
from terms import *
from elast import universe, make_checker, escapes
sig=eval(sys.argv[1]); N=int(sys.argv[2]); k=int(sys.argv[3]); trials=int(sys.argv[4])
U=universe(sig,N); n=len(U)
lgg_mask=make_checker(U)
best=0;bestseq=None
random.seed(1)
for tr in range(trials):
    P=[]; Pm=0
    order=list(range(n))
    while True:
        cands=[s for s in range(n) if not Pm>>s&1 and escapes(P,s,k,lgg_mask)]
        if not cands: break
        # heuristic: prefer largest size with random tie-break, with randomness
        if random.random()<0.7:
            mx=max(size(U[s]) for s in cands)
            cands=[s for s in cands if size(U[s])>=mx-random.randint(0,1)]
        s=random.choice(cands)
        P.append(s); Pm|=1<<s
    if len(P)>best:
        best=len(P); bestseq=[show(U[s]) for s in P]
        print(tr,best,flush=True)
print('|U|',n,'best',best)
print(bestseq)
