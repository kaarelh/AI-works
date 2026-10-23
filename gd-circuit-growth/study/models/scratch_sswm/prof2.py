import sys, time, numpy as np, cProfile, pstats, os
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM
kw = eval('dict(' + sys.argv[1] + ')'); fn = sys.argv[2]; n = int(sys.argv[3])
M = SSWM(**kw)
X, y = C.train_data(fn, 0, n)
out = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/prof2.out"
t0 = time.time()
cProfile.run("r = M.fit(X, y, np.random.default_rng(0))", out)
print('total', time.time() - t0, 'acc', r['n_accepted'], 'size', r['size'])
p = pstats.Stats(out); p.sort_stats('tottime').print_stats(12)
