#!/usr/bin/env python3
"""Exploratory smooth low-ink finite-grid counterexample, model105."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time
from pathlib import Path
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix,csr_matrix,vstack,hstack
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP));import attacks,train
from verify_witness import verify

def total_variation(images):
 a=images.reshape(-1,28,28)
 return np.sum(abs(np.diff(a,axis=1)),axis=(1,2))+np.sum(abs(np.diff(a,axis=2)),axis=(1,2))

def main():
 start=time.monotonic();rec=json.loads(next((EXP/'records').glob('105-*.json')).read_text());c=rec['config'];p=attacks.load_model(c);d=c['dimension']
 coords=np.indices((28,28));border=((coords[0]<2)|(coords[0]>=26)|(coords[1]<2)|(coords[1]>=26)).reshape(-1)
 edges=[(i*28+j,(i+1)*28+j)for i in range(27)for j in range(28)]+[(i*28+j,i*28+j+1)for i in range(28)for j in range(27)];m=len(edges)
 rows=[];cols=[];vals=[]
 for k,(i,j)in enumerate(edges):
  for row,sgn in [(2*k,1),(2*k+1,-1)]:
   rows.extend([row,row,row]);cols.extend([i,j,d+k]);vals.extend([sgn,-sgn,-1.])
 A=coo_matrix((vals,(rows,cols)),shape=(2*m,d+m)).tocsr();inkrow=csr_matrix(np.r_[np.ones(d),np.zeros(m)][None,:]);A=vstack([A,inkrow]);b=np.r_[np.zeros(2*m),(2*.2-1)*d]
 eq=hstack([csr_matrix(p[0][:-1].T),csr_matrix((c['width'],m))]);bounds=[(-1.,-1.)if bit else(-1.,1.)for bit in border]+[(0.,2.)]*m
 lp=linprog(np.r_[np.zeros(d),np.ones(m)],A_ub=A,b_ub=b,A_eq=eq,b_eq=-p[0][-1],bounds=bounds,method='highs')
 out=dict(model=c['id'],lp_success=bool(lp.success),lp_message=lp.message,scope='Exploratory synthetic input with total-variation objective and ink/border constraints; no claim of natural digit semantics.')
 if not lp.success:
  (ROOT/'tv-zero-105.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True);return
 x0=lp.x[:d];pix=np.clip(127.5*(x0+1),0,255);low=np.floor(pix).astype(int);frac=pix-low;rng=np.random.default_rng(258105)
 pixels=low[None,:]+(rng.random((4096,d))<frac).astype(int);xx=(2*pixels-255)/255;z=train.predict(p,xx);selected=np.argsort(abs(z),kind='stable')[:16]
 ev=c['width']*np.dot(p[-1],p[-1]);radius=.001/np.sqrt(1+c['hidden_depth']*ev);a=attacks.attack(p,xx[selected],radius,268105)
 up=abs(np.clip(a['maximum'],-.5,.5)-np.clip(a['clean'],-.5,.5));down=abs(np.clip(a['minimum'],-.5,.5)-np.clip(a['clean'],-.5,.5));change=np.maximum(up,down);j=int(np.argmax(change));choice=up[j]>down[j];chosen=int(selected[j]);eta=np.sqrt(c['width'])*(a['u_max'][:,j]if choice else a['u_min'][:,j]);noise=a['v_max'][j]if choice else a['v_min'][j]
 v=verify(p,xx[chosen],eta,.001,noise,[Fraction(int(2*int(q)-255),255)for q in pixels[chosen]])
 np.savez(ROOT/'tv-zero-105.npz',pixels=pixels[chosen].astype(np.uint8),continuous_zero_input=x0,hidden_noise=eta,output_noise=noise)
 _,_,_,xt,_,_=train.dataset(c,dtype=np.float64);heldpixels=np.rint((xt+1)*127.5)/255;tv=total_variation(heldpixels);ink=np.mean(heldpixels,axis=1);bd=np.mean(heldpixels[:,border],axis=1);witness=pixels[chosen]/255;wtv=float(total_variation(witness)[0]);wink=float(np.mean(witness));quantiles=[0,.01,.05,.1,.5,.9,.95,.99,1]
 out.update(c=.001,continuous_tv=float(total_variation((x0+1)/2)[0]),continuous_mean_ink=float(np.mean((x0+1)/2)),maximum_first_preactivation_residual=float(np.max(abs(np.r_[x0,1]@p[0]))),witness_tv=wtv,witness_mean_ink=wink,witness_border_mean_ink=float(np.mean(witness[border])),witness_black_fraction=float(np.mean(witness==0)),numerical_violation_count=int(np.sum(change>1/16)),maximum_numerical_change=float(change[j]),selected_candidate_indices=selected.tolist(),selected_candidate_clean_outputs=z[selected].tolist(),witness_candidate_index=chosen,verification=v,heldout_comparison=dict(count=len(xt),quantile_levels=quantiles,total_variation_quantiles=np.quantile(tv,quantiles).tolist(),mean_ink_quantiles=np.quantile(ink,quantiles).tolist(),border_mean_ink_quantiles=np.quantile(bd,quantiles).tolist(),fraction_tv_at_least_witness=float(np.mean(tv>=wtv)),fraction_mean_ink_at_least_witness=float(np.mean(ink>=wink)),fraction_tv_and_ink_at_least_witness=float(np.mean((tv>=wtv)&(ink>=wink)))),elapsed_seconds=time.monotonic()-start)
 (ROOT/'tv-zero-105.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
if __name__=='__main__':main()
