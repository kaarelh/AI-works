"""k6: Section 5 of notes-final.md in the per-query scheme (pq) and the fixed-design scheme (fd);
the frozen-label failure with repeats. Written for the revision after referee-A.md (issue 1) and
referee-B.md (issues 1, 4).

(A) Lemma 5.1, the three evidence identities/inequalities, by exact enumeration:
    (pq) per-query labels, inputs i.i.d. with repeats:  E sqrt(Lambda_n) = (1 - gamma)^n   (equality);
    (fd) fixed domain, labels independent:              E sqrt(Lambda)   = prod_x (1 - Hel_x) (equality);
    (wor) the Maclaurin step:  E prod_i a(x_i) (without replacement) <= (mean a)^n;
    frozen labels with repeats: E sqrt(Lambda_n) = E prod_{distinct x} (1 - Hel_x), which exceeds (1-gamma)^n.
(B) Lemma 5.2 in the fd form and Lemma 5.3 at fixed n, by exact enumeration of all label vectors on a
    fixed domain of 10 distinct inputs, for 300 random classes with Kraft sum <= 1.
(C) The frozen counterexample of referee A (two programs of length 1): exact probabilities at finite n.
(D) A per-query noisy parity on X0 = {0,1}^8 (M = 256, so inputs repeat), with the k3-type class
    (constants, parities, partial parities, memorisers of the parity a*, the full table; prefix codes,
    Kraft sum <= 1).  For n up to 2^20 >> M:
      exact structure function of the per-query point set {(l(pi), F(pi))}, F = -sum_i log nu_pi(y_i|x_i);
      Lemma 5.2 over the whole class (slack S), Lemma 5.3 (slack T);
      Thm 5.4(i) (profile steepness), Thm 5.4(iii) wherever its sample-size hypothesis holds;
      Cor 5.5 and Thm 5.6 sample sizes, with the empirical frequency that every lambda-MAP is pi*;
      the growth of the left steepness and the right slope (Cor 5.7), and the lambda = 1 MAP (Cor 5.7(d)).
Seeded: numpy default_rng(6) for (A)-(B), default_rng(60 + k) for the k-th sample size in (D).
Python 3.11, numpy.
"""
import itertools
import math
import numpy as np

LOG2E = math.log2(math.e)
rngA = np.random.default_rng(6)


def hel(P, Q):
    """squared Hellinger 1 - sum_y sqrt(P(y) Q(y)) (Q may be a sub-probability)."""
    return 1.0 - float(np.sum(np.sqrt(np.asarray(P) * np.asarray(Q))))


print("=" * 104)
print("(A) Lemma 5.1 by exact enumeration")
# (pq): M = 3 inputs, |Y| = 2, n <= 6, all (x, y) sequences
worst_pq = 0.0
for trial in range(20):
    M3 = 3
    mu = rngA.dirichlet(np.ones(M3))
    nu = rngA.uniform(0.05, 0.95, M3)
    nupi = rngA.uniform(0.0, 1.0, (M3, 2))
    nupi = nupi / nupi.sum(axis=1, keepdims=True) * rngA.uniform(0.6, 1.0, (M3, 1))   # sub-probability
    Nu = np.stack([1 - nu, nu], axis=1)
    gam = sum(mu[x] * hel(Nu[x], nupi[x]) for x in range(M3))
    for n in range(1, 7):
        tot = 0.0
        for seq in itertools.product(range(M3 * 2), repeat=n):
            pr, lr = 1.0, 1.0
            for s in seq:
                x, y = divmod(s, 2)
                pr *= mu[x] * Nu[x, y]
                lr *= nupi[x, y] / Nu[x, y]
            tot += pr * math.sqrt(lr)
        worst_pq = max(worst_pq, abs(tot - (1 - gam) ** n))
print(f"  (pq) E sqrt(Lambda_n) - (1-gamma)^n over 20 random (mu, nu, nu_pi), n <= 6: max |difference| = {worst_pq:.2e}")
# (fd): fixed domain of 8 distinct inputs, all 2^8 label vectors
worst_fd = 0.0
for trial in range(50):
    m = 8
    nu = rngA.uniform(0.05, 0.95, m)
    q = rngA.uniform(0.0, 1.0, m)
    q2 = (1 - q) * rngA.uniform(0.5, 1.0, m)            # sub-probability: P(1) = q, P(0) = q2 <= 1-q
    prod = np.prod([1 - hel([1 - nu[i], nu[i]], [q2[i], q[i]]) for i in range(m)])
    tot = 0.0
    for ys in itertools.product([0, 1], repeat=m):
        pr, lr = 1.0, 1.0
        for i, y in enumerate(ys):
            pnu = nu[i] if y else 1 - nu[i]
            ppi = q[i] if y else q2[i]
            pr *= pnu
            lr *= ppi / pnu
        tot += pr * math.sqrt(lr)
    worst_fd = max(worst_fd, abs(tot - prod))
