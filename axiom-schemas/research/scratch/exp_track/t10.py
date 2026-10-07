from collections import Counter
from dtrc.syntax import pp, canon_params
from dtrc.datasets import *
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC
data = pa_mix(1, n_ind=12, n_univ=(4,4,3))
m = DTRC(TemplateRefuter('PA')).fit([s for s,_ in data])
lab = {canon_params(s): l for s,l in data}
for c in m.clusters:
    print(len(c.data), Counter(lab[d] for d in c.data), [pp(T) for T in c.acc] if c.acc else 'GROUND')
    if len(set(lab[d] for d in c.data))>1 or len(c.data)==1:
        for d in c.data: print('     ', lab[d], pp(d))
