# Thm 6.6(e) repair (after verification): with auxiliary decidable judgments Sub(phi,x,t,psi) ("psi is phi[t/x]")
# recorded as premises, the induction rule  Sub(phi,x,0,a), Sub(phi,x,Sx,b) / |- a & all x(phi -> b) -> all x phi
# is a first-order pattern, and the lgg of generic instances recovers it (contrast ind_lgg.py).
import sys
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T7-checks')
from ttl_sim import lgg
def S(t): return ('S',t)
def subst_var(f,x,t):
    if f==x: return t
    if isinstance(f,tuple):
        if f[0]=='all' and f[1]==x: return f
        return tuple([f[0]]+[subst_var(a,x,t) for a in f[1:]])
    return f
def ind(phi):
    a=subst_var(phi,'x','0'); b=subst_var(phi,'x',S('x'))
    return ('st',('Sub',phi,'x','0',a),('Sub',phi,'x',S('x'),b),
            ('imp',('and',a,('all','x',('imp',phi,b))),('all','x',phi)))
# generic data: the phi's have different root symbols and their substitution results differ
phis=[('eq',('add','x','0'),'x'), ('lt','0',S('x')), ('and',('eq','x','x'),('lt','x',S('x'))),
      ('not',('eq',S('x'),'0')), ('or',('eq','x','0'),('lt','0','x'))]
L=lgg([ind(p) for p in phis])
print('lgg =',L)
target=('st',('Sub','?P','x','0','?A'),('Sub','?P','x',('S','x'),'?B'),
        ('imp',('and','?A',('all','x',('imp','?P','?B'))),('all','x','?P')))
def alpha_eq(s,t,m=None):
    m={} if m is None else m
    if isinstance(s,str) and s.startswith('?'):
        if not (isinstance(t,str) and t.startswith('?')): return False
        if s in m: return m[s]==t
        if t in m.values(): return False
        m[s]=t; return True
    if isinstance(s,str) or isinstance(t,str): return s==t
    return len(s)==len(t) and s[0]==t[0] and all(alpha_eq(a,b,m) for a,b in zip(s[1:],t[1:]))
print('equals the Sub-encoded induction pattern up to renaming:',alpha_eq(L,target))
