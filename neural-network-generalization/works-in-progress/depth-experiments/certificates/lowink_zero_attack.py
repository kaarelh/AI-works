#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time,argparse
from pathlib import Path
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP))
import train,attacks
from verify_witness import verify


def main():
 ap=argparse.ArgumentParser();ap.add_argument('--index',type=int,default=8);args=ap.parse_args();index=args.index
 rec=json.loads(next((EXP/'records').glob(f'{index:03d}-*.json')).read_text());c=rec['config'];p=attacks.load_model(c);d=c['dimension']
 coords=np.indices((28,28));border=((coords[0]<2)|(coords[0]>=26)|(coords[1]<2)|(coords[1]>=26)).reshape(-1)
 bounds=[(-1.,-1.)if b else(-1.,1.)for b in border]
 lp=linprog(np.ones(d),A_eq=p[0][:-1].T,b_eq=-p[0][-1],bounds=bounds,method='highs')
 record=dict(model=c['id'],lp_success=bool(lp.success),lp_message=lp.message)
 if not lp.success:
  (ROOT/f'lowink-zero-{index:03d}.json').write_text(json.dumps(record,indent=2)+'\n');return
 x0=lp.x;pix=np.clip(127.5*(x0+1),0,255);low=np.floor(pix).astype(int);prob=pix-low
 rng=np.random.default_rng(98000+index);pixels=low[None,:]+(rng.random((4096,d))<prob).astype(int);x=(2*pixels-255)/255
 z=train.predict(p,x);selected=np.argsort(np.abs(z),kind='stable')[:16];xx=x[selected];pp=pixels[selected]
 record.update(first_preactivation_residual=float(np.max(np.abs(np.r_[x0,1]@p[0]))),average_ink=float(np.mean(pix)/255),black_pixel_fraction=float(np.mean(pix<1e-6)),white_pixel_fraction=float(np.mean(pix>255-1e-6)),fractional_pixel_count=int(np.sum((pix>1e-6)&(pix<255-1e-6))),selected_indices=selected.tolist(),selected_clean_outputs=z[selected].tolist())
 const=.001;ev=c['width']*np.sum(p[-1]**2);radius=const/np.sqrt(1+c['hidden_depth']*ev);a=attacks.attack(p,xx,radius,108000+index)
 base=np.clip(a['clean'],-.5,.5);up=np.abs(np.clip(a['maximum'],-.5,.5)-base);down=np.abs(np.clip(a['minimum'],-.5,.5)-base);change=np.maximum(up,down);j=int(np.argmax(change));choose=up[j]>down[j]
 eta=np.sqrt(c['width'])*(a['u_max'][:,j]if choose else a['u_min'][:,j]);output=a['v_max'][j]if choose else a['v_min'][j]
 record.update(c=const,selected_candidate_index=int(selected[j]),numerical_violation_count=int(np.sum(change>1/16)),maximum_numerical_change=float(change[j]),witness_average_ink=float(np.mean(pp[j])/255))
 if change[j]>1/16:
  record['verification']=verify(p,xx[j],eta,const,output,[Fraction(int(2*v-255),255)for v in pp[j]])
  assert record['verification']['exact_rational_budget_pass']and record['verification']['clipped']['0.5']['violation']
 np.savez(ROOT/f'lowink-zero-{index:03d}.npz',pixels=pp[j].astype(np.uint8),continuous_zero_input=x0,hidden_noise=eta,output_noise=output)
 record['scope']='Finite8bitimage withfixedblackborderandlowtotalink; synthesizedusingtrainedweights, not a heldoutnaturalimage. Noise/outputverifiedexactly/withintervals.'
 (ROOT/f'lowink-zero-{index:03d}.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record),flush=True)

if __name__=='__main__':main()
