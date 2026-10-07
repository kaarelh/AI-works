import sys, random
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun')
exec(open('/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun/ref2_within_enum.py').read().split("SM = int")[0])
from practice import *
SM = int(sys.argv[1])
rng = random.Random(5)
for k in ('Sep', 'EInd'): [schema_instance(k, rng) for _ in range(6)]
for trial in range(2):
    xs = [schema_instance('Rep', rng) for _ in range(2)]
    check('Rep pair #%d' % trial, xs, SM, 'set')
