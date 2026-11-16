# Referee's checks for Section 3 of research/prove-c/property-batch.md (Pr4: Theorem 3.3, Lemma 3.5, Theorem 3.6,
# Corollary 3.7, Propositions 3.8 and 3.9, Theorem 3.10, Examples 3.11).  Independent of the prover's scripts:
# the estimators are re-implemented from the definitions, hypotheses are exact rationals (so ties are decided exactly),
# and failure probabilities are exact multinomial sums wherever the sample space is small.
# Pure Python 3.  Run:  python3 property-batch_check_sec3.py > property-batch_check_sec3.out
import math, random, itertools
from fractions import Fraction as Fr
from math import log, sqrt, comb, pi

random.seed(3115)
EPS = 1e-12

def tv(p, q): return float(sum(abs(a-b) for a, b in zip(p, q))/2)
def mass(p, S): return sum((p[o] for o in S), Fr(0))
def K_ln2(w): return log(1.0/float(w))
def r_tol(w, N, kappa): return sqrt((K_ln2(w) + kappa)/(2*N))

def yat(H):
    J, W = len(H), len(H[0])
    return [[frozenset(o for o in range(W) if H[i][o] > H[j][o]) for j in range(J)] for i in range(J)]

def rand_law(W, lattice):
    cuts = sorted(random.randrange(lattice+1) for _ in range(W-1))
    parts = [b-a for a, b in zip([0]+cuts, cuts+[lattice])]
    return [Fr(x, lattice) for x in parts]

def compositions(N, W):
    if W == 1:
        yield (N,); return
    for a in range(N+1):
        for rest in compositions(N-a, W-1):
            yield (a,) + rest

def multinomial_prob(counts, Q):
    N = sum(counts); c = math.factorial(N); p = Fr(1)
    for k, q in zip(counts, Q):
        c //= math.factorial(k); p *= q**k
    return c*p

# ---------------------------------------------------------------- estimators, from the definitions
def crit_penalised(H, w, emp, N, kappa, A):
    """c_N(i) of Definition 3.4."""
    J = len(H); r = [r_tol(w[i], N, kappa) for i in range(J)]; c = []
    for i in range(J):
        d = 0.0
        for j in range(J):
            if j == i: continue
            U = mass(H[i], A[i][j]) - mass(emp, A[i][j])
            d = max(d, float(U) - r[j])
        c.append(d + r[i])
    return c, r

def eps_minimisers(c, eps):
    m = min(c); return [i for i in range(len(c)) if c[i] <= m + eps + EPS]

# ---------------------------------------------------------------- (1) Theorem 3.6: exact failure probability and the proof's event
def check_36(H, w, Q, N, delta, kappa, eps):
    """Return (exact Pr[some eps-minimiser violates (O)], exact Pr[E1 and E2 fail], number of samples on E1&E2 that violate (O))."""
    J = len(H); A = yat(H); W = len(Q)
    r = [r_tol(w[i], N, kappa) for i in range(J)]
    s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N))
    tvs = [tv(H[i], Q) for i in range(J)]
    g = [3*tvs[i] + 2*r[i] for i in range(J)]
    star = min(range(J), key=lambda i: g[i])
    bound = g[star] + 2*s + eps
    p_fail = Fr(0); p_notE = Fr(0); det_viol = 0
    for counts in compositions(N, W):
        pr = multinomial_prob(counts, Q)
        if pr == 0: continue
        emp = [Fr(k, N) for k in counts]
        c, _ = crit_penalised(H, w, emp, N, kappa, A)
        mins = eps_minimisers(c, eps)
        bad = any(tvs[i] > bound + 1e-9 for i in mins)
        E1 = all(float(mass(Q, A[star][j]) - mass(emp, A[star][j])) <= r[j] + s + EPS for j in range(J) if j != star)
        E2 = all(float(mass(emp, A[j][star]) - mass(Q, A[j][star])) <= r[j] + s + EPS for j in range(J) if j != star)
        if bad: p_fail += pr
        if not (E1 and E2): p_notE += pr
        elif bad: det_viol += 1
    return float(p_fail), float(p_notE), det_viol

