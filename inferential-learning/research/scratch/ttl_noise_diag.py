import sys, random
sys.path.insert(0,'/home/user/AI-works/inferential-learning/research/theory/T7-checks')
import ttl_sim as T
rng=random.Random(0)
pool=['p0','p1','F','T',('not','p0'),('imp','p0','p1'),('or','p0','p1'),('and','p0','p1'),('imp','p1','p0'),('not',('not','p0'))]
pi={**{t:1.0 for t in T.GEN},**{t:1.0 for t in T.FAL}}; Z=sum(pi.values()); pi={t:v/Z for t,v in pi.items()}
alpha=0.01; e=2
for N in [60,120,250,500]:
    for trial in range(20):
        data,nn=T.sample_data(rng,N,pi,alpha)
        ttl=T.learner(data,e,audit=True)
        if max(nn.values())>e:
            ok = set(ttl)==set(T.GEN) and all(T.identified(ttl[t],t) for t in T.GEN)
            print(N,trial,{t:v for t,v in nn.items() if v>e},'exact' if ok else 'not exact')
