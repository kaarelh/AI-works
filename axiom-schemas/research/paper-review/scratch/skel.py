import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from collections import Counter
from dtrc.syntax import pp, canon_params
from dtrc.datasets import pa_mix
from dtrc.schemas import pa_targets
from dtrc.dtrc import DTRC
for regime in ('numerals', 'mixed'):
    for seed in (0, 2):
        data = pa_mix(seed, univ_dist=regime)
        lab = {}
        for s, l in data:
            lab.setdefault(canon_params(s), l)
        m = DTRC(None, use_refutation=False, k_stop=len(pa_targets())).fit([s for s, _ in data])
        print(regime, seed)
        for c in m.clusters:
            labs = Counter(lab[d] for d in c.data)
            if len(labs) > 1 or any(k.startswith('Q') for k in labs):
                print('   ', dict(labs), [pp(T) for T in (c.mins or [])][:2])