worst = 0.0; worstE = 0.0; det = 0; cases = 0; nontriv = 0; arg = None
for trial in range(2600):
    W = random.choice([2, 3, 4]); J = random.choice([2, 3, 4, 5]); N = random.choice([1, 2, 3, 5, 8, 12] if W < 4 else [1, 2, 4, 7])
    lattice = random.choice([4, 6, 10])
    H = [rand_law(W, lattice) for _ in range(J)]
    if random.random() < 0.3: H[-1] = list(H[0])                       # the same law under two indices
    # weights: random, total at most 1; sometimes very unequal, sometimes total far below 1
    raw = [random.random()**random.choice([1, 4, 12]) + 1e-9 for _ in range(J)]
    tot = sum(raw)*random.choice([1.0, 1.0, 3.0, 50.0])
    w = [x/tot for x in raw]
    mode = random.choice(["in", "out", "mix"])
    if mode == "in": Q = list(H[random.randrange(J)])
    elif mode == "out": Q = rand_law(W, lattice)
    else:
        a = H[random.randrange(J)]; b = rand_law(W, lattice); lam = Fr(random.choice([1, 2, 5]), 10)
        Q = [(1-lam)*x + lam*y for x, y in zip(a, b)]
    delta = random.choice([0.9, 0.5, 0.2, 0.05])
    kappa = random.choice([log(2/delta), 0.0, 1.0])
    eps = random.choice([0.0, 0.0, 0.05, 0.3])
    f, fe, dv = check_36(H, w, Q, N, delta, kappa, eps)
    cases += 1; nontriv += f > 0; det += dv
    if f/delta > worst: worst, arg = f/delta, (W, J, N, delta, round(kappa, 3), eps, mode)
    worstE = max(worstE, fe/delta)
print(f"(1) Theorem 3.6, exact multinomial sums on {cases} random classes (2 to 5 indices on 2 to 4 points, N <= 12; ties, duplicate laws,")
print(f"    weights of total <= 1, truth in or outside the class, kappa in {{ln(2/delta), 0, 1}}, eps-minimisers with eps in {{0, 0.05, 0.3}}):")
print(f"    max Pr[some eps-minimiser violates (O)]/delta = {worst:.4f} at (W, J, N, delta, kappa, eps, mode) = {arg}  (must be <= 1); cases with positive failure probability: {nontriv}")
print(f"    max Pr[E1 or E2 fails]/delta = {worstE:.4f} (must be <= 1); samples on E1 and E2 on which (O) fails: {det} (must be 0)")

# ---------------------------------------------------------------- (2) Theorem 3.3 and Proposition 3.8, human in the class: exact
def check_33(H, w, i0, N, delta, tests, wt):
    J = len(H); A = yat(H); W = len(H[0]); Q = H[i0]
    half = Fr(1, 2) if tests else Fr(1)
    def tolA(a, b): return sqrt(log(2/(float(half)*w[a]*w[b]*delta))/(2*N))
    def tolR(p): return sqrt(log(2/(float(half)*p*delta))/(2*N))
    Kb = K_ln2(w[i0])
    bound = sqrt((4*Kb + 2*log((4 if tests else 2)/delta))/N)
    pf = Fr(0); undefined = Fr(0)
    for counts in compositions(N, W):
        pr = multinomial_prob(counts, Q)
        if pr == 0: continue
        emp = [Fr(k, N) for k in counts]
        match = []
        for i in range(J):
            ok = all(abs(float(mass(H[i], A[a][b]) - mass(emp, A[a][b]))) <= tolA(a, b) + EPS for a in range(J) for b in range(J) if a != b)
            ok = ok and all(abs(float(mass(H[i], R) - mass(emp, R))) <= tolR(p) + EPS for R, p in zip(tests, wt))
            if ok: match.append(i)
        if not match: pf += pr; undefined += pr; continue
        top = max(w[i] for i in match); cands = [i for i in match if w[i] >= top*(1-1e-15)]
        bad = False
        for e in cands:                                           # every matching index of the largest weight must satisfy the claims
            if w[e] < w[i0]*(1-1e-15): bad = True
            if tv(H[e], Q) > bound + 1e-9: bad = True
            if e != i0 and tv(H[e], Q) > 2*tolA(e, i0) + 1e-9: bad = True
            for R, p in zip(tests, wt):
                if abs(float(mass(H[e], R) - mass(Q, R))) > 2*tolR(p) + 1e-9: bad = True
        if bad: pf += pr
    return float(pf), float(undefined)

