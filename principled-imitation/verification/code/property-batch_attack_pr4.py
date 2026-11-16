# Adversary's checks of Section 3 of research/prove-c/property-batch.md (Pr4: the batch estimators).
# Independent implementation; failure probabilities are EXACT (enumeration of all multinomial outcomes), not simulated.
# Pure Python.  Run:  python3 property-batch_attack_pr4.py > property-batch_attack_pr4.out
import math, random, itertools
from math import log, sqrt, exp, lgamma, comb
random.seed(20261115)
LN2 = log(2.0)
TOL = 1e-12

def tv(p, q): return 0.5*sum(abs(a-b) for a, b in zip(p, q))

def compositions(N, s):
    """all vectors of s nonnegative integers with sum N"""
    if s == 1:
        yield (N,); return
    for k in range(N+1):
        for rest in compositions(N-k, s-1):
            yield (k,) + rest

def multinomial_prob(counts, probs):
    lp = lgamma(sum(counts)+1)
    for c, p in zip(counts, probs):
        if c > 0:
            if p <= 0: return 0.0
            lp += c*log(p)
        lp -= lgamma(c+1)
    return exp(lp)

def yat(H, ties_to_first=False):
    """A[i][j] = indicator vector of {L_i > L_j} (or {L_i >= L_j} if ties_to_first)"""
    J, W = len(H), len(H[0])
    if ties_to_first:
        return [[[1 if (H[i][o] > H[j][o] or (H[i][o] == H[j][o] and i < j)) else 0 for o in range(W)] for j in range(J)] for i in range(J)]
    return [[[1 if H[i][o] > H[j][o] else 0 for o in range(W)] for j in range(J)] for i in range(J)]

def mass(p, ind): return sum(a for a, b in zip(p, ind) if b)

def rN(w, N, kappa): return sqrt((log(1/w) + kappa)/(2*N))

class Instance:
    def __init__(self, H, w, Q, ties_to_first=False):
        self.H, self.w, self.Q = H, w, Q
        self.J, self.W = len(H), len(Q)
        self.A = yat(H, ties_to_first)
        self.QA = [[mass(H[i], self.A[i][j]) for j in range(self.J)] for i in range(self.J)]   # Q_i(A_ij)
        self.TV = [tv(h, Q) for h in H]
        self.supp = [o for o in range(self.W) if Q[o] > 0]
    def outcomes(self, N):
        probs = [self.Q[o] for o in self.supp]
        for c in compositions(N, len(self.supp)):
            pr = multinomial_prob(c, probs)
            if pr == 0.0: continue
            emp = [0.0]*self.W
            for o, k in zip(self.supp, c): emp[o] = k/N
            yield pr, emp

def crit_3_4(inst, emp, N, kappa):
    """c_N(i) of Definition 3.4"""
    J = inst.J; r = [rN(inst.w[i], N, kappa) for i in range(J)]
    c = []
    for i in range(J):
        d = 0.0
        for j in range(J):
            if j != i: d = max(d, inst.QA[i][j] - mass(emp, inst.A[i][j]) - r[j])
        c.append(d + r[i])
    return c, r

def fail_3_6(inst, N, delta, kappa, eps_min):
    """exact Pr[ some eps-minimiser has TV > min_i(3 TV_i + 2 r_i) + 2s + eps ]"""
    r = [rN(inst.w[i], N, kappa) for i in range(inst.J)]
    s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N))
    bound = min(3*inst.TV[i] + 2*r[i] for i in range(inst.J)) + 2*s + eps_min
    f = 0.0
    for pr, emp in inst.outcomes(N):
        c, _ = crit_3_4(inst, emp, N, kappa)
        m = min(c)
        worst = max(inst.TV[i] for i in range(inst.J) if c[i] <= m + eps_min + TOL)
        if worst > bound + 1e-9: f += pr
    return f, bound

