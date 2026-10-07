# Referee check 7: does mincov hit its silent caps (max_antichain=4096, max_templates=50000) on the clusters used?
import sys, random
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/rerun')
import dtlib
from dtlib import *
from practice import *
hits = {'anti': 0, 'tmpl': 0, 'calls': 0}
orig = dtlib.mincov
def probe(X, max_templates=50000, max_antichain=4096):
    # re-run with larger caps and compare
    a = orig(X, max_templates, max_antichain)
    b = orig(X, 10 * max_templates, 10 * max_antichain)
    hits['calls'] += 1
    if set(map(canon, a)) != set(map(canon, b)): hits['anti'] += 1; print('  CAP CHANGES RESULT on |X|=%d' % len(X))
    return a
import dtrc
from dtrc import World, DTRC
for lang, gen, seeds in (('arith', lambda r: pa_data(40, r), (1, 2, 3)), ('set', lambda r: zf_data(45, r), (1,))):
    for seed in seeds:
        rng = random.Random(seed); data = gen(rng); rng.shuffle(data)
        W = World(lang, B=3, hf=3, budget=1500 if lang == 'arith' else 500, seed=seed)
        A = DTRC(W, mincov_fn=probe); A.run([s for _, s in data])
        print(lang, seed, 'mincov calls', hits['calls'], 'cap-sensitive results so far', hits['anti'], flush=True)
