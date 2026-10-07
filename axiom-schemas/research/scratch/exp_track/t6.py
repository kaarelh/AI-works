import time, sys, cProfile, pstats
from collections import Counter
from dtrc.syntax import pp
from dtrc.datasets import *
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC
data = zf_mix(0, n_sep=6, n_rep=5, n_eind=5)
R = TemplateRefuter('ZF', budget=30, data_budget=15, steps=3000)
pr = cProfile.Profile(); pr.enable()
t=time.time(); m = DTRC(R).fit([s for s,_ in data]); print('time', time.time()-t, m.stats)
pr.disable()
lab = {s: l for s,l in data}
for c in m.clusters:
    print(len(c.data), Counter(lab[d] for d in c.data), [pp(T) for T in c.acc] if c.acc else 'GROUND', 'trunc' if c.truncated else '')
pstats.Stats(pr).sort_stats('cumulative').print_stats(18)