def check_38(H, w, i0, N, delta, tests, wt):
    J = len(H); A = yat(H); W = len(H[0]); Q = H[i0]
    dp = delta/2 if tests else delta
    r = [r_tol(w[i], N, log(2/dp)) for i in range(J)]
    def tolR(p): return sqrt(log(2/(p*dp))/(2*N))
    bound = 2*r[i0]
    assert abs(bound - sqrt((2*K_ln2(w[i0]) + 2*log(2/dp))/N)) < 1e-12
    pf = Fr(0)
    for counts in compositions(N, W):
        pr = multinomial_prob(counts, Q)
        if pr == 0: continue
        emp = [Fr(k, N) for k in counts]
        adm = []
        for i in range(J):
            ok = all(float(mass(H[i], A[i][j]) - mass(emp, A[i][j])) <= max(r[i], r[j]) + EPS for j in range(J) if j != i)
            ok = ok and all(abs(float(mass(H[i], R) - mass(emp, R))) <= tolR(p) + EPS for R, p in zip(tests, wt))
            if ok: adm.append(i)
        if not adm: pf += pr; continue
        top = max(w[i] for i in adm); cands = [i for i in adm if w[i] >= top*(1-1e-15)]
        bad = False
        for e in cands:
            if w[e] < w[i0]*(1-1e-15) or tv(H[e], Q) > bound + 1e-9: bad = True
            for R, p in zip(tests, wt):
                if abs(float(mass(H[e], R) - mass(Q, R))) > 2*tolR(p) + 1e-9: bad = True
        if bad: pf += pr
    return float(pf)

w33 = 0.0; w38 = 0.0; n33 = 0; pos33 = 0; pos38 = 0
for trial in range(1500):
    W = random.choice([2, 3, 4]); J = random.choice([2, 3, 4]); N = random.choice([1, 2, 3, 5, 8, 12] if W < 4 else [1, 2, 4, 7])
    lattice = random.choice([4, 6, 10]); H = [rand_law(W, lattice) for _ in range(J)]
    if random.random() < 0.3: H[-1] = list(H[0])
    raw = [random.random()**random.choice([1, 4, 12]) + 1e-9 for _ in range(J)]; tot = sum(raw)*random.choice([1.0, 1.0, 3.0])
    w = [x/tot for x in raw]; i0 = random.randrange(J); delta = random.choice([0.9, 0.5, 0.2, 0.05])
    if random.random() < 0.5: tests, wt = [], []
    else:
        tests = [frozenset([o]) for o in range(W)] + [frozenset(range(W))]; wt = [1.0/(W+1)]*(W+1)
    f, und = check_33(H, w, i0, N, delta, tests, wt); n33 += 1; pos33 += f > 0
    w33 = max(w33, f/delta)
    f8 = check_38(H, w, i0, N, delta, tests, wt); pos38 += f8 > 0
    w38 = max(w38, f8/delta)
print(f"(2) human in the class, exact multinomial sums on {n33} random classes (with and without a family of tests of total weight 1):")
print(f"    Theorem 3.3 (i)-(iii): max failure probability/delta = {w33:.4f} (must be <= 1); cases with positive failure probability: {pos33}")
print(f"    Proposition 3.8:        max failure probability/delta = {w38:.4f} (must be <= 1); cases with positive failure probability: {pos38}")

# ---------------------------------------------------------------- (3) constants of Section 3, recomputed
K, d, N = 37.0, 0.07, 911
lhs = 2*sqrt(log(2/((2.0**-K)**2*d))/(2*N)); rhs = sqrt((4*K*log(2) + 2*log(2/d))/N)
lhs2 = 2*sqrt(log(2/((2.0**-K)**2/2*d))/(2*N)); rhs2 = sqrt((4*K*log(2) + 2*log(4/d))/N)
lhs3 = 2*r_tol(2.0**-K, N, log(2/d)); rhs3 = sqrt((2*K*log(2) + 2*log(2/d))/N)
lhs4 = 2*r_tol(2.0**-K, N, 0.0) + 2*sqrt(log(2/d)/(2*N)); rhs4 = sqrt(2*K*log(2)/N) + sqrt(2*log(2/d)/N)
print("(3) constants: 3.3(ii) without tests %.6f = %.6f; with tests %.6f = %.6f; 3.6 choice 1 %.6f = %.6f; choice 2 %.6f = %.6f"
      % (lhs, rhs, lhs2, rhs2, lhs3, rhs3, lhs4, rhs4))
