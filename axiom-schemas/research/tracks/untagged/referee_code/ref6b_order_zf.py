# Referee check 6b: merge-order independence on ZF (smaller: 30 data, 4 orders), cf. ref6 (PA, 8 orders).
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC
from practice import *
rng = random.Random(7)
lab = zf_data(30, rng)
data = [s for _, s in lab]
W = World('set', hf=3, budget=500, seed=7)
parts = set()
for t in range(4):
    r2 = random.Random(100 + t); d2 = list(data); r2.shuffle(d2)
    A = DTRC(W); A.run(d2); parts.add(frozenset(frozenset(C) for C in A.clusters))
    print('order', t, 'clusters', sorted(len(C) for C in A.clusters), flush=True)
L = {}
for k, s in lab: L.setdefault(s, set()).add(k)
P = next(iter(parts))
print('distinct data', len(set(data)), ' distinct final partitions over 4 orders:', len(parts),
      ' all pure:', all(len(set().union(*[L[s] for s in C])) == 1 for C in P))
