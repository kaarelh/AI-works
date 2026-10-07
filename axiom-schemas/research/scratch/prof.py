import sys; sys.path.insert(0,'/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
import random, cProfile, pstats, time
from dtlib import *
from dtrc import World, DTRC
from practice import *
rng = random.Random(1)
data = zf_data(15, rng); rng.shuffle(data)
W = World('set', hf=3, budget=500, seed=1)
A = DTRC(W)
t0=time.time()
cProfile.run('A.run([s for _, s in data])', '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/prof.out')
print('time', time.time()-t0, 'tests', A.tests, 'calls', W.calls)
p = pstats.Stats('/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/prof.out'); p.sort_stats('cumulative').print_stats(18)
