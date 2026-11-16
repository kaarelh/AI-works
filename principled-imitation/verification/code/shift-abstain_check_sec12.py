#!/usr/bin/env python3
"""Referee's checks of Sections 1 and 2 of research/prove-c/shift-abstain.md.

(A) Lemma 1.4 on random scaffolds (adaptive, with runs of different lengths, runs
    with no call, kernels that abstain, deterministic humans): items (1), (2), (3).
(B) The inequality in the proof of Proposition 2.3 for pairs of kernels.
(C) Example 2.2: Protocol R run EXACTLY by the generic engine (all data paths
    enumerated), compared with the closed forms of the text; then the closed forms
    at the parameters quoted in the text; the supremum of the ratio over omega.
(D) Proposition 2.3 and Corollary 1.3 (R1) on random instances, Protocol R enumerated
    exactly: realised and expected average visit measure.
(E) Lemma 1.2 / Theorem 2.5(i): law of the asked question = d_t / L (exact).
(F) Proposition 2.4(c): the arithmetic  (N0 - beta n) p/(N0 + L) <= delta  =>
    beta n >= L/(4 delta) - L   on a grid; Proposition 2.1(d) numbers.
"""
import importlib.util, math, os, random, itertools, sys
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("eng", os.path.join(here, "shift-abstain_engine.py"))
eng = importlib.util.module_from_spec(spec); spec.loader.exec_module(eng)

rng = random.Random(20261115)
LN2 = math.log(2)

# ---------------------------------------------------------------- (A), (B)
worst = dict(tv_p=-9, p_beta=-9, p_betaP=-9, d=-9, b3a=-9, b3b=-9, pair=-9, peq=0.0)
ncase = 0
for trial in range(6000):
    nx, ny = rng.randint(2, 4), rng.randint(2, 3)
    L = rng.randint(1, 4)
    sc = eng.random_scaffold(rng, nx, ny, rng.randint(1, 3), L,
                             stop_prob=rng.choice([0.0, 0.2, 0.5]),
                             adaptive=rng.random() < 0.8, stop0=rng.choice([0.0, 0.3]))
    P = eng.random_kernel(rng, nx, ny, det=rng.random() < 0.4)
    C = eng.random_kernel(rng, nx, ny, abort=rng.random() < 0.5, det=rng.random() < 0.2)
    C2 = eng.random_kernel(rng, nx, ny, abort=rng.random() < 0.5)
    p = eng.separation_prob(sc, P, C)
    bC = eng.beta_along(sc, C, P, C)        # beta(C): along C's own run
    bP = eng.beta_along(sc, P, P, C)        # beta^P(C): along the human's run
    tv = eng.tv_laws(eng.run_law(sc, C), eng.run_law(sc, P))
    dC, dP = eng.visit(sc, C), eng.visit(sc, P)
    g = [rng.random() for _ in range(nx)]
    dd = abs(sum(g[x] * (dC[x] - dP[x]) for x in range(nx)))
    worst['tv_p'] = max(worst['tv_p'], tv - p)
    worst['p_beta'] = max(worst['p_beta'], p - bC)
    worst['p_betaP'] = max(worst['p_betaP'], p - bP)
    worst['d'] = max(worst['d'], dd - (L - 1) * p)
    worst['b3a'] = max(worst['b3a'], bP - L * p)
    worst['b3b'] = max(worst['b3b'], bC - L * p)
    # (B): int TV(P, C_u) d d_{C_t} <= L beta(C_u) + (L-1) beta(C_t), with C_u = C, C_t = C2
    tvu = [eng.tv_point(P[x], C[x]) for x in range(nx)]
    d2 = eng.visit(sc, C2)
    lhs = sum(tvu[x] * d2[x] for x in range(nx))
    rhs = L * bC + (L - 1) * eng.beta_along(sc, C2, P, C2)
    worst['pair'] = max(worst['pair'], lhs - rhs)
    ncase += 1