print(f"  (fd) E sqrt(Lambda) - prod_x (1 - Hel_x) over 50 random kernels on 8 inputs: max |difference| = {worst_fd:.2e}")


# (wor): Maclaurin, S_n = e_n / binom(M, n) <= (mean)^n, exact elementary symmetric polynomials
def elem_sym(vals, n):
    e = [1.0] + [0.0] * n
    for v in vals:
        for k in range(n, 0, -1):
            e[k] += e[k - 1] * v
    return e


worst_ratio, cases = 0.0, 0
for trial in range(400):
    Mp = int(rngA.integers(2, 16))
    vals = rngA.uniform(0, 1, Mp)
    if trial % 4 == 0:
        vals[rngA.integers(0, Mp)] = 0.0                  # zeros of a included
    if trial % 7 == 0:
        vals[:] = rngA.uniform(0.95, 1.0, Mp)
    e = elem_sym(vals, Mp)
    mean = float(np.mean(vals))
    for n in range(1, Mp + 1):
        Sn = e[n] / math.comb(Mp, n)
        cases += 1
        if mean > 0:
            worst_ratio = max(worst_ratio, Sn / mean ** n)
print(f"  (wor) E prod a(x_i) without replacement / (mean a)^n over {cases} (population, n) cases: max = {worst_ratio:.6f} (<= 1 required)")
assert worst_ratio <= 1 + 1e-12
# frozen labels with repeats: mu on 3 atoms, E sqrt(Lambda_n) = E prod over DISTINCT inputs of (1 - Hel_x)
mu = np.array([0.6, 0.3, 0.1])
hx = np.array([0.0, 0.0, 1 - math.sqrt(0.5)])      # nu = coin; pi = coin except label 0 surely at x = 2
gam = float(mu @ hx)
for n in [1, 5, 20, 100]:
    # E prod_{x in distinct(x_1..x_n)} (1 - hx) = sum over subsets of the probability that exactly they appear
    pr_x2_seen = 1 - (1 - mu[2]) ** n
    frozen = pr_x2_seen * (1 - hx[2]) + (1 - pr_x2_seen)
    verdict = "the (pq)/(wor) bound fails" if frozen > (1 - gam) ** n + 1e-12 else "equal: no repeat possible yet"
    print(f"  frozen, n={n:3d}: E sqrt(Lambda_n) = {frozen:.6f}  vs  (1-gamma)^n = {(1 - gam) ** n:.3e}  ({verdict})")

print("=" * 104)
print("(B) Lemma 5.2 (fd form) and Lemma 5.3 (fixed n), exact over all 2^10 label vectors of a fixed domain")
m = 10
ys_all = np.array(list(itertools.product([0, 1], repeat=m)))          # 1024 x 10
worst52, worst53, nclasses, frac_dequiv = 0.0, 0.0, 0, []
ts = [0.5, 1.0, 2.0, 3.0]
for cls in range(300):
    nu = rngA.uniform(0.03, 0.97, m)
    K = int(rngA.integers(5, 40))
    lengths = rngA.integers(1, 12, K).astype(float)
    while np.sum(2.0 ** -lengths) > 1:
        lengths += 1
    progs = []
    for k in range(K):
        kind = rngA.integers(0, 4)
        if kind == 0:                                   # random kernel
            p1 = rngA.uniform(0, 1, m)
        elif kind == 1:                                 # nu perturbed at a few inputs
            p1 = nu.copy()
            idx = rngA.choice(m, int(rngA.integers(1, 4)), replace=False)
            p1[idx] = np.clip(p1[idx] + rngA.normal(0, 0.2, len(idx)), 0, 1)
        elif kind == 2:                                 # deterministic
            p1 = rngA.integers(0, 2, m).astype(float)
        else:                                           # equal to nu on the domain (D-equivalent)
            p1 = nu.copy()
        mass = rngA.uniform(0.7, 1.0) if rngA.random() < 0.3 else 1.0   # some sub-probability programs
        progs.append((p1 * mass, (1 - p1) * mass))
    # exact probabilities of the label vectors
    P = np.prod(np.where(ys_all == 1, nu, 1 - nu), axis=1)
    Sbits = -np.log2(P)
    slack52 = np.full(len(ys_all), np.inf)
    T = np.full(len(ys_all), np.inf)
    ndeq = 0
    for (p1, p0), l in zip(progs, lengths):
        with np.errstate(divide="ignore"):
            Fp = -np.sum(np.log2(np.where(ys_all == 1, p1, p0)), axis=1)
        HD = sum(1 - math.sqrt(nu[i] * p1[i]) - math.sqrt((1 - nu[i]) * p0[i]) for i in range(m))
        HD = max(HD, 0.0)
        ndeq += HD < 1e-12
        slack52 = np.minimum(slack52, (Fp - Sbits - 2 * LOG2E * HD + 2 * l) / 2)
        T = np.minimum(T, Fp + l - Sbits)
    frac_dequiv.append(ndeq / K)
    for t in ts:
        worst52 = max(worst52, float(P[slack52 <= -t].sum()) / 2.0 ** -t)
        worst53 = max(worst53, float(P[T <= -t].sum()) / 2.0 ** -t)
    nclasses += 1
