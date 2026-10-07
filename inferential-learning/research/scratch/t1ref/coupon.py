import sys, random, math, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import *
from unify import equiv
V=lambda n:('?',n)
# two tagged rules; rule0 = f(x,x,y) (repeated var), rule1 = h(x)
rules=[('f',V('x'),V('x'),V('y')), ('h',V('x'))]
pis=[0.8,0.2]
consts=['a','b','c']
def draw_root(rng,probs):
    u=rng.random(); s=0
    for c_,p in zip(consts,probs):
        s+=p
        if u<s: return (c_,)
    return (consts[-1],)
def sub(t,s):
    if is_var(t): return s[t[1]]
    return (t[0],)+tuple(sub(a,s) for a in t[1:])
def trial(rng,N,probs):
    data=[[],[]]
    for _ in range(N):
        i=0 if rng.random()<pis[0] else 1
        th={v:draw_root(rng,probs) for v in vars_of(rules[i])}
        data[i].append(sub(rules[i],th))
    return all(data[i] and equiv(lgg_list(data[i]),rules[i]) for i in range(2))
def rho_of(probs):
    best=0
    for m in range(1<<len(probs)):
        s=sum(probs[j] for j in range(len(probs)) if m>>j&1); best=max(best,min(s,1-s))
    return best
rng=random.Random(5)
for probs in [[0.9,0.05,0.05],[0.6,0.3,0.1],[1/3,1/3,1/3]]:
    rhoR=rho_of(probs); r=1-sum(p*p for p in probs)
    rho=min(rhoR,r)
    for N in [10,20,40,80]:
        T=4000
        fail=1-sum(trial(rng,N,probs) for _ in range(T))/T
        bound=sum((2*len(vars_of(rules[i]))+math.comb(len(vars_of(rules[i])),2))*math.exp(-N*pis[i]*rho) for i in range(2))
        print(probs, 'N=',N,'fail=%.4f bound=%.4f'%(fail,bound), 'OK' if fail<=bound+0.01 else 'VIOLATION')
