#!/usr/bin/env python3
"""Fixed image-pair interpolation stress test, distinct from global claims."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time
from pathlib import Path
from fractions import Fraction
import numpy as np
r=Path(__file__).resolve().parent;sys.path.insert(0,str(r.parent/'experiment'));import train,attacks
from tv_zero_attack import total_variation
from verify_witness import verify

def band(z):return np.sign(z)*np.minimum(.25,np.maximum(abs(z)-.25,0))
def gains(p,x):
 z,_,ts=train.forward(p,x,cache=True);N=len(p[-1]);H=len(p)-1;ev=N*np.dot(p[-1],p[-1]);g=np.broadcast_to(p[-1],(len(x),N));sq=np.zeros(len(x))
 for s in reversed(range(H)):
  sq+=np.sum(g*g,axis=1)
  if s:g=(g*(1-ts[s]**2))@p[s].T
 return z,np.sqrt((1+N*sq)/(1+H*ev))

def main():
 start=time.monotonic();rec=json.loads(next((r.parent/'experiment/records').glob('105-*.json')).read_text());c=rec['config'];p=attacks.load_model(c)
 _,_,_,xf,y,orig=train.dataset(c,dtype=np.float64);pixels=np.rint((xf+1)*127.5).astype(np.uint8);ink=pixels.astype(float)/255;x=2*ink-1
 coords=np.indices((28,28));border=((coords[0]<2)|(coords[0]>=26)|(coords[1]<2)|(coords[1]>=26)).reshape(-1)
 tv=total_variation(ink);means=np.mean(ink,axis=1);scores=train.predict(p,x);eligible=(tv<=140)&(means<=.195)&np.all(pixels[:,border]==0,axis=1)&(y*scores>.5)
 neg=np.flatnonzero(eligible&(y<0));pos=np.flatnonzero(eligible&(y>0));rng=np.random.default_rng(368105);ni=rng.choice(neg,256,replace=False);pi=rng.choice(pos,256,replace=False)
 out=dict(model=c['id'],scope='Synthetic finite-grid interpolations of heldout opposite-parity images; endpoints are actualdata, interpolationsneednot be natural or have valid labels.',eligible_endpoint_count=int(np.sum(eligible)),endpoint_indices_negative=ni.tolist(),endpoint_indices_positive=pi.tolist(),target_groups=[],by_c={})
 allpix=[];allz=[];allg=[];allpair=[];alltarget=[]
 for target in [0.,.375]:
  lo=np.zeros(256);hi=np.ones(256)
  for step in range(40):
   mid=(lo+hi)/2;xx=x[ni]+mid[:,None]*(x[pi]-x[ni]);z=train.predict(p,xx);lower=z<target;lo=np.where(lower,mid,lo);hi=np.where(lower,hi,mid)
  alpha=(lo+hi)/2;continuous=x[ni]+alpha[:,None]*(x[pi]-x[ni]);realpix=np.clip((continuous+1)*127.5,0,255);floor=np.floor(realpix).astype(int);fraction=realpix-floor
  rng=np.random.default_rng(378105+int(target*1000));rounded=floor[:,None,:]+(rng.random((256,16,784))<fraction[:,None,:]).astype(int);flat=rounded.reshape(-1,784);zs=train.predict(p,(2*flat-255)/255).reshape(256,16)
  which=np.argmin(abs(zs-target),axis=1);chosen=rounded[np.arange(256),which];inputs=(2*chosen-255)/255;z,g=gains(p,inputs)
  actualtv=total_variation(chosen/255);actualink=np.mean(chosen/255,axis=1);valid=(actualtv<=150)&(actualink<=.2)&np.all(chosen[:,border]==0,axis=1)
  eligiblepairs=np.flatnonzero(valid);selected=eligiblepairs[np.argsort(-g[eligiblepairs],kind='stable')[:32]]
  out['target_groups'].append(dict(target=target,continuous_bracket_width_max=float(np.max(hi-lo)),valid_rounded_count=int(np.sum(valid)),selected_pair_indices=selected.tolist(),all_clean_outputs=z.tolist(),all_clean_linear_gain_ratios=g.tolist(),all_tvs=actualtv.tolist(),all_mean_inks=actualink.tolist(),selected_gain_min=float(np.min(g[selected])),selected_gain_max=float(np.max(g[selected]))))
  allpix.extend(chosen[selected]);allz.extend(z[selected]);allg.extend(g[selected]);allpair.extend(selected);alltarget.extend([target]*len(selected))
 pp=np.array(allpix,dtype=np.uint8);xx=(2*pp.astype(float)-255)/255;ev=c['width']*np.dot(p[-1],p[-1]);np.savez_compressed(r/'tv-boundary-105-candidates.npz',pixels=pp,clean_outputs=allz,gain_ratios=allg,pair_indices=allpair,targets=alltarget)
 verified_transforms=set()
 for const in [.001,.003,.01]:
  radius=const/np.sqrt(1+c['hidden_depth']*ev);a=attacks.attack(p,xx,radius,388105+int(const*1e6));row=dict(c=const,count=len(xx),clean_outputs=a['clean'].tolist(),minimum_outputs=a['minimum'].tolist(),maximum_outputs=a['maximum'].tolist(),transforms={})
  for name,fun in [('clip_half',lambda z:np.clip(z,-.5,.5)),('margin_band',band)]:
   up=abs(fun(a['maximum'])-fun(a['clean']));down=abs(fun(a['minimum'])-fun(a['clean']));change=np.maximum(up,down);j=int(np.argmax(change));choice=up[j]>down[j]
   rr=dict(numerical_violations=int(np.sum(change>1/16)),maximum_numerical_change=float(change[j]),worst_candidate_index=j)
   if change[j]>1/16 and name not in verified_transforms:
    eta=np.sqrt(c['width'])*(a['u_max'][:,j]if choice else a['u_min'][:,j]);noise=a['v_max'][j]if choice else a['v_min'][j];v=verify(p,xx[j],eta,const,noise,[Fraction(int(2*int(q)-255),255)for q in pp[j]])
    rr['verification']=v;np.savez(r/f'tv-boundary-105-{name}-c{const}.npz',pixels=pp[j],hidden_noise=eta,output_noise=noise);verified_transforms.add(name)
   row['transforms'][name]=rr
  out['by_c'][str(const)]=row;print(json.dumps(dict(c=const,transforms=row['transforms'])),flush=True)
 out['elapsed_seconds']=time.monotonic()-start;(r/'tv-boundary-105.json').write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
