# Brute-force checks of Prop 1.3, Thm 1.5(b),(c) on random finite closure systems and frames.
import random, itertools
random.seed(3)
def closure_from_family(fam, n):
    full=(1<<n)-1
    fam=set(fam)|{full}
    # close under intersections
    ch=True
    while ch:
        ch=False
        for a,b in itertools.combinations(list(fam),2):
            if a&b not in fam: fam.add(a&b); ch=True
    def C(X):
        r=full
        for T in fam:
            if T&X==X: r&=T
        return r
    return fam,C
def popcount(x): return bin(x).count('1')
bad13=bad15b=bad15c=0; cnt=0; cex_c_unsound=None
for trial in range(20000):
    n=random.randint(2,5); full=(1<<n)-1
    fam,C=closure_from_family([random.randrange(1<<n) for _ in range(random.randint(0,5))],n)
    # frame: models given by their theories (subsets of S)
    M=[random.randrange(1<<n) for _ in range(random.randint(0,4))]
    def Mod(X): return [m for m in M if m&X==X]
    def ThMod(X):
        r=full
        for m in Mod(X): r&=m
        return r
    sound=all(C(X)&ThMod(X)==C(X) for X in range(1<<n))
    strong=all(C(X)==ThMod(X) for X in range(1<<n))
    image=set(ThMod(X) for X in range(1<<n))  # = {Th(K)}
    # points
    pts=[T for T in fam if T!=full and any(not(T>>s&1) and all(T2>>s&1 for T2 in fam if T2&T==T and T2!=T) for s in range(n))]
    if sound:
        cnt+=1
        if (image==fam)!=strong: bad13+=1
        if strong != all(P in M for P in pts): bad15b+=1
    # (c): need finite explosive F (always true: S finite) ; Th({m}) != S for all m
    if all(m!=full for m in M):
        coh=[X for X in range(1<<n) if C(X)!=full]
        weak=all(len(Mod(X))>0 for X in coh)
        maxs=[T for T in fam if T!=full and all(T2==full or T2==T for T2 in fam if T2&T==T)]
        cond=all(T in M for T in maxs)
        if sound and weak!=cond: bad15c+=1
        if (not sound) and weak!=cond and cex_c_unsound is None: cex_c_unsound=(n,sorted(fam),M,weak,cond)
print("sound frames tested",cnt,"Prop1.3 failures",bad13,"Thm1.5b failures",bad15b,"Thm1.5c failures (sound)",bad15c)
print("Thm1.5c counterexample without soundness:",cex_c_unsound)
