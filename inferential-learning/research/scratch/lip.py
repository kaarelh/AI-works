import numpy as np, itertools, math
rs = np.random.default_rng(3)
def rand_lip(L, d, m=12):
    # random L-Lipschitz (sup-norm) function: min/max of cones
    C = rs.uniform(0,1,(m,d)); b = rs.uniform(-0.5,1.5,m); sgn = rs.choice([-1,1])
    def e(P):
        D = np.max(np.abs(P[:,None,:]-C[None,:,:]),axis=2)
        return np.min(b[None,:]+L*D,axis=1) if sgn>0 else np.max(b[None,:]-L*D,axis=1)
    return e
bad_s=bad_c=0
for trial in range(300):
    d = rs.integers(1,3); L = rs.uniform(0.5,5); tau = rs.uniform(0,1); gam = rs.uniform(0.05,0.5); eta = rs.uniform(0,gam*0.9)
    e = rand_lip(L,d)
    h = (gam-eta)/L; n = math.ceil(1/h); s = 1/n
    cent = np.array(list(itertools.product(*[ (np.arange(n)+0.5)*s ]*d)))
    ehi = e(cent) + rs.uniform(0,eta,len(cent))
    rad = (tau-ehi)/L
    P = rs.uniform(0,1,(4000,d))
    D = np.max(np.abs(P[:,None,:]-cent[None,:,:]),axis=2)
    inV = np.any(D <= rad[None,:], axis=1)
    eP = e(P)
    bad_s += np.any(inV & (eP > tau+1e-12))
    bad_c += np.any((eP <= tau-gam) & ~inV)
    assert len(cent) == math.ceil(L/(gam-eta))**d
print("soundness violations", bad_s, "completeness violations", bad_c)
