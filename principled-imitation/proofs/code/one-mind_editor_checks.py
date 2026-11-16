"""Editor's checks for proofs/one-mind.md (statements added or changed in editing).

E1  Example 3.1(c) on every path: at an input that was never asked, the per-call mixture answers with the
    human's law whatever the data are (also when an input was asked twice). Exact rational arithmetic.
E2  Proposition 3.5 (four-call variant of Proposition 3.2): Bayes factors of single answers at a fresh top-level
    input, the run of a member of F, the run law of the per-call mixture; then a simulation of the two drivers.
E3  Example 3.6 (codebook class): frequency with which the member of largest posterior weight is a function;
    the same selection with the weights squared.
E4  Proposition 4.6 (class A with traps slightly heavier than the human): the highest-weight consistent member
    after n = N/2 questions, against the per-call mixture; exact formula and simulation of the rehearsal.
E5  Theorem 3.8 (one program for a stochastic human, weights squared): the deterministic inequalities of Step 3
    of the proof on random instances (exact run laws), the two supermartingales by exact enumeration of all data
    sequences on small instances, a Monte Carlo of the rehearsal for the events of (a), (b) and (c), and part (a)
    exactly on a two-member class.

Usage: python3 one-mind_editor_checks.py        (about one minute)
"""
import itertools
import math
import random
from fractions import Fraction as Fr

import numpy as np

LN2 = math.log(2)


# ------------------------------------------------------------------------------------------------ E1
def check_E1():
    print("E1  Example 3.1(c): the per-call mixture at a never-asked input, for all data lists (inputs may repeat)")
    for eps in (Fr(1, 10), Fr(1, 4), Fr(1, 2)):
        NZ = 3
        P1 = 1 - eps                                    # P(1|z)
        funcs = list(itertools.product((0, 1), repeat=NZ))
        prior = {s: Fr(1, 2) * math.prod(P1 if s[z] else eps for z in range(NZ)) for s in funcs}
        assert sum(prior.values()) == Fr(1, 2)
        nlists = nrep = 0
        for k in range(0, 4):
            for zs in itertools.product(range(NZ), repeat=k):
                for ys in itertools.product((0, 1), repeat=k):
                    likP = math.prod(P1 if y else eps for y in ys)
                    post_f = {s: prior[s] for s in funcs if all(s[z] == y for z, y in zip(zs, ys))}
                    tot = Fr(1, 2) * likP + sum(post_f.values())
                    nlists += 1
                    nrep += len(set(zs)) < k
                    for z in range(NZ):
                        if z in zs:
                            continue
                        m1 = (Fr(1, 2) * likP * P1 + sum(v for s, v in post_f.items() if s[z] == 1)) / tot
                        assert m1 == P1                 # the mixture's law at a fresh input is the human's
        print(f"    eps = {eps}: {nlists} data lists of length <= 3 ({nrep} with a repeated input); "
              f"M(1|z) = P(1|z) at every never-asked z in all of them")


# ------------------------------------------------------------------------------------------------ E2
def members_F4(R):
    """Members of F_z for the four-call class: dict input-key -> answer.
    keys: 'z' -> r in range(R); (r, j) for j in (2, 3) -> bit; (r, b, b2) -> bit if b == b2, 'BAD' otherwise."""
    out = []
    keys4 = [(r, b, b) for r in range(R) for b in (0, 1)]
    for rstar in range(R):
        others = [r for r in range(R) if r != rstar]
        for c in (0, 1):
            for free in itertools.product((0, 1), repeat=2 * len(others)):
                for bits4 in itertools.product((0, 1), repeat=len(keys4)):
                    s = {'z': rstar, (rstar, 2): c, (rstar, 3): c}
                    for i, r in enumerate(others):
                        s[(r, 2)] = free[2 * i]
                        s[(r, 3)] = free[2 * i + 1]
                    for key, bit in zip(keys4, bits4):
                        s[key] = bit
                    for r in range(R):
                        s[(r, 0, 1)] = s[(r, 1, 0)] = 'BAD'
                    out.append(s)
    return out


