import itertools, random
from fractions import Fraction as Fr
random.seed(5)
def subsets(s):
    s=list(s)
    for r in range(len(s)+1):
        for c in itertools.combinations(s,r): yield frozenset(c)
def rand_downclosed(V):
    allS=list(subsets(V))
    forb=[frozenset(random.sample(V,random.randint(0,len(V)))) for _ in range(random.randint(0,3))]
    return {S for S in allS if not any(f<=S for f in forb)}
inst=viol=0; skipped=0
for trial in range(6000):
    nV=random.randint(1,4); nE=random.randint(1,2)
    V=['v%d'%i for i in range(nV)]; E=['F%d'%i for i in range(nE)]
    D={F:rand_downclosed(V) for F in E}
    def feas(S):
        U=frozenset(x for x in S if x in V); return all(U in D[F] for F in S if F in E)
    r={x:Fr(random.randint(1,50),1000) for x in V+E}; k={x:random.randint(1,20) for x in V+E}
    rate={x:r[x]/k[x] for x in V+E}
    crit=sorted(set(rate.values()))
    cs=set(crit)
    pts=[crit[0]/2]+[(a+b)/2 for a,b in zip(crit,crit[1:])]+[crit[-1]*2]
    cs|=set(pts)
    def witnesses(F,P):
        out=[]
        for W in subsets(P):
            if not feas(W|{F}) and all(feas(W2|{F}) for W2 in subsets(W) if W2!=W): out.append(W)
        return out
    ok=True; excluded={F:True for F in E}
    for c in sorted(cs):
        nu={x:r[x]-c*k[x] for x in V+E}
        Vp=frozenset(v for v in V if nu[v]>0); Ep=[F for F in E if nu[F]>0]
        for F in Ep:
            ws=witnesses(F,Vp)
            if ws:
                if frozenset() in ws: continue
                b=min(sum(nu[v] for v in B) for B in subsets(Vp) if all(B&W for W in ws))
                if not b>sum(nu[G] for G in Ep): ok=False
        if not ok: break
        allsets=[S for S in subsets(V+E) if feas(S)]
        best=max(sum(nu[x] for x in S) for S in allsets)
        opt=[S for S in allsets if sum(nu[x] for x in S)==best]
        zero={x for x in V+E if nu[x]==0}
        for F in E:
            # excluded "up to zero ties": F not in every optimal set, or F only in via zero tie
            if all(F in S for S in opt) and nu[F]>0: excluded[F]=False
            # strictly: some optimal set contains F with nu_F>0
            if any(F in S for S in opt) and nu[F]>0: excluded[F]=False
    if not ok: skipped+=1; continue
    inst+=1
    for F in E:
        ws=witnesses(F,V)
        pred=any(all(rate[w]>=rate[F] for w in W) for W in ws)
        if pred!=excluded[F]:
            viol+=1
            if viol<4: print("VIOL",F,rate,ws,excluded[F],pred)
print("instances",inst,"skipped(no VD)",skipped,"violations",viol)
