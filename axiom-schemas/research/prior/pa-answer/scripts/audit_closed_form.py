# Check: under Lemma descent(c),(d) and Lemma audit(b), the audit's output A is the same for every
# oracle tie-breaking / every interleaving of descents and fallback, and equals
#   (P \ S1) \ U C(P \ S1),   S1 = {s : {s} in Conf}  (singleton d-conflicts).
# Model: universe U (practice), genuine G (clean set), Conf upward closed, every member contains a fallacy,
# no subset of G in Conf. A successful descent removes a NONEMPTY subset of B ∩ S1 (schemas having the
# falsified step s as instance; all are singleton conflicts by Lemma 2.5(d)). A blocked descent -> fallback
# B \ U minimal-conflicts-inside-B. Explore ALL nondeterministic paths.
import random, itertools
def minimal(conf):
    return [c for c in conf if not any(d < c for d in conf)]
def run(seed):
    rng=random.Random(seed); n=rng.randint(2,6); U=frozenset(range(n))
    G=frozenset(i for i in U if rng.random()<0.5); F=U-G
    if not F: return None
    # random generators of Conf: sets containing >=1 fallacy
    gens=[]
    for _ in range(rng.randint(1,4)):
        k=rng.randint(1,n); c=set(rng.sample(sorted(U),k))
        if not (c & F): c.add(rng.choice(sorted(F)))
        gens.append(frozenset(c))
    allsets=[frozenset(s) for r in range(n+1) for s in itertools.combinations(sorted(U),r)]
    conf=set(s for s in allsets if any(g<=s for g in gens))
    assert not any(s<=G for s in conf)
    S1=frozenset(i for i in U if frozenset([i]) in conf)
    def mins_in(B): return minimal([c for c in conf if c<=B])
    R=U-S1; target=R-frozenset().union(*mins_in(R)) if mins_in(R) else R
    outs=set()
    def explore(B):
        if B not in conf: outs.add(B); return
        # fallback is always possible (default oracle may return a blocked refutation)
        m=mins_in(B); outs.add(B-frozenset().union(*m))
        cand=sorted(B&S1)
        for r in range(1,len(cand)+1):
            for X in itertools.combinations(cand,r): explore(B-frozenset(X))
    explore(U)
    return outs, target, G, F
bad=0; tested=0; collateral_cases=0
for seed in range(20000):
    r=run(seed)
    if r is None: continue
    outs,target,G,F=r; tested+=1
    if outs!={target}: bad+=1; print('MISMATCH',seed,outs,target)
    if not G<=target: collateral_cases+=1
print('families tested',tested,'mismatches',bad,'cases with genuine collateral',collateral_cases)
