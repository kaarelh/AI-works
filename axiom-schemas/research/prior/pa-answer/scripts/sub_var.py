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
def ind(phi,v):
    a=subst_var(phi,v,'0'); b=subst_var(phi,v,S(v))
    return ('st',('Sub',phi,v,'0',a),('Sub',phi,v,S(v),b),
            ('imp',('and',a,('all',v,('imp',phi,b))),('all',v,phi)))
data=[ind(('eq',('add','x','0'),'x'),'x'), ind(('lt','0',S('y')),'y'), ind(('and',('eq','x','x'),('lt','x',S('x'))),'x'),
      ind(('not',('eq',S('y'),'0')),'y'), ind(('or',('eq','x','0'),('lt','0','x')),'x')]
L=lgg(data); print('lgg with induction variables x and y:\n ',L)
