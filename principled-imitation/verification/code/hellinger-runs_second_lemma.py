"""Second check of proofs/hellinger-runs.md: Lemma 2.10, Corollary 2.11, Remark 2.12,
arithmetic of Theorem 3.1, Proposition 3.6, Theorem 2.7 (Step 0 (iii'), enclosure).
Independent implementation (does not import any earlier script)."""
import itertools, math, random
import numpy as np
import mpmath as mp

rng = random.Random(20261116)
nrng = np.random.default_rng(20261116)

def phi(u):
    return min(1.0, u + math.sqrt(u * u + 2 * u))

# ---------- (1) one-step inequality (*) on extreme laws ----------
# constraint E r^2 <= 1 is linear in the law of r, so point masses r0 <= 1 and
# two-point laws with E r^2 = 1 are the extreme points.
def U(x, m, g):
    return 0.5 * g * max(m - x, 0.0) ** 2
worst = -1e9
for _ in range(200000):
    m = rng.choice([1.0, 1.5, 2.0, 3.0, rng.uniform(1.0001, 5)])
    g = rng.uniform(0.1, 10)
    Lam = rng.choice([0.0, rng.uniform(0, 2 * m), rng.uniform(0, 10 * m)])
    if rng.random() < 0.3:
        r0 = rng.uniform(0, 1)
        laws = [(1.0, r0)]
    else:
        a = rng.uniform(0, 1); b = rng.uniform(1, 30)
        # weights w on a, 1-w on b with w a^2 + (1-w) b^2 = 1
        w = (b * b - 1) / (b * b - a * a)
        laws = [(w, a), (1 - w, b)]
    Er = sum(w * r for w, r in laws)
    lhs = sum(w * U(Lam * r, m, g) for w, r in laws)
    rhs = U(Lam, m, g) + g * m * m * (1 - Er)
    worst = max(worst, lhs - rhs)
print("(1) one step (*): max of E U(Lam r) - U(Lam) - g m^2 (1 - E r) over 200000 extreme laws: %.3e (must be <= 0 up to rounding)" % worst)

# pointwise inequalities used in (a) and (c)
w1 = 1e9; w2 = 1e9
for _ in range(100000):
    x = rng.uniform(0, 3); eta = math.exp(rng.uniform(-5, 5))
    g = 2 * (1 + eta) / eta
    w1 = min(w1, U(x, 1.0, g) - (1 - (1 + eta) * x * x))
    m = rng.uniform(1.0001, 5); g2 = 2 / (m * m - 1)
    w2 = min(w2, U(x, m, g2) - max(1 - x * x, 0.0))
print("    pointwise: min of U - (1-(1+eta)x^2) = %.3e, min of U - (1-x^2)_+ = %.3e (must be >= 0)" % (w1, w2))

# ---------- (2) Lemma 2.10 on random adaptive trees ----------
def rand_kernel(b, zero_prob=0.25, conc=None):
    if conc is None:
        conc = rng.choice([0.1, 0.5, 1.0, 5.0])
    v = nrng.dirichlet([conc] * b)
    if rng.random() < zero_prob:
        v[rng.randrange(b)] = 0.0
        if v.sum() == 0:
            v[rng.randrange(b)] = 1.0
        v = v / v.sum()
    return v

def close_kernel(p, scale):
    # perturb p multiplicatively; sometimes kill a coordinate
    q = p * np.exp(scale * nrng.standard_normal(len(p)))
    if rng.random() < 0.15:
        q[rng.randrange(len(p))] = 0.0
    if q.sum() == 0:
        q = np.ones(len(p))
    if rng.random() < 0.1:
        q = q + 1e-3 * rng.random()
    return q / q.sum()

def random_tree(depth, b, scale):
    """returns leaf probs under P and Q and sigma = E_P sum h"""
    P = {(): 1.0}; Q = {(): 1.0}; sigma = 0.0
    for d in range(depth):
        P2 = {}; Q2 = {}
        for hist in P:
            p = rand_kernel(b)
            q = close_kernel(p, scale) if rng.random() < 0.8 else rand_kernel(b)
            h = 1 - np.sum(np.sqrt(p * q))
            sigma += P[hist] * h
            for y in range(b):
                P2[hist + (y,)] = P[hist] * p[y]
                Q2[hist + (y,)] = Q[hist] * q[y]
        P, Q = P2, Q2
    keys = list(P)
    return np.array([P[k] for k in keys]), np.array([Q[k] for k in keys]), sigma

