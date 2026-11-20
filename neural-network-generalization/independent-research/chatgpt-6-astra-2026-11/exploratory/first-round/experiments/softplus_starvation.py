"""Full population flow in the invariant four-neuron softplus family.
State (a,p,log b); w=(p,b,b), output=A*x1+B*x2*x3 exactly.
Implicit integration resolves the fast linear fit and slow second-feature escape.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import expit
ROOT=Path(__file__).resolve().parents[1]
def logcosh(x):return np.logaddexp(x,-x)-math.log(2)
def logsinh_pos(x):
 if x<1e-3:return math.log(x)+math.log1p(x*x/6+x**4/120)
 return x+math.log1p(-math.exp(-2*x))-math.log(2)
def parts(a,p,lb,beta):
 b=math.exp(max(-745.,min(300.,lb)));t=beta*b;s=beta*p/2
 if math.log(beta)+lb < -8:
  lt=math.log(beta)+lb;t2=math.exp(max(-745.,2*lt))
  ls=math.log1p(t2/6+t2*t2/120+t2**3/5040)
  lth=math.log1p(-t2/3+2*t2*t2/15-17*t2**3/315)
  lc=logcosh(s);lr=2*(lt+ls-lc);den=float(np.logaddexp(0,lr))
  G=den/(4*beta);q=math.exp(max(-745.,lr-den))
  Gp=-.25*math.tanh(s)*q
  ratio=math.exp(max(-745.,math.log(beta)-2*lc+2*ls-lth-den-math.log(4)))
  return b,float(G),float(Gp),float(ratio)
 lr=2*(logsinh_pos(t)-logcosh(s));q=expit(lr)
 G=np.logaddexp(0,lr)/(4*beta)
 Gp=-.25*math.tanh(s)*q
 Gb=.25*q/math.tanh(t)
 return b,float(G),float(Gp),float(Gb/b)
def solve(beta,eps,alpha,th,method='BDF'):
 calls=0
 def fun(t,z):
  nonlocal calls
  calls+=1
  if calls>100000:raise RuntimeError(('excess calls',beta,eps,alpha,t,z.tolist()))
  la,lp,lb=z;a=math.exp(max(-300.,min(300.,la)));p=math.exp(max(-300.,min(300.,lp)))
  b,G,Gp,Gb=parts(a,p,lb,beta)
  r1=1-2*a*p;r2=eps-4*a*G
  return [r1*p/(2*a)+r2*G/a,a/p*(r1/2+r2*Gp),a*r2*Gb]
 def hit(t,z):
  la,lp,lb=z;a=math.exp(la);p=math.exp(lp);b,G,Gp,Gb=parts(a,p,lb,beta)
  return 4*a*G-eps/2
 hit.terminal=True;hit.direction=1
 lam=eps/math.sqrt(2)*beta/(4*math.cosh(beta/(2*math.sqrt(2)))**2)
 horizon=max(100,8*math.log(1/alpha)*(2+1/lam));t0=time.time()
 z0=[math.log(alpha),math.log(alpha*math.cos(th)),math.log(alpha*math.sin(th)/math.sqrt(2))]
 sol=solve_ivp(fun,(0,horizon),z0,method=method,rtol=1e-9,atol=1e-10,events=hit)
 end=sol.y[:,-1];a=math.exp(end[0]);p=math.exp(end[1]);b,G,Gp,Gb=parts(a,p,end[2],beta)
 return dict(beta=beta,epsilon=eps,alpha=alpha,theta_init=th,method=method,
   escape_time=float(sol.t_events[0][0]) if len(sol.t_events[0]) else None,
   saddle_growth_rate=lam,predicted_log_coefficient=2+1/lam,
   scaled_escape=float(sol.t[-1])/math.log(1/alpha),A=float(2*a*p),B=float(4*a*G),
   nfev=sol.nfev,njev=sol.njev,elapsed_s=time.time()-t0,status=sol.status,message=sol.message)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--betas',default='1,2,4,8,12,16,24,32')
 ap.add_argument('--epsilons',default='.125,.5,.75');ap.add_argument('--alphas',default='.01,.0001,.000001,.00000001')
 ap.add_argument('--name',default='softplus_starvation');a=ap.parse_args()
 with (ROOT/'results'/f'{a.name}.jsonl').open('a',buffering=1) as f:
  for eps in map(float,a.epsilons.split(',')):
   for beta in map(float,a.betas.split(',')):
    for alpha in map(float,a.alphas.split(',')):
     z=solve(beta,eps,alpha,math.pi/4);f.write(json.dumps(z)+'\n');print(json.dumps(z),flush=True)
if __name__=='__main__':main()
