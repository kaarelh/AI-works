"""Check rank-deficient coarea, auxiliary normalization cancellation and sector envelopes."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math
import numpy as np
from scipy.special import gammaln
import full_label_independent as f
rng=np.random.default_rng(2026112241);patterns=f.geometry_table()['patterns']

def logphi(x,V):
    ch=np.linalg.cholesky(V);u=np.linalg.solve(ch,x)
    return -len(x)/2*math.log(2*math.pi)-np.log(np.diag(ch)).sum()-.5*u@u

cases=[];max_error=max_coarea=max_normalizer=0.
for extra in range(4):
 for opposite in [False,True]:
  for loss in ['hard','square']:
    pat=rng.choice(patterns);eps=2*((pat>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1
    base=eps[:,None]*f.BASE
    z=np.concatenate([base,np.repeat(base[:1]*(-1 if opposite else 1),extra,axis=0)])
    L=len(z);sigma=z.prod(axis=1);A=np.maximum(f.X@z.T,0)*sigma[None,:]/math.sqrt(f.R)
    uu,ss,vh=np.linalg.svd(A,full_matrices=True);rank=int(np.sum(ss>1e-10));T=vh[:rank].T;U0=vh[rank:].T;B=uu[:,rank:]
    At=A@T;m=f.M-rank;J=math.exp(-np.log(ss[:rank]).sum())
    n=512;N=n+L;s=.5;incoming=rng.normal(size=(n,f.R+1));H=np.maximum(f.XBAR@incoming.T,0)
    means=f.CHI@H/(f.M*f.RHO);V=H@H.T;epsilon=float(np.linalg.eigvalsh(V).min())/(2*N)
    a=1.7;dall=1e-100;B0=10.;cmin=.001;lap=.01
    c=np.full(L,N*.48/(f.K*f.RHO));c[0]/=(extra+1)
    if extra:c[-extra:]=c[0]
    v=rng.normal(size=L)*.01;tc=rng.normal(size=(L,f.R))*1e-8;t=tc@f.TBASE.T
    root=np.sqrt(v*v+4*c);read=(root+v)/2;rad=(root-v)/2
    U=np.column_stack([t[:,0]/np.sqrt(c),rad[:,None]*z/math.sqrt(f.R)+(t[:,1:]*z)/np.sqrt(c)[:,None]])
    phi=np.maximum(U@f.XBAR.T,0);G=phi@f.CHI/f.M;amac=sigma*read
    big=amac@phi;e=big-A@c
    slack=rng.exponential(f.M*f.RHO,size=f.M);Y=N*s*f.CHI+f.CHI*slack
    zz=Y-H@means;r0=zz-A@c;C=B.T@V@B;prec=At.T@np.linalg.solve(V,At)
    mean=np.linalg.solve(prec,At.T@np.linalg.solve(V,zz));d=T.T@c;hnull=U0.T@c
    assert np.max(abs(hnull),initial=0)<=B0*N
    profile=math.log(dall)+math.log(J)+m/2*math.log(epsilon*N)-np.linalg.slogdet(C)[1]/2-float((B.T@zz)@np.linalg.solve(C,B.T@zz))/(2*a) if m else math.log(dall)+math.log(J)
    rowdensity=logphi(d-mean,a*np.linalg.inv(prec))
    coarea=profile+rowdensity-math.log(dall)-m/2*math.log(2*math.pi*a*epsilon*N)-logphi(r0,a*V)
    max_coarea=max(max_coarea,abs(coarea))
    dummyU=rng.normal(size=(L,f.R+1));dummyG=np.maximum(dummyU@f.XBAR.T,0)@f.CHI/f.M
    dummya=np.where(dummyG>=0,1.,-1.)*(.5+abs(rng.normal(size=L)));dummyZ=dummya*dummyG
    assert np.all(dummyZ>=0)
    dummyP=-.5*(dummya*dummya+np.sum(dummyU*dummyU,axis=1))-(f.R+2)/2*math.log(2*math.pi)
    if loss=='hard':logW=-slack.sum()/(f.M*f.RHO);logZW=f.M*math.log(f.M*f.RHO)
    else:
        gamma=2/(f.RHO*f.M);logW=-gamma*np.sum((Y-N*s*f.CHI)**2)/(2*N);logZW=f.M/2*math.log(2*math.pi*N/gamma)
    logcomb=float(gammaln(N+1)-gammaln(L+1)-gammaln(N-L+1))
    marklog=-L/2*math.log(2*math.pi)-np.sum(v*v)/2+L*f.R*math.log(lap/2)-lap*np.sum(abs(tc))
    logCmark=-(f.R+1)/2*math.log(2*math.pi)+f.R*math.log(2/lap)
    logB=logZW+f.M/2*math.log(a)-math.log(dall)+logcomb+L*logCmark-L*f.NU*math.log(cmin*N)+(L-rank)*math.log(2*B0*N)-m/2*math.log(2*math.pi*a*epsilon*N)
    hh=np.sum(abs(t@f.ZERO_BAR.T),axis=1)/(2*f.M);q=read/np.sqrt(c)
    logR=np.sum(f.NU*np.log(cmin*N/c)+np.log(2*np.sqrt(c)/root)-np.sum(t*t,axis=1)/(2*c)-q*hh/f.RHO+lap*np.sum(abs(tc),axis=1)-dummyZ/f.RHO)
    logR+=-.5*(r0-e)@np.linalg.solve(V,r0-e)+.5/a*r0@np.linalg.solve(V,r0)
    ratios=[]
    for Mstar in [1.01,1.2,1.4]:
        macro=-.5*(amac*amac+np.sum(U*U,axis=1))+amac*G/f.RHO-(f.R+2)/2*math.log(2*math.pi)-math.log(Mstar)-f.R/2*np.log(c)-np.log(root)
        dummyQ=dummyP+dummyZ/f.RHO-math.log(Mstar)
        target=logcomb+logW+logphi(r0-e,V)+macro.sum()+(dummyP+math.log(2)).sum()
        proposal=logW-logZW+profile+rowdensity-(L-rank)*math.log(2*B0*N)+marklog+dummyQ.sum()
        direct=target-proposal;ratios.append(direct);max_error=max(max_error,abs(direct-logB-logR))
    max_normalizer=max(max_normalizer,float(np.ptp(ratios)))
    cases.append(dict(extra=extra,opposite=opposite,loss=loss,rank=rank,nullity=L-rank,log_ratio_error=float(abs(ratios[0]-logB-logR))))
assert max_error<1e-8 and max_coarea<1e-8 and max_normalizer<1e-9
out=dict(status='PASS',cases=cases,maximum_log_density_identity_error=max_error,maximum_rank_coarea_identity_error=max_coarea,
         maximum_critical_normalizer_dependence=max_normalizer,
         scope='Independent floating-point density identities for counts K through K+3 and both repeated and opposite rays; not a full sampler implementation or asymptotic proof.')
(f.ROOT/'results/multisector_density_checks.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:v for k,v in out.items() if k!='cases'},indent=2))
