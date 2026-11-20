"""Independent exact checker: no optimization or floating-point inequalities.
Cone completeness is inherited from the repository's existing exact proof;
all restrictions, duals, primals, and strict gaps are checked here anew.
"""
import json,math,hashlib,os
from fractions import Fraction as F
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
REPO=Path(os.environ.get('NNBAYES_REPO', str(Path(__file__).resolve().parents[6])))
source=ROOT/'results/baseline_d4_certificate_input.npz'
if not source.exists():source=REPO/'neural-network-generalization/works-in-progress/online-mistakes/relu-fourbit-mistakes/verification/d4_certificate_input.npz'
base=np.load(source);X=base['X'].astype(object);D=base['D'].astype(np.int64)
assert X.shape==(16,5) and D.shape==(1882,16)
assert all(int(X[i,0])==1 for i in range(16))
for i in range(16):
 assert [int(x) for x in X[i,1:]]==[2*((i>>(3-k))&1)-1 for k in range(4)]
y=np.array([int(row[1]*row[2])*(1 if row[3]==row[4]==1 else -1) for row in X],dtype=object)
path=json.loads((ROOT/'results'/'observed_margin_mistake_path.json').read_text())
order=path['order'];assert sorted(order)==list(range(16));assert len(path['certificates'])==15
records=[]
for t,row in enumerate(path['certificates'],1):
 c=np.load(ROOT/'results'/'observed_margin_certificates'/row['file'])
 history=list(map(int,c['history']));query=int(c['query']);ids=history+[query]
 assert history==order[:t] and query==order[t]
 XX=X[ids];DD=np.unique(D[:,ids],axis=0);DD=DD[DD.sum(axis=1)>0]
 assert np.array_equal(c['X'],XX) and np.array_equal(c['D'],DD) and np.array_equal(c['y'],y[ids])
 alpha=c['alpha'].astype(object);qp=c['qplus'].astype(object);qm=c['qminus'].astype(object)
 assert all(int(v)>=0 for v in alpha)
 assert all(int(v)>=0 for v in qp.flat) and all(int(v)>=0 for v in qm.flat)
 assert qp.shape==qm.shape==DD.shape
 R=int(c['radius']);assert R>0
 DD=DD.astype(object);G=(DD*(alpha*y[ids]))@XX
 resplus=G+((2*DD-1)*qp)@XX;resminus=-G+((2*DD-1)*qm)@XX
 for rr in list(resplus)+list(resminus):assert sum(int(v)**2 for v in rr)<=R*R
 lower=F(sum(map(int,alpha[:-1])),2*R)
 W=c['W'].astype(object);sign=c['readout'].astype(object);H=int(c['primal_denominator'])
 assert H>0 and W.shape[1]==5 and len(W)<=16 and len(sign)==len(W)
 assert all(int(v) in (-1,1) for v in sign)
 out=np.maximum(X@W.T,0)@sign
 assert all(2*int(y[i]*out[i])>=H for i in history)
 roots=0
 for ww in W:
  n=sum(int(v)**2 for v in ww);r=math.isqrt(n);roots+=r+int(r*r<n)
 upper=F(roots,H)
 assert lower==F(int(c['lower_num']),int(c['lower_den']))
 assert upper==F(int(c['upper_num']),int(c['upper_den']))
 assert lower>upper
 # Mean-field Gaussian rate gap at tau=1/50: log1000<7, six parameters.
 warm_gap=2500*(F(999,1000)*lower-upper)-21
 assert warm_gap>0
 records.append(dict(t=t,query=query,width=len(W),lower=str(lower),upper=str(upper),gap=str(lower-upper),
                     meanfield_rate_gap_tau_1_50=str(warm_gap)))
report=dict(passed=True,arithmetic='Python exact integers and Fraction; no numerical solver',
 inherited_fact='Completeness of the1882 affine activation cones, verified in the baseline repository',
 source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),order=order,strict_gaps=15,records=records)
(ROOT/'results'/'observed_margin_exact_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(passed=True,strict_gaps=15,maximum_witness_width=max(r['width'] for r in records),
 minimum_gap=str(min(F(r['gap']) for r in records)),
 minimum_meanfield_rate_gap=str(min(F(r['meanfield_rate_gap_tau_1_50']) for r in records)),order=order),indent=2))
