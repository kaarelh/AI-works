"""Referee's exact checks for research/prove-c/one-mind.md, Sections 1, 2 and 5 (no Monte Carlo in checks 1-6).

check 1  Lemma 1.4 by brute-force enumeration of run trees (stochastic hypotheses, semimeasures, runs of
         variable length, runs with no calls).
check 2  Theorem 2.1, Steps 1-3: E[m_t | D_{t-1}, z] >= (1/L) sum_j Pr[sigma >= j] p_j >= psi_L(u_t(z))/L,
         exactly, on the same random instances.
check 3  Theorem 2.1, totals over an infinite rehearsal, exactly, for random classes of functions: the rehearsal
         is an absorbing Markov chain on version spaces. Also Theorem R1 (mixture driver) and Proposition 5.1
         (first-consistent driver) on the same classes.
check 4  Example 5.2 exactly (first-consistent driver: L*M), and the class of Proposition 2.5 with one and two
         top-level inputs.
check 5  Theorem 5.5: the identity Pr[question removes g | data] = d_t(g)/L, Step 3 (d_t(g) >= u(g) - beta_t),
         and E[m_t | data] = beta_t/L, for every reachable version space of random classes.
check 6  Theorem 5.5, Steps 1 and 2: exact expectation of the two (super)martingales after n rounds, by
         enumeration of all paths of version spaces, and exact probabilities of the events of (a) and (b).
check 7  Theorem 5.5(a) on an instance where it is nearly tight (closed form), and Corollary 5.6 there.
check 8  Referee's additions for the posterior-draw driver: a high-probability form of Theorem 2.1, and
         Theorem 5.5 for a rehearsal driven by posterior draws (per-state identities and exact path enumeration).
Usage: python3 one-mind_check_exact.py
"""
import math
import random
import sys
from math import comb

BOT = 3            # the symbol that carries the missing mass of a semimeasure
LN2 = math.log(2)


def psi(u, L):
    return u - u * u * (L - 1) / (2.0 * L)


class Scaffold:
    """A random scaffold: next_j(z, y_<j) is a lazily filled random table; runs may stop early, also at call 1."""

    def __init__(self, rng, nz, nx, L, stop=0.2, stop_first=0.1):
        self.nz, self.nx, self.L = nz, nx, L
        self.rng = random.Random(rng.random())
        self.stop, self.stop_first = stop, stop_first
        self.table = {}
        p = [rng.random() + 0.05 for _ in range(nz)]
        s = sum(p)
        self.pz = [q / s for q in p]

    def nxt(self, z, ys):
        j = len(ys) + 1
        if j > self.L:
            return None
        key = (z, ys)
        if key not in self.table:
            p = self.stop_first if j == 1 else self.stop
            self.table[key] = None if self.rng.random() < p else self.rng.randrange(self.nx)
        return self.table[key]

    def run_function(self, z, g):
        xs, ys = [], ()
        while True:
            x = self.nxt(z, ys)
            if x is None:
                return tuple(xs), ys
            xs.append(x)
            ys = ys + (g[x],)


def run_tree(sc, z, kern):
    """All runs of the sampler kern (kern[x] = dict answer -> probability) on z: list of (prob, xs, ys)."""
    out = []

    def rec(ys, xs, p):
        x = sc.nxt(z, ys)
        if x is None:
            out.append((p, xs, ys))
            return
        for y, q in kern[x].items():
            if q > 0:
                rec(ys + (y,), xs + (x,), p * q)

    rec((), (), 1.0)
    return out


