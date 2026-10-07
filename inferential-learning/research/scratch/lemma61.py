# Lemma 6.1: pure schema invalid  <=>  some T/F substitution gives a falsified closed instance.
# Validity of a pure schema = validity of its generic instance (metavariables as distinct atoms).
import random, itertools
V=['A','B','C']
def rf(r,d):
    if d==0 or r.random()<0.25: return r.choice(V+['T','F'])
    o=r.choice(['and','or','imp','not'])
    return ('not',rf(r,d-1)) if o=='not' else (o,rf(r,d-1),rf(r,d-1))
def ev(f,v):
    if f=='T': return True
    if f=='F': return False
    if isinstance(f,str): return v[f]
    if f[0]=='not': return not ev(f[1],v)
    a,b=ev(f[1],v),ev(f[2],v)
    return {'and':a and b,'or':a or b,'imp':(not a) or b}[f[0]]
def invalid(prem,concl):
    return any(all(ev(p,v) for p in prem) and not ev(concl,v)
               for v in (dict(zip(V,bits)) for bits in itertools.product([False,True],repeat=3)))
def sub(f,s):
    if isinstance(f,str): return s.get(f,f)
    return tuple([f[0]]+[sub(a,s) for a in f[1:]])
def tf_refutable(prem,concl):
    for bits in itertools.product(['T','F'],repeat=3):
        s=dict(zip(V,bits))
        if all(ev(sub(p,s),{}) for p in prem) and not ev(sub(concl,s),{}): return True
    return False
r=random.Random(7); bad=0; ninv=0
for _ in range(30000):
    prem=[rf(r,3) for _ in range(r.randint(0,2))]; c=rf(r,3)
    a=invalid(prem,c); b=tf_refutable(prem,c); ninv+=a
    if a!=b: bad+=1; print('MISMATCH',prem,c,a,b)
print('schemas 30000, invalid',ninv,'mismatches',bad)
# Cor 6.2(c)/summary 'exactly |F|': AC and its specialization tau2=(T, A->T / A) share the least falsified instance
AC=(['B',('imp','A','B')],'A'); tau2=(['T',('imp','A','T')],'A')
s=(['T',('imp','F','T')],'F')
def is_inst(sch,step):
    th={}
    def m(p,t):
        if p in V:
            if p in th: return th[p]==t
            th[p]=t; return True
        if isinstance(p,str) or isinstance(t,str): return p==t
        return p[0]==t[0] and len(p)==len(t) and all(m(x,y) for x,y in zip(p[1:],t[1:]))
    return len(sch[0])==len(step[0]) and all(m(x,y) for x,y in zip(sch[0]+[sch[1]],step[0]+[step[1]]))
print('s falsified:',all(ev(p,{}) for p in s[0]) and not ev(s[1],{}),'| s in inst(AC):',is_inst(AC,s),'| s in inst(tau2):',is_inst(tau2,s))
