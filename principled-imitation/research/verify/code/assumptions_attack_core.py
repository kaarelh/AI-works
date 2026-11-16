"""Adversary's exact checks for research/prove-c/assumptions.md (key: assumptions), part 1.

Everything here is exact enumeration on small finite instances (no sampling except where a
random INSTANCE is drawn; the seed is printed).  The engine enumerates Protocol R of the note
(rehearsal with one asked call per run) from first principles: the law of the data after every
round, the law of the run of every round's mixture, and the human's answers.

  A  Lemma 0.2 / Theorem 1.11 / Theorem 2.1(a): inequality (0.4) for every member nu, with a
     human in the class, outside the class, and a human who changes after every answer
  B  Theorem 2.1(b): the identity  sum_t E Lambda(M^(t)) = L (ln(W/w(P)) - E ln(1/w_{D_n}(P)))
  C  Theorem 3.2(a): for EVERY subset Q of X, Pr[run of round T meets Q before any question
     did] <= L/n; and the same event for SOME Q of a family (the reading 'for every property
     at once'), which is not bounded by L/n
  D  Theorem 3.2(b): E[G_n] <= 1 for the supermartingale G_n, by enumeration of all paths
  E  a floor that the file does not state: sum_t E[unfaithful calls of the run of round t]
     >= L sum_g w(g) Pr[g is refuted within n rounds]   (deterministic human, functions g)
  F  Proposition 2.2: R1 with K_Pi when the human is not in the class
  G  Proposition 2.5: beta(A)/L <= rho' ; value of rho' for the exact imitator A = P
  H  Example 2.3 from first principles (engine), against the closed formula of the file
  I  Example 3.3 from first principles (engine) for k = 1, L = 2 and k = 1, L = 3
  J  Proposition 4.2 (exchangeable stock, sampling without replacement)
  K  Proposition 4.3 (open system, human asked with probability q)
  L  Corollary 1.12: the inequality KL(p || nu^eta) <= ln(1/(1-eta)) + a (1 + ln(s/eta)),
     random search for a violation; and part 7 of the file's script recomputed exactly

Usage: python3 assumptions_attack_core.py [seed]
"""
import itertools
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20261116
LN2 = math.log(2.0)
INF = float("inf")


def kl(p, q):
    """KL(p || q) in nats for arrays; q may be a sub-probability; +inf if p > 0 where q = 0."""
    s = 0.0
    for a, b in zip(p, q):
        if a > 0:
            if b <= 0:
                return INF
            s += a * math.log(a / b)
    return s


def hell2(p, q):
    return 1.0 - sum(math.sqrt(a * b) for a, b in zip(p, q))


class Scaffold:
    """z ~ D0 on range(nZ), rho ~ lam on range(nR); nxt(z, rho, answers) -> input or None."""

    def __init__(self, D0, lam, nxt, L):
        self.D0, self.lam, self.nxt, self.L = list(D0), list(lam), nxt, L

    def runs(self, C):
        """All runs answered by the kernel C (array [nX, nY]): list of (prob, xs, ys)."""
        out = []
        nY = C.shape[1]

        def rec(z, rho, xs, ys, pr):
            if pr == 0.0:
                return
            x = self.nxt(z, rho, tuple(ys)) if len(xs) < self.L else None
            if x is None:
                out.append((pr, tuple(xs), tuple(ys)))
                return
            for y in range(nY):
                rec(z, rho, xs + [x], ys + [y], pr * C[x, y])

        for z, pz in enumerate(self.D0):
            for rho, pr in enumerate(self.lam):
                if pz * pr > 0:
                    rec(z, rho, [], [], pz * pr)
        return out


