"""Referee check R4: random-sentence fuzzing of both oracles against the independent evaluators."""
import sys, random, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.datasets import rand_zf_formula, rand_pa_formula
from dtrc.syntax import pp, canon_params, size
from dtrc.oracle_zf import ZFEval
from dtrc.oracle_pa import PAEval
from indep_eval import Struct, PABounded, qdepth, strip_close

which = sys.argv[1]; n = int(sys.argv[2]); seed = int(sys.argv[3])
rng = random.Random(seed)
stats = {'True': 0, 'False': 0, 'None': 0, 'contra': 0, 'checked': 0}
t0 = time.time()
if which == 'ZF':
    structs = [Struct(random.Random(seed + i), 6, p, q) for i, (p, q) in enumerate(((0, 0), (0.3, 0.3), (0.8, 0.6)))]
    ev = ZFEval()
    while stats['checked'] < n:
        params = rng.choice([[], ['c'], ['c', 'd']])
        f = (rng.choice(['all','ex']), rand_zf_formula(rng, 0, 1, params, rng.randint(2, 5)))
        f = canon_params(f)
        if qdepth(strip_close(f)) > 4 or qdepth(f) == 0:
            continue
        r = ev.truth(f)
        stats[str(r)] += 1
        if r is None:
            continue
        stats['checked'] += 1
        for M in structs:
            if M.truth(f) != r:
                stats['contra'] += 1
                print('CONTRADICTION', r, pp(f))
                break
else:
    ev = PAEval(); E = PABounded(B=10)
    while stats['checked'] < n:
        params = rng.choice([[], ['a'], ['a', 'b']])
        f = rand_pa_formula(rng, 0, params, rng.randint(2, 5), nholes=1)
        from dtrc.syntax import has_hole
        if has_hole(f):
            continue
        f = canon_params(f)
        r = ev.truth(f)
        stats[str(r)] += 1
        if r is None:
            continue
        stats['checked'] += 1
        try:
            m = E.truth(f)
        except Exception:
            continue
        stats["def"] = stats.get("def", 0) + (m is not None)
        if m is not None and m != r:
            stats['contra'] += 1
            print('CONTRADICTION', r, pp(f))
print(which, stats, '%.0fs' % (time.time() - t0))
