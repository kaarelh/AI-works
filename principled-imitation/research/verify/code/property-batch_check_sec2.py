# Referee's checks for Sections 1-2 of research/prove-c/property-batch.md (Lemma 1.1, Lemmas 2.1, 2.2,
# Theorem 2.3, Corollary 2.4, Theorem 2.5, Corollary 2.6).  Independent of the prover's scripts.
# Pure Python 3.  Run:  python3 property-batch_check_sec2.py > property-batch_check_sec2.out
import math, random, itertools
from fractions import Fraction as Fr
from math import log, sqrt, exp, comb

random.seed(20261115)
INF = float("inf")

def kl(p, q):
    """Bernoulli divergence in nats, with the conventions of Section 1.3 of the file."""
    if p == q: return 0.0
    if q <= 0.0 or q >= 1.0: return INF
    s = 0.0
    if p > 0: s += p*log(p/q)
    if p < 1: s += (1-p)*log((1-p)/(1-q))
    return s

def binom_pmf(N, q):
    return [comb(N, k)*q**k*(1-q)**(N-k) for k in range(N+1)]

# ------------------------------------------------------------------ (1) Lemma 1.1 on random small scaffolds
# A scaffold with horizon 3, variable length (STOP), adaptive inputs, and semimeasure samplers (outcome "bot" ends the run).
# We enumerate the complete runs for each (z, rho) and check: the leaf probabilities prod_j nu(y_j|x_j) sum to 1,
# and Q_nu(E) computed by forward simulation of the tree equals the integral of L_nu over E.
BOT = "bot"
def random_scaffold(nz, nrho, nx, ny, L):
    """next_j is a random table from (z, rho, answers so far) to an input or STOP; built lazily and memoised."""
    table = {}
    def nxt(z, rho, ys):
        key = (z, rho, ys)
        if key not in table:
            if len(ys) >= L: table[key] = None
            else:
                # STOP with probability 0.25 (also at the first call: runs with no calls occur)
                table[key] = None if random.random() < 0.25 else random.randrange(nx)
        return table[key]
    return nxt

def random_sampler(nx, ny, semi):
    S = []
    for x in range(nx):
        g = [Fr(random.randrange(0, 5)) for _ in range(ny)]
        if sum(g) == 0: g[0] = Fr(1)
        tot = sum(g) + (Fr(random.randrange(0, 4)) if semi else 0)
        S.append([a/tot for a in g])          # sums to <= 1; the deficit is the probability of "no answer"
    return S

def runs_and_laws(nxt, nz, nrho, ny, L, S):
    """Return dict: complete run -> (likelihood L_S(run), probability under Q_S) with (z, rho) uniform."""
    out = {}
    base = Fr(1, nz*nrho)
    def rec(z, rho, ys, lik):
        x = nxt(z, rho, ys)
        if x is None or (ys and ys[-1] == BOT):
            out[(z, rho, ys)] = lik; return
        for y in range(ny):
            rec(z, rho, ys + (y,), lik*S[x][y])
        rec(z, rho, ys + (BOT,), lik*(1 - sum(S[x])))
    def rec_top(z, rho):
        rec(z, rho, (), Fr(1))
    for z in range(nz):
        for rho in range(nrho):
            rec_top(z, rho)
    return {r: (l, base*l) for r, l in out.items()}

