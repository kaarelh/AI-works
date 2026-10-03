import itertools
# formulas of depth <=1 over atoms p,q with connectives
atoms=['p','q']
F=[('at','p'),('at','q')]
F+= [('not',a) for a in F[:2]]
base=F[:2]
for c in ['and','or','imp']:
    for a in base:
        for b in base:
            F.append((c,a,b))
F=list(dict.fromkeys(F))
idx={f:i for i,f in enumerate(F)}
n=len(F)
def ev(f,asg):
    t=f[0]
    if t=='at': return asg[f[1]]
    if t=='not': return 1-ev(f[1],asg)
    a=ev(f[1],asg); b=ev(f[2],asg)
    return {'and':a&b,'or':a|b,'imp':(1-a)|b}[t]
bool_vals=[]
for bits in itertools.product([0,1],repeat=2):
    asg=dict(zip(atoms,bits))
    bool_vals.append(tuple(ev(f,asg) for f in F))
print("n formulas",n,"boolean restrictions",len(set(bool_vals)))
# TT instances inside F
TT=[]
for f in F:
    if f[0]=='not' and f[1] in idx:
        a=idx[f[1]]; na=idx[f]
        TT.append(((a,na),()))      # a, not a |- 
        TT.append(((),(a,na)))      # |- a, not a
    if f[0] in ('and','or','imp'):
        a=idx[f[1]]; b=idx[f[2]]; c=idx[f]
        if f[0]=='and':
            TT+= [((c,),(a,)),((c,),(b,)),((a,b),(c,))]
        if f[0]=='or':
            TT+= [((a,),(c,)),((b,),(c,)),((c,),(a,b))]
        if f[0]=='imp':
            TT+= [((),(a,c)),((b,),(c,)),((a,c),(b,))]
def sat(v,seq):
    G,D=seq
    return not (all(v[i]==1 for i in G) and all(v[j]==0 for j in D))
allv=list(itertools.product([0,1],repeat=n))
mc=[v for v in allv if all(sat(v,s) for s in TT)]
print("valuations satisfying multiple-conclusion TT:",len(mc), set(mc)==set(bool_vals))
# single-conclusion: all classically valid sequents G |- phi with |G|<=2 (incl. empty) inside F
def valid(G,D):
    return all(sat(bv,(G,D)) for bv in bool_vals)
single=[]
for k in range(0,3):
    for G in itertools.combinations(range(n),k):
        for phi in range(n):
            if valid(G,(phi,)): single.append((G,(phi,)))
sc=[v for v in allv if all(sat(v,s) for s in single)]
# intersection closure of boolean restrictions (incl. empty intersection = all ones)
inter=set()
for k in range(0,5):
    for S in itertools.combinations(bool_vals,k):
        inter.add(tuple(min([s[i] for s in S],default=1) for i in range(n)))
print("valuations respecting all single-conclusion valid sequents (|G|<=2):",len(sc),"; intersection-closure size:",len(inter), "equal:",set(sc)==inter)
# add empty-succedent (0-denial, non-contradiction) sequents
zero=[(G,()) for k in range(1,3) for G in itertools.combinations(range(n),k) if valid(G,())]
sc0=[v for v in sc if all(sat(v,s) for s in zero)]
print("adding 0-denial (non-contradiction) sequents:",len(sc0), "(should be closure minus all-true):", set(sc0)==inter-{tuple([1]*n)})
# denial rank of each valuation (Thm 4.3), added after verification:
# d(v) = min |Delta| over Delta subset false(v) such that some finite Gamma subset true(v) has Gamma |=_BV Delta.
# Since Gamma may be all of true(v) on this finite fragment, Gamma |= Delta iff every Boolean u extending true(v)
# makes some member of Delta true (empty Delta: no Boolean u extends true(v)).
from collections import Counter
bset=set(bool_vals)
def rank(v):
    T=[i for i in range(n) if v[i]]; Fl=[i for i in range(n) if not v[i]]
    ext=[u for u in bool_vals if all(u[i] for i in T)]
    if not ext: return 0
    for k in range(1,len(Fl)+1):
        for D in itertools.combinations(Fl,k):
            if all(any(u[j] for j in D) for u in ext): return k
    return 'inf'
def cls(v):
    T=[i for i in range(n) if v[i]]
    ext=[u for u in bool_vals if all(u[i] for i in T)]
    if not ext: return 0                      # inconsistent
    closure=[i for i in range(n) if all(u[i] for u in ext)]
    if set(closure)!=set(T): return 1         # consistent, not closed
    if v in bset: return 'inf'                # Boolean
    return 2                                  # closed, consistent, non-maximal
cnt=Counter(); mism=0
for v in allv:
    r=rank(v); c=cls(v); cnt[r]+=1
    if r!=c: mism+=1
print("Thm 4.3 denial ranks over all",len(allv),"valuations:",dict(cnt),"; mismatches with class:",mism)
