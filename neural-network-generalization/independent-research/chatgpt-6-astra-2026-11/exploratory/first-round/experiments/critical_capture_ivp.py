"""Independent adaptive ODE check of the matched rare-neuron capture profile."""
import math,json,time,argparse
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp,quad
from scipy.special import expit
from critical_capture_profile import profile
ROOT=Path(__file__).resolve().parents[1]
def captures(L,delta,eta,logxi,rtol=2e-11,atol=2e-13,gate_tol=1e-13):
 rho=.5+1/L**2+delta;k=rho*L;kap=math.sqrt(2*(L*L+2));D1=2*L*L-rho*(L*L+2)
 Ag=2*L*L*delta/D1;tg=math.log(Ag/(rho-Ag))/k
 phi=3*math.pi/4-eta*delta;c0=abs(math.cos(phi))+abs(math.sin(phi));rg=L/(math.sqrt(c0*c0+L*L)+c0)
 if logxi<=2*math.log(rg):return False
 t0=-math.log(math.expm1(logxi-2*math.log(rg)))/k
 z=np.array([rg*math.cos(phi),rg*math.sin(phi)])
 def unpack(z):return (z[0]*z[0]+z[1]*z[1]-1)/2,z[0],z[1]
 calls=0
 def field(t,z):
  nonlocal calls
  calls+=1
  if calls>30000:raise RuntimeError(('grazing numerical budget',L,delta,eta,logxi,float(t),z.tolist()))
  p,b,c=unpack(z);P=L*abs(p);B=abs(b);C=abs(c);sgp=math.copysign(1,p);sgb=math.copysign(1,b);sgc=math.copysign(1,c)
  g0=g1=g2=0.
  if abs(B-C)<=P<=B+C:g0=-sgb*sgc*L*sgp/4;g1=sgc/4;g2=sgb/4
  elif B>P+C:g2=sgb/2
  elif C>P+B:g1=sgc/2
  A=rho*expit(k*t);r2=1-rho*A;g0=r2*g0+(rho-A)*L/2;g1*=r2;g2*=r2
  a=(1+b*b+c*c)/2;dot=b*g1+c*g2
  return [g0*b+a*g1-b*dot,g0*c+a*g2-c*dot]
 def gate(t,z):
  p,b,c=unpack(z);return abs(b)+abs(c)-L*abs(p)-gate_tol
 gate.direction=-1;gate.terminal=True
 def parity(t,z):return z[0]*z[1]
 parity.direction=1;parity.terminal=True
 def slides(z,t):
  p,b,c=unpack(z);S=abs(b)+abs(c);d=abs(abs(b)-abs(c));cc=math.sqrt(L*L+2)/L
  if d==0:return False
  need=math.asinh(cc*S/d)-math.asinh(cc);available=float(np.logaddexp(0,-k*t))/kap
  return need<available
 if t0>=tg:return slides(z,t0)
 sol=solve_ivp(field,(t0,tg),z,method='DOP853',rtol=rtol,atol=atol,max_step=.25,events=gate)
 if not sol.success:raise RuntimeError(sol.message)
 z=sol.y[:,-1];tt=sol.t[-1]
 if sol.status==1:
  p,b,c=unpack(z)
  # Only an outward positive shortcut crossing is allowed before grazing.
  if p>0:return False
  raise RuntimeError(('early negative exit',L,delta,eta,logxi,tt,tg,gate(tt,z)))
 if z[0]*z[1]>0:return True
 sol=solve_ivp(field,(tg,120),z,method='DOP853',rtol=rtol,atol=atol,max_step=.25,events=[gate,parity])
 if not sol.success:raise RuntimeError(sol.message)
 if len(sol.t_events[1]):return True
 if len(sol.t_events[0]):
  z=sol.y[:,-1];tt=sol.t[-1];p,b,c=unpack(z)
  return slides(z,tt) if p<0 else False
 return False

def endpoint(L,delta,eta,rtol=2e-11,atol=2e-13,gate_tol=1e-13):
 z0=profile(L,eta)
 if z0<=0:return None
 exponent=1+2*math.sqrt(2*(L*L+2));center=math.log(z0)-exponent*math.log(delta)
 lo=center-1;hi=center+1
 for j in range(12):
  if captures(L,delta,eta,lo,rtol,atol,gate_tol):break
  lo-=1
 else:return dict(error='no lower capture',L=L,delta=delta,eta=eta)
 for j in range(12):
  if not captures(L,delta,eta,hi,rtol,atol,gate_tol):break
  hi+=1
 else:return dict(error='no upper endpoint',L=L,delta=delta,eta=eta)
 uncertain=False
 for j in range(20):
  mid=(lo+hi)/2
  try:
   yes=captures(L,delta,eta,mid,rtol,atol,gate_tol)
  except RuntimeError as err:
   if 'grazing numerical budget' not in str(err):raise
   uncertain=True;break
  if yes:lo=mid
  else:hi=mid
 z=math.exp((lo+hi)/2+exponent*math.log(delta))
 return dict(L=L,delta=delta,eta=eta,predicted_z=z0,measured_z=z,ratio=z/z0,log_bracket_width=hi-lo,numerical_budget=uncertain,rtol=rtol,atol=atol,gate_tol=gate_tol)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--L',type=float,default=2);ap.add_argument('--deltas',type=float,nargs='+',default=[1e-3,1e-4,1e-5]);ap.add_argument('--etas',type=float,nargs='+',default=[4,6,10,20,50]);ap.add_argument('--name',default='critical_capture_ivp');a=ap.parse_args()
 start=time.time()
 with (ROOT/'results'/(a.name+'.jsonl')).open('a',buffering=1) as f:
  for delta in a.deltas:
   for eta in a.etas:
    row=endpoint(a.L,delta,eta);row['seconds']=time.time()-start;f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
