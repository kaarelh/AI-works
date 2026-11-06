"""Exact arithmetic verification; no numerical optimizer or third-party modules."""
from fractions import Fraction
from itertools import product
from pathlib import Path
import json
p=Path(__file__).with_name('fractional-ltf-certificate.json')
a=json.loads(p.read_text());w=tuple(map(Fraction,a['weights']));d=len(w)-1
Q=sum(z*z for z in w)
assert Q==Fraction(a['squared_norm'])==Fraction(2405,2)
for x in product((-1,1),repeat=d):
    val=w[0]+sum(z*t for z,t in zip(w[1:],x))
    assert abs(val)>=1
stationarity=[Fraction(0)for _ in w];mass=Fraction(0)
for row in a['dual']:
    assert len(row['x']) == d and all(t in (-1, 1) for t in row['x'])
    x=(1,*row['x']);y=row['label'];lam=Fraction(row['lambda'])
    assert y in (-1,1) and lam>0
    assert y*sum(z*t for z,t in zip(w,x))==1
    for j,t in enumerate(x):stationarity[j]+=lam*y*t
    mass+=lam
assert tuple(stationarity)==w and mass==Q
print('Verified all 512 full-cube margins and the rational positive-dual certificate.')
print('Unique minimum squared norm =',Q)
