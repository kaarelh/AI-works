# Counterexample to the conditional reading of Thm 3.1(b) for randomized verifiers.
# H={R1={a,c}, R2={a,b,c}, R3={a,b}}, P0=empty. Verifier: w.p. eps 'reckless' (accept everything), else VS verifier.
import random
H={'R1':{'a','c'},'R2':{'a','b','c'},'R3':{'a','b'}}
eps=0.01
def run(target, queries, rng):
    reckless = rng.random()<eps
    P=set(); N=set(); trans=[]
    for q in queries:
        VS=[R for R in H.values() if P<=R and not (R&N)]
        inter=set.intersection(*VS); union=set.union(*VS)
        if reckless or q in inter: a='ACC'
        elif q not in union: a='REJ'
        else:
            a='ESC'; (P if q in H[target] else N).add(q)
        trans.append((q,a))
    return trans
rng=random.Random(0)
# soundness: worst case over targets and (all) query sequences of length<=3 over {a,b,c}
import itertools
worst=0
for T in H:
    for L in range(1,4):
        for qs in itertools.product('abc',repeat=L):
            n=20000; bad=0
            for _ in range(n):
                tr=run(T,qs,rng)
                if any(a=='ACC' and q not in H[T] for q,a in tr): bad+=1
            worst=max(worst,bad/n)
print('empirical max Pr[invalid acceptance] over targets/sequences:',worst,'(eps=%g)'%eps)
# conditional acceptance at history h=((c,ACC)) under R*=R2, query b (b not in R1, so b not in cap VS)
n=200000; reach=0; acc=0
for _ in range(n):
    tr=run('R2',['c','b'],rng)
    if tr[0]==('c','ACC'):
        reach+=1; acc+= tr[1][1]=='ACC'
print('Pr[reach h]=%.4f, Pr[ACC b | h]=%.3f  vs delta=%g'%(reach/n, acc/max(reach,1), eps))
