#!/usr/bin/env python3
"""Postprotocol targeted test of optional score, fixed +3/8 clean target."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time
from pathlib import Path
from fractions import Fraction
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP))
import train,attacks
from verify_witness import verify

def band(z):return np.sign(z)*np.minimum(.25,np.maximum(abs(z)-.25,0))

def main():
 index=105;c=json.loads(next((EXP/'records').glob('105-*.json')).read_text())['config'];p=attacks.load_model(c)
 a=np.load(ROOT/'lowink-zero-105.npz');x0=a['continuous_zero_input'].copy();x=x0.copy();free=(x0>-1+1e-8)&(x0<1-1e-8);history=[]
 for step in range(40):
  z,_,ts=train.forward(p,x[None,:],cache=True);g=p[-1].copy()
  for j in reversed(range(len(ts))):g=(g*(1-ts[j][0]**2))@p[j].T
  g=g[:-1]*free;error=.375-z[0];history.append(dict(step=step,output=float(z[0])))
  if abs(error)<1e-10:break
  delta=error*g/(np.dot(g,g)+1e-300);delta*=min(1,.01/(np.linalg.norm(delta)+1e-300))
  candidate=np.clip(x+delta,-1,1)
  for backtrack in range(20):
   newz=float(train.forward(p,candidate[None,:])[0])
   if abs(newz-.375)<abs(error):break
   delta*=.5;candidate=np.clip(x+delta,-1,1)
  x=candidate
 pix=np.clip(127.5*(x+1),0,255);low=np.floor(pix).astype(int);frac=pix-low;rng=np.random.default_rng(198105)
 pixels=low[None,:]+(rng.random((4096,len(x)))<frac).astype(int);xx=(2*pixels-255)/255;z=train.predict(p,xx)
 selected=np.argsort(abs(z-.375),kind='stable')[:16];inputs=xx[selected];pp=pixels[selected]
 const=.001;ev=c['width']*np.sum(p[-1]**2);radius=const/np.sqrt(1+c['hidden_depth']*ev);res=attacks.attack(p,inputs,radius,208105)
 up=abs(band(res['maximum'])-band(res['clean']));down=abs(band(res['minimum'])-band(res['clean']));change=np.maximum(up,down);j=int(np.argmax(change));choose=up[j]>down[j]
 eta=np.sqrt(c['width'])*(res['u_max'][:,j]if choose else res['u_min'][:,j]);output=res['v_max'][j]if choose else res['v_min'][j]
 verification=verify(p,inputs[j],eta,const,output,[Fraction(int(2*int(v)-255),255)for v in pp[j]])
 np.savez(ROOT/'margin-band-target-105.npz',pixels=pp[j].astype(np.uint8),hidden_noise=eta,output_noise=output,continuous_target_input=x)
 out=dict(model=c['id'],optional_postprotocol_variant=True,clean_target=.375,newton_history=history,selected_candidate_indices=selected.tolist(),selected_clean_outputs=z[selected].tolist(),selected_witness_index=int(selected[j]),numerical_band_violation_count=int(np.sum(change>1/16)),maximum_numerical_band_change=float(change[j]),witness_mean_ink=float(np.mean(pp[j])/255),verification=verification,scope='Synthetic black-border low-ink uint8 input, selected for optional margin-band score; raw trained weights; no natural-label assertion.')
 (ROOT/'margin-band-target-105.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
if __name__=='__main__':main()
