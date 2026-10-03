# Check Lemma 2.3: for a finite family C of nonempty subsets of [n]:
#  (a) x lies in some minimal hitting set  <=>  x lies in some inclusion-minimal member of C
#  (b) the minimal hitting set is unique   <=>  every minimal member is a singleton
#  (c) intersection of maximal C-free sets (sets containing no member) = [n] minus union of minimal members
import random, itertools
def minimal(fam):
    return [a for a in fam if not any(b!=a and b & ~a==0 for b in fam)]
def hits(T,fam): return all(T & e for e in fam)
def min_transversals(n,fam):
    ts=[T for T in range(1<<n) if hits(T,fam)]
    return minimal(ts)
def max_free(n,fam):
    fs=[S for S in range(1<<n) if not any(e & ~S==0 for e in fam)]
    return [S for S in fs if not any(S!=R and S & ~R==0 for R in fs)]
rng=random.Random(1); bad=0; trials=0
for trial in range(4000):
    n=rng.randint(1,7); m=rng.randint(1,6)
    fam=list({rng.randint(1,(1<<n)-1) for _ in range(m)})
    mins=minimal(fam); mt=min_transversals(n,fam)
    U_mt=0
    for T in mt: U_mt|=T
    U_me=0
    for e in mins: U_me|=e
    a = (U_mt==U_me)
    b = ((len(mt)==1) == all(bin(e).count('1')==1 for e in mins))
    I=(1<<n)-1
    for S in max_free(n,fam): I&=S
    c = (I == ((1<<n)-1) & ~U_me)
    trials+=1
    if not (a and b and c): bad+=1; print('FAIL',n,fam,a,b,c)
print('trials',trials,'failures',bad)
