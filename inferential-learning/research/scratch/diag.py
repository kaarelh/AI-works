import sys, random
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T7-checks')
import ttl_sim as M
rng=random.Random(0)
pi={**{t:1.0 for t in M.GEN},**{t:1.0 for t in M.FAL}}; Z=sum(pi.values()); pi={t:v/Z for t,v in pi.items()}
for N in [60,120,250,500]:
    for trial in range(20):
        data,nn=M.sample_data(rng,N,pi,0.01)
        if max(nn.values())>2: print(N, trial, {t:v for t,v in nn.items() if v>2})
