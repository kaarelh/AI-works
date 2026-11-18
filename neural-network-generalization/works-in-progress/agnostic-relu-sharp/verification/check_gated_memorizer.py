from pathlib import Path
import itertools,json,math
import numpy as np
rng=np.random.default_rng(20261118)
checks=[]
for D in range(1,6):
 n=2**D;d=D+2;M=(D+1)*n
 cube=np.array(list(itertools.product([-1.,1.],repeat=D)))
 r=rng.uniform(-1,1,n)
 rows=[];cs=[]
 for mask in range(n):
  ids=[j for j in range(D) if mask>>j&1];j=len(ids)
  parity=np.prod(cube[:,ids],axis=1) if ids else np.ones(n)
  coeff=float(parity@r/n)
  if not ids:
   feats=[(.5,2.)]
  else:
   y0=(-1.)**j
   feats=[(j+.5,2*y0)]+[(j-2*i-.5,-4*y0*(-1.)**i) for i in range(j)]
  for b,c in feats:
   row=np.zeros(d+1);row[0]=b-2*(D+1);row[2]=2*(D+1)
   row[[3+t for t in ids]]=1
   rows.append(row);cs.append(coeff*c)
 while len(rows)<M:
  row=np.zeros(d+1);row[0]=.5-2*(D+1);row[2]=2*(D+1)
  rows.append(row);cs.append(0.)
 rows=np.array(rows);cs=np.array(cs)
 assert np.max(np.sum(rows*rows,axis=1))<=16*(D+1)**2
 assert cs@cs<=20*(D+1)*(r@r)/n+1e-10
 noisy=np.column_stack([np.zeros(n),np.ones(n),cube])
 signal=np.column_stack([[-1.,-.01,.01,1.],-np.ones(4),np.zeros((4,D))])
 inputs=np.vstack([noisy,signal]);xb=np.column_stack([np.ones(n+4),inputs])
 target=np.r_[r,np.zeros(4)]
 assert np.max(np.abs(np.maximum(xb@rows.T,0)@cs-target))<1e-10
 for H in range(1,6):
  L=H+1
  for N in [M,2*M+1]:
   ks=np.full(M,N//M);ks[:N%M]+=1
   w1=np.zeros((N,d+1));w1[:M]=np.sqrt(ks)[:,None]*rows
   mats=[w1]
   if H==1:
    v=np.zeros(N);v[:M]=cs/np.sqrt(ks)
   else:
    kp=N//2;km=N-kp
    w=np.zeros((N,N));w[0,:M]=math.sqrt(kp)*cs/np.sqrt(ks);w[1,:M]=-math.sqrt(km)*cs/np.sqrt(ks)
    mats.append(w)
    for _ in range(2,H):
     w=np.zeros((N,N));w[:2,:2]=[[1,-math.sqrt(kp/km)],[-math.sqrt(km/kp),1]];mats.append(w)
    v=np.zeros(N);v[:2]=[1/math.sqrt(kp),-1/math.sqrt(km)]
   qs=[d/N*np.sum(mats[0]**2)]+[np.sum(w*w) for w in mats[1:]]+[N*(v@v)]
   geom=np.prod(qs)**(1/L)
   scales=[math.sqrt(geom/q) for q in qs]
   mats=[w*s for w,s in zip(mats,scales[:-1])];v*=scales[-1]
   states=xb
   for w in mats:states=np.maximum(states@w.T,0)
   out=states@v
   err=float(np.max(np.abs(out-target)))
   assert err<1e-9,(D,H,N,err)
   newqs=[d/N*np.sum(mats[0]**2)]+[np.sum(w*w) for w in mats[1:]]+[N*(v@v)]
   e=(16*d*(D+1)**2*40*(D+1)**2*n*6**(L-2))**(1/L)
   assert max(newqs)<=e+1e-7
   checks.append({'D':D,'H':H,'N':N,'max_error':err,'balanced_layer_energy':float(geom),'energy_bound':float(e)})
record={'checks':len(checks),'max_error':max(c['max_error'] for c in checks),'cases':checks}
Path(__file__).with_name('gated-memorizer-checks.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({k:v for k,v in record.items() if k!='cases'},indent=2))
