"""Locate the grazing separatrix in the invariant four-neuron ReLU family."""
import json,math
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp
ROOT=Path(__file__).resolve().parents[1]
th0=math.atan(1/math.sqrt(2))
def field(t,z,eps):
 lR,th=z;R=math.exp(lR);c=math.cos(th);s=math.sin(th)
 A=2*R*c;B=R*(math.sqrt(2)*s-c)
 U=(1-A)*c/2+(eps-B)*(math.sqrt(2)*s-c)/4
 return [2*U,-(1-A)*s/2+(eps-B)*(math.sqrt(2)*c+s)/4]

def critical(eps,th_init):
 Rstar=math.sqrt(3/8)*(1-1.5*eps)
 def hit(t,z):return z[1]-th_init
 hit.terminal=True;hit.direction=0
 sol=solve_ivp(lambda t,z:-np.array(field(t,z,eps)),[0,3000],
               [math.log(Rstar),th0],events=hit,rtol=2e-11,atol=2e-13,max_step=.25)
 if not len(sol.t_events[0]):raise RuntimeError((eps,th_init,sol.message,sol.y[:,-1]))
 lr,th=sol.y_events[0][0]
 return dict(epsilon=eps,delta=2/3-eps,theta_init=th_init,alpha_crit=math.exp(lr/2),
             R_crit=math.exp(lr),backward_time=float(sol.t_events[0][0]),nfev=sol.nfev)

with (ROOT/'results'/'starvation_grazing.jsonl').open('w',buffering=1) as f:
 for th in [math.pi/4,1.0,1.3]:
  for delta in np.geomspace(.3,1e-7,45):
   z=critical(2/3-delta,th)
   z['scaled_alpha']=z['alpha_crit']/delta**1.5
   f.write(json.dumps(z)+'\n')
  print(json.dumps(z),flush=True)