print(f"  {nclasses} random classes (5-39 programs; random, perturbed, deterministic, D-equivalent, sub-probability)")
print(f"  max over classes and t in {ts} of P[S_D <= -t] / 2^-t = {worst52:.4f}  (Lemma 5.2, fd form; <= 1 required)")
print(f"  max over classes and t of P[T <= -t] / 2^-t = {worst53:.4f}  (Lemma 5.3 at fixed n; <= 1 required)")
assert worst52 <= 1 + 1e-9 and worst53 <= 1 + 1e-9

print("=" * 104)
print("(C) Referee A's frozen counterexample: class {pi* = coin, pi' = coin except label 0 surely at x1}, both length 1")
mu1 = 0.5
for n in [1, 4, 16, 64]:
    frozen = 0.5 * (1 - (1 - mu1) ** n)                 # x1 seen and its frozen label is 0
    fresh = (1 - mu1 / 2) ** n                          # no label 1 at x1 among the queries (pi' still alive)
    fresh_unique = fresh - (1 - mu1) ** n                # alive and x1 queried at least once: Lambda(pi') > 1
    print(f"  n={n:3d}: frozen P[pi' is the unique lambda-MAP, every lambda] = {frozen:.4f};  per-query P[pi' unique MAP] = {fresh_unique:.2e}")
print("  frozen: -> 1/2 as n -> infinity (Cor 5.7(c) fails in the frozen reading); per-query: -> 0")

# ======================================================================================================
print("=" * 104)
print("(D) per-query noisy parity on {0,1}^8, inputs uniform with repeats, fresh label at every query")
TAG, BMAX, d = 3, 6, 8
M = 2 ** d
p = 1 / 8
eps = 0.05


def gam_code(k):
    return 2 * int(math.floor(math.log2(k + 1))) + 1


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


RATES = [(b, 1 + gam_code(b) + b - 1) for b in range(1, BMAX + 1)]
GRID = [(j / 2 ** b, L) for b, L in RATES for j in range(1, 2 ** b, 2)]
GQ = np.array([q for q, _ in GRID])
GL = np.array([L for _, L in GRID])
GSTART = np.r_[0, np.cumsum([2 ** (b - 1) for b, _ in RATES])[:-1]]
GLEN = np.array([L for _, L in RATES])
LQ, L1Q = np.log2(GQ), np.log2(1 - GQ)


def hb(a, b):
    return 1 - math.sqrt(a * b) - math.sqrt((1 - a) * (1 - b))


rngD0 = np.random.default_rng(60)
astar = int(rngD0.integers(1, M))
ellstar = TAG + d + dict(RATES)[3]                     # pi* = F1(a*, q = 1/8), rate precision b = 3
Hs = np.array([hb(p, q) for q in GQ])
Hd = np.array([hb(p, 1 - q) for q in GQ])
Hhalf = hb(p, 0.5)
h_F0 = 0.5 * np.array([hb(p, q) for q in GQ]) + 0.5 * np.array([hb(1 - p, q) for q in GQ])
hdet_true = 1 - math.sqrt(1 - p)
hdet_other = 0.5 * (1 - math.sqrt(1 - p)) + 0.5 * (1 - math.sqrt(p))