print("(A) Lemma 1.4 on %d random scaffolds (horizon 1..4, runs with no call, abstaining kernels):" % ncase)
print("    max [TV(Q_C,Q_P) - p]            = %+.3e  (must be <= 0)" % worst['tv_p'])
print("    max [p - beta(C)]                = %+.3e  (must be <= 0)" % worst['p_beta'])
print("    max [p - beta^P(C)]              = %+.3e  (must be <= 0)" % worst['p_betaP'])
print("    max [|int g d(d_C - d_P)| - (L-1)p] = %+.3e  (must be <= 0)" % worst['d'])
print("    max [beta^P(C) - L p]            = %+.3e  (must be <= 0)" % worst['b3a'])
print("    max [beta(C) - L p]              = %+.3e  (must be <= 0)" % worst['b3b'])
print("(B) proof of Prop. 2.3: max [int TV(P,C_u) d d_Ct - L beta(C_u) - (L-1) beta(C_t)] = %+.3e (<= 0)" % worst['pair'])


# ---------------------------------------------------------------- exact Protocol R
def protocol_R_paths(sc, hyps, w, P, n):
    """Enumerate all data paths of Protocol R (mixture-driven, one uniformly chosen call
    slot asked).  Yields (prob, list of per-round records); record = (M, d_t, beta_t)."""
    L, nx, ny = sc['L'], sc['nx'], sc['ny']
    cache = {}

    def info(data):
        key = tuple(sorted(data))
        if key not in cache:
            post, _ = eng.posterior(hyps, w, data)
            M = eng.mixture(hyps, post)
            d = eng.visit(sc, M)
            b = eng.beta_along(sc, M, P, M)
            cache[key] = (M, d, b)
        return cache[key]

    def rec(t, data, pr, recs):
        if t == n:
            yield pr, recs
            return
        M, d, b = info(data)
        recs2 = recs + [(M, d, b)]
        pnone = 1.0 - sum(d) / L
        if pnone > 1e-15:
            yield from rec(t + 1, data, pr * pnone, recs2)
        for x in range(nx):
            if d[x] <= 0:
                continue
            for y in range(ny):
                if P[x][y] > 0:
                    yield from rec(t + 1, data + [(x, y)], pr * d[x] / L * P[x][y], recs2)

    yield from rec(0, [], 1.0, [])


# ---------------------------------------------------------------- (C) Example 2.2
def example22_engine(L, omega, n):
    # inputs: 0 = x0, 1 = a, 2 = b ; answers 0, 1
    f = [[1.0, 0.0, 0.0]] * 3
    g = [[0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]]
    nxt = {}
    for j in range(L):
        for hist in itertools.product(range(2), repeat=j):
            nxt[(0, hist)] = 0 if j == 0 else (1 if hist[0] == 0 else 2)
    sc = dict(D0=[1.0], nxt=nxt, L=L, nz=1, nx=3, ny=2)
    hyps, w = [f, g], [omega, 1 - omega]
    d_f = eng.visit(sc, f)
    own = hum = 0.0
    dbar = [0.0, 0.0, 0.0]
    tot = 0.0
    for pr, recs in protocol_R_paths(sc, hyps, w, f, n):
        tot += pr
        for (M, d, b) in recs:
            own += pr * b / n
            hum += pr * sum((1 - M[x][0]) * d_f[x] for x in range(3)) / n
            for x in range(3):
                dbar[x] += pr * d[x] / n
    B = max(d_f[x] / dbar[x] for x in range(3) if d_f[x] > 0)
    return own, hum, B, tot


def example22_closed(L, omega, n):
    kappa = (1 + omega * (L - 1)) / L
    S = (1 - (1 - kappa) ** n) / kappa                    # sum of pi_t
    own = (1 - omega) * (1 + omega * (L - 1)) * S / n
    hum = (1 - omega) * L * S / n
    dbar_a = (L - 1) * (1 - (1 - omega) * S / n)
    B = max(1.0, (L - 1) / dbar_a)
    return own, hum, B


