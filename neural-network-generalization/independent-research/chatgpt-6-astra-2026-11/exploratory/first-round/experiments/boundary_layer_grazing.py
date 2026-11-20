"""Accurate backward separatrix for equal relevant weights in rare-neuron flow.

Only a scalar angular ODE is integrated. Event switching handles p=0,
and the negative-gate invariant recovers the critical xi exactly. This
avoids the cancellation and gate-crossing errors of a large forward grid.
"""
import argparse,json,math
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import expit
ROOT=Path(__file__).resolve().parents[1]
def one(L,delta,rtol=1e-11):
 rc=.5+1/L**2;rho=rc+delta;theta0=math.atan(L/math.sqrt(2));k=rho*L
 D1=2*L*L-rho*(L*L+2);Ag=2*L*L*delta/D1
 tg=math.log(Ag/(rho-Ag))/k
 def field(sign):
  def rhs(t,q):
   A=rho*expit(k*t);r1=rho-A;r2=1-rho*A
   return [r2/(2*math.sqrt(2))*math.cos(q[0])-L*(r1/2-sign*r2/4)*math.sin(q[0])]
  return rhs
 def middle(t,q):return q[0]-math.pi/2
 middle.terminal=True
 sol=solve_ivp(field(1),(tg,tg-1000),[theta0],events=middle,method='DOP853',rtol=rtol,atol=rtol/100,max_step=.25)
 assert len(sol.t_events[0])==1,sol.message
 tm=sol.t_events[0][0]
 def boundary(t,q):return q[0]-(math.pi-theta0)
 boundary.terminal=True
 sol2=solve_ivp(field(-1),(tm,tm-1000),[math.pi/2],events=boundary,method='DOP853',rtol=rtol,atol=rtol/100,max_step=.25)
 assert len(sol2.t_events[0])==1,sol2.message
 te=float(sol2.t_events[0][0]);z2=(1-math.cos(theta0))/(1+math.cos(theta0))
 logxi=math.log(z2)+float(np.logaddexp(0,-k*te));nu=1+math.sqrt(2*(L*L+2))
 return dict(L=L,rho=rho,delta=delta,rtol=rtol,t_grazing=tg,t_entry=te,log_xi=logxi,
             xi=math.exp(logxi),exponent=nu,scaled_xi=math.exp(logxi+nu*math.log(delta)))
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--rtol',type=float,default=1e-11);args=ap.parse_args()
 rows=[]
 for L in [2,3,4]:
  for delta in np.geomspace(.1,1e-8,29):
   row=one(L,float(delta),args.rtol);rows.append(row);print(json.dumps(row),flush=True)
 (ROOT/'results'/f'boundary_layer_grazing_{args.rtol:g}.json').write_text(json.dumps(rows,indent=2)+'\n')
