"""Exact completeness check for the stored six-bit balanced orientations.

The known total 807980 is independently counted by matching four-coordinate
moments of two balanced 16-point halves. No covariance estimates enter.
"""
from pathlib import Path
from itertools import combinations
from collections import Counter
import json,hashlib
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
X4=np.array([[1 if x>>i&1 else -1 for i in range(4)] for x in range(16)],dtype=np.int64)
counts=Counter()
for positive in combinations(range(16),8):
    g=-np.ones(16,dtype=np.int64);g[list(positive)]=1
    counts[tuple((g@X4).tolist())]+=1
expected=sum(n*counts[tuple(-x for x in moment)] for moment,n in counts.items())
path=ROOT/'results/relu_balanced_orientations_d6.bin'
patterns=np.fromfile(path,dtype='<u4')
assert len(patterns)==len(np.unique(patterns))==expected==807980
X5=np.array([[1 if x>>i&1 else -1 for i in range(5)] for x in range(32)],dtype=np.int64)
chi=X5.prod(axis=1)
for start in range(0,len(patterns),8192):
    eps=2*((patterns[start:start+8192,None]>>np.arange(32,dtype=np.uint32))&1).astype(np.int64)-1
    g=eps*chi
    assert np.all(g.sum(axis=1)==0)
    assert np.all(g@X5==0)
result=dict(status='PASS',exact_count=expected,stored_unique_count=len(patterns),moment_groups=len(counts),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),credit='Reproduces the known count of first-order resilient Boolean functions on five variables; not a new enumeration result.')
(ROOT/'results/orientation_exact_verification.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