# Corollary 3.7(c): integral of min(1, 2 exp(-N t^2/2)) is at most sqrt(2 pi / N)
Nn = 50; h = 1e-5; integ = sum(min(1.0, 2*math.exp(-Nn*(k*h)**2/2))*h for k in range(int(3/h)))
print(f"    Corollary 3.7(c): integral of min(1, 2 exp(-N t^2/2)) dt for N = 50: {integ:.5f} <= sqrt(2 pi/N) = {sqrt(2*pi/Nn):.5f}")

# ---------------------------------------------------------------- (4) Corollary 3.7(c): exact expectation, kappa = 0, first minimiser
worst = 0.0
for trial in range(400):
    W = random.choice([2, 3]); J = random.choice([2, 3, 4]); N = random.choice([1, 2, 5, 10, 20])
    H = [rand_law(W, 10) for _ in range(J)]; raw = [random.random()**4 + 1e-9 for _ in range(J)]; tot = sum(raw); w = [x/tot for x in raw]
    Q = rand_law(W, 10) if trial % 2 else list(H[random.randrange(J)]); A = yat(H)
    ex = 0.0
    for counts in compositions(N, W):
        pr = multinomial_prob(counts, Q)
        if pr == 0: continue
        c, _ = crit_penalised(H, w, [Fr(k, N) for k in counts], N, 0.0, A)
        m = min(c); e = next(i for i in range(J) if c[i] <= m + 1e-15)          # first minimiser in the enumeration
        ex += float(pr)*tv(H[e], Q)
    b = min(3*tv(H[i], Q) + sqrt(2*K_ln2(w[i])/N) for i in range(J)) + sqrt(2*pi/N)
    worst = max(worst, ex/b)
print(f"(4) Corollary 3.7(c), exact expectation on 400 random classes: max E TV(est, Q)/bound = {worst:.4f} (must be <= 1)")

# ---------------------------------------------------------------- (5) Proposition 3.9: deterministic check on the event of Theorem 2.5(a)
viol = 0; onG = 0; worstG = 0.0
for trial in range(600):
    W = random.choice([2, 3, 4]); N = random.choice([1, 2, 4, 7, 10] if W < 4 else [1, 3, 6])
    Q = rand_law(W, 10); C = [rand_law(W, 10) for _ in range(random.choice([1, 2, 5]))]
    if trial % 3 == 0: C.append(list(Q))
    subsets = [frozenset(S) for k in range(1, W+1) for S in itertools.combinations(range(W), k)]
    tests = random.sample(subsets, min(len(subsets), random.choice([1, 3, 6]))); wt = [1.0/len(tests)]*len(tests)
    delta = random.choice([0.9, 0.3, 0.05]); eps = random.choice([0.0, 0.1])
    tol = [sqrt(log(2/(p*delta))/(2*N)) for p in wt]
    approx = min(max(abs(float(mass(c, R) - mass(Q, R))) for R in tests) for c in C)
    pG = Fr(0)
    for counts in compositions(N, W):
        pr = multinomial_prob(counts, Q)
        if pr == 0: continue
        emp = [Fr(k, N) for k in counts]
        if not all(abs(float(mass(emp, R) - mass(Q, R))) <= t + EPS for R, t in zip(tests, tol)):
            pG += pr; continue
        onG += 1
        dN = [max(max(abs(float(mass(c, R) - mass(emp, R))) - t for R, t in zip(tests, tol)), 0.0) for c in C]
        m = min(dN)
        for c, dc in zip(C, dN):
            if dc <= m + eps + EPS:
                for R, t in zip(tests, tol):
                    if abs(float(mass(c, R) - mass(Q, R))) > 2*t + approx + eps + 1e-9: viol += 1
    worstG = max(worstG, float(pG)/delta)
print(f"(5) Proposition 3.9 on 600 random (candidates, tests, truth): samples on the event of Theorem 2.5(a): {onG}; violations there: {viol} (must be 0);")
print(f"    max Pr[event of 2.5(a) fails]/delta = {worstG:.4f} (must be <= 1)")

