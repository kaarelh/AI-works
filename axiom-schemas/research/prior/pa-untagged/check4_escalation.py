# (4) Transfer of the escalation lower bound (Thm caution:untagged(i)) to PA's signature {0,S,+,*,=,...}
# and the Sub-encoded induction schema: elastic chains inside inst(sigma_ind), witnessed explicitly.
from pa_common import *
import itertools
def Sn(t,a):
    for _ in range(a): t=S(t)
    return t
def comb(leaves):
    t=leaves[0]
    for l in leaves[1:]: t=add(t,l)
    return t
def query(a,v):   # proper, non-vacuous induction instance: phi = (L_a = v)
    return ind_V(eq(comb([Sn(Z,ai) for ai in a]),v),v)
def tau(a,j,c):   # sigma_ind[P -> eq(T_j, w)], T_j = comb with leaf j = S^{a_j+1}(z_j)
    leaves=[MV('z%d'%i) for i in range(c)]; leaves[j]=Sn(MV('z%d'%j),a[j]+1)
    s=sigma_V(True)
    def sub(t):
        if is_var(t): return eq(comb(leaves),MV('w')) if t[1]=='P' else t
        return (t[0],)+tuple(sub(u) for u in t[1:])
    return sub(s)
LQ=lgg_list([ax_V(A) for A in Q])
def chain(c,nmax,v,base,P0):
    pts=sorted(itertools.product(range(nmax+1),repeat=c),key=lambda a:-sum(a))
    seen=[]; ok=True; N=0
    for a in pts:
        s=query(a,v); N=max(N,size(s))
        assert is_instance(s,sigma_V(True))
        W=base+[tau(a,j,c) for j in range(c)]
        cover=all(any(is_instance(t,w) for w in W) for t in P0+seen)
        miss=not any(is_instance(s,w) for w in W)
        ok&= cover and miss and len(W)<=c+len(base)
        seen.append(s)
    return ok,len(pts),N
print('variant (a): P0 = {}, k slots all used for coordinates')
for k in [2,3,4]:
    for nmax in [1,2,3]:
        ok,L,N=chain(k,nmax,x,[],[])
        print(f'  k={k} n={nmax}: elastic chain valid={ok}, length={(nmax+1)**k}={L}, max step size N={N}')
print('variant (b): P0 = the 7 Q axiom steps; one slot for lgg(Q), k-1 coordinates')
P0=[ax_V(A) for A in Q]
for k in [3,4]:
    for nmax in [1,2]:
        ok,L,N=chain(k-1,nmax,x,[LQ],P0)
        print(f'  k={k} n={nmax}: valid={ok}, length={L}=(n+1)^(k-1), N={N}')
print("variant (c): P0 = Q + induction data all on variable x (else generic); queries induct on y; k-2 coordinates")
P0c=P0+[ind_V(f,x) for f in [eq(add(x,Z),x),IMP(lt(Z,x),eq(x,x)),AND(eq(x,x),lt(x,S(x))),NOT(eq(S(x),Z)),OR(eq(x,Z),lt(Z,x)),ALL(y,eq(add(x,y),add(y,x)))]]
print('  lgg of the induction part of P0c:',show(lgg_list(P0c[7:]))[:120],'...')
spec_x=match(sigma_V(True),sigma_V(True)) # dummy
sx=lgg_list(P0c[7:])
for k in [4,5]:
    for nmax in [1,2]:
        ok,L,N=chain(k-2,nmax,y,[LQ,sx],P0c)
        print(f'  k={k} n={nmax}: valid={ok}, length={L}=(n+1)^(k-2), N={N}')
# size formula: N(a) for the extreme point a=(n,...,n)
for c in [1,2,3,4,5]:
    sizes=[size(query((nn,)*c,x)) for nn in range(4)]
    print(f'  c={c}: size of query((n,..,n)) for n=0..3:',sizes, ' increments:',[sizes[i+1]-sizes[i] for i in range(3)])
