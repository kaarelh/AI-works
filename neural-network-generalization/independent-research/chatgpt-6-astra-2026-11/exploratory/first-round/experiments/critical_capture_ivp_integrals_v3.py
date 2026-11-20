import json,math,time
from pathlib import Path
import numpy as np
from numpy.polynomial.legendre import leggauss
from critical_capture_ivp import endpoint
from critical_capture_profile import profile,constant
ROOT=Path(__file__).resolve().parents[1];start=time.time()
with (ROOT/'results/critical_capture_ivp_gate_refinement.jsonl').open('w',buffering=1) as f:
 for L in [2,3,4]:
  for delta in [1e-5,1e-6]:
   for tol in [1e-12,1e-10,1e-8]:
    try:row=endpoint(L,delta,L**4/4,rtol=3e-13,atol=3e-15,gate_tol=tol)
    except RuntimeError as e:row=dict(error=str(e),L=L,delta=delta,gate_tol=tol)
    row['seconds']=time.time()-start;f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
with (ROOT/'results/critical_capture_ivp_integrals_v3.jsonl').open('w',buffering=1) as f:
 for L,delta,n in [(2,1e-6,64),(3,1e-4,64),(3,1e-5,64),(3,1e-6,64),(4,1e-4,64),(4,1e-5,64),(4,1e-6,64)]:
  eta0=L**4/8;vmax=1-eta0/(math.pi/(4*delta));nodes,weights=leggauss(n);nodes=(nodes+1)/2*vmax;weights=weights/2*vmax
  val=pred=missing_pred=0;failed=0;max_bracket=0
  for v,w in zip(nodes,weights):
   eta=eta0/(1-v);jac=eta0/(1-v)**2
   try:row=endpoint(L,delta,eta,rtol=3e-13,atol=3e-15,gate_tol=1e-10)
   except RuntimeError as e:row=dict(error=str(e))
   zz=row.get('measured_z',0) if row else 0
   if not row or 'error' in row:failed+=1;missing_pred+=w*jac*profile(L,eta)
   if row and 'log_bracket_width' in row:max_bracket=max(max_bracket,row['log_bracket_width'])
   val+=w*jac*zz;pred+=w*jac*profile(L,eta)
  target=constant(L)['predicted_constant']
  row=dict(L=L,delta=delta,n=n,scaled_upper_endpoint_integral=2/math.pi*val,predicted_same_quadrature=2/math.pi*pred,predicted_constant=target,ratio=2/math.pi*val/target,missing_endpoints=failed,missing_predicted_fraction=missing_pred/pred,max_log_bracket_width=max_bracket,gate_tol=1e-10,seconds=time.time()-start)
  f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
