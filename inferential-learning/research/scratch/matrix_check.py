import itertools
# All 2-element matrices interpreting not (unary), and/or/imp (binary), designated {1}.
# Check which validate a finite set of single-conclusion CPC rules and are non-trivial (do not validate p |- q).
un=list(itertools.product([0,1],repeat=2))        # f(0),f(1)
bi=list(itertools.product([0,1],repeat=4))        # f(00),f(01),f(10),f(11)
def B(f,a,b): return f[2*a+b]
# rules as python predicates over (N,A,O,I) and atoms p,q,r
def rules(N,A,O,I):
    n=lambda a:N[a]; a_=lambda x,y:B(A,x,y); o=lambda x,y:B(O,x,y); i=lambda x,y:B(I,x,y)
    R=[]
    # (premises list, conclusion) as lambdas of p,q
    R.append((lambda p,q:[p,n(p)], lambda p,q:q))           # explosion
    R.append((lambda p,q:[n(n(p))], lambda p,q:p))
    R.append((lambda p,q:[p], lambda p,q:n(n(p))))
    R.append((lambda p,q:[a_(p,q)], lambda p,q:p))
    R.append((lambda p,q:[a_(p,q)], lambda p,q:q))
    R.append((lambda p,q:[p,q], lambda p,q:a_(p,q)))
    R.append((lambda p,q:[p], lambda p,q:o(p,q)))
    R.append((lambda p,q:[q], lambda p,q:o(p,q)))
    R.append((lambda p,q:[o(p,q),n(p)], lambda p,q:q))     # disjunctive syllogism
    R.append((lambda p,q:[p,i(p,q)], lambda p,q:q))
    R.append((lambda p,q:[q], lambda p,q:i(p,q)))
    R.append((lambda p,q:[n(p)], lambda p,q:i(p,q)))
    return R
good=[]
for N in un:
  for A in bi:
    for O in bi:
      for I in bi:
        ok=True
        for prem,conc in rules(N,A,O,I):
            for p,q in itertools.product([0,1],repeat=2):
                if all(x==1 for x in prem(p,q)) and conc(p,q)!=1: ok=False;break
            if not ok: break
        if ok:
            # nontrivial: p |- q fails
            triv = all(not (p==1 and q==0) for p,q in itertools.product([0,1],repeat=2))
            good.append((N,A,O,I))
print(len(good), good)
