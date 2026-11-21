"""Exact rational enumeration of the six-dimensional transverse norm floor.

The minimum h(t)/||t|| occurs on a ray of the arrangement of the 20
zero-activation hyperplanes. Enumerate all independent five-row
intersections by integer cofactors. On each cone h is linear, so its
raywise lower bound extends by triangle inequality to the whole cone.
"""
import itertools,json,math
from fractions import Fraction
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
zero=[x for x in itertools.product((-1,1),repeat=6) if sum(x)==0]
rows=[(1,*(x[i]-x[5] for i in range(5))) for x in zero]

def det(matrix):
    a=[list(row) for row in matrix];n=len(a);sign=1;previous=1
    for k in range(n-1):
        pivot=next((i for i in range(k,n) if a[i][k]),None)
        if pivot is None:return 0
        if pivot!=k:a[pivot],a[k]=a[k],a[pivot];sign=-sign
        p=a[k][k]
        for i in range(k+1,n):
            for j in range(k+1,n):
                numerator=a[i][j]*p-a[i][k]*a[k][j]
                assert numerator%previous==0
                a[i][j]=numerator//previous
            a[i][k]=0
        previous=p
    return sign*a[-1][-1]

rays=set();singular=0;tested=0
for indices in itertools.combinations(range(len(rows)),5):
    a=[rows[i] for i in indices];v=tuple((-1)**j*det([row[:j]+row[j+1:] for row in a]) for j in range(6))
    tested+=1
    if not any(v):singular+=1;continue
    assert all(sum(x*y for x,y in zip(row,v))==0 for row in a)
    divisor=math.gcd(*v);v=tuple(x//divisor for x in v)
    if next(x for x in v if x)<0:v=tuple(-x for x in v)
    rays.add(v)
best=None;minimizers=[]
for v in sorted(rays):
    hnum=sum(abs(sum(x*y for x,y in zip(row,v))) for row in rows)
    norm2=sum(x*x for x in v)+sum(v[1:])**2
    ratio=Fraction(hnum*hnum,128*128*norm2)
    if best is None or ratio<best:best=ratio;minimizers=[v]
    elif ratio==best:minimizers.append(v)
out=dict(status='PASS',row_subsets=tested,singular_subsets=singular,distinct_rays_up_to_sign=len(rays),
         minimum_squared_ratio=dict(numerator=best.numerator,denominator=best.denominator),
         minimum_ratio=math.sqrt(float(best)),minimizing_integer_rays=minimizers,
         coordinates='(bias,w1,...,w5), with w6=-sum(w1,...,w5)',
         scope='Exact integer cofactor enumeration plus the stated polyhedral-cone argument; not a Lean formalization.')
(ROOT/'results/transverse_norm_certificate.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
