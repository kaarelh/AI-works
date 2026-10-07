# Thm 4.5(c): world-family consequence = CPC consequence of tagged K_i + bridge axioms + tagged Gamma.
import random, itertools
rng=random.Random(5)
na=2; NV=1<<na  # local valuations per context
def rf(p): return sum(1<<v for v in range(NV) if rng.random()<p)
mis=0; mis_noK=0; tests=0
for trial in range(3000):
    I=range(rng.randint(2,3))
    K=[rf(0.75) for _ in I]; G=[rf(0.85) for _ in I]
    br=[]
    for _ in range(rng.randint(0,4)):
        prem=[(j,rf(0.5)) for j in I if rng.random()<0.5]; h=rng.choice(list(I)); br.append((prem,h,rf(0.5)))
    # world families: tuples of local valuations
    fams=list(itertools.product(range(NV),repeat=len(I)))
    def isW(w,useK=True,useG=True):
        if useK and not all(K[i]>>w[i]&1 for i in I): return False
        if useG and not all(G[i]>>w[i]&1 for i in I): return False
        return all((not all(f>>w[j]&1 for j,f in prem)) or (psi>>w[h]&1) for prem,h,psi in br)
    W=[w for w in fams if isW(w)]
    # tagged CPC: valuations of disjoint union of atoms = same tuples; axioms = tagged K, bridge material conditionals, tagged Gamma
    taggedmodels=[w for w in fams if all(K[i]>>w[i]&1 for i in I) and all(G[i]>>w[i]&1 for i in I)
                  and all((not all(f>>w[j]&1 for j,f in prem)) or (psi>>w[h]&1) for prem,h,psi in br)]
    noK=[w for w in fams if all((not all(f>>w[j]&1 for j,f in prem)) or (psi>>w[h]&1) for prem,h,psi in br)]
    for i in I:
        for phi in range(1<<NV):
            tests+=1
            a=all(phi>>w[i]&1 for w in W); b=all(phi>>w[i]&1 for w in taggedmodels); c=all(phi>>w[i]&1 for w in noK)
            mis+= a!=b; mis_noK+= a!=c
print("tests",tests,"mismatches with tagged K and Gamma:",mis,"; mismatches if K, Gamma omitted:",mis_noK)
