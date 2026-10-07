# [T7 verification] Written by a referee during adversarial verification of T7; re-run by the author (see the Verification log of T7).
# Thm 4.1(iv) / §0 / §8 check: is the audited set A monotonically non-increasing as the depth d grows?
# Practice {MP, AC}, no world, no trusted steps. Positions:
#   P1 = [ {q, p->q, p->F} : {} ]   (the A_1 of the file)
#   P2 = [ {r, s->r} : {s} ]        (a bilateral position with large r, s)
# Target {MP}: both positions are in bounds (classical valuations: q=1,p=0 ; r=1,s=0).
import itertools, heapq
def size(f): return 1 if isinstance(f,str) else 1+sum(size(a) for a in f[1:])
def imp(a,b): return ('imp',a,b)
r=('and',('and','a','b'),('and','c','d')); s=('or',('or','e','f'),('or','g','h'))
P1=({'q',imp('p','q'),imp('p','F')}, set())
P2=({r,imp(s,r)}, {s})
POS=[P1,P2]
# schema application: return list of (premises tuple, conclusion) applicable to a set X
def apply(name,X):
    out=[]
    for f in X:
        if isinstance(f,tuple) and f[0]=='imp':
            x,y=f[1],f[2]
            if name=='MP' and x in X: out.append(((f,x),y))
            if name=='AC' and y in X: out.append(((y,f),x))
    return out
def min_trees(B,pos):
    A,D=pos
    cost={a:size(a) for a in A}; how={a:None for a in A}
    changed=True
    while changed:
        changed=False
        X=set(cost)
        for name in B:
            for prem,c in apply(name,X):
                k=size(c)+sum(cost[p] for p in prem)
                if c not in cost or k<cost[c]:
                    cost[c]=k; how[c]=(name,prem); changed=True
    return cost,how
def refutations(B):
    # smallest refutation over positions: (size, position index, conclusion, step producing it)
    best=None
    for i,pos in enumerate(POS):
        A,D=pos; cost,how=min_trees(B,pos)
        for j in cost:
            if (j=='F' or j in D) and how[j] is not None:
                cand=(cost[j],i,j,how[j])
                if best is None or cand[:2]<best[:2]: best=cand
    return best
def m(B):
    rr=refutations(B); return None if rr is None else rr[0]
def e(j,pos):
    A,D=pos
    if j in A: return 1
    if j=='F' or j in D: return 0
    return None
def descent(rr):
    k,i,j,(name,prem)=rr; pos=POS[i]
    cost,how=min_trees(BCUR,pos)
    node=j; step=(name,prem)
    while True:
        vals=[e(p,pos) for p in step[1]]
        if all(v==1 for v in vals): return (step[0],step[1],node)
        if 0 in vals:
            node=step[1][vals.index(0)]; step=how[node]
            continue
        return None  # blocked
def audit(d):
    global BCUR
    B={'MP','AC'}
    while True:
        BCUR=B
        rr=refutations(B)
        if rr is None or rr[0]>d: return B,'clean'
        out=descent(rr)
        if out is not None:
            name,prem,concl=out
            # remove every schema of B having this step as an instance
            B={x for x in B if not any(pp==prem and cc==concl for pp,cc in apply(x,set(prem)))}
            continue
        # fallback: B minus union of minimal d-conflicts inside B
        subs=[frozenset(c) for k in range(1,len(B)+1) for c in itertools.combinations(sorted(B),k)]
        conf=[c for c in subs if m(set(c)) is not None and m(set(c))<=d]
        mins=[c for c in conf if not any(o<c for o in conf)]
        U=set().union(*mins) if mins else set()
        return B-U,'fallback mins=%s'%[sorted(c) for c in mins]
for B in [{'MP'},{'AC'},{'MP','AC'}]:
    print(sorted(B),'min refutation size:',m(B))
prev=None
for d in range(0,40):
    A,why=audit(d)
    if A!=prev: print('d=%2d  A=%s  (%s)'%(d,sorted(A),why)); prev=A
