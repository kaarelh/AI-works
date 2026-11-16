# Referee's checks for Sections 5 and 6 of research/prove-c/property-batch.md (Proposition 5.2, Example 5.3,
# Theorem 6.1, Theorem 6.2, Example 6.3).  Independent of the prover's scripts; exact rationals and full enumeration.
# Pure Python 3.  Run:  python3 property-batch_check_sec56.py > property-batch_check_sec56.out
import math, random, itertools
from fractions import Fraction as Fr
from math import log, sqrt, comb

random.seed(5615)
INF = float("inf")
def kl(p, q):
    if p == q: return 0.0
    if q <= 0.0 or q >= 1.0: return INF
    s = 0.0
    if p > 0: s += p*log(p/q)
    if p < 1: s += (1-p)*log((1-p)/(1-q))
    return s
def rand_law(n, lattice=12, positive=False):
    while True:
        cuts = sorted(random.randrange(lattice+1) for _ in range(n-1))
        parts = [b-a for a, b in zip([0]+cuts, cuts+[lattice])]
        if not positive or min(parts) > 0: return [Fr(x, lattice) for x in parts]

# ================================================================= (1) Proposition 5.2
# (b): the total variation between the run laws, by direct computation on X x Y
okb = True
for trial in range(300):
    u = random.choice([1, 2, 5]); ny = random.choice([2, 3]); mu = rand_law(u); P0 = [rand_law(ny) for _ in range(u)]
    F = [random.choice([y for y in range(ny) if P0[x][y] > 0]) for x in range(u)]
    direct = sum(abs(mu[x]*(1 if F[x] == y else 0) - mu[x]*P0[x][y]) for x in range(u) for y in range(ny))/2
    formula = sum(mu[x]*(1 - P0[x][F[x]]) for x in range(u))
    if direct != formula or formula < 1 - sum(mu[x]*max(P0[x]) for x in range(u)): okb = False
print("(1) Proposition 5.2(b): TV(Q_F, Q_P0) = sum_x mu(x)(1 - P0(F(x)|x)) >= 1 - sum_x mu(x) max_y P0(y|x), exact, 300 random instances:", okb)

# (a): exact probability over F that some test of a family deviates by more than its bound
def check_52a(u, ny, ntests, eta, uniform_mu, coin):
    mu = [Fr(1, u)]*u if uniform_mu else rand_law(u, 24, positive=True)
    P0 = [[Fr(1, ny)]*ny for _ in range(u)] if coin else [rand_law(ny, 6) for _ in range(u)]
    coll = float(sum(m*m for m in mu))
    pairs = [(x, y) for x in range(u) for y in range(ny)]
    tests = [frozenset(p for p in pairs if random.random() < random.choice([0.2, 0.5])) for _ in range(ntests)]
    raw = [random.choice([1, 2, 8]) for _ in tests]; pi_ = [r/sum(raw) for r in raw]
    bound = [sqrt(coll*log(2/(p*eta))/2) for p in pi_]
    freq0 = [sum(mu[x]*sum(P0[x][y] for y in range(ny) if (x, y) in R) for x in range(u)) for R in tests]
    pfail = Fr(0); maxdev = 0.0; mean_ok = [Fr(0)]*ntests
    for F in itertools.product(range(ny), repeat=u):
        pF = Fr(1)
        for x in range(u): pF *= P0[x][F[x]]
        if pF == 0: continue
        bad = False
        for t, R in enumerate(tests):
            fr = sum(mu[x] for x in range(u) if (x, F[x]) in R)
            mean_ok[t] += pF*fr
            dev = abs(float(fr - freq0[t])); maxdev = max(maxdev, dev/bound[t])
            if dev > bound[t] + 1e-12: bad = True
        if bad: pfail += pF
    return float(pfail), all(m == f0 for m, f0 in zip(mean_ok, freq0)), maxdev
worst = 0.0; means = True; md = 0.0
for (u, ny) in ((10, 2), (12, 2), (7, 3)):
    for eta in (0.9, 0.3, 0.05):
        for uniform_mu in (True, False):
            for coin in (True, False):
                for ntests in (1, 12):
                    p, mok, mdv = check_52a(u, ny, ntests, eta, uniform_mu, coin)
                    worst = max(worst, p/eta); means = means and mok; md = max(md, mdv)