class Klass:
    def __init__(self, kernels, weights):
        self.k = [np.asarray(a, dtype=float) for a in kernels]
        self.w = np.asarray(weights, dtype=float)
        self.W = float(self.w.sum())
        assert self.W <= 1.0 + 1e-12

    def lik(self, data):
        """data: tuple of (x, y); returns the vector nu(D)."""
        out = np.ones(len(self.k))
        for (x, y) in data:
            out *= np.array([a[x, y] for a in self.k])
        return out

    def posterior(self, data):
        v = self.w * self.lik(data)
        s = v.sum()
        if s <= 0:
            return self.w / self.W, 0.0
        return v / s, s

    def mixture(self, data):
        post, _ = self.posterior(data)
        return sum(p * a for p, a in zip(post, self.k))


def rehearse(scaf, klass, human, n, per_round=None):
    """Exact law of Protocol R.  human(state) -> kernel of the human given the data so far
    (a function of the data list; a fixed kernel is the case of A1).  States are the sorted
    data tuples (the posterior depends on the multiset only; the human may depend on its size).
    per_round(t, state, prob, M, runs, P_t) is called for every state before round t."""
    states = {(): 1.0}
    for t in range(1, n + 1):
        new = {}
        for st, pr in states.items():
            M = klass.mixture(st)
            P_t = human(st)
            rs = scaf.runs(M)
            if per_round is not None:
                per_round(t, st, pr, M, rs, P_t)
            for (q, xs, ys) in rs:
                for J in range(1, scaf.L + 1):
                    w_ = pr * q / scaf.L
                    if J <= len(xs):
                        x = xs[J - 1]
                        for y in range(P_t.shape[1]):
                            if P_t[x, y] > 0:
                                ns = tuple(sorted(st + ((x, y),)))
                                new[ns] = new.get(ns, 0.0) + w_ * P_t[x, y]
                    else:
                        new[st] = new.get(st, 0.0) + w_
        states = new
    return states


def random_kernel(rng, nX, nY, det=False, sparse=0.0):
    if det:
        k = np.zeros((nX, nY))
        k[np.arange(nX), rng.integers(0, nY, nX)] = 1.0
        return k
    k = rng.dirichlet(np.ones(nY), size=nX)
    if sparse > 0:
        mask = rng.random((nX, nY)) < sparse
        k = np.where(mask, 0.0, k)
        for i in range(nX):
            if k[i].sum() == 0:
                k[i, rng.integers(0, nY)] = 1.0
        k = k / k.sum(axis=1, keepdims=True)
    return k


def random_scaffold(rng, nX, nY, L, nZ=2, nR=2, stop_prob=0.2):
    table = {}

    def nxt(z, rho, ans):
        key = (z, rho, ans)
        if key not in table:
            if len(ans) > 0 and rng.random() < stop_prob:
                table[key] = None
            else:
                table[key] = int(rng.integers(0, nX))
        return table[key]

    D0 = rng.dirichlet(np.ones(nZ))
    lam = rng.dirichlet(np.ones(nR))
    return Scaffold(D0, lam, nxt, L)


# ---------------------------------------------------------------------------------------------
def part_A(rng):
    print("== A: inequality (0.4) of Lemma 0.2 (R1 against any member, any human), exact")
    worst = INF
    cases = 0
    for trial in range(60):
        nX, nY, L, n = int(rng.integers(2, 4)), 2, int(rng.integers(1, 4)), int(rng.integers(2, 5))
        scaf = random_scaffold(rng, nX, nY, L)
        mode = trial % 3      # 0: human in class; 1: not in class; 2: human changes after each answer
        H = int(rng.integers(2, 5))
        kernels = [random_kernel(rng, nX, nY, sparse=0.15 if trial % 2 else 0.0) for _ in range(H)]
        w = rng.dirichlet(np.ones(H)) * rng.uniform(0.5, 1.0)
        klass = Klass(kernels, w)
        if mode == 0:
            humans = [kernels[0]]
        elif mode == 1:
            humans = [random_kernel(rng, nX, nY)]
        else:
            humans = [random_kernel(rng, nX, nY) for _ in range(n + 1)]

        def human(st, humans=humans):
            return humans[min(len(st), len(humans) - 1)]

        lhs = [0.0]
        rhs_terms = np.zeros(H)

        def per_round(t, st, pr, M, rs, P_t):
            for (q, xs, ys) in rs:
                for x in xs:
                    lhs[0] += pr * q * kl(P_t[x], M[x])
                    for i in range(H):
                        rhs_terms[i] += pr * q * kl(P_t[x], kernels[i][x])

        rehearse(scaf, klass, human, n, per_round)
        for i in range(H):
            rhs = L * math.log(klass.W / w[i]) + rhs_terms[i]
            if rhs < INF:
                cases += 1
                worst = min(worst, rhs - lhs[0])
                assert lhs[0] <= rhs + 1e-9, (trial, i, lhs[0], rhs)
    print(f"  60 random instances, {cases} finite (instance, member) pairs: smallest value of"
          f" (right side - left side) = {worst:.6f}  (>= 0 required)")


