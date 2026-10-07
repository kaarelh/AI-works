# Thm 3.1 checks: (a) complementary-pair agendas: coherence (LP) <-> all valid counting sequents (bounded mult.) satisfied
# (b) non-complement-closed agenda: counting sequents cannot characterize coherence (scope paragraph caveat)
import itertools, random
import numpy as np
from scipy.optimize import linprog
from fractions import Fraction
rng=random.Random(1)
def worlds(na): return list(itertools.product([0,1],repeat=na))
def coherent(cols,P):
    # cols: list of truth vectors over worlds; P vector; LP feasibility mu>=0 sum 1, sum mu v = P
    W=len(cols[0]); A=np.array(cols,dtype=float); 
    Aeq=np.vstack([A,np.ones((1,W))]); beq=np.concatenate([np.array(P,float),[1.0]])
    r=linprog(np.zeros(W),A_eq=Aeq,b_eq=beq,bounds=[(0,None)]*W,method='highs')
    return r.status==0
def min_slack(cols,P,U):
    # min over multisets with mult<=U of sum_Phi P - m(Phi) where m = min_v #true  (max valid threshold)
    F=len(cols); W=len(cols[0]); best=None; arg=None
    for mult in itertools.product(range(U+1),repeat=F):
        m=min(sum(mult[f]*cols[f][w] for f in range(F)) for w in range(W))
        s=sum(mult[f]*P[f] for f in range(F))-m
        if best is None or s<best: best=s; arg=mult
    return best,arg
na=2; Ws=worlds(na)
# all 16 truth functions over 2 atoms as formulas
tfs=list(itertools.product([0,1],repeat=len(Ws)))
mismatch=0; tested=0; inc=0
for trial in range(300):
    base=rng.sample(tfs,3)
    cols=[]; 
    for f in base:
        cols.append(list(f)); cols.append([1-x for x in f])
    # random negation-coherent P
    P=[]
    for i in range(3):
        a=Fraction(rng.randint(0,6),6); P+= [a,1-a]
    coh=coherent(cols,[float(x) for x in P])
    best,arg=min_slack(cols,P,3)
    tested+=1; inc+= (not coh)
    if coh and best<0: mismatch+=1; print("coherent but violated",base,P,arg)
    if (not coh) and best>=0: mismatch+=1; print("incoherent but no violated sequent with mult<=3",base,P)
print("(a) complementary-pair agendas: tested",tested,"incoherent",inc,"mismatches",mismatch)
# (b) agenda {p, p&q} without complements
Ws=worlds(2); p=[w[0] for w in Ws]; pq=[w[0]*w[1] for w in Ws]
cols=[p,pq]; P=[Fraction(0),Fraction(1)]
print("(b) F={p,p&q}, P=(0,1): coherent?",coherent(cols,[0.,1.]))
best,arg=min_slack(cols,P,6)
print("    min over all counting sequents (mult<=6) of sum P - threshold:",best,"(>=0 means none violated)")
# any valid counting sequent here has m <= 0 since all-false world makes nothing true
