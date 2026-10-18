#!/usr/bin/env python3
"""Exact rational dual lower bound for TV of zero-first-state images."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import json,hashlib
from pathlib import Path
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix,csr_matrix,vstack,hstack
from exact_svd_bound import dyadic_integer_matrix,rational_record
r=Path(__file__).resolve().parent;model=next((r.parent/'experiment/models').glob('105-*.npz'));w=np.load(model)['w0'].astype(float);d,N=w.shape[0]-1,w.shape[1]
coords=np.indices((28,28));border=((coords[0]<2)|(coords[0]>=26)|(coords[1]<2)|(coords[1]>=26)).reshape(-1)
edges=[(i*28+j,(i+1)*28+j)for i in range(27)for j in range(28)]+[(i*28+j,i*28+j+1)for i in range(28)for j in range(27)];m=len(edges)
rows=[];cols=[];vals=[]
for k,(i,j)in enumerate(edges):
 for row,sgn in [(2*k,1),(2*k+1,-1)]:rows.extend([row,row,row]);cols.extend([i,j,d+k]);vals.extend([sgn,-sgn,-1.])
A=coo_matrix((vals,(rows,cols)),shape=(2*m,d+m)).tocsr();A=vstack([A,csr_matrix(np.r_[np.ones(d),np.zeros(m)][None,:])]);b=np.r_[np.zeros(2*m),-.6*d]
eq=hstack([csr_matrix(w[:-1].T),csr_matrix((N,m))]);bounds=[(-1.,-1.)if bit else(-1.,1.)for bit in border]+[(0.,2.)]*m
lp=linprog(np.r_[np.zeros(d),np.ones(m)],A_ub=A,b_ub=b,A_eq=eq,b_eq=-w[-1],bounds=bounds,method='highs');assert lp.success
lam=lp.eqlin.marginals;mu=np.minimum(lp.ineqlin.marginals,0.)
np.savez_compressed(r/'tv-exclusion-dual-105.npz',equality_multipliers=lam,inequality_multipliers=mu)
wi,dw=dyadic_integer_matrix(w);li,dl=dyadic_integer_matrix(lam);prod=wi@li;products=[Fraction(int(v),dw*dl)for v in prod];mf=[Fraction.from_float(float(v))for v in mu]
rx=[-v-mf[-1] for v in products[:-1]];rt=[]
for k,(i,j)in enumerate(edges):
 q=mf[2*k]-mf[2*k+1];rx[i]-=q;rx[j]+=q;rt.append(1+mf[2*k]+mf[2*k+1])
constant=-products[-1]+mf[-1]*Fraction(-3*d,5)
box=sum((-v if fixed else-abs(v)for v,fixed in zip(rx,border)),Fraction(0))+sum((2*min(v,Fraction(0))for v in rt),Fraction(0))
tvbound=(constant+box)/2;lnorm=sum((abs(Fraction.from_float(float(v)))for v in lam),Fraction(0));threshold=Fraction(150);preact_epsilon=2*(tvbound-threshold)/lnorm
out=dict(model=model.stem,model_sha256=hashlib.sha256(model.read_bytes()).hexdigest(),scope='Every exactrealinput withouter2pixelborderblack, pixelbox[-1,1], meanink<=1/5 and EXACTzero firstpreactivations.',exact_tv_lower_bound=rational_record(tvbound),tv_lower_bound_approx=float(tvbound),zero_state_tv_exceeds_180=bool(tvbound>180),dual_constant_exact=rational_record(constant),box_residual_correction_exact=rational_record(box),equality_multiplier_l1_exact=rational_record(lnorm),approximate_zero_extension='For any suchinput with maxabsfirstpreactivation<=epsilon, TV>=lower_bound−(lambdaL1/2)*epsilon.',epsilon_for_tv150_exact=rational_record(preact_epsilon),epsilon_for_tv150_approx=float(preact_epsilon),method='Arbitrarydyadicequalitymultipliers andnonpositiveinequalitymultipliers; exactrationalresidualboundedoverallboxvariables. No LPsolveraccuracyoroptimalityistrusted.',qualification='Excludesexact/nearzero-first-stateinputsfromspecifiedTVregion; doesNOTprove networkstability onthatregion. Exactinteger/rationalarithmetic, not Lean.')
(r/'tv-exclusion-105-exact.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
