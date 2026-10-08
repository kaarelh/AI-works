#!/usr/bin/env python3
"""Refit published Stockfish observations; numerical and source audit recorded alongside output."""
import csv,json,math,hashlib
from pathlib import Path
import numpy as np
from scipy.optimize import least_squares
BASE=Path(__file__).resolve().parent
ROWS=list(csv.DictReader(open(BASE/'matched_observations.csv')))
Z=np.array([float(r['cumulative_tests']) for r in ROWS])/float(ROWS[-1]['cumulative_tests'])
Y=np.array([float(r['log_efficiency']) for r in ROWS])
CUT=int(.8*len(Y)); K0=10**-27.5; N=1e120

def model(name,z,p):
 b=p[0]
 if name=='power':return b+p[1]*np.log(z)
 if name=='shifted_power':return b+p[1]*np.log(z+np.exp(p[2]))
 if name=='logarithmic':return b+np.log1p(np.exp(p[1])*np.log1p(z/np.exp(p[2])))
 if name=='linear_efficiency':return b+np.log1p(np.exp(p[1])*z)
 if name=='exponential':return b+np.exp(p[1])*z
 if name=='stretched_exponential':return b+np.exp(p[1])*z**np.exp(p[2])
 # Saturation in log efficiency, with exponential/hyperbolic convergence.
 if name=='exp_ceiling':return b+np.exp(p[1])*(-np.expm1(-z/np.exp(p[2])))
 if name in ['hyperbolic_ceiling_p1','hyperbolic_ceiling_p2']:
  q=1 if name.endswith('p1') else 2
  return b+np.exp(p[1])*(-np.expm1(-q*np.log1p(z/np.exp(p[2]))))
 if name=='hyperbolic_ceiling':return b+np.exp(p[1])*(-np.expm1(-np.exp(p[3])*np.log1p(z/np.exp(p[2]))))
 raise ValueError(name)
SPECS={
 'linear_efficiency':([-100,-20],[100,25],[[0,5]]),
 'hyperbolic_ceiling_p1':([-100,-15,-12],[100,25,20],[[0,2,0],[0,3,-2]]),
 'hyperbolic_ceiling_p2':([-100,-15,-12],[100,25,20],[[0,2,0],[0,3,-2]]),
 'power':([-20,1e-5],[20,20],[[5,1]]),
 'shifted_power':([-100,1e-5,-18],[100,20,10],[[5,1,-3],[5,2,-2],[4,.5,-5]]),
 'logarithmic':([-100,-20,-18],[100,25,15],[[0,3,-5],[-5,7,-2],[1,5,1]]),
 'exponential':([-100,-20],[100,10],[[1,1.6]]),
 'stretched_exponential':([-100,-20,-5],[100,10,3],[[0,1.7,-.5],[1,1,0]]),
 'exp_ceiling':([-100,-15,-12],[100,25,20],[[0,2,0],[0,2,-2],[0,4,1],[0,8,6]]),
 'hyperbolic_ceiling':([-100,-15,-12,-6],[100,25,20,5],[[0,2,0,0],[0,3,-3,-2],[0,8,3,-1],[0,2,-3,-1]])}

def fit(name,z,y):
 lo,hi,starts=SPECS[name]
 opts=[least_squares(lambda p:model(name,z,p)-y,np.array(p,dtype=float),bounds=(lo,hi),max_nfev=10000,xtol=1e-11,ftol=1e-11,gtol=1e-11) for p in starts]
 o=min(opts,key=lambda o:sum(o.fun**2))
 return o

def out(name):
 f=fit(name,Z,Y);h=fit(name,Z[:CUT],Y[:CUT]);p=f.x
 return dict(name=name,params=p.tolist(),train_params=h.x.tolist(),n=len(Y),fit_rmse=float(np.sqrt(np.mean((model(name,Z,p)-Y)**2))),holdout_rmse=float(np.sqrt(np.mean((model(name,Z[CUT:],h.x)-Y[CUT:])**2))),train_rmse=float(np.sqrt(np.mean(h.fun**2))),success=bool(f.success),optimality=float(f.optimality),jacobian_condition=float(np.linalg.cond(f.jac)),active_bounds=f.active_mask.tolist(),fit_aic=float(len(Y)*np.log(np.mean(f.fun**2))+2*len(p)),train_until=ROWS[CUT-1]['date'])

if __name__=='__main__':
 outp=[out(n) for n in SPECS]
 (BASE/'fit_results.json').write_text(json.dumps(outp,indent=2))
 for r in outp:print(r)
