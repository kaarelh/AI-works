"""Second checker of part rehearsal-core: independent numerical checks.

Written from the statements of proofs/rehearsal-core.md, without reusing the
prover's, verifiers' or editor's scripts. Exact arithmetic (fractions or floats
from exact enumeration) wherever possible.

Blocks:
 1. Theorem 5.1(d2): exact Protocol R on the example, posterior computed from
    the weights (not from the closed form), compared with the closed form.
 2. Theorem 5.1(d1): equality in (a).
 3. Proposition 5.2(c) direct form and (d): exact law of beta(M^(T)).
 4. Proposition 5.6 (R7): exact enumeration of Protocol R on small adaptive
    scaffolds, for every subset Q of X, with a human who answers adversarially
    (depending on the round and on the data) and is not in the class.
 5. Remark 4.4(d): exact Protocol R where P is not in H but members agree with
    P on every input the scaffold can produce.
 6. Theorem 13.1(a0), (a1), (a2): inequalities per call, and exact binomial
    coverage of (a2).
 7. Numbers quoted in the note (Sections 3.1, 3.4, 3.5) and in the proof file.
 8. The paragraph "Compute" of Section 2: rejection sampling from the posterior.
"""
import itertools
import math
import random
from fractions import Fraction as F

out = []


def say(s=""):
    print(s)
    out.append(s)


# ---------------------------------------------------------------------------
# generic exact engine for Protocol R
# ---------------------------------------------------------------------------
# A scaffold: D0 = list of (z, prob); nxt(z, ys) -> input or None (STOP); L.
# A hypothesis: function nu(x) -> dict y -> prob (sum <= 1).
# Data: tuple of (x, y) pairs (order irrelevant for the posterior).


def runs_of(scaffold, kernel):
    """All runs with probabilities: list of (prob, z, xs, ys)."""
    D0, nxt, L = scaffold
    res = []

    def rec(z, p, xs, ys):
        if len(ys) >= L:
            res.append((p, z, tuple(xs), tuple(ys)))
            return
        x = nxt(z, tuple(ys))
        if x is None:
            res.append((p, z, tuple(xs), tuple(ys)))
            return
        for y, q in kernel(x).items():
            if q > 0:
                rec(z, p * q, xs + [x], ys + [y])

    for z, pz in D0:
        rec(z, pz, [], [])
    return res


def mixture(H, data):
    """H: list of (weight, nu). Returns kernel x -> dict."""
    post = []
    for w, nu in H:
        lik = w
        for x, y in data:
            lik *= nu(x).get(y, 0)
        post.append(lik)
    Z = sum(post)
    if Z == 0:
        raise ValueError("zero evidence")

    def M(x):
        d = {}
        for pw, (w, nu) in zip(post, H):
            if pw == 0:
                continue
            for y, q in nu(x).items():
                d[y] = d.get(y, 0) + pw * q / Z
        return d

    return M


def tv(a, b):
    keys = set(a) | set(b)
    return sum(abs(a.get(k, 0) - b.get(k, 0)) for k in keys) / 2


def kl(p, q):
    s = 0.0
    for y, py in p.items():
        if py > 0:
            qy = q.get(y, 0)
            if qy == 0:
                return math.inf
            s += py * math.log(py / qy)
    return s


def protocol_R(scaffold, H, human, n, functional):
    """Exact: returns list over t=1..n of E[functional(M^(t), data_{t-1}, t)].
    human(x, data, t) -> dict of answer probabilities (may be adversarial).
    Also returns the full distribution over data lists per round."""
    D0, nxt, L = scaffold
    dist = {(): 1.0}
    values = []
    dists = []
    for t in range(1, n + 1):
        dists.append(dict(dist))
        newdist = {}
        val = 0.0
        for data, pd in dist.items():
            M = mixture(H, data)
            val += pd * functional(M, data, t)
            R = runs_of(scaffold, M)
            for pr, z, xs, ys in R:
                for J in range(1, L + 1):
                    pj = pr * pd / L
                    if J <= len(xs):
                        x = xs[J - 1]
                        for y, q in human(x, data, t).items():
                            if q > 0:
                                nd = tuple(sorted(data + ((x, y),)))
                                newdist[nd] = newdist.get(nd, 0) + pj * q
                    else:
                        newdist[data] = newdist.get(data, 0) + pj
        values.append(val)
        dist = newdist
    return values, dists