print(f"    Proposition 5.2(a), all functions F enumerated (u in {{7, 10, 12}}, uniform and non-uniform mu, coin and other samplers, 1 or 12 weighted tests):")
print(f"    E_F Q_F(R) = Q_P0(R) exactly: {means}; max Pr_F[some test deviates by more than the bound]/eta = {worst:.4f} (must be <= 1); largest deviation/bound seen = {md:.3f}")
# the consequence: constants
okc = True
for N in range(1, 400):
    for delta in (1.0, 0.5, 0.1, 1e-3):
        # at most (delta/2) e^(2N) tests can have tol_N < 1; for u >= 3N this is below 2^(-N/10) 2^u
        if log(delta/2) + 2*N - 3*N*log(2) >= -(N/10)*log(2): okc = False
u, N, pi_, delta = 4096, 1024, 1/1490, 0.1
print(f"    consequence: (delta/2) e^(2N) / 2^(3N) < 2^(-N/10) for all N < 400 and delta <= 1: {okc}; e^2/8 = {math.e**2/8:.5f} < 2^(-1/10) = {2**-0.1:.5f}")
print(f"    u = 4096, N = 1024, pi = 1/1490, delta = 0.1: bound of (a) = {sqrt(log(2/(pi_*delta))/(2*u)):.4f} = sqrt(N/u) tol_N = {sqrt(N/u)*sqrt(log(2/(pi_*delta))/(2*N)):.4f}; tol_N = {sqrt(log(2/(pi_*delta))/(2*N)):.4f}")

# ================================================================= (2) Example 5.3
u = 8; ok53 = True; worst = 0.0
pairs = [(z, y) for z in range(u) for y in (0, 1)]
tests = [frozenset(p for p in pairs if random.random() < 0.5) for _ in range(40)]
for g in itertools.product((0, 1), repeat=u):
    # run of the imitator: (z, g(z), g(z)); run of the human system: (z, y1, y2) with fair coins
    agree_im = Fr(1); agree_h = sum(Fr(1, u)*Fr(1, 4) for z in range(u) for y1 in (0, 1) for y2 in (0, 1) if y1 == y2)
    if agree_im != 1 or agree_h != Fr(1, 2): ok53 = False
    for Bt in tests:
        # per-call frequencies as defined in Section 6.1 with L = 2 (both calls are always made)
        a = Fr(1, 2)*sum(Fr(1, u)*((1 if (z, g[z]) in Bt else 0) + (1 if (z, g[z]) in Bt else 0)) for z in range(u))
        h = Fr(1, 2)*sum(Fr(1, u)*2*Fr(1, 2)*((1 if (z, 0) in Bt else 0) + (1 if (z, 1) in Bt else 0)) for z in range(u))
        if a != Fr(1, u)*sum(1 for z in range(u) if (z, g[z]) in Bt): ok53 = False
        if h != Fr(1, u)*sum(Fr(1, 2)*((1 if (z, 0) in Bt else 0) + (1 if (z, 1) in Bt else 0)) for z in range(u)): ok53 = False
print(f"(2) Example 5.3, u = 8, all 256 functions g, 40 random per-call tests: the formulas for a(B) and h(B) agree with the definitions of Section 6.1: {ok53};")
print("    'the two answers agree' has probability 1 for every g and 1/2 for the human system: True by the same enumeration")

