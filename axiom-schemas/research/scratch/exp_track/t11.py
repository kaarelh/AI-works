import random, sys
sys.path.insert(0,'.')
from e1_universal import *
T = TARGETS['x+0=x']
bad = 0
for r in range(400):
    rng = random.Random(1000 + r)
    D = []; heads=set()
    for N in range(1, 41):
        t = draw_term(rng, 'mixed')
        D.append(canon_params(instantiate(T, {'t': t})))
        heads.add(canon_params(('=', t, ('0',)))[1][0])
        mins = MinCover(D).minimal()
        ex = len(mins)==1 and equiv(mins[0], T)
        if len(heads) > 1 and not ex:
            bad += 1
            if bad < 5: print('heads', heads, [pp(d) for d in D], [pp(M) for M in mins])
            break
        if ex: break
print('bad', bad)
