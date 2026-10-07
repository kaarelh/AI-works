# Thm 5.6 'fallback is optimal' at finite d: positions A1={q,p>q,p>F}, A2={phi, F>phi}, phi=q&(q&q); practice {MP,AC}.
# Minimal refutation size (sum of symbols of distinct judgments in a derivation DAG), by exhaustive search over
# derivations built from closure steps (tiny example, so brute force over subsets of the finite closure).
import itertools
def imp(a,b): return ('>',a,b)
def size(f): return 1 if isinstance(f,str) else 1+sum(size(x) for x in f[1:])
phi=('&','q',('&','q','q'))
A1=['q',imp('p','q'),imp('p','F')]; A2=[phi,imp('F',phi)]
def steps(rules,X):
    out=[]
    for f in X:
        if isinstance(f,tuple) and f[0]=='>':
            a,b=f[1],f[2]
            if 'MP' in rules and a in X: out.append(((a,f),b))
            if 'AC' in rules and b in X: out.append(((b,f),a))
    return out
def closure(rules,ctx,cap=4):
    X=set(ctx)
    for _ in range(cap):
        new={c for (_,c) in steps(rules,X)}-X
        if not new: break
        X|=new
    return X
def min_ref(rules,ctx):
    # derivation = set of judgments containing ctx-leaves used and derived nodes, closed under being justified
    X=closure(rules,ctx)
    if 'F' not in X: return None
    best=None
    nodes=sorted(X,key=str)
    for r in range(1,len(nodes)+1):
        for S in itertools.combinations(nodes,r):
            S=set(S)
            if 'F' not in S: continue
            ok=all(f in ctx or any(set(p)<=S for (p,c) in steps(rules,S) if c==f) for f in S)
            if ok:
                sz=sum(size(f) for f in S)
                best=sz if best is None else min(best,sz)
    return best
for rules in [{'MP'},{'AC'},{'MP','AC'}]:
    print(sorted(rules),'A1:',min_ref(rules,A1),'A2:',min_ref(rules,A2))
