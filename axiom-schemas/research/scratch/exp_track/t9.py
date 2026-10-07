import time, sys, itertools, signal
from collections import Counter
from dtrc.syntax import pp
from dtrc.datasets import *
from dtrc.mincover import MinCover
class TO(Exception): pass
def handler(s, f): raise TO
signal.signal(signal.SIGALRM, handler)
ta0 = sys.argv[1] != 'full'
for mix in ['zf', 'pa']:
    data = zf_mix(0) if mix == 'zf' else pa_mix(0)
    sents = [s for s,_ in data]
    lab = {s:l for s,l in data}
    n=0; tot=0; mx=0; nmins=Counter(); t0=time.time()
    for a, b in itertools.combinations(range(len(sents)), 2):
        signal.alarm(3)
        try:
            t = time.time()
            mc = MinCover([sents[a], sents[b]], term_arity0=ta0)
            mins = mc.minimal()
            signal.alarm(0)
            dt = time.time()-t; mx = max(mx, dt); tot += 1
            nmins[min(len(mins), 10)] += 1
        except TO:
            n+=1
    print(mix, 'class', 'DT0_F' if ta0 else 'DT0', 'pairs', tot+n, 'timeouts(>3s)', n, 'max time %.2f' % mx, 'total %.1f' % (time.time()-t0), '#min histogram', sorted(nmins.items()))
