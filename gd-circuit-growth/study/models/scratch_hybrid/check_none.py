import sys, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.hybrid import Hybrid
from models.race import Race
ag = []
for fn, n in [('mux', 256), ('maj9', 64), ('sparsepoly', 1024), ('par3', 512), ('rand1', 128), ('dict', 16)]:
    for s in range(3):
        X, y = C.train_data(fn, s, n); Xte, _ = C.test_data(fn)
        r1 = Race(theta=1.5, Q=3, gate='relu').fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
        r2 = Hybrid(mode='none').fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
        assert r1['orders'] == r2['orders'] and r1['fanin'] == r2['fanin'] and abs(r1['time'] - r2['time']) < 1e-6, (fn, n, s)
        ag.append(np.mean(r1['predict'](Xte) == r2['predict'](Xte)))
print(f'mode none: same gates and clock on 18 fits; test predictions identical on {np.mean(ag):.5f} of points (min {min(ag):.5f})')
