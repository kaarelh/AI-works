"""Independent exact checker for the complete five-bit activation list.

No LP solver is used. All primal/Farkas and orbit checks use integers or
fractions; the NumPy archive is compared to the independently reconstructed list.
"""
import itertools,json
from fractions import Fraction
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/fivebit_cones'

def verify():
    record=json.loads((OUT/'exact_enumeration.json').read_text());r=record['dimension'];n=1<<r
    mono={0,1};counts=[len(mono)]
    for d in range(1,r+1):
        half=1<<(d-1);mono={a|(b<<half) for a in mono for b in mono if a&b==a};counts.append(len(mono))
    X=[[1]+[2*((i>>j)&1)-1 for j in range(r)] for i in range(n)]
    maps=[[sum(((i>>p[j])&1)<<j for j in range(r)) for i in range(n)] for p in itertools.permutations(range(r))]
    seen=set();feasible=set();maxcode=(1<<n)-1
    for row in record['certificates']:
        code=row['code'];orbit=set()
        for m in maps:
            transformed=sum(((code>>m[i])&1)<<i for i in range(n));orbit.add(transformed)
            orbit.add(maxcode ^ sum(((code>>m[n-1-i])&1)<<i for i in range(n)))
        assert len(orbit)==row['orbit_size'] and not (seen&orbit) and orbit<=mono
        seen|=orbit
        A=[[ (1 if code>>i&1 else -1)*v for v in X[i]] for i in range(n)]
        if row['feasible']:
            w=list(map(Fraction,row['w']));assert len(w)==r+1
            assert all(sum(a*v for a,v in zip(arow,w))>=1 for arow in A)
            feasible|=orbit
        else:
            q=list(map(Fraction,row['q']));assert len(q)==n and min(q)>=0 and sum(q)==1
            assert all(sum(q[i]*A[i][j] for i in range(n))==0 for j in range(r+1))
    assert seen==mono and counts==record['monotone_counts']
    codes=sorted({sum(((code>>(i^flip))&1)<<i for i in range(n)) for code in feasible for flip in range(n)})
    data=np.load(OUT/'activation_patterns.npz')
    assert np.array_equal(data['codes'],codes) and np.array_equal(data['X'],X)
    expected=((np.array(codes,dtype=np.uint64)[:,None]>>np.arange(n,dtype=np.uint64))&1).astype(np.int8)
    assert np.array_equal(data['D'],expected)
    result=dict(status='PASS',monotone_counts=counts,certified_orbits=len(record['certificates']),monotone_thresholds=len(feasible),affine_patterns=len(codes),qualification='Exact rational certificate checks and exhaustive integer symmetry reconstruction; independent of an optimizer.')
    (OUT/'independent_check.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));return result
if __name__=='__main__':verify()
