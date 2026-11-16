#!/usr/bin/env python3
"""Referee's checks of Section 4 of research/prove-c/shift-abstain.md (Ab1).

(A) Theorem 4.1 on random classes, all orders, every member as the human; total weight
    below 1; classes that also contain samplers; the claim "never wrong if eta < w(f)/W".
(B) Example 4.2 (a), (b) in exact rational arithmetic.
(C) Proposition 4.3(b): exact expectations for the two audit variants on random classes
    and adaptive input rules; the tightness example.
(D) Theorem 4.4: Protocol R[Thr_eta] enumerated exactly on random adaptive scaffolds.
(E) Theorem 4.5: linear programme over all (symmetrised) protocols; the bound; the
    protocol "refuse a fraction a of the runs outright" (tightness in a).
(F) Proposition 4.6: exact value of the game, against C(m+1, <= k+1) - 1.
(G) Proposition 4.7: the inequalities for kl on a grid; the two expected counts, exactly.
(H) Proposition 4.8: the identity, for random randomised rules.
"""
import importlib.util, math, os, random, itertools, sys
from fractions import Fraction as Fr
from functools import lru_cache
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("eng", os.path.join(here, "shift-abstain_engine.py"))
eng = importlib.util.module_from_spec(spec); spec.loader.exec_module(eng)
rng = random.Random(11)
LN2 = math.log(2)
log2 = math.log2


def thr_kernel(M, eta, ny):
    """Threshold rule as a kernel with an abstention column."""
    C = []
    for x in range(len(M)):
        row = [0.0] * (ny + 1)
        ys = [y for y in range(ny) if M[x][y] >= 1 - eta]
        if ys:
            row[ys[0]] = 1.0
        else:
            row[ny] = 1.0
        C.append(row)
    return C


# ------------------------------------------------------------------ (A)
used = 0.0; cases = 0; neverwrong_viol = 0; nw_cases = 0
for trial in range(400):
    nx, ny = rng.randint(2, 5), rng.randint(2, 3)
    nh = rng.randint(2, 7)
    hyps = [eng.random_kernel(rng, nx, ny, det=True) for _ in range(nh)]
    if trial % 3 == 0:      # add samplers to the class; the human stays a function
        hyps += [eng.random_kernel(rng, nx, ny, abort=rng.random() < 0.5) for _ in range(2)]
    w = [rng.random() ** 2 + 0.01 for _ in hyps]
    W = rng.choice([1.0, 0.7, 0.3]); s = sum(w); w = [v * W / s for v in w]
    eta = rng.choice([0.05, 0.2, 0.35, 0.49])
    for hi in range(nh):
        f = hyps[hi]
        fval = [f[x].index(1.0) for x in range(nx)]
        for order in itertools.permutations(range(nx)):
            data = []; wr = ab = 0
            for x in order:
                post, _ = eng.posterior(hyps, w, data)
                M = eng.mixture(hyps, post)
                C = thr_kernel(M, eta, ny)
                if C[x][ny] == 1.0: ab += 1
                elif C[x][fval[x]] != 1.0: wr += 1
                data.append((x, fval[x]))
            budget = log2(W / w[hi])
            use = wr * log2(1 / eta) + ab * log2(1 / (1 - eta))
            used = max(used, use / budget if budget > 0 else 0.0)
            assert use <= budget + 1e-9, (use, budget)
            cases += 1
        # never wrong if eta0 < w(f)/W : all data lists (subsets of inputs) and all x
        eta0 = min(0.49, 0.999 * w[hi] / W)
        for r in range(nx + 1):
            for sub in itertools.combinations(range(nx), r):
                data = [(x, fval[x]) for x in sub]
                post, _ = eng.posterior(hyps, w, data)
                M = eng.mixture(hyps, post)
                C = thr_kernel(M, eta0, ny)
                for x in range(nx):
                    nw_cases += 1
                    if C[x][ny] != 1.0 and C[x][fval[x]] != 1.0:
                        neverwrong_viol += 1
print("(A) Theorem 4.1: %d (class, human, order) cases; largest (used budget)/(log2(W/w(f))) = %.4f (<= 1)" % (cases, used))
print("    'never wrong if eta < w(f)/W': %d (data list, input) cases, violations %d" % (nw_cases, neverwrong_viol))