def random_kernel(rng, f, nx):
    """A random hypothesis: a function, a noisy version of f, an arbitrary sampler, or a semimeasure."""
    kind = rng.choice(["function", "noisy", "sampler", "semi", "nearf"])
    kern = []
    for x in range(nx):
        if kind == "function":
            y = f[x] if rng.random() < 0.6 else rng.randrange(4)      # may be BOT
            kern.append({y: 1.0})
        elif kind == "nearf":
            e = rng.choice([0.0, 0.0, 0.05, 0.3, 1.0])
            other = rng.choice([y for y in range(4) if y != f[x]])
            kern.append({f[x]: 1.0 - e, other: e})
        else:
            p = [rng.random() ** 2 for _ in range(4)]
            if kind == "noisy":
                p[f[x]] += 3.0
            if kind != "semi":
                p[BOT] = 0.0
            s = sum(p)
            kern.append({y: p[y] / s for y in range(4)})
    return kern


def checks_1_2(trials, seed):
    rng = random.Random(seed)
    worst12 = worst23 = math.inf
    nruns = nstoch = n_nocall = 0
    tight = 0.0
    for _ in range(trials):
        L = rng.randint(1, 4)
        nz, nx = rng.randint(1, 3), rng.randint(2, 6)
        sc = Scaffold(rng, nz, nx, L)
        f = [rng.randrange(3) for _ in range(nx)]
        hyps = [[{f[x]: 1.0} for x in range(nx)]] + [random_kernel(rng, f, nx) for _ in range(rng.randint(1, 5))]
        w = [rng.random() ** 3 + 1e-3 for _ in hyps]
        s = sum(w)
        w = [q / s for q in w]                                       # any posterior is of this form
        ebar = [sum(wn * (1.0 - nu[x].get(f[x], 0.0)) for nu, wn in zip(hyps, w)) for x in range(nx)]
        for z in range(nz):
            xf, yf = sc.run_function(z, f)
            Tf = len(xf)
            n_nocall += Tf == 0
            u = Em = 0.0
            p = [0.0] * Tf
            for nu, wn in zip(hyps, w):
                tree = run_tree(sc, z, nu)
                nruns += len(tree)
                nstoch += len(tree) > 1
                assert abs(sum(t[0] for t in tree) - 1.0) < 1e-12
                unf, sig = 0.0, [0.0] * Tf
                for pr, xs, ys in tree:
                    wrong = [j for j in range(len(xs)) if ys[j] != f[xs[j]]]
                    if wrong:                                         # Lemma 1.4(a),(b)
                        j = wrong[0]
                        assert j < Tf and xs[: j + 1] == xf[: j + 1] and ys != yf
                        unf += pr
                        sig[j] += pr
                    else:
                        assert xs == xf and ys == yf
                    Em += wn * pr * sum(ebar[x] for x in xs) / L      # E[removed mass], J uniform on [L]
                prod = 1.0                                            # Lemma 1.4(c)
                for j, x in enumerate(xf):
                    e = 1.0 - nu[x].get(f[x], 0.0)
                    assert abs(sig[j] - e * prod) < 1e-12
                    prod *= 1.0 - e
                assert abs((1.0 - unf) - prod) < 1e-12
                u += wn * unf
                for j in range(Tf):
                    p[j] += wn * sig[j]
            mid = sum(p[j] * (1.0 - sum(p[:j])) for j in range(Tf)) / L
            low = psi(u, L) / L
            assert Em >= mid - 1e-12 and mid >= low - 1e-12
            worst12 = min(worst12, Em - mid)
            worst23 = min(worst23, mid - low)
            if low > 1e-9:
                tight = max(tight, low / Em)
    print(f"checks 1 and 2: {trials} random instances, {nruns} runs enumerated ({nstoch} run trees of stochastic "
          f"hypotheses, {n_nocall} top-level inputs with no call)")
    print(f"   Lemma 1.4(a),(b),(c): no violation")
    print(f"   min of E[m|z] - (1/L)sum_j Pr[sigma>=j]p_j = {worst12:.3e};  min of (1/L)sum_j Pr[sigma>=j]p_j - psi_L(u)/L"
          f" = {worst23:.3e};  largest ratio (psi_L(u)/L)/E[m|z] = {tight:.4f}")


