#!/usr/bin/env python3
"""Translate curve fits under raw-proxy and universal recursive proxy mappings.
Every model is anchored at the last matched observation with dlog(A)/dx=k0.
Saturation results include fixed tail exponents, explicitly assumptions rather than estimates.
"""
import json,math
from pathlib import Path
from scipy.integrate import quad
from scipy.optimize import brentq
from scipy.special import gammaincc,gammaln
BASE=Path(__file__).resolve().parent
K0=10**-27.5;N=1e120;LN10=math.log(10);L=math.log(K0*N)

def val(log10x):
 return {'log10_flops':log10x,'flops':10**log10x if log10x<308 else None}
def stop_fraction(frac):
 return {'status':'finite_optimum','stop_fraction_N':frac,'optimal_research_flops':frac*N,'log10_optimal_research_flops':120+math.log10(frac),'log10_remaining_flops':120+math.log10(1-frac),'log10_marginal_gain_at_stop':-120-math.log10(1-frac)}
def stop_early(logx):
 return {'status':'finite_optimum','stop_fraction_N':10**(logx-120),'optimal_research_flops':10**logx,'log10_optimal_research_flops':logx,'log10_remaining_flops':120.,'log10_marginal_gain_at_stop':-120.,'approximation':'x/N negligible; exact threshold and economic stop agree at shown precision'}
def stop_almost_all(logremaining):
 return {'status':'finite_optimum','stop_fraction_N':1.,'optimal_research_flops':N,'log10_optimal_research_flops':120.,'log10_remaining_flops':logremaining,'log10_marginal_gain_at_stop':-logremaining,'rounding':'stop is N minus the explicitly reported reserve'}
def out(r):
 name=r['name'];p=r['params'];o={'name':name,'fit_rmse_log_efficiency':r['fit_rmse'],'chronological_holdout_rmse_log_efficiency':r['holdout_rmse'],'parameters':p}
 if name in ['logarithmic','hyperbolic_ceiling']:
  o['status']='tail_unidentified';o['reason']='Logarithmic fits run to linear-efficiency limit; free hyperbolic-ceiling fits run toward shifted-power limit. Finite tail parameters are optimizer-bound-dependent.'
  return o
 if name in ['power','shifted_power','linear_efficiency']:
  power=p[1] if name!='linear_efficiency' else 1.
  o['power_exponent']=power
  raw=stop_fraction(power/(1+power));raw['exact_1e_minus120_threshold']=val(120+math.log10(power));o['raw_proxy']=raw
  if power<1:
   rec=stop_fraction(power);rec['exact_1e_minus120_threshold']=val(120+math.log10(power/(1-power)))
  elif power==1:
   rec=stop_almost_all(27.5);rec['exact_1e_minus120_threshold']={'status':'never','reason':'constant k=k0'}
  else:
   rec={'status':'no_finite_maximizer','reason':'Utility unbounded as a finite research singularity is approached; no downward 1e-120 crossing','research_singularity':val(27.5+math.log10(power/(power-1)))}
  o['recursive_proxy']=rec
 elif name=='exponential':
  raw=stop_almost_all(27.5);raw['exact_1e_minus120_threshold']={'status':'never','reason':'constant k=k0'};o['raw_proxy']=raw
  o['recursive_proxy']={'status':'no_finite_maximizer','reason':'Utility unbounded at finite research singularity; k increases','research_singularity':val(27.5)}
 elif name=='stretched_exponential':
  c=math.exp(p[1]);a=math.exp(p[2]);slope=c*a;q=1-a
  logremaining=27.5+q*(120-27.5-math.log10(slope))
  raw=stop_almost_all(logremaining);raw['exact_1e_minus120_threshold']=val(math.log10(slope)+27.5+92.5/q);o['raw_proxy']=raw
  logsing=27.5+((1-1/a)*math.log(c)+c+gammaln(1/a)+math.log(gammaincc(1/a,c)))/LN10
  o['stretched_exponent']=a;o['recursive_proxy']={'status':'no_finite_maximizer','reason':'Utility unbounded at finite research singularity; eventual k increases','research_singularity':val(logsing)}
 elif name=='exp_ceiling':
  H=math.exp(p[1]);T=math.exp(p[2]);C=H*math.exp(-1/T)
  lograw=math.log10(C/K0*L)
  raw=stop_early(lograw);raw['exact_1e_minus120_threshold']=val(lograw);o['raw_proxy']=raw
  d=brentq(lambda d:C*(-math.expm1(-d))-d+L,0,L+C+1)
  I=quad(lambda u:math.exp(-C*(-math.expm1(-u))),0,d,epsabs=1e-9,epsrel=1e-10)[0]
  logrec=math.log10(C/K0*I)
  rec=stop_early(logrec);rec['exact_1e_minus120_threshold']=val(logrec);o['recursive_proxy']=rec;o['ceiling_remaining_log_gain']=C
 elif name.startswith('hyperbolic_ceiling_p'):
  q=float(name[-1]);H=math.exp(p[1]);T=math.exp(p[2]);C=H*(1+1/T)**-q
  lograw=math.log10(q*C)+27.5+92.5/(q+1)
  logrec=lograw-C*q/(q+1)/LN10
  raw=stop_early(lograw);raw['exact_1e_minus120_threshold']=val(lograw);o['raw_proxy']=raw
  rec=stop_early(logrec);rec['exact_1e_minus120_threshold']=val(logrec);o['recursive_proxy']=rec;o['tail_exponent_fixed_not_estimated']=q;o['ceiling_remaining_log_gain']=C
 return o
if __name__=='__main__':
 res=[out(r) for r in json.loads((BASE/'fit_results.json').read_text())]
 (BASE/'stopping_results.json').write_text(json.dumps({'k0':K0,'budget_N':N,'current_anchor':'2023-06-22','fits':res},indent=2))
 for r in res:
  print(r['name'], 'RMSE',r['fit_rmse_log_efficiency'],r['chronological_holdout_rmse_log_efficiency'])
  for key in ['raw_proxy','recursive_proxy']:
   if key in r:print(key,r[key])
