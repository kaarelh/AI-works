#!/usr/bin/env python3
"""Optional postprotocol confident-input, hidden-only finite-grid stress test."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import datetime,json,sys,time
from pathlib import Path
from fractions import Fraction
import numpy as np

ROOT=Path(__file__).resolve().parent
EXP=ROOT.parent/'experiment'
sys.path.insert(0,str(EXP))
import train,attacks
from verify_witness import verify

def main():
    started=time.monotonic();target=.55;constant=.001
    protocol=ROOT/'confident-target-protocol.json'
    if not protocol.exists():
        protocol.write_text(json.dumps(dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            status='Optional postprotocol follow-up requested after the original and margin-band witnesses; no new training.',
            model_index=105,clean_target=target,newton_steps=40,newton_step_l2_cap=.01,
            backtracks_per_step=20,stochastic_uint8_roundings=4096,nearest_candidates=16,
            rounding_seed=298105,attack_seed=308105,attack_steps_per_direction=100,restarts=2,
            c=constant,success='Clean output at least1/2 and hidden-only perturbed output below7/16.',
            start='Saved continuous low-ink zero input; fixed black-border coordinates and other active box constraints remain fixed.',
            attack='Use the existing joint-noise PGD proposals, then discard scalar output noise and re-evaluate hidden-only downward outputs. Select the lowest perturbed output among candidates whose clean output is at least1/2.',
            verification='Exact rational noise budget and100decimal interval outputs under both ideal rational pixel normalization and the original float32 feature map.',
            retention='Save the fixed search outcome and candidate summaries whether or not a violation is found; preserve all original scripts and results.'),indent=2)+'\n')
    rec=json.loads(next((EXP/'records').glob('105-*.json')).read_text());c=rec['config'];p=attacks.load_model(c)
    old=np.load(ROOT/'lowink-zero-105.npz');x0=old['continuous_zero_input'].copy();x=x0.copy()
    free=(x0>-1+1e-8)&(x0<1-1e-8);history=[]
    for step in range(40):
        z,_,ts=train.forward(p,x[None,:],cache=True);g=p[-1].copy()
        for j in reversed(range(len(ts))):g=(g*(1-ts[j][0]**2))@p[j].T
        g=g[:-1]*free;error=target-z[0];history.append(dict(step=step,output=float(z[0])))
        if abs(error)<1e-10:break
        delta=error*g/(np.dot(g,g)+1e-300);delta*=min(1,.01/(np.linalg.norm(delta)+1e-300))
        candidate=np.clip(x+delta,-1,1)
        for _ in range(20):
            newz=float(train.forward(p,candidate[None,:])[0])
            if abs(newz-target)<abs(error):break
            delta*=.5;candidate=np.clip(x+delta,-1,1)
        x=candidate
    pix=np.clip(127.5*(x+1),0,255);low=np.floor(pix).astype(int);fraction=pix-low
    rng=np.random.default_rng(298105)
    pixels=low[None,:]+(rng.random((4096,len(x)))<fraction).astype(int)
    xx=(2*pixels-255)/255;clean=train.predict(p,xx)
    selected=np.argsort(abs(clean-target),kind='stable')[:16];inputs=xx[selected];pp=pixels[selected]
    ev=c['width']*np.sum(p[-1]**2);radius=constant/np.sqrt(1+c['hidden_depth']*ev)
    result=attacks.attack(p,inputs,radius,308105)
    etas=np.sqrt(c['width'])*result['u_min']
    noisy=train.forward(p,inputs,eta=etas,output_noise=None)
    eligible=clean[selected]>=.5
    order=np.argsort(np.where(eligible,noisy,np.inf),kind='stable')
    j=int(order[0]) if np.any(eligible) else int(np.argmin(noisy))
    eta=etas[:,j];original_input=(pp[j].astype(np.float32)/np.float32(127.5)-np.float32(1)).astype(np.float64)
    verification=verify(p,inputs[j],eta,constant,0.,[Fraction(int(2*int(v)-255),255)for v in pp[j]])
    original=verify(p,original_input,eta,constant,0.)
    np.savez_compressed(ROOT/'confident-target-105.npz',pixels=pp[j].astype(np.uint8),
                        input=inputs[j],original_float32_input=original_input,
                        hidden_noise=eta,output_noise=0.,continuous_target_input=x)
    output=dict(model=c['id'],optional_postprotocol_followup=True,clean_target=target,c=constant,
        newton_history=history,selected_candidate_indices=selected.tolist(),
        selected_clean_outputs=clean[selected].tolist(),selected_hidden_only_noisy_outputs=noisy.tolist(),
        selected_witness_index=int(selected[j]),numerical_success_count=int(np.sum(eligible&(noisy<7/16))),
        numerical_clean_output=float(clean[selected[j]]),numerical_hidden_only_noisy_output=float(noisy[j]),
        witness_mean_ink=float(np.mean(pp[j])/255),witness_black_fraction=float(np.mean(pp[j]==0)),
        output_noise=0.,ideal_rational_pixel_verification=verification,original_float32_feature_verification=original,
        elapsed_seconds=time.monotonic()-started,
        scope='Synthetic8bit low-ink image with fixed black border. No natural target label is asserted. Positive clean output itself satisfies the confident-input premise. Raw trained weights remain unchanged.')
    (ROOT/'confident-target-105.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(output),flush=True)

if __name__=='__main__':main()