class Det:
    """A class of functions G (G[0] = f) with weights w on a scaffold; exact one-round quantities per version space."""

    def __init__(self, sc, G, w):
        self.sc, self.G, self.w, self.m = sc, G, w, len(G)
        f = G[0]
        self.agree = [sum(1 << h for h in range(self.m) if G[h][x] == f[x]) for x in range(sc.nx)]
        self.runs = [[sc.run_function(z, G[h]) for z in range(sc.nz)] for h in range(self.m)]
        self.dev = [[self.runs[h][z][1] != self.runs[0][z][1] for z in range(sc.nz)] for h in range(self.m)]
        self.u_own = [sum(sc.pz[z] for z in range(sc.nz) if self.dev[h][z]) for h in range(self.m)]
        self.memo = {}

    def members(self, V):
        return [h for h in range(self.m) if V >> h & 1]

    def wV(self, V):
        return sum(self.w[h] for h in self.members(V))

    def step_single(self, V, law):
        """One round when the run is answered by a single function drawn from law (dict h -> prob).
        Returns (E[u], E[psi_L(u)]) for this law as the per-z unfaithfulness, and the transition law."""
        sc, L = self.sc, self.sc.L
        ubar = psibar = 0.0
        trans = {}
        for z in range(sc.nz):
            uz = sum(q for h, q in law.items() if self.dev[h][z])
            ubar += sc.pz[z] * uz
            psibar += sc.pz[z] * psi(uz, L)
            for h, q in law.items():
                xs = self.runs[h][z][0]
                for J in range(1, L + 1):
                    V2 = V & self.agree[xs[J - 1]] if J <= len(xs) else V
                    trans[V2] = trans.get(V2, 0.0) + sc.pz[z] * q / L
        return (ubar, psibar), trans

    def step_draw(self, V):
        wv = self.wV(V)
        return self.step_single(V, {h: self.w[h] / wv for h in self.members(V)})

    def step_first(self, V, order):
        first = next(h for h in order if V >> h & 1)
        return self.step_single(V, {first: 1.0})

    def step_mix(self, V):
        """One round of the mixture driver. Returns (Pr[run unfaithful], beta = E[#unfaithful calls]),
        the transition law, and d[g] = E[#calls of the run at whose inputs g is wrong]."""
        sc, L, f = self.sc, self.sc.L, self.G[0]
        mem = self.members(V)
        wv = self.wV(V)
        pun = beta = 0.0
        trans = {}
        d = [0.0] * self.m
        pred = {}

        def M(x):
            if x not in pred:
                q = {}
                for h in mem:
                    q[self.G[h][x]] = q.get(self.G[h][x], 0.0) + self.w[h] / wv
                pred[x] = q
            return pred[x]

        def rec(z, ys, xs, p, nun):
            nonlocal pun, beta
            x = sc.nxt(z, ys)
            if x is None:
                pun += p * (nun > 0)
                beta += p * nun
                for g in range(self.m):
                    d[g] += p * sum(self.G[g][xx] != f[xx] for xx in xs)
                for J in range(1, L + 1):
                    V2 = V & self.agree[xs[J - 1]] if J <= len(xs) else V
                    trans[V2] = trans.get(V2, 0.0) + p / L
                return
            for y, q in M(x).items():
                rec(z, ys + (y,), xs + (x,), p * q, nun + (y != f[x]))

        for z in range(sc.nz):
            rec(z, (), (), sc.pz[z], 0)
        return (pun, beta), trans, d

    def total(self, V, step, key):
        """Expected total, over an infinite rehearsal started at V, of the immediate values returned by step."""
        k = (key, V)
        if k in self.memo:
            return self.memo[k]
        imm, trans = step(V)[:2]
        leave = sum(q for V2, q in trans.items() if V2 != V)       # summed directly: 1 - stay would lose digits
        acc = list(imm)
        for V2, q in trans.items():
            if V2 != V:
                sub = self.total(V2, step, key)
                for i in range(len(acc)):
                    acc[i] += q * sub[i]
        if leave == 0.0:
            assert all(abs(a) < 1e-12 for a in imm), "a version space that never shrinks must be faithful"
            res = tuple(0.0 for _ in acc)
        else:
            res = tuple(a / leave for a in acc)
        self.memo[k] = res
        return res


