# Fidelity check: PA, untagged H_k, noise-free. Encoding follows T7-checks/ind_sub_lgg.py
# (bound variable 'x' fixed; metavariables P,A,B), with Q's axioms as premise-free steps 'st0'.
import sys
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import lgg_list, is_instance, show, canon
V=lambda n:('?',n)
def C(s,*a): return (s,)+tuple(a)
x=C('x'); y=C('y'); z0=C('0')
def S(t): return C('S',t)
def subst(f,var,t):
    if f==var: return t
    if len(f)>1:
        if f[0] in('all','ex') and f[1]==var: return f
        return (f[0],)+tuple(subst(a,var,t) for a in f[1:])
    return f
def ind(phi):
    a=subst(phi,x,z0); b=subst(phi,x,S(x))
    return C('st3',C('Sub',phi,x,z0,a),C('Sub',phi,x,S(x),b),
             C('imp',C('and',a,C('all',x,C('imp',phi,b))),C('all',x,phi)))
sigma=C('st3',C('Sub',V('P'),x,z0,V('A')),C('Sub',V('P'),x,S(x),V('B')),
        C('imp',C('and',V('A'),C('all',x,C('imp',V('P'),V('B')))),C('all',x,V('P'))))
eq=lambda a,b:C('eq',a,b); plus=lambda a,b:C('plus',a,b); times=lambda a,b:C('times',a,b)
Q=[C('all',x,C('not',eq(S(x),z0))),
   C('all',x,C('all',y,C('imp',eq(S(x),S(y)),eq(x,y)))),
   C('all',x,C('or',eq(x,z0),C('ex',y,eq(x,S(y))))),
   C('all',x,eq(plus(x,z0),x)),
   C('all',x,C('all',y,eq(plus(x,S(y)),S(plus(x,y))))),
   C('all',x,eq(times(x,z0),z0)),
   C('all',x,C('all',y,eq(times(x,S(y)),plus(times(x,y),x))))]
Qsteps=[C('st0',q) for q in Q]
# two generic induction formulas per root (x free, different subterms), 8 formula roots
lt=lambda a,b:C('lt',a,b)
byroot={
 'eq':[eq(plus(z0,x),x), eq(times(x,S(z0)),plus(x,z0))],
 'lt':[lt(x,S(x)), lt(z0,plus(x,S(z0)))],
 'not':[C('not',eq(S(x),z0)), C('not',lt(x,x))],
 'and':[C('and',eq(x,x),lt(x,S(x))), C('and',lt(z0,S(x)),eq(plus(x,z0),x))],
 'or':[C('or',eq(x,z0),lt(z0,x)), C('or',lt(x,z0),eq(times(x,z0),z0))],
 'imp':[C('imp',eq(x,z0),eq(plus(x,x),z0)), C('imp',lt(z0,x),C('not',eq(x,z0)))],
 'all':[C('all',y,eq(plus(x,y),plus(y,x))), C('all',C('z'),lt(x,plus(x,S(C('z')))))],
 'ex':[C('ex',y,eq(S(x),y)), C('ex',C('z'),lt(x,C('z')))],
}
for r,fs in byroot.items():
    for f in fs: assert is_instance(ind(f),sigma), r
# genericity within each root class: lgg of the class equals sigma[P -> r(...)]
roots_in_data=['eq','lt','not','and','or','imp','all']   # 7 = k-1 roots, k=8
D=Qsteps+[ind(f) for r in roots_in_data for f in byroot[r]]
merged=lgg_list(Qsteps)
print('lgg of the 7 Q-axiom steps =',show(merged))
slots=[merged]+[lgg_list([ind(f) for f in byroot[r]]) for r in roots_in_data]
print('number of slots =',len(slots))
for s in slots[1:]: print('  slot:',show(s))
print('h covers D:',all(any(is_instance(d,s) for s in slots) for d in D))
miss=ind(byroot['ex'][0])
print('well-formed induction instance with root ex:',show(miss)[:80],'...')
print('  in R* (instance of sigma):',is_instance(miss,sigma))
print('  in h:',any(is_instance(miss,s) for s in slots))
# Thm (a) hypothesis: is Sub_ind(D) covered by k=8 failure sets? roots used = 7 <= 8, so yes -> (a) silent
print('distinct P-roots in data:',len(roots_in_data))
# merged slot has a false instance: |- all x (0 = S0)
bad=C('st0',C('all',x,eq(z0,S(z0))))
print('merged slot covers |- all x (0=S0):',is_instance(bad,merged))
# Prop (a) of the paper with k-k'+1 = 1 specialization would need all induction data to share one root
