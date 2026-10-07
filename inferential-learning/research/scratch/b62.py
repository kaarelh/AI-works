import numpy as np
rng = np.random.default_rng(3)
a=1.0
N=5_000_000
psi = rng.uniform(0, 2*np.pi, N)
# s spanning near-cylinder to far, log-uniform plus near 0
s = np.where(rng.random(N)<0.5, rng.uniform(0, 2, N), np.exp(rng.uniform(np.log(1e-3), np.log(1e4), N)))
th=(psi+np.pi)/2
X = a*np.cos(th)+s*np.cos(psi); Y=a*np.sin(th)+s*np.sin(psi)
r=np.hypot(X,Y); phi=np.arctan2(Y,X)
c=np.sin(psi/2); E=a*c/(2*s+a*c); E0=a/2*np.abs(np.sin(phi/2))/r
eps=a/r; sig=np.abs(np.sin(phi/2)); m=np.arcsin(np.minimum(eps,1))/2
hyp=(eps<2/np.sqrt(5))&(sig>m)
lo=1-m/sig; hi=(1+m/sig)/(np.sqrt(np.maximum(1-eps**2,0))-eps/2)
rat=E/E0
v = hyp & ((rat<lo-1e-12)|(rat>hi+1e-12))
print("points satisfying hyp:", hyp.sum(), "violations:", v.sum())
# tightness of lower/upper near hypothesis boundary
print("min slack lo:", np.min((rat-lo)[hyp]), " min slack hi:", np.min((hi-rat)[hyp]))
# coverage: points with hyp but outside image? sample floor points directly and invert
M=200000
rr = np.exp(rng.uniform(np.log(1.12), np.log(1000), M)); pp = rng.uniform(0,2*np.pi,M)
ee=1/rr; ss_=np.abs(np.sin(pp/2)); mm=np.arcsin(ee)/2
h2=(ee<2/np.sqrt(5))&(ss_>mm)
# phi(psi) = psi + atan2(a cos(psi/2), u), u = sqrt(r^2 - a^2 cos^2(psi/2)); covers (asin eps, 2pi - asin eps)
pmod = np.mod(pp, 2*np.pi)
inside = (pmod > np.arcsin(ee)) & (pmod < 2*np.pi - np.arcsin(ee))
print("hyp points not covered by image:", (h2 & ~inside).sum(), "of", h2.sum())