def h_F2(v, same):
    sub = Hs if same else 0.5 * Hs + 0.5 * Hd
    return 2.0 ** -v * sub + (1 - 2.0 ** -v) * Hhalf


def h_F3(j):
    return (j / M) * (1 - math.sqrt(p)) + (1 - j / M) * Hs


# every program of the class as (length, gap, count): exact, all lengths
ENTRIES = []
for idx, (q, Lq) in enumerate(GRID):
    ENTRIES.append((TAG + Lq, h_F0[idx], 1))
    ENTRIES.append((TAG + d + Lq, Hs[idx], 1))
    ENTRIES.append((TAG + d + Lq, 0.5 * Hs[idx] + 0.5 * Hd[idx], M - 1))
ENTRIES.append((TAG + 2, hdet_other, 2))
ENTRIES.append((TAG + d + 1, hdet_true, 1))
ENTRIES.append((TAG + d + 1, hdet_other, M - 1))
for v in range(1, d + 1):
    base = TAG + gam_code(v) + (d - v)
    ht, ho = h_F2(v, True), h_F2(v, False)
    for idx, (q, Lq) in enumerate(GRID):
        ENTRIES.append((base + Lq, ht[idx], 1))
        if d - v > 0:
            ENTRIES.append((base + Lq, ho[idx], 2 ** (d - v) - 1))
    ENTRIES.append((base + 1, 2.0 ** -v * hdet_true + (1 - 2.0 ** -v) * Hhalf, 1))
    if d - v > 0:
        ENTRIES.append((base + 1, 2.0 ** -v * (0.5 * hdet_true + 0.5 * (1 - math.sqrt(p))) + (1 - 2.0 ** -v) * Hhalf,
                        2 ** (d - v) - 1))
F3BASE = {}
for j in range(1, M + 1):
    base = TAG + d + gam_code(j) + math.ceil(log2binom(M, j) - 1e-9)
    F3BASE[j] = base
    cnt = math.comb(M, j)
    hj = h_F3(j)
    for idx, (q, Lq) in enumerate(GRID):
        ENTRIES.append((base + Lq, hj[idx], cnt))
    ENTRIES.append((base + 1, (j / M) * (1 - math.sqrt(p)) + (1 - j / M) * hdet_true, cnt))
LF4 = TAG + gam_code(d) + M
kraft = sum(c * 2.0 ** -l for l, h, c in ENTRIES) + 2.0 ** M * 2.0 ** -LF4
assert sum(1 for l, h, c in ENTRIES if h < 1e-15) == 1, "pi* must be the only equivalent program"
assert kraft <= 1
print(f"  d={d}, M={M}, p={p}, a*={astar}, l* = l(pi*) = {ellstar}; rates j/2^b, b <= {BMAX}; Kraft sum = {kraft:.4f}")


def gamma_le(L, strict=False):
    return min(h for l, h, c in ENTRIES if h > 1e-15 and (l < L if strict else l <= L))


def gamma_eq(l):
    hs = [h for ll, h, c in ENTRIES if ll == l and h > 1e-15]
    return min(hs) if hs else math.inf


def W_near(lam, g, Llam):
    return sum(c * 2.0 ** (-lam * (l - ellstar)) for l, h, c in ENTRIES if 1e-15 < h < g and ellstar < l <= Llam)


gamma_minus = gamma_le(ellstar, strict=True)
rate57a = 2 * LOG2E * min(gamma_eq(l) / (ellstar - l) for l in range(0, ellstar) if gamma_eq(l) < math.inf)
gamma0 = gamma_le(ellstar)
print(f"  margins: gamma_< (shorter than l*) = {gamma_minus:.5f}; gamma_0 (length <= l*) = {gamma0:.5f}; "
      + "; ".join(f"gamma_L({L}) = {gamma_le(L):.3e}" for L in [ellstar + 1, ellstar + 2, ellstar + 3, ellstar + 11]))

x_all = np.arange(M)


def popparity(x):
    x = x.copy()
    par = np.zeros_like(x)
    while x.any():
        par ^= x & 1
        x >>= 1
    return par


f_star = popparity(x_all & astar)


