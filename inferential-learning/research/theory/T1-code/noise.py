import random, itertools
from terms import *
from unify import *
from toy_nd import RULES, rand_formula, subst, sample_step
rng=random.Random(1)
# 1) one sporadic error tagged andE1 collapses the lgg
P=[sample_step(rng,'andE1') for _ in range(30)]
err=('s1',('or',('p0',),('p1',)),('p0',))   # "A or B |- A" mis-tagged as andE1
print('clean lgg     :',show(canon(lgg_list(P))))
print('with 1 error  :',show(canon(lgg_list(P+[err]))))
# 2) trimmed version-space verifier with budget e: accepted set = inst(glb{lgg(Q): |P\Q|=e})
def trimmed(P,e):
    Ls=[lgg_list([p for j,p in enumerate(P) if j not in D]) for D in itertools.combinations(range(len(P)),e)]
    return glb(Ls)
for e in [1,2]:
    errs=[err, ('s1',('imp',('p2',),('p3',)),('p3',))][:e]
    g=trimmed(P+errs,e)
    print('trimmed e=%d, %d errors -> accepted schema:'%(e,len(errs)), show(canon(g)) if g else None, ' == andE1?', g is not None and equiv(g,RULES['andE1']))
# with more errors than budget
g=trimmed(P+[err,('s1',('imp',('p2',),('p3',)),('p3',))],1)
print('trimmed e=1, 2 errors ->', show(canon(g)) if g else None)
# 3) systematic fallacy: affirming the consequent tagged as MP, at rate alpha
def mp_data(n, alpha):
    out=[]
    for _ in range(n):
        A_=rand_formula(rng); B_=rand_formula(rng)
        if rng.random()<alpha: out.append(('s2',('imp',A_,B_),B_,A_))  # fallacy
        else: out.append(('s2',('imp',A_,B_),A_,B_))
    return out
D=mp_data(40,0.15)
print('MP data with 15% systematic fallacy, lgg:', show(canon(lgg_list(D))))