def part_B(rng):
    print("== B: Theorem 2.1(b), the identity for the price of rehearsal under A1 and A2, exact")
    worst = 0.0
    for trial in range(30):
        nX, nY, L, n = int(rng.integers(2, 4)), 2, int(rng.integers(1, 4)), int(rng.integers(2, 5))
        scaf = random_scaffold(rng, nX, nY, L)
        H = int(rng.integers(2, 5))
        kernels = [random_kernel(rng, nX, nY) for _ in range(H)]
        w = rng.dirichlet(np.ones(H)) * rng.uniform(0.5, 1.0)
        klass = Klass(kernels, w)
        P = kernels[0]
        lhs = [0.0]

        def per_round(t, st, pr, M, rs, P_t):
            for (q, xs, ys) in rs:
                for x in xs:
                    lhs[0] += pr * q * kl(P_t[x], M[x])

        final = rehearse(scaf, klass, lambda st: P, n, per_round)
        e_surprise = sum(pr * math.log(1.0 / klass.posterior(st)[0][0]) for st, pr in final.items())
        rhs = L * (math.log(klass.W / w[0]) - e_surprise)
        worst = max(worst, abs(lhs[0] - rhs))
    print(f"  30 random instances: largest |left - right| = {worst:.2e}")
    print("  (the identity holds with W = sum of the weights; the bound L K ln 2 is reached only")
    print("   if W = 1 and the posterior weight of the member P itself tends to 1)")


def part_C(rng):
    print("== C: Theorem 3.2(a) for every subset Q, and for 'some Q of a family', exact")
    worst_ratio = 0.0
    for trial in range(40):
        nX, nY, L, n = int(rng.integers(2, 5)), 2, int(rng.integers(1, 4)), int(rng.integers(2, 6))
        scaf = random_scaffold(rng, nX, nY, L, nZ=3)
        H = int(rng.integers(2, 4))
        kernels = [random_kernel(rng, nX, nY) for _ in range(H)]
        klass = Klass(kernels, rng.dirichlet(np.ones(H)))
        humans = [random_kernel(rng, nX, nY) for _ in range(n + 1)]   # any process
        subsets = [frozenset(c) for r in range(1, nX + 1) for c in itertools.combinations(range(nX), r)]
        acc = {Q: 0.0 for Q in subsets}

        def per_round(t, st, pr, M, rs, P_t):
            asked = set(x for (x, y) in st)
            for Q in subsets:
                if asked & Q:
                    continue
                v = sum(q for (q, xs, ys) in rs if set(xs) & Q)
                acc[Q] += pr * v

        rehearse(scaf, klass, lambda st: humans[min(len(st), n)], n, per_round)
        for Q in subsets:
            val = acc[Q] / n
            assert val <= L / n + 1e-12, (trial, Q, val, L / n)
            worst_ratio = max(worst_ratio, val / (L / n))
    print(f"  40 random instances, all subsets Q: largest value of probability/(L/n) = {worst_ratio:.4f}"
          "  (<= 1 required)")
    # the simultaneous reading: Pr[the run of round T has an input that no earlier question had]
    print("  the event for SOME singleton Q = {x} (a run of round T contains an input never asked before):")
    for N, n in ((50, 10), (200, 20), (1000, 50)):
        # L = 1, input uniform on [N], any class: the question of each round is the input of the run
        p = sum((1 - 1 / N) ** (t - 1) for t in range(1, n + 1)) / n
        print(f"    X = [{N}], L = 1, n = {n}: probability {p:.4f};  L/n = {1 / n:.4f};"
              f"  each fixed x: {p / N:.6f}")
    print("  so Theorem 3.2(a) is a statement for each fixed Q, not for all Q at once.")


