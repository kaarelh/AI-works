import itertools, random, sys
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T6-checks')
NM = 4; ALL = (1 << NM) - 1
def entails(prem, concl):
    m = ALL
    for p in prem: m &= p
    return (m & ~concl) == 0
def mc_closure(I, K, bridges, Gamma):
    Th = {i: set(K[i]) | set(Gamma.get(i, [])) for i in I}
    while True:
        for i in I:
            Th[i] = {psi for psi in range(1 << NM) if entails(Th[i], psi)}
        new = False
        for (prem, (i, psi)) in bridges:
            if all(phi in Th[j] for (j, phi) in prem) and psi not in Th[i]:
                Th[i].add(psi); new = True
        if not new: return Th
def closed_from_mask(m):  # theory with model set m
    return frozenset(psi for psi in range(1 << NM) if (m & ~psi) == 0)
def chains(I, K, bridges, Gamma, pointwise=False):
    choices = []
    for i in I:
        allowed = ALL
        for phi in list(K[i]) + list(Gamma.get(i, [])): allowed &= phi
        opts = [1 << b for b in range(NM) if allowed >> b & 1] if pointwise else [s for s in range(1 << NM) if (s & ~allowed) == 0]
        choices.append(opts)
    for combo in itertools.product(*choices):
        c = dict(zip(I, combo)); ok = True
        for (prem, (i, psi)) in bridges:
            if all((c[j] & ~phi) == 0 for (j, phi) in prem) and (c[i] & ~psi) != 0: ok = False; break
        if ok: yield c

random.seed(12345)
I = [0, 1, 2]
bad43 = 0; bad45a = 0; strict = 0; nonleast_eq = 0; trials = 300
for t in range(trials):
    K = {i: [random.randrange(1, 1 << NM) for _ in range(random.randint(0, 1))] for i in I}
    bridges = []
    for _ in range(random.randint(1, 5)):
        prem = [(random.choice(I), random.randrange(1 << NM)) for _ in range(random.randint(0, 2))]
        bridges.append((prem, (random.choice(I), random.randrange(1 << NM))))
    Gamma = {i: [random.randrange(1, 1 << NM)] for i in I if random.random() < 0.4}
    Th = mc_closure(I, K, bridges, Gamma)
    # Prop 4.3: enumerate all belief states of closed theories (one mask per context)
    eqs = []
    for ms in itertools.product(range(1 << NM), repeat=len(I)):
        S = {i: closed_from_mask(ms[k]) for k, i in enumerate(I)}
        ok = True
        for i in I:
            gens = set(K[i]) | set(Gamma.get(i, []))
            for (prem, (h, psi)) in bridges:
                if h == i and all(phi in S[j] for (j, phi) in prem): gens.add(psi)
            m = ALL
            for g in gens: m &= g
            if closed_from_mask(m) != S[i]: ok = False; break
        if ok: eqs.append(S)
    T = {i: frozenset(Th[i]) for i in I}
    if T not in eqs: bad43 += 1
    for S in eqs:
        if not all(T[i] <= S[i] for i in I): bad43 += 1
        if S != T: nonleast_eq += 1
    for D in [ [i for i in I if (mask >> i) & 1] for mask in range(8)]:
        coh = all(0 not in T[i] for i in D)
        ex = any(all(0 not in S[i] for i in D) for S in eqs)
        if coh != ex: bad43 += 1
    # Thm 4.5(a) direction
    CH = list(chains(I, K, bridges, Gamma)); PW = list(chains(I, K, bridges, Gamma, True))
    for i in I:
        for phi in range(1 << NM):
            sem = all((c[i] & ~phi) == 0 for c in CH)
            pw = all((c[i] & ~phi) == 0 for c in PW)
            if sem and not pw: bad45a += 1
            if pw and not sem: strict += 1
print("Prop 4.3 violations:", bad43, "| non-least equilibria seen:", nonleast_eq)
print("Thm 4.5(a) violations (LMS entails but W does not):", bad45a, "| strict-gap cases:", strict)

# direction check on the original script's count
