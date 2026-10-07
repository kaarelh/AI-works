import random, itertools, math, sys
from terms import *
from unify import *
V=lambda n:('?',n)
A,B=V('A'),V('B')
RULES={
 'andI': ('s2',A,B,('and',A,B)),
 'andE1':('s1',('and',A,B),A),
 'andE2':('s1',('and',A,B),B),
 'orI1': ('s1',A,('or',A,B)),
 'orI2': ('s1',B,('or',A,B)),
 'MP':   ('s2',('imp',A,B),A,B),
}
NATOMS=4
def rand_formula(rng, p_stop=0.55):
    if rng.random()<p_stop: return ('p%d'%rng.randrange(NATOMS),)
    c=rng.choice(['and','or','imp','not'])
    if c=='not': return ('not',rand_formula(rng,p_stop))
    return (c,rand_formula(rng,p_stop),rand_formula(rng,p_stop))
def subst(t,s):
    if is_var(t): return s[t[1]]
    return (t[0],)+tuple(subst(a,s) for a in t[1:])
def sample_step(rng, rule):
    return subst(RULES[rule],{'A':rand_formula(rng),'B':rand_formula(rng)})
def identify_trial(rng, N):
    data={r:[] for r in RULES}
    for _ in range(N):
        r=rng.choice(list(RULES)); data[r].append(sample_step(rng,r))
    ok=True
    for r,P in data.items():
        if not P or not equiv(lgg_list(P),RULES[r]): ok=False
    return ok
if __name__=='__main__':
    rng=random.Random(0)
    for N in [12,24,48,96,192]:
        T=400
        succ=sum(identify_trial(rng,N) for _ in range(T))
        print('N=%d  P(exact identification of all 6 rules)=%.3f'%(N,succ/T))