def part_D(rng):
    print("== D: Theorem 3.2(b), E[G_n] <= 1 by enumeration of all paths")
    worst = 0.0
    for trial in range(12):
        nX, nY, L, n = 2, 2, int(rng.integers(1, 3)), 4
        scaf = random_scaffold(rng, nX, nY, L)
        H = 3
        kernels = [random_kernel(rng, nX, nY) for _ in range(H)]
        klass = Klass(kernels, rng.dirichlet(np.ones(H)))
        P = kernels[0]
        nu = kernels[1]
        cache = {}

        def node(st):
            if st not in cache:
                M = klass.mixture(st)
                rs = scaf.runs(M)
                d = sum(q * sum(hell2(P[x], nu[x]) for x in xs) for (q, xs, ys) in rs) / L
                trans = {}
                for (q, xs, ys) in rs:
                    for J in range(1, L + 1):
                        if J <= len(xs):
                            x = xs[J - 1]
                            for y in range(nY):
                                trans[(x, y)] = trans.get((x, y), 0.0) + q / L * P[x, y]
                        else:
                            trans[None] = trans.get(None, 0.0) + q / L
                cache[st] = (d, trans)
            return cache[st]

        total = [0.0]

        def dfs(t, st, pr, R, sumd):
            if t == n:
                total[0] += pr * R * math.exp(sumd)
                return
            d, trans = node(st)
            for key, q in trans.items():
                if q == 0:
                    continue
                if key is None:
                    dfs(t + 1, st, pr * q, R, sumd + d)
                else:
                    x, y = key
                    dfs(t + 1, tuple(sorted(st + (key,))), pr * q,
                        R * math.sqrt(nu[x, y] / P[x, y]), sumd + d)

        dfs(0, (), 1.0, 1.0, 0.0)
        worst = max(worst, total[0])
        assert total[0] <= 1 + 1e-9
    print(f"  12 random instances (n = 4): largest E[G_n] = {worst:.6f}  (<= 1 required)")


def part_E(rng):
    print("== E: a floor not stated in the file (deterministic human f, functions g in the class):")
    print("   sum_t E[unfaithful calls of run t] >= L sum_g w(g) Pr[g refuted within n rounds]")
    worst = INF
    rows = []
    for trial in range(30):
        nX, nY, L, n = int(rng.integers(2, 5)), 2, int(rng.integers(1, 4)), int(rng.integers(2, 6))
        scaf = random_scaffold(rng, nX, nY, L, nZ=3)
        H = int(rng.integers(2, 6))
        kernels = [random_kernel(rng, nX, nY, det=True) for _ in range(H)]
        w = rng.dirichlet(np.ones(H))
        klass = Klass(kernels, w)
        f = kernels[0]
        tot = [0.0]

        def per_round(t, st, pr, M, rs, P_t):
            for (q, xs, ys) in rs:
                for x in xs:
                    tot[0] += pr * q * (1.0 - float((M[x] * f[x]).sum()))

        final = rehearse(scaf, klass, lambda st: f, n, per_round)
        refuted = np.zeros(H)
        for st, pr in final.items():
            lk = klass.lik(st)
            refuted += pr * (lk == 0)
        lower = L * float((w * refuted).sum())
        upper = L * math.log(1.0 / w[0])
        assert lower <= tot[0] + 1e-9 <= upper + 2e-9, (lower, tot[0], upper)
        worst = min(worst, tot[0] - lower)
        rows.append((lower, tot[0], upper))
    lo, mid, up = rows[0]
    print(f"  30 random instances: floor <= exact sum <= L K ln 2 in all; smallest (sum - floor) = {worst:.4f}")
    print(f"  first instance: floor {lo:.4f} <= exact {mid:.4f} <= R1 bound {up:.4f}")


