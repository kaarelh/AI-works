#!/usr/bin/env python3
"""Referee check (key: hellinger-runs), part 4: Sections 4 and 5 (Theorems A, B, B').

All expectations are EXACT (enumeration of the recorded runs) unless marked otherwise.

(B4)  Example 4.4: the six values of E KL(Q_P || Qhat_{t+1}).
(B5)  Example 4.6: the closed formulas against brute force on a small instance; the
      lower bounds; the SAME lower bound for the Cesaro average (1/N) sum_t Q_{M_t},
      which is the object of Theorem A (the file argues for each t separately).
(B6)  Proposition 4.7(a) on random adaptive scaffolds with a deterministic human.
(B7)  Proposition 4.7(b): KL(Q_P||Q_M) <= L KL(Q_P||Qhat) for inputs that do not depend
      on the answers; and its FAILURE on an adaptive scaffold (Example 4.8 at one t).
(B8)  Example 4.8: the two sums, the integral, the lower bound.
(B9)  Theorem 4.2(a),(b) on random scaffolds with L = 2, human inside and outside the class,
      also a human with memory inside the run.
(B10) Lemma 5.0 on random pairs.
(B11) Theorem 5.1(a),(b): exact expected posterior mass and exact probability, against beta.
(B12) Example 5.4: brute force for d = 2, and the exact values for large d by a recursion.
(B13) Theorem 5.5 and (B14) Proposition 5.6 on the instances of (B9).
Needs numpy.
"""
import itertools
import math

import numpy as np

rng = np.random.default_rng(45)
LN2 = math.log(2.0)


def H2(p, q):
    return 1.0 - float(np.sum(np.sqrt(p * q)))


def TV(p, q):
    return 0.5 * float(np.sum(np.abs(p - q)))


def KL(p, q):
    m = p > 0
    if np.any(q[m] == 0):
        return math.inf
    return float(np.sum(p[m] * np.log(p[m] / q[m])))


# ------------------------------------------------------------------ (B4)
def part_b4():
    theta = np.array([0.5, 0.4, 0.99])
    w = np.array([0.01, 0.89, 0.10])
    out = []
    for t in range(0, 6):
        e = 0.0
        for k in range(t + 1):                       # k ones among t answers of the human Bern(1/2)
            pr = math.comb(t, k) * 0.5 ** t
            post = w * theta ** k * (1 - theta) ** (t - k)
            post /= post.sum()
            m1 = float(np.sum(post * theta))
            e += pr * KL(np.array([0.5, 0.5]), np.array([1 - m1, m1]))
        out.append(e)
    print("(B4) Example 4.4, E KL(Q_P||Qhat_{t+1}) for t = 0..5:", " ".join(f"{v:.5f}" for v in out),
          f"; ratio t=4 / t=0 = {out[4] / out[0]:.1f}")
    print(f"     for comparison K ln2/N at N = 4: {math.log(100) / 4:.4f} (the bump is far below the bound of Theorem 4.2(c))")


# ------------------------------------------------------------------ (B5)
def ex46_laws(B, L, visited):
    """Run laws of Example 4.6 given the set of visited z.  A run is (z, y_1..y_L).
    Returns Q_f, Qhat (draw per run), Q_M (per-call mixture) as dicts z -> array over {0,1}^L."""
    v = len(visited)
    wf = B / (2 * B - v)
    om = 1 / (2 * B - v)
    ys = list(itertools.product((0, 1), repeat=L))
    Qf, Qh, QM = {}, {}, {}
    for z in range(B):
        qf = np.array([1.0 if sum(y) == 0 else 0.0 for y in ys])
        if z in visited:
            Qf[z], Qh[z], QM[z] = qf, qf.copy(), qf.copy()
        else:
            # posterior: f with weight wf, g_z with weight om, the other g_b (which answer 0 at z)
            # with total weight 1 - wf - om
            qh = np.array([(1 - om) if sum(y) == 0 else (om if sum(y) == L else 0.0) for y in ys])
            if L == 1:
                qh = np.array([1 - om, om])
            qm = np.array([om ** sum(y) * (1 - om) ** (L - sum(y)) for y in ys])
            Qf[z], Qh[z], QM[z] = qf, qh, qm
    return Qf, Qh, QM, om, v


