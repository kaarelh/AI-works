"""Numerical cumulants for the XOR statistic under Gaussian/quartic priors.

All parameter coordinates have variance one. Gaussian integration over the
readout is exact. Quartic quadrature uses |theta/scale|^4 ~ Gamma(1/4).
This is illustrative quadrature, not the critical-mean interval certificate.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import roots_hermitenorm,roots_genlaguerre,gammaln,logsumexp
ROOT=Path(__file__).resolve().parents[1]
def G(b,u,v):
 lc=lambda z:np.logaddexp(z,-z)-np.log(2)
 return (np.logaddexp(lc(b),lc(u+v))-np.logaddexp(lc(b),lc(u-v)))/4
ap=argparse.ArgumentParser();ap.add_argument('--quartic-n',type=int,default=24);ap.add_argument('--gaussian-n',type=int,default=96);args=ap.parse_args();start=time.time();rows=[]
x,w=roots_hermitenorm(args.gaussian_n);lw=np.log(w)-.5*np.log(2*np.pi);g=G(x[:,None,None],x[None,:,None],x[None,None,:]).ravel();lq=(lw[:,None,None]+lw[None,:,None]+lw[None,None,:]).ravel()
for t in np.linspace(0,2*np.sqrt(2),81):
 e=lq+t*t*g*g/2;logM=logsumexp(e);m=t*np.sum(np.exp(e-logM)*g*g);rows.append(dict(prior='Gaussian',t=float(t),mean=float(m),log_mgf=float(logM),rate=float(t*m-logM)))
x,w=roots_genlaguerre(args.quartic_n,-.75);scale=math.exp((gammaln(.25)-gammaln(.75))/2);xx=np.r_[-x**.25,x**.25]*scale;ww=np.r_[w,w]/(2*math.exp(gammaln(.25)));lw=np.log(ww)
g=G(xx[:,None,None],xx[None,:,None],xx[None,None,:]).ravel();lq=(lw[:,None,None]+lw[None,:,None]+lw[None,None,:]).ravel()
z=(xx[:,None]*g[None,:]).ravel();lq=(lw[:,None]+lq[None,:]).ravel()
for t in np.linspace(0,5,101):
 e=lq+t*z;logM=logsumexp(e);m=np.sum(np.exp(e-logM)*z);rows.append(dict(prior='Quartic unit variance',t=float(t),mean=float(m),log_mgf=float(logM),rate=float(t*m-logM)))
meta=dict(quartic_n=args.quartic_n,gaussian_n=args.gaussian_n,quartic_scale=scale,seconds=time.time()-start,rows=rows)
path=ROOT/'results'/f'softplus_rate_curves_q{args.quartic_n}_g{args.gaussian_n}.json';path.write_text(json.dumps(meta,indent=2)+'\n')
print(json.dumps(dict(path=str(path),seconds=time.time()-start,gaussian_critical=rows[80],quartic_final=rows[-1])),flush=True)