def check_E2():
    print("E2  Proposition 3.5 (four calls: z, (z,y1,2), (z,y1,3), (z,y1,y2,y3,4))")
    for R in (2, 3):
        F = members_F4(R)
        assert len(F) == R * 2 * 4 ** (R - 1) * 2 ** (2 * R)

        def human(key):
            return {r: Fr(1, R) for r in range(R)} if key == 'z' else {0: Fr(1, 2), 1: Fr(1, 2)}

        def lawF(key):
            law = {}
            for s in F:
                law[s[key]] = law.get(s[key], 0) + Fr(1, len(F))
            return law
        # (a) single answers: the uniform law on F_z gives every input of the first three calls, and every
        #     fourth input with y2 = y3, the human's law; a fourth input with y2 != y3 gets BAD for certain
        for key in F[0]:
            lf = lawF(key)
            if len(key) == 3 and key[1] != key[2]:
                assert lf == {'BAD': 1}
            else:
                assert lf == human(key)
        # (b) the run of a member of F never reaches a fourth input with y2 != y3
        for s in F:
            y1 = s['z']
            assert s[(y1, 2)] == s[(y1, 3)]
        # (c) run law of the per-call mixture at a fresh z, posterior mass wF on F
        for wF in (Fr(1, 2), Fr(7, 8)):
            wP = 1 - wF
            tv = Fr(0)
            kl = 0.0
            for y1 in range(R):
                for y2 in (0, 1):
                    for y3 in (0, 1):
                        pre = Fr(1, 4 * R)              # first three answers: the human's law under both
                        for y4 in (0, 1, 'BAD'):
                            qp = pre * human((y1, y2, y3)).get(y4, 0)
                            qm = pre * (wP * human((y1, y2, y3)).get(y4, 0) + wF * lawF((y1, y2, y3)).get(y4, 0))
                            tv += abs(qp - qm) / 2
                            if qp:
                                kl += float(qp) * math.log(float(qp) / float(qm))
            assert tv == wF / 2
            assert abs(kl - 0.5 * math.log(1 / float(wP))) < 1e-12
        print(f"    R = {R}: |F_z| = {len(F)}; single answers have the human's law except BAD at (z,r,b,b'), b != b'; "
              f"no member's own run reaches such an input; TV(Q_M, Q_P) = w(F)/2 and KL(Q_P||Q_M) = (1/2) ln(1/w(P)) at a fresh z")
    # simulation of the two drivers at fresh top-level inputs (posterior odds change only when F is refuted)
    rng = random.Random(7)
    print("    simulation at fresh top-level inputs, R = 2, 20000 rehearsals per cell: number of rounds until F is refuted")
    print("       K   driver            mean rounds   expected     mean sum_t TV(Q_M^(t), Q_P)   expected (1-2^-K)/2 * rounds")
    for K in (1, 3, 5):
        wP = 2.0 ** (-K)
        for driver in ("posterior draw", "mixture"):
            tot = 0
            trials = 20000
            for _ in range(trials):
                t = 0
                while True:
                    t += 1
                    if driver == "posterior draw":
                        if rng.random() < wP:           # the driver is P: its run has independent answers
                            y2, y3 = rng.random() < 0.5, rng.random() < 0.5
                        else:                           # the driver is a member of F: y2 = y3
                            y2 = y3 = True
                    else:                               # the mixture: independent draws at calls 2 and 3
                        y2, y3 = rng.random() < 0.5, rng.random() < 0.5
                    J = rng.randrange(4)
                    if J == 3 and y2 != y3:             # the human answers a bit where all of F says BAD
                        break
                tot += t
            mean = tot / trials
            exp = 8 / wP if driver == "posterior draw" else 8.0
            # F is alive in rounds 1..t (t the round whose answer refutes it), so sum_t TV = (1 - wP)/2 * t
            print(f"    {K:4d}   {driver:15s} {mean:12.2f} {exp:10.1f} {(1 - wP) / 2 * mean:22.2f} {(1 - wP) / 2 * exp:26.2f}")
            assert abs(mean - exp) < 0.05 * exp


