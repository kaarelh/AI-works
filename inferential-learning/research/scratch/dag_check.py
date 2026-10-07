# DAG (distinct-judgment) minimal refutation sizes for the depth_nonmono.py positions, to confirm 9 and 29.
import itertools, sys
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T7-checks')
def imp(a,b): return ('>',a,b)
def size(f): return 1 if isinstance(f,str) else 1+sum(size(x) for x in f[1:])
r=('&',('&','a','b'),('&','c','d')); s=('|',('|','e','f'),('|','g','h'))
P1=(['q',imp('p','q'),imp('p','F')],['F']); P2=([r,imp(s,r)],[s,'F'])
def steps(rules,X):
    out=[]
    for f in X:
        if isinstance(f,tuple) and f[0]=='>':
            a,b=f[1],f[2]
            if 'MP' in rules and a in X: out.append(((a,f),b))
            if 'AC' in rules and b in X: out.append(((b,f),a))
    return out
def closure(rules,ctx,cap=6):
    X=set(ctx)
    for _ in range(cap):
        new={c for (_,c) in steps(rules,X)}-X
        if not new: break
        X|=new
    return X
def wf(rules,ctx,S):
    J={f for f in S if f in ctx}; ch=True
    while ch:
        ch=False
        for (p,c) in steps(rules,J):
            if c in S and c not in J: J.add(c); ch=True
    return J==S
def min_ref(rules,pos):
    ctx,bad=pos; X=closure(rules,ctx); best=None
    nodes=sorted(X,key=str)
    for k in range(1,len(nodes)+1):
        for S in itertools.combinations(nodes,k):
            S=set(S)
            if any(b in S for b in bad) and wf(rules,ctx,S) and not any(b in ctx for b in bad if b in S):
                z=sum(size(f) for f in S); best=z if best is None else min(best,z)
    return best
for B in (['MP'],['AC'],['MP','AC']):
    print(B, 'P1:',min_ref(B,P1),'P2:',min_ref(B,P2))
