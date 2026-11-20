"""Random sharp-atom approximations to the exact parity margin norm.
No training or posterior approximation: this checks an explicit representation.
All cube inputs evaluated exactly (floating point), via XOR convolution.
"""
import argparse,json,math,time
from pathlib import Path
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
def fwht(a):
    a=np.array(a,dtype=np.float64,copy=True)
    k=1
    while k<a.size:
        v=a.reshape(-1,2*k)
        l=v[:,:k].copy(); r=v[:,k:].copy()
        v[:,:k]=l+r;v[:,k:]=l-r;k*=2
    return a

def setup(d):
    ids=np.arange(1<<d,dtype=np.uint32)
    pc=np.zeros(1<<d,dtype=np.uint8)
    for j in range(d):pc+=((ids>>j)&1).astype(np.uint8)
    parity=1.-2.*(pc%2)
    h=np.maximum((d-2*pc.astype(float))/math.sqrt(d),0)
    rho=math.comb(d-2,(d-2)//2)/(2**(d-1)*math.sqrt(d))
    kappa=float(np.mean(parity*h))
    assert abs(abs(kappa)/rho-1)<1e-10
    return parity,h,fwht(h),kappa

def evaluate(d,n,seed,pre):
    parity,h,hhat,kappa=pre
    rng=np.random.default_rng(seed)
    ids=rng.integers(0,1<<d,size=n)
    counts=np.bincount(ids,minlength=1<<d).astype(float)/n
    coeff=counts*parity/kappa
    score=fwht(fwht(coeff)*hhat)/(1<<d)
    signed=parity*score
    return dict(d=d,n=n,seed=seed,min_margin=float(signed.min()),
                max_margin=float(signed.max()),mean_margin=float(signed.mean()),
                rms_error=float(np.sqrt(np.mean((signed-1)**2))),
                distinct=int(np.count_nonzero(counts)),
                cost_ratio=float(1/signed.min()) if signed.min()>0 else None)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--dims',default='4,6,8,10,12,14,16,18')
    ap.add_argument('--seeds',type=int,default=24);ap.add_argument('--name',default='parity_mc')
    args=ap.parse_args();out=ROOT/'results'/f'{args.name}.jsonl'
    start=time.time()
    with out.open('a',buffering=1) as f:
      for d in map(int,args.dims.split(',')):
        pre=setup(d)
        for factor in [0.25,0.5,1,2,4,8,16,32,64]:
          n=max(1,round(factor*d**3))
          for seed in range(args.seeds):
            z=evaluate(d,n,seed,pre);z['factor']=factor
            f.write(json.dumps(z)+'\n')
          print(json.dumps({'d':d,'factor':factor,'elapsed_s':round(time.time()-start,2)}),flush=True)
if __name__=='__main__':main()
