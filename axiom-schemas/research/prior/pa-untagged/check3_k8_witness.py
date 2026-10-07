# (2)/(3) PA with all 7 Q axioms, k>=8: explicit members of VS_{H_k}(D) that miss proper induction instances.
from pa_common import *
import random
random.seed(1)
def rterm(v,d):
    r=random.random()
    if d==0 or r<0.3: return random.choice([Z,v,S(Z),y if v!=y else n])
    if r<0.55: return S(rterm(v,d-1))
    if r<0.8: return add(rterm(v,d-1),rterm(v,d-1))
    return mul(rterm(v,d-1),rterm(v,d-1))
def rformula(v,root,d=2):
    if root=='eq': return eq(rterm(v,d),rterm(v,d))
    if root=='lt': return lt(rterm(v,d),rterm(v,d))
    if root=='imp': return IMP(eq(rterm(v,d),rterm(v,d)),eq(rterm(v,d),rterm(v,d)))
    if root=='all': return ALL(m,eq(add(rterm(v,1),m),add(m,rterm(v,1))))
    if root=='and': return AND(eq(rterm(v,d),v),lt(Z,S(v)))
    if root=='not': return NOT(eq(S(rterm(v,d)),Z))
    if root=='or': return OR(eq(v,Z),lt(Z,v))
    if root=='ex': return EX(m,eq(v,add(m,rterm(v,1))))
def sample(roots,rootp,names,N):
    out=[]
    for _ in range(N):
        v=random.choice(names); f=random.choices(roots,rootp)[0]; phi=rformula(v,f)
        if subst(phi,v,Z)==phi: phi=eq(add(v,Z),v)   # keep x free in phi (non-vacuous induction)
        out.append(ind_V(phi,v))
    return out
def check(name,D,witness,queries,k):
    assert len(witness)<=k
    cov=all(any(is_instance(d,w) for w in witness) for d in D)
    print(f'== {name}: |witness|={len(witness)}<=k={k}; witness covers all {len(D)} data: {cov}')
    for qn,q in queries:
        print(f'   misses {qn}: {not any(is_instance(q,w) for w in witness)}  (q is an instance of sigma_ind: {is_instance(q,sigma_V(True))})')
LQ=lgg_list([ax_V(A) for A in Q])
P,X,A_,B_=MV('P'),MV('X'),MV('A'),MV('B')
def spec_root(f,ar):  # sigma_ind[P -> f(z1..zar)]
    zs=[MV('z%d'%i) for i in range(ar)]
    s=sigma_V(True); return match_sub(s,{'P':(f,)+tuple(zs)})
def spec_X(c): return match_sub(sigma_V(True),{'X':c})
def match_sub(t,sub):
    if is_var(t): return sub.get(t[1],t)
    return (t[0],)+tuple(match_sub(a,sub) for a in t[1:])
# realistic usage: induction mostly on equations; names x,y,n
roots=['eq','imp','all','and','not']; rootp=[.6,.2,.1,.05,.05]
D=[ax_V(A) for A in Q]+sample(roots,rootp,[x,y,n],400)
qs=[('or-rooted induction on x',ind_V(OR(eq(x,Z),lt(Z,x)),x)),('ex-rooted induction on x',ind_V(EX(m,eq(x,add(m,m))),x)),
    ('eq-rooted induction on new name w',ind_V(eq(add(Z,w),w),w))]
AR={'eq':2,'lt':2,'imp':2,'and':2,'or':2,'not':1,'all':2,'ex':2}
check('root cover (realistic roots), k=8',D,[LQ]+[spec_root(f,AR[f]) for f in roots],qs[:2],8)
check('name cover (names x,y,n), k=8',D,[LQ]+[spec_X(c) for c in [x,y,n]],qs,8)
# every formula root of the language, 7 of them: cover of ALL clean data in 8 slots
allroots=['eq','not','and','or','imp','all','ex']
D2=[ax_V(A) for A in Q]+sample(allroots,[1/7]*7,VARNAMES,400)
imp_q=('st',('Sub',Z,Z,Z,Z),('Sub',Z,Z,S(Z),Z),IMP(AND(Z,ALL(Z,IMP(Z,Z))),ALL(Z,Z)))
check('all 7 formula roots, k=8 (any clean data)',D2,[LQ]+[spec_root(f,AR[f]) for f in allroots],[('improper instance phi:=0',imp_q)],8)
# all 7 roots used, but every forall-rooted phi binds the same variable m: per-root-class lggs (8 slots)
SIGP=sigma_V(True)
classes={}
for d in D2[7:]:
    classes.setdefault(match(SIGP,d)['P'][0],[]).append(d)
W=[LQ]+[lgg_list(c) for c in classes.values()]
q=ind_V(ALL(w,eq(add(x,w),add(w,x))),x)   # proper, forall-rooted, binds w instead of m
check('all 7 roots used, forall-class binds only m, k=8',D2,W,[('proper forall-w induction',q)],8)
print('   forall-class lgg:',show(lgg_list(classes['all']))[:110])
