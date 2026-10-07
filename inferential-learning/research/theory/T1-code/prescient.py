# Added during verification (referee script): Thm 4.2(a) fails if the prover foresees the oracle noise.
import random
# H = subsets of {0,1}, uniform prior, R*={0}; noisy oracle flips w.p. eta; prover sees the oracle's next coin.
H=[frozenset(),frozenset({0}),frozenset({1}),frozenset({0,1})]
def run(rng,eta,dprime,T=300):
    w={R:.25 for R in H}; Rs=frozenset({0}); delta=.25*dprime
    for t in range(T):
        if sum(v for R,v in w.items() if 1 not in R)<delta: return True   # query invalid step 1 -> ACC
        flip=rng.random()<eta            # prover knows this before choosing
        q=1 if flip else 0               # invalid step only when its answer will be flipped to 'valid'
        if sum(v for R,v in w.items() if q not in R)<delta: continue  # accepted valid step, no observation
        y=(q in Rs)!=flip
        for R in w: w[R]*=(1-eta) if ((q in R)==y) else eta
        Z=sum(w.values()); w={R:v/Z for R,v in w.items()}
    return False
rng=random.Random(0)
for eta in [0.1,0.3]:
    print('eta',eta,'P(accept invalid) with prescient prover =',sum(run(rng,eta,0.05) for _ in range(2000))/2000,'(Ville bound 0.05)')
