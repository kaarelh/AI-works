"""Referee check R2: Prop E7 (exact iff heads not all equal) on random data, and re-estimate the numerals mean
with fresh seeds."""
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
from dtrc.syntax import parse, num, P, canon_params, pp
from dtrc.templates import instantiate, equiv
from dtrc.mincover import MinCover
from dtrc.datasets import rand_closed_term

TARGETS = ['?t+0=?t', '?t*0=0', '0+?t=?t', '~S?t=0', '?t<S?t', '?t=?t', '?t+?t=?t*2', 'S?t+0=S(?t+0)', '?t*1=?t']
rng = random.Random(12345)
viol = 0; tot = 0
for it in range(3000):
    T = parse(rng.choice(TARGETS))
    N = rng.randint(1, 4)
    ts = []
    for _ in range(N):
        r = rng.random()
        if r < 0.4: t = num(rng.randrange(5))
        elif r < 0.85: t = rand_closed_term(rng, 3, params=('a','b'))
        else: t = P(rng.choice('ab'))
        ts.append(t)
    D = [canon_params(instantiate(T, {'t': t})) for t in ts]
    mins = MinCover(D).minimal()
    exact = len(mins) == 1 and equiv(mins[0], T)
    # parameters canonicalise to w0 in each datum, so the 'head' of a parameter term is the parameter class
    heads = set(('p' if t[0]=='p' else t[0]) for t in ts)
    pred = len(heads) > 1
    # but parameter identity can matter: compare canonical data
    tot += 1
    if exact != pred:
        viol += 1
        if viol <= 8:
            print('VIOLATION', pp(T), [pp(d) for d in D], [pp(M) for M in mins], 'exact', exact, 'pred', pred)
print('E7 check: %d data sets, %d violations' % (tot, viol))

# fresh-seed estimate of mean N to exactness for numerals 0..7 (head process only, which E7 justifies)
def sim(runs, seed):
    r = random.Random(seed); tot = 0
    for _ in range(runs):
        hs = set()
        for N in range(1, 41):
            hs.add('0' if r.randrange(8) == 0 else 'S')
            if len(hs) > 1: break
        else:
            N = 41
        tot += N
    return tot / runs
print('head-process mean, numerals, 200000 runs:', sim(200000, 7))
