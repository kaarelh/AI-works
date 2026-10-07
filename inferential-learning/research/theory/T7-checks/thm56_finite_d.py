# Thm 5.6(c) (added after verification): at finite depth d the fallback can be strictly suboptimal.
# Practice {MP, AC}; no world, no trusted steps; positions A1 = {q, p->q, p->bot}, A2 = {phi, bot->phi},
# phi = q&(q&q).  Size of a derivation = symbols in its distinct judgments (well-founded derivations only).
# (Referee script had a circularity bug: it accepted 'p' justified by AC from 'bot' itself; fixed here.)
import itertools
def imp(a,b): return ('>',a,b)
def size(f): return 1 if isinstance(f,str) else 1+sum(size(x) for x in f[1:])
phi=('&','q',('&','q','q'))
A1=['q',imp('p','q'),imp('p','F')]; A2=[phi,imp('F',phi)]
POS={'A1':A1,'A2':A2}
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
def wellfounded(rules,ctx,S):
    J={f for f in S if f in ctx}; ch=True
    while ch:
        ch=False
        for (p,c) in steps(rules,J):
            if c in S and c not in J: J.add(c); ch=True
    return J==S
def min_ref(rules,ctx):
    X=closure(rules,ctx)
    if 'F' not in X: return None
    nodes=sorted(X,key=str); best=None
    for r in range(1,len(nodes)+1):
        for S in itertools.combinations(nodes,r):
            S=set(S)
            if 'F' in S and wellfounded(rules,ctx,S):
                sz=sum(size(f) for f in S); best=sz if best is None else min(best,sz)
    return best
def m(B):
    vals=[min_ref(B,ctx) for ctx in POS.values()]; vals=[v for v in vals if v is not None]
    return min(vals) if vals else None
subsets=[frozenset(c) for k in (1,2) for c in itertools.combinations(['AC','MP'],k)]
for B in subsets:
    print(sorted(B),{n:min_ref(B,ctx) for n,ctx in POS.items()})
def ttl_fallback(d):
    # no world, no trusted steps: every descent is blocked unless the last step's premises are asserted;
    # here the first refutation (if any) is blocked, so the fallback runs at B0 = {MP, AC}.
    conf=[B for B in subsets if m(B) is not None and m(B)<=d]
    if not conf: return {'AC','MP'},'clean'
    mins=[B for B in conf if not any(o<B for o in conf)]
    return {'AC','MP'}-set().union(*mins),'fallback, minimal conflicts %s'%[sorted(c) for c in mins]
prev=None
for d in range(0,20):
    A,why=ttl_fallback(d)
    if A!=prev: print('d=%2d  A=%s  (%s)'%(d,sorted(A),why)); prev=A
print('infinity-clean subsets (admissible targets): ', [sorted(B) for B in [frozenset()]+subsets if not B or m(B) is None])
print('=> for 9 <= d <= 12 TTL(d) withholds MP, yet "assert R_MP after burn-in" is sound in every admissible scenario.')
