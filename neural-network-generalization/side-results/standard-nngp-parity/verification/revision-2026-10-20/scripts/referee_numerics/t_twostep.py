import numpy as np
from myspec import *
for s1 in [0.2, 0.5, 1.0, 2.0, 5.0]:
    c, v = coeffs_tanh(3001, s1**2)
    odd = np.arange(1, 2999, 2)
    rat = c[odd+2]/c[odd]
    i = np.argmin(rat)
    # L=3 composite with sigma2=1: q2 = v
    c2, v2 = coeffs_tanh(401, v)
    F = compose(c2, c[:402], 401)
    o2 = np.arange(1, 397, 2); r2 = F[o2+2]/F[o2]
    print(f"sigma1={s1}: L=2 min c_(m+2)/c_m={rat[i]:.4e} at m={odd[i]}, ratio at m=2997: {rat[-1]:.4f}, monotone ratio? {np.all(np.diff(rat)>=-1e-12)} | L=3 min={r2.min():.4e} at m={o2[np.argmin(r2)]}, sum F={F.sum():.6f}")
