# Non-standard semantics showing that A1,A2,A3 + MP + the RULES p&q|>p, p&q|>q, p,q|>p&q
# do NOT generate classical consequence: p->(q->(p&q)) is not a theorem.
# Theta* defined by recursion on complexity:  v_s(a&b)=1 iff a in Theta* and b in Theta*.
import itertools, functools, random
random.seed(0)
def atoms(f,acc=None):
    if acc is None: acc=set()
    if f[0]=='at': acc.add(f[1])
    for g in f[1:]:
        if isinstance(g,tuple): atoms(g,acc)
    return acc
@functools.lru_cache(None)
def inTheta(f):
    A=sorted(atoms(f))
    return all(val(f,tuple(zip(A,b))) for b in itertools.product([0,1],repeat=len(A)))
def val(f,s):
    s=dict(s) if not isinstance(s,dict) else s
    t=f[0]
    if t=='at': return s[f[1]]
    if t=='not': return 1-val(f[1],s)
    if t=='imp': return (1-val(f[1],s))|val(f[2],s)
    if t=='and': return 1 if (inTheta(f[1]) and inTheta(f[2])) else 0
p,q,r=('at',0),('at',1),('at',2)
I=lambda a,b:('imp',a,b); N=lambda a:('not',a); C=lambda a,b:('and',a,b)
def rnd(d):
    if d==0 or random.random()<0.3: return ('at',random.randrange(3))
    c=random.choice(['not','imp','imp','and'])
    if c=='not': return N(rnd(d-1))
    return (c,rnd(d-1),rnd(d-1))
# axiom instances
bad=0
for _ in range(3000):
    a,b,c=rnd(3),rnd(3),rnd(3)
    for ax in [I(a,I(b,a)), I(I(a,I(b,c)),I(I(a,b),I(a,c))), I(I(N(a),N(b)),I(b,a))]:
        if not inTheta(ax): bad+=1
print('axiom instances outside Theta*:',bad)
# closure under MP, and-I, and-E on random pairs
F=[rnd(3) for _ in range(400)]
T=[f for f in F if inTheta(f)]
mpbad=sum(1 for a in F for b in F if inTheta(a) and inTheta(I(a,b)) and not inTheta(b))
andI=sum(1 for a in T for b in T if not inTheta(C(a,b)))
andE=sum(1 for a in F for b in F[:60] if inTheta(C(a,b)) and not (inTheta(a) and inTheta(b)))
print('MP violations',mpbad,' andI violations',andI,' andE violations',andE)
for f,name in [(I(p,I(q,C(p,q))),'p->(q->(p&q))'),(I(C(p,q),p),'(p&q)->p'),(C(I(p,p),I(q,q)),'(p->p)&(q->q)')]:
    print(name,'in Theta*?',inTheta(f))
