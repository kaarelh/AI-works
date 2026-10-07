import time, sys, itertools
from collections import Counter
from dtrc.syntax import pp
from dtrc.datasets import *
from dtrc.mincover import MinCover
data = zf_mix(0)
sents = [s for s,_ in data]
lab = {s:l for s,l in data}
worst = []
for a, b in itertools.combinations(range(len(sents)), 2):
    t = time.time()
    mc = MinCover([sents[a], sents[b]])
    t1 = time.time()
    confs = mc.configurations()
    t2 = time.time()
    mins = mc.minimal()
    t3 = time.time()
    if t3 - t > 0.5:
        print('%s/%s slots=%d confs=%d mins=%d trunc=%s  init %.2f conf %.2f min %.2f' % (lab[sents[a]], lab[sents[b]], len(mc.slots), len(confs), len(mins), mc.truncated, t1-t, t2-t1, t3-t2), flush=True)
