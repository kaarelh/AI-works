import importlib.util,io,contextlib
spec=importlib.util.spec_from_file_location('f','fid_vs.py')
with contextlib.redirect_stdout(io.StringIO()):
    f=importlib.util.module_from_spec(spec); spec.loader.exec_module(f)
m=f.m; C=m.C; x=m.x; z0=m.z0; S=m.S; eq=m.eq; ind=m.ind
Q2=[m.Qsteps[3],m.Qsteps[5]]   # x+0=x, x*0=0  (k'=3 with induction)
I={'eq':ind(eq(C('plus',z0,x),x)),'lt':ind(C('lt',x,S(x))),'not':ind(C('not',eq(S(x),z0))),
   'and':ind(C('and',eq(x,x),C('lt',x,S(x))))}
q=ind(C('ex',C('y'),eq(S(x),C('y'))))
Pneg=[C('st0',C('all',x,eq(z0,S(z0))))]
for k in (3,4):
  for roots in (['eq','lt'],['eq','lt','not'],['eq','lt','not','and']):
    D=Q2+[I[r] for r in roots]
    a,_=f.in_cautious(D,k,[],q); b,_=f.in_cautious(D,k,Pneg,q)
    print(f"k={k} (k'=3), induction roots {roots}: ex-instance accepted without world: {a}; with negative |-all x(0=S0): {b}")
