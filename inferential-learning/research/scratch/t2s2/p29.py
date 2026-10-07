import itertools
# Prop 2.9(b): atoms a_1..a_k, p_1..p_k. h_b = Cn_CPC{a_i -> l_i^{b_i}}, l^1=p, l^0=~p.
# s_c = OR_i (a_i -> l_i^{1-c_i}). Claim: |- s_c in h_b iff b != c.
def lit(bit,p): return p if bit==1 else 1-p
def imp(x,y): return (1-x)|y
for k in range(1,5):
    vals=list(itertools.product([0,1],repeat=2*k))
    B=list(itertools.product([0,1],repeat=k))
    ok=True
    for b in B:
        mods=[v for v in vals if all(imp(v[i],lit(b[i],v[k+i])) for i in range(k))]
        for c in B:
            sc_valid=all(any(imp(v[i],lit(1-c[i],v[k+i])) for i in range(k)) for v in mods)
            if sc_valid != (b!=c): ok=False; print("FAIL",k,b,c)
    # union of all h_b is coherent: all h_b satisfied by any valuation with all a_i false
    print("k",k,"claim s_c in h_b iff b!=c:",ok)

# Simulate ANY oligarchic learner (S_t nonempty, R_hat subset of some member of VS) vs adaptive adversary
# Adversary: pick c with h_c in S_t, present s_c (valid for any target != c). Error since s_c not in h_c >= R_hat.
# Count errors until |VS|=1.  Show: errors = 2^k - 1 regardless of learner's S_t choice (as long as S_t nonempty).
import random
for k in range(1,6):
    worst=0
    for trial in range(200):
        VS=set(itertools.product([0,1],repeat=k))
        errs=0
        while len(VS)>1:
            n=len(VS)
            # learner OH: pick random coalition of >= half (uniform weights)
            size=random.randint((n+1)//2,n)
            S=random.sample(sorted(VS),size)
            c=S[0]          # adversary picks a coalition member
            VS.remove(c)    # positive datum s_c deletes exactly h_c (s_c in h_b for all b!=c)
            errs+=1
        worst=max(worst,errs)
    print("k",k,"OH incompleteness errors forced:",worst,"= 2^k-1:",2**k-1)