def part_F(rng):
    print("== F: Proposition 2.2 (R1 with K_Pi when the human is outside the class), exact")
    worst = INF
    for trial in range(20):
        nX, nY, L, n = 4, 2, int(rng.integers(1, 3)), int(rng.integers(2, 5))
        reach = [0, 1]            # the scaffold only produces inputs 0 and 1

        table = {}

        def nxt(z, rho, ans, table=table, rng=rng, reach=reach):
            key = (z, rho, ans)
            if key not in table:
                table[key] = int(rng.choice(reach))
            return table[key]

        scaf = Scaffold([0.5, 0.5], [0.5, 0.5], nxt, L)
        P = random_kernel(rng, nX, nY)
        members = []
        for i in range(2):                       # two members that agree with P on X_Pi only
            m = random_kernel(rng, nX, nY)
            m[reach] = P[reach]
            members.append(m)
        members.append(random_kernel(rng, nX, nY))
        w = rng.dirichlet(np.ones(3))
        klass = Klass(members, w)
        K_Pi_nats = math.log(1.0 / (w[0] + w[1]))
        lhs = [0.0]

        def per_round(t, st, pr, M, rs, P_t):
            for (q, xs, ys) in rs:
                for x in xs:
                    lhs[0] += pr * q * kl(P_t[x], M[x])

        rehearse(scaf, klass, lambda st: P, n, per_round)
        assert lhs[0] <= L * K_Pi_nats + 1e-9
        worst = min(worst, L * K_Pi_nats - lhs[0])
    print(f"  20 random instances: smallest value of L K_Pi ln 2 - sum = {worst:.4f}  (>= 0 required)")


def part_G(rng):
    print("== G: Proposition 2.5: beta(A)/L <= rho', and rho' for the exact imitator A = P")
    worst = INF
    for trial in range(200):
        nY = int(rng.integers(2, 6))
        A = rng.dirichlet(np.ones(nY))
        P = rng.dirichlet(np.ones(nY) * rng.choice([0.2, 1.0, 5.0]))
        tv = 0.5 * np.abs(A - P).sum()
        rho = 1.0 - float((A * P).sum())
        worst = min(worst, rho - tv)
    print(f"  200 random pairs: smallest (mismatch probability - TV) = {worst:.3e}  (>= 0 required)")
    print("  the exact imitator A = P, a human who gives the answer f(x) with probability 1 - e and one")
    print("  other answer with probability e: mismatch probability per asked call 2 e (1 - e), although")
    print("  beta(A) = 0.  Certificate (a) (no mismatch in m rounds) is passed with probability (1-2e(1-e))^m:")
    for e in (0.0, 0.001, 0.01, 0.1):
        rho = 2 * e * (1 - e)
        m = 300
        print(f"    e = {e:5.3f}: rho' = {rho:.4f};  Pr[no mismatch in m = 300 rounds] = {(1 - rho) ** m:.3e};"
              f"  certified beta/L by (b) at m -> infinity: {rho:.4f}")
    print("  with theta = 0.1 (faults tolerated per call), R3 needs beta/(theta L) < 1, i.e. rho' < 0.1:")
    print("  for e = 0.1 the exact imitator has rho' = 0.18 and certifies nothing, for every m.")
    print("  answers of h bits of entropy (free text): mismatch probability >= 1 - 2^(-h_min); for")
    for h in (1, 3, 10):
        print(f"    min-entropy {h:2d} bits: rho' >= {1 - 2.0 ** (-h):.4f}")


