import random, sys
from collections import Counter
sys.path.insert(0,'.')
from e1_universal import *
T = TARGETS['x+0=x']
n_dt, n_fo, agree = run('x+0=x', T, 'mixed', 400, 40, 1000)
c = Counter(n_dt)
e, hd = predicted_mean('mixed', 40)
print(hd)
ps = list(hd.values())
for N in range(1, 8):
    emp = sum(v for k, v in c.items() if k > N) / 400
    print(N, round(emp,3), round(sum(p**N for p in ps),3))
# empirical head distribution in the run's own draws
rng = random.Random(1000); cnt=Counter()
for r in range(400):
    rng = random.Random(1000 + r)
    for N in range(3):
        t = draw_term(rng, 'mixed'); cnt[canon_params(('=', t, ('0',)))[1][0]] += 1
print({k: round(v/1200,3) for k,v in cnt.items()})
