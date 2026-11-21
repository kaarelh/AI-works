"""Exploratory finite-depth Gaussian-kernel calculation, not a theorem check.

The proved ordering is shallow. This program tests a precisely specified deeper
recursion with equal bias and hidden-signal variance. Mesh differences estimate
numerical sensitivity, not certified error. Tiny Fourier tails are unresolved.
"""
import os
for k in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[k]='1'
import json,math,time
from pathlib import Path
import numpy as np
from scipy.special import roots_hermitenorm
ROOT=Path(__file__).resolve().parents[1]

def radial_eigenvalues(d,k):
    return np.array([sum((-1)**l*math.comb(p,l)*math.comb(d-p,h)*k[l+h]
                        for l in range(p+1) for h in range(d-p+1))/2**d
                     for p in range(1,d+1)])

def run(d,beta,n,depths):
    z,w=roots_hermitenorm(n);w/=math.sqrt(2*math.pi);measure=w[:,None]*w[None,:]
    den=.5 if beta is None else float(np.dot(w,(np.logaddexp(0,beta*z)/beta)**2))
    c=np.array([(d+1-2*h)/(d+1) for h in range(d+1)]);rows=[]
    for depth in range(1,depths+1):
        nxt=[]
        for value in c:
            value=float(np.clip(value,-1,1))
            if value>=1-2e-15:v=1.
            elif beta is None:v=(math.sqrt(1-value*value)+value*(math.pi-math.acos(value)))/math.pi
            else:
                u=math.sqrt((1+value)/2)*z[:,None];v=math.sqrt((1-value)/2)*z[None,:]
                p=np.logaddexp(0,beta*(u+v))/beta;q=np.logaddexp(0,beta*(u-v))/beta
                v=float(np.sum(measure*p*q))/den
            nxt.append((1+v)/2)
        c=np.array(nxt);lam=radial_eigenvalues(d,c)
        mass=lam*np.array([math.comb(d,p) for p in range(1,d+1)])
        rows.append(dict(depth=depth,radial_kernel=c.tolist(),eigenvalues=lam.tolist(),
                         total_centered_variance=float(mass.sum()),upper_tails=(np.cumsum(mass[::-1])[::-1]/mass.sum()).tolist()))
    return rows

def main():
    start=time.monotonic();rows=[];comparisons=[]
    for d in (2,3,4,6,8,12):
        groups=[]
        for beta in (.25,.5,1.,2.,4.,8.,None):
            low=run(d,beta,128,6);high=run(d,beta,256,6)
            record=dict(dimension=d,beta=beta,coarse=low,fine=high);rows.append(record);groups.append(record)
            print(json.dumps(dict(dimension=d,beta=beta,seconds=time.monotonic()-start)),flush=True)
        for old,new in zip(groups,groups[1:]):
            for j in range(6):
                for k in range(1,d):
                    oldval=old['fine'][j]['upper_tails'][k];newval=new['fine'][j]['upper_tails'][k]
                    mesh=abs(oldval-old['coarse'][j]['upper_tails'][k])+abs(newval-new['coarse'][j]['upper_tails'][k])
                    gap=newval-oldval;tol=max(1e-10,100*mesh)
                    status='increase_resolved_heuristically' if gap>tol else ('candidate_decrease' if gap < -tol else 'unresolved')
                    comparisons.append(dict(dimension=d,depth=j+1,minimum_degree=k+1,old_beta=old['beta'],new_beta=new['beta'],gap=gap,mesh_difference=mesh,status=status))
    counts={k:sum(x['status']==k for x in comparisons) for k in ('increase_resolved_heuristically','candidate_decrease','unresolved')}
    report=dict(status='complete',scope=__doc__.strip(),seconds=time.monotonic()-start,rows=rows,comparisons=comparisons,counts=counts)
    (ROOT/'results/deep_spectral_order_exploration.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(status='complete',seconds=report['seconds'],counts=counts)),flush=True)
if __name__=='__main__':main()