def rand_dist(W, lattice=None, zeros=0.0):
    if lattice:
        cuts = sorted(random.randrange(lattice+1) for _ in range(W-1))
        parts = [b-a for a, b in zip([0]+cuts, cuts+[lattice])]
        return [x/lattice for x in parts]
    g = [0.0 if random.random() < zeros else random.gammavariate(random.choice([0.3, 1.0, 3.0]), 1.0) for _ in range(W)]
    if sum(g) == 0: g[random.randrange(W)] = 1.0
    t = sum(g); return [x/t for x in g]

def rand_weights(J):
    mode = random.choice(["geom", "equal", "skew", "sub"])
    if mode == "geom": w = [2.0**-(i+1) for i in range(J)]
    elif mode == "equal": w = [1.0/J]*J
    elif mode == "skew": w = [0.9] + [0.1/(J-1)*random.uniform(0.01, 1) for _ in range(J-1)] if J > 1 else [1.0]
    else: w = [random.uniform(1e-4, 1.0/J) for _ in range(J)]
    random.shuffle(w); return w

# ---------------------------------------------------------------- (1) Theorem 3.6, exact, random search
print("(1) Theorem 3.6 (penalised one-sided minimum distance), exact failure probability over all samples;")
print("    'failure' = some eps-minimiser of c_N has TV(Q_est, Q) > min_i [3 TV(Q_i,Q) + 2 r_N(i)] + 2s + eps")
best = (0.0, None); cases = 0; positive = 0
for trial in range(2600):
    J = random.choice([2, 2, 3, 3, 4]); W = random.choice([2, 3, 4, 5])
    lat = random.choice([None, None, 4, 10])
    H = [rand_dist(W, lat, zeros=0.3) for _ in range(J)]
    if random.random() < 0.15: H[-1] = list(H[0])                      # two indices for one measure
    w = rand_weights(J)
    inclass = random.random() < 0.4
    if inclass: Q = list(H[random.randrange(J)])
    else:
        Q = rand_dist(W, lat, zeros=0.4)
    # keep the support of Q small so that the enumeration is exact and cheap
    supp = [o for o in range(W) if Q[o] > 0]
    if len(supp) > 3:
        keep = random.sample(supp, 3); Q = [Q[o] if o in keep else 0.0 for o in range(W)]; t = sum(Q); Q = [x/t for x in Q]
    N = random.choice([1, 2, 3, 5, 8, 12, 20, 30])
    delta = random.choice([0.9, 0.5, 0.2, 0.05])
    kappa = random.choice([log(2/delta), 0.0, 0.5*log(2/delta)])
    eps_min = random.choice([0.0, 0.0, 0.02, 0.2])
    inst = Instance(H, w, Q, ties_to_first=(random.random() < 0.3))
    f, b = fail_3_6(inst, N, delta, kappa, eps_min)
    cases += 1
    if f > 0: positive += 1
    if f/delta > best[0]: best = (f/delta, (J, W, N, delta, round(kappa, 3), eps_min, [round(x, 4) for x in w], [[round(x, 4) for x in h] for h in H], [round(x, 4) for x in Q]))
print(f"    {cases} random instances (2 to 4 hypotheses on 2 to 5 points, N <= 30, delta in {{0.9, 0.5, 0.2, 0.05}}, three choices of kappa,")
print(f"    eps in {{0, 0.02, 0.2}}, lattice probabilities and duplicated measures included): instances with a positive failure probability: {positive};")
print(f"    largest failure probability / delta = {best[0]:.4f}   (the theorem asserts <= 1)")
print(f"    attained at (J, W, N, delta, kappa, eps, w, H, Q) = {best[1]}")

# ---------------------------------------------------------------- (1b) hill climbing on the two-hypothesis family on {0,1}
def fail_two(p1, p2, q, w1, w2, N, delta, kappa):
    inst = Instance([[1-p1, p1], [1-p2, p2]], [w1, w2], [1-q, q])
    return fail_3_6(inst, N, delta, kappa, 0.0)[0]
