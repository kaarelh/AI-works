"""Exact rational checks of the perturbation recursion through six updates."""
from fractions import Fraction as F
from pathlib import Path
import json,random
rng=random.Random(2026112171)
cases=[];checks=0;minimum_constant=None
for case in range(30):
    size=2+case%7
    masses=[rng.randrange(1,9) for _ in range(size)];q=[F(m,sum(masses)) for m in masses]
    raw=[F(rng.randrange(-20,21)) for _ in range(size)];mean=sum(a*b for a,b in zip(q,raw));L=[v-mean for v in raw]
    if not any(L):continue
    limiting=L[:];constants=[]
    for k in range(7):
        constant=sum(q[i]*abs(limiting[i]) for i in range(size))/2
        assert constant>0
        constants.append(constant)
        assert sum(q[i]*limiting[i] for i in range(size))==0
        assert all(limiting[i]<=limiting[j] for i in range(size) for j in range(size) if L[i]<=L[j])
        limiting=[sum(q[j]*max(F(0),L[i]-L[j]) for j in range(size))*limiting[i]
                  -sum(q[j]*limiting[j]*max(F(0),L[j]-L[i]) for j in range(size)) for i in range(size)]
    rows=[]
    for denominator in [2,8,32,128,512]:
        eps=1/(denominator*max(abs(v) for v in L));w=[1+eps*v for v in L];p=[q[i]*w[i] for i in range(size)]
        K=[]
        for i in range(size):
            row=[q[j]*min(F(1),w[j]/w[i]) for j in range(size)]
            row[i]+=1-sum(row);K.append(row)
            for j in range(size):
                assert max(F(0),L[j]-L[i])/w[j]<=max(F(0),L[j])+max(F(0),-L[i])
        current=q[:];scaled=L[:];errors=[]
        for k in range(7):
            assert all(p[i]-current[i]==q[i]*eps**(k+1)*scaled[i] for i in range(size))
            tv=sum(abs(p[i]-current[i]) for i in range(size))/2
            errors.append(float(abs(tv/eps**(k+1)/constants[k]-1)))
            scaled=[scaled[i]*sum(q[j]*max(F(0),L[i]-L[j]) for j in range(size))/w[i]
                    -sum(q[j]*scaled[j]*max(F(0),L[j]-L[i])/w[j] for j in range(size)) for i in range(size)]
            current=[sum(current[i]*K[i][j] for i in range(size)) for j in range(size)];checks+=1
        rows.append(dict(denominator=denominator,relative_constant_errors=errors))
    assert max(rows[-1]['relative_constant_errors'])<.03
    cases.append(dict(size=size,constants=[str(c) for c in constants],convergence=rows))
out=dict(status='PASS',laws=len(cases),exact_recursion_checks=checks,updates=list(range(7)),arithmetic='fractions.Fraction',cases=cases,
         scope='Exact finite-support checks of the residual recursion, kernel bounds, centering, monotonicity and positive constants. The Wasserstein limit theorem is a separate conventional proof.')
root=Path(__file__).resolve().parents[1];(root/'results/mh_perturbation_hierarchy_exact.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:out[k] for k in ['status','laws','exact_recursion_checks','updates','arithmetic']}))