# ------------------------------------------------------------------ (B)
def example42a(K, eta):
    k = int(K // log2(1 / float(eta)))
    W = Fr(1, 2 ** K) / eta ** k
    wg = [(1 - eta) * eta ** i * W for i in range(k)]
    wf = eta ** k * W
    assert sum(wg) + wf == W and W <= 1 and wf == Fr(1, 2 ** K)
    wrong = 0
    tot = W                                 # weight of the hypotheses consistent before round i
    for i in range(k):
        m1 = wg[i] / tot                    # mixture probability of answer 1 at x_i
        if m1 >= 1 - eta: wrong += 1
        tot -= wg[i]                        # g_i is refuted by the answer 0
    return k, wrong


def example42b(K, eta, etap):
    kp = int(K // log2(1 / (1 - float(etap))))
    W = Fr(1, 2 ** K) / (1 - etap) ** kp
    wf = (1 - etap) ** kp * W
    ab = 0
    tot = W
    wgi = etap * W
    s = Fr(0)
    for i in range(kp):
        m1 = wgi / tot
        if not (m1 >= 1 - eta) and not (1 - m1 >= 1 - eta): ab += 1
        tot -= wgi; s += wgi
        wgi *= (1 - etap)
    assert s + wf == W and W <= 1 and tot == wf
    return kp, ab


print("(B) Example 4.2 in exact arithmetic")
for K, eta in [(20, Fr(1, 4)), (20, Fr(1, 10)), (40, Fr(1, 100)), (7, Fr(49, 100))]:
    k, wr = example42a(K, eta)
    etap = eta + Fr(1, 2 ** 12)
    kp, ab = example42b(K, eta, etap)
    print("    K=%d eta=%s: (a) wrong rounds %d of k = %d, bound K/log2(1/eta) = %.3f ; (b) abstention rounds %d of k' = %d, bound K/log2(1/(1-eta)) = %.3f"
          % (K, eta, wr, k, K / log2(1 / float(eta)), ab, kp, K / log2(1 / (1 - float(eta)))))
print("    (for K < log2(1/eta) the example (a) has k = 0 rounds: K=1, eta=1/4 gives k = %d)" % int(1 // log2(4)))

# ------------------------------------------------------------------ (C)
def audits_exact(hyps, w, fval, eta, q, h, rule, variant):
    """Exact E[Sil], E[Abs], max Abs on a path (variant A), E[questions]."""
    ny = len(hyps[0][0]) - 1
    acc = dict(sil=0.0, abs=0.0, qu=0.0, maxabs=0)

    def rec(t, data, pr, nabs):
        if t == h:
            acc['maxabs'] = max(acc['maxabs'], nabs)
            return
        post, _ = eng.posterior(hyps, w, data)
        M = eng.mixture(hyps, post)
        x = rule(post, M)
        C = thr_kernel(M, eta, ny)
        abst = C[x][ny] == 1.0
        wrong = (not abst) and C[x][fval[x]] != 1.0
        # coin = 1: asked
        acc['qu'] += pr * q
        rec(t + 1, data + [(x, fval[x])], pr * q, nabs)
        # coin = 0
        if q < 1:
            p0 = pr * (1 - q)
            if wrong:
                acc['sil'] += p0
                rec(t + 1, data, p0, nabs)
            elif abst:
                acc['abs'] += p0
                if variant == 'A':
                    acc['qu'] += p0
                    rec(t + 1, data + [(x, fval[x])], p0, nabs + 1)
                else:
                    rec(t + 1, data, p0, nabs + 1)
            else:
                rec(t + 1, data, p0, nabs)

    rec(0, [], 1.0, 0)
    return acc


wsil = wabsA = wabsB = wqu = -9.0
for trial in range(120):
    nx, ny = rng.randint(2, 4), 2
    nh = rng.randint(2, 6)
    hyps = [eng.random_kernel(rng, nx, ny, det=True) for _ in range(nh)]
    w = [rng.random() ** 2 + 0.01 for _ in hyps]; s = sum(w); w = [v / s for v in w]
    fval = [hyps[0][x].index(1.0) for x in range(nx)]
    eta = rng.choice([0.1, 0.3, 0.45]); q = rng.choice([0.2, 0.5, 0.8]); h = 9
    K = log2(1 / w[0])
    # adversarial rule: an input where the threshold rule is wrong if there is one, else where it abstains
    def rule(post, M, fval=fval, eta=eta, ny=ny, nx=nx):
        C = thr_kernel(M, eta, ny)
        for x in range(nx):
            if C[x][ny] != 1.0 and C[x][fval[x]] != 1.0: return x
        for x in range(nx):
            if C[x][ny] == 1.0: return x
        return 0
    for variant in 'AB':
        a = audits_exact(hyps, w, fval, eta, q, h, rule, variant)
        wsil = max(wsil, a['sil'] - (1 - q) / q * K / log2(1 / eta))
        if variant == 'A':
            wabsA = max(wabsA, a['maxabs'] - K / log2(1 / (1 - eta)))
            wqu = max(wqu, a['qu'] - (q * h + K / log2(1 / (1 - eta))))
        else:
            wabsB = max(wabsB, a['abs'] - K / (q * log2(1 / (1 - eta))))
print("(C) Proposition 4.3(b), exact, 120 random classes, adversarial input rule, 9 steps:")
print("    max [E Sil - ((1-q)/q) K/log2(1/eta)]            = %+.3e (<= 0)" % wsil)
print("    variant A: max over paths [Abs - K/log2(1/(1-eta))] = %+.3e (<= 0);  max [E Qu - (q h + K/log2(1/(1-eta)))] = %+.3e (<= 0)" % (wabsA, wqu))
print("    variant B: max [E Abs - K/(q log2(1/(1-eta)))]   = %+.3e (<= 0)" % wabsB)
# tightness: class of Example 4.2(a), input x_i shown until asked
K, eta, q = 8, 0.25, 0.3
k = int(K // log2(1 / eta))
print("    tightness example (K=8, eta=1/4, q=0.3): E Sil = k(1-q)/q = %.4f ; bound %.4f" % (k * (1 - q) / q, (1 - q) / q * K / log2(1 / eta)))

# ------------------------------------------------------------------ (D)
def protocol_thr_exact(sc, hyps, w, fval, eta, n):
    """sum_t (log2(1/eta) E Wr_t + log2(1/(1-eta)) P[Halt_t]) for Protocol R[Thr_eta]."""
    L, nx, ny = sc['L'], sc['nx'], sc['ny']
    total = [0.0]
    cache = {}

    def info(data):
        key = tuple(sorted(data))
        if key not in cache:
            post, _ = eng.posterior(hyps, w, data)
            M = eng.mixture(hyps, post)
            C = thr_kernel(M, eta, ny)
            rs = eng.runs(sc, C)
            wr = sum(pr * sum(1 for x, y in zip(xs, ys) if y != eng.ABORT and y != fval[x]) for pr, z, xs, ys in rs)
            halt = sum(pr for pr, z, xs, ys in rs if ys and ys[-1] == eng.ABORT)
            d = eng.visit(sc, C)
            cache[key] = (wr, halt, d)
        return cache[key]

    def rec(t, data, pr):
        if t == n: return
        wr, halt, d = info(data)
        total[0] += pr * (log2(1 / eta) * wr + log2(1 / (1 - eta)) * halt)
        pnone = 1.0 - sum(d) / L
        if pnone > 1e-15: rec(t + 1, data, pr * pnone)
        for x in range(nx):
            if d[x] > 0: rec(t + 1, data + [(x, fval[x])], pr * d[x] / L)

    rec(0, [], 1.0)
    return total[0]


worst = 0.0; cnt = 0; anywrong = 0
for trial in range(300):
    nx, ny = rng.randint(2, 4), 2
    L = rng.randint(1, 3); n = rng.randint(1, 5)
    sc = eng.random_scaffold(rng, nx, ny, rng.randint(1, 3), L, stop_prob=rng.choice([0.0, 0.3]), stop0=rng.choice([0, 0, 0.3]))
    nh = rng.randint(2, 6)
    hyps = [eng.random_kernel(rng, nx, ny, det=True) for _ in range(nh)]
    w = [rng.random() ** 3 + 0.01 for _ in hyps]
    W = rng.choice([1.0, 0.5]); s = sum(w); w = [v * W / s for v in w]
    fval = [hyps[0][x].index(1.0) for x in range(nx)]
    eta = rng.choice([0.1, 0.3, 0.45])
    tot = protocol_thr_exact(sc, hyps, w, fval, eta, n)
    bud = L * log2(W / w[0])
    worst = max(worst, tot / bud if bud > 0 else 0)
    assert tot <= bud + 1e-9
    cnt += 1
print("(D) Theorem 4.4: %d instances of Protocol R[Thr_eta] enumerated exactly (n = 1..5, L = 1..3, runs of different lengths, W = 1 or 0.5):" % cnt)
print("    largest [sum_t (log2(1/eta) E Wr_t + log2(1/(1-eta)) P(Halt_t))] / (L log2(W/w(f))) = %.4f (<= 1)" % worst)

# ------------------------------------------------------------------ (E)
import numpy as np
from scipy.optimize import linprog


def dist_unasked_visited(N0, L, k):
    """Law of u = number of distinct unasked cells among L independent uniform cells,
    when k of the N0 cells are asked."""
    # dp over calls: state = number of distinct unasked cells visited so far
    dist = {0: 1.0}
    for _ in range(L):
        new = {}
        for u, pr in dist.items():
            p_new = (N0 - k - u) / N0
            if p_new > 0: new[u + 1] = new.get(u + 1, 0.0) + pr * p_new
            if 1 - p_new > 0: new[u] = new.get(u, 0.0) + pr * (1 - p_new)
        dist = new
    return dist


def lp_needle(N0, L, n, a_max):
    """min over symmetrised protocols of max_f sigma(f), subject to E|S| <= n and
    P_{f0}[abstain] <= a_max.  Variables v_b(k,u) = P(k) * Pr[outcome b | k, u], b in {0,1,abst};
    P(k) = law of the number of asked cells on the all-zero path."""
    idx = {}; cols = 0
    pis = {}
    for k in range(N0 + 1):
        pis[k] = dist_unasked_visited(N0, L, k)
        for u in pis[k]:
            for b in range(3):
                idx[(k, u, b)] = cols; cols += 1
    for k in range(N0 + 1):
        idx[('P', k)] = cols; cols += 1
    sig = cols; cols += 1
    c = np.zeros(cols); c[sig] = 1.0
    A_ub = []; b_ub = []; A_eq = []; b_eq = []
    # v_0 + v_1 + v_abst = P(k) for each (k,u)
    for k in range(N0 + 1):
        for u in pis[k]:
            row = np.zeros(cols)
            for b in range(3): row[idx[(k, u, b)]] = 1.0
            row[idx[('P', k)]] = -1.0
            A_eq.append(row); b_eq.append(0.0)
    row = np.zeros(cols)
    for k in range(N0 + 1): row[idx[('P', k)]] = 1.0
    A_eq.append(row); b_eq.append(1.0)
    row = np.zeros(cols)                                 # E|S| <= n
    for k in range(N0 + 1): row[idx[('P', k)]] = k
    A_ub.append(row); b_ub.append(n)
    row = np.zeros(cols)                                 # abstention under f0
    for k in range(N0 + 1):
        for u, pu in pis[k].items(): row[idx[(k, u, 2)]] = pu
    A_ub.append(row); b_ub.append(a_max)
    row = np.zeros(cols)                                 # sigma(f0) = P[outcome 1] <= sig
    for k in range(N0 + 1):
        for u, pu in pis[k].items(): row[idx[(k, u, 1)]] = pu
    row[sig] = -1.0
    A_ub.append(row); b_ub.append(0.0)
    row = np.zeros(cols)                                 # sigma(needle), by symmetry the same for every needle
    for k in range(N0 + 1):
        for u, pu in pis[k].items():
            # needle c uniform among the N0 cells; unasked with prob (N0-k)/N0; then in the run w.p. u/(N0-k)
            row[idx[(k, u, 0)]] = pu * u / N0
            row[idx[(k, u, 1)]] = pu * (N0 - k - u) / N0
    row[sig] = -1.0
    A_ub.append(row); b_ub.append(0.0)
    res = linprog(c, A_ub=np.array(A_ub), b_ub=np.array(b_ub), A_eq=np.array(A_eq), b_eq=np.array(b_eq),
                  bounds=[(0, None)] * cols, method='highs')
    assert res.status == 0, res.message
    return res.fun


print("(E) Theorem 4.5: least max_f sigma(f) (linear programme) against ((N0-n)p - L a)/(N0+L)")
print("     N0  L    n     a        LP     bound   refuse-a-fraction")
viol = 0
for N0, L in [(4, 2), (5, 2), (4, 3), (8, 2), (10, 3), (12, 4)]:
    p = 1 - (1 - 1 / N0) ** L
    for n in [0, 1, 2.5, N0 / 2]:
        for a in [0.0, 0.2, 0.5]:
            v = lp_needle(N0, L, n, a)
            bd = max(0.0, ((N0 - n) * p - L * a) / (N0 + L))
            # protocol that refuses every run with probability a and otherwise is the best protocol
            # without abstention that uses n/(1-a) expected questions
            mix = (1 - a) * lp_needle(N0, L, min(N0, n / (1 - a)), 0.0)
            if v < bd - 1e-7: viol += 1
            if (N0, L) in [(4, 2), (4, 3), (12, 4)]:
                print("    %3d %2d %4.1f  %.1f   %.4f   %.4f   %.4f" % (N0, L, n, a, v, bd, mix))
print("    violations of the bound: %d" % viol)
# the consequence n >= (1-a)^2 L/(4 sigma) - L, checked through the LP: least n with max sigma <= sigma
print("    consequence: least expected number of questions (LP, bisection) against (1-a)^2 L/(4 sigma) - L, N0 = (1-a)L/(2 sigma)")
for L, sigma, a in [(2, 0.1, 0.0), (2, 0.1, 0.2), (3, 0.1, 0.25), (2, 0.05, 0.5), (4, 0.125, 0.0), (4, 0.1, 0.5)]:
    N0 = (1 - a) * L / (2 * sigma)
    if abs(N0 - round(N0)) > 1e-9: continue
    N0 = int(round(N0))
    lo, hi = 0.0, float(N0)
    for _ in range(40):
        mid = (lo + hi) / 2
        if lp_needle(N0, L, mid, a) <= sigma + 1e-9: hi = mid
        else: lo = mid
    print("      L=%d sigma=%.3f a=%.2f N0=%d: least n = %.3f ; bound %.3f" % (L, sigma, a, N0, hi, (1 - a) ** 2 * L / (4 * sigma) - L))

# ------------------------------------------------------------------ (F)
@lru_cache(maxsize=None)
def feasible(n, k, m):
    """Can a deterministic rule keep <= k wrong answers and <= m wrong-or-abstained rounds
    when n thresholds are consistent?  An input splits them into a lower part (answer 0)
    and an upper part (answer 1)."""
    if n <= 1: return True
    for a in range(1, n):
        b = n - a
        ok = False
        if m >= 1 and feasible(a, k, m - 1) and feasible(b, k, m - 1): ok = True            # abstain
        if not ok and feasible(a, k, m) and (k >= 1 and m >= 1 and feasible(b, k - 1, m - 1)): ok = True   # answer 0
        if not ok and feasible(b, k, m) and (k >= 1 and m >= 1 and feasible(a, k - 1, m - 1)): ok = True   # answer 1
        if not ok: return False
    return True


def binom_le(t, j): return sum(math.comb(t, i) for i in range(j + 1))
print("(F) Proposition 4.6: largest number of thresholds that a rule can handle (exact game) and C(m+1, <= k+1) - 1")
allok = True
for k in range(0, 4):
    vals = []
    for m in range(0, 8):
        F = binom_le(m + 1, k + 1) - 1
        if F > 140: vals.append("(%d not computed)" % F); continue
        n = 1
        while feasible(n + 1, k, m): n += 1
        vals.append("%d" % n)
        if n != F: allok = False
    print("    k=%d, m=0..7: %s" % (k, " ".join(vals)))
print("    equal to the formula in every computed case: %s" % allok)
bad = 0
for k in range(0, 6):
    for e in range(k + 1, 40):
        N = 2 ** e
        # least m with N <= F(k,m)
        m = 0
        while binom_le(m + 1, k + 1) - 1 < N: m += 1
        if m - k < (k + 1) * N ** (1 / (k + 1)) / math.e - k - 1 - 1e-9: bad += 1
print("    consequence (abstentions >= (k+1) N^(1/(k+1))/e - k - 1 for N = 2^e >= 2^(k+1)): violations %d" % bad)

# ------------------------------------------------------------------ (G)
def kl(a, b):
    t = 0.0
    if a > 0: t += a * math.log(a / b)
    if a < 1: t += (1 - a) * math.log((1 - a) / (1 - b))
    return t
def hbin(e): return 0.0 if e in (0, 1) else -e * math.log(e) - (1 - e) * math.log(1 - e)
bad1 = bad2 = bad3 = 0
for i in range(1, 200):
    eta = 0.5 * i / 200
    for j in range(0, 200):
        eps = eta * j / 200
        if kl(1 - eps, eta) < (1 - eps) * math.log(1 / eta) - hbin(eps) - 1e-12: bad1 += 1
        if kl(eps, eta) < (eta - eps) ** 2 / (2 * eta) - 1e-12: bad2 += 1
        if eps <= eta / 2 and 1 / kl(eps, eta) > 8 / eta + 1e-9: bad3 += 1
print("(G) Proposition 4.7: kl(1-e0||eta) >= (1-e0) ln(1/eta) - h(e0): violations %d ; kl(e0||eta) >= (eta-e0)^2/(2 eta): %d ; 1/kl(e0||eta) <= 8/eta for e0 <= eta/2: %d" % (bad1, bad2, bad3))
# exact expected counts for a human with a mode, asked inputs in a fixed adaptive order
worstw = worsta = -9.0
for trial in range(60):
    nx, ny = rng.randint(2, 3), 2
    eta = rng.choice([0.2, 0.35]); eps0 = rng.choice([0.0, 0.02, 0.1])
    nh = rng.randint(2, 5)
    mode = [rng.randrange(ny) for _ in range(nx)]
    P = []
    for x in range(nx):
        e = eps0 * rng.random()
        row = [e, e, 0.0]; row[mode[x]] = 1 - e
        P.append(row)
    hyps = [P] + [eng.random_kernel(rng, nx, ny, det=rng.random() < 0.5) for _ in range(nh - 1)]
    w = [rng.random() ** 2 + 0.02 for _ in hyps]; s = sum(w); w = [v / s for v in w]
    K = log2(1 / w[0]); h = 8
    acc = [0.0, 0.0]
    def rec(t, data, pr):
        if t == h: return
        post, _ = eng.posterior(hyps, w, data)
        M = eng.mixture(hyps, post)
        C = thr_kernel(M, eta, ny)
        # asked input: where the rule is off the mode, else where it abstains, else cyclic
        x = next((x for x in range(nx) if C[x][ny] != 1.0 and C[x][mode[x]] != 1.0),
                 next((x for x in range(nx) if C[x][ny] == 1.0), t % nx))
        if C[x][ny] == 1.0: acc[1] += pr
        elif C[x][mode[x]] != 1.0: acc[0] += pr
        for y in range(ny):
            if P[x][y] > 0: rec(t + 1, data + [(x, y)], pr * P[x][y])
    rec(0, [], 1.0)
    worstw = max(worstw, acc[0] - K * LN2 / kl(1 - eps0, eta))
    worsta = max(worsta, acc[1] - K * LN2 / kl(eps0, eta))
    # the joint form
    assert acc[0] * kl(1 - eps0, eta) + acc[1] * kl(eps0, eta) <= K * LN2 + 1e-9
print("    exact, 60 random classes, 8 asked rounds: max [E wrong - K ln2/kl(1-e0||eta)] = %+.3f ; max [E abst - K ln2/kl(e0||eta)] = %+.3f (both <= 0)" % (worstw, worsta))

# ------------------------------------------------------------------ (H)
print("(H) Proposition 4.8: Abs(P0) = N - 2 * mean_b Sil(g_b) for random randomised rules")
maxdiff = 0.0
for trial in range(200):
    N = rng.randint(1, 7)
    rule = {}
    def r(hist):
        if hist not in rule:
            v = [rng.random(), rng.random(), rng.random() * rng.choice([0, 1, 3])]
            s = sum(v); rule[hist] = [a / s for a in v]      # probabilities of 0, 1, abstention
        return rule[hist]
    sil_mean = 0.0; abs0 = 0.0
    for b in itertools.product(range(2), repeat=N):
        for t in range(N):
            law = r(b[:t])
            sil_mean += law[1 - b[t]] / 2 ** N
            abs0 += law[2] / 2 ** N              # under P0 the earlier answers are uniform
    maxdiff = max(maxdiff, abs(abs0 - (N - 2 * sil_mean)))
print("    largest |Abs(P0) - (N - 2 mean Sil)| over 200 rules: %.2e" % maxdiff)
