#!/usr/bin/env python3
"""Selected rigorous pointwise finite-noise saturation certificate.

Interval clean trajectory and derivative bounds; exact rational matrix norm
certificates of every tube Jacobian. No reliance on float SVD accuracy.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys,json,time,argparse,hashlib
from pathlib import Path
from fractions import Fraction
import numpy as np
import mpmath as mp
from exact_svd_bound import operator_square_upper,rational_record,dyadic_integer_matrix
from verify_witness import interval,tanh_iv,clip_iv
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment'
sys.path.insert(0,str(EXP));import attacks

def endpoint_fraction(v,upper=True):
 sign,man,exponent,bc=v._mpi_[int(upper)]
 q=Fraction(int(man),1)
 q=q*(2**exponent) if exponent>=0 else q/Fraction(2**(-exponent),1)
 return -q if sign else q

def iv(q):
 q=Fraction(q);return mp.iv.mpf(q.numerator)/mp.iv.mpf(q.denominator)

def ceil_dyadic(v,bits=40):
 q=endpoint_fraction(v,True);num=-((-q.numerator*(2**bits))//q.denominator)
 return Fraction(num,2**bits)

def product_norm_bound(w,d,folder,layer):
 # Actual derivative caps d are exact dyadic; rounded products are proposals.
 exact=np.array([[Fraction.from_float(float(v))*dd for v,dd in zip(row,d)] for row in w],dtype=object)
 approx=np.array(exact,dtype=float)
 factor=folder/f'layer{layer}-factors.npz'
 g,rec=operator_square_upper(approx,factor_path=factor,existing_factor_path=factor if factor.exists() else None)
 error2=sum(((a-Fraction.from_float(float(b)))**2 for a,b in zip(exact.flat,approx.flat)),Fraction(0))
 eps=Fraction(1,10**10)
 upper=(1+eps)*g+(1+1/eps)*error2
 rec.update(actual_jacobian_squared_upper=rational_record(upper),product_rounding_frobenius_squared=rational_record(error2),product_rounding_young_epsilon=rational_record(eps),derivative_upper_numerators=[str(v.numerator)for v in d],derivative_upper_denominators=[str(v.denominator)for v in d])
 (folder/f'layer{layer}.json').write_text(json.dumps(rec,indent=2)+'\n')
 return upper

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--index',type=int,default=8);ap.add_argument('--uniform-index',type=int,default=3);ap.add_argument('--c',default='.0625');args=ap.parse_args()
 mp.iv.dps=90;c=Fraction(args.c);start=time.monotonic()
 path=next((EXP/'records').glob(f'{args.index:03d}-*.json'));record=json.loads(path.read_text());p=attacks.load_model(record['config']);N=len(p[-1]);H=len(p)-1
 xx,yy,indices,original=attacks.audit_inputs(record['config'],record)['heldout_uniform'];x=xx[args.uniform_index]
 folder=ROOT/f'pointwise-verified-{args.index:03d}-uniform{args.uniform_index}-c{args.c}';folder.mkdir(exist_ok=True)
 np.savez_compressed(folder/'input.npz',input=x)
 ev=N*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0));r2=c*c/(1+H*ev)
 h=[interval(v)for v in np.r_[x,1.]];q=Fraction(1);layers=[]
 for s,w in enumerate(p[:-1]):
  a=[sum((h[i]*interval(w[i,j])for i in range(len(h))),mp.iv.mpf(0))for j in range(N)]
  if s:
   state=mp.iv.sqrt(iv(N*r2*q));d=[]
   for j,aa in enumerate(a):
    col2=sum((Fraction.from_float(float(v))**2 for v in w[:,j]),Fraction(0))
    b=state*mp.iv.sqrt(iv(col2))
    abs_lower=Fraction(0)if bool(aa.a<=0 and aa.b>=0) else min(abs(endpoint_fraction(aa,False)),abs(endpoint_fraction(aa,True)))
    near=max(Fraction(0),endpoint_fraction(iv(abs_lower)-b,False))
    e=mp.iv.exp(-2*iv(near));upper=min(Fraction(1),ceil_dyadic(4*e/(1+e)**2))
    d.append(upper)
   ell2=product_norm_bound(w,d,folder,s);q=1+ell2*q
   layers.append(dict(layer=s,operator_squared_upper=rational_record(ell2),prefix_gain_squared=rational_record(q),max_derivative_upper_approx=float(max(d))))
   print('layer',s,'gain',float(q),'dmax',float(max(d)),flush=True)
  h=[tanh_iv(v)for v in a]
 clean=sum((v*interval(w)for v,w in zip(h,p[-1])),mp.iv.mpf(0));raw=mp.iv.sqrt(iv(r2*(1+ev*q)))
 disturbed=mp.iv.mpf([clean.a-raw.b,clean.b+raw.b]);changes={}
 for cap in [.5,1.]:
  difference=clip_iv(disturbed,cap)-clip_iv(clean,cap)
  changes[str(cap)]=dict(change_interval=str(difference),certified=bool(difference.a>=-mp.iv.mpf(1)/16 and difference.b<=mp.iv.mpf(1)/16))
 out=dict(model=path.stem,uniform_local_index=args.uniform_index,test_index=int(indices[args.uniform_index]),original_test_index=int(original[args.uniform_index]),label=float(yy[args.uniform_index]),c=float(c),c_exact=rational_record(c),readout_energy_exact=rational_record(ev),radius_squared_exact=rational_record(r2),clean_output_interval=str(clean),raw_output_change_upper_interval=str(raw),disturbed_output_enclosure=str(disturbed),clipped=changes,layers=layers,scope='This exact saved float32-normalized held-out input, with every simultaneous internal/output disturbance inside the specified radius; no input perturbation.',method='90decimal outward interval clean trajectory, dyadic outward derivative caps on reachable tubes, exact rational approximate-SVD matrix certificates and prefix-energy recursion.',qualification='Trusts mpmath interval evaluation and Python integer arithmetic; no trusted floating SVD accuracy; not a Lean formalization.',elapsed_seconds=time.monotonic()-start)
 (folder/'certificate.json').write_text(json.dumps(out,indent=2)+'\n');print('FINAL',out['clean_output_interval'],out['raw_output_change_upper_interval'],changes,flush=True)
if __name__=='__main__':main()