# ------------------------------------------------------------------------------------------------ E3
def check_E3():
    print("E3  Example 3.6 (codebook class): human = fair coin, P has weight 2^-K, 2^m random functions, m = n + K - 2")
    rng = np.random.default_rng(3)
    print("       K    n    m   trials   freq[MAP is a function]   1-(1-2^-n)^(2^m)   1-exp(-2^(K-2))   freq[2-MAP is a function]")
    for K, n in ((3, 6), (4, 6), (4, 10), (5, 8), (6, 8)):
        m = n + K - 2
        trials = 3000
        cnt = cnt2 = 0
        wP = 2.0 ** (-K)
        wS = (1 - wP) * 2.0 ** (-m)
        # posterior weights after n answers at distinct inputs: P: wP * 2^-n; a consistent function: wS
        assert wS > wP * 2.0 ** (-n)                    # a consistent function outweighs P
        assert wS ** 2 < wP ** 2 * 2.0 ** (-n) or n < 4  # with squared weights P outweighs every function (n >= 4)
        for _ in range(trials):
            answers = rng.integers(0, 2, n)
            book = rng.integers(0, 2, (2 ** m, n), dtype=np.int8)
            consistent = np.all(book == answers, axis=1).any()
            cnt += bool(consistent)
            cnt2 += bool(consistent) and (wS ** 2 >= wP ** 2 * 2.0 ** (-n))
        exact = 1 - (1 - 2.0 ** (-n)) ** (2 ** m)
        lower = 1 - math.exp(-2.0 ** (K - 2))
        assert exact >= lower - 1e-12 and abs(cnt / trials - exact) < 0.03
        print(f"    {K:4d} {n:4d} {m:4d} {trials:8d} {cnt / trials:18.4f} {exact:22.4f} {lower:17.4f} {cnt2 / trials:20.4f}")
    # TV between (c,c,c) with c a fixed bit and three fair coins
    tv = sum(abs((1.0 if y == (1, 1, 1) else 0.0) - 1 / 8) for y in itertools.product((0, 1), repeat=3)) / 2
    assert abs(tv - 7 / 8) < 1e-15
    print("    TV(run of a function, run of the human system) at a fresh input = 7/8")


# ------------------------------------------------------------------------------------------------ E4
def check_E4():
    print("E4  Proposition 4.6 (class A', traps of weight proportional to 1 + iota, human g_0 of weight proportional to 1)")
    print("       n    N    L   Pr[heaviest consistent member has >= L/4 ones]   (9/32) L/n   mixture: bound (L/n)^c/c!")
    for n, L in ((16, 8), (50, 12), (200, 40), (200, 200)):
        N = 2 * n
        c0 = math.ceil(L / 4)
        m0 = L - c0 + 1
        exact = 1 - (1 - 1 / N) ** m0
        assert m0 >= 3 * L / 4 and exact >= 9 / 32 * L / n - 1e-15
        mix = (L / n) ** c0 / math.factorial(c0)
        print(f"    {n:4d} {N:4d} {L:4d} {exact:32.5f} {9 / 32 * L / n:22.5f} {mix:20.3e}")
    # simulation of the mixture-driven rehearsal on A' and of the two deployed objects
    rng = random.Random(11)
    n, L, iota = 30, 12, 0.01
    N = 2 * n
    c0 = math.ceil(L / 4)
    trials = 20000
    bad_member = bad_mix = 0
    for _ in range(trials):
        alive = [True] * (N + 1)                        # traps 1..N; g_0 is the human and always alive

        def weights():
            k = sum(alive[1:])
            return k, 1.0 / (k * (1 + iota) + 1)        # mass of g_0; each surviving trap has (1 + iota) times it

        def mixture_answer(b, s):
            """A fresh posterior draw answers the input (b, s); returns 0 or 1."""
            k, w0 = weights()
            target = b if s == 0 else s                 # the one trap that answers 1 at this input
            return int(alive[target] and rng.random() < (1 + iota) * w0)
        for _t in range(n):
            flag = 0
            inputs = []
            for _j in range(L):
                b = rng.randrange(1, N + 1)
                inputs.append((b, flag))
                y = mixture_answer(b, flag)
                if flag == 0 and y == 1:
                    flag = b
            b, s = inputs[rng.randrange(L)]             # the question; the human g_0 answers 0
            alive[b if s == 0 else s] = False
        assert sum(alive[1:]) >= N - n
        heaviest = next(a for a in range(1, N + 1) if alive[a])      # traps are heavier than g_0; ties by index
        # one deployed run of the heaviest consistent member
        z = [rng.randrange(1, N + 1) for _ in range(L)]
        ones = (L - z.index(heaviest)) if heaviest in z else 0
        bad_member += ones >= c0
        # one deployed run of the per-call mixture
        flag = ones = 0
        for b in z:
            y = mixture_answer(b, flag)
            ones += y
            if flag == 0 and y == 1:
                flag = b
        bad_mix += ones >= c0
    exact = 1 - (1 - 1 / N) ** (L - c0 + 1)
    print(f"    simulation n = {n}, N = {N}, L = {L}, {trials} rehearsals: heaviest consistent member has >= L/4 ones with "
          f"frequency {bad_member / trials:.4f} (exact {exact:.4f}, bound (9/32)L/n = {9 / 32 * L / n:.4f}); "
          f"per-call mixture {bad_mix / trials:.5f} (bound (L/n)^c/c! = {(L / n) ** c0 / math.factorial(c0):.5f})")
    assert abs(bad_member / trials - exact) < 0.01 and bad_mix / trials <= (L / n) ** c0 / math.factorial(c0)


