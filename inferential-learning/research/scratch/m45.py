import itertools
# Independent re-check of Prop 4.5, all designated sets D, plus rule-redundancy analysis
un=list(itertools.product([0,1],repeat=2)); bi=list(itertools.product([0,1],repeat=4))
def B(f,a,b): return f[2*a+b]
names=['explosion','nnE','nnI','andE1','andE2','andI','orI1','orI2','DS','MP','q>p->q','~p>p->q']
def rules(N,A,O,I):
    n=lambda a:N[a]; c=lambda x,y:B(A,x,y); o=lambda x,y:B(O,x,y); i=lambda x,y:B(I,x,y)
    return [(lambda p,q:[p,n(p)],lambda p,q:q),(lambda p,q:[n(n(p))],lambda p,q:p),(lambda p,q:[p],lambda p,q:n(n(p))),
            (lambda p,q:[c(p,q)],lambda p,q:p),(lambda p,q:[c(p,q)],lambda p,q:q),(lambda p,q:[p,q],lambda p,q:c(p,q)),
            (lambda p,q:[p],lambda p,q:o(p,q)),(lambda p,q:[q],lambda p,q:o(p,q)),(lambda p,q:[o(p,q),n(p)],lambda p,q:q),
            (lambda p,q:[p,i(p,q)],lambda p,q:q),(lambda p,q:[q],lambda p,q:i(p,q)),(lambda p,q:[n(p)],lambda p,q:i(p,q))]
def valid(rule,D):
    prem,conc=rule
    return all(not(all(x in D for x in prem(p,q)) and conc(p,q) not in D) for p,q in itertools.product([0,1],repeat=2))
for D in [set(),{0},{1},{0,1}]:
    good=[]; cnt=0
    for N in un:
      for A in bi:
        for O in bi:
          for I in bi:
            cnt+=1
            R=rules(N,A,O,I)
            if all(valid(r,D) for r in R): good.append((N,A,O,I))
    # nontrivial: some sequent fails; p|-q fails iff exists a in D, b notin D
    nontriv = lambda: any(a in D and b not in D for a in (0,1) for b in (0,1))
    print("D=",D,"matrices",cnt,"validating all 12:",len(good),"nontrivial(p|-q fails):",nontriv(), good[:3])
# redundancy: drop each rule, D={1}
D={1}
for j in range(12):
    good=[]
    for N in un:
      for A in bi:
        for O in bi:
          for I in bi:
            R=rules(N,A,O,I)
            if all(valid(r,D) for k,r in enumerate(R) if k!=j): good.append((N,A,O,I))
    print("drop",names[j],"->",len(good))