def wht(v):
    v = v.astype(np.int64).copy()
    h = 1
    while h < len(v):
        v = v.reshape(-1, 2 * h)
        a, b = v[:, :h].copy(), v[:, h:].copy()
        v[:, :h], v[:, h:] = a + b, a - b
        v = v.reshape(-1)
        h *= 2
    return v


def ratefit(k, n):
    """fit of k mismatches among n queries at every grid rate (vector over GRID)."""
    return -(k * LQ + (n - k) * L1Q)


def one_run(n, rs):
    nx = rs.multinomial(n, np.full(M, 1.0 / M))
    p1 = np.where(f_star == 1, 1 - p, p)                # nu(1 | x)
    n1 = rs.binomial(nx, p1)
    n0 = nx - n1
    flips = np.where(f_star == 1, n0, n1)               # queries whose label differs from f*(x)
    kstar = int(flips.sum())
    S = kstar * math.log2(1 / p) + (n - kstar) * math.log2(1 / (1 - p))
    best_ne = {}                                        # length -> least fit over NON-equivalent programs
    slack = [math.inf]

    def put(l, fit):
        if fit < best_ne.get(l, math.inf):
            best_ne[l] = fit

    def put_vec(base, fitvec):
        for Lb, fb in zip(GLEN, np.minimum.reduceat(fitvec, GSTART)):
            put(base + int(Lb), float(fb))

    def sl(fitvec, hvec, lvec):
        slack[0] = min(slack[0], float(np.min((fitvec - S - 2 * LOG2E * n * hvec + 2 * lvec) / 2)))

    def sl1(fit, h, l):                                 # one deterministic program (fit 0 or infinity)
        if fit < math.inf:
            slack[0] = min(slack[0], (fit - S - 2 * LOG2E * n * h + 2 * l) / 2)

    # F0
    N1 = int(n1.sum())
    put(TAG + 2, 0.0 if N1 in (0, n) else math.inf)
    sl1(0.0 if N1 in (0, n) else math.inf, hdet_other, TAG + 2)
    f0 = ratefit(N1, n)
    put_vec(TAG, f0)
    sl(f0, h_F0, TAG + GL)
    # F1 via WHT of g(x) = n0 - n1; mismatches k(a') = (n - W(a'))/2
    W = wht(n0 - n1)
    k_all = (n - W) // 2
    Ft = ratefit(int(k_all[astar]), n)
    ko = np.delete(k_all, astar)
    Fo = np.minimum(ratefit(int(ko.min()), n), ratefit(int(ko.max()), n))
    # pi* itself is F1(a*, q = 1/8): exclude that single (a*, q) entry from the non-equivalent table
    Ft_ne = Ft.copy()
    istar = [i for i, (q, L) in enumerate(GRID) if abs(q - p) < 1e-12][0]
    Ft_ne[istar] = math.inf
    put_vec(TAG + d, np.minimum(Ft_ne, Fo))
    put(TAG + d + 1, 0.0 if k_all.min() == 0 else math.inf)
    sl1(0.0 if k_all[astar] == 0 else math.inf, hdet_true, TAG + d + 1)
    sl1(0.0 if ko.min() == 0 else math.inf, hdet_other, TAG + d + 1)
    sl(Ft, Hs, TAG + d + GL)                            # includes pi* (slack l* > 0), harmless
    sl(Fo, 0.5 * Hs + 0.5 * Hd, TAG + d + GL)
    # F2: partial parities, unknown top v coordinates
    for v in range(1, d + 1):
        sub = (x_all >> (d - v)) == 0
        nsub = int(nx[sub].sum())
        base = TAG + gam_code(v) + (d - v)
        gsub = (n0 - n1)[sub]
        ksub = (nsub - wht(gsub)) // 2
        pref_true = astar & ((1 << (d - v)) - 1)
        Ftv = ratefit(int(ksub[pref_true]), nsub) + (n - nsub)
        sl(Ftv, h_F2(v, True), base + GL)
        allf = Ftv
        if len(ksub) > 1:
            kot = np.delete(ksub, pref_true)
            Fov = np.minimum(ratefit(int(kot.min()), nsub), ratefit(int(kot.max()), nsub)) + (n - nsub)
            sl(Fov, h_F2(v, False), base + GL)
            allf = np.minimum(Ftv, Fov)
        put_vec(base, allf)
        put(base + 1, (n - nsub) + (0.0 if ksub.min() == 0 else math.inf))
        hv_t = 2.0 ** -v * hdet_true + (1 - 2.0 ** -v) * Hhalf
        hv_o = 2.0 ** -v * (0.5 * hdet_true + 0.5 * (1 - math.sqrt(p))) + (1 - 2.0 ** -v) * Hhalf
        sl1((n - nsub) + (0.0 if ksub[pref_true] == 0 else math.inf), hv_t, base + 1)
        if len(ksub) > 1:
            sl1((n - nsub) + (0.0 if np.delete(ksub, pref_true).min() == 0 else math.inf), hv_o, base + 1)
    # F3: memorisers of a* at j inputs (label f* xor 1 surely there); best J = unanimous-flipped inputs
    #     with the most queries, padded with unqueried inputs
    unan = np.sort(nx[(nx > 0) & (flips == nx)])[::-1]
    nunq = int((nx == 0).sum())
    removed = np.r_[0, np.cumsum(unan)]
    for j in range(1, M + 1):
        base = F3BASE[j]
        if j <= len(unan):
            r = int(removed[j])
        elif j <= len(unan) + nunq:
            r = int(removed[-1])
        else:
            continue
        fj = ratefit(kstar - r, n - r)
        put_vec(base, fj)
        put(base + 1, 0.0 if kstar - r == 0 else math.inf)
        sl(fj, h_F3(j), base + GL)
        sl1(0.0 if kstar - r == 0 else math.inf, (j / M) * (1 - math.sqrt(p)) + (1 - j / M) * hdet_true, base + 1)
    # F4: the full table, finite iff every queried input is unanimous
    if np.all((n0 == 0) | (n1 == 0)):
        put(LF4, 0.0)
        # least-gap consistent table: the queried labels, and f* at unqueried inputs
        lab = np.where(n1 > 0, 1, 0)
        pl = np.where(lab == 1, p1, 1 - p1)
        h4 = (np.sum(np.where(nx > 0, 1 - np.sqrt(pl), 0.0)) + np.sum(nx == 0) * (1 - math.sqrt(1 - p))) / M
        sl1(0.0, h4, LF4)
    pts = sorted((l, f) for l, f in best_ne.items() if f < math.inf)
    Tv = min([f + l for l, f in pts] + [S + ellstar]) - S
    left = [(f - S) / (ellstar - l) for l, f in pts if l < ellstar]
    right = [(S - f) / (l - ellstar) for l, f in pts if l > ellstar]
    sminus = min(left)
    splus = max([0.0] + right)
    eq_tie = best_ne.get(ellstar, math.inf) <= S + 1e-9
    is_vertex = (not eq_tie) and all(f > S + 1e-9 for l, f in pts if l < ellstar) and sminus > splus

    def map_is_pistar(lam):
        return lam * ellstar + S < min(lam * l + f for l, f in pts) - 1e-9

    return dict(S=S, slack=slack[0], T=Tv, sminus=sminus, splus=splus, is_vertex=is_vertex,
                best_ne=best_ne, map=map_is_pistar)


