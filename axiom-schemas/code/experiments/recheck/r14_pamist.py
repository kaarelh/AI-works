"""R14: PA mistakes (E4b): accepted templates of contaminated clusters, and whether they are valid."""
import sys
from collections import Counter
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import canon_params, pp
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC
from dtrc.datasets import pa_mix
for seed in (0, 1, 2):
    data = pa_mix(seed, mistakes=8, true_nontargets=3)
    lab = {canon_params(s): l for s, l in data}
    m = DTRC(TemplateRefuter('PA')).fit([s for s, _ in data])
    for c in m.clusters:
        labs = Counter(lab[d] for d in c.data)
        if any(l.startswith('MISTAKE') for l in labs) and len(c.data) > 1:
            print('seed', seed, dict(labs))
            for d in c.data: print('     datum:', pp(d))
            for T in (c.acc or []):
                big = TemplateRefuter('PA', budget=3000, data_budget=300, seed=3)
                print('   accepted:', pp(T), '| refuted at budget 3000:', big.refuted(T, c.data))