etas = [0.1, 0.25, 1.0, 4.0, 100.0]
mx = {"a%g" % e: 0 for e in etas}; mx["b"] = 0; mx["c"] = 0; mx["c2sqrt"] = 0; mx["k2"] = 0; mx["k3"] = 0
mx["H2/4sig"] = 0; mx["c_nontriv"] = 0
ntrees = 0
for it in range(6000):
    depth = rng.choice([1, 2, 3, 4, 5]); b = rng.choice([2, 2, 3])
    if b ** depth > 400:
        depth = 3
    scale = math.exp(rng.uniform(-6, 1))
    p, q, sig = random_tree(depth, b, scale)
    if sig <= 1e-14:
        continue
    ntrees += 1
    for e in etas:
        lhs = np.sum(np.maximum(p - (1 + e) * q, 0))
        mx["a%g" % e] = max(mx["a%g" % e], lhs / (2 * (1 + 1 / e) * sig))
    mx["b"] = max(mx["b"], p[q == 0].sum() / (2 * sig))
    tv = 0.5 * np.abs(p - q).sum()
    mx["c"] = max(mx["c"], tv / phi(sig))
    if phi(sig) < 1:
        mx["c_nontriv"] = max(mx["c_nontriv"], tv / phi(sig))
    mx["c2sqrt"] = max(mx["c2sqrt"], phi(sig) / (2 * math.sqrt(sig)))
    mx["H2/4sig"] = max(mx["H2/4sig"], (1 - np.sum(np.sqrt(p * q))) / (4 * sig))
    if len(p) <= 30 and it % 3 == 0:
        for k in (2, 3):
            pk = p; qk = q
            for _ in range(k - 1):
                pk = np.outer(pk, p).ravel(); qk = np.outer(qk, q).ravel()
            tvk = 0.5 * np.abs(pk - qk).sum()
            mx["k%d" % k] = max(mx["k%d" % k], tvk / phi(k * sig))
print("(2) Lemma 2.10 / Corollary 2.11 on %d random adaptive trees (depth <= 5, zeros allowed); largest ratios (all must be <= 1):" % ntrees)
print("    (a) sup_G[P(G)-(1+eta)Q(G)] / (2(1+1/eta) sigma): " + ", ".join("eta=%g: %.10f" % (e, mx["a%g" % e]) for e in etas))
print("    (b) P(q=0)/(2 sigma): %.10f   (c) TV/phi(sigma): %.10f   phi(sigma)/(2 sqrt sigma): %.10f   H2/(4 sigma): %.4f" % (mx["b"], mx["c"], mx["c2sqrt"], mx["H2/4sig"]))
print("    k independent runs, TV(P^k,Q^k)/phi(k sigma): k=2: %.10f, k=3: %.10f" % (mx["k2"], mx["k3"]))
print("    largest TV/phi(sigma) among trees with phi(sigma) < 1: %.10f" % mx["c_nontriv"])

# hill climbing on TV/phi(sigma) at small sigma, depth 3 binary (adversarial)
def tree_from_params(theta, depth):
    # theta: for each internal node (in BFS order) two logits (p, q)
    P = {(): 1.0}; Q = {(): 1.0}; sig = 0.0; idx = 0
    for d in range(depth):
        P2 = {}; Q2 = {}
        for hist in sorted(P):
            a, c = theta[idx]; idx += 1
            p1 = 1 / (1 + math.exp(-a)); q1 = 1 / (1 + math.exp(-c))
            p = np.array([1 - p1, p1]); q = np.array([1 - q1, q1])
            sig += P[hist] * (1 - np.sum(np.sqrt(p * q)))
            for y in range(2):
                P2[hist + (y,)] = P[hist] * p[y]; Q2[hist + (y,)] = Q[hist] * q[y]
        P, Q = P2, Q2
    keys = sorted(P)
    return np.array([P[k] for k in keys]), np.array([Q[k] for k in keys]), sig

best = {}
for depth in (2, 3):
    nodes = 2 ** depth - 1
    for target in (0.001, 0.01, 0.1):
        bestv = 0
        for restart in range(15):
            th = []
            for _ in range(nodes):
                a0 = rng.gauss(0, 3); th.append((a0, a0 + rng.gauss(0, 0.01)))
            def score(th):
                p, q, s = tree_from_params(th, depth)
                if s <= 0 or s > target:
                    return -1
                return 0.5 * np.abs(p - q).sum() / phi(s)
            cur = score(th)
            step = 1.0
            for k in range(1500):
                th2 = [(a + step * rng.gauss(0, 1), c + step * rng.gauss(0, 1)) if rng.random() < 0.4 else (a, c) for a, c in th]
                v = score(th2)
                if v > cur:
                    th, cur = th2, v
                if k % 300 == 299:
                    step *= 0.6
            bestv = max(bestv, cur)
        best[(depth, target)] = bestv
print("    hill climbing, binary trees, sigma <= target: largest TV/phi(sigma): " + ", ".join("depth %d, %g: %.4f" % (d, t, v) for (d, t), v in best.items()))

# ---------- (3) Remark 2.12 (i): constants of one call ----------
print("(3) Remark 2.12(i), one call:")
for eta in (0.25, 1.0, 4.0):
    a = 1e-6
    p = np.array([1 - a, a]); q = np.array([1 - a / (1 + eta) ** 2, a / (1 + eta) ** 2])
    h = 1 - np.sum(np.sqrt(p * q))
    print("    eta=%g: [P(G)-(1+eta)Q(G)]/h = %.5f, 2(1+1/eta) = %.5f" % (eta, (p[1] - (1 + eta) * q[1]) / h, 2 * (1 + 1 / eta)))
