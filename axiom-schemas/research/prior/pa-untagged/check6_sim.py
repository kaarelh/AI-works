# Monte Carlo for the artificial distribution of check5: exactness <=> all 7 Q seen and >= k distinct phi-roots
# among induction steps (x fixed, proper non-vacuous data; failure sets for A,B coincide a.s. with those of P).
import random
random.seed(0)
def fail_rate(N,K,trials=20000,r=9,piG=0.1,pi=0.3):
    bad=0
    for _ in range(trials):
        seenQ=set(); roots=set()
        for _ in range(N):
            u=random.random()
            if u<7*piG: seenQ.add(int(u/piG))
            else: roots.add(random.randrange(r))
        if len(seenQ)<7 or len(roots)<=K: bad+=1
    return bad/trials
for N in [40,52,60,70,80,97]:
    print(N,'untagged (k-1=7) fail:',fail_rate(N,7),' paper-style k=8 criterion fail:',fail_rate(N,8))