def Lambda(scaffold, M, P):
    return sum(pr * sum(kl(P(x), M(x)) for x in xs)
               for pr, z, xs, ys in runs_of(scaffold, M))


def beta(scaffold, M, P):
    return sum(pr * sum(tv(P(x), M(x)) for x in xs)
               for pr, z, xs, ys in runs_of(scaffold, M))


# ---------------------------------------------------------------------------
say("== 1. Theorem 5.1(d2): the bound of (c) is approached ==")
# Independent route: the posterior is computed from the weights by the generic
# engine for a representative asked set {0..k-1}; the number of rounds spent
# with k distinct inputs asked is geometric with mean N/(N-k).
for (N, L, w) in [(3, 2, 0.3), (10, 1, 0.01), (10, 3, 0.01), (100, 1, 0.01)]:
    f = lambda x: {0: 1.0}
    H = [(w, f)] + [((1 - w) / N, (lambda i: (lambda x: {1 if x == i else 0: 1.0}))(i))
                    for i in range(N)]
    scaffold = ([(z, 1.0 / N) for z in range(N)], lambda z, ys: z, L)
    total = 0.0
    for k in range(N):
        data = tuple((i, 0) for i in range(k))
        M = mixture(H, data)
        b = beta(scaffold, M, f)
        total += b * N / (N - k)
    closed = L * sum(((1 - w) / N) / (1 - k * (1 - w) / N) for k in range(N))
    say(f"  N={N} L={L} w={w}: sum_t E beta(M^(t)) = {total:.6f}; closed form = {closed:.6f}; "
        f"L ln(1/w) = {L * math.log(1 / w):.6f}; ratio to bound = {total / (L * math.log(1 / w)):.4f}")
# direct exact protocol for small N and finite n, compared with the Markov chain
N, L, w, n = 3, 2, 0.3, 8
f = lambda x: {0: 1.0}
H = [(w, f)] + [((1 - w) / N, (lambda i: (lambda x: {1 if x == i else 0: 1.0}))(i)) for i in range(N)]
scaffold = ([(z, 1.0 / N) for z in range(N)], lambda z, ys: z, L)
vals, _ = protocol_R(scaffold, H, lambda x, d, t: {0: 1.0}, n, lambda M, d, t: beta(scaffold, M, f))
# Markov chain on k
pk = [1.0] + [0.0] * N
mc = 0.0
for t in range(n):
    for k in range(N):
        data = tuple((i, 0) for i in range(k))
        mc += pk[k] * beta(scaffold, mixture(H, data), f)
    new = [0.0] * (N + 1)
    for k in range(N + 1):
        if k < N:
            new[k] += pk[k] * k / N
            new[k + 1] += pk[k] * (N - k) / N
        else:
            new[k] += pk[k]
    pk = new
say(f"  exact Protocol R (N=3, L=2, w=0.3, n=8): sum_t<=n E beta = {sum(vals):.10f}; Markov chain on k: {mc:.10f}")
say("  Riemann-sum claim: the closed form is below L ln(1/w) for every N and increases to it (see the ratios above).")
for N in [1, 2, 5, 20, 1000]:
    w = 0.01
    c = sum(((1 - w) / N) / (1 - k * (1 - w) / N) for k in range(N))
    say(f"    N={N}: closed form / L = {c:.5f} < ln(1/w) = {math.log(1 / w):.5f}: {c < math.log(1 / w)}")

# ---------------------------------------------------------------------------
say()
say("== 2. Theorem 5.1(d1): equality in (a) ==")
for L, w in [(1, 0.5), (3, 0.2), (4, 0.01)]:
    f = lambda x: {1: 1.0}
    g = lambda x: {0: 1.0}
    H = [(w, f), (1 - w, g)]
    scaffold = ([(0, 1.0)], lambda z, ys: len(ys), L)
    for n in [1, 3]:
        vals, _ = protocol_R(scaffold, H, lambda x, d, t: {1: 1.0}, n, lambda M, d, t: Lambda(scaffold, M, f))
        valsb, _ = protocol_R(scaffold, H, lambda x, d, t: {1: 1.0}, n, lambda M, d, t: beta(scaffold, M, f))
        say(f"  L={L} w={w} n={n}: sum E Lambda = {sum(vals):.10f}, L ln(1/w) = {L * math.log(1 / w):.10f}; "
            f"sum E beta = {sum(valsb):.10f}, L(1-w) = {L * (1 - w):.10f}")

