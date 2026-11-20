"""Check exact Fourier identities and finite-dimensional transfer bounds.

The coefficient checks use fractions. Matrix checks are floating point,
using analytic lower bounds for the ordinary kernel and exceptional mass;
no estimated critical-law moments are needed.
"""
import os
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:
    os.environ[key]='1'
from pathlib import Path
from fractions import Fraction
import math,json
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
checks=0
for r in range(4,82,2):
    rho_scaled=Fraction(math.comb(r-2,(r-2)//2),2**(r-1))
    for j in range(2,r+1,2):
        direct=Fraction(sum((-1)**a*math.comb(j,a)*math.comb(r-j,b)*max(r-2*(a+b),0)
                            for a in range(j+1) for b in range(r-j+1)),2**r)
        formula=rho_scaled*(-1)**((j-2)//2)*Fraction(math.comb((r-2)//2,(j-2)//2),math.comb(r-2,j-2))
        assert direct==formula,(r,j,direct,formula)
        checks+=1
blindness_checks=[]
for r in range(6,82,2):
    bias=Fraction(r,r-3)
    values=[]
    for j in [r-2,r]:
        direct=sum(Fraction((-1)**a*math.comb(j,a)*math.comb(r-j,b),2**r)
                   *max(bias+r-2*(a+b),0)
                   for a in range(j+1) for b in range(r-j+1))
        values.append(direct)
    full_zero=Fraction((-1)**(r//2-1)*math.comb(r-2,r//2-1),2**(r-1))
    assert values[0]==0,(r,values)
    assert values[1]==-2*full_zero/(r-3),(r,values)
    blindness_checks.append(dict(r=r,bias=str(bias),full_coefficient=str(values[1]),near_coefficient=str(values[0])))
# Check the complete orbit projection and blindness with exact integers at r=6.
r=6;M=2**r;bias=2
cube_small=np.array([[1 if x>>i&1 else -1 for i in range(r)] for x in range(M)])
features_small=np.maximum(bias+cube_small@cube_small.T,0)
target_small=np.prod(cube_small,axis=1)
assert np.array_equal(features_small@target_small,-8*target_small)
for mask in range(M):
    if mask.bit_count()!=r-2:continue
    character=np.prod(cube_small[:,[i for i in range(r) if mask>>i&1]],axis=1)
    assert np.all(features_small.T@character==0)
rng=np.random.default_rng(181126)
matrices=[]
for r in [4,6,8,10]:
    M=2**r;K=M//2
    cube=np.array([[1 if x>>i&1 else -1 for i in range(r)] for x in range(M)])
    even=[t for t in range(M) if t.bit_count()%2==0]
    masks=even+[1<<i for i in range(r)]
    walsh=np.column_stack([np.prod(cube[:,[i for i in range(r) if t>>i&1]],axis=1) for t in masks])
    canonical=cube[1::2]
    rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r))
    delta=1/8;alpha=delta/(K*rho);lambda_lower=(r-2)/(4*r)
    # epsilon=chi_(r-2)*h on the last r-2 coordinates, h balanced.
    # Then g=chi_(r-1)*epsilon=b_1*h is 1-resilient.
    patterns=[np.ones(K,dtype=int)]
    for trial in range(8):
        h=np.ones(2**(r-2),dtype=int);h[:len(h)//2]=-1;rng.shuffle(h)
        eps=np.array([np.prod(z[2:])*h[i//2] for i,z in enumerate(canonical)])
        patterns.append(eps)
    maximum=0;maximum_error=0
    for eps in patterns:
        z=canonical*eps[:,None]
        assert np.all(np.sum(np.prod(z,axis=1)[:,None]*z,axis=0)==0)
        features=np.maximum(cube@z.T/np.sqrt(r),0)
        hats=walsh.T@features/M
        surrogate=alpha*hats@hats.T
        surrogate[K:,K:]+=lambda_lower*np.eye(r)
        inverse=np.linalg.inv(surrogate)
        for row,t in enumerate(even):
            j=t.bit_count()
            if not j:continue
            bj=rho*(-1)**((j-2)//2)*math.comb((r-2)//2,(j-2)//2)/math.comb(r-2,j-2)
            coefficients=np.prod(z[:,[i for i in range(r) if t>>i&1]],axis=1)/(K*bj)
            represented=hats@coefficients
            expected=np.zeros(K);expected[row]=1
            maximum_error=max(maximum_error,float(np.max(np.abs(represented[:K]-expected))))
            bound=(rho/delta+1/(4*r*lambda_lower))/bj**2
            maximum=max(maximum,float(inverse[row,row]/bound))
            assert inverse[row,row]<=bound*(1+1e-8),(r,t,inverse[row,row],bound)
        assert np.max(np.sum(features*features,axis=1))<=K*(1+1e-10)
    matrices.append(dict(r=r,patterns=len(patterns),max_norm_bound_ratio=maximum,max_representation_error=maximum_error))
out=dict(status='PASS',exact_coefficient_checks=checks,dimensions_checked=[4,80],
         exact_transfer_blindness_examples=blindness_checks,exact_six_bit_orbit_check=True,
         floating_point_matrix_checks=matrices,
         limitations='Matrix checks are diagnostics; they do not replace the proof or certify posterior sampling.')
(ROOT/'results/feature_transfer_checks.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out,indent=2))
