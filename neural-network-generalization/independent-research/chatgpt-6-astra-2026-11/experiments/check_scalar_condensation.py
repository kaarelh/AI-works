"""Exact finite checks for the scalar-conditioning application.

Checks the change-of-variables Jacobian, limiting constant identity, and
the actual critical ReLU ridge's classification count. These checks do
not verify the cited conditional limit theorem or replace its hypotheses.
"""
import json, math
from pathlib import Path
import numpy as np
import sympy as s

ROOT=Path(__file__).resolve().parents[1]
c=s.symbols('c',positive=True);v=s.symbols('v',real=True)
root=s.sqrt(v*v+4*c);A=(root+v)/2;R=(root-v)/2
assert s.simplify(A*R-c)==0
assert s.simplify(A-R-v)==0
jac=s.det(s.Matrix([[s.diff(A,c),s.diff(A,v)],
                    [s.diff(R,c),s.diff(R,v)]]))
assert s.simplify(jac+1/root)==0
q=A/s.sqrt(c)
assert s.simplify(s.diff(q,c)+q*v/(2*c*root))==0
dim=s.symbols('d',integer=True,positive=True)
assert s.simplify(((dim-1)/2)/(dim-1)-s.Rational(1,2))==0

rows=[];rng=np.random.default_rng(202611190001)
for r in range(4,17,2):
    X=2*((np.arange(1<<r)[:,None]>>np.arange(r))&1)-1
    parity=np.prod(X,axis=1);m=r//2
    count=(1<<(r-2))-math.comb(r,m)//2
    direct=sum(math.comb(r,k) for k in range(m) if (k-m)%2==0)
    assert direct==count
    # m_c=1, delta=rho*sqrt(r)/2. Twice the actual limiting
    # output is 2*chi(x) + sigma_s * max(s.x,0), all integers.
    trials=[]
    for rep in range(12):
        signs=2*rng.integers(0,2,r)-1
        sig=(-1)**(m-1)*int(np.prod(signs))
        output2=2*parity+sig*np.maximum(X@signs,0)
        margin2=parity*output2
        mistakes=int(np.sum(margin2<0))
        assert not np.any(margin2==0)
        assert mistakes==count
        trials.append(mistakes)
    rows.append(dict(r=r,inputs=1<<r,orientations=len(trials),
        mistakes=count,error_exact=f'{count}/{1<<r}',
        error_float=count/(1<<r)))

out=dict(status='PASS',symbolic_identities=5,
         exact_ridge_checks=sum(x['orientations'] for x in rows),rows=rows,
         qualification='Symbolic algebra and exact finite-cube integer evaluations; no verification of the full asymptotic conditional law.')
(ROOT/'results/scalar_condensation_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out))
