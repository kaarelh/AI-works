# End-to-end simulation of the two-tier learner (TTL) on a propositional practice (CPC specialization, Cor 6.2).
# Practice = genuine tagged schemas + systematic fallacy schemas (own latent tags) + sporadic mis-tagged noise.
# Positive-data module: per-tag trimmed lgg (T1 Thm 6.2) with budget e.
# Audit (world channel): a learned schema is refuted iff some {T,F}-substitution of its metavariables gives a
#   closed instance with true premises and false conclusion (closed-instance refutability, Lemma 6.1).
# Assertion tier = union of instance sets of unrefuted learned schemas (after burn-in).
# Adversarial prover: exhaustively searches steps over a formula pool for an accepted classically-invalid step.
import random, itertools, sys
ATOMS=['p0','p1','p2']
def rand_f(rng,d):
    if d==0 or rng.random()<0.3: return rng.choice(ATOMS+['T','F'])
    op=rng.choice(['and','or','imp','not'])
    if op=='not': return ('not',rand_f(rng,d-1))
    return (op,rand_f(rng,d-1),rand_f(rng,d-1))
def isvar(t): return isinstance(t,str) and t.startswith('?')
def subst(t,th):
    if isvar(t): return th[t]
    if isinstance(t,str): return t
    return tuple([t[0]]+[subst(a,th) for a in t[1:]])
def vars_of(t,acc=None):
    acc=set() if acc is None else acc
    if isvar(t): acc.add(t)
    elif isinstance(t,tuple):
        for a in t[1:]: vars_of(a,acc)
    return acc
def match(pat,t,th):
    if isvar(pat):
        if pat in th: return th[pat]==t
        th[pat]=t; return True
    if isinstance(pat,str) or isinstance(t,str): return pat==t
    if pat[0]!=t[0] or len(pat)!=len(t): return False
    return all(match(a,b,th) for a,b in zip(pat[1:],t[1:]))
def lgg(ts):
    table={}
    def A(col):
        if all(isinstance(c,tuple) for c in col) and len({(c[0],len(c)) for c in col})==1:
            return tuple([col[0][0]]+[A(tuple(c[i] for c in col)) for i in range(1,len(col[0]))])
        if all(c==col[0] for c in col): return col[0]
        if col not in table: table[col]='?z%d'%len(table)
        return table[col]
    return A(tuple(ts))
def ev(f,v):
    if f=='T': return True
    if f=='F': return False
    if isinstance(f,str): return v[f]
    o=f[0]
    if o=='not': return not ev(f[1],v)
    a,b=ev(f[1],v),ev(f[2],v)
    return {'and':a and b,'or':a or b,'imp':(not a) or b}[o]
def valid_step(s):   # s=('st',prem1,...,concl): classically valid?
    fs=s[1:]
    for bits in itertools.product([0,1],repeat=len(ATOMS)):
        v=dict(zip(ATOMS,map(bool,bits)))
        if all(ev(p,v) for p in fs[:-1]) and not ev(fs[-1],v): return False
    return True
def world_refuted(schema):  # closed-instance refutability via {T,F} substitution (sigma_v)
    vs=sorted(vars_of(schema))
    for bits in itertools.product(['T','F'],repeat=len(vs)):
        s=subst(schema,dict(zip(vs,bits)))
        if not valid_step(s): return True
    return False
A,B='?A','?B'
GEN={'andI':('st',A,B,('and',A,B)),'andE1':('st',('and',A,B),A),'andE2':('st',('and',A,B),B),
     'orI1':('st',A,('or',A,B)),'orI2':('st',B,('or',A,B)),'MP':('st',A,('imp',A,B),B),
     'MT':('st',('imp',A,B),('not',B),('not',A)),'DS':('st',('or',A,B),('not',A),B),
     'DNE':('st',('not',('not',A)),A)}
FAL={'AC':('st',B,('imp',A,B),A),'DA':('st',('not',A),('imp',A,B),('not',B)),
     'CONV':('st',('imp',A,B),('imp',B,A)),'XOR':('st',('or',A,B),A,('not',B))}
ALL={**GEN,**FAL}
def sample_data(rng,N,pi,alpha):
    tags=list(pi); w=[pi[t] for t in tags]; data={t:[] for t in tags}; nnoise={t:0 for t in tags}
    for _ in range(N):
        t=rng.choices(tags,w)[0]; sch=ALL[t]
        if rng.random()<alpha:   # sporadic noise: random invalid step with right arity, mis-tagged t
            while True:
                s=tuple(['st']+[rand_f(rng,2) for _ in range(len(sch)-1)])
                if not valid_step(s): break
            nnoise[t]+=1
        else:
            s=subst(sch,{A:rand_f(rng,2),B:rand_f(rng,2)})
        data[t].append(s)
    return data,nnoise
