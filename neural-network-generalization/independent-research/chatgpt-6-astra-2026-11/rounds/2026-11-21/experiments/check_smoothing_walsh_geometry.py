"""Exact bounded-integer six-bit critical-ray covariance geometry.

All matrix products are integer sums. The displayed bound proves these
particular int64 operations cannot overflow; no eigenvalue solver is used.
"""
import json
from fractions import Fraction
import numpy as np
import full_label_independent as f
cube=f.X.astype(np.int64)
degrees=np.array([int(i).bit_count() for i in range(f.M)])
H=np.ones((f.M,f.M),dtype=np.int64)
for s in range(f.M):
 for i in range(f.R):
  if (s>>i)&1:H[:,s]*=cube[:,i]
phi=np.maximum(cube.sum(1),0)
numerators=H.T@phi
expected=np.array([60,32,12,0,-4,0,12],dtype=np.int64)[degrees]
assert np.array_equal(numerators,expected)
assert np.array_equal(H.T@H,f.M*np.eye(f.M,dtype=np.int64))
ridges=np.maximum(cube@cube.T,0)
gram=ridges@ridges.T
transform=H.T@gram@H
# Maximum intermediate absolute sum is at most M^4 r^2.
bound=f.M**4*f.R**2
assert bound<2**63
assert np.array_equal(transform,np.diag(f.M*numerators*numerators))
eigen=[Fraction(int(x*x),f.R) for x in [60,32,12,0,-4,0,12]]
assert np.count_nonzero(numerators)==38
out=dict(status='PASS',integer_overflow_bound=bound,walsh_numerators_by_degree=[60,32,12,0,-4,0,12],
   ray_covariance_eigenvalues_by_degree=[str(x) for x in eigen],nonzero_character_count=38,
   scope='Exact bounded-integer finite Walsh transform and ray Gram diagonalization. The covariance-temperature asymptotic and integral constant remain conventional analysis.')
(f.ROOT/'results/smoothing_walsh_geometry_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
