#!/usr/bin/env python3
"""Referee's checks of Section 3 of research/prove-c/shift-abstain.md (open systems).

(A) Theorem 3.1 and Example 3.2(i): exact enumeration of the online form (each step asked
    with probability q) against an adaptive input rule, for functions and for samplers,
    with semimeasure hypotheses and total weight below 1.  Checks
       sum_t E[q KL_t] <= ln(W/w(P)),  the identity of Example 3.2(i),
       E[silent errors] <= (1-q) K ln2 / q,  sum_t E[TV_t^2] <= K ln2/(2q).
(B) Example 3.2(ii): exact value K(1-q)/(2q).
(C) Theorem 3.3(a): exact minimum over all deterministic learners with at most Q
    questions on every run (dynamic programme over information states), against the
    bound (N^2/(Q+1) - (Q+1))/4; part (c): the stated learner, simulated.
(D) Theorem 3.3(b): lower hull of (E[Qu], E[Sil]) over all learners (Lagrangian dynamic
    programme), against N/(9(Qbar+1)) - sqrt((Qbar+1)/(8N)) and N/15.
(E) Lemma 3.4 on random and near-extremal sequences.  (F) constants.
"""
import importlib.util, math, os, random, itertools, sys
from functools import lru_cache
here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("eng", os.path.join(here, "shift-abstain_engine.py"))
eng = importlib.util.module_from_spec(spec); spec.loader.exec_module(eng)
rng = random.Random(7)
LN2 = math.log(2)


# ------------------------------------------------------------------ (A)
def online_exact(hyps, w, P, q, h, rule):
    """Steps 1..h.  rule(post, M) -> input.  Returns E sum KL_t (all steps), E sum c_t KL_t,
    E ln(1/w_D(P)) at the end, E silent errors (function human), E sum TV_t^2."""
    nx = len(P); ny = len(P[0]) - 1
    acc = dict(kl=0.0, ckl=0.0, endlog=0.0, sil=0.0, tv2=0.0)

    def rec(t, data, pr):
        post, _ = eng.posterior(hyps, w, data)
        if t == h:
            acc['endlog'] += pr * math.log(1 / post[0])
            return
        M = eng.mixture(hyps, post)
        x = rule(post, M)
        kl = sum(P[x][y] * math.log(P[x][y] / M[x][y]) for y in range(ny) if P[x][y] > 0)
        tv = eng.tv_point(P[x], M[x])
        acc['kl'] += pr * kl
        acc['ckl'] += pr * q * kl
        acc['tv2'] += pr * tv * tv
        acc['sil'] += pr * (1 - q) * tv       # for a function TV = 1 - M(f(x)|x)
        rec(t + 1, data, pr * (1 - q))
        for y in range(ny):
            if P[x][y] > 0:
                rec(t + 1, data + [(x, y)], pr * q * P[x][y])

    rec(0, [], 1.0)
    return acc


print("(A) Theorem 3.1, exact enumeration (adaptive input rule = input where the mixture is farthest from the human)")
wa = wb = wc = wid = -9.0
for trial in range(60):
    nx, ny = rng.randint(2, 3), 2
    nh = rng.randint(2, 5)
    det = trial % 2 == 0
    hyps = [eng.random_kernel(rng, nx, ny, det=det, abort=(not det) and rng.random() < 0.4) for _ in range(nh)]
    hyps[0] = eng.random_kernel(rng, nx, ny, det=det)
    w = [rng.random() + 0.05 for _ in range(nh)]
    W = rng.choice([1.0, 0.5]); s = sum(w); w = [v * W / s for v in w]
    P = hyps[0]
    q = rng.choice([0.2, 0.5, 0.9, 1.0])
    h = 8
    rule = lambda post, M: max(range(nx), key=lambda x: eng.tv_point(P[x], M[x]))
    a = online_exact(hyps, w, P, q, h, rule)
    K = math.log2(1 / w[0])
    wa = max(wa, a['ckl'] - math.log(W / w[0]))
    wid = max(wid, abs(a['ckl'] - (math.log(W / w[0]) - a['endlog'])))
    if det:
        wb = max(wb, a['sil'] - (1 - q) * K * LN2 / q)
    wc = max(wc, a['tv2'] - K * LN2 / (2 * q))
print("    max [sum_t E q KL_t - ln(W/w(P))]                      = %+.3e (<= 0)" % wa)
print("    max |sum_t E q KL_t - (ln(W/w(P)) - E ln(1/w_D(P)))|   = %.3e (identity of Example 3.2(i))" % wid)
print("    max [E silent errors - (1-q) K ln2/q] (functions)      = %+.3e (<= 0)" % wb)
print("    max [sum_t E TV_t^2 - K ln2/(2q)]                      = %+.3e (<= 0)" % wc)

