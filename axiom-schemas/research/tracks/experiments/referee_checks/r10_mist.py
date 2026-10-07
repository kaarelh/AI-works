"""R10: ZF mistakes (E4b) at budget 400: what do the contaminated clusters accept, and are their accepted
templates false (refutable with a much larger budget)?"""
import sys, random
from collections import Counter
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import canon_params, pp
from dtrc.refute import TemplateRefuter, Oracle
from dtrc.dtrc import DTRC
from dtrc.datasets import zf_mix
for seed in (0, 1):
    data = zf_mix(seed, mistakes=6)
    lab = {canon_params(s): l for s, l in data}
    m = DTRC(TemplateRefuter('ZF', budget=400)).fit([s for s, _ in data])
    for c in m.clusters:
        labs = Counter(lab[d] for d in c.data)
        if len(labs) > 1:
            print('seed', seed, 'mixed cluster', dict(labs))
            for T in (c.acc or []):
                print('   accepted template:', pp(T))
                big = TemplateRefuter('ZF', budget=3000, data_budget=300, seed=1)
                r = big.refuted(T, c.data)
                print('   refuted with budget 3000:', r, ('witness: ' + pp(big.witness(T))) if r else '', big.stats())
