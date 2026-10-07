# [T7 verification] Written by a referee during adversarial verification of T7; re-run by the author (see the Verification log of T7).
# Does first-order lgg (T1 / ttl_sim.py) recover the induction schema or forall-E from instances?
import sys, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T7-checks')
from ttl_sim import lgg, subst, vars_of, isvar
# terms: ('eq',a,b) ('add',a,b) ('S',a) '0' 'x' ; formulas: ('and',f,g) ('imp',f,g) ('all','x',f)
def S(t): return ('S',t)
def add(a,b): return ('add',a,b)
def eq(a,b): return ('eq',a,b)
def subst_var(f,x,t):
    if f==x: return t
    if isinstance(f,tuple):
        if f[0]=='all' and f[1]==x: return f
        return tuple([f[0]]+[subst_var(a,x,t) for a in f[1:]])
    return f
def induction(phi):  # |- phi(0) & all x (phi(x) -> phi(Sx)) -> all x phi(x)
    return ('st', ('imp', ('and', subst_var(phi,'x','0'), ('all','x',('imp',phi,subst_var(phi,'x',S('x'))))), ('all','x',phi)))
phis=[eq(add('x','0'),'x'), eq(add('0','x'),'x'), eq(add(S('x'),'0'),S('x')), eq(add('x',S('0')),S('x'))]
data=[induction(p) for p in phis]
L=lgg(data); print('lgg of induction instances:\n ',L)
# evaluate closed arithmetic sentences over a bounded domain (enough for the counterexample)
def tm(t,env):
    if t=='0': return 0
    if isinstance(t,str): return env[t]
    if t[0]=='S': return tm(t[1],env)+1
    if t[0]=='add': return tm(t[1],env)+tm(t[2],env)
def fm(f,env,B=30):
    o=f[0]
    if o=='eq': return tm(f[1],env)==tm(f[2],env)
    if o=='and': return fm(f[1],env) and fm(f[2],env)
    if o=='imp': return (not fm(f[1],env)) or fm(f[2],env)
    if o=='all': return all(fm(f[2],{**env,f[1]:n}) for n in range(B))
# search small instances of the lgg for a false one
vs=sorted(vars_of(L)); print('metavariables:',vs)
cands=['0','x',S('0'),S('x'),add('x','0')]
for th in itertools.product(cands,repeat=len(vs)):
    inst=subst(L,dict(zip(vs,th)))
    try:
        if not fm(inst[1],{}): print('FALSE instance of the lgg:\n ',inst[1]); break
    except KeyError: pass
# forall-E: Gamma |- all x phi  /  Gamma |- phi[t/x]
def allE(phi,t): return ('st',('all','x',phi), subst_var(phi,'x',t))
d2=[allE(eq(add('x','0'),'x'),'0'), allE(eq(add('0','x'),'x'),S('0')), allE(eq(add(S('x'),'0'),S('x')),S(S('0')))]
L2=lgg(d2); print('\nlgg of forall-E instances:\n ',L2)
vs=sorted(vars_of(L2))
for th in itertools.product(cands,repeat=len(vs)):
    inst=subst(L2,dict(zip(vs,th)))
    try:
        if fm(inst[1],{}) and not fm(inst[2],{}): print('invalid instance of the lgg:',inst); break
    except KeyError: pass