def walk(t,th):
    while isvar(t) and t in th: t=th[t]
    return t
def occurs(v,t,th):
    t=walk(t,th)
    if t==v: return True
    return isinstance(t,tuple) and any(occurs(v,a,th) for a in t[1:])
def unify(a,b,th):
    a,b=walk(a,th),walk(b,th)
    if a==b: return True
    if isvar(a):
        if occurs(a,b,th): return False
        th[a]=b; return True
    if isvar(b): return unify(b,a,th)
    if isinstance(a,str) or isinstance(b,str): return False
    if a[0]!=b[0] or len(a)!=len(b): return False
    return all(unify(x,y,th) for x,y in zip(a[1:],b[1:]))
def resolve(t,th):
    t=walk(t,th)
    if isinstance(t,tuple): return tuple([t[0]]+[resolve(a,th) for a in t[1:]])
    return t
def mgu_all(Ls):
    # accepted set of the trimmed VS = intersection of inst(L) = inst(most general common instance)
    th={}; base=None
    for k,L in enumerate(Ls):
        Lr=subst(L,{v:'?r%d_%s'%(k,v[1:]) for v in vars_of(L)})
        if base is None: base=Lr; continue
        if not unify(base,Lr,th): return None
    return resolve(base,th)
def trimmed_lggs(P,e):
    if len(P)<=e: return None      # 'all data could be noise': the trimmed VS contains the empty rule, accept nothing
    out=set()
    for E in itertools.combinations(range(len(P)),e):
        rest=[P[i] for i in range(len(P)) if i not in E]
        if rest: out.add(lgg(rest))
    return list(out)
def accepts(Ls,s): return Ls is not None and all(match(L,s,{}) for L in Ls)
def learner(data,e,audit=True):
    acc={}
    for t,P in data.items():
        Ls=trimmed_lggs(P,e)
        if Ls is None: continue
        M=mgu_all(Ls)
        if M is None: continue                       # empty accepted set
        if audit and world_refuted(M): continue      # audit the accepted schema itself
        acc[t]=[M]
    return acc
def identified(acc_ls,t):   # trimmed VS for tag t equals inst(ALL[t]) iff all pieces >= sigma and one piece == sigma
    if acc_ls is None: return False
    sig=ALL[t]; sk={v:'c_'+v[1:] for v in vars_of(sig)}
    gen=all(match(L,subst(sig,sk),{}) for L in acc_ls)
    eq=any(match(L,subst(sig,sk),{}) and match(sig,subst(L,{v:'d_'+v[1:] for v in vars_of(L)}),{}) for L in acc_ls)
    return gen and eq
POOL=None
def prover_attack(acc,pool):
    # adaptive prover: search all steps of each accepted tag's arity over the pool; report an accepted invalid step
    for t,Ls in acc.items():
        ar=len(ALL[t])-1
        for fs in itertools.product(pool,repeat=ar):
            s=('st',)+fs
            if accepts(Ls,s) and not valid_step(s): return (t,s)
    return None
if __name__=='__main__':
    rng=random.Random(int(sys.argv[1]) if len(sys.argv)>1 else 0)
    pool=['p0','p1','F','T',('not','p0'),('imp','p0','p1'),('or','p0','p1'),('and','p0','p1'),('imp','p1','p0'),('not',('not','p0'))]
    pi={**{t:1.0 for t in GEN},**{t:1.0 for t in FAL}}; Z=sum(pi.values()); pi={t:v/Z for t,v in pi.items()}
    alpha=0.01; e=2
    print('tags:',len(GEN),'genuine,',len(FAL),'fallacies; alpha=',alpha,'trim e=',e)
    for N in [60,120,250,500]:
        res={'pos_only_unsound':0,'ttl_unsound':0,'ttl_exact':0,'ttl_exact_given_noise<=e':0,'untrimmed_unsound':0,'untrimmed_exact':0}
        T=20
        for trial in range(T):
            data,nn=sample_data(rng,N,pi,alpha)
            if max(nn.values())>e: res['noise>e']=res.get('noise>e',0)+1
            pos=learner(data,e,audit=False); ttl=learner(data,e,audit=True); unt=learner(data,0,audit=True)
            if prover_attack(pos,pool): res['pos_only_unsound']+=1
            if prover_attack(ttl,pool): res['ttl_unsound']+=1
            if prover_attack(unt,pool): res['untrimmed_unsound']+=1
            ok = set(ttl)==set(GEN) and all(identified(ttl[t],t) for t in GEN)
            res['ttl_exact']+=ok
            if max(nn.values())<=e: res['ttl_exact_given_noise<=e']+=ok
            res['untrimmed_exact']+= set(unt)==set(GEN) and all(identified(unt[t],t) for t in GEN)
        print('N=%4d'%N,{k:'%d/%d'%(v,T) for k,v in res.items()})