# ---------------------------------------------------------------- (6) Theorem 3.10 (simulated runs), two indices on {0,1}: exact triple binomial sum
def check_310(p1, p2, q, w1, w2, N, Ns, delta, kappa, eps):
    H = [[1-p1, p1], [1-p2, p2]]; w = [w1, w2]; Q = [1-q, q]
    if p1 == p2: return 0.0
    A12 = 1 if p1 > p2 else 0; A21 = 1 - A12              # A_12 = {answer A12}, A_21 = {answer A21}
    r = [r_tol(w[i], N, kappa) + r_tol(w[i], Ns, kappa) for i in range(2)]
    s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N)); st = sqrt(max(log(2/delta) - kappa, 0.0)/(2*Ns))
    tvs = [abs(float(p1 - q)), abs(float(p2 - q))]
    bound = min(3*tvs[i] + 2*r[i] for i in range(2)) + 2*s + 2*st + eps
    if all(t <= bound + 1e-9 for t in tvs): return 0.0
    def pm(n, p): return [comb(n, k)*p**k*(1-p)**(n-k) for k in range(n+1)]
    pd, ps1, ps2 = pm(N, q), pm(Ns, p1), pm(Ns, p2); fail = Fr(0)
    for a in range(N+1):
        e1 = Fr(a, N); emp = [1-e1, e1]
        for b in range(Ns+1):
            t1 = Fr(b, Ns); sim1 = [1-t1, t1]
            c1 = max(float(sim1[A12] - emp[A12]) - r[1], 0.0) + r[0]
            for c in range(Ns+1):
                t2 = Fr(c, Ns); sim2 = [1-t2, t2]
                c2 = max(float(sim2[A21] - emp[A21]) - r[0], 0.0) + r[1]
                m = min(c1, c2); mins = [i for i, cc in enumerate((c1, c2)) if cc <= m + eps + EPS]
                if any(tvs[i] > bound + 1e-9 for i in mins): fail += pd[a]*ps1[b]*ps2[c]
    return float(fail)
worst = 0.0; cnt = 0; pos = 0
grid = [Fr(i, 10) for i in range(11)]
for (N, Ns) in ((3, 3), (8, 5), (12, 12)):
    for delta in (0.45, 0.2, 0.05):
        for (w1, w2) in ((0.5, 0.5), (0.9, 0.1), (0.05, 0.9)):
            for kappa in (log(2/delta), 0.0):
                for p1 in grid:
                    for p2 in grid:
                        for q in (grid if N <= 8 else grid[::2]):
                            f = check_310(p1, p2, q, w1, w2, N, Ns, delta, kappa, 0.0); cnt += 1; pos += f > 0
                            worst = max(worst, f/(2*delta))
print(f"(6) Theorem 3.10, exact sums over the data and the two simulated samples ({cnt} cases, {pos} with positive failure probability):")
print(f"    max failure probability/(2 delta) = {worst:.4f} (must be <= 1)")

# ---------------------------------------------------------------- (7) Example 3.11(a): the factor 3
for e0 in (Fr(1, 20), Fr(1, 100)):
    n1 = [Fr(0), Fr(1, 4)+e0, Fr(1, 2), Fr(1, 4)-e0]; n2 = [Fr(1, 2)+e0, Fr(1, 4)-e0, Fr(0), Fr(1, 4)]; Q = [Fr(1, 2), Fr(1, 2), Fr(0), Fr(0)]
    H = [n1, n2]; w = [0.5, 0.5]; A = yat(H)
    assert A[0][1] == frozenset([1, 2]) and A[1][0] == frozenset([0, 3])
    assert mass(n1, A[0][1]) == Fr(3, 4)+e0 == mass(n2, A[1][0])
    assert Fr(sum(abs(a-b) for a, b in zip(n1, Q)), 2) == Fr(3, 4)-e0 and Fr(sum(abs(a-b) for a, b in zip(n2, Q)), 2) == Fr(1, 4)+e0
    ratio = (Fr(3, 4)-e0)/(Fr(1, 4)+e0); assert ratio == 3 - 16*e0/(1+4*e0)
    for N in (5, 31, 101, 1001):
        kappa = log(2/0.1); rN = r_tol(0.5, N, kappa); p1 = Fr(0); ties = Fr(0)
        for s in range(N+1):                      # s = number of answers equal to 2 (index 1); the others equal 1 (index 0)
            pr = Fr(comb(N, s), 2**N); emp = [Fr(N-s, N), Fr(s, N), Fr(0), Fr(0)]
            c, _ = crit_penalised(H, w, emp, N, kappa, A)
            if abs(c[0] - c[1]) <= 1e-13: ties += pr
            elif c[0] < c[1]: p1 += pr
        print(f"(7) Example 3.11(a), eps0 = {e0}: ratio TV(nu1,Q)/TV(nu2,Q) = {float(ratio):.4f}; N = {N}: r_N = {rN:.4f} ({'<' if rN < 0.25 else '>='} 1/4);"
              f" exact Pr[estimate = nu1] = {float(p1):.6f}, Pr[tie] = {float(ties):.6f}")

