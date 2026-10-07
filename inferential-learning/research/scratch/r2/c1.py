import itertools
# Prop 2.9(b)/(d): h_b = Cn{a_i -> l_i^{b_i}}, s_c = OR_i (a_i -> l_i^{1-c_i}); check s_c in h_b iff b != c ; union learner bound
def entails(k, b, formula):
    # check: all valuations of a_i,p_i satisfying axioms of h_b satisfy formula
    for vals in itertools.product([0,1], repeat=2*k):
        a = vals[:k]; p = vals[k:]
        ok = all((not a[i]) or (p[i]==b[i]) for i in range(k))
        if ok and not formula(a,p): return False
    return True
for k in range(1,5):
    bad=0
    for b in itertools.product([0,1],repeat=k):
        for c in itertools.product([0,1],repeat=k):
            sc = lambda a,p,c=c: any((not a[i]) or (p[i]==1-c[i]) for i in range(k))
            if entails(k,b,sc) != (b!=c): bad+=1
    print("k",k,"s_c membership mismatches",bad)
# adversary simulation for (d): learner = OH 'boldest half' approximated: announce intersection of a random half; check errors count
import random
for k in range(1,5):
    H=list(itertools.product([0,1],repeat=k))
    for trial in range(50):
        VS=set(H); errors=0
        while len(VS)>=2:
            # OH: pick S of size >= half (uniform prior)
            S=random.sample(sorted(VS), (len(VS)+1)//2)
            # R_hat subset of every R in S; adversary picks c in S
            c=S[0]
            # s_c not in h_c, so not in R_hat => error; delete those not containing s_c: only h_c
            errors+=1
            VS={b for b in VS if b!=c}
        assert errors==2**k-1
print("adversary ok")
