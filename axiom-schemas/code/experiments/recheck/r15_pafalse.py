"""R15: DTRC on PA-mix with mistakes (seed 0, budgets 80 and 400, as in E4b) accepts a false sentence."""
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp, EQ, H, S, ZERO, canon_params
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC
from dtrc.datasets import pa_mix
from dtrc.schemas import pa_targets
from dtrc.metrics import targets_of
q = parse('((exists x. (0=0 & ~0=2)) & (forall x. ((exists y. (x=0 & ~x=2)) -> (exists y. (y<Sx & ~Sx=2))))) -> (forall x. exists y. (y<Sx & ~Sx=2))')
print('query:', pp(q))
print('instance of a PA-mix target:', targets_of(q, pa_targets()))
# v2 copy: the v1 data are pa_mix(..., univ_dist='mixed'); also try the v2 numerals regime and budget 2000
from dtrc.oracle_pa import PAEval
print('v2 oracle verdict on the query:', PAEval().truth(q), '; without the case split:', PAEval(split=0).truth(q))
for dist in ('mixed', 'numerals'):
    for budget in (80, 400, 2000):
        m = DTRC(TemplateRefuter('PA', budget=budget)).fit([s for s, _ in pa_mix(0, mistakes=8, true_nontargets=3, univ_dist=dist)])
        print(dist, 'budget', budget, 'DTRC accepts:', m.accepts(q), 'via clusters', [[pp(d)[:60] for d in c.data] for c in m.accepting_clusters(q)])
# truth in N, by hand: premise 1 true; premise 2: x=0 -> 0<1 & 1!=2 true, x!=0 -> antecedent false; conclusion fails at x=1 (S1=2).