print("\n(C) Example 2.2: generic exact engine against the closed forms of the text")
for (L, om, n) in [(2, 0.5, 5), (3, 0.3, 6), (4, 0.25, 6), (5, 0.1, 5)]:
    e = example22_engine(L, om, n)
    c = example22_closed(L, om, n)
    print("    L=%d omega=%.2f n=%d: beta_own %.6f / %.6f   beta_hum %.6f / %.6f   B %.5f / %.5f  (engine / closed; total prob %.6f)"
          % (L, om, n, e[0], c[0], e[1], c[1], e[2], c[2], e[3]))
    assert abs(e[0] - c[0]) < 1e-9 and abs(e[1] - c[1]) < 1e-9 and abs(e[2] - c[2]) < 1e-9
print("    closed forms at the parameters quoted in the text:")
for (L, om, n) in [(100, 0.01, 10**4), (1000, 0.001, 10**6)]:
    own, hum, B = example22_closed(L, om, n)
    K = math.log2(1 / om)
    claim = B * L * K * LN2 / n
    print("    L=%d omega=%g n=%d: E int e dd_f = %.4f ; candidate's bound B L K ln2/n = %.5f ; B = %.4f ; ratio %.2f ; L/(2 ln L) = %.2f ;"
          " beta_hum/beta_own = %.2f ; (2L-1) B beta_own = %.3f"
          % (L, om, n, hum, claim, B, hum / claim, L / (2 * math.log(L)), hum / own, (2 * L - 1) * B * own))
print("    the ratio beta_hum/beta_own = L/(1+omega(L-1)) tends to L as omega -> 0 (n large, B -> 1):")
for om in [1e-2, 1e-4, 1e-6]:
    L, n = 50, 10**7
    own, hum, B = example22_closed(L, om, n)
    print("      L=50 omega=%g n=1e7: ratio %.3f, B = %.6f, so the factor in Prop. 2.3 is at least %.3f" % (om, hum / own, B, hum / own / B))
print("    largest violation of the candidate's bound over omega (L=1000, n=1e7):")
best = max(((example22_closed(1000, om, 10**7)[1] / (example22_closed(1000, om, 10**7)[2] * 1000 * math.log(1 / om) / 10**7), om)
            for om in [10 ** (-e / 4) for e in range(4, 40)]))
print("      max ratio %.1f at omega = %.2e ; L/ln L = %.1f ; L/(2 ln L) = %.1f" % (best[0], best[1], 1000 / math.log(1000), 500 / math.log(1000)))

