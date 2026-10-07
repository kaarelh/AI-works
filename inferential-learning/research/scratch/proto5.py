import time, sys
sys.path.insert(0, '.')
from cil.domains.algebra import *
from cil.provers import *
from cil.learners import *
from cil.evaluation import unsound_active
N = int(sys.argv[1]); B = int(sys.argv[2])
import os
NOISE = dict(noise_rate=0.05, fallacy_rate=0.3) if os.environ.get("CLEAN") is None else {}
steps = prepare_training(generate_corpus(N, HumanConfig(**NOISE), seed=0), ALGEBRA)
P = ProposalGenerator()
def build(kind):
    if kind == 'pos': return LGGLearner(ALGEBRA, tagged=True, m=2).fit(steps=steps)
    if kind == 'pos_ms': return LGGLearner(ALGEBRA, tagged=True, m=2, guard_mode='most_specific').fit(steps=steps)
    calc = LGGLearner(ALGEBRA, tagged=True, m=2).fit(steps=steps)
    CoherenceRepairer(calc, CoherenceConfig(mode=kind, seed=0), oracle=WorldOracle(seed=7000)).run()
    return calc
for kind in sys.argv[3].split(','):
    t = time.time()
    calc = build(kind)
    tb = time.time() - t
    un = unsound_active(calc)
    t = time.time()
    nf = nt = dfs = 0; lines = []
    for g in FALSE_GOALS + TRUE_GOALS:
        r = prove(g, EdgeChecker(calc), P, B, seed=0)
        dfs += len(r.derived_false)
        if r.proved and not g.true:
            nf += 1; lines.append(f"   FALSE {g.name} q={r.queries}: " + ' | '.join(map(str, r.proof)) + '  ' + str(r.proof_labels))
        if r.proved and g.true: nt += 1
        if not r.proved and g.true: lines.append(f"   missed true {g.name}")
    print(kind, 'build %.1fs'%tb, 'unsound active', len(un), 'false', nf, 'true', nt, 'derived false', dfs, '%.1fs'%(time.time()-t))
    print('\n'.join(lines))
    print('   unsound:', [str(s.rule) for s in un])