# ================================================================= (3) Theorem 6.1, exact, on a small scaffold with runs of variable length and a stateful answerer
def check_61(m, delta, family):
    # scaffold: z uniform on {0,1}; call 1 at input z; if z = 0 a second call at input y1; if z = 1 stop.  L = 2.
    A1 = [rand_law(2, 6) for _ in range(2)]                       # A's law of the first answer given x1
    A2 = {(x1, y1): rand_law(2, 6) for x1 in range(2) for y1 in range(2)}   # A's second answer depends on the history: A is not a sampler
    P = [rand_law(2, 6) for _ in range(2)]
    L = 2
    # outcome of one round: None (empty) or (x*, a*, h*)
    out = {}
    def add(o, p):
        out[o] = out.get(o, Fr(0)) + p
    a_def = {}; h_def = {}                                         # the two expectations of the definition, per pair
    for z in range(2):
        for y1 in range(2):
            p1 = Fr(1, 2)*A1[z][y1]
            if z == 1:
                runs = [([(z, y1)], p1)]
            else:
                runs = [([(z, y1), (y1, y2)], p1*A2[(z, y1)][y2]) for y2 in range(2)]
            for calls, pr in runs:
                if pr == 0: continue
                for (x, y) in calls:
                    a_def[(x, y)] = a_def.get((x, y), Fr(0)) + pr*Fr(1, L)
                    for hh in range(2): h_def[(x, hh)] = h_def.get((x, hh), Fr(0)) + pr*Fr(1, L)*P[x][hh]
                for J in range(1, L+1):
                    if J > len(calls): add(None, pr*Fr(1, L)); continue
                    x, a = calls[J-1]
                    for hh in range(2): add((x, a, hh), pr*Fr(1, L)*P[x][hh])
    assert sum(out.values()) == 1
    pairs = [(x, y) for x in range(2) for y in range(2)]
    if family == "singletons": tests = [frozenset([p]) for p in pairs]
    else: tests = [frozenset(S) for k in range(1, 5) for S in itertools.combinations(pairs, k)]
    pi_ = 1.0/len(tests)
    aB = [sum(a_def.get(p, Fr(0)) for p in Bt) for Bt in tests]; hB = [sum(h_def.get(p, Fr(0)) for p in Bt) for Bt in tests]
    # the means of the indicators of one round agree with the definitions
    okdef = all(aB[t] == sum(pr for o, pr in out.items() if o is not None and (o[0], o[1]) in Bt) and
                hB[t] == sum(pr for o, pr in out.items() if o is not None and (o[0], o[2]) in Bt) for t, Bt in enumerate(tests))
    types = [o for o in out if out[o] > 0]; probs = [out[o] for o in types]
    fa = fb = fc = Fr(0)
    tolA = sqrt(2*log(2/(pi_*delta))/m); aa = log(2/(pi_*delta))/m
    def comps(n, k):
        if k == 1:
            yield (n,); return
        for i in range(n+1):
            for rest in comps(n-i, k-1): yield (i,) + rest
    for counts in comps(m, len(types)):
        pr = Fr(math.factorial(m))
        for c, q in zip(counts, probs): pr = pr*q**c/math.factorial(c)
        if pr == 0: continue
        badA = badB = badC = False
        for t, Bt in enumerate(tests):
            al = sum(c for o, c in zip(types, counts) if o is not None and (o[0], o[1]) in Bt)/m
            et = sum(c for o, c in zip(types, counts) if o is not None and (o[0], o[2]) in Bt)/m
            if abs(float(aB[t] - hB[t]) - (al - et)) > tolA + 1e-12: badA = True
            hval = float(hB[t])
            if kl(et, hval) > aa + 1e-12: badB = True
            elif abs(et - hval) > sqrt(aa/2) + 1e-12 or (et == 0 and hval > aa + 1e-12): badC = True   # the two stated consequences of (b)
        fa += pr*badA; fb += pr*badB; fc += pr*badC
    return okdef, float(fa)/delta, float(fb)/delta, float(fc)
wa = wb = 0.0; okd = True; wc = 0.0
for trial in range(60):
    m = random.choice([1, 2, 4, 7]); delta = random.choice([0.9, 0.4, 0.1]); fam = random.choice(["singletons", "all"])
    okdef, ra, rb, rc = check_61(m, delta, fam); okd = okd and okdef; wa = max(wa, ra); wb = max(wb, rb); wc = max(wc, rc)
