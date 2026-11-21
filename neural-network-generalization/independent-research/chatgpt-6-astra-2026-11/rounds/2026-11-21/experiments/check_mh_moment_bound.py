"""Exact rational finite-space checks for the independent-MH coupling bound."""
from fractions import Fraction as F
from itertools import product
from pathlib import Path
import json

def compositions(n,k,positive=False):
    low=int(positive)
    if k==1:
        if n>=low:yield (n,)
        return
    for x in range(low,n-low*(k-1)+1):
        for rest in compositions(n-x,k-1,positive):yield (x,*rest)

cases=0;updates=0
for size in (2,3,4):
    for pi in compositions(6,size):
        p=[F(x,6) for x in pi]
        for qi in compositions(7,size,positive=True):
            q=[F(x,7) for x in qi];w=[p[i]/q[i] for i in range(size)]
            kernel=[]
            for i in range(size):
                row=[q[j]*min(F(1),w[j]/w[i]) if w[i]>0 else q[j] for j in range(size)]
                row[i]+=1-sum(row);assert sum(row)==1 and min(row)>=0
                kernel.append(row)
            assert [sum(p[i]*kernel[i][j] for i in range(size)) for j in range(size)]==p
            reject=[sum(q[j]*max(F(0),1-w[j]/t) for j in range(size)) if t>0 else F(0) for t in w]
            current=q
            for k in range(5):
                tv=sum(abs(current[i]-p[i]) for i in range(size))/2
                coupling=sum(q[i]*max(F(0),w[i]-1)*reject[i]**k for i in range(size))
                assert tv<=coupling,(p,q,k,tv,coupling)
                if k:
                    moment=(2**k)*sum(q[i]*abs(w[i]-1)**(k+1) for i in range(size))
                    assert coupling<=moment,(p,q,k,coupling,moment)
                current=[sum(current[i]*kernel[i][j] for i in range(size)) for j in range(size)]
                updates+=1
            cases+=1
result=dict(status='PASS',rational_probability_pairs=cases,finite_step_checks=updates,
            supports=[2,3,4],target_denominator=6,proposal_denominator=7,
            update_counts=[0,1,2,3,4],arithmetic='fractions.Fraction',
            scope='Exhaustive checks on these finite grids; the general coupling argument is a separate conventional proof.')
root=Path(__file__).resolve().parents[1]
(root/'results/mh_moment_bound_exact.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
