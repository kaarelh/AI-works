"""Finite numerical checks of the path-norm and narrower-bias refinements.

These are perturbed actual ReLU networks, not an asymptotic proof or an
interval certificate. The same source networks are used for every target.
"""
import json,math
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
rng=np.random.default_rng(202611182252)
records=[]
for r in (6,8,10):
 X=2*((np.arange(2**r)[:,None]>>np.arange(r))&1)-1
 source=np.prod(X,axis=1);Z=X[X[:,0]==1];N=len(Z)
 rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r));s=.5
 for p in (2.,2.1,3.,4.,8.):
  q=p/2;t=s/(rho*math.sqrt(r));Vstar=2*math.sqrt(r)*t**q
  A=math.sqrt(t)*r**(1/(2*p));m=math.sqrt(t)*r**(-1/(2*p))
  for nominal in (.001,.01,.1):
   gamma=min(1.,r*nominal)**((p-2)/(2*p)) if p>2 else 1.
   for repetition in range(3):
    a=A*((-1)**((r-2)//2))*np.prod(Z,axis=1)*(1+rng.normal(0,nominal/5,N))
    U=np.column_stack([gamma*m*rng.normal(0,nominal/5,N),m*Z*(1+rng.normal(0,nominal/5,Z.shape))])
    V=float(np.mean(abs(a)**p+abs(U[:,0]/gamma)**p+np.sum(abs(U[:,1:])**p,axis=1)))
    eps=max(nominal,V/Vstar-1,0.)
    H=np.maximum(U[:,0,None]+U[:,1:]@X.T,0).T;He=(H+H[::-1])/2
    F=H@a/N;hinge=float(np.mean(np.maximum(s-source*F,0)))
    P=float(np.mean(abs(a)*np.linalg.norm(U,axis=1)))
    assert P<=(1+eps)*s/rho+1e-10
    A2=float(np.mean(a*a));U2=float(np.mean(np.sum(U*U,axis=1)))
    v=math.sqrt(2*P*(eps*s+hinge)/rho)
    u=math.sqrt((s+P*math.sqrt(r+1))*(eps*s+2*hinge))
    for k in (1,2):
     j=r-2*k
     bj=rho*((-1)**((j-2)//2))*math.comb((r-2)//2,(j-2)//2)/math.comb(r-2,j-2)
     modifier=np.prod(np.where(U[:,1:1+2*k]>=0,1.,-1.),axis=1)
     target=np.prod(X[:,2*k:],axis=1)
     predictor=((-1)**((r-2)//2))*rho/(s*bj)*(He@(a*modifier)/N)
     error=float(np.sqrt(np.mean((predictor-target)**2)))
     bound=rho/(s*abs(bj))*((1+(r-1)**k)*v+(r-1)**k*u)
     assert error<=bound+1e-10
     norm=(rho/(s*bj))**2*A2
     radius=float(np.max(np.mean(He*He,axis=1)))
     assert radius<=(r+1)*U2+1e-10
     records.append(dict(r=r,p=p,nominal=nominal,repetition=repetition,k=k,gamma=gamma,
        effective_epsilon=eps,cost_ratio=V/Vstar,path_ratio=P*rho/s,
        measured_error=error,error_upper_bound=bound,
        coefficient_norm_squared=norm,measured_radius_squared=radius))
result=dict(status='PASS',networks=len(records)//2,transfer_checks=len(records),records=records,
 qualification='Floating-point checks on finite networks; not interval arithmetic or a formal proof.')
(ROOT/'results/path_norm_refinement_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='records'}))
