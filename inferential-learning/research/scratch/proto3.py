import time, sys
sys.path.insert(0, '.')
from cil.domains.algebra import *
from cil.provers import *
oracle = WorldOracle(seed=5, n_points=60)
for g in FALSE_GOALS + TRUE_GOALS:
    ce = oracle.counterexample(g.lhs, g.rhs, g.facts)
    if (ce is None) != g.true: print('LABEL MISMATCH', g.name, ce)
V = RuleSetVerifier(TARGET_RULES)
P = ProposalGenerator()
B = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
tot = 0
for g in TRUE_GOALS + FALSE_GOALS:
    t = time.time()
    ch = EdgeChecker(V)
    r = prove(g, ch, P, B, seed=0)
    tot += time.time()-t
    print(f"{g.name:18s} true={g.true} proved={r.proved} q={r.queries} exp={r.expansions} acc={r.accepted} dfalse={len(r.derived_false)} {time.time()-t:.2f}s", ' | '.join(map(str, r.proof)) if r.proved else '')
print('total', tot)
