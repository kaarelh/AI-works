# Checks for Section 3 of research/prove-c/property-batch.md (Pr4: minimum-distance estimation with weighted Yatracos sets).
# Pure Python.  Run:  python3 property-batch_pr4.py > property-batch_pr4.out
import random, math
from math import log, sqrt, comb, pi
random.seed(11)
LN2 = log(2.0)

def tv(p, q): return 0.5*sum(abs(a-b) for a, b in zip(p, q))
def mass(p, S): return sum(p[o] for o in S)

def rand_dist(W, conc=1.0, lattice=None):
    """A random probability vector on W points.  With lattice=g the entries are multiples of 1/g (ties between hypotheses become common)."""
    if lattice is None:
        g = [random.gammavariate(conc, 1.0) for _ in range(W)]; s = sum(g); return [x/s for x in g]
    cuts = sorted(random.randrange(lattice+1) for _ in range(W-1))
    parts = [b-a for a, b in zip([0]+cuts, cuts+[lattice])]
    return [x/lattice for x in parts]

def yatracos(H):
    J, W = len(H), len(H[0])
    return [[[o for o in range(W) if H[i][o] > H[j][o]] for j in range(J)] for i in range(J)]

# ---------------------------------------------------------------- (1) Scheffe identity, with ties
worst = 0.0
for _ in range(2000):
    W = random.choice([3, 5, 8]); H = [rand_dist(W, lattice=random.choice([None, 10])) for _ in range(4)]
    A = yatracos(H)
    for i in range(4):
        for j in range(4):
            if i != j: worst = max(worst, abs(tv(H[i], H[j]) - (mass(H[i], A[i][j]) - mass(H[j], A[i][j]))))
print("(1) Lemma 3.2(a): max |TV(Q_i,Q_j) - (Q_i(A_ij) - Q_j(A_ij))| over 2000 random classes (half of them with ties):", f"{worst:.1e}")

# ---------------------------------------------------------------- estimators
def r_tol(w, N, kappa): return sqrt((log(1/w) + kappa)/(2*N))

def est_penalised(H, w, emp, N, kappa, QA=None):
    """Definition 3.4: minimise c_N(i) = max_j (U(i,j) - r_j)^+ + r_i with U(i,j) = Q_i(A_ij) - emp(A_ij) (one-sided).
    QA[i][j], if given, replaces the exact Q_i(A_ij) (the simulated version of Theorem 3.10; then r includes the simulation tolerance)."""
    J = len(H); A = yatracos(H); r = [r_tol(w[i], N, kappa) for i in range(J)]
    best, arg = None, None
    for i in range(J):
        d = 0.0
        for j in range(J):
            if j == i: continue
            qi = mass(H[i], A[i][j]) if QA is None else QA[i][j]
            d = max(d, qi - mass(emp, A[i][j]) - r[j])
        c = d + r[i]
        if best is None or c < best - 1e-15: best, arg = c, i
    return arg

def est_matching(H, w, emp, N, delta, tests=None, wt=None):
    """Theorem 3.3: the highest-weight index that matches all tests two-sidedly; Yatracos sets with weight w_i w_j (halved if a family of tests is present)."""
    J = len(H); A = yatracos(H); half = 0.5 if tests else 1.0
    for i in sorted(range(J), key=lambda i: -w[i]):
        ok = True
        for a in range(J):
            for b in range(J):
                if a == b: continue
                tol = sqrt(log(2/(half*w[a]*w[b]*delta))/(2*N))
                if abs(mass(H[i], A[a][b]) - mass(emp, A[a][b])) > tol: ok = False; break
            if not ok: break
        if ok and tests:
            for R, p in zip(tests, wt):
                if abs(mass(H[i], R) - mass(emp, R)) > sqrt(log(2/(0.5*p*delta))/(2*N)): ok = False; break
        if ok: return i
    return None

def est_admissible(H, w, emp, N, delta):
    """Proposition 3.8: the highest-weight index with U(i,j) <= max(r_i, r_j) for all j (one-sided), kappa = ln(2/delta)."""
    J = len(H); A = yatracos(H); k = log(2/delta); r = [r_tol(w[i], N, k) for i in range(J)]
    for i in sorted(range(J), key=lambda i: -w[i]):
        if all(mass(H[i], A[i][j]) - mass(emp, A[i][j]) <= max(r[i], r[j]) for j in range(J) if j != i): return i
    return None

