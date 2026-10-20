import numpy as np
def walk_levels(c, D, M):
    p = np.zeros(D+1); p[0] = 1.0
    W = np.zeros(D+1)
    j = np.arange(D+1)
    up = (D - j)/D; dn = j/D
    for m in range(1, M+1):
        q = np.zeros(D+1)
        q[1:] += p[:-1]*up[:-1]
        q[:-1] += p[1:]*dn[1:]
        p = q
        if c[m] != 0: W += c[m]*p
    return W
