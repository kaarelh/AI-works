import random, itertools
# check rho <= 1-m <= c*rho; find sup of (1-m)/rho
def rho(p):
    n=len(p); best=0
    for mask in range(1<<n):
        s=sum(p[i] for i in range(n) if mask>>i&1)
        best=max(best,min(s,1-s))
    return best
rng=random.Random(0); worst=0; wp=None
for trial in range(20000):
    n=rng.randint(1,10)
    w=[rng.random()**rng.choice([1,3,8]) for _ in range(n)]
    S=sum(w); p=[x/S for x in w]
    r=rho(p); m=max(p)
    if r>0:
        ratio=(1-m)/r
        assert r<=1-m+1e-12
        if ratio>worst: worst=ratio; wp=p
# uniform on n atoms
for n in [3,5,7,9,11,13]:
    p=[1/n]*n; print(n, (1-max(p))/rho(p))
print('worst random ratio (1-m)/rho =',worst)
