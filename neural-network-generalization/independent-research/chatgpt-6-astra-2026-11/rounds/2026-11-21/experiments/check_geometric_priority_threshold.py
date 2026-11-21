"""Exact rational check of the geometric-priority competitor obstruction."""
from fractions import Fraction as F
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
rows=[]
for q in range(4,14):
 h=2**(q-1)
 for t in (F(1,2),F(3,4),F(19,25),F(4,5),F(99,100)):
  direct=2*sum(t**(h+8*j+2)+t**(h+8*j+4)-t**(h+8*j+1)-t**(h+8*j+7) for j in range(h//8))
  formula=2*t**h*sum(t**(8*j) for j in range(h//8))*t*(1-t)*(1+t*t)*(t**3+t*t-1)
  assert direct==formula
  rows.append(dict(q=q,t=str(t),gain_sign=(direct>0)-(direct<0)))
(ROOT/'results/geometric_priority_threshold_checks.json').write_text(json.dumps(dict(status='PASS',cases=rows,
 scope='Exact rational competitor objective and polynomial factorization; not a neural realization.'),indent=2)+'\n')
print('PASS',len(rows),'exact geometric-priority competitor checks')
