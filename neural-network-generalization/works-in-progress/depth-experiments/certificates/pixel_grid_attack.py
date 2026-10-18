#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,argparse
from pathlib import Path
from fractions import Fraction
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP))
import train,attacks
from verify_witness import verify


def main():
 ap=argparse.ArgumentParser();ap.add_argument('--index',type=int,default=4);ap.add_argument('--radii',default='.003,.01');args=ap.parse_args()
 index=args.index;rec=json.loads(next((EXP/'records').glob(f'{index:03d}-*.json')).read_text());c=rec['config'];p=attacks.load_model(c)
 xzero=np.linalg.lstsq(p[0][:-1].T,-p[0][-1],rcond=None)[0];realpixels=127.5*(xzero+1);low=np.floor(realpixels).astype(int);frac=realpixels-low
 assert low.min()>=0 and low.max()<255
 rng=np.random.default_rng(88000+index);pixels=low[None,:]+(rng.random((4096,len(low)))<frac).astype(int);x=(2*pixels-255)/255
 z=train.predict(p,x);selected=np.argsort(np.abs(z),kind='stable')[:16];xx=x[selected];pp=pixels[selected]
 ev=c['width']*np.sum(p[-1]**2);out=dict(model=c['id'],candidate_count=4096,seed=88000+index,pixel_min=int(pixels.min()),pixel_max=int(pixels.max()),selected_candidate_indices=selected.tolist(),selected_clean_outputs=z[selected].tolist(),by_c={})
 for const in map(float,args.radii.split(',')):
  radius=const/np.sqrt(1+c['hidden_depth']*ev);a=attacks.attack(p,xx,radius,99000+index+int(const*1e6))
  base=np.clip(a['clean'],-.5,.5);up=np.abs(np.clip(a['maximum'],-.5,.5)-base);down=np.abs(np.clip(a['minimum'],-.5,.5)-base);change=np.maximum(up,down);j=int(np.argmax(change));choose=up[j]>down[j]
  eta=np.sqrt(c['width'])*(a['u_max'][:,j]if choose else a['u_min'][:,j]);noise=a['v_max'][j]if choose else a['v_min'][j]
  row=dict(c=const,numerical_violation_count=int(np.sum(change>1/16)),maximum_numerical_clipped_change=float(change[j]),selected_candidate_index=int(selected[j]))
  if change[j]>1/16:
   row['verification']=verify(p,xx[j],eta,const,noise,[Fraction(int(2*v-255),255)for v in pp[j]])
   assert row['verification']['exact_rational_budget_pass']and row['verification']['clipped']['0.5']['violation']
   np.savez(ROOT/f'pixel-grid-{index:03d}-c{const}.npz',pixels=pp[j].astype(np.uint8),input_float64=xx[j],hidden_noise=eta,output_noise=noise)
  out['by_c'][str(const)]=row;print(json.dumps(row),flush=True)
 out['scope']='Actual uint8 pixel grid, but synthetic near-gray image. Verification uses exact rational normalized pixels, not float32-rounded training preprocessing. Exact linear Booleanbitdecoder gives equivalent6272-bit-input network.'
 (ROOT/f'pixel-grid-{index:03d}.json').write_text(json.dumps(out,indent=2)+'\n')

if __name__=='__main__':main()