def empirical(Q, N):
    W = len(Q); xs = random.choices(range(W), weights=Q, k=N); return [xs.count(o)/N for o in range(W)]

# ---------------------------------------------------------------- (2)-(4) Monte Carlo on random classes
W, J, delta = 6, 12, 0.1
w = [2.0**-(i+1) for i in range(J)]
def trial_class(lattice):
    return [rand_dist(W, lattice=lattice) for _ in range(J)]

print("(2) Theorem 3.3 (two-sided matching, product weights; a family of 6 singleton tests of weight 1/6 added), human in the class:")
for N in (30, 200, 2000):
    fails = 0; ratios = []; tests = [[o] for o in range(W)]; wt = [1.0/W]*W; T = 1500
    for t in range(T):
        H = trial_class(20 if t % 2 else None); i0 = random.randrange(J); Q = H[i0]; emp = empirical(Q, N)
        e = est_matching(H, w, emp, N, delta, tests, wt)
        if e is None: fails += 1; continue
        bound = sqrt((4*log(1/w[i0]) + 2*log(4/delta))/N); err = tv(H[e], Q)
        okt = all(abs(mass(H[e], R) - mass(Q, R)) <= sqrt(2*log(4/(p*delta))/N) + 1e-12 for R, p in zip(tests, wt))
        if not (w[e] >= w[i0] and err <= bound + 1e-12 and okt): fails += 1
        ratios.append(err/bound)
    print(f"    N={N:5d}: failures {fails}/{T} (allowed {delta:.0%}); TV/bound mean {sum(ratios)/len(ratios):.3f}, max {max(ratios):.3f}")

print("(3) Theorem 3.6 (penalised one-sided minimum distance, kappa = ln(2/delta)): TV(est, Q) against min_i [3 TV(Q_i,Q) + 2 r_N(i)]")
for mode in ("in the class", "outside the class"):
    for N in (30, 200, 2000, 20000):
        fails = 0; ratios = []; T = 1500
        for t in range(T):
            H = trial_class(20 if t % 2 else None)
            if mode == "in the class": Q = H[random.randrange(J)]
            else:
                base = H[random.randrange(J)]; noise = rand_dist(W, 0.3); lam = random.choice([0.05, 0.2, 0.5])
                Q = [(1-lam)*a + lam*b for a, b in zip(base, noise)]
            emp = empirical(Q, N); k = log(2/delta)
            e = est_penalised(H, w, emp, N, k)
            bound = min(3*tv(H[i], Q) + 2*r_tol(w[i], N, k) for i in range(J)); err = tv(H[e], Q)
            if err > bound + 1e-12: fails += 1
            ratios.append(err/bound)
        print(f"    {mode:17s} N={N:5d}: failures {fails}/{T} (allowed {delta:.0%}); TV/bound mean {sum(ratios)/len(ratios):.3f}, max {max(ratios):.3f}")

print("(4) Proposition 3.8 (highest-weight index passing the one-sided tests), human in the class: bound 2 r_N = sqrt((2K ln2 + 2 ln(2/delta))/N)")
for N in (30, 200, 2000):
    fails = 0; ratios = []; T = 1500
    for t in range(T):
        H = trial_class(20 if t % 2 else None); i0 = random.randrange(J); Q = H[i0]; emp = empirical(Q, N)
        e = est_admissible(H, w, emp, N, delta)
        if e is None: fails += 1; continue
        bound = sqrt((2*log(1/w[i0]) + 2*log(2/delta))/N); err = tv(H[e], Q)
        if not (w[e] >= w[i0] and err <= bound + 1e-12): fails += 1
        ratios.append(err/bound)
    print(f"    N={N:5d}: failures {fails}/{T} (allowed {delta:.0%}); TV/bound mean {sum(ratios)/len(ratios):.3f}, max {max(ratios):.3f}")