def random_class(rng, m=None):
    L = rng.randint(1, 5)
    nz, nx = rng.randint(1, 4), rng.randint(3, 8)
    sc = Scaffold(rng, nz, nx, L)
    f = [rng.randrange(3) for _ in range(nx)]
    G = [f]
    for _ in range(m if m is not None else rng.randint(2, 9)):
        rate = rng.choice([0.1, 0.25, 0.5])
        G.append([(rng.randrange(4) if rng.random() < rate else f[x]) for x in range(nx)])
    w = [rng.random() ** 2 + 1e-3 for _ in G]
    if rng.random() < 0.5:
        w[0] = rng.choice([1e-3, 1e-2, 0.05]) * max(w)               # a human of small weight
    s = sum(w) / rng.choice([1.0, 0.9, 0.5])                         # W = 1, 0.9 or 0.5
    return Det(sc, G, [q / s for q in w])


def check_3(trials, seed):
    rng = random.Random(seed)
    r_psi = r_u = r_mix = r_first = 0.0
    r_psi2 = r_u2 = r_mix2 = 0.0                                     # the same maxima over the classes with L >= 2
    nstates = nL2 = 0
    for _ in range(trials):
        C = random_class(rng)
        L, V0 = C.sc.L, (1 << C.m) - 1
        cap = math.log(sum(C.w) / C.w[0])                            # ln(W/w(f)) <= K ln 2
        tu, tpsi = C.total(V0, C.step_draw, "draw")
        assert tpsi <= L * cap + 1e-9 and tu <= 2 * L * L / (L + 1) * cap + 1e-9
        tpun, tbeta = C.total(V0, C.step_mix, "mix")
        assert tbeta <= L * cap + 1e-9 and tpun <= tbeta + 1e-12
        order = sorted(range(C.m), key=lambda h: (-C.w[h], h != 0))   # non-increasing weight; f first among ties
        i0 = order.index(0) + 1
        tf = C.total(V0, lambda V: C.step_first(V, order), "first")[0]
        assert tf <= L * (i0 - 1) + 1e-9 and i0 - 1 <= sum(C.w) / C.w[0] - 1 + 1e-12
        nstates += len(C.memo)
        if cap > 1e-9:
            r_psi, r_u, r_mix = max(r_psi, tpsi / (L * cap)), max(r_u, tu / (2 * L * L / (L + 1) * cap)), max(r_mix, tbeta / (L * cap))
            if L >= 2:
                nL2 += 1
                r_psi2, r_u2, r_mix2 = max(r_psi2, tpsi / (L * cap)), max(r_u2, tu / (2 * L * L / (L + 1) * cap)), max(r_mix2, tbeta / (L * cap))
        if i0 > 1:
            r_first = max(r_first, tf / (L * (i0 - 1)))
    print(f"check 3: {trials} random classes of functions (W in {{1, 0.9, 0.5}}), infinite rehearsal, exact totals "
          f"({nstates} version spaces evaluated)")
    print(f"   posterior draw: max of sum_t E[psi_L(u_t)] / (L ln(W/w(f))) = {r_psi:.4f};  "
          f"max of sum_t E[u_t] / ((2L^2/(L+1)) ln(W/w(f))) = {r_u:.4f}")
    print(f"   mixture (Theorem R1): max of sum_t E[#unfaithful calls] / (L ln(W/w(f))) = {r_mix:.4f}")
    print(f"   the same three maxima over the {nL2} classes with L >= 2: {r_psi2:.4f}, {r_u2:.4f}, {r_mix2:.4f}")
    print(f"   first consistent (Proposition 5.1): max of sum_t Pr[run unfaithful] / (L (i0 - 1)) = {r_first:.4f}")