def joint(Q, B):
    return np.concatenate([Q[z] / B for z in range(B)])


def part_b5():
    print("(B5) Example 4.6")
    worst = 0.0
    for (B, L) in [(4, 1), (4, 3), (6, 2), (5, 4)]:
        for v in range(0, B // 2 + 1):
            visited = set(range(v))
            Qf, Qh, QM, om, _ = ex46_laws(B, L, visited)
            jf, jh, jm = joint(Qf, B), joint(Qh, B), joint(QM, B)
            f1 = (B - v) * om / B
            f2 = (B - v) / B * math.log(1 / (1 - om))
            f3 = (B - v) / B * (1 - (1 - om) ** L)
            worst = max(worst, abs(TV(jh, jf) - f1), abs(KL(jf, jh) - f2), abs(TV(jm, jf) - f3), abs(KL(jf, jm) - L * f2))
    print(f"     closed formulas against brute force (B <= 6, L <= 4): largest deviation = {worst:.2e}")
    # the posterior itself, by brute force over the class {f, g_1..g_B} with weights 1/2 and 1/(2B)
    B, L = 5, 3
    visited = {0, 3}
    wts = np.array([0.5] + [1 / (2 * B)] * B)
    lik = np.array([1.0] + [0.0 if b in visited else 1.0 for b in range(B)])
    post = wts * lik / np.sum(wts * lik)
    print(f"     posterior by brute force (B=5, v=2): w(f) = {post[0]:.6f} (formula B/(2B-v) = {B / (2 * B - 2):.6f}),"
          f" w(g_b) = {post[1 + 1]:.6f} (formula 1/(2B-v) = {1 / (2 * B - 2):.6f})")
    # the Cesaro average over t of the per-call run laws, exact expectation over the recorded z's
    print("     Cesaro average Qbar' = (1/N) sum_t Q_{M_t}, B = 2N: E KL(Q_f||Qbar') against L/(8N) and ln2/N; E TV against the bound of Theorem A")
    # Q_f is the point mass on "all zeros" given z, so only Qbar'(all zeros | z) is needed:
    # Q_{M_t}(all zeros | z) = (1 - omega_t)^L if z is unvisited before round t, and 1 otherwise.
    small = None
    for (N, L) in [(2, 6), (2, 12), (3, 6), (3, 24), (4, 8), (4, 40), (5, 6), (5, 30), (5, 200)]:
        B = 2 * N
        ekl = etv = 0.0
        for zs in itertools.product(range(B), repeat=N - 1):     # the runs that matter for t <= N
            pr = B ** (-(N - 1))
            zero = np.zeros(B)                                   # Qbar'(all zeros | z)
            for t in range(1, N + 1):
                visited = set(zs[:t - 1])
                om = 1 / (2 * B - len(visited))
                for z in range(B):
                    zero[z] += (1.0 if z in visited else (1 - om) ** L) / N
            ekl += pr * float(np.mean(np.log(1 / zero)))
            etv += pr * float(np.mean(1 - zero))
        if (N, L) == (2, 6):
            small = (ekl, etv)
        print(f"       N = {N}, L = {L:3d}: E KL = {ekl:.4f} >= L/(8N) = {L / (8 * N):.4f}; Theorem A would need <= {LN2 / N:.4f};"
              f" E TV = {etv:.4f} >= (1-exp(-L/(4N)))/2 = {(1 - math.exp(-L / (4 * N))) / 2:.4f}; Theorem A would need <= {math.sqrt(LN2 / (2 * N)):.4f}")
    # the same quantity for (N, L) = (2, 6) by full enumeration of the runs, as a check of the shortcut
    N, L = 2, 6
    B = 2 * N
    ys = list(itertools.product((0, 1), repeat=L))
    ekl = etv = 0.0
    for zs in itertools.product(range(B), repeat=N - 1):
        pr = B ** (-(N - 1))
        avg = {z: np.zeros(len(ys)) for z in range(B)}
        for t in range(1, N + 1):
            _, _, QM, _, _ = ex46_laws(B, L, set(zs[:t - 1]))
            for z in range(B):
                avg[z] += QM[z] / N
        Qf, _, _, _, _ = ex46_laws(B, L, set())
        ekl += pr * KL(joint(Qf, B), joint(avg, B))
        etv += pr * TV(joint(Qf, B), joint(avg, B))
    print(f"       check of the shortcut by full enumeration at N = 2, L = 6: deviations {abs(ekl - small[0]):.1e}, {abs(etv - small[1]):.1e}")
    for (B, N, L) in [(200, 100, 50), (200, 100, 7), (2000, 1000, 4000)]:
        # expectation over v after N runs of the formulas (as in the prover's table): v = number of distinct z
        # exact law of v by the occupancy recursion
        pv = np.zeros(N + 1); pv[0] = 1.0
        for _ in range(N):
            nv = np.zeros(N + 1)
            idx = np.arange(N + 1)
            nv += pv * idx / B
            nv[1:] += pv[:-1] * (B - idx[:-1]) / B
            pv = nv
        idx = np.arange(N + 1)
        om = 1 / (2 * B - idx)
        tv_call = float(np.sum(pv * (B - idx) / B * (1 - (1 - om) ** L)))
        tv_run = float(np.sum(pv * (B - idx) / B * om))
        print(f"       B = {B}, N = {N}, L = {L}: E TV per-call = {tv_call:.5f}, per-run = {tv_run:.6f}, bound of Theorem A = {math.sqrt(LN2 / (2 * N)):.5f}")
    print(f"     thresholds: L/(8N) > ln2/N iff L > {8 * LN2:.3f}; L/(16N) > sqrt(ln2/(2N)) iff L > {16 * math.sqrt(LN2 / 2):.3f} sqrt(N);"
          f" (1-1/e)/2 = {(1 - math.exp(-1)) / 2:.4f} > sqrt(ln2/(2N)) iff N > {LN2 / 2 / ((1 - math.exp(-1)) / 2) ** 2:.3f}")


# ------------------------------------------------------------------ random scaffolds
class RandScaffold:
    """Top-level input z uniform on {0..Z-1}; up to L calls; inputs in {0..X-1}; answers {0,1}.
    next_j(z, y_<j) is a random input or STOP (if allow_stop).  adaptive=False: next_j depends on z only."""

    def __init__(self, Z, X, L, adaptive=True, allow_stop=True):
        self.Z, self.X, self.L = Z, X, L
        self.nxt = {}
        for z in range(Z):
            for j in range(L):
                for hist in itertools.product((0, 1), repeat=j):
                    key = (z, hist) if adaptive else (z, j)
                    if (z, hist) not in self.nxt:
                        if key not in self.nxt:
                            stop = allow_stop and j > 0 and rng.random() < 0.2
                            self.nxt[key] = None if stop else int(rng.integers(X))
                        self.nxt[(z, hist)] = self.nxt[key]
        # list of complete runs (z, xs, ys)
        self.runs = []
        for z in range(Z):
            self._expand(z, (), ())

    def _expand(self, z, xs, ys):
        if len(ys) == self.L or self.nxt[(z, ys)] is None:
            self.runs.append((z, xs, ys))
            return
        x = self.nxt[(z, ys)]
        for y in (0, 1):
            self._expand(z, xs + (x,), ys + (y,))

    def law(self, S):
        """Run law for a sampler S (array [x][y])."""
        return np.array([np.prod([S[x][y] for x, y in zip(xs, ys)]) / self.Z for (z, xs, ys) in self.runs])

    def law_answerer(self, A):
        """Run law for an answerer A(z, xs_so_far, ys_so_far) -> probability of answer 1."""
        out = []
        for (z, xs, ys) in self.runs:
            pr = 1.0 / self.Z
            for j in range(len(ys)):
                p1 = A(z, xs[:j + 1], ys[:j])
                pr *= p1 if ys[j] == 1 else 1 - p1
            out.append(pr)
        return np.array(out)


def rand_sampler(X, det=False, zeros=False):
    if det:
        th = rng.integers(2, size=X).astype(float)
    else:
        th = rng.random(X)
        if zeros:
            th[rng.integers(X)] = float(rng.integers(2))
    return np.stack([1 - th, th], axis=1)


def seq_enum(qstar, N):
    """All sequences of N run indices with positive probability under qstar, with their probabilities."""
    supp = [i for i in range(len(qstar)) if qstar[i] > 0]
    for seq in itertools.product(supp, repeat=N):
        yield seq, float(np.prod([qstar[i] for i in seq]))


# ------------------------------------------------------------------ (B6)
def part_b6():
    worst_gap = np.inf
    ok = True
    for trial in range(40):
        sc = RandScaffold(Z=3, X=5, L=3, adaptive=True, allow_stop=True)
        nH = int(rng.integers(2, 7))
        H = [rand_sampler(5, det=True) for _ in range(nH)]
        w = rng.dirichlet(np.ones(nH)) * rng.uniform(0.6, 1.0)
        f = H[0]
        qf = sc.law(f)
        laws = np.array([sc.law(S) for S in H])
        N = 4
        s1 = s2 = 0.0
        for t in range(1, N + 1):
            for seq, pr in seq_enum(qf, t - 1):
                post = w * np.prod(laws[:, list(seq)], axis=1)
                post /= post.sum()
                M = sum(post[i] * H[i] for i in range(nH))
                s1 += pr * TV(sc.law(M), qf)
                # E_{Q_f} sum_j (1 - M(f(x_j)|x_j))
                e = 0.0
                for (z, xs, ys), pf in zip(sc.runs, qf):
                    if pf > 0:
                        e += pf * sum(1 - M[x][y] for x, y in zip(xs, ys))
                s2 += pr * e
        bound = sc.L * math.log(1 / w[0])
        ok = ok and (s1 <= s2 + 1e-12) and (s2 <= bound + 1e-12)
        worst_gap = min(worst_gap, bound - s2)
    print(f"(B6) Proposition 4.7(a), 40 random adaptive scaffolds (L = 3, N = 4, functions): sum_t E TV <= sum_t E E sum_j (1-M) <= L K ln2"
          f" in all cases: {ok}; smallest slack = {worst_gap:.4f}")


# ------------------------------------------------------------------ (B7)
def part_b7():
    worst = -np.inf
    for trial in range(400):
        sc = RandScaffold(Z=2, X=4, L=3, adaptive=False, allow_stop=False)
        nH = int(rng.integers(2, 5))
        H = [rand_sampler(4, zeros=(rng.random() < 0.3) and i > 0) for i in range(nH)]
        post = rng.dirichlet(np.ones(nH) * rng.choice([0.3, 1.0]))
        P = H[0]
        M = sum(post[i] * H[i] for i in range(nH))
        qhat = sum(post[i] * sc.law(H[i]) for i in range(nH))
        worst = max(worst, KL(sc.law(P), sc.law(M)) - sc.L * KL(sc.law(P), qhat))
    print(f"(B7) Proposition 4.7(b), 400 random cases with inputs that do not depend on the answers: max of KL(Q_P||Q_M) - L KL(Q_P||Qhat) = {worst:.3e} (must be <= 0)")
    # the same inequality on the adaptive scaffold of Example 4.8 at one posterior: it fails
    p, om = 0.01, 0.9
    kl_hat = KL(np.array([1 - p, p]), np.array([1 - p * (1 - om), p * (1 - om)]))
    kl_M = kl_hat + p * math.log(1 / (1 - om))
    print(f"     adaptive scaffold of Example 4.8 at p = {p}, posterior weight {om} on nu: KL(Q_P||Q_M) = {kl_M:.5f}, L KL(Q_P||Qhat) = {2 * kl_hat:.5f}"
          f" (so the hypothesis on the inputs in 4.7(b) is needed)")


# ------------------------------------------------------------------ (B8)
def part_b8():
    print("(B8) Example 4.8: sum over t <= N of the expected per-call divergences along human runs")
    for eta, p, N in [(0.1, 0.01, 6000), (0.01, 0.01, 6000), (1e-4, 0.01, 6000), (1e-8, 0.01, 6000), (0.01, 0.5, 200)]:
        o = eta / (1 - eta)
        frozen = coherent = 0.0
        for t in range(1, N + 1):
            u = (1 - p) ** (t - 1)
            omc = u / (o + u)                     # 1 - omega_t, computed without cancellation
            klh = p * math.log(1 / omc) + (1 - p) * math.log((1 - p) / (1 - p * omc))   # KL(Bern(p)||Bern(p(1-omega_t)))
            coherent += u * klh
            frozen += u * (klh + p * math.log(1 + o / u))
        integral = (1 + o) * math.log(1 + o) + o * math.log(1 / o)
        print(f"     eta = {eta:g}, p = {p}: frozen = {frozen:.4e}, draw per run = {coherent:.4e} <= K ln2 = {math.log(1 + o):.4e};"
              f" (1-p) x integral = {(1 - p) * integral:.4e} <= frozen - draw per run = {frozen - coherent:.4e};"
              f" frozen/(L K ln2) = {frozen / (2 * math.log(1 + o)):.3f} >= (1-p) ln(1/o)/2 = {(1 - p) * math.log(1 / o) / 2:.3f}")


def part_b8c():
    """Example 4.8 at one round: total variation of the two imitators from the run laws."""
    worst = 0.0
    for p in (0.01, 0.3, 0.9):
        for om in (0.001, 0.2, 0.7, 0.999):
            QP = np.array([1 - p, 0.0, p])                                   # runs (0), (1,0), (1,1)
            Qhat = (1 - om) * QP + om * np.array([1.0, 0.0, 0.0])            # one draw per run
            m0, m1 = p * (1 - om), 1 - om                                    # M(1|x0), M(1|x1)
            QM = np.array([1 - m0, m0 * (1 - m1), m0 * m1])                  # per-call mixture
            worst = max(worst, abs(TV(Qhat, QP) - p * om), abs(TV(QM, QP) - p * om * (2 - om)))
    print(f"(B8c) Example 4.8 at one round: TV(Qhat_t, Q_P) = p omega and TV(Q_M_t, Q_P) = p omega (2 - omega): largest deviation {worst:.1e}"
          f" (so the two total variations differ by the factor 2 - omega_t, between 1 and 2)")


# ------------------------------------------------------------------ (B9), (B13), (B14)
def instance(outside, memory=False):
    sc = RandScaffold(Z=2, X=4, L=2, adaptive=True, allow_stop=True)
    nH = int(rng.integers(2, 5))
    H = [rand_sampler(4, zeros=(rng.random() < 0.25) and i > 0) for i in range(nH)]
    w = rng.dirichlet(np.ones(nH)) * rng.uniform(0.6, 1.0)
    laws = np.array([sc.law(S) for S in H])
    if memory:                                   # a human who remembers the first answer of the run
        tab = rng.random((2, 4, 2))
        qstar = sc.law_answerer(lambda z, xs, ys: tab[0, xs[-1], 0] if len(ys) == 0 else tab[1, xs[-1], ys[0]])
    elif outside:
        qstar = sc.law(rand_sampler(4))
    else:
        qstar = laws[0].copy()
    return sc, H, w, laws, qstar


def part_b9_b13_b14():
    okA = okB5 = ok56 = True
    slackA = np.inf
    nontrivial56 = 0
    for trial in range(36):
        kind = trial % 3
        sc, H, w, laws, qstar = instance(outside=(kind == 1), memory=(kind == 2))
        nH = len(H)
        N = 4
        kls = np.array([KL(qstar, laws[i]) for i in range(nH)])
        # Theorem 4.2(a): sum_t E KL(Q*||Qhat_t) <= min_nu [ln(1/w) + N KL(Q*||Q_nu)]
        tot = 0.0
        for t in range(1, N + 1):
            for seq, pr in seq_enum(qstar, t - 1):
                lik = np.prod(laws[:, list(seq)], axis=1) if seq else np.ones(nH)
                if np.sum(w * lik) == 0:
                    tot = math.inf
                    continue
                post = w * lik / np.sum(w * lik)
                tot += pr * KL(qstar, post @ laws)
        boundA = float(np.min(np.log(1 / w) + N * kls))
        okA = okA and (tot <= boundA + 1e-10)
        if boundA < math.inf:
            slackA = min(slackA, boundA - tot)
        # Theorem 5.5 (alpha in {0.3, 0.5, 0.8}) and Proposition 5.6 with all N runs
        h2s = np.array([H2(laws[i], qstar) for i in range(nH)])
        for alpha in (0.3, 0.5, 0.8):
            A = np.array([float(np.sum(qstar ** (1 - alpha) * laws[i] ** alpha)) for i in range(nH)])
            e1 = e2 = 0.0
            for seq, pr in seq_enum(qstar, N):
                lik = np.prod(laws[:, list(seq)], axis=1)
                tw = w * lik ** alpha
                if tw.sum() == 0:
                    continue                      # happens only if KL* is infinite for every member
                tp = tw / tw.sum()
                live = tp > 0
                e1 += pr * float(np.sum(tp[live] * (-np.log(A[live]))))
                e2 += pr * float(np.sum(tp * h2s))
            rhs = float(np.min(np.log(1 / w) / N + alpha * kls))
            okB5 = okB5 and (e1 <= rhs + 1e-10) and (e2 <= rhs / (2 * min(alpha, 1 - alpha)) + 1e-10)
        for lam in (1.0, 2.0):
            S = float(np.sum(w ** (lam / 2)))
            for d1, d2 in ((0.3, 0.3), (0.45, 0.45)):
                for istar in range(nH):
                    if kls[istar] == math.inf:
                        continue
                    eps0 = kls[istar] / (2 * d1) + ((lam / 2) * math.log(1 / w[istar]) + math.log(S / d2) + 1 / (2 * math.e * d1)) / N
                    bad = h2s >= eps0
                    if not np.any(bad):
                        continue
                    nontrivial56 += 1
                    prob = mass = 0.0
                    for seq, pr in seq_enum(qstar, N):
                        lik = np.prod(laws[:, list(seq)], axis=1)
                        sc_ = w ** lam * lik
                        if np.any(bad & (sc_ >= sc_[istar])):
                            prob += pr
                        mass += pr * float(np.sum((sc_ / sc_.sum())[bad]))
                    ok56 = ok56 and (prob <= d1 + d2 + 1e-12) and (mass <= d1 + d2 + 1e-12)
    print(f"(B9) Theorem 4.2(a), 36 random instances (human in the class, a sampler outside, a human with memory inside the run), N = 4:"
          f" bound holds in all: {okA}; smallest slack = {slackA:.4f}")
    print(f"(B13) Theorem 5.5, same instances, alpha in {{0.3, 0.5, 0.8}}: both inequalities hold in all: {okB5}")
    print(f"(B14) Proposition 5.6, same instances: bound holds in all {nontrivial56} non-trivial cases: {ok56}"
          f" (with N = 4 the threshold eps0^2 exceeds 1 in most cases, so this is a weak test)")


# ------------------------------------------------------------------ (B10)
def part_b10():
    worst = -np.inf
    for _ in range(100000):
        k = int(rng.integers(2, 7))
        p = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        q = rng.dirichlet(np.ones(k) * rng.choice([0.2, 1.0, 5.0]))
        if rng.random() < 0.3:
            j = rng.integers(k); q = q.copy(); q[j] = 0.0; q /= q.sum()
        s = rng.uniform(0.01, 0.99)
        A = float(np.sum(p ** (1 - s) * q ** s))
        bc = float(np.sum(np.sqrt(p * q)))
        worst = max(worst, A - bc ** (2 * min(s, 1 - s)))
    print(f"(B10) Lemma 5.0 on 100000 random pairs and exponents: max of A_s - BC^(2 min(s,1-s)) = {worst:.2e} (must be <= 0)")


# ------------------------------------------------------------------ (B11)
def part_b11():
    print("(B11) Theorem 5.1: one call per run at one input, class of Bernoulli samplers with code lengths l; exact values")
    thetas = np.array([0.5, 0.45, 0.6, 0.3, 0.9, 0.52])
    ell = np.array([3.0, 1.0, 2.0, 4.0, 5.0, 6.0])               # Kraft sum = 1/8+1/2+1/4+1/16+1/32+1/64 < 1
    assert np.sum(2.0 ** (-ell)) <= 1
    P = 0
    h2 = np.array([1 - math.sqrt(thetas[i] * thetas[P]) - math.sqrt((1 - thetas[i]) * (1 - thetas[P])) for i in range(len(thetas))])
    ok = True
    rows = []
    for lam in (1.05, 1.5, 2.0, 3.0):
        for eps2 in (0.004, 0.02):
            bad = h2 >= eps2
            for N in (20, 100, 400):
                emass = eprob = 0.0
                for k in range(N + 1):
                    logpr = math.lgamma(N + 1) - math.lgamma(k + 1) - math.lgamma(N - k + 1) + k * math.log(thetas[P]) + (N - k) * math.log(1 - thetas[P])
                    pr = math.exp(logpr)
                    logsc = -lam * ell * LN2 + k * np.log(thetas) + (N - k) * np.log(1 - thetas)
                    sc_ = np.exp(logsc - logsc.max())
                    emass += pr * float(np.sum(sc_[bad]) / np.sum(sc_))
                    if np.any(bad & (logsc >= logsc[P])):
                        eprob += pr
                best = min((2.0 ** (lam * s * ell[P]) * (1 - eps2) ** (2 * min(s, 1 - s) * N), s)
                           for s in np.linspace(1 / lam, 0.999, 400))
                s_c = max(0.5, 1 / lam)
                beta_c = 2.0 ** (lam * s_c * ell[P]) * (1 - eps2) ** (2 * min(s_c, 1 - s_c) * N)
                ok = ok and (emass <= best[0] + 1e-12) and (eprob <= best[0] + 1e-12)
                rows.append((lam, eps2, N, emass, eprob, beta_c, best[0]))
    for r in rows[::4]:
        print(f"      lambda = {r[0]}, eps^2 = {r[1]}, N = {r[2]:3d}: E mass = {r[3]:.3e}, Pr[(b)] = {r[4]:.3e}, beta at s = max(1/2, 1/lambda): {r[5]:.3e}, best beta over s: {r[6]:.3e}")
    print(f"      E[posterior mass of B_eps] and the probability of (b) are below beta for every admissible s in all {len(rows)} cases: {ok}")
    # arithmetic of (c)
    for lam, lP, dl, e2 in [(2.0, 5, 0.01, 0.02), (3.0, 5, 0.01, 0.02), (1.5, 5, 0.01, 0.02)]:
        if lam >= 2:
            Nmin = ((lam / 2) * lP * LN2 + math.log(1 / dl)) / e2
            s = 0.5
        else:
            Nmin = lam * (lP * LN2 + math.log(1 / dl)) / (2 * (lam - 1) * e2)
            s = 1 / lam
        Nc = math.ceil(Nmin)
        beta = 2.0 ** (lam * s * lP) * (1 - e2) ** (2 * min(s, 1 - s) * Nc)
        print(f"      (c): lambda = {lam}, l(P) = {lP}, delta = {dl}, eps^2 = {e2}: N >= {Nmin:.1f}; beta at N = {Nc}: {beta:.5f} <= delta: {beta <= dl}")


# ------------------------------------------------------------------ (B12)
def part_b12():
    print("(B12) Example 5.4")
    # brute force, d = 2 (4 inputs, 16 tables), N = 3: posterior mass of the tables at lambda = 1 and 2
    d, N = 2, 3
    Xn = 2 ** d
    tables = list(itertools.product((0, 1), repeat=Xn))
    worst = 0.0
    e1 = e2 = 0.0
    for zs in itertools.product(range(Xn), repeat=N):
        for ys in itertools.product((0, 1), repeat=N):
            pr = Xn ** (-N) * 0.5 ** N
            R = N - len(set(zs))
            cons = sum(1 for tb in tables if all(tb[z] == y for z, y in zip(zs, ys)))
            for lam, acc in ((1, 1), (2, 2)):
                wt = cons * 2.0 ** (-lam * (Xn + 1))
                wc = 2.0 ** (-lam) * 0.5 ** N
                mass = wt / (wt + wc)
                if lam == 1:
                    e1 += pr * mass
                    if cons > 0:
                        worst = max(worst, abs(mass - 1 / (1 + 2.0 ** (-R))))
                else:
                    e2 += pr * mass
                    if cons > 0:
                        worst = max(worst, abs(wt / wc - 2.0 ** (R - Xn)))
    print(f"     d = 2, N = 3, brute force over the 16 tables: largest deviation from 1/(1+2^-R) and from the odds 2^(R-2^d): {worst:.2e};"
          f" E[mass of the tables] = {e1:.4f} (lambda = 1), {e2:.5f} (lambda = 2)")
    print(f"     H2(Q_table, Q_coin) = 1 - 1/sqrt2 = {1 - 1 / math.sqrt(2):.4f}")
    for d, N in [(10, 32), (20, 512), (30, 1024), (30, 16384), (40, 2 ** 20)]:
        M = 2.0 ** d
        rmax = 80
        pr = np.zeros(rmax + 1)
        pr[0] = 1.0
        for n in range(N):                        # n runs so far; r repeats; n - r distinct inputs
            rr = np.arange(rmax + 1)
            prep = np.clip((n - rr) / M, 0.0, 1.0)
            new = pr * (1 - prep)
            new[1:] += (pr * prep)[:-1]
            pr = new
        rr = np.arange(rmax + 1)
        val = float(np.sum(pr * 2.0 ** (-rr) / (1 + 2.0 ** (-rr))))
        print(f"     d = {d}, N = {N}: E[2^-R/(1+2^-R)] = {val:.4f}; Pr[R = 0] = {pr[0]:.4f}; lower bound (1 - N^2/2^(d+1))/2 = {0.5 * (1 - N * N / 2 ** (d + 1)):.4f};"
              f" N <= 2^(d/2): {N <= 2 ** (d / 2)}")


def part_b14_large():
    """Proposition 5.6 on a Bernoulli class (one call per run), truth outside the class, exact by binomial enumeration."""
    thetas = np.array([0.5, 0.45, 0.6, 0.3, 0.9, 0.52])
    ell = np.array([3.0, 1.0, 2.0, 4.0, 5.0, 6.0])
    ok = True
    rows = []
    for tstar in (0.47, 0.56):
        qs = np.array([1 - tstar, tstar])
        h2 = np.array([H2(np.array([1 - th, th]), qs) for th in thetas])
        kls = np.array([KL(qs, np.array([1 - th, th])) for th in thetas])
        for lam in (1.0, 2.0):
            S = float(np.sum(2.0 ** (-lam * ell / 2)))
            for N in (100, 400, 1600):
                for d1, d2 in ((0.2, 0.2), (0.05, 0.4)):
                    for istar in range(len(thetas)):
                        eps0 = kls[istar] / (2 * d1) + ((lam / 2) * ell[istar] * LN2 + math.log(S / d2) + 1 / (2 * math.e * d1)) / N
                        bad = h2 >= eps0
                        if not np.any(bad):
                            continue
                        prob = mass = 0.0
                        for k in range(N + 1):
                            logpr = math.lgamma(N + 1) - math.lgamma(k + 1) - math.lgamma(N - k + 1) + k * math.log(tstar) + (N - k) * math.log(1 - tstar)
                            pr = math.exp(logpr)
                            logsc = -lam * ell * LN2 + k * np.log(thetas) + (N - k) * np.log(1 - thetas)
                            if np.any(bad & (logsc >= logsc[istar])):
                                prob += pr
                            sc_ = np.exp(logsc - logsc.max())
                            mass += pr * float(np.sum(sc_[bad]) / np.sum(sc_))
                        ok = ok and (prob <= d1 + d2 + 1e-12) and (mass <= d1 + d2 + 1e-12)
                        rows.append((tstar, lam, N, d1, d2, istar, eps0, int(bad.sum()), prob, mass))
    worst = max(rows, key=lambda r: max(r[8], r[9]) / (r[3] + r[4]))
    print(f"(B14b) Proposition 5.6, Bernoulli class, truth Bern(0.47) or Bern(0.56) outside the class: {len(rows)} non-trivial cases, bound holds in all: {ok};"
          f" largest (probability or mass)/(delta1+delta2) = {max(worst[8], worst[9]) / (worst[3] + worst[4]):.3f}"
          f" (truth {worst[0]}, lambda {worst[1]}, N {worst[2]}, nu* = Bern({thetas[worst[5]]}), eps0^2 = {worst[6]:.4f})")


if __name__ == "__main__":
    part_b4()
    part_b5()
    part_b6()
    part_b7()
    part_b8()
    part_b8c()
    part_b9_b13_b14()
    part_b14_large()
    part_b10()
    part_b11()
    part_b12()
