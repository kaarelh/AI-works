"""One-neuron checks at beta=sqrt(N)/(a log N), with stable exponents.

These are conditional critical-corner integrals, not posterior count estimates.
The raw normalization ratio tends to one under the proposed Gaussian marks.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,time
import numpy as np
import full_label_independent as f
import softplus_corrected_proposal as sp
rng=np.random.default_rng(2026112258);start=time.monotonic();rows=[];samples=200000
for a in [.25,1.,4.]:
 for eta in [.2,.5,1.]:
  cov=4*a*f.RHO/math.sqrt(eta)*np.linalg.inv(sp.Q);ch=np.linalg.cholesky(cov)
  v=rng.normal(size=samples);tc=rng.normal(size=(samples,f.R))@ch.T;t=tc@f.TBASE.T
  quad=math.sqrt(eta)/(8*a*f.RHO)*np.sum((tc@sp.Q)*tc,axis=1)
  for lnN in [8.,16.,32.,64.,128.,256.,512.]:
    N=math.exp(lnN);c=N*eta;beta=math.sqrt(N)/(a*lnN)
    root=np.sqrt(v*v+4*c);read=(root+v)/2;rad=(root-v)/2
    u=t*math.sqrt(lnN/N);zero=u@f.ZERO_BAR.T
    # Stable log cosh. The central constant is subtracted analytically.
    z=beta*zero/2;lc=np.logaddexp(z,-z)-math.log(2)
    radial_shift=v/2+v*v/(2*(root+2*math.sqrt(c)))
    correction=.5*np.sum(u*u,axis=1)+(sp.P0*math.log(2)/(beta*f.RHO))*radial_shift
    correction+=read/(beta*f.RHO*f.M)*lc.sum(axis=1)-quad
    logweight=-.5*np.log1p(v*v/(4*c))-correction
    weights=np.exp(logweight);normalizer=float(weights.mean());normalized=weights/normalizer
    # Verify no nonzero-layer sign crossing on these sampled corner marks.
    assert np.max(abs(u@f.XBAR.T)/rad[:,None])<1/math.sqrt(f.R)
    # Omitting the exponentially tiny nonzero-layer softplus correction has
    # explicit bound max read*exp(-beta*rad/sqrt(r))/rho/beta.
    logbound=float(np.max(np.log(read/(f.RHO*beta))-beta*rad/math.sqrt(f.R)))
    rows.append(dict(a=a,eta=eta,logN=lnN,beta=beta,samples=samples,
                     radial_normalizer_ratio=normalizer,conditional_mark_discrepancy=float(.5*np.mean(abs(normalized-1))),
                     imbalance_mean=float(np.mean(normalized*v)),transverse_second_moment=float(np.mean(normalized*np.sum(tc*tc,axis=1))),
                     limiting_transverse_second_moment=float(np.trace(cov)),log_bound_omitted_nonzero_correction=logbound))
    print(json.dumps(rows[-1]),flush=True)
for a in [.25,1.,4.]:
 for eta in [.2,.5,1.]:
  group=[r for r in rows if r['a']==a and r['eta']==eta]
  assert group[-1]['conditional_mark_discrepancy']<group[0]['conditional_mark_discrepancy']/4
out=dict(status='PASS',seconds=time.monotonic()-start,cases=rows,
         scope='Conditional one-neuron importance integrations at the logarithmic temperature scale; omitted nonzero-layer correction explicitly bounded. Not a posterior count or evidence certificate.')
(f.ROOT/'results/logarithmic_softplus_corner_checks.json').write_text(json.dumps(out,indent=2)+'\n')
