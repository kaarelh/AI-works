"""Verify stored d4 cone and algebraic-dual certificates without optimization."""
import itertools,json
from pathlib import Path
from fractions import Fraction as F
import numpy as np
import sympy as sp
ROOT=Path(__file__).resolve().parent

def sign(a,b):
    a=F(a);b=F(b)
    if not b:return (a>0)-(a<0)
    if not a:return (b>0)-(b<0)
    if a>0 and b>0:return 1
    if a<0 and b<0:return -1
    delta=a*a-15*b*b
    return ((delta>0)-(delta<0))*(1 if a>0 else -1)

def run():
    a=np.load(ROOT/'d4_certificate_input.npz');X=a['X'].astype(int);D=a['D'].astype(int)
    expected_X=np.c_[np.ones(16,dtype=int),np.array(list(itertools.product((-1,1),repeat=4)))]
    assert np.array_equal(a['X'],expected_X)and np.array_equal(a['D'],D)and np.all((D==0)|(D==1))
    maps=[]
    for perm in itertools.permutations(range(4)):
        for flip in itertools.product((-1,1),repeat=4):maps.append(((X[:,1:][:,perm]*flip+1)//2)@np.array([8,4,2,1]))
    maps=np.array(maps);weights=2**np.arange(16,dtype=np.int64);canonical=np.full(65536,-1,dtype=int);feasible=set()
    certificates=json.load(open(ROOT/'d4_exact_cone_completeness.json'))['certificates']
    for row in certificates:
        code=row['code'];orbit=((code>>maps)&1)@weights;orbit=np.unique(np.r_[orbit,65535-orbit]);assert min(orbit)==code and len(orbit)==row['size']
        assert np.all(canonical[orbit]==-1);canonical[orbit]=code
        y=np.array([1 if code>>i&1 else -1 for i in range(16)]);A=y[:,None]*X
        if row['feasible']:
            w=np.array(list(map(F,row['w'])),dtype=object);assert all(v>=1 for v in A@w);feasible.update(map(int,orbit))
        else:
            q=np.array(list(map(F,row['q'])),dtype=object);assert all(v>=0 for v in q)and sum(q)==1 and all(v==0 for v in A.T@q)
    assert np.all(canonical>=0)and np.array_equal(canonical,a['canonical'])
    assert feasible==set(map(int,D@weights))and len(feasible)==1882
    chi=X[:,1]*X[:,2];gate=np.all(X[:,3:]==1,axis=1)
    la=np.array([F(int(c),3)if g else F(0)for c,g in zip(chi,gate)],dtype=object)
    lb=np.array([F(int(c),6)if g else F(-int(c),12)for c,g in zip(chi,gate)],dtype=object)
    cache={};seen=set();rows=json.load(open(ROOT/'d4_exact_dual_certificate.json'))['certificates']
    for row in rows:
        j=row['cone'];sg=row['readout_sign'];assert (j,sg)not in seen;seen.add((j,sg));assert sg in(-1,1)
        d=D[j];A=(2*d-1)[:,None]*X;S=tuple(row['active'])
        if S not in cache:
            T=sp.Matrix(X[list(S)].tolist())if S else sp.zeros(0,5)
            Q=-(T*T.T).inv()*T if S else sp.zeros(0,5)
            cache[S]=np.array(Q.tolist(),dtype=object).reshape(len(S),5)
        ga=sg*X.T@(d*la);gb=sg*X.T@(d*lb);Q=cache[S]
        qa=(Q@ga)*(2*d[list(S)]-1);qb=(Q@gb)*(2*d[list(S)]-1)
        pa=ga+A[list(S)].T@qa;pb=gb+A[list(S)].T@qb
        assert all(sign(u,v)>=0 for u,v in zip(qa,qb))
        assert all(sign(u,v)>=0 for u,v in zip(A@pa,A@pb))
        u=2*sum(t*t+15*s*s for t,s in zip(pa,pb));v=4*sum(t*s for t,s in zip(pa,pb))
        assert sign(1-u,-v)>=0
        assert [str(u),str(v)]==row['norm_square']
    assert seen==set(itertools.product(range(1882),(-1,1)))
    def add(x,y):return x[0]+y[0],x[1]+y[1]
    def mul(x,y):return x[0]*y[0]+15*x[1]*y[1],x[0]*y[1]+x[1]*y[0]
    def scale(c,x):return c*x[0],c*x[1]
    def relu(x):return x if sign(*x)>0 else (F(0),F(0))
    def decode(rows):return [(tuple(map(F,n['readout'])),[tuple(map(F,v))for v in n['incoming']])for n in rows]
    target=chi*np.where(gate,1,-1)
    primal=json.load(open(ROOT/'d4_exact_target_primal.json'))
    neurons=decode(primal['neurons']);assert len(neurons)==16
    cost_over_root2=(F(0),F(0))
    for c,w in neurons:
        norm2=(F(0),F(0))
        for v in w:norm2=add(norm2,mul(v,v))
        cc=c if sign(*c)>=0 else scale(-1,c)
        if norm2==(F(10,3),F(0)):cost_over_root2=add(cost_over_root2,mul(cc,(F(0),F(1,3))))
        else:
            assert norm2==(F(9,2),F(0));cost_over_root2=add(cost_over_root2,scale(F(3,2),cc))
    assert cost_over_root2==(F(2,3),F(5,6))
    for key,prefactor,output_scale,unit in [('neurons',F(1),F(1,2),False),('unit_bounded_margin_one_teacher',F(1),F(1),True),('canonical_unit_teacher_width16',F(1,2),F(21,40),True)]:
        nn=decode(primal[key]);assert len(nn)==16
        for c,w in nn:
            if unit:
                for v in [c]+w:assert sign(1-v[0],-v[1])>=0 and sign(1+v[0],v[1])>=0
        for x,label in zip(X,target):
            out=(F(0),F(0))
            for c,w in nn:
                dot=(F(0),F(0))
                for xi,v in zip(x,w):dot=add(dot,scale(int(xi),v))
                out=add(out,mul(c,relu(dot)))
            assert scale(prefactor,out)==(output_scale*int(label),F(0))
    import math
    stars=json.load(open(ROOT/'d4_exact_star_primals.json'));classes=[]
    for row in stars['records']:
        W=np.array(row['integer_vectors'],dtype=np.int64);read=np.array(row['readouts'],dtype=np.int64)
        assert int(np.max(abs(W)))<10**10 and len(W)<=2*len(D)and np.all(abs(read)==1)
        yy=target.copy();yy[row['point']]*=-1;out=np.maximum(X@W.T,0)@read
        common=F(row['common_scale']);den=row['denominator']
        assert all(F(int(label)*int(v),den)*common>=F(1,2)for label,v in zip(yy,out))
        total=0
        for w in W:
            n=sum(int(v)**2 for v in w);rr=math.isqrt(n);total+=rr+int(rr*rr<n)
        upper=common*F(total,den);assert upper==F(row['exact_variation_upper'])and upper<F(5507,1000)
        code=sum(int(v>0)<<i for i,v in enumerate(yy));classes.append(int(canonical[code]))
    code=sum(int(v>0)<<i for i,v in enumerate(target));assert set(classes)=={int(canonical[code^(1<<i)])for i in range(16)}
    print('Exact cone completeness,3764 dual inequalities,target norm,canonical-unit teacher,and all16 cheaper-star witnesses verified without optimization.')

if __name__=='__main__':run()
