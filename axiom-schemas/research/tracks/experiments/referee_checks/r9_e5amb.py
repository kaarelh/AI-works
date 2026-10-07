"""Referee check R9: E5 PA streams -- are all DTRC/tagged differences caused by ambiguous data?
Re-run the same streams (same seeds) (a) as is, recording every (seed, N, target) disagreement,
(b) with data that are instances of >1 target removed."""
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
import e5_curves as E5
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC, tagged_learner
from dtrc.metrics import exact_for, targets_of
from dtrc.schemas import pa_targets
from common import by_label

targets = pa_targets()
for variant in ('as is', 'ambiguous removed'):
    dis = []
    amb_count = 0
    for seed in E5.SEEDS:
        full = E5.stream('PA', seed, max(E5.GRID))
        if variant != 'as is':
            n0 = len(full)
            full = [(s, k) for s, k in full if len(targets_of(s, targets)) == 1]
            amb_count += n0 - len(full)
        R = TemplateRefuter('PA')
        for N in E5.GRID:
            data = full[:N]
            m = DTRC(R).fit([s for s, _ in data])
            ex_d = {k: any(c.acc and exact_for(c.acc, T) for c in m.clusters) for k, T in targets.items()}
            tl = tagged_learner(by_label(data), refuter=R)
            ex_t = {k: (k in tl and exact_for(tl[k]['acc'], T)) for k, T in targets.items()}
            for k in targets:
                if ex_d[k] != ex_t[k]:
                    dis.append((seed, N, k, 'DTRC' if ex_d[k] else 'tagged'))
    print(variant, 'ambiguous items removed:', amb_count, 'disagreements:', len(dis))
    for d in dis: print('   ', d)
