"""Critical initialization in the Boolean shortcut family; independent covariance form."""
import json,math,argparse
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import expit
ROOT=Path(__file__).resolve().parents[1]
def field(z,L,rho,loss='square'):
 lr,th=z;R=math.exp(lr);c=math.cos(th);s=math.sin(th)
 A=2*L*R*c;B=R*(math.sqrt(2)*s-L*c)
 if loss=='square':r1=rho-A-rho*B;r2=1-B-rho*A
 else:
  up=(1+rho)/2*expit(-B-A);down=(1-rho)/2*expit(-B+A)
  r1=up-down;r2=up+down
 return np.array([r1*L*c+r2*(math.sqrt(2)*s-L*c)/2,
                  -r1*L*s/2+r2*(math.sqrt(2)*c+L*s)/4])
def solve(L,delta,th,loss='square'):
 rc=.5+1/(L*L);rho=rc+delta;th0=math.atan(L/math.sqrt(2))
 D1=2*L*L-rho*(L*L+2)
 As=2*L*L*delta/D1 if loss=='square' else 2*(math.atanh(rho)-math.atanh(rc))
 Rs=As/(2*L*math.cos(th0))
 def event(t,z):return z[1]-th
 event.terminal=True
 sol=solve_ivp(lambda t,z:-field(z,L,rho,loss),(0,3000),[math.log(Rs),th0],events=event,
               rtol=2e-11,atol=2e-13,max_step=.25)
 assert len(sol.t_events[0])
 lr=sol.y_events[0][0,0];al=math.exp(lr/2)
 den=L*L+2;lam=math.sqrt(den)/(2*math.sqrt(2)*L)
 c=L*L/(2*math.sqrt(den));D1c=2*L*L-rc*den;k=L*D1c/(math.sqrt(2)*den)
 pred=math.sqrt(4*c**3/(9*k*lam*lam))/math.sin(th-th0)
 if loss=='logistic':pred*=math.sqrt(2)
 return dict(L=L,rho=rho,delta=delta,theta_init=th,alpha_crit=al,loss=loss,
             scaled_alpha=al/delta**1.5,predicted_coefficient=pred,ratio=al/delta**1.5/pred)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--loss',choices=['square','logistic'],default='square');args=ap.parse_args()
 suffix='' if args.loss=='square' else '_logistic'
 with (ROOT/'results'/f'boolean_shortcut_grazing{suffix}.jsonl').open('w',buffering=1) as f:
  for L in [2,3,4]:
   th0=math.atan(L/math.sqrt(2));th=(th0+math.pi/2)/2
   for delta in np.geomspace(.02,1e-7,40):
    z=solve(L,float(delta),th,args.loss);f.write(json.dumps(z)+'\n')
   print(json.dumps(z),flush=True)
