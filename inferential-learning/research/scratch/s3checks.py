import itertools, random
random.seed(1)
# ---------- formulas ----------
# ('at',i) ('not',a) ('and',a,b) ('or',a,b) ('imp',a,b) ('bot',)
def ev(f,v):
    t=f[0]
    if t=='at': return v[f[1]]
    if t=='bot': return 0
    if t=='not': return 1-ev(f[1],v)
    a=ev(f[1],v); b=ev(f[2],v)
    return {'and':a&b,'or':a|b,'imp':(1-a)|b}[t]
def atoms(f,acc=None):
    if acc is None: acc=set()
    if f[0]=='at': acc.add(f[1])
    for g in f[1:]:
        if isinstance(g,tuple): atoms(g,acc)
    return acc
def subst(f,s):
    t=f[0]
    if t=='at': return s.get(f[1],f)
    if t=='bot': return f
    if t=='not': return ('not',subst(f[1],s))
    return (t,subst(f[1],s),subst(f[2],s))
def taut(f):
    A=sorted(atoms(f))
    return all(ev(f,dict(zip(A,b))) for b in itertools.product([0,1],repeat=len(A)))
def contra(f):
    A=sorted(atoms(f))
    return all(not ev(f,dict(zip(A,b))) for b in itertools.product([0,1],repeat=len(A)))
def rnd(conns,d,na=4):
    if d==0 or random.random()<0.25: return ('at',random.randrange(na))
    c=random.choice(conns)
    if c=='not': return ('not',rnd(conns,d-1,na))
    return (c,rnd(conns,d-1,na),rnd(conns,d-1,na))
# ---- Thm 3.1 sigma_v lemma, {not,and}, {not,or}, {not,imp}, pure {imp}
P0=('at',99)
for conns,top,bot in [(['not','and'],('not',('and',P0,('not',P0))),None),
                      (['not','or'],('or',P0,('not',P0)),None),
                      (['not','imp'],('imp',P0,P0),None)]:
    bot=('not',top); bad=0
    for _ in range(3000):
        f=rnd(conns,5); A=sorted(atoms(f)); v={a:random.randint(0,1) for a in A}
        g=subst(f,{a:(top if v[a] else bot) for a in A})
        if ev(f,v)==1 and not taut(g): bad+=1
        if ev(f,v)==0 and not contra(g): bad+=1
    print('Thm3.1 sigma_v',conns,'failures',bad)
top=('imp',P0,P0); bad=0
for _ in range(3000):
    f=rnd(['imp'],6); A=sorted(atoms(f)); v={a:random.randint(0,1) for a in A}
    g=subst(f,{a:(top if v[a] else P0) for a in A})
    # equivalence to top or p0
    tgt= top if ev(f,v) else P0
    if not taut(('imp',g,tgt)) or not taut(('imp',tgt,g)): bad+=1
print('Thm3.1 pure-imp sigma_v failures',bad)
# ---- Prop 3.2: lattice terms in q,r up to equivalence
Q=('at',0);R=('at',1)
vals=set()
for _ in range(3000):
    f=rnd(['and','or'],6,2)
    vals.add(tuple(ev(f,{0:a,1:b}) for a,b in itertools.product([0,1],repeat=2)))
print('Prop3.2 distinct 2-var lattice term truth tables:',sorted(vals))
