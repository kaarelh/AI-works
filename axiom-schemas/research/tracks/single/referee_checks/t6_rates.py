# Referee sanity check of Theorem E(a) on T* = Ax(0 = f(x)), f ~ {0: .4, z: .3, Sz: .3}.
import random
from rc_core import *
from rc_anchor import feat_truth
z = ('z', 0)
T = ALL(EQ(Z, M('f', V(0))))
law = [(Z, .4), (z, .3), (S(z), .3)]
rho = 1 - .4; nu = .6; kappa = 1 - .7 ** 2
rng = random.Random(3)
def draw():
    r = rng.random(); acc = 0
    for b, p in law:
        acc += p
        if r < acc: return b
    return law[-1][0]
for N in [2, 4, 6, 8, 12]:
    runs = 4000; bad = 0
    for _ in range(runs):
        D = list({inst(T, {'f': draw()}) for _ in range(N)})
        ok, _ = feat_truth(T, D)
        bad += (not ok)
    exact = None
    # exact: not anchor iff all values in {0,z} (coincidence or root/N failure) or all values = Sz (root & N fail)
    exact = .7 ** N + .3 ** N
    bound = (1 - rho) ** (N - 1) + (1 - nu) ** N + (1 - kappa) ** (N // 2)
    print('N=%2d  MC P[not anchor]=%.4f  exact=%.4f  Thm E bound=%.4f  lower bound max((1-rho)^N,(1-nu)^N)=%.4f' % (N, bad / runs, exact, bound, max((1-rho)**N, (1-nu)**N)))