def part_H(rng):
    print("== H: Example 2.3 from first principles (engine) against the file's recursion")
    a, b = 0, 1

    def nxt(z, rho, ans):
        if len(ans) == 0:
            return a
        if len(ans) == 1 and ans[0] == 1:
            return b
        return None

    scaf = Scaffold([1.0], [1.0], nxt, 2)
    nu1 = np.array([[1.0, 0.0], [0.0, 1.0]])
    nu2 = np.array([[0.5, 0.5], [1.0, 0.0]])
    f = np.array([[1.0, 0.0], [1.0, 0.0]])
    klass = Klass([nu1, nu2], [0.5, 0.5])
    for n in (5, 12):
        final = rehearse(scaf, klass, lambda st: f, n)
        dead = sum(pr for st, pr in final.items() if klass.lik(st)[0] == 0)
        fail = 0.0
        for st, pr in final.items():
            M = klass.mixture(st)
            fail += pr * sum(q for (q, xs, ys) in scaf.runs(M) if ys != (0,))
        # the file's recursion
        alive, d2 = {0: 1.0}, 0.0
        for _ in range(n):
            new = {}
            for k, p_ in alive.items():
                om = 1.0 / (1.0 + 2.0 ** k)
                d2 += p_ * om / 4.0
                new[k + 1] = new.get(k + 1, 0.0) + p_ * 0.5
                new[k] = new.get(k, 0.0) + p_ * (0.5 - om / 4.0)
            alive = new
        print(f"  n = {n:2d}: engine Pr[nu1 refuted] = {dead:.6f} (file's recursion {d2:.6f});"
              f"  Pr[run of the next mixture differs from the human system] = {fail:.6f}")
    prod = 1.0
    for k in range(200):
        prod *= 2.0 / (2.0 + 1.0 / (1.0 + 2.0 ** k))
    print(f"  limit: 1 - prod_k 2/(2+omega_k) = {1 - prod:.6f}")


def part_I(rng):
    print("== I: Example 3.3 from first principles (engine), k = 1")
    for L in (2, 3):
        k = 1
        seeds = [0, 1]
        zs = list(itertools.product(range(L), repeat=len(seeds)))      # z = (z_0, z_1)
        nZ = len(zs)
        # inputs (z, j): index z_index * L + j
        nX = nZ * L

        def nxt(z, rho, ans, L=L):
            return z * L + len(ans) if len(ans) < L else None

        f = np.zeros((nX, 2))
        f[:, 0] = 1.0
        kernels = [f]
        for s in seeds:
            g = np.zeros((nX, 2))
            for zi, zz in enumerate(zs):
                for j in range(L):
                    g[zi * L + j, 0 if j == zz[s] else 1] = 1.0
            kernels.append(g)
        klass = Klass(kernels, [0.5, 0.25, 0.25])
        scaf = Scaffold([1.0 / nZ] * nZ, [1.0], nxt, L)
        s_true = 0
        for n in (3, 6):
            # seeded protocol: J_t = z_{t, s_true}
            states = {(): 1.0}
            tot_seed = 0.0
            for t in range(1, n + 1):
                new = {}
                for st, pr in states.items():
                    M = klass.mixture(st)
                    for (q, xs, ys) in scaf.runs(M):
                        tot_seed += pr * q * sum(1.0 - M[x, 0] for x in xs)
                        zi = xs[0] // L
                        J = zs[zi][s_true]
                        x = xs[J]
                        ns = tuple(sorted(st + ((x, 0),)))
                        new[ns] = new.get(ns, 0.0) + pr * q
                states = new
            tot_fresh = [0.0]

            def per_round(t, st, pr, M, rs, P_t):
                for (q, xs, ys) in rs:
                    tot_fresh[0] += pr * q * sum(1.0 - M[x, 0] for x in xs)

            rehearse(scaf, klass, lambda st: f, n, per_round)
            # the file's formula for the seeded protocol
            form = 0.0
            for t in range(1, n + 1):
                qv = float(L) ** (-(t - 1))
                form += (L - 1) * sum(math.comb(1, i) * qv ** i * (1 - qv) ** (1 - i) * (1 + i) / (2 + 1 + i)
                                      for i in range(2))
            print(f"  L = {L}, n = {n}: sum over rounds of E[unfaithful calls]: seeded J {tot_seed:.6f}"
                  f" (file's formula {form:.6f}), fresh J {tot_fresh[0]:.6f};"
                  f" R1 bound L K ln 2 = {L * LN2:.6f}; floor n (L-1)/(2^k+1) = {n * (L - 1) / 3:.6f}")


