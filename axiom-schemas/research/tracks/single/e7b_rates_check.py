# e7b: larger Monte Carlo for the Prop D.4 template at N = 16, 24 (the bound of Theorem E is close to
# the estimate there, so check with 20000 runs).
import random
from e7_rates import Tu, u_pool, u_w, params, bound, events
rng = random.Random(77)
res = params(Tu, u_pool, u_w)
for N in [16, 24]:
    runs, bad = 20000, 0
    for _ in range(runs):
        ths = rng.choices(u_pool, weights=u_w, k=N)
        ev, D = events(Tu, ths)
        bad += (not ev['pred'])
    p = bad / runs
    print('N=%d  MC P[not anchor] = %.5f +- %.5f (1 s.e., %d runs)   bound = %.5f' % (N, p, (p * (1 - p) / runs) ** 0.5, runs, bound(res, N)))