a = 1e-6; h = 1 - math.sqrt(1 - a)
print("    q=(1,0): P(G)/h = %.5f (limit 2)" % (a / h))
for t in (0.01, 0.1, 0.3):
    h = 1 - math.sqrt(1 - 4 * t * t)
    print("    symmetric t=%g: TV=%.6f, sqrt(h(2-h))=%.6f, phi(h)=%.6f" % (t, 2 * t, math.sqrt(h * (2 - h)), phi(h)))

# ---------- (4) arithmetic of Theorem 3.1 and Remark 3.2(iii) ----------
print("(4) Theorem 3.1 arithmetic:")
worst_eps = 0
for eps in np.linspace(1e-4, 1, 2001):
    u = eps * eps / (2 * (1 + eps))
    worst_eps = max(worst_eps, abs(u + math.sqrt(u * u + 2 * u) - eps))
print("    max |phi(eps^2/(2(1+eps))) - eps| over eps in (0,1]: %.2e" % worst_eps)
us = np.linspace(0, 5, 50001)
f = us + np.sqrt(us * us + 2 * us)
d2 = np.diff(f, 2)
print("    u + sqrt(u^2+2u): min first difference %.2e (>=0), max second difference %.2e (<=0)" % (np.diff(f).min(), d2.max()))
print("    max of phi(u) - 2 sqrt(u) on [0,5]: %.2e (<= 0)" % max(phi(u) - 2 * math.sqrt(u) for u in us))
# expansion: phi(s)/sqrt(2s) - 1 = O(sqrt s)
for s in (1e-2, 1e-4, 1e-6):
    print("    s=%g: (phi(s)/sqrt(2s) - 1)/sqrt(s) = %.4f" % (s, (phi(s) / math.sqrt(2 * s) - 1) / math.sqrt(s)))
# Remark 3.3(iii)
cstar = mp.mpf("2.96414715730767803218167583868")
print("    c*/2 = %s (claimed <= 1.49)" % mp.nstr(cstar / 2, 8))

# ---------- (5) Proposition 3.6 constants ----------
worst = 1e9
for K in range(1, 200):
    for n in range(max(1, math.ceil(3 * K / 4)), 3 * K + 400, 7):
        d2 = K / (16 * n + 4 * K)
        lhs = 0.25 * math.sqrt(d2)
        rhs = math.sqrt(3) / 32 * math.sqrt(K / n)
        worst = min(worst, lhs - rhs)
        hyp = K * (1 - 4 * d2) / (16 * d2)
        assert abs(hyp - n) < 1e-6 * n
print("(5) Proposition 3.6: min over K<200, n>=3K/4 of (1/4)sqrt(K/(16n+4K)) - (sqrt3/32)sqrt(K/n) = %.3e (>= 0); sqrt3/32 = %.5f; R3 constant sqrt(ln2/2) = %.5f; ratio %.2f" % (worst, math.sqrt(3) / 32, math.sqrt(math.log(2) / 2), math.sqrt(math.log(2) / 2) / (math.sqrt(3) / 32)))

# ---------- (6) Theorem 2.7: g, uniqueness, enclosure ----------
mp.mp.dps = 50
def g(q):
    q = mp.mpf(q)
    return 1 + q * mp.e ** (q * q / 4) * (1 / mp.sqrt(2) + mp.sqrt(mp.pi) / 2 * mp.erf(q / 2))
def k(q):
    q = mp.mpf(q); return 1 / (1 - q * q / 2)
def r(q):
    s = 1 / g(q); return (1 - s) / q - mp.mpf(q) / 2
q0 = mp.findroot(lambda q: g(q) - k(q), 1.15)
print("(6) Theorem 2.7: q0 = %s, c* = %s" % (mp.nstr(q0, 30), mp.nstr(k(q0), 30)))
print("    g-k at 1.15120357: %s ; at 1.15120358: %s" % (mp.nstr(g("1.15120357") - k("1.15120357"), 6), mp.nstr(g("1.15120358") - k("1.15120358"), 6)))
qs = [mp.mpf(i) / 1000 for i in range(1, 3000)]
rv = [r(q) for q in qs]
print("    r on (0.001, 3): strictly decreasing: %s; sign changes: %d; r(0.001) = %s" % (all(rv[i] > rv[i + 1] for i in range(len(rv) - 1)), sum(1 for i in range(len(rv) - 1) if rv[i] > 0 >= rv[i + 1]), mp.nstr(rv[0], 6)))
# g' identity
q = mp.mpf("0.7")
gp = mp.diff(g, q)
print("    g'(0.7) numeric %s vs (g-1)(1/q+q/2)+q/2 = %s" % (mp.nstr(gp, 15), mp.nstr((g(q) - 1) * (1 / q + q / 2) + q / 2, 15)))
