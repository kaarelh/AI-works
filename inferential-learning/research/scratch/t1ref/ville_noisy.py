import random, itertools
# H = all subsets of {0,1,2,3}, uniform prior; R*={0}; noisy oracle flip eta; adaptive greedy prover
U=4
H=[frozenset(c for c in range(U) if m>>c&1) for m in range(1<<U)]
def run(rng,eta,dprime,T=400):
    w={R:1/len(H) for R in H}; Rstar=frozenset({0}); wstar=1/len(H); delta=wstar*dprime
    for t in range(T):
        # prover: among invalid steps pick the one with smallest w(q notin R); if < delta -> accepted
        cand=[q for q in range(U) if q not in Rstar]
        q=min(cand,key=lambda q: sum(v for R,v in w.items() if q not in R))
        if sum(v for R,v in w.items() if q not in R)<delta: return True
        # escalate: noisy answer
        y=(q in Rstar)
        if rng.random()<eta: y=not y
        for R in w: w[R]*= (1-eta) if ((q in R)==y) else eta
        Z=sum(w.values()); w={R:v/Z for R,v in w.items()}
    return False
rng=random.Random(1)
for eta in [0.1,0.3,0.45]:
    for dp in [0.2,0.5]:
        T=3000
        f=sum(run(rng,eta,dp) for _ in range(T))/T
        print('eta',eta,'delta\'',dp,'P(accept invalid)=%.4f'%f,'<= bound',dp)