# ---------------------------------------------------------------- (8) Example 3.11(b): without a penalty the replay of the data wins
u, N = 7, 3
unif = [Fr(1, u)]*u
subs = list(itertools.combinations(range(u), N))
H = [unif] + [[Fr(1, N) if o in S else Fr(0) for o in range(u)] for S in subs]
J = len(H); A = yat(H); okb = True; okU = True
for sample in itertools.combinations(range(u), N):          # the N recorded answers are distinct
    emp = [Fr(1, N) if o in sample else Fr(0) for o in range(u)]
    c = []
    for i in range(J):                                        # criterion without penalty: r = 0
        c.append(max([float(mass(H[i], A[i][j]) - mass(emp, A[i][j])) for j in range(J) if j != i] + [0.0]))
    mins = [i for i in range(J) if c[i] <= min(c) + 1e-15]
    if mins != [1 + subs.index(sample)]: okb = False
    iS = 1 + subs.index(sample)
    if mass(H[0], A[0][iS]) - mass(emp, A[0][iS]) != 1 - Fr(N, u): okU = False
print(f"(8) Example 3.11(b), u = {u}, N = {N}, all {len(subs)} samples of distinct answers: the unpenalised criterion is minimised only by the replay: {okb};"
      f" U_N(Q, Q_S) = 1 - N/u: {okU}; TV(Q_S, Q) = {float(1 - Fr(N, u)):.4f}")
for (u, N, wQ, kappa) in ((200, 3, 0.5, 0.0), (10**4, 10, 0.5, log(20)), (10**6, 100, 0.01, log(20))):
    rQ = r_tol(wQ, N, kappa); lnC = math.lgamma(u+1) - math.lgamma(N+1) - math.lgamma(u-N+1)
    rS = sqrt((lnC + log(1/(1-wQ)) + kappa)/(2*N))
    print(f"    penalised: u = {u}, N = {N}, w(Q) = {wQ}: condition u > N exp(2(1+r_N(Q))^2) = {N*math.exp(2*(1+rQ)**2):.1f}: {u > N*math.exp(2*(1+rQ)**2)};"
          f" r_N(Q_S) = {rS:.3f} against 1 + r_N(Q) = {1+rQ:.3f}; lower bound sqrt(ln(u/N)/2) = {sqrt(log(u/N)/2):.3f}")

# ---------------------------------------------------------------- (9) Example 3.11(c): outside the class no index may match
for N in (20, 100, 1000):
    H = [[Fr(3, 4), Fr(1, 4)], [Fr(1, 4), Fr(3, 4)]]; w = [0.5, 0.5]; A = yat(H); delta = 0.1
    p_none33 = Fr(0); p_none38 = Fr(0)
    r = [r_tol(w[i], N, log(2/delta)) for i in range(2)]
    for s in range(N+1):
        pr = Fr(comb(N, s), 2**N); emp = [Fr(N-s, N), Fr(s, N)]
        m33 = [i for i in range(2) if all(abs(float(mass(H[i], A[a][b]) - mass(emp, A[a][b]))) <= sqrt(log(2/(w[a]*w[b]*delta))/(2*N)) for a in range(2) for b in range(2) if a != b)]
        m38 = [i for i in range(2) if float(mass(H[i], A[i][1-i]) - mass(emp, A[i][1-i])) <= max(r)]
        if not m33: p_none33 += pr
        if not m38: p_none38 += pr
    print(f"(9) Example 3.11(c), N = {N}: Pr[no index matches (Theorem 3.3)] = {float(p_none33):.6f}; Pr[no index is admissible (Proposition 3.8)] = {float(p_none38):.6f}")

# ---------------------------------------------------------------- (10) Lemma 3.5 and (C1): which indices can matter
okc = True
for trial in range(2000):
    J = random.choice([3, 6, 12]); W = 3; N = random.choice([1, 2, 5, 30]); kappa = random.choice([0.0, 1.0, 3.0])
    H = [rand_law(W, 10) for _ in range(J)]; raw = [random.random()**random.choice([1, 8, 30]) + 1e-12 for _ in range(J)]; tot = sum(raw); w = [x/tot for x in raw]
    emp = rand_law(W, N) if N > 1 else [Fr(1), Fr(0), Fr(0)]; A = yat(H); eps = random.choice([0.0, 0.2])
    c, r = crit_penalised(H, w, emp, N, kappa, A)
    r1 = min(r)
    for i in eps_minimisers(c, eps):
        if r[i] > 1 + r1 + eps + 1e-9: okc = False
        if float(w[i]) < math.exp(kappa - 2*N*(1 + r1 + eps)**2)*(1-1e-9): okc = False
    # competitors with r >= 1 contribute nothing: recompute the criterion without them
    keep = [j for j in range(J) if r[j] < 1]
    for i in range(J):
        d = max([float(mass(H[i], A[i][j]) - mass(emp, A[i][j])) - r[j] for j in keep if j != i] + [0.0])
        if abs(d + r[i] - c[i]) > 1e-12: okc = False