# ---------------------------------------------------------------- (D), (E)
print("\n(D) Corollary 1.3 (R1) and Proposition 2.3 with Protocol R enumerated exactly (random classes and scaffolds)")
w_r1 = w_23a = w_23b = w_r1tv = -9.0
w_lem12 = 0.0
cases = 0
for trial in range(160):
    nx, ny = rng.randint(2, 3), 2
    L = rng.randint(1, 3)
    n = rng.randint(1, 4)
    sc = eng.random_scaffold(rng, nx, ny, rng.randint(1, 2), L, stop_prob=rng.choice([0.0, 0.3]),
                             stop0=rng.choice([0.0, 0.0, 0.3]))
    nh = rng.randint(2, 4)
    det = rng.random() < 0.5
    semi = (not det) and rng.random() < 0.4
    hyps = [eng.random_kernel(rng, nx, ny, det=det, abort=semi) for _ in range(nh)]
    hyps[0] = eng.random_kernel(rng, nx, ny, det=det)      # the human is a sampler (no missing mass)
    w = [rng.random() + 0.05 for _ in range(nh)]
    W = rng.choice([1.0, 0.6])
    s = sum(w); w = [x * W / s for x in w]
    P = hyps[0]
    K = math.log2(1 / w[0])
    Ebeta = 0.0            # E beta(M^(T))
    EKL = 0.0              # (1/n) sum_t E int KL(P || M^(t)) d d_t
    lhs_real = 0.0         # E_T int TV(P, M^(T)) d dbar_realised
    Edbar = [0.0] * nx
    per_u = []             # for the expected-dbar version
    for pr, recs in protocol_R_paths(sc, hyps, w, P, n):
        betas = [r[2] for r in recs]
        Ebeta += pr * sum(betas) / n
        for (M, d, b) in recs:
            for x in range(nx):
                if d[x] > 0:
                    kl = sum(P[x][y] * math.log(P[x][y] / M[x][y]) for y in range(ny) if P[x][y] > 0)
                    EKL += pr * d[x] * kl / n
        dbar = [sum(r[1][x] for r in recs) / n for x in range(nx)]
        for x in range(nx):
            Edbar[x] += pr * dbar[x]
        tvs = [[eng.tv_point(P[x], r[0][x]) for x in range(nx)] for r in recs]
        avg_tv = [sum(tvs[u][x] for u in range(n)) / n for x in range(nx)]
        lhs_real += pr * sum(avg_tv[x] * dbar[x] for x in range(nx))
        per_u.append((pr, avg_tv))
    lhs_exp = sum(pr * sum(avg_tv[x] * Edbar[x] for x in range(nx)) for pr, avg_tv in per_u)
    w_r1 = max(w_r1, EKL - L * math.log(W / w[0]) / n)
    if det:
        w_r1tv = max(w_r1tv, Ebeta - L * K * LN2 / n)
    else:
        w_r1tv = max(w_r1tv, Ebeta - L * math.sqrt(K * LN2 / (2 * n)))
    w_23a = max(w_23a, lhs_real - (2 * L - 1) * Ebeta)
    w_23b = max(w_23b, lhs_exp - (2 * L - 1) * Ebeta)
    cases += 1
print("    %d instances (functions and samplers, semimeasure hypotheses, total weight 1 or 0.6, n = 1..4, L = 1..3)" % cases)
print("    max [(1/n) sum_t E int KL dd_t - L ln(W/w(P))/n]      = %+.3e (<= 0)" % w_r1)
print("    max [E beta(M^(T)) - R1 bound]                         = %+.3e (<= 0)" % w_r1tv)
print("    max [E int TV(P,M^(T)) d dbar_realised - (2L-1) E beta] = %+.3e (<= 0)" % w_23a)
print("    max [E int TV(P,M^(T)) d E[dbar] - (2L-1) E beta]       = %+.3e (<= 0)" % w_23b)

# ---------------------------------------------------------------- (F)
print("\n(F) Proposition 2.4(c): (N0 - m) p/(N0 + L) <= delta with N0 = L/(2 delta) forces m >= L/(4 delta) - L")
bad = 0; tightest = 1e9
for L in range(1, 41):
    for N0 in range(max(2 * L, 2), 60 * L + 1, max(1, L // 2)):
        delta = L / (2 * N0)
        if delta > 0.25:
            continue
        p = 1 - (1 - 1 / N0) ** L
        m_min = N0 - delta * (N0 + L) / p          # least m allowed by the first inequality
        lower = L / (4 * delta) - L
        tightest = min(tightest, m_min - lower)
        if m_min < lower - 1e-9:
            bad += 1
print("    violations: %d ; smallest slack (m_min - (L/(4 delta) - L)) = %.4f" % (bad, tightest))
print("    Proposition 2.1(d): lower bound N (L/(4 delta) - 3L/2) against Protocol R's N L K ln2/delta, ratio = 4 K ln2 / (1 - 6 delta):")
for (N, L, delta) in [(8, 4, 0.05), (64, 10, 0.01), (1024, 10, 0.01)]:
    N0 = math.ceil(L / (2 * delta)); K = math.log2(N * N0 + 1)
    lo = N * (L / (4 * delta) - 1.5 * L); up = N * L * K * LN2 / delta
    print("      N=%d L=%d delta=%g: K = %.2f, lower %.0f, upper %.0f, ratio %.1f" % (N, L, delta, K, lo, up, up / lo))