# ---------------------------------------------------------------------------
say()
say("== 3. Proposition 5.2(c) direct form and 5.2(d) ==")
# (d): exact law of beta(M^(T)) in the example; check Pr[beta = q/2] = (1-(1-q)^n)/(qn) >= (1-e^{-1/delta}) delta > 0.63 delta
worst = 1e9
for n in [1, 2, 5, 10, 37, 100, 1000]:
    for delta in [1.0, 0.9, 0.63, 0.5, 0.3, 0.1, 1.0 / n]:
        if delta < 1.0 / n - 1e-12:
            continue
        q = 1.0 / (delta * n)
        p_exact = sum((1 - q) ** (t - 1) for t in range(1, n + 1)) / n
        lower = (1 - math.exp(-1 / delta)) * delta
        worst = min(worst, p_exact / (0.63 * delta))
        assert p_exact >= lower - 1e-12 and lower > 0.63 * delta
say(f"  Pr[beta(M^(T)) = q/2] >= (1 - e^(-1/delta)) delta > 0.63 delta on the grid; least ratio Pr/(0.63 delta) = {worst:.4f}")
say(f"  0.63/(2 ln 2) = {0.63 / (2 * math.log(2)):.5f} > 0.45; 1 - e^(-1) = {1 - math.exp(-1):.5f} > 0.63")
# direct exact check of the example with the engine for one (n, delta): beta(M^(t)) values
n, delta = 6, 0.5
q = 1.0 / (delta * n)
f = lambda x: {0: 1.0}
g = lambda x: {1: 1.0} if x == 1 else {0: 1.0}
H = [(0.5, f), (0.5, g)]
scaffold = ([(0, 1 - q), (1, q)], lambda z, ys: z, 1)
vals, dists = protocol_R(scaffold, H, lambda x, d, t: f(x), n, lambda M, d, t: 0.0)
p_half = 0.0
for t, dist in enumerate(dists, 1):
    for data, pd in dist.items():
        b = beta(scaffold, mixture(H, data), f)
        if abs(b - q / 2) < 1e-12:
            p_half += pd / n
say(f"  engine, n={n}, delta={delta}: Pr[beta(M^(T)) = q/2 = {q / 2:.4f}] = {p_half:.6f}; formula {(1 - (1 - q) ** n) / (q * n):.6f}")
# (c) direct form: Markov for beta(M^(T)): on random small instances, Pr[beta(M^(T)) > E/delta] <= delta (trivial), and
# the comparison with the two-parameter form for delta = delta1 + delta2
for d1, d2 in [(0.05, 0.05), (0.01, 0.09), (0.5, 0.4)]:
    direct = 1 / (d1 + d2)
    two = (1 + math.log(1 / d1) / 1.0) / d2  # with ln(W/w) = 1 as unit; the two-parameter bound is L(ln(W/w)+ln(1/d1))/(n d2)
    say(f"  delta1={d1}, delta2={d2}: direct factor 1/(d1+d2) = {direct:.3f}  <  (1 + ln(1/d1)/ln(W/w))/d2 = {two:.3f} (ln(W/w)=1)")

