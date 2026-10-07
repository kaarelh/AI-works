import itertools
import numpy as np
from fractions import Fraction
from scipy.optimize import milp, LinearConstraint, Bounds
def run(k,mmax,U):
    atoms=range(k); pairs=list(itertools.combinations(atoms,2)); worlds=list(itertools.product([0,1],repeat=k))
    cols=[];P=[];names=[]
    for i in atoms:
        cols.append([w[i] for w in worlds]);P.append(Fraction(1,k-1));names.append(f"A{i}")
        cols.append([1-w[i] for w in worlds]);P.append(1-Fraction(1,k-1));names.append(f"~A{i}")
    for (i,j) in pairs:
        cols.append([w[i]*w[j] for w in worlds]);P.append(Fraction(0));names.append(f"A{i}A{j}")
        cols.append([1-w[i]*w[j] for w in worlds]);P.append(Fraction(1));names.append(f"~A{i}A{j}")
    F=len(cols);Tm=np.array(cols).T
    c=np.array([float(p) for p in P]+[-1.0])
    A=np.hstack([Tm,-np.ones((len(worlds),1))])
    r=milp(c,constraints=LinearConstraint(A,lb=0,ub=np.inf),integrality=np.ones(F+1),
           bounds=Bounds(lb=np.r_[np.zeros(F),-50],ub=np.r_[np.full(F,U),mmax]),options={"mip_rel_gap":0})
    x=np.round(r.x).astype(int)
    assert all(int(Tm[w]@x[:F])>=x[F] for w in range(len(worlds)))
    val=sum(Fraction(int(x[f]))*P[f] for f in range(F))-int(x[F])
    sup=[(names[f],int(x[f])) for f in range(F) if x[f]]
    return val,int(x[F]),sup
for k in (3,4,5,6):
    for U in (8,25):
        v1,_,_=run(k,k-2,U); v2,m2,sup=run(k,k-1,U)
        print(f"k={k} U={U}: min(m<=k-2)={v1}  min(m<=k-1)={v2} at m={m2}; maxmult in witness={max(c for _,c in sup)}")
