import itertools, random
random.seed(7)
def subsets(xs):
    xs=list(xs)
    for r in range(len(xs)+1):
        for c in itertools.combinations(xs,r): yield frozenset(c)
def minimal(sets):
    sets=[frozenset(s) for s in sets]
    return [s for s in sets if not any(t< s for t in sets)]
stats=dict(trials=0,vd=0,viol=0,ties=0,sacrifice_trials=0,sac_ok=0,sac_viol=0)
for trial in range(20000):
    nV=random.randint(1,5); nE=random.randint(1,3)
    V=[f"v{i}" for i in range(nV)]; E=[f"e{i}" for i in range(nE)]
    g={x: random.choice([-1,1])*random.random()*random.choice([0.1,1,3]) for x in V+E}
    if random.random()<0.1: g[random.choice(V+E)]=0.0
    # witnesses: for each error, random family of subsets of V (incl. possibly empty) -> infeasible upsets
    wit={}
    for F in E:
        fam=[frozenset(random.sample(V,random.randint(0,min(2,nV)))) for _ in range(random.randint(0,2))]
        if random.random()<0.85: fam=[w for w in fam if w]  # mostly nonempty
        wit[F]=minimal(set(fam))
    def feasible(S):  # error-independent by construction
        U=S&frozenset(V)
        return all(not any(w<=U for w in wit[F]) for F in S if F in wit)
    Vp=frozenset(v for v in V if g[v]>0); Ep=frozenset(F for F in E if g[F]>0)
    # valid dominance
    def beta(F):
        ws=[w for w in wit[F] if w<=Vp]
        if not ws: return None
        best=float('inf')
        for B in subsets(Vp):
            if all(B&w for w in ws): best=min(best,sum(g[v] for v in B))
        return best
    sumEp=sum(g[F] for F in Ep)
    vd=all((beta(F) is None) or beta(F)>sumEp for F in Ep)
    allS=[S for S in subsets(V+E) if feasible(S)]
    val=lambda S: sum(g[x] for x in S)
    best=max(val(S) for S in allS)
    opts=[S for S in allS if abs(val(S)-best)<1e-12]
    Sstar=Vp|frozenset(F for F in Ep if feasible(Vp|{F}))
    stats['trials']+=1
    if vd:
        stats['vd']+=1
        zero=frozenset(x for x in V+E if g[x]==0)
        ok=feasible(Sstar) and abs(val(Sstar)-best)<1e-12 and all((S-zero)==Sstar for S in opts)
        if not ok: stats['viol']+=1; print("VIOL",g,wit,Sstar,opts); break
    else:
        # Prop 5.3: exists F in E+ with witness in V+ and beta<g_F  -> clean set not optimal
        for F in Ep:
            b=beta(F)
            if b is not None and b<g[F]:
                stats['sacrifice_trials']+=1
                if val(Sstar)<best-1e-12: stats['sac_ok']+=1
                else: stats['sac_viol']+=1; print("5.3 VIOL",g,wit,F,b,Sstar,best)
                break
print(stats)
