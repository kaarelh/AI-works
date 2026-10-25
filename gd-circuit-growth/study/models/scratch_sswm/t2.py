import sys, time, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM, _apply
X, y = C.train_data('thr10', 0, 4096)
W = np.ascontiguousarray(X.T)
r = np.random.randn(4096).astype(np.float32)
rng = np.random.default_rng(0)
t0 = time.time()
for _ in range(100):
    u = rng.integers(0, 30, 256); v = rng.integers(0, 30, 256); tt = rng.integers(0, 6, 256)
    vals = _apply(tt, W[u], W[v]); mu = vals.mean(1, dtype=np.float64); q = vals @ r
print('100 full batches', time.time() - t0)
