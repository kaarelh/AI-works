# Randomized stress test of Prop 3.2 (voting audit), d = infinity, with a trusted rule (notE) so that
# backward propagation and conflicting e^+ can occur.  Exact oracle (returns some refutation if one exists).
import random, itertools
random.seed(1)
ATOMS=['p','q','r']
def imp(a,b): return ('>',a,b)
def neg(a): return ('~',a)
def rnd(depth):
    if depth==0 or random.random()<0.35: return random.choice(ATOMS)
    return imp(rnd(depth-1),rnd(depth-1)) if random.random()<0.6 else neg(rnd(depth-1))
def apply(name,X):
    out=[]
    for f in X:
        if isinstance(f,tuple) and f[0]=='>':
            a,b=f[1],f[2]
            if name=='MP' and a in X: out.append(((a,f),b))
            if name=='MT' and neg(b) in X: out.append(((f,neg(b)),neg(a)))
            if name=='AC' and b in X: out.append(((b,f),a))
            if name=='DA' and neg(a) in X: out.append(((neg(a),f),neg(b)))
            if name=='CONV': out.append(((f,),imp(b,a)))
        if isinstance(f,tuple) and f[0]=='~':
            if name=='DNE' and isinstance(f[1],tuple) and f[1][0]=='~': out.append(((f,),f[1][1]))
            if name=='notE' and f[1] in X: out.append(((f[1],f),'F'))
    return out
TRUST=['notE']
SIGMA=['MP','MT','DNE']; FALL=['AC','DA','CONV']; SP=SIGMA+FALL
def closure(rules,A,cap=8):
    how={a:None for a in A}; X=set(A)
    for _ in range(cap):
        new={}
        for n in rules:
            for prem,c in apply(n,X):
                if c not in X and c not in new: new[c]=(n,prem)
        if not new: break
        for c,h in new.items(): how[c]=h; X.add(c)
    return X,how
def efun(pos):
    A,D=pos
    def e(j):
        if j in A: return 1
        if j=='F' or j in D: return 0
        return None
    return e
def ref(B,pos):
    A,D=pos; X,how=closure(list(B)+TRUST,A)
    bad=[j for j in X if (j=='F' or j in D) and how[j] is not None]
    if not bad: return None
    j=sorted(bad,key=str)[0]
    # collect derivation pi
    steps=[]; seen=set(); st=[j]
    while st:
        x=st.pop()
        if x in seen or how.get(x) is None: continue
        seen.add(x); n,prem=how[x]; steps.append((n,prem,x)); st.extend(prem)
    return j,steps
def descend(pos,j,steps):
    e=efun(pos); judg={x for (_,P,c) in steps for x in P}|{c for (_,_,c) in steps}
    val={x:e(x) for x in judg if e(x) is not None}
    conflict=False; ch=True
    tsteps=[(P,c) for (n,P,c) in steps if n in TRUST]
    while ch:
        ch=False
        for (P,c) in tsteps:
            if all(val.get(x)==1 for x in P):
                if val.get(c)==0: conflict=True
                elif c not in val: val[c]=1; ch=True
            if val.get(c)==0:
                unk=[x for x in P if val.get(x)!=1]
                if len(unk)==1:
                    if val.get(unk[0])==1: pass
                    elif unk[0] not in val: val[unk[0]]=0; ch=True
        for (P,c) in tsteps:
            if all(val.get(x)==1 for x in P) and val.get(c)==0: conflict=True
    if conflict: return 'conflict'
    prod={c:(n,P) for (n,P,c) in steps}
    node=j
    while True:
        n,P=prod[node]
        vs=[val.get(x) for x in P]
        if all(v==1 for v in vs): return (n,P,node)
        if 0 in vs: node=P[vs.index(0)]; continue
        return 'blocked'
def good(pos):  # (WS) for target SIGMA at pos via equivalent form (no world)
    A,D=pos
    if A&(D|{'F'}): return False
    X,_=closure(SIGMA+TRUST,A)
    return not (X&(D|{'F'}))
def clean_with(B,pos): return ref(B,pos) is None
viol=0; trials=0; stats={'bad':0,'blocked':0,'conflict':0,'blamed_genuine':0,'fall_removed':0}
for trial in range(3000):
    POS=[]
    for k in range(random.randint(1,4)):
        A=frozenset(rnd(2) for _ in range(random.randint(1,4))); D=frozenset(rnd(2) for _ in range(random.randint(0,2)))
        POS.append((A,D))
    goodv=[good(p) for p in POS]; m=goodv.count(False); stats['bad']+=m
    Blamed={}; calls=0; complete={}; discarded=set()
    for i,pos in enumerate(POS):
        A,D=pos; Bp=set(SP); Bl=set(); complete[i]=False
        if A&(D|{'F'}): calls+=1; discarded.add(i); Blamed[i]=set(); continue
        while True:
            calls+=1; r=ref(Bp,pos)
            if r is None: complete[i]=goodv[i]; break
            out=descend(pos,*r)
            if out=='blocked': stats['blocked']+=1; break
            if out=='conflict': stats['conflict']+=1; discarded.add(i); Bl=set(); break
            n,P,c=out
            S={x for x in Bp if any(pp==P and cc==c for pp,cc in apply(x,set(P)))}
            if not S: print('EMPTY BLAME', out, goodv[i]); viol+=1; break
            Bp-=S; Bl|=S
            if S&set(SIGMA): stats['blamed_genuine']+=1
        Blamed[i]=Bl
    votes={x:sum(1 for i in Blamed if x in Blamed[i]) for x in SP}
    Aout={x for x in SP if votes[x]<m+1}
    trials+=1; stats['fall_removed']+=len(set(FALL)-Aout)
    # (a)
    if not set(SIGMA)<=Aout: viol+=1; print('(a) fails',POS,goodv,Blamed)
    # (b)
    if calls> len(POS)*(len(FALL)+1)+m*len(SIGMA): viol+=1; print('(b) fails',calls)
    # (c)
    for i,pos in enumerate(POS):
        if complete[i]:
            for t in FALL:
                if not clean_with(set(SIGMA)|{t},pos) and t not in Blamed[i]: viol+=1; print('(c) fails',pos,t)
    for t in FALL:
        if t in Aout:
            cnt=sum(1 for i,pos in enumerate(POS) if complete[i] and not clean_with(set(SIGMA)|{t},pos))
            if cnt>m: viol+=1; print('(c) residue fails',t)
    # m=0 & all complete => A d-clean
    if m==0 and all(complete.values()):
        if any(ref(Aout,p) is not None for p in POS): viol+=1; print('m=0 clean fails')
print("trials",trials,"violations",viol,stats)
