import itertools, random
from fractions import Fraction as Fr
random.seed(3)
def subsets(s):
    s=list(s)
    for r in range(len(s)+1):
        for c in itertools.combinations(s,r): yield frozenset(c)
def rand_downclosed(V):
    # generate random down-closed family on V via random maximal "forbidden" minimal sets
    allS=list(subsets(V))
    forb=[frozenset(random.sample(V,random.randint(0,len(V)))) for _ in range(random.randint(0,3))]
    return {S for S in allS if not any(f<=S for f in forb)}
stats=dict(inst=0,thm=0,cor=0,p53=0,p53inst=0,p54=0,p54inst=0)
for trial in range(40000):
    nV=random.randint(1,4); nE=random.randint(1,3)
    V=['v%d'%i for i in range(nV)]; E=['F%d'%i for i in range(nE)]
    D={F:rand_downclosed(V) for F in E}
    def feas(S):
        U=frozenset(x for x in S if x in V); Ep=[x for x in S if x in E]
        return all(U in D[F] for F in Ep)
    rate={}; k={}; r={}
    for x in V+E:
        k[x]=random.randint(1,20); 
        r[x]=random.choice([random.uniform(0,0.05), round(random.uniform(0,0.05),2)])
        rate[x]=r[x]/k[x]
    def analyze(c):
        nu={x:r[x]-c*k[x] for x in V+E}
        Vp=frozenset(v for v in V if nu[v]>1e-15); Ep=[F for F in E if nu[F]>1e-15]
        zero={x for x in V+E if abs(nu[x])<=1e-15}
        def witnesses_in(F,P):
            P=list(P); ws=[]
            for W in subsets(P):
                if not feas(W|{F}) and all(feas(W2|{F}) for W2 in subsets(W) if W2!=W): ws.append(W)
            return ws
        vd=True; beta={}
        for F in Ep:
            ws=witnesses_in(F,Vp)
            if ws:
                b=min((sum(nu[v] for v in B) for B in subsets(Vp) if all(B&W for W in ws)),default=float('inf'))
                beta[F]=b
                if not b>sum(nu[G] for G in Ep): vd=False
        allsets=[S for S in subsets(V+E) if feas(S)]
        best=max(sum(nu[x] for x in S) for S in allsets)
        opt=[S for S in allsets if sum(nu[x] for x in S)>=best-1e-12]
        Sstar=Vp|frozenset(F for F in Ep if feas(Vp|{F}))
        return nu,Vp,Ep,zero,vd,beta,opt,Sstar,allsets,best,witnesses_in
    c=random.choice([random.uniform(1e-4,5e-3), random.choice([rate[x] for x in V+E])])
    nu,Vp,Ep,zero,vd,beta,opt,Sstar,allsets,best,wit=analyze(c)
    # Thm 5.2
    if vd:
        stats['inst']+=1
        pred={S for S in allsets if Sstar<=S and (S-Sstar)<=zero}
        if not feas(Sstar) or set(opt)!=pred:
            stats['thm']+=1; 
            if stats['thm']<3: print("THM52 VIOL",V,E,c,nu,opt,pred)
        # Cor 5.2a
        surv=[F for F in E if feas(frozenset(V)|{F})]
        lhs = all(frozenset(V)<=S and not (S&set(E)) for S in opt)
        rhs = (max([rate[F] for F in surv],default=-1)<c) and (c<min(rate[v] for v in V))
        if lhs!=rhs:
            stats['cor']+=1
            if stats['cor']<3: print("COR VIOL",c,rate,surv,opt,[S for S in allsets])
    # Prop 5.3
    for F in Ep:
        ws=wit(F,Vp)
        if not ws: continue
        Bs=[B for B in subsets(Vp) if all(B&W for W in ws)]
        if not Bs: continue
        B=min(Bs,key=lambda B:sum(nu[v] for v in B)); b=sum(nu[v] for v in B)
        if b<nu[F]-1e-12:
            stats['p53inst']+=1
            clean=Vp|frozenset(G for G in Ep if feas(Vp|{G}))
            Sp=(Vp-B)|{F}|(clean&set(E))
            val=lambda S:sum(nu[x] for x in S)
            if not feas(Sp) or abs(val(Sp)-(val(clean)+nu[F]-b))>1e-12 or val(clean)>=best-1e-12:
                stats['p53']+=1; print("P53 VIOL")
print(stats)