def part_J(rng):
    print("== J: Proposition 4.2 (exchangeable stock without replacement), exact")
    worst = INF
    for trial in range(6):
        n = 3
        stock = n + 1
        nX, nY, L = stock * 2, 2, 2
        # the run on task z asks input 2z, then input 2z + (first answer)
        def nxt_task(z, ans):
            if len(ans) == 0:
                return 2 * z
            if len(ans) == 1:
                return 2 * z + ans[0]
            return None

        H = 3
        kernels = [random_kernel(rng, nX, nY) for _ in range(H)]
        w = rng.dirichlet(np.ones(H))
        klass = Klass(kernels, w)
        P = kernels[0]
        total = 0.0
        perms = list(itertools.permutations(range(stock)))
        for perm in perms:
            states = {(): 1.0}
            for t in range(1, n + 1):
                z = perm[t - 1]
                # deployed mixture M^(t) on the last task perm[n]
                for st, pr in states.items():
                    M = klass.mixture(st)
                    sc = Scaffold([1.0], [1.0], lambda zz, rho, ans, zt=perm[n]: nxt_task(zt, ans), L)
                    for (q, xs, ys) in sc.runs(M):
                        total += pr * q * sum(kl(P[x], M[x]) for x in xs) / (n * len(perms))
                new = {}
                for st, pr in states.items():
                    M = klass.mixture(st)
                    sc = Scaffold([1.0], [1.0], lambda zz, rho, ans, zt=z: nxt_task(zt, ans), L)
                    for (q, xs, ys) in sc.runs(M):
                        for J in range(1, L + 1):
                            x = xs[J - 1]
                            for y in range(nY):
                                ns = tuple(sorted(st + ((x, y),)))
                                new[ns] = new.get(ns, 0.0) + pr * q / L * P[x, y]
                states = new
        bound = L * math.log(1.0 / w[0]) / n
        assert total <= bound + 1e-9
        worst = min(worst, bound - total)
    print(f"  6 random instances (n = 3, stock of 4 tasks, each used once): smallest bound - value = {worst:.4f}")


