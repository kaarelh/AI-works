"""Independent direct autograd checks of the physical four-neuron reductions.
No gradient is obtained by differentiating the tied base parameterization.
"""
import itertools,json,math
from pathlib import Path
import numpy as np
import torch
torch.set_default_dtype(torch.float64)
ROOT=Path(__file__).resolve().parents[1]
cube=np.array(list(itertools.product([-1.,1.],repeat=3)))
H=np.array([s for s in cube if s[0]==s[1]*s[2]])
rng=np.random.default_rng(1802)
errors={k:0. for k in ['relu_regression_output','relu_regression_gradient','relu_boolean_output','relu_boolean_gradient','softplus_output','softplus_gradient']}
def compare(name,a,b):
 errors[name]=max(errors[name],float(np.max(np.abs(np.asarray(a)-np.asarray(b)))))
for trial in range(500):
 a=rng.uniform(.001,2);p=rng.uniform(.001,2);b=rng.uniform(.001,2)
 for model in ['regression','boolean','softplus']:
  L=rng.uniform(1,4) if model=='boolean' else 1.
  rho=rng.uniform(.01,.99);eps=rng.uniform(.01,1.5);beta=rng.uniform(.1,24)
  if model!='softplus' and 2*b<=L*p:continue
  X=cube.copy();X[:,0]*=L
  W=torch.tensor(H*np.array([p,b,b]),requires_grad=True)
  aa=torch.tensor(H[:,0]*a,requires_grad=True)
  Z=torch.tensor(X)@W.T
  V=torch.logaddexp(torch.zeros_like(Z),beta*Z)/beta if model=='softplus' else torch.relu(Z)
  F=V@aa
  P=(1+rho*cube[:,0]*cube[:,1]*cube[:,2])/8 if model=='boolean' else np.ones(8)/8
  y=cube[:,1]*cube[:,2] if model=='boolean' else cube[:,0]+eps*cube[:,1]*cube[:,2]
  loss=torch.sum(torch.tensor(P)*(F-torch.tensor(y))**2)/2
  da,dw=torch.autograd.grad(loss,(aa,W))
  base_da=(-da.detach().numpy()*H[:,0]);base_dw=-dw.detach().numpy()*H
  if model=='softplus':
   from softplus_starvation import parts
   _,G,Gp,Gb_over_b=parts(a,p,math.log(b),beta);Gb=b*Gb_over_b
   A=2*a*p;B=4*a*G;r1=1-A;r2=eps-B
   name='softplus'
  else:
   G=(2*b-L*p)/4;Gp=-L/4;Gb=.25
   A=2*a*L*p;B=4*a*G
   r1=(rho-A-rho*B) if model=='boolean' else 1-A
   r2=(1-B-rho*A) if model=='boolean' else eps-B
   name='relu_'+model
  pred=A*cube[:,0]+B*cube[:,1]*cube[:,2]
  gd_a=r1*L*p/2+r2*G
  gd_w=a*np.array([r1*L/2+r2*Gp,r2*Gb,r2*Gb])
  compare(name+'_output',F.detach().numpy(),pred)
  compare(name+'_gradient',base_da,gd_a)
  compare(name+'_gradient',base_dw,gd_w)
assert max(errors.values())<1e-10,errors
report=dict(trials=500,maximum_absolute_errors=errors,passed=True)
print(json.dumps(report,indent=2))
(ROOT/'results'/'reduction_validation.json').write_text(json.dumps(report,indent=2)+'\n')