# ------------------------------------------------------------------------------------------------ E5
class Inst:
    """A random closed system with binary answers and a class of samplers; the human is member 0."""

    def __init__(self, rng, L, nz, nx, m, wP=None):
        self.L, self.nz, self.nx, self.m = L, nz, nx, m
        self.pz = rng.dirichlet(np.ones(nz))
        # next maps: input index or -1 (STOP)
        self.X1 = rng.integers(0, nx, nz)
        self.X2 = rng.integers(0, nx, (nz, 2))
        self.X3 = rng.integers(0, nx, (nz, 2, 2))
        if L >= 2:
            self.X2[rng.random((nz, 2)) < 0.15] = -1
        if L >= 3:
            self.X3[rng.random((nz, 2, 2)) < 0.15] = -1
        p = np.empty((m, nx))
        p[0] = rng.choice([0.1, 0.3, 0.5, 0.7, 0.9, 1.0], nx)        # the human; deterministic at some inputs
        for i in range(1, m):
            kind = i % 4
            if kind == 0:                                           # the human with its coins filled in
                p[i] = (rng.random(nx) < p[0]).astype(float)
            elif kind == 1:                                         # the human, changed at a few inputs
                p[i] = p[0].copy()
                idx = rng.random(nx) < 0.3
                p[i][idx] = rng.random(int(idx.sum()))
            elif kind == 2:                                         # a slightly tilted human
                p[i] = np.clip(p[0] + rng.normal(0, 0.1, nx), 0.0, 1.0)
            else:
                p[i] = rng.random(nx)
        self.p = p
        w = rng.dirichlet(np.ones(m) * 0.5)
        if wP is not None:
            w[0] = max(w[0], wP)
        self.w = w / w.sum() * rng.choice([1.0, 0.8])               # total weight 1 or 0.8
        self.K = -math.log2(self.w[0])
        # per-call squared Hellinger distance to the human, shape (m, nx)
        self.g = 1 - np.sqrt(p * p[0]) - np.sqrt((1 - p) * (1 - p[0]))

    def cells(self):
        """All (z, answers) cells with their input sequences."""
        out = []
        for z in range(self.nz):
            for y1 in (0, 1):
                x1 = self.X1[z]
                if self.L == 1 or self.X2[z, y1] < 0:
                    out.append((z, (y1,), (x1,)))
                    continue
                x2 = self.X2[z, y1]
                for y2 in (0, 1):
                    if self.L == 2 or self.X3[z, y1, y2] < 0:
                        out.append((z, (y1, y2), (x1, x2)))
                        continue
                    x3 = self.X3[z, y1, y2]
                    for y3 in (0, 1):
                        out.append((z, (y1, y2, y3), (x1, x2, x3)))
        return out

    def run_law(self, q):
        """Run law of a sampler given by q[x] = Pr[answer 1]; array over self.cells()."""
        law = []
        for z, ys, xs in self._cells:
            pr = self.pz[z]
            for y, x in zip(ys, xs):
                pr *= q[x] if y else 1 - q[x]
            law.append(pr)
        return np.array(law)

    def prepare(self):
        self._cells = self.cells()
        self.laws = np.array([self.run_law(self.p[i]) for i in range(self.m)])
        assert np.allclose(self.laws.sum(1), 1.0)
        self.H2run = 1 - np.sqrt(self.laws * self.laws[0]).sum(1)   # H^2(Q_nu, Q_P), exact
        # G[nu, cell] = sum over the calls of the cell of H^2(nu, P)(x_j)
        self.G = np.array([[sum(self.g[i, x] for x in xs) for (_, _, xs) in self._cells] for i in range(self.m)])
        self.EP_G = (self.G * self.laws[0]).sum(1)                  # E_{Q_P}[g_nu]