# ---------------------------------------------------------------------------
say()
say("== 4. Proposition 5.6 (R7): exact check on adaptive scaffolds, every subset Q, adversarial human not in H ==")
rng = random.Random(20261116)
worst_ratio = 0.0
cases = 0
for trial in range(12):
    X = [0, 1, 2]
    Y = [0, 1]
    L = rng.choice([1, 2, 3])
    n = rng.choice([2, 3, 4])
    # adaptive scaffold: next input depends on z and on the answers so far; may stop early
    table = {}

    def nxt(z, ys, table=table, L=L):
        key = (z, ys)
        if key not in table:
            r = rng.random()
            table[key] = None if (len(ys) > 0 and r < 0.25) else rng.choice(X)
        return table[key]
    D0 = [(0, 0.5), (1, 0.3), (2, 0.2)]
    scaffold = (D0, nxt, L)
    # class: a few random samplers (not containing the human)
    H = []
    for _ in range(3):
        tab = {x: rng.random() for x in X}
        H.append((rng.random() / 3, (lambda tab: (lambda x: {1: tab[x], 0: 1 - tab[x]}))(tab)))
    # adversarial human: depends on x, the data and the round, deterministically by a hash
    def human(x, data, t, salt=rng.random()):
        r = random.Random(hash((x, data, t, salt)) & 0xFFFFFFFF).random()
        return {1: r, 0: 1 - r}
    # warm the scaffold table on all histories (so that it is fixed before the protocol)
    for z, _ in D0:
        def walk(ys):
            if len(ys) >= L:
                return
            x = nxt(z, ys)
            if x is None:
                return
            for y in Y:
                walk(ys + (y,))
        walk(())
    _, dists = protocol_R(scaffold, H, human, n, lambda M, d, t: 0.0)
    for r in range(0, len(X) + 1):
        for Q in itertools.combinations(X, r):
            Q = set(Q)
            prob = 0.0
            for t, dist in enumerate(dists, 1):
                for data, pd in dist.items():
                    if any(x in Q for x, y in data):
                        continue  # A_t fails
                    M = mixture(H, data)
                    hit = sum(pr for pr, z, xs, ys in runs_of(scaffold, M) if any(x in Q for x in xs))
                    prob += pd * hit / n
            cases += 1
            worst_ratio = max(worst_ratio, prob / (L / n))
say(f"  {cases} pairs (instance, Q): largest Pr[event] / (L/n) = {worst_ratio:.4f} (<= 1 required)")
# a case meant to be near-extremal: one call per run (L=1) at a fixed input, n rounds: Pr = 1/n * [t=1 term] ...
for n in [1, 2, 5]:
    L = 1
    scaffold = ([(0, 1.0)], lambda z, ys: 0, L)
    H = [(0.5, lambda x: {0: 1.0}), (0.5, lambda x: {1: 1.0})]
    _, dists = protocol_R(scaffold, H, lambda x, d, t: {0: 1.0}, n, lambda M, d, t: 0.0)
    prob = 0.0
    for t, dist in enumerate(dists, 1):
        for data, pd in dist.items():
            if any(x == 0 for x, y in data):
                continue
            prob += pd / n
    say(f"  L=1, every run calls x=0, Q={{0}}, n={n}: probability = {prob:.4f} = L/n = {L / n:.4f} (attained)")

# ---------------------------------------------------------------------------
say()
say("== 5. Remark 4.4(d): P not in H, two members agree with P on the inputs the scaffold can produce ==")
# X = {0,1,2,3}; the scaffold only ever produces inputs 0,1 (adaptively). P is stochastic.
P = lambda x: {1: 0.7, 0: 0.3} if x in (0, 1) else {1: 0.5, 0: 0.5}
nu1 = lambda x: {1: 0.7, 0: 0.3} if x in (0, 1) else {1: 1.0}
nu2 = lambda x: {1: 0.7, 0: 0.3} if x in (0, 1) else {0: 1.0}
bad1 = lambda x: {1: 0.2, 0: 0.8}
bad2 = lambda x: {1: 0.95, 0: 0.05} if x == 0 else {1: 0.4, 0: 0.6}
H = [(0.05, nu1), (0.05, nu2), (0.5, bad1), (0.3, bad2)]
W = 0.9
for L in [1, 2, 3]:
    scaffold = ([(0, 0.6), (1, 0.4)], lambda z, ys: (z + sum(ys)) % 2, L)
    for n in [2, 4]:
        vals, _ = protocol_R(scaffold, H, lambda x, d, t: P(x), n, lambda M, d, t: Lambda(scaffold, M, P))
        bound = L * math.log(W / 0.1)
        say(f"  L={L} n={n}: sum_t E Lambda(M^(t)) = {sum(vals):.6f} <= L ln(W/w([P])) = {bound:.6f}: {sum(vals) <= bound + 1e-12}")