# ---------------------------------------------------------------- (5) exact failure probability, two hypotheses on {0,1}
# Q_1 = Bern(p1), Q_2 = Bern(p2), truth Bern(q).  The estimator depends on the data through the number of ones only,
# so Pr[TV(est, Q) > min_i (3 TV_i + 2 r_i)] is a binomial sum.  Maximum of (that probability)/delta over a grid.
def exact_fail(p1, p2, q, w1, w2, N, delta):
    H = [[1-p1, p1], [1-p2, p2]]; ww = [w1, w2]; Q = [1-q, q]; k = log(2/delta)
    bound = min(3*tv(H[i], Q) + 2*r_tol(ww[i], N, k) for i in range(2))
    bad = [tv(H[i], Q) > bound + 1e-12 for i in range(2)]
    if not any(bad): return 0.0
    pr = 0.0
    for s in range(N+1):
        emp = [1 - s/N, s/N]
        if bad[est_penalised(H, ww, emp, N, k)]:
            pr += comb(N, s)*q**s*(1-q)**(N-s)
    return pr
worst = 0.0; arg = None; cnt = 0
grid = [i/20 for i in range(0, 21)]
for N in (5, 10, 20, 40, 80):
    for delta_ in (0.3, 0.1, 0.01):
        for (w1, w2) in ((0.5, 0.5), (0.9, 0.1), (0.1, 0.9), (0.5, 0.01), (0.01, 0.5)):
            for p1 in grid:
                for p2 in grid:
                    if p1 == p2: continue
                    for q in grid:
                        f = exact_fail(p1, p2, q, w1, w2, N, delta_); cnt += 1
                        if f/delta_ > worst: worst, arg = f/delta_, (N, delta_, w1, w2, p1, p2, q)
print(f"(5) Theorem 3.6, exact binomial computation for two hypotheses on {{0,1}} ({cnt} cases, truth in or outside the class):")
print(f"    max Pr[TV(est,Q) > min_i(3 TV_i + 2 r_N(i))] / delta = {worst:.4f} (must be <= 1), at (N, delta, w1, w2, p1, p2, q) = {arg}")

# ---------------------------------------------------------------- (6) the factor 3 is attained by this estimator (Example 3.11(a))
# Four atoms (Mahalanabis and Stefankovic 2008, Lemma 11): f1, f2 and the truth g.
for eps in (0.05, 0.01):
    f1 = [0.0, 0.25+eps, 0.5, 0.25-eps]; f2 = [0.5+eps, 0.25-eps, 0.0, 0.25]; g = [0.5, 0.5, 0.0, 0.0]
    H = [f1, f2]; ww = [0.5, 0.5]
    for N in (101, 10001):
        T = 4000; pick1 = 0
        for _ in range(T):
            s = sum(1 for _ in range(N) if random.random() < 0.5)      # number of sample points in atom A2 (others in A1)
            emp = [1 - s/N, s/N, 0.0, 0.0]
            if est_penalised(H, ww, emp, N, log(2/0.1)) == 0: pick1 += 1
        print(f"(6) eps={eps}: TV(f1,g)={tv(f1,g):.3f}, TV(f2,g)={tv(f2,g):.3f}, ratio {tv(f1,g)/tv(f2,g):.3f}; N={N}: the estimator returns f1 in {pick1}/{T} trials")