def h2(a, b):
    return 1 - math.sqrt(a * b) - math.sqrt((1 - a) * (1 - b))


def check_E5():
    print("E5  Theorem 3.8 (weights squared, stochastic human)")
    rng = np.random.default_rng(5)
    # (i) the deterministic inequalities of Step 3, on random instances and random mixtures:
    #     H2(Q_nu, Q_M) <= 4 E_{Q_M} sum_j H2(nu, M)(x_j)                 (Corollary 2.3 of hellinger-runs)
    #     H2(Q_P,  Q_M) <= 4 kappa,  kappa = E_{Q_M} sum_j H2(P, M)(x_j)   (the same)
    #     H2(nu, M)(x) <= 2 H2(nu, P)(x) + 2 H2(P, M)(x)                   (triangle inequality, per call)
    #     H2(Q_nu, Q_P) <= 2 H2(Q_nu, Q_M) + 2 H2(Q_M, Q_P)                (triangle inequality, run laws)
    #     hence H2(Q_nu, Q_P) <= 16 L h(nu) + 24 kappa,  L h(nu) = E_{Q_M} sum_j H2(nu, P)(x_j)
    worst = [0.0, 0.0, 0.0, 0.0, 0.0]
    ninst = 0
    for trial in range(400):
        L = int(rng.integers(1, 4))
        I = Inst(rng, L, nz=int(rng.integers(1, 5)), nx=int(rng.integers(2, 9)), m=int(rng.integers(3, 12)))
        I.prepare()
        for _ in range(5):
            post = rng.dirichlet(np.ones(I.m) * rng.choice([0.2, 1.0]))
            if rng.random() < 0.5:
                post = 0.9 * post
                post[0] += 0.1
            M = np.clip(post @ I.p, 0.0, 1.0)
            lawM = I.run_law(M)
            H2PM = 1 - np.sqrt(lawM * I.laws[0]).sum()
            H2nuM = 1 - np.sqrt(I.laws * lawM).sum(1)                              # H^2(Q_nu, Q_M)
            gPM = 1 - np.sqrt(I.p[0] * M) - np.sqrt((1 - I.p[0]) * (1 - M))        # H^2(P, M)(x)
            gnuM = 1 - np.sqrt(I.p * M) - np.sqrt((1 - I.p) * (1 - M))             # H^2(nu, M)(x), shape (m, nx)
            assert np.all(gnuM <= 2 * I.g + 2 * gPM + 1e-12)                       # per-call triangle inequality
            r0 = float(np.max(gnuM / np.maximum(2 * I.g + 2 * gPM, 1e-300) * (2 * I.g + 2 * gPM > 1e-14)))
            kappa = sum(lawM[c] * sum(gPM[x] for x in xs) for c, (_, _, xs) in enumerate(I._cells))
            EM_nuM = np.array([sum(lawM[c] * sum(gnuM[i, x] for x in xs) for c, (_, _, xs) in enumerate(I._cells))
                               for i in range(I.m)])
            EM_G = (I.G * lawM).sum(1)                                             # E_{Q_M}[g_nu] = L h(nu)
            assert np.all(H2nuM <= 4 * EM_nuM + 1e-12)
            r1 = float(np.max(H2nuM / np.maximum(4 * EM_nuM, 1e-300) * (EM_nuM > 1e-14)))
            assert H2PM <= 4 * kappa + 1e-12
            r2 = H2PM / (4 * kappa) if kappa > 1e-14 else 0.0
            assert np.all(I.H2run <= 2 * H2nuM + 2 * H2PM + 1e-12)                 # triangle inequality for run laws
            r3 = float(np.max(I.H2run / np.maximum(2 * H2nuM + 2 * H2PM, 1e-300) * (2 * H2nuM + 2 * H2PM > 1e-14)))
            rhs = 16 * EM_G + 24 * kappa
            assert np.all(I.H2run <= rhs + 1e-12)
            r4 = float(np.max(I.H2run / np.maximum(rhs, 1e-300) * (rhs > 1e-14)))
            worst = [max(a, b) for a, b in zip(worst, (r0, r1, r2, r3, r4))]
            ninst += 1
    print(f"    (i) {ninst} random (instance, mixture) pairs, exact run laws; largest ratios (all must be <= 1):")
    print(f"        per-call triangle {worst[0]:.4f};  H2(Q_nu,Q_M)/(4 E_M sum H2(nu,M)) = {worst[1]:.4f};  H2(Q_P,Q_M)/(4 kappa) = {worst[2]:.4f};  "
          f"run-law triangle {worst[3]:.4f};  H2(Q_nu,Q_P)/(16 L h + 24 kappa) = {worst[4]:.4f}")

    # (ii) the two supermartingales, exactly, by enumeration of all data sequences
    print("    (ii) exact expectations over all data sequences (mixture-driven rehearsal, L = 2):")
    print("         inst   n   paths    max_nu E[N_n(nu)]   E[N'_n]   Pr[sum kappa_t >= L(K ln2/2 + ln(1/d))]   E[Pi_2(A)]   Pr[some nu in A beats P]   delta")
    for trial in range(4):
        I = Inst(rng, 2, nz=2, nx=4, m=5, wP=0.25)
        I.prepare()
        n = 4
        delta = 0.5 if trial < 2 else 0.25
        a = math.log(I.w.sum() / I.w[0]) + math.log(1 / delta)
        res = {"EN": np.zeros(I.m), "ENp": 0.0, "tot": 0.0, "paths": 0, "fB": 0.0, "mass": 0.0, "beat": 0.0}

        def rec(t, prob, lik, Nv, Np, sum_h, sum_k):
            if t == n:
                res["EN"] += prob * Nv
                res["ENp"] += prob * Np
                res["tot"] += prob
                res["paths"] += 1
                res["fB"] += prob * (sum_k >= I.L * (0.5 * I.K * LN2 + math.log(1 / delta)))
                A = sum_h >= a
                s2 = I.w ** 2 * lik
                res["mass"] += prob * (s2[A].sum() / s2.sum())
                res["beat"] += prob * bool(np.any(s2[A] >= s2[0]))
                return
            post = I.w * lik
            post = post / post.sum()
            M = np.clip(post @ I.p, 0.0, 1.0)
            lawM = I.run_law(M)
            h = (I.G * lawM).sum(1) / I.L
            gM = np.array([h2(float(I.p[0, x]), float(M[x])) for x in range(I.nx)])
            kap = sum(lawM[c] * sum(gM[x] for x in xs) for c, (_, _, xs) in enumerate(I._cells))
            for c, (z, ys, xs) in enumerate(I._cells):
                if lawM[c] == 0:
                    continue
                for J in range(I.L):
                    pr = prob * lawM[c] / I.L
                    if J >= len(xs):                                # no question in this round
                        rec(t + 1, pr, lik, Nv * np.exp(h), Np * math.exp(kap / I.L), sum_h + h, sum_k + kap)
                        continue
                    x = xs[J]
                    for y in (0, 1):
                        py = I.p[0, x] if y else 1 - I.p[0, x]
                        if py == 0:
                            continue
                        ly = I.p[:, x] if y else 1 - I.p[:, x]
                        my = M[x] if y else 1 - M[x]
                        rec(t + 1, pr * py, lik * ly, Nv * np.sqrt(ly / py) * np.exp(h),
                            Np * math.sqrt(my / py) * math.exp(kap / I.L), sum_h + h, sum_k + kap)

        rec(0, 1.0, np.ones(I.m), np.ones(I.m), 1.0, np.zeros(I.m), 0.0)
        assert abs(res["tot"] - 1) < 1e-9
        assert np.all(res["EN"] <= 1 + 1e-9) and res["ENp"] <= 1 + 1e-9
        assert res["fB"] <= delta + 1e-12 and res["mass"] <= delta + 1e-12 and res["beat"] <= delta + 1e-12
        print(f"         {trial:4d} {n:3d} {res['paths']:7d} {res['EN'][1:].max():16.6f} {res['ENp']:12.6f} {res['fB']:26.4f} "
              f"{res['mass']:27.5f} {res['beat']:18.5f} {delta:14.2f}")

    # (iii) Monte Carlo of the rehearsal
    print("    (iii) Monte Carlo of the mixture-driven rehearsal; A = {nu : sum_t h_t(nu) >= K ln2 + ln(1/delta)};")
    print("          B = bound (c) = L (28 K ln2 + 40 ln(1/d))/n")
    print("          L   K(bits)     n  delta  trials   E[Pi_2(A)]   freq[2-MAP in A]   freq[sum kappa >= its bound]   B        "
          "E[Pi_2(H2 >= B)]   freq[H2(2-MAP) >= B]   mean H2: Pi_2 draw, 2-MAP, Pi_1 draw, 1-MAP")
    for L, n, delta, trials in ((1, 300, 0.25, 60), (2, 800, 0.25, 50), (3, 1500, 0.25, 40), (3, 400, 0.5, 60)):
        I = Inst(rng, L, nz=4, nx=8, m=40, wP=0.15)
        I.prepare()
        a = I.K * LN2 + math.log(1 / delta)
        kb = L * (0.5 * I.K * LN2 + math.log(1 / delta))
        B = (16 * L * a + 24 * kb) / n
        assert abs(B - L * (28 * I.K * LN2 + 40 * math.log(1 / delta)) / n) < 1e-9
        acc = dict(massA=0.0, mapA=0.0, kap=0.0, massB=0.0, mapB=0.0, m2=0.0, map2=0.0, m1=0.0, map1=0.0)
        logw = np.log(I.w)
        for _ in range(trials):
            loglik = np.zeros(I.m)
            sum_h = np.zeros(I.m)
            sum_k = 0.0
            for t in range(n):
                s = logw + loglik
                post = np.exp(s - s.max())
                post /= post.sum()
                M = np.clip(post @ I.p, 0.0, 1.0)
                lawM = I.run_law(M)
                sum_h += (I.G * lawM).sum(1) / L
                gM = 1 - np.sqrt(I.p[0] * M) - np.sqrt((1 - I.p[0]) * (1 - M))
                sum_k += sum(lawM[c] * sum(gM[x] for x in xs) for c, (_, _, xs) in enumerate(I._cells))
                c = rng.choice(len(lawM), p=lawM / lawM.sum())
                z, ys, xs = I._cells[c]
                J = int(rng.integers(0, L))
                if J < len(xs):
                    x = xs[J]
                    y = rng.random() < I.p[0, x]
                    with np.errstate(divide="ignore"):
                        loglik += np.log(I.p[:, x] if y else 1 - I.p[:, x])

            def posterior(lam):
                s = lam * logw + loglik
                q = np.exp(s - s.max())
                return q / q.sum()
            pi2, pi1 = posterior(2.0), posterior(1.0)
            A = sum_h >= a
            acc["massA"] += pi2[A].sum()
            acc["mapA"] += float(A[int(np.argmax(pi2))])
            acc["kap"] += float(sum_k >= kb)
            acc["massB"] += pi2[I.H2run >= B].sum()
            acc["mapB"] += float(I.H2run[int(np.argmax(pi2))] >= B)
            acc["m2"] += pi2 @ I.H2run
            acc["map2"] += I.H2run[int(np.argmax(pi2))]
            acc["m1"] += pi1 @ I.H2run
            acc["map1"] += I.H2run[int(np.argmax(pi1))]
        for k in acc:
            acc[k] /= trials
        assert acc["massA"] <= delta and acc["mapA"] <= delta and acc["kap"] <= delta
        assert acc["massB"] <= 2 * delta and acc["mapB"] <= 2 * delta
        print(f"        {L:4d} {I.K:8.2f} {n:6d} {delta:5.2f} {trials:6d} {acc['massA']:11.5f} {acc['mapA']:15.3f} {acc['kap']:22.3f} "
              f"{B:16.4f} {acc['massB']:12.5f} {acc['mapB']:18.3f}          {acc['m2']:.6f}, {acc['map2']:.6f}, {acc['m1']:.6f}, {acc['map1']:.6f}")


