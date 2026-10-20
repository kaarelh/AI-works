"""S1 sample-size check (reconstruction).
For f = h(sum_i x_i) learned by the all-ones-weight readout of claim S1, the expected test error is
E = sum_v p_v (1 - p_v)^n, p_v = Pr[sum_i x_i = v]  (mass of grid values not seen in n samples).
Checks that n = ceil((2/(e eps)) (sqrt(2 d ln(4/eps)) + 1)) gives E <= eps, and prints the crude bound (d+1)/(e n).
Columns: d, eps, n, E, E <= eps, (d+1)/(e n).
The original script was not saved; this reconstruction reproduces the original output v4.out line for line."""
import math
from math import comb
for d in [41, 101, 401, 1001]:
    for eps in [0.1, 0.01]:
        n = math.ceil(2 / (math.e * eps) * (math.sqrt(2 * d * math.log(4 / eps)) + 1))
        p = [comb(d, k) / 2 ** d for k in range(d + 1)]
        E = sum(pv * (1 - pv) ** n for pv in p)
        print(d, eps, n, E, E <= eps, (d + 1) / (math.e * n))