def part_K(rng):
    print("== K: Proposition 4.3 (open system, the human asked with probability q), exact")
    worst = INF
    for trial in range(20):
        nX, nY, T = 3, 2, 6
        q = float(rng.choice([0.2, 0.5, 0.8]))
        H = 3
        det = trial % 2 == 0
        kernels = [random_kernel(rng, nX, nY, det=det) for _ in range(H)]
        w = rng.dirichlet(np.ones(H))
        klass = Klass(kernels, w)
        P = kernels[0]
        rule = {}

        def call(hist, rule=rule, rng=rng):          # the next call depends on the whole past
            if hist not in rule:
                rule[hist] = int(rng.integers(0, nX))
            return rule[hist]

        tot_kl = [0.0]
        tot_wrong = [0.0]

        def dfs(t, hist, data, pr):
            if t == T or pr == 0:
                return
            x = call(hist)
            M = klass.mixture(data)
            tot_kl[0] += pr * kl(P[x], M[x])
            # asked
            for y in range(nY):
                if P[x, y] > 0:
                    dfs(t + 1, hist + (("h", x, y),), tuple(sorted(data + ((x, y),))), pr * q * P[x, y])
            # answered by the mixture
            for y in range(nY):
                if M[x, y] > 0:
                    if det:
                        tot_wrong[0] += pr * (1 - q) * M[x, y] * (1.0 - P[x, y])
                    dfs(t + 1, hist + (("m", x, y),), data, pr * (1 - q) * M[x, y])

        dfs(0, (), (), 1.0)
        bound = math.log(1.0 / w[0]) / q
        assert tot_kl[0] <= bound + 1e-9
        if det:
            assert tot_wrong[0] <= (1 - q) * bound + 1e-9
        worst = min(worst, bound - tot_kl[0])
    print(f"  20 random instances (6 calls): smallest value of K ln 2/q - summed divergence = {worst:.4f}")


def part_L(rng):
    print("== L: Corollary 1.12")
    worst = INF
    for trial in range(200000):
        s = int(rng.integers(2, 7))
        p = rng.dirichlet(np.ones(s) * rng.choice([0.1, 1.0]))
        nu = rng.dirichlet(np.ones(s) * rng.choice([0.1, 1.0]))
        if trial % 3 == 0:
            nu = np.where(rng.random(s) < 0.4, 0.0, nu)
            if nu.sum() == 0:
                continue
            nu = nu / nu.sum()
        eta = float(rng.choice([1e-6, 1e-3, 0.05, 0.3, 0.9]))
        qd = (1 - eta) * nu + eta / s
        a = 0.5 * np.abs(p - nu).sum()
        lhs = float(np.sum(np.where(p > 0, p * np.log(np.where(p > 0, p, 1.0) / qd), 0.0)))
        rhs = math.log(1.0 / (1 - eta)) + a * (1 + math.log(s / eta))
        worst = min(worst, rhs - lhs)
    print(f"  inequality KL(p || nu^eta) <= ln(1/(1-eta)) + a(1+ln(s/eta)): 200000 random cases,"
          f" smallest slack {worst:.3e}  (>= 0 required)")
    # part 7 of the file's script, exactly: the number of ones among the first T-1 answers is
    # Poisson-binomial; the posterior depends on it only.
    grid = np.linspace(0.05, 0.95, 19)
    gamma, p0 = 2e-4, 0.5
    print("  part 7 of the file's script recomputed exactly (no sampling):")
    for n in (10, 30, 100, 300, 1000, 2000):
        dist = np.array([1.0])
        tv0 = tvT = 0.0
        for T in range(1, n + 1):
            m = T - 1
            ones = np.arange(m + 1)
            loglik = ones[:, None] * np.log(grid)[None, :] + (m - ones)[:, None] * np.log(1 - grid)[None, :]
            post = np.exp(loglik - loglik.max(axis=1, keepdims=True))
            post /= post.sum(axis=1, keepdims=True)
            mix = post @ grid
            tv0 += float(dist @ np.abs(mix - (p0 + gamma)))
            tvT += float(dist @ np.abs(mix - (p0 + gamma * T)))
            pT = p0 + gamma * T
            nd = np.zeros(m + 2)
            nd[:-1] += dist * (1 - pT)
            nd[1:] += dist * pT
            dist = nd
        print(f"    n = {n:5d}: to the human of round 1: {tv0 / n:.4f};  to the human of round T: {tvT / n:.4f}")


if __name__ == "__main__":
    print(f"seed {SEED}")
    rng = np.random.default_rng(SEED)
    part_A(rng)
    part_B(rng)
    part_C(rng)
    part_D(rng)
    part_E(rng)
    part_F(rng)
    part_G(rng)
    part_H(rng)
    part_I(rng)
    part_J(rng)
    part_K(rng)
    part_L(rng)
