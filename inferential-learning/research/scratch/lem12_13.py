import sys, random, itertools
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import *
from unify import equiv
rng=random.Random(5)
SIG={'a':0,'b':0,'g':1,'f':2,'h':3}
def rand_term(d, varp, vars_):
    if d==0 or rng.random()<0.3:
        if vars_ and rng.random()<varp: return ('?',rng.choice(vars_))
        return (rng.choice(['a','b']),)
    f=rng.choice(['g','f','h'])
    return (f,)+tuple(rand_term(d-1,varp,vars_) for _ in range(SIG[f]))
def subst(t,th):
    if is_var(t): return th.get(t[1],t)
    return (t[0],)+tuple(subst(a,th) for a in t[1:])
def is_renaming(th, vs):
    imgs=[th.get(v,('?',v)) for v in vs]
    return all(is_var(i) for i in imgs) and len(set(imgs))==len(imgs)
bad12=0; bad13=0; n12=0; n13=0
for it in range(20000):
    vs=['x%d'%i for i in range(rng.randint(0,3))]
    s=rand_term(3,0.5,vs)
    sv=sorted(vars_of(s))
    # Lemma 1.2
    th={v: rand_term(2,0.5,['y0','y1','y2','x0']) for v in sv}
    t=subst(s,th)
    n12+=1
    if mu(t)<mu(s) or ((mu(t)==mu(s)) != is_renaming(th,sv)): bad12+=1; print('L1.2 fail',show(s),th)
    # Lemma 1.3
    n=rng.randint(1,4)
    thetas=[{v: rand_term(2,0.0,[]) for v in sv} for _ in range(n)]
    ts=[subst(s,th) for th in thetas]
    L=lgg_list(ts)
    R=all(len(set(th[v][0] for th in thetas))>1 for v in sv)
    D=all(any(th[x]!=th[y] for th in thetas) for x,y in itertools.combinations(sv,2))
    eq=equiv(L,s)
    # lgg <= s : s generalizes L
    gen = match(s, L) is not None
    n13+=1
    if not gen or eq!=(R and D): bad13+=1; print('L1.3 fail',show(s),[show(u) for u in ts],show(L),R,D)
print('Lemma1.2 tests',n12,'fails',bad12,'| Lemma1.3 tests',n13,'fails',bad13)
