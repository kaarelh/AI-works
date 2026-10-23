import sys, time, numpy as np, cProfile, pstats
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.sswm import SSWM
M = SSWM()
X, y = C.train_data('thr10', 0, 4096)
cProfile.run("r = M.fit(X, y, np.random.default_rng(0))", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/prof.out")
p = pstats.Stats("/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/prof.out"); p.sort_stats('cumtime').print_stats(15)
print(r['n_accepted'], r['size'], r['time'])