# ------------------------------------------------------------------ (B)
print("(B) Example 3.2(ii): all 2^K functions on K points, input rule a_1, a_1, ..., a_2, ...")
for K, q in [(3, 0.5), (3, 0.25), (4, 0.25)]:
    # exact: number of asked points i is a Markov chain; silent error prob 1/2 at unasked steps while i < K
    h = 400
    dist = [0.0] * (K + 1); dist[0] = 1.0; sil = 0.0
    for t in range(h):
        new = [0.0] * (K + 1)
        for i in range(K + 1):
            if dist[i] == 0: continue
            if i < K:
                sil += dist[i] * (1 - q) * 0.5
                new[i + 1] += dist[i] * q
                new[i] += dist[i] * (1 - q)
            else:
                new[i] += dist[i]
        dist = new
    # the engine on the first 9 steps for K = 3 (true posterior, not the shortcut)
    extra = ""
    if K == 3:
        pts = list(itertools.product(range(2), repeat=K))
        hyps = [[[1.0, 0.0, 0.0] if b[x] == 0 else [0.0, 1.0, 0.0] for x in range(K)] for b in pts]
        w = [2.0 ** -K] * len(hyps)
        def rule(post, M):
            for x in range(K):
                if abs(M[x][0] - 1.0) > 1e-12:
                    return x
            return 0
        a9 = online_exact(hyps, w, hyps[0], q, 9, rule)
        dist9 = [0.0] * (K + 1); dist9[0] = 1.0; sil9 = 0.0
        for t in range(9):
            new = [0.0] * (K + 1)
            for i in range(K + 1):
                if i < K:
                    sil9 += dist9[i] * (1 - q) * 0.5; new[i + 1] += dist9[i] * q; new[i] += dist9[i] * (1 - q)
                else:
                    new[i] += dist9[i]
            dist9 = new
        extra = " ; first 9 steps, engine %.6f = chain %.6f" % (a9['sil'], sil9)
    print("    K=%d q=%.2f: E silent errors = %.6f ; K(1-q)/(2q) = %.6f ; bound (1-q)K ln2/q = %.6f%s"
          % (K, q, sil, K * (1 - q) / (2 * q), (1 - q) * K * LN2 / q, extra))

# ------------------------------------------------------------------ (C)
sys.setrecursionlimit(100000)


def min_total_mistakes(N, Q):
    """min over deterministic learners with at most Q questions on every run of
    sum_{s=0}^{N-1} (number of wrong predictions under threshold s); inputs 1..N-1 in order."""
    @lru_cache(maxsize=None)
    def V(x, lo, hi, ql):
        if x > N - 1 or lo == hi:
            return 0
        if x <= lo or x > hi:
            return V(x + 1, lo, hi, ql)       # label known
        best = min(x - lo, hi - x + 1) + V(x + 1, lo, hi, ql)
        if ql > 0:
            best = min(best, V(x + 1, lo, x - 1, ql - 1) + V(x + 1, x, hi, ql - 1))
        return best
    return V(1, 0, N - 1, Q)


print("(C) Theorem 3.3(a): exact minimum of N*E[Sil] over all learners with at most Q questions, and the bound")
worst_ratio = 9e9; viol = 0
rows = []
for N in list(range(2, 41)) + [48, 60, 64]:
    for Q in range(0, min(N - 1, 12) + 1):
        ex = min_total_mistakes(N, Q)
        bd = (N * N / (Q + 1) - (Q + 1)) / 4
        if ex < bd - 1e-9:
            viol += 1
        if Q + 1 <= N / 2:
            worst_ratio = min(worst_ratio, ex * (Q + 1) / N / N)     # E[Sil](Q+1)/N
        if (N, Q) in [(6, 0), (6, 4), (12, 2), (16, 5), (60, 0), (60, 5), (60, 11)]:
            rows.append((N, Q, ex, bd))
for r in rows:
    print("    N=%d Q=%d: exact %d, bound %.2f" % r)
print("    violations of (a): %d ; smallest E[Sil](Q+1)/N over Q+1 <= N/2: %.4f (claimed >= 3/16 = 0.1875)" % (viol, worst_ratio))
# part (c): the stated learner
def stated_learner_total(N, Q):
    b = N // (Q + 1)
    tot = 0
    for s in range(N):
        seen0 = False
        for x in range(1, N):
            if x % b == 0 and x // b <= Q and not seen0:
                if x > s: seen0 = True
                continue            # a question, no mistake
            pred = 0 if seen0 else 1
            if pred != (1 if x <= s else 0):
                tot += 1
    return tot
