# Independent re-check of Thm 5.6(c): minimal refutation sizes (distinct-judgment / DAG size),
# audit under BOTH tie-breaking rules, admissible targets, and soundness of "assert R_MP".
import itertools
def imp(a,b): return ('>',a,b)
def sz(f): return 1 if isinstance(f,str) else 1+sum(sz(x) for x in f[1:])
phi=('&','q',('&','q','q'))
POS={'A1':(frozenset(['q',imp('p','q'),imp('p','F')]),frozenset()),
     'A2':(frozenset([phi,imp('F',phi)]),frozenset())}
def inst(rule,X):
    out=[]
    for f in X:
        if isinstance(f,tuple) and f[0]=='>':
            a,b=f[1],f[2]
            if rule=='MP' and a in X: out.append(((a,f),b))
            if rule=='AC' and b in X: out.append(((b,f),a))
    return out
def closure(B,A):
    X=set(A)
    while True:
        new={c for r in B for (_,c) in inst(r,X)}-X
        if not new: return X
        X|=new
def refs(B,pname):
    """enumerate all well-founded derivations as (set of judgments, producing step per non-leaf),
       return list of (size, unblocked?, steps) of refutations (conclusion F or denied)"""
    A,D=POS[pname]; X=closure(B,A); res=[]
    nodes=sorted(X,key=str)
    for r in range(1,len(nodes)+1):
        for S in itertools.combinations(nodes,r):
            S=set(S)
            if not ('F' in S or S&D): continue
            # well-founded: build from leaves in A
            J=set(S&A); used=[]
            ch=True
            while ch:
                ch=False
                for rule in B:
                    for (p,c) in inst(rule,J):
                        if c in S and c not in J: J.add(c); used.append((rule,p,c)); ch=True
            if J!=S: continue
            concl=[c for c in S if c=='F' or c in D]
            for c in concl:
                # descent (no trusted steps, no world): blocked unless the producing step has all premises in A
                st=[u for u in used if u[2]==c][0] if c not in A else None
                unb = st is not None and all(x in A for x in st[1])
                res.append((sum(sz(f) for f in S),unb,used))
    return res
def minsize(B):
    best=None
    for pn in POS:
        for (s,u,_) in refs(B,pn):
            best=s if best is None else min(best,s)
    return best
subs=[frozenset(c) for k in (1,2) for c in itertools.combinations(['AC','MP'],k)]
ms={B:minsize(B) for B in subs}
print({tuple(sorted(B)):v for B,v in ms.items()})
def unblocked_min(B):
    best=None
    for pn in POS:
        for (s,u,_) in refs(B,pn):
            if u: best=s if best is None else min(best,s)
    return best
print('min unblocked refutation sizes:',{tuple(sorted(B)):unblocked_min(B) for B in subs})
for d in [8,9,12,13,20]:
    conf=[B for B in subs if ms[B] is not None and ms[B]<=d]
    mins=[B for B in conf if not any(o<B for o in conf)]
    # default rule: smallest refutation of {MP,AC}: size 9 blocked when d>=9
    A_fallback=set(['AC','MP'])-set().union(*mins) if mins else {'AC','MP'}
    # prefer-unblocked: if unblocked of size<=d exists, descend (removes AC), then re-query {MP}
    ub=unblocked_min(frozenset(['AC','MP']))
    if ms[frozenset(['AC','MP'])] is None or ms[frozenset(['AC','MP'])]>d: A_pu={'AC','MP'}
    elif ub is not None and ub<=d: A_pu={'MP'}
    else: A_pu=A_fallback
    print('d=%2d mins=%s  A(default)=%s  A(prefer-unblocked)=%s'%(d,[sorted(m) for m in mins],sorted(A_fallback),sorted(A_pu)))
print('clean-at-every-depth subsets:',[sorted(B) for B in [frozenset()]+subs if not B or ms[B] is None])