ok_mass = True; ok_len0 = False; worst_scheffe = Fr(0); n_ties = 0
for trial in range(300):
    nz, nrho, nx, ny, L = 2, 2, 3, 2, 3
    nxt = random_scaffold(nz, nrho, nx, ny, L)
    S1 = random_sampler(nx, ny, semi=(trial % 2 == 0)); S2 = random_sampler(nx, ny, semi=(trial % 3 == 0))
    R1 = runs_and_laws(nxt, nz, nrho, ny, L, S1); R2 = runs_and_laws(nxt, nz, nrho, ny, L, S2)
    assert set(R1) == set(R2)
    # complete runs: a run ending in BOT has no further call; a run of length 0 is allowed
    if any(len(r[2]) == 0 for r in R1): ok_len0 = True
    if sum(p for (_, p) in R1.values()) != 1 or sum(p for (_, p) in R2.values()) != 1: ok_mass = False
    # Scheffe identity with the set A = {L_1 > L_2} (strict), and with ties added
    A = [r for r in R1 if R1[r][0] > R2[r][0]]
    ties = [r for r in R1 if R1[r][0] == R2[r][0] and R1[r][0] > 0]
    n_ties += len(ties) > 0
    tvd = sum(abs(R1[r][1] - R2[r][1]) for r in R1)/2
    d1 = sum(R1[r][1] - R2[r][1] for r in A)
    d2 = sum(R1[r][1] - R2[r][1] for r in A + ties)
    worst_scheffe = max(worst_scheffe, abs(tvd - d1), abs(tvd - d2))
print("(1) Lemma 1.1 on 300 random scaffolds (horizon 3, STOP at any step, adaptive inputs, semimeasure samplers with 'no answer'):")
print("    leaf probabilities sum to 1 exactly:", ok_mass, "; runs with no call occurred:", ok_len0)
print("    Lemma 3.2(a) (Scheffe) for run laws, with strict set and with ties added (", n_ties, "trials had ties): max error =", worst_scheffe)

# ------------------------------------------------------------------ (2) Lemma 2.1, exact binomial tails
worst_up = 0.0; worst_lo = 0.0; worst_two = 0.0; worst_one = 0.0
qs = [0.0, 1e-6, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 0.99, 0.999999, 1.0]
for N in (1, 2, 3, 5, 10, 30, 100, 300):
    for q in qs:
        pmf = binom_pmf(N, q)
        up = [sum(pmf[k:]) for k in range(N+2)]          # Pr[S >= k]
        lo = [sum(pmf[:k+1]) for k in range(N+1)]        # Pr[S <= k]
        for k in range(N+1):
            x = k/N
            if x >= q:
                b = exp(-N*kl(x, q)) if kl(x, q) < INF else 0.0
                if b > 0: worst_up = max(worst_up, up[k]/b)
                else: assert up[k] == 0.0
            if x <= q:
                b = exp(-N*kl(x, q)) if kl(x, q) < INF else 0.0
                if b > 0: worst_lo = max(worst_lo, lo[k]/b)
                else: assert lo[k] == 0.0
        for a in (1e-3, 0.01, 0.05, 0.2, 0.7, 2.0, 5.0):
            two = sum(pmf[k] for k in range(N+1) if kl(k/N, q) > a)
            oneu = sum(pmf[k] for k in range(N+1) if k/N > q and kl(k/N, q) > a)
            onel = sum(pmf[k] for k in range(N+1) if k/N < q and kl(k/N, q) > a)
            b = exp(-N*a)
            if b < 1e-290:                       # the bound underflows; then the exact probabilities must be (numerically) zero too
                assert two < 1e-280 and oneu < 1e-280 and onel < 1e-280, (N, q, a, two)
                continue
            worst_two = max(worst_two, two/(2*b))
            worst_one = max(worst_one, oneu/b, onel/b)
print("(2) Lemma 2.1, exact binomials, N in {1..300}, q in a grid that contains 0 and 1:")
print(f"    max Pr[Qhat >= x]/exp(-N kl) = {worst_up:.6f}, max Pr[Qhat <= x]/exp(-N kl) = {worst_lo:.6f} (must be <= 1)")
print(f"    max Pr[kl(Qhat||q) > a]/(2 e^-Na) = {worst_two:.6f}; max one-sided/(e^-Na) = {worst_one:.6f} (must be <= 1)")

# ------------------------------------------------------------------ (3) Lemma 2.2 on a grid with end points
viol = 0; G = 200
for i in range(G+1):
    for j in range(G+1):
        p, q = i/G, j/G
        d = kl(p, q)
        if d + 1e-12 < 2*(p-q)**2: viol += 1
        m = max(p, q)
        if m > 0 and d + 1e-12 < (p-q)**2/(2*m): viol += 1
        if p == 0 and q < 1 and abs(d - log(1/(1-q))) > 1e-12: viol += 1
        if p == 0 and d + 1e-12 < q: viol += 1
