# Referee check 6: merge-order independence under separation (Thm 5.2(ii)): same data, 8 random orders.
import sys, random
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun')
from dtlib import *
from dtrc import World, DTRC
from practice import *
def part(A): return frozenset(frozenset(C) for C in A.clusters)
for lang, gen, n in (('arith', lambda r: pa_data(40, r), 40), ('set', lambda r: zf_data(45, r), 45)):
    rng = random.Random(7)
    data = [s for _, s in gen(rng)]
    W = World(lang, B=3, hf=3, budget=500 if lang == 'set' else 1500, seed=7)
    parts = set()
    for t in range(8):
        r2 = random.Random(100 + t); d2 = list(data); r2.shuffle(d2)
        A = DTRC(W); A.run(d2); parts.add(part(A))
    print(lang, 'distinct data', len(set(data)), ' distinct final partitions over 8 orders:', len(parts),
          ' clusters:', sorted(len(C) for C in next(iter(parts))))