bestr, bestarg = 0.0, None
for N in [1, 2, 3, 4, 6, 9, 14, 20, 30, 45]:
    for delta in [0.9, 0.5, 0.2, 0.05, 0.01]:
        for kappa in (log(2/delta), 0.0):
            for _ in range(60):
                p1, p2, q = random.random(), random.random(), random.random()
                w1 = random.choice([0.5, 0.9, 0.99, 0.1, 0.01]); w2 = min(1-w1, random.choice([0.5, 0.1, 0.01, 0.001]))
                cur = fail_two(p1, p2, q, w1, w2, N, delta, kappa)
                step = 0.2
                for it in range(40):
                    cand = [min(1, max(0, x + random.uniform(-step, step))) for x in (p1, p2, q)]
                    f = fail_two(cand[0], cand[1], cand[2], w1, w2, N, delta, kappa)
                    if f >= cur: (p1, p2, q), cur = cand, f
                    else: step *= 0.93
                if cur/delta > bestr: bestr, bestarg = cur/delta, (N, delta, round(kappa, 3), w1, w2, round(p1, 4), round(p2, 4), round(q, 4))
print(f"(1b) hill climbing over two hypotheses on {{0,1}} (N <= 45, delta down to 0.01, kappa = ln(2/delta) and 0): largest failure probability / delta = {bestr:.4f}")
print(f"     at (N, delta, kappa, w1, w2, p1, p2, q) = {bestarg}")

# ---------------------------------------------------------------- (2) Theorem 3.3, exact (human in the class; two-sided matching; product weights)
def fail_3_3(inst, i0, N, delta):
    J = inst.J; w = inst.w
    f = 0.0; nomatch = 0.0
    K = log(1/w[i0])/LN2
    bound_draft = sqrt((4*K*LN2 + 2*log(2/delta))/N)
    for pr, emp in inst.outcomes(N):
        match = []
        for i in range(J):
            ok = True
            for a in range(J):
                for b in range(J):
                    if a == b: continue
                    tolab = sqrt(log(2/(w[a]*w[b]*delta))/(2*N))
                    if abs(mass(inst.H[i], inst.A[a][b]) - mass(emp, inst.A[a][b])) > tolab + TOL: ok = False; break
                if not ok: break
            if ok: match.append(i)
        if i0 not in match: f += pr; nomatch += pr; continue
        wmax = max(w[i] for i in match)
        worst = max(inst.TV[i] for i in match if w[i] >= wmax - 1e-15)
        if worst > bound_draft + 1e-9: f += pr
    return f, nomatch
best = 0.0; arg = None; cnt = 0
for trial in range(900):
    J = random.choice([2, 3, 4]); W = random.choice([2, 3, 4])
    lat = random.choice([None, 4, 10])
    H = [rand_dist(W, lat, zeros=0.2) for _ in range(J)]
    w = rand_weights(J)
    if sum(w) > 1: t = sum(w); w = [x/t for x in w]
    i0 = random.randrange(J); Q = list(H[i0])
    if len([o for o in range(W) if Q[o] > 0]) > 3: continue
    N = random.choice([1, 2, 4, 8, 15, 30]); delta = random.choice([0.9, 0.5, 0.2, 0.05])
    inst = Instance(H, w, Q)
    f, nm = fail_3_3(inst, i0, N, delta); cnt += 1
    if f/delta > best: best, arg = f/delta, (J, W, N, delta, round(nm, 5))
print(f"(2) Theorem 3.3 (the draft's estimator), human in the class, no further tests, {cnt} random instances, exact:")
print(f"    largest Pr[the human's index does not match, or the highest-weight match has TV > sqrt((4K ln2 + 2 ln(2/delta))/N)] / delta = {best:.4f}  at (J, W, N, delta, Pr[human does not match]) = {arg}")

# ---------------------------------------------------------------- (3) Proposition 3.8, exact
def fail_3_8(inst, i0, N, delta):
    J = inst.J; w = inst.w; kappa = log(2/delta)
    r = [rN(w[i], N, kappa) for i in range(J)]
    f = 0.0
    for pr, emp in inst.outcomes(N):
        adm = [i for i in range(J) if all(inst.QA[i][j] - mass(emp, inst.A[i][j]) <= max(r[i], r[j]) + TOL for j in range(J) if j != i)]
        if i0 not in adm: f += pr; continue
        wmax = max(w[i] for i in adm)
        worst = max(inst.TV[i] for i in adm if w[i] >= wmax - 1e-15)
        if worst > 2*r[i0] + 1e-9: f += pr
    return f