print("(10) Lemma 3.5(b),(c) and (C1) on 2000 random instances (eps-minimisers have r <= 1 + r(nu_1) + eps; competitors with r >= 1 are irrelevant):", okc)

# ---------------------------------------------------------------- (11) Theorem 3.6 in the critical regime: indices Bern(p_i), exact binomial sums, N up to 400
# The random classes of block (1) seldom make the bound smaller than a distance in the class.  Here the distances are of the order of the bound.
def binom_pmf_f(N, q):
    out = []
    for k in range(N+1):
        if q <= 0: out.append(1.0 if k == 0 else 0.0)
        elif q >= 1: out.append(1.0 if k == N else 0.0)
        else: out.append(math.exp(math.lgamma(N+1) - math.lgamma(k+1) - math.lgamma(N-k+1) + k*log(q) + (N-k)*log(1-q)))
    return out
def fail_bern(ps, w, q, N, delta, kappa, eps=0.0):
    J = len(ps); r = [r_tol(w[i], N, kappa) for i in range(J)]
    s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N))
    tvs = [abs(p - q) for p in ps]
    bound = min(3*tvs[i] + 2*r[i] for i in range(J)) + 2*s + eps
    bad = [t > bound + 1e-12 for t in tvs]
    if not any(bad): return 0.0
    pmf = binom_pmf_f(N, q); f = 0.0
    for k in range(N+1):
        e = k/N; c = []
        for i in range(J):
            d = 0.0
            for j in range(J):
                if j == i or ps[i] == ps[j]: continue
                U = (ps[i] - e) if ps[i] > ps[j] else (e - ps[i])
                d = max(d, U - r[j])
            c.append(d + r[i])
        m = min(c)
        if any(bad[i] and c[i] <= m + eps + 1e-13 for i in range(J)): f += pmf[k]
    return f
worst = 0.0; arg = None; cnt = 0; pos = 0
for N in (25, 100, 400):
    for delta in (0.9, 0.5, 0.1, 0.01):
        for kappa in (log(2/delta), 0.0):
            for (w0, w1) in ((0.5, 0.5), (0.01, 0.99), (0.99, 0.01), (0.001, 0.5)):
                r0 = r_tol(w0, N, kappa); s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N))
                for base in (0.5, 0.2, 0.02):
                    for cfac in (1.0005, 1.02, 1.1, 1.3, 1.7):
                        D = cfac*(2*r0 + 2*s)
                        for sign in (+1, -1):
                            p1 = base + sign*D
                            if not (0 <= p1 <= 1): continue
                            f = fail_bern([base, p1], [w0, w1], base, N, delta, kappa); cnt += 1; pos += f > 0
                            if f/delta > worst: worst, arg = f/delta, (N, delta, round(kappa, 2), w0, w1, base, round(p1, 4))
print(f"(11) Theorem 3.6, two indices Bern(p0), Bern(p1), truth = Bern(p0), |p1 - p0| just above the bound 2 r_N(0) + 2s: {cnt} cases, {pos} with positive failure probability;")
print(f"     max failure probability/delta = {worst:.4f} at (N, delta, kappa, w0, w1, p0, p1) = {arg} (must be <= 1)")
worst = 0.0; arg = None; cnt = 0; pos = 0
for trial in range(6000):
    N = random.choice([25, 100, 400]); J = random.choice([2, 3, 4, 6]); delta = random.choice([0.9, 0.5, 0.1, 0.01])
    kappa = random.choice([log(2/delta), 0.0]); centre = random.choice([0.5, 0.15])
    spread = random.choice([1.0, 2.5, 5.0])/sqrt(N)
    ps = [min(1.0, max(0.0, centre + random.uniform(-spread, spread))) for _ in range(J)]
    raw = [random.random()**random.choice([1, 6, 20]) + 1e-9 for _ in range(J)]; tot = sum(raw)*random.choice([1.0, 2.0]); w = [x/tot for x in raw]
    q = ps[random.randrange(J)] if random.random() < 0.5 else min(1.0, max(0.0, centre + random.uniform(-spread, spread)))
    eps = random.choice([0.0, 0.0, 0.02])
    f = fail_bern(ps, w, q, N, delta, kappa, eps); cnt += 1; pos += f > 0
    if f/delta > worst: worst, arg = f/delta, (N, J, delta, round(kappa, 2), eps)