# ---------------------------------------------------------------- (7) simulated version (Theorem 3.10)
print("(7) Theorem 3.10 (Q_i(A_ij) replaced by frequencies in N_sim simulated runs of hypothesis i): TV against min_i[3TV_i + 2 r_N(i) + 2 r_Nsim(i)]")
for (N, Ns) in ((200, 200), (200, 5000), (2000, 2000)):
    fails = 0; ratios = []; T = 800; k = log(2/delta)
    for t in range(T):
        H = trial_class(20 if t % 2 else None)
        base = H[random.randrange(J)]; noise = rand_dist(W, 0.3); lam = random.choice([0.0, 0.05, 0.3])
        Q = [(1-lam)*a + lam*b for a, b in zip(base, noise)]
        emp = empirical(Q, N); A = yatracos(H)
        sims = [empirical(H[i], Ns) for i in range(J)]
        QA = [[mass(sims[i], A[i][j]) for j in range(J)] for i in range(J)]
        # tolerance r_N + r_Nsim, implemented by passing an effective sample size for each of the two terms
        r = [r_tol(w[i], N, k) + r_tol(w[i], Ns, k) for i in range(J)]
        best, arg = None, None
        for i in range(J):
            d = max([QA[i][j] - mass(emp, A[i][j]) - r[j] for j in range(J) if j != i] + [0.0]); c = d + r[i]
            if best is None or c < best: best, arg = c, i
        bound = min(3*tv(H[i], Q) + 2*r[i] for i in range(J)); err = tv(H[arg], Q)
        if err > bound + 1e-12: fails += 1
        ratios.append(err/bound)
    print(f"    N={N}, N_sim={Ns}: failures {fails}/{T} (allowed {2*delta:.0%}); TV/bound mean {sum(ratios)/len(ratios):.3f}, max {max(ratios):.3f}")

# ---------------------------------------------------------------- (8) expectation form (Corollary 3.7(c)), kappa = 0
print("(8) Corollary 3.7(c) (kappa = 0): E TV(est,Q) against min_i[3TV_i + sqrt(2 K_i ln2 / N)] + sqrt(2 pi/N), one fixed class and truth per row")
for N in (50, 500, 5000):
    H = trial_class(None); base = H[3]; noise = rand_dist(W, 0.3); Q = [(0.9)*a + 0.1*b for a, b in zip(base, noise)]
    T = 3000; s = 0.0
    for _ in range(T):
        s += tv(H[est_penalised(H, w, empirical(Q, N), N, 0.0)], Q)
    orac = min(3*tv(H[i], Q) + sqrt(2*log(1/w[i])/N) for i in range(J))
    print(f"    N={N:5d}: E TV = {s/T:.4f}; best TV in class = {min(tv(h, Q) for h in H):.4f}; bound = {orac + sqrt(2*pi/N):.4f}")

# ---------------------------------------------------------------- (9) exact failure probability, three hypotheses on three points
# The estimator depends on the data through the vector of counts, so the failure probability of Theorem 3.6 is a multinomial sum.
def exact_fail3(H, ww, Q, N, delta_):
    k = log(2/delta_)
    bound = min(3*tv(h, Q) + 2*r_tol(wi, N, k) for h, wi in zip(H, ww))
    bad = [tv(h, Q) > bound + 1e-12 for h in H]
    if not any(bad): return 0.0
    pr = 0.0
    for a in range(N+1):
        for b in range(N+1-a):
            c = N - a - b
            emp = [a/N, b/N, c/N]
            if bad[est_penalised(H, ww, emp, N, k)]:
                pr += math.factorial(N)/(math.factorial(a)*math.factorial(b)*math.factorial(c)) * Q[0]**a * Q[1]**b * Q[2]**c
    return pr
random.seed(21)
lat = [(i/6, j/6, (6-i-j)/6) for i in range(7) for j in range(7-i)]
worst = 0.0; arg = None; cnt = 0; nontrivial = 0
for N in (6, 12, 24, 48):
    for delta_ in (0.5, 0.2, 0.05):
        for ww in ((1/3, 1/3, 1/3), (0.7, 0.2, 0.1), (0.1, 0.2, 0.7), (0.5, 0.25, 0.01)):
            for _ in range(150):
                H = [list(random.choice(lat)) for _ in range(3)]
                if H[0] == H[1] or H[1] == H[2] or H[0] == H[2]: continue
                Q = list(random.choice(lat)) if random.random() < 0.5 else list(random.choice(H))
                f = exact_fail3(H, list(ww), Q, N, delta_); cnt += 1; nontrivial += (f > 0)
                if f/delta_ > worst: worst, arg = f/delta_, (N, delta_, ww, H, Q)
print(f"(9) Theorem 3.6, exact multinomial computation for three hypotheses on three points ({cnt} cases, {nontrivial} with positive failure probability):")
print(f"    max Pr[TV(est,Q) > min_i(3 TV_i + 2 r_N(i))] / delta = {worst:.4f} (must be <= 1)")