def check_E5_two():
    """Theorem 3.8(a) on a two-member class, exactly: one input, one call (L = 1), the human P = Bern(p) with
    weight wP and one other member nu = Bern(q) with weight 1 - wP. Then h_t(nu) = H^2(nu, P) =: h for every t,
    A = {nu} as soon as n h >= a := ln(1/wP) + ln(1/delta), and Pi_2(A) = 1/(1 + (wP/(1-wP))^2 P(D)/nu(D)).
    The number of answers 1 is binomial, so E[Pi_2(A)] is a finite sum. Taken at the first n with n h >= a."""
    from math import lgamma, log, exp, sqrt, ceil

    def logbinom(n, k):
        return lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)

    def expected_mass(p, q, wP, n):
        E = beat = 0.0
        for k in range(n + 1):
            lp = logbinom(n, k) + k * log(p) + (n - k) * log(1 - p)
            if q == 1.0:
                llr = n * log(1 / p) if k == n else None
            else:
                llr = k * log(q / p) + (n - k) * log((1 - q) / (1 - p))
            if llr is None:
                continue
            x = 2 * log((1 - wP) / wP) + llr
            pi2 = 1.0 if x > 700 else 0.0 if x < -700 else 1 / (1 + exp(-x))
            E += exp(lp) * pi2
            beat += exp(lp) * (x >= 0)
        return E, beat

    print("    (iv) a two-member class, exact (binomial sums), at the first n with sum_t h_t(nu) >= a:")
    worst = worst_beat = worst_half = 0.0
    arg = None
    for p, q in ((0.5, 0.6), (0.5, 0.9), (0.5, 1.0), (0.3, 0.31), (0.9, 0.99), (0.5, 0.52)):
        h = 1 - sqrt(p * q) - sqrt((1 - p) * (1 - q))
        for wP in (0.5, 0.1, 0.01, 0.001):
            for delta in (0.5, 0.25, 0.1, 0.01):
                a = log(1 / wP) + log(1 / delta)
                E, beat = expected_mass(p, q, wP, ceil(a / h))
                assert E <= delta and beat <= delta
                if E / delta > worst:
                    worst, arg = E / delta, (p, q, wP, delta, ceil(a / h))
                worst_beat = max(worst_beat, beat / delta)
                # the same with the threshold a/2 in place of a (not a statement of the theorem)
                E2, _ = expected_mass(p, q, wP, ceil(0.5 * a / h))
                worst_half = max(worst_half, E2 / delta)
    print(f"         96 cases: largest E[Pi_2(A)]/delta = {worst:.4f} at (p, q, wP, delta, n) = {arg}; "
          f"largest Pr[nu beats P]/delta = {worst_beat:.4f}  (both must be <= 1)")
    print(f"         with the threshold a/2 in place of a the largest ratio would be {worst_half:.2f} "
          f"(so the threshold of (a) cannot be halved)")


if __name__ == "__main__":
    check_E1()
    check_E2()
    check_E3()
    check_E4()
    check_E5()
    check_E5_two()
    print("all assertions passed")