print(f"     random classes of 2 to 6 indices Bern(p_i) with p_i within a few standard errors of each other: {cnt} cases, {pos} with positive failure probability;")
print(f"     max failure probability/delta = {worst:.4f} at (N, J, delta, kappa, eps) = {arg} (must be <= 1)")

# ---------------------------------------------------------------- (12) Theorem 3.10 in the critical regime, exact (numpy), two indices
import numpy as np
def fail_310_np(p0, p1, w0, w1, N, Ns, delta, kappa):
    """Truth = Bern(p0) = index 0.  Exact Pr[index 1 is a minimiser of c~ and TV(1, truth) exceeds the bound]."""
    w = [w0, w1]; r = [r_tol(w[i], N, kappa) + r_tol(w[i], Ns, kappa) for i in range(2)]
    s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N)); st = sqrt(max(log(2/delta) - kappa, 0.0)/(2*Ns))
    bound = 2*r[0] + 2*s + 2*st                                  # 3 TV(Q_0, Q) = 0
    if abs(p1 - p0) <= bound + 1e-12: return 0.0
    pd = np.array(binom_pmf_f(N, p0)); ps0 = np.array(binom_pmf_f(Ns, p0)); ps1 = np.array(binom_pmf_f(Ns, p1))
    e = np.arange(N+1)/N; t0 = np.arange(Ns+1)/Ns; t1 = np.arange(Ns+1)/Ns
    if p0 > p1:      # A_01 = {1}, A_10 = {0}
        U0 = t0[None, :] - e[:, None]                 # sim0({1}) - emp({1})
        U1 = (1 - t1)[None, :] - (1 - e)[:, None]     # sim1({0}) - emp({0})
    else:            # A_01 = {0}, A_10 = {1}
        U0 = (1 - t0)[None, :] - (1 - e)[:, None]
        U1 = t1[None, :] - e[:, None]
    c0 = np.maximum(U0 - r[1], 0.0) + r[0]            # shape (N+1, Ns+1): data count a, simulated count b of index 0
    c1 = np.maximum(U1 - r[0], 0.0) + r[1]            # shape (N+1, Ns+1): data count a, simulated count c of index 1
    f = 0.0
    for a in range(N+1):
        if pd[a] == 0: continue
        fail = c1[a][None, :] <= c0[a][:, None] + 1e-13          # (b, c): index 1 is a minimiser
        f += pd[a]*float(ps0 @ fail @ ps1)
    return f
worst = 0.0; arg = None; cnt = 0; pos = 0
for (N, Ns) in ((30, 30), (60, 20), (100, 100), (200, 50)):
    for delta in (0.45, 0.1, 0.01):
        for kappa in (log(2/delta), 0.0):
            for (w0, w1) in ((0.5, 0.5), (0.01, 0.99), (0.9, 0.1)):
                r0 = r_tol(w0, N, kappa) + r_tol(w0, Ns, kappa)
                s = sqrt(max(log(2/delta) - kappa, 0.0)/(2*N)); st = sqrt(max(log(2/delta) - kappa, 0.0)/(2*Ns))
                for base in (0.5, 0.1, 0.9):
                    for cfac in (1.0005, 1.05, 1.3):
                        for sign in (+1, -1):
                            p1 = base + sign*cfac*(2*r0 + 2*s + 2*st)
                            if not (0 <= p1 <= 1): continue
                            f = fail_310_np(base, p1, w0, w1, N, Ns, delta, kappa); cnt += 1; pos += f > 0
                            if f/(2*delta) > worst: worst, arg = f/(2*delta), (N, Ns, delta, round(kappa, 2), w0, w1, base, round(p1, 4))
print(f"(12) Theorem 3.10, two indices, truth in the class, |p1 - p0| just above the bound, exact sums: {cnt} cases, {pos} with positive failure probability;")
print(f"     max failure probability/(2 delta) = {worst:.5f} at (N, Ns, delta, kappa, w0, w1, p0, p1) = {arg} (must be <= 1)")
