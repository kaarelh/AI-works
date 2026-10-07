"""R16: E3 PA-mix with universal axioms observed only through numeral instances (as the task specified);
dtrc's pa_mix draws numerals w.p. 0.6, closed terms 0.25 and a parameter 0.15 (w0+0=w0 is the closure-normal
form of the axiom itself).  Same seeds; DTRC vs tagged."""
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
import dtrc.datasets as DS
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC, tagged_learner
from dtrc.metrics import exact_for
from dtrc.schemas import pa_targets
from common import by_label, clustering_scores
orig = DS.universal_instance
targets = pa_targets()
for mode, kw in (('as in E3', {}), ('numerals only', {'p_numeral': 1.0})):
    DS.universal_instance = lambda rng, T, _kw=kw: orig(rng, T, **_kw)
    tot_d = tot_t = 0; per = {}
    for seed in range(5):
        data = DS.pa_mix(seed)
        m = DTRC(TemplateRefuter('PA')).fit([s for s, _ in data])
        tl = tagged_learner(by_label(data), refuter=TemplateRefuter('PA'))
        for k in ('U_add0', 'U_mul0', 'U_0add'):
            d = any(c.acc and exact_for(c.acc, targets[k]) for c in m.clusters)
            t = exact_for(tl[k]['acc'], targets[k])
            per.setdefault(k, [0, 0]); per[k][0] += d; per[k][1] += t
        cs = clustering_scores(m, data, targets)
    print(mode, {k: 'DTRC %d/5, tagged %d/5' % tuple(v) for k, v in per.items()})
DS.universal_instance = orig
