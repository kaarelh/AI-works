import sys, random, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/single')
from dtunion import two_sat
rng = random.Random(1)
bad = 0
for t in range(3000):
    n = rng.randint(1, 6)
    cl = [((rng.randrange(n), rng.random()<.5), (rng.randrange(n), rng.random()<.5)) for _ in range(rng.randint(0, 3*n))]
    bf = any(all(a[a_[0]] == a_[1] or a[b_[0]] == b_[1] for a_, b_ in cl) for a in itertools.product([False, True], repeat=n))
    if bf != two_sat(n, cl): bad += 1
print('2-SAT disagreements:', bad)
