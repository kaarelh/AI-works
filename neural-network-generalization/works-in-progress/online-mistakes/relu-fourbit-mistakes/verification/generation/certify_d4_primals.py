"""Exact target formula and rational feasible witnesses for all d4 stars."""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
import sys,itertools,math,json
from pathlib import Path
from fractions import Fraction as F
import numpy as np
from certify_d4_dual import sign
ROOT=Path(__file__).resolve().parent.parent
def add(x,y):return x[0]+y[0],x[1]+y[1]
def mul(x,y):return x[0]*y[0]+15*x[1]*y[1],x[0]*y[1]+x[1]*y[0]
def scale(c,x):return c*x[0],c*x[1]
def relu(x):return x if sign(*x)>0 else (F(0),F(0))

def target_primal(X,y):
    neurons=[]
    for ss in itertools.product((-1,1),repeat=2):
        read=(F(-5,8)*ss[0]*ss[1],F(1,24)*ss[0]*ss[1])
        w=[(F(2,3),F(0)),(F(ss[0]),F(0)),(F(ss[1]),F(0)),(F(2,3),F(0)),(F(2,3),F(0))]
        neurons.append((read,w))
        for aug in sorted(set(itertools.permutations((-2,1,1)))):
            read=(F(ss[0]*ss[1],12),F(0))
            w=[(F(0),F(aug[0],6)),(F(ss[0]),F(0)),(F(ss[1]),F(0)),(F(0),F(aug[1],6)),(F(0),F(aug[2],6))]
            neurons.append((read,w))
    for x,label in zip(X,y):
        z=(F(0),F(0))
        for read,w in neurons:
            t=(F(0),F(0))
            for xi,wi in zip(x,w):t=add(t,scale(int(xi),wi))
            z=add(z,mul(read,relu(t)))
        assert z==(F(int(label),2),F(0)),(x,z,label)
    unit=[]
    for c,w in neurons:
        # A family: double its readout. B family: halve its incoming vector
        # and quadruple its readout. The resulting output is the full Boolean g.
        cc=scale(2,c)if w[0][1]==0 else scale(4,c)
        ww=w if w[0][1]==0 else [scale(F(1,2),v)for v in w]
        for v in [cc]+ww:
            assert sign(1-v[0],-v[1])>=0 and sign(1+v[0],v[1])>=0
        unit.append((cc,ww))
    for x,label in zip(X,y):
        z=(F(0),F(0))
        for c,w in unit:
            t=(F(0),F(0))
            for xi,wi in zip(x,w):t=add(t,scale(int(xi),wi))
            z=add(z,mul(c,relu(t)))
        assert z==(F(int(label)),F(0))
    encode=lambda nn:[dict(readout=list(map(str,c)),incoming=[list(map(str,wj))for wj in w])for c,w in nn]
    canonical=[]
    for c,w in neurons:
        if w[0][1]==0:cc=scale(F(21,10),c);ww=w
        else:cc=scale(F(21,5),c);ww=[scale(F(1,2),v)for v in w]
        for v in [cc]+ww:
            assert sign(1-v[0],-v[1])>=0 and sign(1+v[0],v[1])>=0
        canonical.append((cc,ww))
    for x,label in zip(X,y):
        z=(F(0),F(0))
        for c,w in canonical:
            t=(F(0),F(0))
            for xi,wi in zip(x,w):t=add(t,scale(int(xi),wi))
            z=add(z,mul(c,relu(t)))
        assert scale(F(1,2),z)==(F(21*int(label),40),F(0))
    (ROOT/'d4_exact_target_primal.json').write_text(json.dumps(dict(width=len(neurons),cost='5*sqrt(30)/6 + 2*sqrt(2)/3',field='a+b*sqrt(15)',neurons=encode(neurons),unit_bounded_margin_one_teacher=encode(unit),canonical_unit_teacher_width16=encode(canonical),canonical_network_output_prefactor='1/2',canonical_teacher_output='21*g/40'),indent=2))

def star_primals(X,D,y):

    import cvxpy as cp
    J=len(D);U=cp.Variable((J,5));V=cp.Variable((J,5));label=cp.Parameter(16)
    pu=U@X.T;pv=V@X.T;z=cp.sum(cp.multiply(D,pu-pv),axis=0)
    problem=cp.Problem(cp.Minimize(cp.sum(cp.norm(U,axis=1))+cp.sum(cp.norm(V,axis=1))),[cp.multiply(2*D-1,pu)>=0,cp.multiply(2*D-1,pv)>=0,cp.multiply(label,z)>=.5])
    records=[];den=10**7
    for point in [0,1,3]:
        yy=y.copy();yy[point]*=-1;label.value=yy
        value=problem.solve(solver='CLARABEL',tol_gap_abs=1e-8,tol_gap_rel=1e-8,tol_feas=1e-8,max_iter=400)
        W=np.rint(np.r_[U.value,V.value]*den).astype(np.int64);read=np.r_[np.ones(J,dtype=int),-np.ones(J,dtype=int)]
        keep=np.any(W!=0,axis=1);W=W[keep];read=read[keep]
        out=np.maximum(X@W.T,0)@read
        signed=yy*out;minimum=int(min(signed));assert minimum>0
        # ReLU homogeneity: incoming common_scale*W/den has margin exactly1/2.
        common=F(den,2*minimum)
        integer_norms=[]
        for w in W:
            n=sum(int(v)**2 for v in w);s=math.isqrt(n);integer_norms.append(s if s*s==n else s+1)
        upper=common*F(sum(integer_norms),den)
        assert upper<F(5507,1000)
        rec=dict(point=point,solver_value=float(value),width=len(W),denominator=den,common_scale=str(common),exact_variation_upper=str(upper),variation_upper=float(upper),integer_vectors=W.tolist(),readouts=read.tolist(),signed_integer_margin_min=minimum)
        records.append(rec);print(json.dumps({k:v for k,v in rec.items()if k not in('integer_vectors','readouts')}),flush=True)
    a=np.load(ROOT/'d4_certificate_input.npz');code=sum(int(t>0)<<i for i,t in enumerate(y))
    classes=[int(a['canonical'][code^(1<<i)])for i in range(16)]
    assert set(classes)=={classes[i]for i in[0,1,3]}
    (ROOT/'d4_exact_star_primals.json').write_text(json.dumps(dict(scope='Rational full-cube feasible primal witnesses; NPN equivalence covers all16 stars',star_classes=classes,records=records),indent=2))

def run():
    a=np.load(ROOT/'d4_certificate_input.npz');X=a['X'].astype(int);D=a['D'].astype(int)
    y=np.prod(X[:,1:3],axis=1)*np.where(np.all(X[:,3:]==1,axis=1),1,-1)
    target_primal(X,y);star_primals(X,D,y)

if __name__=='__main__':run()
