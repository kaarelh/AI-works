#!/usr/bin/env python3
"""Post-audit refinement of the single unresolved primary-radius vertex."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
import datetime,json,sys,time
import numpy as np
import attacks

ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'certificates'))
from explicit_signed import certificate
from finite_tube import clipped_change

def main():
    path=next((ROOT/'full-cube').glob('505*.json'));initial=json.loads(path.read_text())
    selected=next(s for s in initial['summaries'] if s['c']==.001)['unresolved_indices']
    assert selected==[325], 'The refinement selection must match its frozen initial audit.'
    protocol=ROOT/'boolean-single-refinement-protocol.json'
    if not protocol.exists():
        protocol.write_text(json.dumps(dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            status='Exploratory stronger bound chosen after the initial exhaustive audit; original audit is retained.',
            model=initial['config']['id'],input_index=325,c=.001,
            selection='The only unresolved vertex at the primary radius across the six full512 audits.',
            budget='One explicit clean-transfer/signed-remainder certificate; no new attack or training.'),indent=2)+'\n')
    p=attacks.load_model(initial['config']);x=(2*((325>>np.arange(9))&1)-1).astype(float)
    started=time.monotonic();new=certificate(p,x,.001);old=initial['rows'][325]['by_c']['0.001']
    merged=dict(old);merged['lower']=max(old['lower'],new['lower']);merged['upper']=min(old['upper'],new['upper'])
    bound=clipped_change(merged,.5)
    merged.update(clipped_change_bound=bound,certified=bound<=1/16,
                  method='Intersection of initial and explicit clean-transfer bounds',
                  max_preactivation_tube=new['max_preactivation_tube'])
    output=dict(model=initial['config']['id'],input_index=325,c=.001,initial=old,stronger=new,
                intersection=merged,clipped_change_bound=bound,certified=bound<=1/16,
                elapsed_seconds=time.monotonic()-started,
                qualification='Float64 sufficient inequalities, not interval-verified. The original exhaustive audit is unchanged.')
    (ROOT/'boolean-single-refinement.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(output),flush=True)

if __name__=='__main__':main()