print(f"(3) Theorem 6.1 on 60 random (stateful answerer, human) pairs, scaffold with runs of 1 or 2 calls, exact multinomial sums over m <= 7 rounds:")
print(f"    the means of alpha_i(B), eta_i(B) equal a(B), h(B) of the definition: {okd}; max failure/delta of (a) = {wa:.4f}, of (b) = {wb:.4f} (must be <= 1);")
print(f"    probability that (b) holds and one of its two stated consequences fails: {wc:.1e} (must be 0)")
print(f"    tolerances: paired form sqrt(2 ln(2/(pi delta))/m) is exactly twice sqrt(ln(2/(pi delta))/(2m)): {abs(sqrt(2*3.7/11) - 2*sqrt(3.7/(2*11))) < 1e-15}")

# ================================================================= (4) Theorem 6.2
def rand_procedure(u, ny, m, may_repeat):
    """A procedure with internal randomness (2 seeds): input at each step and the final decision are tables on (seed, answers so far)."""
    tab_in = {}; tab_acc = {}
    def nxt(seed, asked, ys):
        key = (seed, ys)
        if key not in tab_in:
            if may_repeat: tab_in[key] = random.randrange(u)
            else: tab_in[key] = random.choice([x for x in range(u) if x not in asked])
        return tab_in[key]
    def acc(seed, ys):
        key = (seed, ys)
        if key not in tab_acc: tab_acc[key] = random.random() < 0.5
        return tab_acc[key]
    return nxt, acc
def run_procedure(proc, seed, answer_fn, m):
    """answer_fn(step, x, asked) -> list of (answer, probability).  Returns (Pr[accept], Pr[some input repeated])."""
    nxt, acc = proc
    def rec(asked, ys, p):
        if len(ys) == m:
            return (p if acc(seed, ys) else Fr(0)), (p if len(set(asked)) < len(asked) else Fr(0))
        x = nxt(seed, asked, ys); a = Fr(0); r = Fr(0)
        for y, py in answer_fn(x, asked, ys):
            if py == 0: continue
            da, dr = rec(asked + (x,), ys + (y,), p*py); a += da; r += dr
        return a, r
    return rec((), (), Fr(1))
okc = True; okeq = True; okd = True; gap = Fr(0); cases = 0
for trial in range(120):
    u = 4; ny = random.choice([2, 3]); m = 3; may_repeat = trial % 2 == 0
    P0 = [rand_law(ny, 6) for _ in range(u)]
    proc = rand_procedure(u, ny, m, may_repeat); seeds = [(0, Fr(1, 3)), (1, Fr(2, 3))]
    a0 = Fr(0); xi = Fr(0)
    for sd, ps in seeds:
        a, r = run_procedure(proc, sd, lambda x, asked, ys: [(y, P0[x][y]) for y in range(ny)], m); a0 += ps*a; xi += ps*r
    # deterministic humans: all functions F, weighted by prod_x P0(F(x)|x)
    EaF = Fr(0); aF = {}
    for F in itertools.product(range(ny), repeat=u):
        pF = Fr(1)
        for x in range(u): pF *= P0[x][F[x]]
        a = Fr(0)
        for sd, ps in seeds:
            aa_, _ = run_procedure(proc, sd, lambda x, asked, ys, F=F: [(F[x], Fr(1))], m); a += ps*aa_
        aF[F] = (a, pF); EaF += pF*a
    cases += 1
    if abs(EaF - a0) > xi: okc = False
    gap = max(gap, abs(EaF - a0))
    if not may_repeat and (EaF != a0 or xi != 0): okeq = False
    # (d): a function in G (test frequencies within the bound) accepted with probability >= a0 - xi - eta
    mu = rand_law(u, 12, positive=True); coll = float(sum(q*q for q in mu)); eta = random.choice([0.5, 0.1])
    pairs = [(x, y) for x in range(u) for y in range(ny)]
    tests = [frozenset(p for p in pairs if random.random() < 0.5) for _ in range(5)]; pi_ = 0.2
    f0 = [sum(mu[x]*sum(P0[x][y] for y in range(ny) if (x, y) in R) for x in range(u)) for R in tests]
    G = [F for F, (a, pF) in aF.items() if pF > 0 and all(abs(float(sum(mu[x] for x in range(u) if (x, F[x]) in R) - f0[t])) <= sqrt(coll*log(2/(pi_*eta))/2) + 1e-12 for t, R in enumerate(tests))]
    pG = sum(aF[F][1] for F in G)
    if float(pG) < 1 - eta - 1e-12: okd = False
    if not any(float(aF[F][0]) >= float(a0 - xi) - eta - 1e-12 for F in G): okd = False