okc = all(stated_learner_total(N, Q) * 2 == N * (N // (Q + 1) - 1)
          for N in range(2, 61) for Q in range(0, N) if N % (Q + 1) == 0)
print("    part (c): the learner with questions at multiples of N/(Q+1) has N*E[Sil] = N(N/(Q+1)-1)/2 in all cases: %s" % okc)
r = [(min_total_mistakes(N, Q) / (N * (N / (Q + 1) - 1) / 2)) for N, Q in [(60, 1), (60, 2), (60, 5), (64, 3), (64, 7)]]
print("    exact optimum / value of the learner of (c) for (60,1),(60,2),(60,5),(64,3),(64,7): " + " ".join("%.3f" % v for v in r))

# ------------------------------------------------------------------ (D)
def lagrangian(N, lam):
    """Deterministic learner minimising sum_s (Sil(s) + lam*Qu(s)); returns (sum Sil, sum Qu)."""
    @lru_cache(maxsize=None)
    def V(x, lo, hi):
        if x > N - 1 or lo == hi:
            return (0.0, 0, 0)
        if x <= lo or x > hi:
            return V(x + 1, lo, hi)
        c = V(x + 1, lo, hi)
        m = min(x - lo, hi - x + 1)
        best = (c[0] + m, c[1] + m, c[2])
        a, b = V(x + 1, lo, x - 1), V(x + 1, x, hi)
        n = hi - lo + 1
        cand = (a[0] + b[0] + lam * n, a[1] + b[1], a[2] + b[2] + n)
        if cand[0] < best[0] - 1e-12:
            best = cand
        return best
    v = V(1, 0, N - 1)
    return v[1], v[2]


print("(D) Theorem 3.3(b): vertices of the lower hull of (E[Qu], E[Sil]) over all learners")
for N in [8, 12, 24, 48, 64]:
    pts = set()
    for i in range(0, 241):
        lam = 0.02 * (1.06 ** i)
        S, Qs = lagrangian(N, lam)
        pts.add((Qs / N, S / N))
    pts = sorted(pts)
    g = lambda v: N / (9 * (v + 1)) - math.sqrt((v + 1) / (8 * N))
    slack = min(m - g(qb) for qb, m in pts)
    prod = min((m * (qb + 1) / N for qb, m in pts if qb + 1 <= N / 4), default=float('nan'))
    # also on the chords between consecutive vertices (randomised learners)
    chord = 9e9
    for (q1, m1), (q2, m2) in zip(pts, pts[1:]):
        for k in range(1, 20):
            t = k / 20; qq = q1 + t * (q2 - q1); mm = m1 + t * (m2 - m1)
            if qq + 1 <= N / 4:
                chord = min(chord, mm * (qq + 1) / N)
    print("    N=%d: %d vertices; min(E[Sil] - g(Qbar)) = %.4f (>= 0); min E[Sil](Qbar+1)/N for Qbar+1 <= N/4: vertices %.4f, chords %.4f (claimed >= 1/15 = 0.0667)"
          % (N, len(pts), slack, prod, chord))

# ------------------------------------------------------------------ (E), (F)
worst = 9e9
for trial in range(40000):
    u = rng.randint(1, 30)
    b = [rng.random() ** rng.choice([1, 3]) + 1e-6 for _ in range(u)]
    if rng.random() < 0.3:
        b = sorted(b, reverse=True)
    Nn = sum(b)
    val = sum(x * x for x in b) * sum((j + 1) * x for j, x in enumerate(b)) / Nn ** 3
    worst = min(worst, val)
J = 2000
b = [J - j for j in range(1, J)]
Nn = sum(b)
ext = sum(x * x for x in b) * sum((j + 1) * x for j, x in enumerate(b)) / Nn ** 3
print("(E) Lemma 3.4: smallest (sum b^2)(sum j b)/N^3 over 40000 random sequences %.4f ; for b_j = J - j, J = 2000: %.5f ; 4/9 = %.5f" % (worst, ext, 4 / 9))
print("(F) constants: 1/9 - 1/(8 sqrt 8) = %.6f > 1/15 = %.6f ; (N/(Q+1) - (Q+1)/N)(Q+1)/(4N) at Q+1 = N/2: %.4f = 3/16"
      % (1 / 9 - 1 / (8 * math.sqrt(8)), 1 / 15, (2 - 0.5) / 8))
# Corollary 3.5: the Jensen step and the constant, on a grid
bad = 0
for u in range(1, 30):
    for N1 in [4, 8, 16, 64, 256]:
        for k in range(0, 60):
            Qb = k / 59 * (u * N1 / 4 - u)
            if Qb < 0: continue
            val = u * u * N1 / (9 * (Qb + u)) - math.sqrt(u * (Qb + u) / (8 * N1))
            if val * (Qb + u) < u * u * N1 / 15 - 1e-9:
                bad += 1
print("    Corollary 3.5: [u^2 N1/(9(Q+u)) - sqrt(u(Q+u)/(8 N1))](Q+u) >= u^2 N1/15 for Q+u <= u N1/4: violations %d" % bad)