best = 0.0; arg = None; cnt = 0
for trial in range(900):
    J = random.choice([2, 3, 4]); W = random.choice([2, 3, 4])
    lat = random.choice([None, 4, 10])
    H = [rand_dist(W, lat, zeros=0.2) for _ in range(J)]
    w = rand_weights(J)
    if sum(w) > 1: t = sum(w); w = [x/t for x in w]
    i0 = random.randrange(J); Q = list(H[i0])
    if len([o for o in range(W) if Q[o] > 0]) > 3: continue
    N = random.choice([1, 2, 4, 8, 15, 30]); delta = random.choice([0.9, 0.5, 0.2, 0.05])
    inst = Instance(H, w, Q)
    f = fail_3_8(inst, i0, N, delta); cnt += 1
    if f/delta > best: best, arg = f/delta, (J, W, N, delta)
print(f"(3) Proposition 3.8 (highest-weight admissible index), human in the class, {cnt} random instances, exact:")
print(f"    largest Pr[the human's index is not admissible, or the estimate has TV > 2 r_N(human)] / delta = {best:.4f}  at (J, W, N, delta) = {arg}")

# ---------------------------------------------------------------- (4) Example 3.11(a), exact; and a rule that uses all of the empirical measure
print("(4) Example 3.11(a) (the factor 3), exact binomial computation:")
for e0 in (0.05, 0.01):
    H = [[0.0, 0.25+e0, 0.5, 0.25-e0], [0.5+e0, 0.25-e0, 0.0, 0.25]]; Q = [0.5, 0.5, 0.0, 0.0]
    inst = Instance(H, [0.5, 0.5], Q)
    for N in (11, 101, 1001):
        p_far = 0.0; p_far_mintv = 0.0
        for pr, emp in inst.outcomes(N):
            c, _ = crit_3_4(inst, emp, N, log(2/0.1))
            if c[0] < c[1] - TOL: p_far += pr
            # the rule "the member closest in total variation to the empirical measure" (it does not look at Yatracos sets only)
            if tv(H[0], emp) < tv(H[1], emp) - TOL: p_far_mintv += pr
        print(f"    eps0 = {e0}: TV(nu1,Q) = {inst.TV[0]:.3f}, TV(nu2,Q) = {inst.TV[1]:.3f}, ratio {inst.TV[0]/inst.TV[1]:.3f}; N = {N:5d}: "
              f"Pr[Definition 3.4 returns the far one] = {p_far:.6f};  Pr[the member nearest to the empirical measure is the far one] = {p_far_mintv:.2e}")

# ---------------------------------------------------------------- (5) Example 3.11(b): the replay of the data
print("(5) Example 3.11(b) (replay of the data), u answers, human uniform, the hypotheses 'uniform on a set S of N answers':")
for (u, N) in ((60, 3), (2000, 3), (10**6, 5)):
    delta = 0.1; kappa = log(2/delta)
    wQ = 0.5; wS = 0.5/comb(u, N)
    rQ = rN(wQ, N, kappa); rS = rN(wS, N, kappa)
    # data = N distinct answers, S = their set.  U(Q_S, .) = 0;  U(Q, Q_S) = 1 - N/u.
    # with r = 0 (no penalty): c(Q_S) = 0 < c(Q) = 1 - N/u.   with penalties: c(Q_S) >= r(Q_S); c(Q) <= 1 + r(Q).
    cS_lower = rS; cQ_upper = 1.0 + rQ
    print(f"    u = {u}, N = {N}: Pr[all answers distinct] = {math.prod((u-i)/u for i in range(N)):.4f}; without penalty the replay has criterion 0 and TV {1-N/u:.4f} from the human;"
          f" with penalty r(Q_S) = {rS:.3f} against 1 + r(Q) = {cQ_upper:.3f}: replay excluded: {cS_lower > cQ_upper}; the file's condition u > N e^(2(1+r(Q))^2) = {N*exp(2*(1+rQ)**2):.0f}: {u > N*exp(2*(1+rQ)**2)}")

