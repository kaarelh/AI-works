"""Finite numerical stress checks for power-cost transfer and readout identities.
These checks can catch normalization errors; they do not prove asymptotic claims.
"""
import itertools,json,math
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
rng=np.random.default_rng(2026111811)

def coeff(r,j):
    rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r))
    if j==0:return (r-1)*rho
    return rho*(-1)**((j-2)//2)*math.comb((r-2)//2,(j-2)//2)/math.comb(r-2,j-2)

def check_le(a,b,context):
    assert a<=b+1e-9*(1+abs(a)+abs(b)),(context,a,b)

rows=[]
for r in (6,8):
    x=np.array(list(itertools.product((-1.,1.),repeat=r)))
    xb=np.column_stack((np.ones(len(x)),x)); chi=np.prod(x,axis=1)
    rho=abs(coeff(r,r)); c=rho*math.sqrt(r); s=.5; n=len(x); D=r+1
    for p in (2.,2.1,3.,4.,8.):
        q=p/2; vstar=2*math.sqrt(r)*(s/c)**q
        for noise in (0.,.001,.01,.05):
            for repeat in range(2):
                mm=math.sqrt(s/c)*r**(-1/(2*p)); aa=math.sqrt(s/c)*r**(1/(2*p))
                u=np.column_stack((np.zeros(n),mm*x))+noise*rng.normal(size=(n,D))
                a=aa*np.sign(coeff(r,r))*chi+noise*rng.normal(size=n)
                V=(np.abs(a)**p).mean()+(np.abs(u)**p).sum(axis=1).mean()
                scale=max(1.,vstar/V)**(1/p); u*=scale;a*=scale
                V=(np.abs(a)**p).mean()+(np.abs(u)**p).sum(axis=1).mean()
                eps=max(0.,V/vstar-1); assert eps<=1
                f=np.maximum(xb@u.T,0)@a/n
                h=np.maximum(s-chi*f,0).mean(); assert h<=s
                eta=eps+q*h/s
                P=D**(.5-1/p)*(V/2)**(2/p)
                v0=D**(.5-1/p)*(V*eta*vstar)**(1/p)
                u0=math.sqrt(max(0,(s+P*math.sqrt(D))*(s*((1+eps)**(1/q)-1)+2*h)))
                z=np.where(u[:,1:]>=0,1.,-1.); m=np.abs(u[:,1:]).min(axis=1)
                projected=np.column_stack((np.zeros(n),m[:,None]*z))
                hc=np.maximum(xb@projected.T,0); hc_even=(hc+hc[::-1])/2
                features=np.maximum(xb@u.T,0); even=(features+features[::-1])/2
                fc=hc@a/n
                check_le(np.linalg.norm(f-fc)/math.sqrt(n),v0,('projection',r,p,noise))
                check_le(np.linalg.norm(f-s*chi)/math.sqrt(n),u0,('source',r,p,noise))
                W=(np.abs(u)**p).sum(axis=1)
                check_le((W-r*m**p).mean(),eta*vstar,('incoming excess',r,p,noise))
                for k in (0,1,2):
                    if r-2*k<2:continue
                    A=list(range(2*k)); j=r-2*k
                    signs=np.prod(z[:,A],axis=1) if A else np.ones(n)
                    factor=coeff(r,r)/(s*coeff(r,j))
                    g=factor*even@(a*signs)/n
                    target=np.prod(x[:,2*k:],axis=1)
                    err=np.linalg.norm(g-target)/math.sqrt(n)
                    bound=rho/(s*abs(coeff(r,j)))*((1+(r-1)**k)*v0+(r-1)**k*u0)
                    check_le(err,bound,('transfer',r,p,noise,k))
                    b2=(rho/(s*coeff(r,j)))**2*V**(2/p)
                    check_le(np.dot(a,a)/n*factor**2,b2,('coefficient norm',r,p,noise,k))
                    radius=np.max((even*even).mean(axis=1))
                    check_le(radius,D**(2-2/p)*V**(2/p),('radius',r,p,noise,k))
                    if p==2:
                        # A separately formed skip predictor, using Euclidean-normalized projection.
                        E=V/2; R=np.linalg.norm(u,axis=1)
                        projected_e=np.column_stack((np.zeros(n),R[:,None]*z/math.sqrt(r)))
                        ell=((a*signs*R)[:,None]*z/math.sqrt(r)).mean(axis=0)/2
                        skip=factor*(features@(a*signs)/n-x@ell)
                        E_star=s/rho; e=max(0,E/E_star-1); d0=e*s+h
                        vg=math.sqrt(2*E*d0/rho); ug=math.sqrt((s+E*math.sqrt(D))*(e*s+2*h))
                        skipbound=rho/(s*abs(coeff(r,j)))*((1+(r-1)**k)*vg+(r-1)**k*ug)
                        check_le(np.linalg.norm(skip-target)/math.sqrt(n),skipbound,('skip',r,noise,k))
                        skipnorm=factor**2*(np.dot(a,a)/n+8*np.dot(ell,ell)/E)
                        check_le(skipnorm,4*E*factor**2,('skipnorm',r,noise,k))
                    rows.append(dict(r=r,p=p,noise=noise,replicate=repeat,k=k,epsilon=eps,
                        hinge=h,error=err,error_bound=bound,norm_bound=b2,radius=radius))

# Sequential-ridge identity is evaluated by independent direct minimizations.
ridge=[]
for v in (.01,.3,1.,10.):
    for rep in range(20):
        dim=9;n=45
        dictionary=rng.normal(size=(13,dim))
        phi=dictionary[rng.integers(0,len(dictionary),size=n)]
        y=rng.choice((-1.,1.),size=n)
        A=v*np.eye(dim); b=np.zeros(dim); minimum=0.; cumulative=0.; maxerr=0.
        for t in range(n):
            w=np.linalg.solve(A,b); pred=phi[t]@w; leverage=phi[t]@np.linalg.solve(A,phi[t])
            check_le(np.dot(w,w),t/v,('ridge norm',v,rep,t))
            A+=np.outer(phi[t],phi[t]);b+=y[t]*phi[t]
            neww=np.linalg.solve(A,b)
            newminimum=np.sum((y[:t+1]-phi[:t+1]@neww)**2)+v*np.dot(neww,neww)
            predicted=(y[t]-pred)**2/(1+leverage)
            maxerr=max(maxerr,abs(newminimum-minimum-predicted))
            assert abs(newminimum-minimum-predicted)<1e-8
            minimum=newminimum;cumulative+=(y[t]-pred)**2
        R2=np.max(np.sum(phi*phi,axis=1))
        check_le(cumulative,(1+R2/v)*minimum,('online ridge',v,rep))
        ridge.append(dict(v=v,replicate=rep,max_identity_error=maxerr))

# Square objective decomposition in actual cube coordinates.
square=[]
for r in (6,8):
    x=np.array(list(itertools.product((-1.,1.),repeat=r)));xb=np.column_stack((np.ones(len(x)),x))
    chi=np.prod(x,axis=1);rho=abs(coeff(r,r))
    for rep in range(50):
        u=rng.normal(size=(19,r+1));a=rng.normal(size=19)
        f=np.maximum(xb@u.T,0)@a/19
        E=(np.dot(a,a)+np.sum(u*u))/38
        risk=np.mean((1-chi*f)**2);deficit=rho*E-np.mean(chi*f)
        assert deficit>=-1e-12
        error=abs(rho*E+risk-.75-deficit-np.mean((f-.5*chi)**2))
        assert error<1e-10
        square.append(dict(r=r,replicate=rep,identity_error=error))

result=dict(status='PASS',transfer_cases=rows,ridge_cases=ridge,square_cases=square,
    qualification='Floating-point finite stress checks, not a formal proof or a posterior mixing check.')
(ROOT/'results/power_and_readout_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(status='PASS',transfer_cases=len(rows),ridge_cases=len(ridge),square_cases=len(square))))
