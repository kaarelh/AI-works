"""Referee check R6: how often does the alignment-complete Min differ from dtrc's Min on the experiments' data?
 (i) E2 tagged data sets (N=2,3; 30 seeds; same generator and seeds as e2_schemas.py) -> exactness;
 (ii) E9-style cross-target pairs (PA-mix, ZF-mix, near-miss) -> does every aligned min get refuted?"""
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
from dtrc.syntax import pp
from dtrc.templates import geq, equiv
from dtrc.mincover import MinCover
from dtrc.metrics import exact_for
from dtrc.schemas import T_SEP, T_REP, T_EIND, T_IND, Sep, Rep, EInd, Ind
from dtrc.datasets import zf_body, pa_motive
from alignmin import aligned_min

SCHEMAS = {
    'Sep': (T_SEP, lambda rng: Sep(zf_body(rng, 2, [0]))),
    'Rep': (T_REP, lambda rng: Rep(zf_body(rng, 3, [0, 1]))),
    'EInd': (T_EIND, lambda rng: EInd(zf_body(rng, 1, [0]))),
    'Ind': (T_IND, lambda rng: Ind(pa_motive(rng))),
}
for name, (T, gen) in SCHEMAS.items():
    for N in (2, 3, 4):
        diff = ex_c = ex_a = 0; skipped = 0
        for seed in range(30):
            rng = random.Random(seed * 7919 + N)
            D = list(dict.fromkeys(gen(rng) for _ in range(N)))
            mc = MinCover(D).minimal()
            ma = aligned_min(D)
            if ma is None:
                skipped += 1; continue
            same = len(mc) == len(ma) and all(any(equiv(a, b) for b in ma) for a in mc)
            diff += int(not same)
            ex_c += int(exact_for(mc, T)); ex_a += int(exact_for(ma, T))
            if not same and diff <= 1:
                print('  example', name, N, 'computed', [pp(x) for x in mc], 'aligned', [pp(x) for x in ma])
        print(name, 'N=%d' % N, 'Min differs in %d/30 (skipped %d); exact computed %d, aligned %d' % (diff, skipped, ex_c, ex_a))
