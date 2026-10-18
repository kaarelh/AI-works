#!/usr/bin/env python3
"""Exact finite-radius Taylor certificate using the full clean-response covariance.

For row Jacobian A_s=W_s D_s, G_0=I and G_s=A_s.T G_{s-1} A_s+I
are the hidden-noise linear-response Gramians. Their operator norms replace
products of local norms. Signed nonlinear remainders are propagated by clean
adjoints; their state norms are enclosed inductively. All matrix products for
G and adjoints use outward-rounded integer dyadic intervals.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,sys,json,time,hashlib
from pathlib import Path
from fractions import Fraction
import numpy as np,mpmath as mp
import exact_boolean_cube as base
import verify_reachable_tube as point
from fast_exact_svd_bound import operator_square_upper
from exact_svd_bound import dyadic_integer_matrix,rational_record
from verify_witness import tanh_iv
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';BITS=320;S=2**BITS
point.operator_square_upper=operator_square_upper

def fl(v,den):return v//den

def ce(v,den):return -((-v)//den)

def right(lo,hi,wi,dw):
 pos=np.maximum(wi,0);neg=np.minimum(wi,0)
 return fl(lo@pos+hi@neg,dw),ce(hi@pos+lo@neg,dw)

def left(lo,hi,wi,dw):
 pos=np.maximum(wi,0);neg=np.minimum(wi,0)
 return fl(pos@lo+neg@hi,dw),ce(pos@hi+neg@lo,dw)

def multiply(lo,hi,dl,dh,den=S):
 a=lo*dl;b=lo*dh;c=hi*dl;d=hi*dh
 return fl(np.minimum(np.minimum(a,b),np.minimum(c,d)),den),ce(np.maximum(np.maximum(a,b),np.maximum(c,d)),den)

def fixed_iv(lo,hi):return base.bounds_iv(lo,hi,S)

def floor_iv(v,bits=60):
 q=base.endpoint_fraction(v,False);den=2**bits;return Fraction((q.numerator*den)//q.denominator,den)

def frac_upper(v,bits=60):return base.ceil_dyadic(v,bits)

def gram_norm(lo,hi,folder):
 approx=(np.array(lo,dtype=float)+np.array(hi,dtype=float))/(2*float(S));np.savez_compressed(folder/'covariance-proposal.npz',matrix=approx)
 g2,record=operator_square_upper(approx,factor_path=folder/'covariance-factors.npz')
 mi,dm=dyadic_integer_matrix(approx)
 if S%dm==0:
  mid=mi*(S//dm);error=np.maximum(np.abs(lo-mid),np.abs(hi-mid));e2=Fraction(sum(int(v)*int(v)for v in error.flat),S*S)
 else:
  den=max(S,dm);error=np.maximum(np.abs(lo*(den//S)-mi*(den//dm)),np.abs(hi*(den//S)-mi*(den//dm)));e2=Fraction(sum(int(v)*int(v)for v in error.flat),den*den)
 upper=frac_upper(mp.iv.sqrt(base.iv(g2))+mp.iv.sqrt(base.iv(e2)))
 record.update(interval_entry_error_frobenius_squared=rational_record(e2),true_covariance_operator_upper=rational_record(upper))
 (folder/'covariance-norm.json').write_text(json.dumps(record,indent=2)+'\n');return upper

def remainder(ai,hi,di,b):
 bb=base.iv(b);values=[mp.iv.mpf(0),tanh_iv(ai-bb)-hi+di*bb,tanh_iv(ai+bb)-hi-di*bb]
 critical=-2*ai
 if bool(critical.a<=bb.b and critical.b>=-bb.b):values.append(-2*hi+2*ai*di)
 cap=b*b/2 # |tanh''|<=1 globally.
 lo=max(-cap,min(base.endpoint_fraction(v,False)for v in values));up=min(cap,max(base.endpoint_fraction(v,True)for v in values))
 if lo>0 or up<0 or lo>up:raise AssertionError('Remainder must enclose zero.')
 return lo,up

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--index',type=int,default=505);ap.add_argument('--vertex',type=int,default=325);ap.add_argument('--c',default='1/1000');args=ap.parse_args();start=time.monotonic();mp.iv.dps=120;base.BITS=BITS;base.SCALE=S
 model=next((EXP/'models').glob(f'{args.index:03d}-*.npz'));saved=np.load(model);p=[saved[k]for k in sorted([k for k in saved.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]))];N=len(p[-1]);H=len(p)-1
 if p[0].shape[0]!=10:raise ValueError('Declared9-bit model only.')
 x=(2*((args.vertex>>np.arange(9))&1)-1).astype(float);c=Fraction(args.c);ev=N*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0));r2=c*c/(1+H*ev);eta=mp.iv.sqrt(base.iv(N*r2))
 folder=ROOT/f'point-covariance-verified-{args.index:03d}-v{args.vertex}-c{args.c.replace("/","_")}';folder.mkdir(exist_ok=True)
 zlo,zhi,history=base.forward_batch(p,x[None,:],True);aa=[];hh=[];dd=[];dl=[];dh=[];weights=[]
 for s,w in enumerate(p[:-1]):
  al,ah,den=history[s];a=[base.bounds_iv(al[0,j],ah[0,j],den)for j in range(N)];h=[tanh_iv(t)for t in a];d=[mp.iv.mpf(1)-t**2 for t in h]
  low=np.array([max(0,base.scaled_endpoint(v,False))for v in d],dtype=object);high=np.array([min(S,base.scaled_endpoint(v,True))for v in d],dtype=object)
  aa.append(a);hh.append(h);dd.append(d);dl.append(low);dh.append(high);weights.append(dyadic_integer_matrix(w))
 # Exact outward interval clean output adjoints.
 vi,dv=dyadic_integer_matrix(p[-1]);den=max(S,dv);gl=fl(vi*(den//dv),den//S);gh=ce(vi*(den//dv),den//S);adj=[None]*H;adj[-1]=(gl,gh)
 for s in range(H-1,0,-1):
  vl,vh=multiply(gl,gh,dl[s],dh[s]);wi,dw=weights[s];gl,gh=left(vl,vh,wi,dw);adj[s-1]=(gl,gh)
 gain2=Fraction(0)
 for gl,gh in adj:gain2+=Fraction(sum(max(abs(int(a)),abs(int(b)))**2 for a,b in zip(gl,gh)),S*S)
 linear=frac_upper(mp.iv.sqrt(base.iv(r2*(1+N*gain2))))
 Glo=np.eye(N,dtype=object)*S;Ghi=Glo.copy();rho=Fraction(0);B=frac_upper(eta);outlo=Fraction(0);outhi=Fraction(0);layers=[]
 for s in range(1,H):
  w=p[s];wi,dw=weights[s];sub=folder/f'layer-{s:03d}';sub.mkdir(exist_ok=True)
  col2=[Fraction(sum(int(v)*int(v)for v in wi[:,j]),dw*dw)for j in range(N)]
  bs=[frac_upper(base.iv(B)*mp.iv.sqrt(base.iv(v)))for v in col2];rs=[remainder(aa[s][j],hh[s][j],dd[s][j],bs[j])for j in range(N)]
  dupper=[Fraction(int(v),S)for v in dh[s]]
  # Round positive derivative caps outward to40bits for compact norm proposals.
  dupper=[Fraction(-((-v.numerator*(2**40))//v.denominator),2**40)for v in dupper]
  ell2=point.product_norm_bound(w,dupper,sub,s)
  prelo,prehi=left(Glo,Ghi,wi.T,dw);prelo,prehi=right(prelo,prehi,wi,dw)
  dlo=dl[s][:,None]*dl[s][None,:];dhi=dh[s][:,None]*dh[s][None,:]
  Glo,Ghi=multiply(prelo,prehi,dlo,dhi,S*S);Glo+=np.eye(N,dtype=object)*S;Ghi+=np.eye(N,dtype=object)*S
  covariance=gram_norm(Glo,Ghi,sub);remainder2=sum((max(abs(a),abs(b))**2 for a,b in rs),Fraction(0))
  rho=frac_upper(mp.iv.sqrt(base.iv(ell2))*base.iv(rho)+mp.iv.sqrt(base.iv(remainder2)))
  B=frac_upper(eta*mp.iv.sqrt(base.iv(covariance))+base.iv(rho))
  gl,gh=adj[s]
  for j,(rl,rh)in enumerate(rs):
   products=[Fraction(int(g),S)*rr for g in [gl[j],gh[j]]for rr in [rl,rh]];outlo+=min(products);outhi+=max(products)
  layers.append(dict(layer=s,covariance_operator_upper=rational_record(covariance),remainder_state_norm_upper=rational_record(rho),total_state_norm_upper=rational_record(B),maximum_preactivation_displacement_upper=rational_record(max(bs)),clean_operator_squared_upper=rational_record(ell2),remainder_norm_squared_upper=rational_record(remainder2)))
  print('LAYER',s,'state',float(B),'covnorm',float(covariance),'remainder',float(rho),flush=True)
 state_output=frac_upper(base.iv(B)*mp.iv.sqrt(base.iv(ev/N))+mp.iv.sqrt(base.iv(r2)))
 lower=max(zlo[0]-linear+outlo,zlo[0]-state_output);upper=min(zhi[0]+linear+outhi,zhi[0]+state_output);cap=Fraction(1,2);clip=lambda v:max(-cap,min(cap,v));change=max(clip(upper)-clip(zlo[0]),clip(zhi[0])-clip(lower))
 result=dict(model=model.stem,model_sha256=hashlib.sha256(model.read_bytes()).hexdigest(),vertex=args.vertex,c_exact=rational_record(c),readout_energy_exact=rational_record(ev),noise_radius_squared_exact=rational_record(r2),clean_output_lower=rational_record(zlo[0]),clean_output_upper=rational_record(zhi[0]),perturbed_output_lower=rational_record(lower),perturbed_output_upper=rational_record(upper),linear_output_change_upper=rational_record(linear),state_based_output_change_upper=rational_record(state_output),signed_output_remainder_lower=rational_record(outlo),signed_output_remainder_upper=rational_record(outhi),clipped_change_upper=rational_record(change),certified=change<=Fraction(1,16),layers=layers,dyadic_bits=BITS,interval_decimal_digits=mp.iv.dps,elapsed_seconds=time.monotonic()-start,scope='The exact declared Boolean vertex, every simultaneous hidden/output disturbance in the specified radius; cap1/2 and tolerance1/16.',qualification='Exact dyadic interval clean covariance/adjoints, exact matrix-factor bounds, outward interval tanh and signed Taylor remainders. Not Lean; no floating sufficient test is used as a proof.')
 (folder/'certificate.json').write_text(json.dumps(result,indent=2)+'\n');print('FINAL',float(lower),float(upper),float(change),result['certified'],time.monotonic()-start,flush=True)
if __name__=='__main__':main()
