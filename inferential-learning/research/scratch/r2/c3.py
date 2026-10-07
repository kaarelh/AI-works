import itertools, random
# 3-valued matrix: values 0, H(=0.5), 1; designated {1}; h maps H->1
H=0.5
def h(x): return 1 if x in (1,H) else 0
def NEG(x): return 1-h(x)
def IMP(x,y): return max(1-h(x),h(y))
def AND(x,y): return 1 if (x==1 and y==1) else 0
def OR(x,y): return max(h(x),h(y))
atoms=['p','q','r']
def ev(f,v):
    if isinstance(f,str): return v[f]
    op=f[0]
    if op=='~': return NEG(ev(f[1],v))
    a=ev(f[1],v); b=ev(f[2],v)
    return {'>':IMP,'&':AND,'|':OR}[op](a,b)
def rand(d):
    if d==0 or random.random()<0.3: return random.choice(atoms)
    op=random.choice(['~','>','&','|'])
    if op=='~': return ('~',rand(d-1))
    return (op,rand(d-1),rand(d-1))
vals=list(itertools.product([0,H,1],repeat=3))
def taut(f): return all(ev(f,dict(zip(atoms,v)))==1 for v in vals)
I=lambda a,b:('>',a,b); N=lambda a:('~',a)
ax=[lambda p,q,r:I(p,I(q,p)), lambda p,q,r:I(I(p,I(q,r)),I(I(p,q),I(p,r))), lambda p,q,r:I(I(N(p),N(q)),I(q,p))]
bad=0
for _ in range(3000):
    p,q,r=rand(2),rand(2),rand(2)
    for A in ax:
        if not taut(A(p,q,r)): bad+=1
print("axiom-instance failures:",bad)
print("p>(q>p&q) designated always?", taut(I('p',I('q',('&','p','q')))))