class PathScaffold:
    """Example 2.4: inputs (z, j) coded z*L + (j-1), and the sink coded nz*L; answers 0/1."""

    def __init__(self, nz, L, pz=None):
        self.nz, self.L, self.nx = nz, L, nz * L + 1
        self.pz = pz if pz is not None else [1.0 / nz] * nz

    def nxt(self, z, ys):
        j = len(ys) + 1
        if j > self.L:
            return None
        return z * self.L + (j - 1) if not any(ys) else self.nz * self.L

    run_function = Scaffold.run_function


def check_4():
    print("check 4: Example 5.2 (one top-level input, g_i wrong at position i, i <= M <= L), exact totals")
    print("     L   M   first consistent  [L*M]   posterior draw  [2L^2 ln(M+1)/(L+1)]   mixture  [L ln(M+1)]")
    for L, M in ((1, 1), (2, 2), (3, 2), (4, 4), (6, 6), (8, 5), (10, 10), (12, 12)):
        sc = PathScaffold(1, L)
        G = [[0] * sc.nx] + [[1 if x == i - 1 else 0 for x in range(sc.nx)] for i in range(1, M + 1)]
        C = Det(sc, G, [1.0 / (M + 1)] * (M + 1))
        V0 = (1 << C.m) - 1
        order = list(range(1, M + 1)) + [0]                           # g_1, ..., g_M, f
        tf = C.total(V0, lambda V: C.step_first(V, order), "first")[0]
        td = C.total(V0, C.step_draw, "draw")[0]
        tm = C.total(V0, C.step_mix, "mix")
        assert abs(tf - L * M) < 1e-8 and td <= 2 * L * L / (L + 1) * math.log(M + 1) + 1e-9
        assert tm[1] <= L * math.log(M + 1) + 1e-9 and abs(tm[0] - tm[1]) < 1e-9   # at most one unfaithful call per run
        print(f"   {L:3d} {M:3d} {tf:14.6f} {L * M:8d} {td:14.4f} {2 * L * L / (L + 1) * math.log(M + 1):16.4f}"
              f" {tm[1]:14.4f} {L * math.log(M + 1):10.4f}")
    print("   the class of Proposition 2.5 with N_z top-level inputs (the proposition is the limit N_z -> infinity):")
    print("     L  N_z   K     sum_t E[u_t] exact   S(L,K)   bound (2L^2/(L+1)) K ln2")
    for L, nz, K in ((2, 1, 3.0), (2, 2, 3.0), (2, 3, 3.0), (3, 1, 3.0), (3, 2, 3.0), (4, 1, 5.0), (4, 2, 5.0)):
        import itertools
        sc = PathScaffold(nz, L)
        eps = 2.0 ** (-K)
        G = [[0] * sc.nx]
        for a in itertools.product(range(L), repeat=nz):
            G.append([1 if (x < nz * L and a[x // L] == x % L) else 0 for x in range(sc.nx)])
        w = [eps] + [(1 - eps) / L ** nz] * (L ** nz)
        C = Det(sc, G, w)
        td = C.total((1 << C.m) - 1, C.step_draw, "draw")[0]
        R, S = 2.0 ** K - 1, 0.0
        while R > 1e-15:
            u = R / (1 + R)
            S += u / (1 - u * (L - 1) / (2.0 * L))
            R *= 1 - 1.0 / L
        up = 2 * L * L / (L + 1) * K * LN2
        assert td <= up + 1e-9
        print(f"   {L:3d} {nz:4d} {K:4.1f} {td:16.4f} {S:14.4f} {up:14.4f}")


def check_5(trials, seed):
    rng = random.Random(seed)
    nV = 0
    worst = math.inf
    for _ in range(trials):
        C = random_class(rng, m=rng.randint(2, 7))
        L = C.sc.L
        seen, stack = set(), [(1 << C.m) - 1]
        while stack:
            V = stack.pop()
            if V in seen:
                continue
            seen.add(V)
            (pun, beta), trans, d = C.step_mix(V)
            wv = C.wV(V)
            Em = sum(q * (1.0 - C.wV(V2) / wv) for V2, q in trans.items())
            assert abs(Em - beta / L) < 1e-12                                     # E[m_t | data] = beta_t / L
            assert beta / L <= 1.0 - C.w[0] / wv + 1e-12
            for g in C.members(V):
                removed = sum(q for V2, q in trans.items() if not V2 >> g & 1)
                assert abs(removed - d[g] / L) < 1e-12                            # Pr[g removed] = d_t(g)/L
                assert d[g] >= C.u_own[g] - pun - 1e-12 and pun <= beta + 1e-12    # Step 3
                worst = min(worst, d[g] - (C.u_own[g] - beta))
            stack.extend(V2 for V2 in trans if V2 not in seen)
        nV += len(seen)
    print(f"check 5: {trials} random classes, {nV} reachable version spaces (mixture driver): "
          f"E[m_t] = beta_t/L, Pr[g removed] = d_t(g)/L and d_t(g) >= u(g) - Pr[mixture run unfaithful] >= u(g) - beta_t hold; "
          f"min slack of the last inequality = {worst:.3e}")


def check_6(seed):
    """All paths of version spaces of n rounds of mixture-driven rehearsal for small classes."""
    rng = random.Random(seed)
    print("check 6: Theorem 5.5, exact enumeration of all paths of version spaces")
    print("   class  L  m  K(bits)   n  delta   max_{g != f} E[N_n(g)]   E[Step-2 martingale]   Pr[(a) fails]   Pr[(b) fails]   paths")
    for idx in range(14):
        if idx < 8:
            C = random_class(rng, m=rng.randint(3, 5))
            L, n = C.sc.L, rng.choice([6, 8, 10])
            delta = rng.choice([0.5, 0.25, 0.1])
        else:                                                        # heavy human, small L, more rounds: (b) is not empty
            while True:
                C = random_class(rng, m=rng.randint(2, 3))
                if C.sc.L <= 2 and C.w[0] / sum(C.w) >= 0.2 and max(C.u_own) > 0.3:
                    break
            s_ = sum(C.w)
            C.w = [q / s_ for q in C.w]
            L, n, delta = C.sc.L, 36, 0.5
        K = math.log2(1.0 / C.w[0])
        cache = {}

        def one(V):
            if V not in cache:
                (pun, beta), trans, d = C.step_mix(V)
                cache[V] = (beta, trans, d)
            return cache[V]

        EN = [0.0] * C.m
        Emart = 0.0
        fail_a = fail_b = 0.0
        npaths = 0

        def rec(V, t, p, sums, sbeta, mart):
            nonlocal Emart, fail_a, fail_b, npaths
            if t == n:
                npaths += 1
                Emart += p * mart
                bad_a = bad_b = False
                for g in C.members(V):
                    EN[g] += p * math.exp(sums[g] / L)
                    if sums[g] >= L * math.log(1.0 / (C.w[g] * delta)):
                        bad_a = True
                    if C.u_own[g] >= L * (math.log(1.0 / C.w[g]) + K * LN2 + 2 * math.log(1.0 / delta)) / n:
                        bad_b = True
                fail_a += p * bad_a
                fail_b += p * bad_b
                return
            beta, trans, d = one(V)
            wv = C.wV(V)
            s2 = [sums[g] + d[g] for g in range(C.m)]
            for V2, q in trans.items():
                rec(V2, t + 1, p * q, s2, sbeta + beta, mart * (C.wV(V2) / wv) / (1.0 - beta / L))

        rec((1 << C.m) - 1, 0, 1.0, [0.0] * C.m, 0.0, 1.0)
        assert max(EN) <= 1.0 + 1e-9 and abs(EN[0] - 1.0) < 1e-9 and abs(Emart - 1.0) < 1e-9
        assert fail_a <= delta + 1e-12 and fail_b <= 2 * delta + 1e-12
        thr = min(L * (math.log(1.0 / C.w[g]) + K * LN2 + 2 * math.log(1.0 / delta)) / n for g in range(1, C.m))
        print(f"   {idx:5d} {L:2d} {C.m - 1:2d} {K:7.2f} {n:4d} {delta:6.2f} {max(EN[1:]):14.6f} {Emart:18.6f} {fail_a:16.3e} {fail_b:14.3e} {npaths:9d}"
              f"   smallest threshold of (b): {thr:.3f}, largest u(g): {max(C.u_own):.3f}")


def check_7():
    """L = 1, input z uniform on [N_z], f = 0, g_i wrong at input i only (i <= m), w(g_i) = w, w(f) = w0.
    Then d_t(g_i) = 1/N_z for all t, and (a) fails iff n/N_z >= ln(1/(w delta)) and some g_i survives."""
    print("check 7: Theorem 5.5(a) and Corollary 5.6 on a nearly tight instance (L = 1, d_t(g_i) = 1/N_z), closed form")
    print("     m     w     N_z  delta      n     Pr[(a) fails] exact    delta    E[posterior mass of Bad_c]   delta (Cor. 5.6)")
    for m, Nz, delta in ((10, 200, 0.1), (100, 2000, 0.1), (100, 2000, 0.01), (1000, 5000, 0.2)):
        w = 0.5 / m
        w0 = 0.5
        n = math.ceil(Nz * math.log(1.0 / (w * delta)))
        fail = 0.0
        for k in range(1, m + 1):                                  # inclusion-exclusion: some g_i never asked
            term = comb(m, k) * (1.0 - k / Nz) ** n
            fail += term if k % 2 else -term
            if term < 1e-18:
                break
        assert fail <= delta
        # Corollary 5.6: c = K ln 2 + ln(1/delta) = ln(1/(w0 delta)); Bad_c is the set of survivors when n/N_z >= c
        c = math.log(1.0 / (w0 * delta))
        n2 = math.ceil(Nz * c)
        # E[mass] <= E[w * #survivors]/w0, and E[#survivors] = m (1 - 1/N_z)^n2
        emass_upper = w * m * (1.0 - 1.0 / Nz) ** n2 / w0
        assert emass_upper <= delta
        print(f"   {m:5d} {w:7.4f} {Nz:5d} {delta:6.2f} {n:6d} {fail:18.6f} {delta:12.4f} {emass_upper:22.6f} {delta:14.4f}")


def check_8(trials, seed):
    """Referee's additions for the posterior-draw driver.
    (i)  High-probability form of Theorem 2.1: with prob >= 1 - delta,
         sum_{t<=n} ubar_t < (2L^2/(L+1)) (ln(W/w(f)) + ln(1/delta)),  ubar_t = E[u_t(z_t) | D_{t-1}].
         It rests on E[m_t | D_{t-1}] >= ubar_t (L+1)/(2L^2) and on the mean-1 martingale
         prod_t (1 - m_t)/(1 - E[m_t | D_{t-1}]).
    (ii) Theorem 5.5 for a rehearsal driven by posterior draws: Pr[g removed | D_{t-1}] = d_t(g)/L with d_t(g)
         the expected number of calls of the driver's run at whose inputs g is wrong, and d_t(g) >= u(g) - ubar_t.
         Hence with prob >= 1 - 2 delta every consistent g has
         u(g) < [L ln(1/(w(g) delta)) + (2L^2/(L+1)) (ln(W/w(f)) + ln(1/delta))] / n."""
    rng = random.Random(seed)
    nV = 0
    for _ in range(trials):
        C = random_class(rng, m=rng.randint(2, 7))
        L, f = C.sc.L, C.G[0]
        seen, stack = set(), [(1 << C.m) - 1]
        while stack:
            V = stack.pop()
            if V in seen:
                continue
            seen.add(V)
            wv = C.wV(V)
            (ubar, psibar), trans = C.step_draw(V)
            Em = sum(q * (1.0 - C.wV(V2) / wv) for V2, q in trans.items())
            assert Em >= psibar / L - 1e-12 and psibar >= ubar * (L + 1) / (2.0 * L) - 1e-12
            for g in C.members(V):
                d = sum(C.w[h] / wv * C.sc.pz[z] * sum(C.G[g][x] != f[x] for x in C.runs[h][z][0])
                        for h in C.members(V) for z in range(C.sc.nz))
                removed = sum(q for V2, q in trans.items() if not V2 >> g & 1)
                assert abs(removed - d / L) < 1e-12 and d >= C.u_own[g] - ubar - 1e-12
            stack.extend(V2 for V2 in trans if V2 not in seen)
        nV += len(seen)
    print(f"check 8: posterior-draw driver, {trials} random classes, {nV} reachable version spaces: E[m_t] >= E[psi_L(u_t)]/L >= "
          f"ubar_t (L+1)/(2L^2), Pr[g removed] = d_t(g)/L and d_t(g) >= u(g) - ubar_t hold")
    print("   exact enumeration of all paths (posterior-draw driver):")
    print("   class  L  m  K(bits)   n  delta   E[martingale]   Pr[sum_t ubar_t >= bound]   Pr[some consistent g violates the bound on u(g)]   paths")
    for idx in range(8):
        while True:
            C = random_class(rng, m=rng.randint(2, 4))
            if idx < 4 or (C.sc.L <= 2 and C.w[0] / sum(C.w) >= 0.2 and max(C.u_own) > 0.3):
                break
        L = C.sc.L
        n, delta = (rng.choice([6, 8, 10]), rng.choice([0.5, 0.25])) if idx < 4 else (30, 0.5)
        cap = math.log(sum(C.w) / C.w[0])
        cache = {}

        def one(V):
            if V not in cache:
                (ubar, psibar), trans = C.step_draw(V)
                wv = C.wV(V)
                Em = sum(q * (1.0 - C.wV(V2) / wv) for V2, q in trans.items())
                d = [sum(C.w[h] / wv * C.sc.pz[z] * sum(C.G[g][x] != C.G[0][x] for x in C.runs[h][z][0])
                         for h in C.members(V) for z in range(C.sc.nz)) for g in range(C.m)]
                cache[V] = (ubar, Em, trans, d)
            return cache[V]

        res = {"mart": 0.0, "f1": 0.0, "f2": 0.0, "paths": 0}

        def rec(V, t, p, sums, su, mart):
            if t == n:
                res["paths"] += 1
                res["mart"] += p * mart
                res["f1"] += p * (su >= 2.0 * L * L / (L + 1) * (cap + math.log(1.0 / delta)))
                bad = any(C.u_own[g] >= (L * math.log(1.0 / (C.w[g] * delta)) + 2.0 * L * L / (L + 1) * (cap + math.log(1.0 / delta))) / n
                          for g in C.members(V))
                res["f2"] += p * bad
                return
            ubar, Em, trans, d = one(V)
            wv = C.wV(V)
            s2 = [sums[g] + d[g] for g in range(C.m)]
            for V2, q in trans.items():
                rec(V2, t + 1, p * q, s2, su + ubar, mart * (C.wV(V2) / wv) / (1.0 - Em))

        rec((1 << C.m) - 1, 0, 1.0, [0.0] * C.m, 0.0, 1.0)
        assert abs(res["mart"] - 1.0) < 1e-9 and res["f1"] <= delta + 1e-12 and res["f2"] <= 2 * delta + 1e-12
        print(f"   {idx:5d} {L:2d} {C.m - 1:2d} {math.log2(1 / C.w[0]):7.2f} {n:4d} {delta:6.2f} {res['mart']:14.6f} {res['f1']:20.3e} {res['f2']:36.3e} {res['paths']:22d}")


if __name__ == "__main__":
    checks_1_2(4000, 1)
    check_3(300, 2)
    check_4()
    check_5(200, 3)
    check_6(4)
    check_7()
    check_8(200, 5)
    print("all assertions passed")
