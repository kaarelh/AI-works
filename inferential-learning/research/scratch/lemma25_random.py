# Random test of Lemma 2.5 (local e+_pi agrees with a WS valuation; descent output falsified & untrusted;
# (d) extracted {sigma}-refutation is a valid refutation with distinct-judgment size <= that of pi).
import random
exec(open('prop32_random.py').read().split('viol=0; trials=0')[0])
random.seed(7)
def sz(f): return 1 if isinstance(f,str) else 1+sum(sz(x) for x in f[1:])
def local_eplus(pos,steps):
    e=efun(pos); judg={x for (_,P,c) in steps for x in P}|{c for (_,_,c) in steps}
    val={x:e(x) for x in judg if e(x) is not None}; why={}
    ch=True; tsteps=[(n,P,c) for (n,P,c) in steps if n in TRUST]
    while ch:
        ch=False
        for (n,P,c) in tsteps:
            if all(val.get(x)==1 for x in P) and c not in val: val[c]=1; why[c]=('fwd',n,P,c); ch=True
            if val.get(c)==0:
                unk=[x for x in P if val.get(x)!=1]
                if len(unk)==1 and unk[0] not in val: val[unk[0]]=0; why[unk[0]]=('bwd',n,P,c); ch=True
    return val,why
def extract(pos,val,why,s):
    e=efun(pos); n,P,c=s; der=[(n,P,c)]; need=list(P)
    # justify value-1 premises
    done=set()
    while need:
        x=need.pop()
        if x in done: continue
        done.add(x)
        if e(x)==1: continue
        k,tn,TP,tc=why[x]; assert k=='fwd'; der.append((tn,TP,tc)); need.extend(TP)
    # chain for the conclusion
    x=c
    while e(x)!=0:
        k,tn,TP,tc=why[x]; assert k=='bwd'; der.append((tn,TP,tc))
        for y in TP:
            if y!=x: need.append(y)
        while need:
            z=need.pop()
            if z in done: continue
            done.add(z)
            if e(z)==1: continue
            kk,un,UP,uc=why[z]; assert kk=='fwd'; der.append((un,UP,uc)); need.extend(UP)
        x=tc
    return der,x
def valid_refutation(pos,der,concl,allowed):
    e=efun(pos); have={}; prod={}
    for (n,P,c) in der:
        if n not in allowed: return False,'step not allowed'
        prod.setdefault(c,(n,P))
    J={x for (_,P,_) in der for x in P}|{c for (_,_,c) in der}
    # well-founded build from e-true leaves
    D=set(x for x in J if e(x)==1); ch=True
    while ch:
        ch=False
        for (n,P,c) in der:
            if c not in D and all(x in D for x in P): D.add(c); ch=True
    if concl not in D: return False,'not well-founded'
    if e(concl)!=0: return False,'conclusion not e-false'
    return True,sum(sz(x) for x in J)
cnt=0; fails=0
for trial in range(4000):
    A=frozenset(rnd(2) for _ in range(random.randint(1,4))); D=frozenset(rnd(2) for _ in range(random.randint(0,2)))
    pos=(A,D)
    if not good(pos): continue
    B=set(random.sample(SP,random.randint(1,len(SP))))
    r=ref(B,pos)
    if r is None: continue
    j,steps=r
    val,why=local_eplus(pos,steps)
    # (WS) valuation: V = indicator of closure of A under SIGMA+TRUST (equivalent form)
    X,_=closure(SIGMA+TRUST,A,cap=12)
    for x,v in val.items():
        if (v==1)!=(x in X): fails+=1; print('e+ disagrees with V',x,v)
    out=descend(pos,j,steps)
    if out in ('blocked','conflict'):
        if out=='conflict': fails+=1; print('conflict at good position')
        continue
    n,P,c=out
    if n in TRUST or n in SIGMA: fails+=1; print('(a) output trusted/genuine',out)
    der,concl=extract(pos,val,why,out)
    sigmas=[x for x in B if any(pp==P and cc==c for pp,cc in apply(x,set(P)))]
    for sg in sigmas:
        ok,info=valid_refutation(pos,[(sg if k==n else k,PP,cc) for (k,PP,cc) in der],concl,set([sg])|set(TRUST))
        pi_size=sum(sz(x) for x in ({x for (_,PP,_) in steps for x in PP}|{cc for (_,_,cc) in steps}))
        if not ok or info>pi_size: fails+=1; print('(d) fails',ok,info,pi_size)
    cnt+=1
print('unblocked refutations tested',cnt,'failures',fails)
