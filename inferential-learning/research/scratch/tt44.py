import itertools
# Structural meanings of the form V = {d o h : h: Fm -> A homomorphism} for a matrix (A, ops, Dset).
# TT(p,q) satisfied by all v in V  <=>  per-connective conditions on all (a,b) in A^2.
# The 11 schemata as conditions on (da, db, dnot_a | dc) :
def cond_not(da, dna): return [not(da and dna), (da or dna)]           # p,~p |>  ;  |> p,~p
def cond_and(da,db,dc): return [not(dc and not da), not(dc and not db), not(da and db and not dc)]
def cond_or(da,db,dc):  return [not(da and not dc), not(db and not dc), not(dc and not da and not db)]
def cond_imp(da,db,dc): return [(da or dc), not(db and not dc), not(da and dc and not db)]
names=['p,~p|>','|>p,~p','and1','and2','andI','orI1','orI2','orE','|>p,p->q','q|>p->q','MP']
def check_size(k):
    A=range(k)
    results={'all11_nonBV':0,'all11_total':0}
    drop_witness={j:None for j in range(11)}
    for Dbits in itertools.product([0,1],repeat=k):
        d=lambda a:Dbits[a]
        # per-connective: set of tables satisfying each subset of conditions
        nots=list(itertools.product(A,repeat=k))
        bins=list(itertools.product(A,repeat=k*k))
        def okN(f,skip=None):
            return all(all(c for i,c in enumerate(cond_not(d(a),d(f[a]))) if i!=skip) for a in A)
        def okB(f,cf,skip=None):
            return all(all(c for i,c in enumerate(cf(d(a),d(b),d(f[a*k+b]))) if i!=skip) for a in A for b in A)
        # with all 11: is d o h always a homomorphism onto 2 (V=BV)?  V subset BV is automatic from conditions;
        # V = BV needs both a designated and undesignated element: ensured if some f_not exists (TT-not forces it)
        Ns=[f for f in nots if okN(f)]; As=[f for f in bins if okB(f,cond_and)]
        Os=[f for f in bins if okB(f,cond_or)]; Is=[f for f in bins if okB(f,cond_imp)]
        tot=len(Ns)*len(As)*len(Os)*len(Is)
        results['all11_total']+=tot
        if tot and (all(Dbits) or not any(Dbits)): results['all11_nonBV']+=tot
        # drop each schema: find a matrix where some v=d o h is NOT Boolean (so V != BV)
        for j in range(11):
            if drop_witness[j] is not None: continue
            if j<2: Nj=[f for f in nots if okN(f,skip=j)]
            else: Nj=Ns
            Aj=[f for f in bins if okB(f,cond_and,skip=j-2)] if 2<=j<5 else As
            Oj=[f for f in bins if okB(f,cond_or,skip=j-5)] if 5<=j<8 else Os
            Ij=[f for f in bins if okB(f,cond_imp,skip=j-8)] if 8<=j<11 else Is
            if not(Nj and Aj and Oj and Ij): continue
            # need a non-homomorphic d: check in the connective whose schema was dropped
            def nonhomN(f): return any(d(f[a])!=1-d(a) for a in A)
            def nonhomB(f,op): return any(d(f[a*k+b])!=op(d(a),d(b)) for a in A for b in A)
            if j<2: cand=[f for f in Nj if nonhomN(f)]
            elif j<5: cand=[f for f in Aj if nonhomB(f,lambda x,y:x&y)]
            elif j<8: cand=[f for f in Oj if nonhomB(f,lambda x,y:x|y)]
            else: cand=[f for f in Ij if nonhomB(f,lambda x,y:(1-x)|y)]
            # also require V nonempty (always) -- the 12th datum
            if cand: drop_witness[j]=(Dbits,cand[0])
    return results,drop_witness
for k in (2,3):
    r,w=check_size(k)
    print("size",k,r)
    for j in range(11): print("   drop",names[j],"-> non-Boolean structural V exists:",w[j] is not None, w[j])
