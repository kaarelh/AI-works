import itertools, random
from fractions import Fraction as Fr
R={'A':(10,Fr(1,2),8),'B':(40,Fr(1,100),8),'F':(8,Fr(5,100),8)}
names=list(R)
pts={}
for k in range(4):
    for s in itertools.combinations(names,k):
        C=sum(R[r][0] for r in s); NLL=sum(R[r][1]*R[r][2] for r in R if r not in s)
        pts[frozenset(s)]=(C,NLL)
for s,p in sorted(pts.items(),key=lambda x:x[1][0]): print(sorted(s),p[0],float(p[1]))
# convex hull
def hull(P):
    P=sorted(set(P))
    def cross(o,a,b): return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
    lo=[];
    for p in P:
        while len(lo)>=2 and cross(lo[-2],lo[-1],p)<=0: lo.pop()
        lo.append(p)
    up=[]
    for p in reversed(P):
        while len(up)>=2 and cross(up[-2],up[-1],p)<=0: up.pop()
        up.append(p)
    return lo[:-1]+up[:-1]
H=hull(list(pts.values()))
print("hull vertices:",[ (sorted(s)) for s,p in pts.items() if p in H])
print("AB vertex?", pts[frozenset('AB')] in H)
# Pareto domination
ab=pts[frozenset('AB')]
print("dominators of AB:",[sorted(s) for s,p in pts.items() if p[0]<=ab[0] and p[1]<=ab[1] and p!=ab])
# exact kappa scan using breakpoints
ks=sorted(set([R[r][1]*R[r][2]/R[r][0] for r in R]))
print("kappa_r:",{r:float(R[r][1]*R[r][2]/R[r][0]) for r in R})
# random brute-force check of Prop 7.1 and Cor 7.2
rng=random.Random(0)
bad71=0;bad72=0
for trial in range(3000):
    n=rng.randint(1,5)
    rules=[(rng.randint(1,50),Fr(rng.randint(0,20),100),rng.randint(1,10),rng.random()<0.5) for _ in range(n)]
    N=rng.choice([10,100,1000])
    for lam in [Fr(rng.randint(1,2000),10) for _ in range(5)]:
        best=None;bestv=None;vals={}
        for k in range(n+1):
            for s in itertools.combinations(range(n),k):
                v=lam*sum(rules[i][0] for i in s)+N*sum(rules[i][1]*rules[i][2] for i in range(n) if i not in s)
                vals[s]=v
        m=min(vals.values()); argmins=[set(s) for s,v in vals.items() if v==m]
        pred=set(i for i in range(n) if lam*rules[i][0]<N*rules[i][1]*rules[i][2])
        ties=any(lam*rules[i][0]==N*rules[i][1]*rules[i][2] for i in range(n))
        if pred not in argmins: bad71+=1
        if not ties and len(argmins)!=1: bad71+=1
    # Cor 7.2: exists kappa>0 (strictly, no ties) s.t. MAP == valid set
    valid=set(i for i in range(n) if rules[i][3])
    rates=[rules[i][1]*rules[i][2]/rules[i][0] for i in range(n)]
    cand=sorted(set(rates+[0]))
    # test kappas: midpoints and above max
    tests=[(cand[j]+cand[j+1])/2 for j in range(len(cand)-1)]+[cand[-1]+1]
    exists=any(set(i for i in range(n) if rates[i]>k)==valid for k in tests if k>0)
    vr=[rates[i] for i in valid]; fr=[rates[i] for i in range(n) if i not in valid]
    cond=(min(vr) if vr else Fr(10**9))>(max(fr) if fr else Fr(0)) 
    if exists!=cond: bad72+=1; 
    if exists!=cond and bad72<4: print("Cor7.2 mismatch",rules,rates,exists,cond)
print("Prop7.1 violations",bad71,"Cor7.2 mismatches",bad72)
