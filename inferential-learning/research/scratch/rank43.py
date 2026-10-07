import itertools, collections, sys
def build(depth_spec):
    atoms=[('at','p'),('at','q')]
    F=list(atoms)
    return F
def ev(f,asg):
    t=f[0]
    if t=='at': return asg[f[1]]
    if t=='not': return 1-ev(f[1],asg)
    a=ev(f[1],asg); b=ev(f[2],asg)
    return {'and':a&b,'or':a|b,'imp':(1-a)|b}[t]
def subs(f):
    S={f}
    for g in f[1:]:
        if isinstance(g,tuple): S|=subs(g)
    return S
def analyze(F,label):
    F=list(dict.fromkeys(F)); n=len(F); idx={f:i for i,f in enumerate(F)}
    # check subformula closed
    assert all(all(g in idx for g in subs(f)) for f in F)
    BVs=[tuple(ev(f,{'p':a,'q':b}) for f in F) for a,b in itertools.product([0,1],repeat=2)]
    BVset=set(BVs)
    # TT instances inside F
    TT=[]
    for f in F:
        if f[0]=='not': a=idx[f[1]]; na=idx[f]; TT+=[((a,na),()),((),(a,na))]
        if f[0] in('and','or','imp'):
            a=idx[f[1]]; b=idx[f[2]]; c=idx[f]
            if f[0]=='and': TT+=[((c,),(a,)),((c,),(b,)),((a,b),(c,))]
            if f[0]=='or': TT+=[((a,),(c,)),((b,),(c,)),((c,),(a,b))]
            if f[0]=='imp': TT+=[((),(a,c)),((b,),(c,)),((a,c),(b,))]
    def sat(v,s):
        G,D=s; return not(all(v[i] for i in G) and all(not v[j] for j in D))
    cnt=collections.Counter(); bad=0; valTT=0
    for v in itertools.product([0,1],repeat=n):
        if all(sat(v,s) for s in TT): valTT+=1; assert v in BVset
        T=[i for i in range(n) if v[i]]; Fl=[i for i in range(n) if not v[i]]
        ext=[u for u in BVs if all(u[i] for i in T)]   # Boolean u extending true-set
        # d(v): min |Delta|, Delta subset of false(v), with true(v) |= Delta (no ext u falsifies all of Delta)
        if not ext: d=0
        else:
            d=None
            for k in range(1,len(Fl)+1):
                if any(all(any(u[j] for j in Dl) for u in ext) for Dl in itertools.combinations(Fl,k)): d=k;break
            if d is None: d='inf'
        # classification
        if not ext: cls=0
        else:
            closure=[i for i in range(n) if all(u[i] for u in ext)]
            if set(closure)!=set(T): cls=1
            elif v in BVset: cls='inf'
            else: cls=2
        cnt[(d,cls)]+=1
        if d!=cls: bad+=1
    print(label,"n=",n,"|Val(TT)|=",valTT,"(Boolean restrictions",len(BVset),") ; (rank,class) counts:",dict(cnt),"mismatches:",bad)
p=('at','p'); q=('at','q')
F1=[p,q,('not',p),('not',q)]+[(c,a,b) for c in['and','or','imp'] for a in[p,q] for b in[p,q]]
analyze(F1,"carnap_check fragment")
# richer: add negations of the binary compounds and a couple of depth-2 formulas
F2=F1+[('not',f) for f in F1 if f[0] in('and','or','imp')][:4]
analyze(F2,"F1 + 4 negated compounds")
F3=[p,q,('not',p),('or',p,('not',p)),('not',('or',p,('not',p))),('imp',p,q),('imp',q,p),('and',p,q),('or',p,q),('not',q),('imp',p,('not',p))]
F3=list(dict.fromkeys(sum([sorted(subs(f),key=str) for f in F3],[])))
analyze(F3,"mixed depth-2 fragment")
