import itertools, sympy as sp
imp=lambda a,b:(1-a)|b
# --- Prop 2.9(b),(d): s_c in h_b iff b!=c ; union learner: every h_b axiom follows from {~a_i}
def ell(bit,p): return p if bit==1 else 1-p
for k in range(1,5):
    ok=True
    for b in itertools.product([0,1],repeat=k):
        for c in itertools.product([0,1],repeat=k):
            # h_b |- s_c  iff every valuation satisfying h_b's axioms satisfies s_c
            ent=True
            for v in itertools.product([0,1],repeat=2*k):
                a=v[:k]; p=v[k:]
                if all(imp(a[i],ell(b[i],p[i])) for i in range(k)):
                    s=any(imp(a[i],ell(1-c[i],p[i])) for i in range(k))
                    if not s: ent=False;break
            if ent!=(b!=c): ok=False
    # {~a_i} entails every axiom a_i -> l : trivially true; check consistency of {~a_i} and entailment
    ok2=all(imp(0,x)==1 for x in (0,1))
    print("k",k,"s_c in h_b iff b!=c:",ok," ~a_i |= a_i->l:",ok2)
# --- Prop 2.9(e)/Thm 2.4 memberships: theories T1={p,q},T2={p,~q},T3={~p,q}
T=[lambda p,q:p and q, lambda p,q:p and not q, lambda p,q:(not p) and q]
fs={'p':lambda p,q:p,'q':lambda p,q:q,'~(p&q)':lambda p,q:1-(p&q)}
for name,f in fs.items():
    print(name,[i+1 for i,t in enumerate(T) if all(f(p,q) for p,q in itertools.product([0,1],repeat=2) if t(p,q))])
# majority set must contain p, q, ~(p&q) (each in two theories); pairs:
for i,j in [(0,1),(0,2),(1,2)]:
    miss=[n for n,f in fs.items() if not all(all(f(p,q) for p,q in itertools.product([0,1],repeat=2) if T[x](p,q)) for x in (i,j))]
    print("h%d∩h%d lacks"%(i+1,j+1),miss)
# --- Prop 2.8' example: {p_j} coherent with Cn{~p_i:i<n} iff j>=n  (finite check, 6 atoms)
N=6
for n in range(N+1):
    for j in range(N):
        cons=any(all(v[i]==0 for i in range(n)) and v[j]==1 for v in itertools.product([0,1],repeat=N))
        assert cons==(j>=n)
print("Prop 2.8' coherence pattern OK on",N,"atoms")
# --- Prop 3.11(c): cubic x^3-4x+1
x=sp.symbols('x'); f=x**3-4*x+1
print("disc",sp.discriminant(f,x),"irreducible over Q:",sp.Poly(f,x).is_irreducible, "real roots", [sp.N(r,6) for r in sp.real_roots(f)])
r1=sp.CRootOf(f,2)
print("factor over Q(r1):",sp.factor(f,extension=r1) if False else "skipped (slow)")
a=sp.symbols('a')
K=sp.QQ.algebraic_field(sp.CRootOf(f,0))
print("factor over Q(root0):", sp.factor_list(sp.Poly(f,x,domain=K)))
# --- §6 example 4 counterexample to 'iff'
# atoms p1,p2,q1,q2; K={p1->q1,p2->q2}; A={q1 v q2, ~p1, ~p2}
vals=list(itertools.product([0,1],repeat=4))
KA=lambda p1,p2,q1,q2: imp(p1,q1) and imp(p2,q2) and (q1 or q2) and not p1 and not p2
print("K+A consistent:",any(KA(*v) for v in vals))
print("K+A+per-law converse consistent:",any(KA(*v) and imp(v[2],v[0]) and imp(v[3],v[1]) for v in vals))
print("K+A |= q1:",all(v[2] for v in vals if KA(*v))," K+A |= q2:",all(v[3] for v in vals if KA(*v)))
# sprinkler: K={r->w,s->w,~(r&s)}, A={w}; Clark: w<->(r v s)
vals3=list(itertools.product([0,1],repeat=3))
base=lambda r,s,w: imp(r,w) and imp(s,w) and not(r and s) and w
print("sprinkler + Clark completion consistent:",any(base(*v) and (v[2]==(v[0] or v[1])) for v in vals3))
print("sprinkler + per-law converse consistent:",any(base(*v) and imp(v[2],v[0]) and imp(v[2],v[1]) for v in vals3))
# --- Thm 3.3(a) revised D: the ->-axioms are tautologies
ax=[lambda p,q,r: imp(p,imp(q,p)), lambda p,q,r: imp(imp(p,imp(q,r)),imp(imp(p,q),imp(p,r))),
    lambda p,q,r: imp(imp(1-p,1-q),imp(q,p)), lambda p,q,r: imp(p&q,p), lambda p,q,r: imp(p&q,q),
    lambda p,q,r: imp(p,imp(q,p&q)), lambda p,q,r: imp(p,p|q), lambda p,q,r: imp(q,p|q),
    lambda p,q,r: imp(imp(p,r),imp(imp(q,r),imp(p|q,r))), lambda p,q,r: imp(imp(imp(p,q),p),p)]
print("all D axioms tautologies:",all(a(*v) for a in ax for v in itertools.product([0,1],repeat=3)))
