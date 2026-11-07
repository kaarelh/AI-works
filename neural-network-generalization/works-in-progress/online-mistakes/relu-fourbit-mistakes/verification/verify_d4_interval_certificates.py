"""Independent exact-integer verification and rigorous fifteen-gap path.

No optimizer is imported or called. Cone completeness is established by the
separate exact rational checker certify_d4_cones.py.
"""
import itertools,json,math
from pathlib import Path
from fractions import Fraction as F
import numpy as np
ROOT=Path(__file__).resolve().parent;DEST=ROOT/'d4_interval_certificates'

def run():
    a=np.load(ROOT/'d4_certificate_input.npz');X=a['X'].astype(np.int64);D=a['D'].astype(np.int64);canonical=a['canonical'];J=len(D)
    bounds={}
    for code in sorted(set(map(int,canonical))):
        z=np.load(DEST/f'{code}.npz');alpha=z['alpha'];qp=z['qplus'];qm=z['qminus'];radius=int(z['dual_radius'])
        assert int(z['code'])==code
        assert radius>0 and all(np.issubdtype(v.dtype,np.integer)for v in(alpha,qp,qm))
        y=np.array([1 if code>>i&1 else -1 for i in range(16)],dtype=np.int64)
        assert np.all(alpha>=0)and np.all(qp>=0)and np.all(qm>=0)
        assert max(int(np.max(alpha)),int(np.max(qp)),int(np.max(qm)))<10**10
        G=(D*(y*alpha))@X
        residual=np.r_[G+((2*D-1)*qp)@X,-G+((2*D-1)*qm)@X]
        exact_max=max(sum(int(v)**2 for v in row)for row in residual)
        assert exact_max<=radius**2 and exact_max==int(z['dual_max_square'])
        lower=F(sum(map(int,alpha)),2*radius)
        W=z['W'];read=z['readout'];den=int(z['primal_denominator']);assert np.all(abs(read)==1)
        assert den>0 and np.issubdtype(W.dtype,np.integer)and np.issubdtype(read.dtype,np.integer)
        assert int(np.max(abs(W)))<10**10 and len(W)<=2*J
        output=np.maximum(X@W.T,0)@read
        assert all(2*int(label)*int(out)>=den for label,out in zip(y,output))
        total=0
        for w in W:
            n=sum(int(v)**2 for v in w);root=math.isqrt(n);total+=root+int(root*root<n)
        assert total==int(z['primal_root_sum'])
        upper=F(total,den);assert lower<=upper
        assert lower==F(int(z['lower_num']),int(z['lower_den']))and upper==F(int(z['upper_num']),int(z['upper_den']))
        bounds[code]=(lower,upper)
    assert bounds[7905][0]>F(5507,1000)
    assert max(v[1]for c,v in bounds.items()if c!=7905)<F(5507,1000)
    (ROOT/'d4_exact_norm_intervals.json').write_text(json.dumps({str(c):dict(lower=str(lo),upper=str(hi),lower_float=float(lo),upper_float=float(hi))for c,(lo,hi)in bounds.items()},indent=2))
    target=7905;order=[0,1,2,4,5,6,8,9,12,10,13,7,3,11,14,15]
    codes=np.arange(1<<16);mask=0;bits=0;steps=[]
    for t,point in enumerate(order):
        current=codes[(codes&mask)==bits];upper_code=min(map(int,current),key=lambda c:bounds[int(canonical[c])][1]);upper=bounds[int(canonical[upper_code])][1]
        correct_mask=mask|(1<<point);correct_bits=bits|(target&(1<<point));correct=codes[(codes&correct_mask)==correct_bits]
        lower_code=min(map(int,correct),key=lambda c:bounds[int(canonical[c])][0]);lower=bounds[int(canonical[lower_code])][0]
        gap=lower-upper
        if t:assert gap>0,(t,point,gap)
        steps.append(dict(step=t,point=point,label=1 if target>>point&1 else -1,current_upper=str(upper),current_upper_float=float(upper),upper_witness_code=upper_code,correct_lower=str(lower),correct_lower_float=float(lower),lower_witness_class=int(canonical[lower_code]),variation_gap=str(gap),variation_gap_float=float(gap)))
        mask=correct_mask;bits=correct_bits
    original=np.prod(X[:,1:3],axis=1)*np.where(np.all(X[:,3:]==1,axis=1),1,-1)
    original_code=sum(int(y>0)<<i for i,y in enumerate(original));transform=None
    for perm in itertools.permutations(range(4)):
        for flip in itertools.product((-1,1),repeat=4):
            mapping=(((X[:,1:][:,perm]*flip)+1)//2)@np.array([8,4,2,1]);labels=original[mapping]
            for output_sign in [1,-1]:
                code=sum(int(y>0)<<i for i,y in enumerate(output_sign*labels))
                if code==target:transform=dict(permutation=list(perm),flips=list(flip),output_sign=output_sign,mapping=mapping.tolist());break
            if transform:break
        if transform:break
    assert transform
    mapped_order=[transform['mapping'][i]for i in order]
    out=dict(scope='Exact rational continuous-ReLU atomic-norm intervals for all65536 Boolean functions modulo222 verified isometry classes',classes=len(bounds),activation_cones=J,strict_gaps=15,unique_maximum_isometry_class=7905,maximum_class_size=int(np.sum(canonical==7905)),canonical_target=target,canonical_order=order,original_target='x1*x2*ANDsign(x3,x4)',original_code=original_code,original_order=mapped_order,transform=transform,minimum_strict_variation_gap=min(s['variation_gap_float']for s in steps[1:]),steps=steps)
    (ROOT/'d4_exact_mistake_path.json').write_text(json.dumps(out,indent=2))
    print(json.dumps({k:v for k,v in out.items()if k not in('steps','transform')}))

if __name__=='__main__':run()
