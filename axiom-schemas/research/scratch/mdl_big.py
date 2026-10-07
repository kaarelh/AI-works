import sys; sys.path.insert(0,'/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
import random
exec(open('/home/user/AI-works/axiom-schemas/research/tracks/untagged/code/u7_mdl.py').read().split("for n in (50")[0])
for n in (16000, 64000):
    rng = random.Random(n)
    data = pa_data(n, rng, p_ind=0.5)
    out = []
    for mode in ('NAIVE','PC','DPC'):
        Lt = codelength(data,'true',mode); Ls = codelength(data,'root',mode)
        out.append('%s %+.0f' % (mode, Ls-Lt))
    print(n, out, flush=True)