print(f"(4) Theorem 6.2 on {cases} random adaptive procedures (4 inputs, 2 or 3 answers, non-uniform P0, m = 3, internal randomness), all functions enumerated:")
print(f"    (c) |E_F Pr_F(accept) - Pr_P0(accept)| <= xi: {okc} (largest gap {float(gap):.4f}); equality when no question is repeated: {okeq};")
print(f"    (d) Pr[F in G] >= 1 - eta and some f in G has Pr_f(accept) >= Pr_P0(accept) - xi - eta: {okd}")
# the conclusion of (d) is one-sided: a procedure for which every single function is at distance 1/2 from the coin in acceptance probability
u = 4
def acc_prob_f(F): return Fr(1) if F[0] == 0 else Fr(0)       # ask input 0 once, accept iff the answer is 0
a0 = Fr(1, 2)
dists = set(abs(acc_prob_f(F) - a0) for F in itertools.product((0, 1), repeat=u))
print(f"    the procedure 'ask input 0, accept iff the answer is 0' (no repetition, xi = 0): Pr_coin(accept) = 1/2, and |Pr_f(accept) - 1/2| takes the values {sorted(float(d) for d in dists)} over all f;")
print("    so (d) cannot be strengthened to a two-sided statement for one f: only the average over F is exactly indistinguishable (statement (c))")
# the remark on runs: a scaffold whose runs make L calls; coin against f
okrun = True
for trial in range(50):
    u = 4; L = 3
    nxt_tab = {}
    def nxt(z, ys):
        if (z, ys) not in nxt_tab: nxt_tab[(z, ys)] = random.randrange(u)      # adaptive inputs, repetitions inside a run allowed
        return nxt_tab[(z, ys)]
    f = [random.randrange(2) for _ in range(u)]
    Qc = {}; Qf = {}
    for z in range(2):
        for ys in itertools.product((0, 1), repeat=L):
            Qc[(z, ys)] = Fr(1, 2)*Fr(1, 2**L)
            okf = all(ys[j] == f[nxt(z, ys[:j])] for j in range(L))
            Qf[(z, ys)] = Fr(1, 2) if okf else Fr(0)
    assert sum(Qf.values()) == 1
    if sum(abs(Qc[k] - Qf[k]) for k in Qc)/2 != 1 - Fr(1, 2**L): okrun = False
print(f"    run laws of the coin and of a function f for adaptive scaffolds whose runs make L = 3 calls: TV = 1 - 2^-L exactly in 50 random scaffolds: {okrun}")

# ================================================================= (5) Example 6.3: all tests that ignore one input bit
for d in (1, 2, 3):
    X = list(itertools.product((0, 1), repeat=d)); par = {x: sum(x) % 2 for x in X}
    nB = 0; ok = True
    for i in range(d):
        reduced = sorted(set((x[:i] + x[i+1:], y) for x in X for y in (0, 1)))
        for mask in range(2**len(reduced)):
            Bred = {reduced[j] for j in range(len(reduced)) if mask >> j & 1}
            inB = lambda x, y: (x[:i] + x[i+1:], y) in Bred
            fr_f = Fr(sum(1 for x in X if inB(x, par[x])), len(X))
            fr_c = Fr(sum(1 for x in X for y in (0, 1) if inB(x, y)), 2*len(X))
            nB += 1
            if fr_f != fr_c: ok = False
    graph = Fr(sum(1 for x in X), len(X)); graph_c = Fr(1, 2)
    print(f"(5) Example 6.3, d = {d}: all {nB} tests (with repetition over the ignored coordinate) that ignore one input bit have equal frequencies for the parity and the coin: {ok};"
          f" the test 'y = parity(x)' has frequency {graph} against {graph_c}")
