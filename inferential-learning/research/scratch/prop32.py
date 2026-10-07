# Prop 3.2 (voting audit, m mis-designations tolerated): concrete checks.
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
def smallest_ref(B,pos):
    A,D=pos; cost={a:size(a) for a in A}; how={a:None for a in A}; ch=True
    while ch:
        ch=False; X=set(cost)
        for n in sorted(B):
            for prem,c in apply(n,X):
                k=size(c)+sum(cost[p] for p in prem)
                if c not in cost or k<cost[c]: cost[c]=k; how[c]=(n,prem); ch=True
    refs=[(cost[j],j) for j in cost if (j=='F' or j in D) and how[j] is not None]
    if not refs: return None
    k,j=min(refs,key=lambda t:(t[0],str(t[1])))
    # descent (no world, no trusted steps): output the falsified step if its premises are asserted
    n,prem=how[j]
    while True:
        if all(p in A for p in prem): return (prem,j)
        zero=[p for p in prem if p=='F' or p in D]
        if zero: j=zero[0]; n,prem=how[j]; continue
        return 'blocked'
def blamed(B,step):
    prem,c=step
    return {n for n in B if any(pp==prem and cc==c for pp,cc in apply(n,set(prem)))}
def voting_audit(B,POS,m):
    B=set(B); votes={}; descents=0
    while True:
        removed=False
        for i,pos in enumerate(POS):
            r=smallest_ref(B,pos)
            if r is None or r=='blocked': continue
            descents+=1
            for n in blamed(B,r): votes.setdefault(n,set()).add(i)
        for n in list(B):
            if len(votes.get(n,()))>=m+1: B.discard(n); removed=True
        if not removed: return B,votes,descents
# (1) |F|=0, m=1, one mis-designated position: genuine MP is falsified there.
Pbad=({'a',imp('a','b')},{'b'})
B,v,dsc=voting_audit({'MP'},[Pbad],1)
print('(1) target {MP}, F=empty, m=1: successful descents =',dsc,' > (m+1)|F| = 0 ; A =',sorted(B))
# (2) m=1, two truthful bilateral positions; AC falsifiable only at p1, DA falsifiable at p1 AND p2 (= m+1 positions).
p1=({'q',imp('p','q'),neg('p')},{'p',neg('q')})
p2=({neg('r'),imp('r','t')},{neg('t')})
for name in ['AC','DA','MP']:
    print('   ',name,'falsifiable at positions:',[i for i,pos in enumerate([p1,p2]) if smallest_ref({name},pos) not in (None,'blocked')])
B,v,dsc=voting_audit({'MP','AC','DA'},[p1,p2],1)
print('(2) final A =',sorted(B),' votes =',{k:sorted(x) for k,x in v.items()})
