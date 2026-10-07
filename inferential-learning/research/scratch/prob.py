import itertools, numpy as np
from fractions import Fraction
from scipy.optimize import linprog, milp, LinearConstraint, Bounds
def coherent(rows, p):
    V=np.array(rows,dtype=float).T; m=V.shape[1]
    A=np.vstack([V,np.ones((1,m))]); b=np.concatenate([np.array(p,float),[1.0]])
    r=linprog(np.zeros(m),A_eq=A,b_eq=b,bounds=[(0,None)]*m,method='highs'); return r.status==0
# Thm 3.4 with enlarged agenda: all 16 Boolean functions of each pair of atoms (plus single atoms)
for k in range(3,8):
    atoms=range(k); pairs=list(itertools.combinations(atoms,2))
    q=1/(k-1)
    # pair marginal: P(11)=0,P(10)=q,P(01)=q,P(00)=1-2q
    marg={(1,1):0,(1,0):q,(0,1):q,(0,0):1-2*q}
    funcs=list(itertools.product([0,1],repeat=4))  # truth table over (00,01,10,11)
    idx={(0,0):0,(0,1):1,(1,0):2,(1,1):3}
    def agenda(A):
        F=[]
        for (i,j) in itertools.combinations(A,2):
            for f in funcs:
                F.append((i,j,f))
        return F
    def row(v,F): return [f[idx[(v[i],v[j])]] for (i,j,f) in F]
    def cred(F): return [sum(marg[ab]*f[idx[ab]] for ab in marg) for (i,j,f) in F]
    F=agenda(atoms)
    allv=list(itertools.product([0,1],repeat=k))
    g=coherent([row(v,F) for v in allv],cred(F))
    loc=True
    for A in itertools.combinations(atoms,k-1):
        FA=agenda(A)
        # coherent extension check: need mu on ALL k-atom worlds reproducing FA values
        loc&=coherent([row(v,FA) for v in allv],cred(FA))
    print("k=%d enlarged agenda: global coherent=%s, every (k-1)-atom subagenda coherent=%s"%(k,g,loc))
# Thm 3.5(b): MILP min sum_Phi P - m  s.t. valid, m<=k-2, integer multiplicities in [0,B]
for k,B in [(3,12),(4,8),(5,5)]:
    atoms=list(range(k)); pairs=list(itertools.combinations(atoms,2))
    F=[('A',i) for i in atoms]+[('nA',i) for i in atoms]+[('C',p) for p in pairs]+[('nC',p) for p in pairs]
    q=Fraction(1,k-1)
    P=[q]*k+[1-q]*k+[0]*len(pairs)+[1]*len(pairs)
    allv=list(itertools.product([0,1],repeat=k))
    def t(v,f):
        typ,x=f
        if typ=='A': return v[x]
        if typ=='nA': return 1-v[x]
        if typ=='C': return v[x[0]]*v[x[1]]
        return 1-v[x[0]]*v[x[1]]
    nF=len(F)
    for mmax in [k-2,k-1]:
        # vars: n_f (nF), m
        c=np.array([float(p) for p in P]+[-1.0])
        A=[ [t(v,f) for f in F]+[-1] for v in allv]   # #true - m >=0
        cons=[LinearConstraint(np.array(A,float),0,np.inf)]
        bnds=Bounds([0]*nF+[-50],[B]*nF+[mmax])
        r=milp(c,constraints=cons,integrality=np.ones(nF+1),bounds=bnds)
        print("k=%d, m<=%d, mult<=%d: min (sum_Phi P - m) = %.6f"%(k,mmax,B,r.fun))
