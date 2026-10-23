import sys, time, cProfile, pstats; sys.path.insert(0, '.')
import numpy as np, common as C
from models.race import Race
fn, n = sys.argv[1], int(sys.argv[2])
X, y = C.train_data(fn, 0, n)
M = Race(gate="relu", theta=1.5)
t0 = time.time()
cProfile.run("r = M.fit(X, y, np.random.default_rng(0))", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/race_prof")
print('secs', time.time() - t0, 'size', r['size'])
pstats.Stats("/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/race_prof").sort_stats('tottime').print_stats(8)