def sigma_profile(n):
    vals = [(2 * LOG2E * n * gamma_eq(l) - 2 * l - 2 * math.log2(1 / eps)) / (ellstar - l)
            for l in range(0, ellstar) if gamma_eq(l) < math.inf]
    return min(vals)


CAPS = [ellstar + 2, ellstar + 3, ellstar + 5]
NS = [64, 256, 1024, 4096, 16384, 65536, 262144, 1048576]
SEEDS = 200
LAMS = [1.0, 1.5, 2.0, 4.0, 8.0]
print(f"  Cor 5.7(a) rate: 2 log e min_(l < l*) gamma_=(l)/(l* - l) = {rate57a:.5f} (a.s. lower bound on liminf left steepness / n)")
print(f"  {SEEDS} samples per n, eps = {eps}")
for L in CAPS:
    gL = gamma_le(L)
    print(f"  Thm 5.4(iii) cap lbar={L}: gamma_lbar={gL:.3e}, needs n > {(L + math.log2(1 / eps)) / (LOG2E * gL):.4g}, "
          f"tau_lbar = {1 + (ellstar + math.log2(1 / eps)) / (L - ellstar):.3f}")
n0s = {}
for lam in [1.5, 2.0, 4.0, 8.0]:
    Llam = ellstar + (ellstar + math.log2(1 / eps)) / (lam - 1)
    gL = gamma_le(Llam)
    num = max(0.0, 2 - lam) * Llam + lam * ellstar + 2 * math.log2(1 / eps)
    n0 = num / (2 * LOG2E * gL)
    n0near = num / (2 * LOG2E * gamma0)
    Wn = W_near(lam, gamma0, Llam)
    n0s[lam] = (n0, n0near, Wn)
    print(f"  lambda={lam}: lbar_lambda={Llam:.1f}, gamma_lbar={gL:.3e}; Cor 5.5 n0 = {n0:.4g} (prob >= {1 - 2 * eps:.2f}); "
          f"Thm 5.6 (gamma = gamma_0) n0 = {n0near:.4g}, W_near = {Wn:.4f}, prob >= {1 - 2 * eps - Wn:.3f}")
