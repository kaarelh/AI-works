# (2) the threshold for PA-type targets: ground premise-free axioms + one premised schema.
# Claim: with all ground axioms in D, the cautious H_k verifier is exact iff Sub_ind(D) is not covered by
# k-1 failure sets (whose union misses some instance).  Paper: sufficient "not covered by k";
# blocking "covered by k-k'+1".  Brute-force test on small cases.
from pa_common import *
import itertools
SIG=sigma_V(True)
MVS=['P','X','A','B']
def theta_of(step):
    return match(SIG,step)
def failure_sets(thetas):
    fs=set()
    for th in thetas:
        for v in MVS: fs.add(('root',v,th[v][0]))
        for u,v in itertools.combinations(MVS,2):
            if th[u]==th[v]: fs.add(('eq',u,v))
    return sorted(fs)
def in_fs(th,F):
    if F[0]=='root': return th[F[1]][0]==F[2]
    return th[F[1]]==th[F[2]]
def min_cover(thetas):
    fs=failure_sets(thetas)
    for r in range(0,len(fs)+1):
        for c in itertools.combinations(fs,r):
            if all(any(in_fs(th,F) for F in c) for th in thetas): return r,c
def run(name,ground,inds,k,queries):
    D=[ax_V(A) for A in ground]+[ind_V(p,v) for p,v in inds]
    th=[theta_of(ind_V(p,v)) for p,v in inds]
    r,c=min_cover(th)
    kp=len(ground)+1
    print(f'== {name}: k={k}, k\'={kp}, |D|={len(D)}; min #failure sets covering Sub_ind(D) = {r} {c}')
    print(f'   paper Thm(a) applies (not covered by k={k})? {r>k};  paper Prop(a) blocks (covered by k-k\'+1={k-kp+1})? {r<=k-kp+1};  claim: exact iff not covered by k-1={k-1}: predicts exact={r>k-1}')
    for qn,q in queries:
        ok,wit=in_cap_vs(q,D,k,True)
        print(f'   query {qn:38s} accepted={ok}' + ('' if ok else '   witness: '+' | '.join(show(l)[:70] for l in wit)))
Q2=[Q[0],Q[3]]
qs=[('and-rooted, var x',ind_V(AND(eq(x,x),lt(x,S(x))),x)),
    ('or-rooted, var y',ind_V(OR(eq(y,Z),lt(Z,y)),y)),
    ('not-rooted, var w (new name)',ind_V(NOT(eq(S(w),Z)),w)),
    ('all-rooted, var x',ind_V(ALL(y,eq(add(x,y),add(y,x))),x)),
    ('eq-rooted, new var w',ind_V(eq(mul(w,Z),Z),w)),
    ('IMPROPER: phi:=0 (a term), x:=0',('st',('Sub',Z,Z,Z,Z),('Sub',Z,Z,S(Z),Z),IMP(AND(Z,ALL(Z,IMP(Z,Z))),ALL(Z,Z))))]
# Case A: phi roots only {eq, imp}: covered by 2 = k-1 failure sets, not by 1 = k-k'+1.
A=[(eq(add(x,Z),x),x),(eq(add(Z,y),y),y),(eq(mul(n,S(Z)),n),n),
   (IMP(lt(Z,x),eq(x,x)),x),(IMP(eq(y,Z),lt(y,S(y))),y),(IMP(lt(n,S(Z)),eq(n,Z)),n)]
run('A (roots eq,imp)',Q2,A,3,qs)
# Case B: roots {eq, imp, and}, names {x,y,n,m}: covered by 3 = k, not by 2 = k-1.
B=A+[(AND(eq(m,m),lt(m,S(m))),m),(AND(lt(Z,S(x)),eq(x,x)),x)]
run('B (roots eq,imp,and)',Q2,B,3,qs)
# Case C: same data as B but k=4: now covered by 3 = k-1 -> claim predicts NOT exact
run('C (= B with k=4)',Q2,B,4,qs[:3])