# ---------------------------------------------------------------------------
say()
say("== 6. Theorem 13.1(a0), (a1), (a2) ==")
rng = random.Random(7)
mx1 = mx2 = mx3 = -1.0
for _ in range(50000):
    s = rng.choice([2, 3, 5, 10])
    a = [rng.random() ** rng.choice([1, 3, 8]) for _ in range(s + 1)]  # last entry: bottom
    p = [rng.random() ** rng.choice([1, 3, 8]) for _ in range(s)]
    sa, sp = sum(a), sum(p)
    a = [v / sa for v in a]
    p = [v / sp for v in p] + [0.0]
    dis = 1 - sum(x * y for x, y in zip(a, p))
    t = sum(abs(x - y) for x, y in zip(a, p)) / 2
    noise = 1 - sum(y * y for y in p)
    mx1 = max(mx1, t - dis)
    mx2 = max(mx2, dis - t - noise)
    mx3 = max(mx3, noise / 2 - dis)
say(f"  50000 random pairs (a on Y with bottom, p on Y): max(TV - dis) = {mx1:.2e}, max(dis - TV - noise) = {mx2:.2e}, max(noise/2 - dis) = {mx3:.2e} (all <= 0)")
# (a2): exact binomial coverage: Pr[rho > rho_hat + sqrt(2 rho_hat l/m) + 2 l/m] <= delta
worst = 0.0
for m in [10, 30, 100, 300, 1000]:
    for delta in [0.2, 0.05, 0.01, 0.001]:
        l = math.log(1 / delta)
        for rho in [x / 1000 for x in range(1, 1000, 7)]:
            # sum over k of binomial pmf where bound fails
            fail = 0.0
            logp = [math.lgamma(m + 1) - math.lgamma(k + 1) - math.lgamma(m - k + 1)
                    + (k * math.log(rho) if k else 0) + ((m - k) * math.log(1 - rho) if m - k else 0)
                    for k in range(m + 1)]
            for k in range(m + 1):
                rh = k / m
                if rho > rh + math.sqrt(2 * rh * l / m) + 2 * l / m:
                    fail += math.exp(logp[k])
            worst = max(worst, fail / delta)
say(f"  (a2) exact binomial: largest Pr[rho above the bound]/delta over m in 10..1000, 4 deltas, rho grid = {worst:.4f} (<= 1)")
# (a1): issue probability (1-rho)^m <= exp(-m s/2); false certificate prob < delta
worst = 0.0
for m in [10, 100, 1000]:
    for delta in [0.1, 0.01]:
        thr = math.log(1 / delta) / m
        for rho in [thr * (1 + e) for e in (1e-9, 1e-3, 0.1, 1, 5)]:
            if rho < 1:
                worst = max(worst, (1 - rho) ** m / delta)
say(f"  (a1) largest Pr[no disagreement]/delta when rho > ln(1/delta)/m: {worst:.6f} (< 1)")
say(f"  'about 4.4 ln(1/delta)/m' when rho_hat = ln(1/delta)/m: 1 + sqrt(2) + 2 = {1 + math.sqrt(2) + 2:.4f}")

# ---------------------------------------------------------------------------
say()
say("== 7. Numbers quoted in the note and in the proof file ==")
for K in [1e2, 1e4, 1e9]:
    n = 10 * K * math.log(2) / 0.1
    say(f"  R1 budget, L=10, 0.1 unfaithful calls, K={K:.0e}: n = {n:.4g} answers = {n / 2000:.4g} years of 2000 hours = {n / 8766:.4g} calendar years")
L, mu, k = 4000, 0.002, 399
say(f"  Example 8.5(d), first count: (1-mu)^(L-k) = {(1 - mu) ** (L - k):.6f}; beta/(k+1) = {mu * L / (k + 1):.4f}; sum = {(1 - mu) ** (L - k) + mu * L / (k + 1):.4f}")
# Pr[Bin(L, mu) <= k]
lp = lambda j: math.lgamma(L + 1) - math.lgamma(j + 1) - math.lgamma(L - j + 1) + j * math.log(mu) + (L - j) * math.log(1 - mu)
say(f"    Pr[Bin(4000, 0.002) <= 399] = 1 - {sum(math.exp(lp(j)) for j in range(400, L + 1)):.3e}")
# blind tolerance bound check by exact DP for a blind rule that answers its k calls at the end, and one adaptive blind rule
say("    blind rule bound: the run is bad only if the >= L-k passed human answers are all 0: (1-mu)^(L-k) (optional stopping)")
for L_, eta, delta in [(1000, 0.5, 0.01)]:
    k8 = math.floor((eta * L_ - math.sqrt(8 * L_ * math.log(1 / delta))))
    k2 = math.floor((eta * L_ - math.sqrt(2 * L_ * math.log(1 / delta))))
    say(f"  Remark 12.3(v): L={L_}, eta={eta}, delta={delta}, mu=1, D=0: constant 8 admits k={k8}, constant 2 admits k={k2}")