print("-" * 104)
for k, n in enumerate(NS):
    rs = np.random.default_rng(60 + k + 1)
    runs = [one_run(n, rs) for _ in range(SEEDS)]
    slk = np.array([r["slack"] for r in runs])
    Tv = np.array([r["T"] for r in runs])
    sm = np.array([r["sminus"] for r in runs])
    sp = np.array([r["splus"] for r in runs])
    vt = np.array([r["is_vertex"] for r in runs])
    print(f"n={n:8d} (n/M={n / M:8.2f}): (l*, S_n) a vertex in {vt.mean():.3f}; left steepness median {np.median(sm):10.2f} "
          f"(min {sm.min():9.2f}), /n = {np.median(sm) / n:.4f}; right slope median {np.median(sp):.3f} (max {sp.max():.3f}); "
          f"right slope < 1 in {np.mean(sp < 1):.3f}")
    print("    Lemma 5.2 P[S <= -t], t=1,2,3: " + ", ".join(f"{np.mean(slk <= -t):.3f}" for t in [1, 2, 3])
          + f" (bounds 0.5, 0.25, 0.125); min S = {slk.min():.2f}.  Lemma 5.3 P[T <= -t], t=1,2,3: "
          + ", ".join(f"{np.mean(Tv <= -t):.3f}" for t in [1, 2, 3]))
    sg = sigma_profile(n)
    if sg > 0:
        print(f"    Thm 5.4(i): profile steepness bound sigma_n = {sg:.2f}; holds in {np.mean(sm >= sg):.3f} (guaranteed >= {1 - eps:.2f})")
    else:
        print(f"    Thm 5.4(i): profile bound {sg:.2f} <= 0 (vacuous at this n)")
    for L in CAPS:
        gL = gamma_le(L)
        if n > (L + math.log2(1 / eps)) / (LOG2E * gL):
            tau = 1 + (ellstar + math.log2(1 / eps)) / (L - ellstar)
            flat = np.mean([all(r["best_ne"].get(l, math.inf) > r["S"] for l in range(0, L + 1)) for r in runs])
            sec = np.mean([all((r["S"] - f) / (l - ellstar) < tau for l, f in r["best_ne"].items() if l > L)
                           for r in runs])
            inside = [r for r, s in zip(runs, sm) if sg > tau]
            okmap = np.mean([all(r["map"](lam) for lam in [tau * 1.01, math.sqrt(tau * sg), sg / 1.01]) for r in inside]) \
                if inside and sg > tau else float("nan")
            print(f"    Thm 5.4(iii) lbar={L}: hypothesis holds; flat part (no non-equivalent program of length <= lbar fits "
                  f"as well as pi*) in {flat:.3f}; secants beyond lbar < tau={tau:.2f} in {sec:.3f}; "
                  + (f"sigma_n={sg:.1f} > tau, every lambda-MAP = pi* at 3 lambdas in (tau, sigma_n) in {okmap:.3f}"
                     if sg > tau else "sigma_n <= tau"))
    fr = {lam: np.mean([r["map"](lam) for r in runs]) for lam in LAMS}
    print("    every lambda-MAP is pi*: " + ", ".join(f"lambda={lam}: {fr[lam]:.3f}" for lam in LAMS))
    for lam, (n0, n0near, Wn) in n0s.items():
        if n >= n0:
            print(f"      Cor 5.5 applies at lambda={lam} (n >= n0={n0:.3g}): frequency {fr[lam]:.3f} >= {1 - 2 * eps:.2f} required")
        if n >= n0near and 1 - 2 * eps - Wn > 0:
            print(f"      Thm 5.6 applies at lambda={lam} (n >= {n0near:.3g}): frequency {fr[lam]:.3f} >= {1 - 2 * eps - Wn:.3f} required")
