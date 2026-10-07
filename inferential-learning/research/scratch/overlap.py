# Prop 2.4(c) check: is  ∩{R_Σ : Σ maximal clean}  =  R_{Σ^P \ ∪C_d} ?  (instance level vs schema level)
import sys, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T7-checks')
from ttl_sim import GEN, FAL, unify, resolve, subst, vars_of, match, valid_step
MP=GEN['MP']; AC=FAL['AC']
th={}
ACr=subst(AC,{v:v+'_r' for v in vars_of(AC)})
ok=unify(MP,ACr,th); common=resolve(MP,th)
print('MP =',MP); print('AC =',AC); print('unifiable:',ok,' most general common instance:',common)
# a ground common instance
g=subst(common,{v:('imp','p0','p1') for v in vars_of(common)})
print('ground common instance:',g,' matches MP:',match(MP,g,{}),' matches AC:',match(AC,g,{}),' classically valid:',valid_step(g))
