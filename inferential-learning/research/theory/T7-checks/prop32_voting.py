# Prop 3.2 (revised after verification): voting audit with at most m mis-designated positions.
# Toy model: practice schemas MP, AC, DA over formulas; no world, no trusted steps; positions [A:D].
# Contrast: (old) per-position smallest refutation + global voting   vs   (new) independent per-position
# descent loops excluding already-blamed schemas, with the prefer-unblocked oracle, then voting.
# Referee examples (verification of T7): (1) one bad position, F empty, m=1; (2) m=1, two truthful positions.
import itertools
def size(f): return 1 if isinstance(f,str) else 1+sum(size(a) for a in f[1:])
def imp(a,b): return ('imp',a,b)
def neg(a): return ('not',a)
def apply(name,X):
    out=[]
    for f in X:
        if isinstance(f,tuple) and f[0]=='imp':
            x,y=f[1],f[2]
            if name=='MP' and x in X: out.append(((f,x),y))
            if name=='AC' and y in X: out.append(((y,f),x))
            if name=='DA' and neg(x) in X: out.append(((neg(x),f),neg(y)))
    return out
def min_trees(B,pos):
    A,D=pos; cost={a:size(a) for a in A}; how={a:None for a in A}; ch=True
    while ch:
        ch=False; X=set(cost)
        for n in sorted(B):
            for prem,c in apply(n,X):
                k=size(c)+sum(cost[p] for p in prem)
                if c not in cost or k<cost[c]: cost[c]=k; how[c]=(n,prem); ch=True
    return cost,how
def e(j,pos):
    A,D=pos
    if j in A: return 1
    if j=='F' or j in D: return 0
    return None
def descent(j,how,pos):
    n,prem=how[j]
    while True:
        vals=[e(p,pos) for p in prem]
        if all(v==1 for v in vals): return (prem,j)
        if 0 in vals: j=prem[vals.index(0)]; n,prem=how[j]; continue
        return 'blocked'
def candidates(B,pos):
    A,D=pos; cost,how=min_trees(B,pos)
    return [(cost[j],str(j),descent(j,how,pos)) for j in cost if (j=='F' or j in D) and how[j] is not None]
def ref_smallest(B,pos):            # old oracle: smallest refutation of B itself
    c=candidates(B,pos)
    return None if not c else min(c,key=lambda t:(t[0],t[1]))[2]
def ref_pref_unblocked(B,pos):      # new oracle: prefer refutations whose descent is unblocked (over subsets of B)
    best=None
    for k in range(1,len(B)+1):
        for Bs in itertools.combinations(sorted(B),k):
            for c in candidates(set(Bs),pos):
                key=(c[2]=='blocked',c[0],c[1])
                if best is None or key<best[0]: best=(key,c[2])
    return None if best is None else best[1]
def blamed(B,step):
    prem,c=step
    return {n for n in B if any(pp==prem and cc==c for pp,cc in apply(n,set(prem)))}
def old_voting(B,POS,m):
    B=set(B); votes={}; descents=0
    while True:
        removed=False
        for i,pos in enumerate(POS):
            r=ref_smallest(B,pos)
            if r is None or r=='blocked': continue
            descents+=1
            for n in blamed(B,r): votes.setdefault(n,set()).add(i)
        for n in list(B):
            if len(votes.get(n,()))>=m+1: B.discard(n); removed=True
        if not removed: return B,votes,descents
def new_voting(SigmaP,POS,m):
    Blamed={}; calls=0; complete={}
    for i,pos in enumerate(POS):
        Bp=set(SigmaP); Bl=set(); complete[i]=False
        while True:
            calls+=1; r=ref_pref_unblocked(Bp,pos)
            if r is None: complete[i]=True; break
            if r=='blocked': break
            S=blamed(Bp,r); Bp-=S; Bl|=S
        Blamed[i]=Bl
    votes={n:{i for i in Blamed if n in Blamed[i]} for n in SigmaP}
    A={n for n in SigmaP if len(votes[n])<m+1}
    return A,{n:sorted(v) for n,v in votes.items() if v},calls,complete
print('--- (1) target {MP}, F = {}, m = 1, one mis-designated position [{a, a->b} : {b}]')
Pbad=({'a',imp('a','b')},{'b'})
B,v,d=old_voting({'MP'},[Pbad],1); print('old: A =',sorted(B),' successful descents =',d,' (claimed bound (m+1)|F| = 0)')
A,v,c,cp=new_voting({'MP'},[Pbad],1); print('new: A =',sorted(A),' votes =',v,' oracle calls =',c,' bound |A|(|F|+1)+m|Sigma*| = 2')
print('--- (2) m = 1, truthful p1 = [{q, p->q, ~p} : {p, ~q}], p2 = [{~r, r->t} : {~t}], practice {MP, AC, DA}, target {MP}')
p1=({'q',imp('p','q'),neg('p')},{'p',neg('q')}); p2=({neg('r'),imp('r','t')},{neg('t')})
for name in ['AC','DA','MP']:
    print('   {MP,%s} refutable at positions:'%name,[i for i,pos in enumerate([p1,p2]) if ref_pref_unblocked({'MP',name},pos) not in (None,'blocked')])
B,v,d=old_voting({'MP','AC','DA'},[p1,p2],1); print('old: A =',sorted(B),' votes =',{k:sorted(x) for k,x in v.items()},'  <- DA survives although refutable at m+1 = 2 positions')
A,v,c,cp=new_voting({'MP','AC','DA'},[p1,p2],1); print('new: A =',sorted(A),' votes =',v,' calls =',c,' complete positions =',cp)
print('    expected: DA removed (refutable with Sigma* at 2 complete positions); AC may survive (refutable at only 1 <= m)')
print('--- (3) m = 1, positions p1, p2 and the bad position; practice {MP, AC, DA}')
A,v,c,cp=new_voting({'MP','AC','DA'},[p1,p2,Pbad],1); print('new: A =',sorted(A),' votes =',v,' calls =',c, ' (MP blamed only by the bad position, kept)')
