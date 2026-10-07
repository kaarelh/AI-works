# Def 4.0 Lindenbaum semantics M_i = Fix(C_i)\{L_i}: brute-force Thm 4.1(c), Cor 4.2 (non-triviality and explosive-falsum readings)
import random, itertools
rng=random.Random(3)
def rand_moore(n):
    full=(1<<n)-1; fam={full}
    for _ in range(rng.randint(0,5)): fam.add(rng.randrange(1<<n))
    ch=True
    while ch:
        ch=False
        for a in list(fam):
            for b in list(fam):
                if a&b not in fam: fam.add(a&b); ch=True
    return sorted(fam)
def C(fam,X,n):
    out=(1<<n)-1
    for T in fam:
        if X&~T==0: out&=T
    return out
mism=0; cor_mis=0; fals_mis=0; fals_tested=0; systems=0; nonexp_gap=0
for trial in range(600):
    I=[0,1]; n=[rng.randint(2,3) for _ in I]; full=[(1<<n[i])-1 for i in I]
    fam=[rand_moore(n[i]) for i in I]
    M=[[T for T in fam[i] if T!=full[i]] for i in I]
    if any(len(M[i])>6 for i in I): continue
    K=[rng.randrange(1<<n[i]) if rng.random()<0.5 else 0 for i in I]
    G=[rng.randrange(1<<n[i]) if rng.random()<0.3 else 0 for i in I]
    bridges=[]
    for _ in range(rng.randint(0,4)):
        prem=[(j,rng.randrange(n[j])) for j in I if rng.random()<0.6]
        h=rng.choice(I); bridges.append((prem,h,rng.randrange(n[h])))
    # Der
    T=[C(fam[i],K[i]|G[i],n[i]) for i in I]
    ch=True
    while ch:
        ch=False
        for prem,h,psi in bridges:
            if all(T[j]>>f&1 for j,f in prem) and not T[h]>>psi&1:
                T[h]=C(fam[h],T[h]|1<<psi,n[h]); ch=True
    # LMS
    def sat(ci,f,i): return all(m>>f&1 for m in ci)
    def satset(ci,X): return all(X&~m==0 for m in ci)
    models=[]
    for c0 in range(1<<len(M[0])):
        for c1 in range(1<<len(M[1])):
            c=[[M[0][a] for a in range(len(M[0])) if c0>>a&1],[M[1][a] for a in range(len(M[1])) if c1>>a&1]]
            if not all(satset(c[i],K[i]|G[i]) for i in I): continue
            if all((not all(sat(c[j],f,j) for j,f in prem)) or sat(c[h],psi,h) for prem,h,psi in bridges):
                models.append(c)
    systems+=1
    for i in I:
        for f in range(n[i]):
            mc=bool(T[i]>>f&1); lms=all(sat(c[i],f,i) for c in models)
            mism+= mc!=lms
    for D in ([0],[1],[0,1]):
        lhs=all(T[i]!=full[i] for i in D); rhs=any(all(c[i] for i in D) for c in models)
        cor_mis+= lhs!=rhs
    # falsum reading: bot = formula 0 in context 0; explosive iff C({0}) = full
    explosive = C(fam[0],1,n[0])==full[0]
    if explosive:
        fals_tested+=1
        fals_mis += ((T[0]>>0&1)==1) != (T[0]==full[0])
    else:
        if (T[0]>>0&1) and T[0]!=full[0]: nonexp_gap+=1
print("systems",systems,"Thm4.1(c) mismatches",mism,"Cor4.2 non-triviality mismatches",cor_mis)
print("explosive-falsum systems",fals_tested,"falsum-vs-nontriviality mismatches",fals_mis,"; non-explosive gaps found",nonexp_gap)