print("(3) Lemma 2.2 (i), (ii), (iii) on a 201 x 201 grid including p, q in {0, 1}: violations =", viol)

# ------------------------------------------------------------------ (4) Corollaries 2.4 and 2.6: the kl-interval
def kl_interval(ph, a):
    """{q : kl(ph||q) <= a} = [lo, hi], by bisection."""
    lo_, hi_ = 0.0, ph
    for _ in range(200):
        mid = (lo_+hi_)/2
        if kl(ph, mid) <= a: hi_ = mid
        else: lo_ = mid
    left = hi_
    lo_, hi_ = ph, 1.0
    for _ in range(200):
        mid = (lo_+hi_)/2
        if kl(ph, mid) <= a: lo_ = mid
        else: hi_ = mid
    return left, lo_
v24 = 0; v26 = 0; cnt = 0; slack26 = 0.0
for _ in range(20000):
    a = 10**random.uniform(-5, 0.5)
    ph = random.choice([0.0, 1.0, random.random(), 10**random.uniform(-6, 0), 1 - 10**random.uniform(-6, 0)])
    lo_, hi_ = kl_interval(ph, a); cnt += 1
    for q in (lo_, hi_):
        if abs(ph - q) > sqrt(a/2) + 1e-9: v24 += 1                                   # 2.4(a)
        if abs(ph - q) > sqrt(2*a*max(ph, q)) + 1e-9: v24 += 1                        # 2.4(b)
        if not (ph - sqrt(2*a*ph) - 1e-9 <= q <= ph + sqrt(2*a*ph) + 2*a + 1e-9): v24 += 1
        if sqrt(ph) > sqrt(q) + sqrt(2*a) + 1e-9: v24 += 1
    if ph == 0.0 and hi_ > 1 - exp(-a) + 1e-9: v24 += 1                               # 2.4(c)
    if ph == 1.0 and 1 - lo_ > a + 1e-9: v24 += 1
    # 2.6(ii): for Q(R) = q anywhere in the interval and Q'(R) = q' anywhere in the interval
    for t in (0.0, 0.1, 0.5, 0.9, 1.0):
        q = lo_ + t*(hi_ - lo_)
        worst = max(hi_ - q, q - lo_)
        qb = min(q, 1-q)
        bound = min(sqrt(2*a), 2*sqrt(2*a*qb) + 6*a)
        if worst > bound + 1e-9: v26 += 1
        slack26 = max(slack26, worst/bound if bound > 0 else 0)
    if ph == 0.0 and hi_ > a + 1e-9: v26 += 1                                         # 2.6(iii)
print(f"(4) Corollary 2.4(a),(b),(c) at the end points of {{q : kl(phat||q) <= a}} for {cnt} random (phat, a): violations = {v24}")
print(f"    Corollary 2.6(ii),(iii) for Q(R), Q'(R) anywhere in that interval: violations = {v26}; largest |Q'-Q|/bound = {slack26:.4f}")