# ---------------------------------------------------------------- (6) Example 3.11(c): outside the class nothing matches
print("(6) Example 3.11(c): two hypotheses with nu(1) = 1/4, 3/4, human Q(1) = 1/2, exact:")
inst = Instance([[0.75, 0.25], [0.25, 0.75]], [0.5, 0.5], [0.5, 0.5])
for N in (10, 40, 160, 640):
    delta = 0.1; nomatch = 0.0; noadm = 0.0
    r = rN(0.5, N, log(2/delta)); tolab = sqrt(log(2/(0.25*delta))/(2*N))
    for pr, emp in inst.outcomes(N):
        m = [i for i in range(2) if all(abs(mass(inst.H[i], inst.A[a][b]) - mass(emp, inst.A[a][b])) <= tolab for a in range(2) for b in range(2) if a != b)]
        ad = [i for i in range(2) if inst.QA[i][1-i] - mass(emp, inst.A[i][1-i]) <= r]
        if not m: nomatch += pr
        if not ad: noadm += pr
    print(f"    N = {N:4d}: Pr[no index matches (Theorem 3.3)] = {nomatch:.4f};  Pr[no index is admissible (Proposition 3.8)] = {noadm:.4f}")

# ---------------------------------------------------------------- (7) a human who keeps state within a run, against stateless hypotheses
print("(7) A human who is consistent within a run (scaffold: the same question twice; the human answers a fair bit and repeats it):")
best = min((0.5*(abs(p*p-0.5) + 2*p*(1-p) + abs((1-p)**2-0.5)), p) for p in [i/100000 for i in range(100001)])
print(f"    run law of the human: (0,0) and (1,1) with probability 1/2 each; best stateless sampler: p = {best[1]:.5f}, TV = {best[0]:.5f} (= sqrt(2) - 1 = {sqrt(2)-1:.5f});")
print(f"    the approximation term of Theorem 3.6 is 3 x {best[0]:.4f} = {3*best[0]:.4f} > 1: the oracle inequality is empty for every class of stateless samplers.")

# ---------------------------------------------------------------- (8) Theorem 3.10 with simulations that share their randomness (common random numbers)
def emp_from_uniforms(P, us):
    W = len(P); c = [0]*W
    for u in us:
        acc = 0.0
        for o in range(W):
            acc += P[o]
            if u < acc or o == W-1: c[o] += 1; break
    n = len(us); return [x/n for x in c]
fails = 0; trials = 3000; delta = 0.1; N = 60; Ns = 60; kappa = log(2/delta)
for t in range(trials):
    J, W = 5, 4
    H = [rand_dist(W) for _ in range(J)]; w = [2.0**-(i+1) for i in range(J)]
    Q = rand_dist(W) if t % 2 else list(H[random.randrange(J)])
    inst = Instance(H, w, Q)
    emp = emp_from_uniforms(Q, [random.random() for _ in range(N)])
    us = [random.random() for _ in range(Ns)]                               # ONE set of uniforms for all hypotheses
    sims = [emp_from_uniforms(H[i], us) for i in range(J)]
    rt = [rN(w[i], N, kappa) + rN(w[i], Ns, kappa) for i in range(J)]
    c = []
    for i in range(J):
        d = 0.0
        for j in range(J):
            if j != i: d = max(d, mass(sims[i], inst.A[i][j]) - mass(emp, inst.A[i][j]) - rt[j])
        c.append(d + rt[i])
    est = min(range(J), key=lambda i: c[i])
    bound = min(3*inst.TV[i] + 2*rt[i] for i in range(J))
    if inst.TV[est] > bound + 1e-9: fails += 1
print(f"(8) Theorem 3.10 with all simulations driven by one shared set of random numbers (N = N_s = 60, 5 hypotheses, {trials} trials): failures {fails} (allowed {2*delta:.0%})")
