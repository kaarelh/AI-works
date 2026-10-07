import sys
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T7-checks')
from ttl_sim import lgg
def S(t): return ('S',t)
def add(a,b): return ('add',a,b)
def eq(a,b): return ('eq',a,b)
# quantifier swap fallacy: all x ex y A / ex y all x A  (A a formula metavariable, x,y fixed names)
def qswap(A): return ('st', ('all','x',('ex','y',A)), ('ex','y',('all','x',A)))
As=[eq(add('x','0'),'y'), eq('y',S('x')), ('and',eq('x','x'),eq(add('y','y'),'0')), eq(add(S('x'),'y'),S(S('0')))]
print(lgg([qswap(A) for A in As]))