# ------------------------------------------------------------------ (5) Theorem 2.5: exact failure probabilities for one test
# eps := pi(R)*delta.  (a): |Qhat - q| > tol.  (b): Qhat = 0 and q > ln(1/eps)/N.  (c): the union.
worst_a = worst_b = worst_c = 0.0; arg_c = None; worst_c_small = 0.0; arg_small = None
for N in (1, 2, 3, 5, 8, 13, 20, 50, 100, 300, 1000):
    for eps in (0.999, 0.95, 0.905, 0.8, 0.5, 0.3, 0.2, 0.1, 0.03, 0.01, 1e-3, 1e-5):
        tol = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N
        cand = set([0.0, 1.0, 0.1, 0.2, 0.5, min(1.0, qR*1.0000001), min(1.0, tol), min(1.0, tol*1.0000001)])
        cand |= {i/200 for i in range(201)} | {min(1.0, qR*(1+j/20)) for j in range(1, 40)}
        for q in sorted(cand):
            pmf = binom_pmf(N, q)
            fa = sum(pmf[k] for k in range(N+1) if abs(k/N - q) > tol)
            fb = pmf[0] if q > qR else 0.0
            fc = sum(pmf[k] for k in range(N+1) if abs(k/N - q) > tol or (k == 0 and q > qR))
            worst_a = max(worst_a, fa/eps); worst_b = max(worst_b, fb/eps)
            if fc/eps > worst_c: worst_c, arg_c = fc/eps, (N, eps, q)
            if eps <= 0.2 and fc/eps > worst_c_small: worst_c_small, arg_small = fc/eps, (N, eps, round(q, 6))
print("(5) Theorem 2.5 for one test, exact binomials (eps = pi*delta):")
print(f"    (a) max failure/eps = {worst_a:.4f} (<= 1);  (b) max failure/eps = {worst_b:.4f} (<= 1)")
print(f"    (c) joint: max failure/eps = {worst_c:.4f} at (N, eps, q) = {arg_c}  (the draft claims <= 1; the file proves <= 1.5)")
print(f"    (c) joint, restricted to eps <= 0.2: max = {worst_c_small:.4f} at {arg_small}")
# the counterexample of the file
N, eps, q = 1, 0.905, 0.2
tol = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N
print(f"    counterexample N=1, delta=0.905, Q(R)=0.2: tol = {tol:.4f}, ln(1/delta)/N = {qR:.4f}; run in R: |1-0.2| = 0.8 > tol: {0.8 > tol};"
      f" run not in R: Q(R) = 0.2 > {qR:.4f}: {0.2 > qR}; so the joint statement fails with probability 1")
# how far can the joint failure exceed eps?  sup over q for N = 1: failure = 1 whenever tol < min(q, 1-q) ... scan
best = 0.0
for eps_i in range(1, 1000):
    eps = eps_i/1000
    for N in (1, 2, 3, 4):
        tol = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N
        for qi in range(0, 1001):
            q = qi/1000
            pmf = binom_pmf(N, q)
            fc = sum(pmf[k] for k in range(N+1) if abs(k/N - q) > tol or (k == 0 and q > qR))
            best = max(best, fc/eps)
print(f"    sup of joint failure/eps over N <= 4, eps in (0,1), q on a grid: {best:.4f} (the proved constant is 1.5)")

# ------------------------------------------------------------------ (6) Remark 2.7(4), which Section 5.1 uses for "the second price cannot be lowered"
# M independent tests of probability 1/2: the largest deviation of the empirical frequencies is of the order sqrt(ln M / N).
print("(6) Remark 2.7(4): M independent events of probability 1/2, N runs; exact probability that the largest |Qhat - 1/2| is at least t:")
for N in (100, 400, 2500):
    pmf = [exp(math.lgamma(N+1) - math.lgamma(k+1) - math.lgamma(N-k+1) - N*log(2)) for k in range(N+1)]
    for M in (10**2, 10**4, 10**6):
        if log(M) > N: continue
        t_lo = 0.5*sqrt(log(M)/N); t_hi = sqrt(log(2*M/0.1)/(2*N))
        p_lo = sum(pmf[k] for k in range(N+1) if abs(k/N - 0.5) >= t_lo)
        p_hi = sum(pmf[k] for k in range(N+1) if abs(k/N - 0.5) > t_hi)
        P_lo = 1 - (1 - p_lo)**M; P_hi = 1 - (1 - p_hi)**M
        print(f"    N = {N:5d}, M = {M:8d}: Pr[max >= (1/2) sqrt(ln M/N) = {t_lo:.4f}] = {P_lo:.6f};  Pr[max > tol_N with pi = 1/M, delta = 0.1 (= {t_hi:.4f})] = {P_hi:.4f} (<= 0.1)")