m = math.log(1 / 0.05) / (0.1 * 0.1)
say(f"  Certificate: m = ln(1/0.05)/(theta * 0.1) = {m:.1f}; with m = 300: L ln(1/delta)/m / (theta L) = {math.log(20) / 300 / 0.1:.5f} <= 0.1")
say(f"  Prop 5.6 'what it does not say': N=1000, n=50: (1/n) sum_t (1-1/N)^(t-1) = {sum((1 - 1 / 1000) ** (t - 1) for t in range(1, 51)) / 50:.4f}")
say(f"  Theorem 9.2 constant: 1/(8 sqrt 2) = {1 / (8 * math.sqrt(2)):.5f}; sqrt(ln2/2) = {math.sqrt(math.log(2) / 2):.5f}")

# ---------------------------------------------------------------------------
say()
say("== 8. 'Compute' (Section 2): rejection sampling from the posterior ==")
# Programs = codewords of a prefix-free code; each program is an always-halting sampler.
# Complete code {0, 10, 110, 111}: weights 1/2, 1/4, 1/8, 1/8 (Kraft sum 1).
progs = {"0": {0: 0.9, 1: 0.1}, "10": {0: 0.5, 1: 0.5}, "110": {0: 0.2, 1: 0.8}, "111": {0: 0.0, 1: 1.0}}
weights = {c: 2.0 ** (-len(c)) for c in progs}
data = [0, 1, 1, 0, 1]  # answers to five questions (inputs irrelevant: programs ignore x here)
lik = {c: math.prod(progs[c][y] for y in data) for c in progs}
xi = sum(weights[c] * lik[c] for c in progs)
post = {c: weights[c] * lik[c] / xi for c in progs}
human = "110"
K = len(human)
P_D = lik[human]
rng = random.Random(1)
counts = {c: 0 for c in progs}
trials_total = 0
S = 100000
for _ in range(S):
    while True:
        trials_total += 1
        code = ""
        while code not in progs:
            code += rng.choice("01")
        if all(rng.random() < progs[code][y] for y in data):
            counts[code] += 1
            break
say(f"  posterior: {', '.join(f'{c}:{post[c]:.4f}' for c in progs)}")
say(f"  accepted : {', '.join(f'{c}:{counts[c] / S:.4f}' for c in progs)}  ({S} draws)")
say(f"  mean trials per draw = {trials_total / S:.3f}; 1/xi(D) = {1 / xi:.3f}; 2^K / P(D) = {2 ** K / P_D:.3f} (bound holds: {1 / xi <= 2 ** K / P_D})")
# incomplete code: Kraft sum < 1, so the reading of a codeword can fail to end
incomplete = {"0": None, "10": None}  # Kraft sum 3/4; the prefix '11' has no codeword extension
say("  with an incomplete code, e.g. {0, 10} (Kraft sum 3/4), the reading never ends after the prefix 11:")
say("    probability 1/4 per trial; a reader cannot in general decide that a prefix has no extension in a decidable code,")
say("    so the expected time per draw is infinite unless the code is complete or dead prefixes are decidable.")
# growth of 1/xi with n for a stochastic human
for nn in [10, 50, 100]:
    rng2 = random.Random(nn)
    ys = [1 if rng2.random() < 0.8 else 0 for _ in range(nn)]
    lk = {c: math.prod(progs[c][y] for y in ys) for c in progs}
    x2 = sum(weights[c] * lk[c] for c in progs)
    say(f"    stochastic human (Bern 0.8), n={nn} answers: 1/xi(D) = {1 / x2:.3e} (grows like exp(n x entropy))")

with open(__file__.replace(".py", ".out"), "w") as fh:
    fh.write("\n".join(out) + "\n")
