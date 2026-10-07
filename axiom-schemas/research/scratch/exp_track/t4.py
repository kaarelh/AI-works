import time, sys
from collections import Counter
from dtrc.syntax import pp
from dtrc.datasets import *
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC
seed = int(sys.argv[1]) if len(sys.argv)>1 else 0
data = pa_mix(seed)
print(len(data), Counter(l for _,l in data))
for s,l in data[:8]: print(l, pp(s))
R = TemplateRefuter('PA')
t=time.time(); m = DTRC(R).fit([s for s,_ in data]); print('time', time.time()-t, m.stats)
lab = {s: l for s,l in data}
for c in m.clusters:
    print(len(c.data), Counter(lab[d] for d in c.data), [pp(T) for T in c.acc] if c.acc else 'GROUND', 'trunc' if c.truncated else '')
