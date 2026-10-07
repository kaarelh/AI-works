"""T6 check 3: completeness of a monotone multi-context calculus (MC) w.r.t. local-models
(belief-state / chain) semantics, by brute force; and the gap to world-family (pointwise) semantics.
Each context has 2 atoms -> 4 local models; a formula is identified with its set of local models
(a 4-bit mask; the local logic is classical propositional, hence locally complete)."""
import itertools, random
NM = 4                      # local models per context
ALL = (1 << NM) - 1         # the formula 'top'

def entails(prem_masks, concl):
    m = ALL
    for p in prem_masks: m &= p
    return (m & ~concl) == 0

def mc_closure(I, K, bridges, Gamma):
    """Syntactic closure: Th[i] = set of formulas derivable at i (local rules + bridges)."""
    Th = {i: set() for i in I}
    for i in I:
        Th[i] |= set(K[i]) | set(Gamma.get(i, []))
    while True:
        # local closure
        for i in I:
            Th[i] = {psi for psi in range(1 << NM) if entails(Th[i], psi)}
        new = False
        for (prem, (i, psi)) in bridges:
            if all(phi in Th[j] for (j, phi) in prem) and psi not in Th[i]:
                Th[i].add(psi); new = True
        if not new:
            return Th

def chains(I, K, bridges, Gamma, pointwise=False):
    """All bridge-compatible chains satisfying K and Gamma.  c[i] is a set of local models (mask)."""
    choices = []
    for i in I:
        allowed = ALL
        for phi in list(K[i]) + list(Gamma.get(i, [])): allowed &= phi
        if pointwise:
            opts = [1 << b for b in range(NM) if allowed >> b & 1]
        else:
            opts = [s for s in range(1 << NM) if (s & ~allowed) == 0]
        choices.append(opts)
    for combo in itertools.product(*choices):
        c = dict(zip(I, combo))
        ok = True
        for (prem, (i, psi)) in bridges:
            if all((c[j] & ~phi) == 0 for (j, phi) in prem) and (c[i] & ~psi) != 0:
                ok = False; break
        if ok:
            yield c

random.seed(7)
I = [0, 1, 2]
mismatch_bs = 0; diff_pw = 0; trials = 400
for t in range(trials):
    K = {i: [random.randrange(1, 1 << NM) for _ in range(random.randint(0, 1))] for i in I}
    bridges = []
    for _ in range(random.randint(1, 4)):
        prem = [(random.choice(I), random.randrange(1 << NM)) for _ in range(random.randint(1, 2))]
        bridges.append((prem, (random.choice(I), random.randrange(1 << NM))))
    Gamma = {i: [random.randrange(1, 1 << NM)] for i in I if random.random() < 0.4}
    Th = mc_closure(I, K, bridges, Gamma)
    CH = list(chains(I, K, bridges, Gamma))
    PW = list(chains(I, K, bridges, Gamma, pointwise=True))
    for i in I:
        for phi in range(1 << NM):
            sem = all((c[i] & ~phi) == 0 for c in CH)
            pw = all((c[i] & ~phi) == 0 for c in PW)
            if sem != (phi in Th[i]): mismatch_bs += 1
            if pw != sem: diff_pw += 1
    # coherence <-> existence of a chain with nonempty components at designated contexts
    D = [i for i in I if random.random() < 0.6]
    syn_coh = all(0 not in Th[i] for i in D)          # 0 = empty mask = 'bottom'
    sem_coh = any(all(c[i] != 0 for i in D) for c in CH)
    assert syn_coh == sem_coh
print("MC completeness (belief-state semantics): mismatches = %d over %d random systems" % (mismatch_bs, trials))
print("D-coherence <-> existence of chain nonempty on D: OK")
print("pointwise (world-family) entailment differs from belief-state entailment in %d (context,formula) cases" % diff_pw)

# the disjunction example: K_j = {p or q}; bridges j:p => i:r, j:q => i:r; K_i = {not r}
# local models of a context with atoms (x,y): bit b = 2*x + y.  p = first atom, q = second atom.
p = sum(1 << b for b in range(4) if b >> 1 & 1); q = sum(1 << b for b in range(4) if b & 1)
r = p; notr = ALL & ~r
I2 = [0, 1]  # 0 = j, 1 = i
K2 = {0: [p | q], 1: [notr]}
br = [([(0, p)], (1, r)), ([(0, q)], (1, r))]
Th = mc_closure(I2, K2, br, {})
print("disjunction example: MC derives i:bottom?", 0 in Th[1],
      "| a belief-state model with c_i nonempty exists?", any(c[1] != 0 for c in chains(I2, K2, br, {})),
      "| a world-family model exists?", any(True for _ in chains(I2, K2, br, {}, pointwise=True)))
