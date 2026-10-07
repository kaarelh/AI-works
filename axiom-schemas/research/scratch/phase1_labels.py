import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
from dtrc.syntax import canon_params, pp
from dtrc.datasets import pa_mix, zf_mix
from dtrc.schemas import pa_targets, zf_targets
from dtrc.dtrc import DTRC
from dtrc.refute import TemplateRefuter
from dtrc.templates import covers
for lang, regime in (('PA','numerals'),('PA','mixed'),('ZF','-')):
    targets = pa_targets() if lang=='PA' else zf_targets()
    for seed in range(5):
        data = pa_mix(seed, univ_dist=regime) if lang=='PA' else zf_mix(seed)
        D = list(dict.fromkeys(canon_params(s) for s,_ in data))
        R = TemplateRefuter(lang)
        m = DTRC(R).fit(D)
        labs = []
        bad = []
        for c in m.clusters:
            ls = [k for k,T in targets.items() if all(covers(T,d) for d in c.data)]
            if len(ls)!=1: bad.append(([pp(d) for d in c.data], ls))
            else: labs.append(ls[0])
        withdata = [k for k,T in targets.items() if any(covers(T,d) for d in D)]
        missing = [k for k in withdata if k not in labs]
        print(lang, regime, seed, 'clusters', len(m.clusters), 'P-violations', bad, 'targets with data but no phase-1 cluster', missing, 'dup labels', len(labs)-len(set(labs)))
