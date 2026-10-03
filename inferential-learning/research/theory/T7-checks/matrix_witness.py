# Find a finite matrix (values V, designated D, implication table f, value of F) such that
#  - every S and DN instance is designated (for all assignments),
#  - AC preserves designation: b in D and f(a,b) in D  ==>  a in D,
#  - F is not designated,
#  - context A1 = {q, p>q, p>F} is satisfiable (some p,q values make all three designated).
# Such a matrix proves {S,DN,AC} coherent on {empty, A1} for derivations of ANY length (soundness).
import itertools
def search(n):
    V=range(n)
    for D in itertools.chain.from_iterable(itertools.combinations(V,k) for k in range(1,n)):
        D=set(D)
        for Fv in V:
            if Fv in D: continue
            for tab in itertools.product(V,repeat=n*n):
                f=lambda x,y: tab[x*n+y]
                if not all(f(f(f(a,Fv),Fv),a) in D for a in V): continue
                if not all(f(f(a,f(b,c)),f(f(a,b),f(a,c))) in D for a in V for b in V for c in V): continue
                if not all((a in D) for a in V for b in V if b in D and f(a,b) in D): continue
                if not any(q in D and f(p,q) in D and f(p,Fv) in D for p in V for q in V): continue
                return D,Fv,tab
    return None
for n in [2,3]:
    r=search(n); print(n,r)
    if r: break
