# Size (symbols, prefix encoding, unary numerals S^k 0) of the Euler refutation
#   |- forall x P(x*x+x+41)   (tau)      |- P(40*40+40+41)   (forall-E),  W(P(1681)) = 0
# with P(t) := S0 < t  &  forall y (y<t -> forall z (z<t -> ~(y*z = t)))   (Delta_0)
def num(k): 
    t='0'
    for _ in range(k): t=('S',t)
    return t
def size(f): return 1 if isinstance(f,str) else 1+sum(size(a) for a in f[1:])
def sub(f,v,t):
    if f==v: return t
    if isinstance(f,tuple): return tuple([f[0]]+[sub(a,v,t) for a in f[1:]])
    return f
def P(t): return ('and',('lt',num(1),t),('all','y',('imp',('lt','y',t),('all','z',('imp',('lt','z',t),('not',('eq',('mul','y','z'),t)))))))
t=('add',('add',('mul','x','x'),'x'),num(41))
theta=P(t); ax=('all','x',theta); inst=sub(theta,'x',num(40))
# note: sub also hits the bound 'x' only in ax, not used here
print('|theta|=',size(theta),' |forall x theta|=',size(ax),' |theta(40)|=',size(inst),' refutation size d >=',size(ax)+size(inst))
