#!/usr/bin/env python3
"""Attack on Lemma 1.5, Theorem 1.6, Corollary 1.7 and Lemma 1.10 of
research/prove/lower-bounds.md by exact computation on random small instances.

The prover and the first referee tested the patch-family lemma only on needle
classes with the OR scaffold.  Here the lemma is tested in the generality in
which it is stated:

  * arbitrary functions f0 and patches f_i (random values on random disjoint sets),
  * scaffolds whose inputs depend on the answers, with internal randomness and
    early stopping, and with an arbitrary outcome map,
  * randomised adaptive protocols (random decision tables),
  * the deployed system that is BEST for the protocol (the Bayes rule for the
    prior of the lemma), so that the left side is as small as the protocol allows.

Part A: Lemma 1.10(1) and (2), exact rational arithmetic.
Part B: Lemma 1.5 / Theorem 1.6(1),(2) and Corollary 1.7 for stochastic
        samplers that agree on a set A: exact transcript laws.

Everything is exact (fractions.Fraction).  The script stops at the first
violated inequality.
"""
import itertools
import random
import sys
from fractions import Fraction as F

random.seed(20261115)


# ----------------------------------------------------------------------------
# scaffolds
# ----------------------------------------------------------------------------
class Scaffold:
    """A random scaffold: (z, rho) uniform on a finite set, next_j a random table
    of the history, out a random table of the history."""

    def __init__(self, nx, ny, L, nseeds, nout, adaptive=True, pstop=0.15):
        self.nx, self.ny, self.L, self.nseeds, self.nout = nx, ny, L, nseeds, nout
        self.adaptive = adaptive
        self.pstop = pstop
        self.next_tab = {}
        self.out_tab = {}

    def nxt(self, seed, hist):
        key = (seed, hist if self.adaptive else len(hist))
        if key not in self.next_tab:
            if len(hist) >= self.L:
                self.next_tab[key] = None
            elif len(hist) > 0 and random.random() < self.pstop:
                self.next_tab[key] = None
            else:
                self.next_tab[key] = random.randrange(self.nx)
        return self.next_tab[key]

    def out(self, seed, hist):
        key = (seed, hist)
        if key not in self.out_tab:
            self.out_tab[key] = random.randrange(self.nout)
        return self.out_tab[key]

    def run(self, seed, f):
        """run with the function f (a tuple) answering; returns (inputs, outcome)."""
        hist = ()
        xs = []
        while True:
            x = self.nxt(seed, hist)
            if x is None:
                break
            xs.append(x)
            hist = hist + (f[x],)
        return tuple(xs), self.out(seed, hist)


# ----------------------------------------------------------------------------
# protocols
# ----------------------------------------------------------------------------
class Protocol:
    """A randomised adaptive protocol: seed r uniform on range(nr); at step t the
    question is a random table of (r, answers so far); None = no question."""

    def __init__(self, nx, T, nr, pskip=0.3):
        self.nx, self.T, self.nr, self.pskip = nx, T, nr, pskip
        self.tab = {}

    def q(self, r, ys):
        key = (r, ys)
        if key not in self.tab:
            self.tab[key] = None if random.random() < self.pskip else random.randrange(self.nx)
        return self.tab[key]

    def transcript(self, r, f):
        ys = ()
        qs = []
        for _ in range(self.T):
            x = self.q(r, ys)
            qs.append(x)
            ys = ys + ((f[x],) if x is not None else (None,))
        return tuple(qs), ys


def part_a(trials=4000):
    worst1 = None
    worst2 = None
    n_checked = 0
    for trial in range(trials):
        nx = random.randint(4, 9)
        ny = random.randint(2, 3)
        L = random.randint(1, 4)
        nseeds = random.randint(2, 6)
        nout = random.randint(2, 3)
        sc = Scaffold(nx, ny, L, nseeds, nout, adaptive=(trial % 3 != 0))
        f0 = tuple(random.randrange(ny) for _ in range(nx))
        # disjoint patch sets
        xs = list(range(nx))
        random.shuffle(xs)
        N = random.randint(1, min(4, nx))
        cuts = sorted(random.sample(range(1, nx), N - 1)) if N > 1 else []
        cuts = [0] + cuts + [random.randint(cuts[-1] + 1 if cuts else 1, nx)]
        Bs = [xs[cuts[i]:cuts[i + 1]] for i in range(N)]
        fs = []
        for Bi in Bs:
            g = list(f0)
            for x in Bi:
                g[x] = random.randrange(ny)          # may or may not differ
            fs.append(tuple(g))
        # outcomes
        o0 = [sc.run(s, f0)[1] for s in range(nseeds)]
        oi = [[sc.run(s, fs[i])[1] for s in range(nseeds)] for i in range(N)]
        Delta = [F(sum(1 for s in range(nseeds) if oi[i][s] != o0[s]), nseeds) for i in range(N)]
        M = max(sum(1 for i in range(N) if oi[i][s] != o0[s]) for s in range(nseeds))
        M = max(M, 1)  # the lemma allows any M >= the count; M >= 1 keeps weights meaningful
        for _ in range(6):
            T = random.randint(0, 4)
            nr = random.randint(1, 4)
            pr = Protocol(nx, T, nr)
            # f0-path
            S = []
            for r in range(nr):
                qs, _ = pr.transcript(r, f0)
                S.append(set(x for x in qs if x is not None))
            n_exp = F(sum(sum(1 for x in pr.transcript(r, f0)[0] if x is not None) for r in range(nr)), nr)
            pi = [F(sum(1 for r in range(nr) if S[r] & set(Bs[i])), nr) for i in range(N)]
            assert sum(pi) <= n_exp, "sum of pi exceeds n"
            # transcripts under every member
            members = [f0] + fs
            tr = [[pr.transcript(r, g) for r in range(nr)] for g in members]
            # ---- (2): Bayes-optimal deployed system for prior (M,1,...,1)/(N+M)
            prior = [F(M, N + M)] + [F(1, N + M)] * N
            total = F(0)
            for r in range(nr):
                for s in range(nseeds):
                    # group members by transcript; for each transcript the best outcome
                    groups = {}
                    for k, g in enumerate(members):
                        groups.setdefault(tr[k][r], []).append(k)
                    for D, ks in groups.items():
                        true_out = {k: (o0[s] if k == 0 else oi[k - 1][s]) for k in ks}
                        mass = sum(prior[k] for k in ks)
                        best = max(sum(prior[k] for k in ks if true_out[k] == o) for o in range(nout))
                        total += F(1, nr * nseeds) * (mass - best)
            lhs2 = total
            rhs2 = sum((1 - pi[i]) * Delta[i] for i in range(N)) / (N + M)
            assert lhs2 >= rhs2, ("Lemma 1.10(2) violated", lhs2, rhs2)
            rhs2b = (N - n_exp) * min(Delta) / (N + M)
            assert rhs2 >= rhs2b, ("second inequality of Lemma 1.10(2) violated", rhs2, rhs2b)
            if rhs2 > 0:
                ratio = lhs2 / rhs2
                if worst2 is None or ratio < worst2:
                    worst2 = ratio
            # ---- (1): for each i, best deployed system for the pair {f0, f_i}
            for i in range(N):
                tot = F(0)
                for r in range(nr):
                    same = tr[0][r] == tr[i + 1][r]
                    for s in range(nseeds):
                        if same and oi[i][s] != o0[s]:
                            tot += F(1, nr * nseeds)      # one of the two must fail
                rhs1 = (1 - pi[i]) * Delta[i]
                assert tot >= rhs1, ("Lemma 1.10(1) violated", tot, rhs1)
                if rhs1 > 0:
                    ratio = tot / rhs1
                    if worst1 is None or ratio < worst1:
                        worst1 = ratio
            n_checked += 1
    print("Part A: Lemma 1.10 on %d random (scaffold, class, protocol) triples" % n_checked)
    print("   scaffolds: adaptive in 2 of 3 trials, with early stopping; outcomes arbitrary")
    print("   smallest ratio  min_g [Fail(f0)+Fail(f_i)] / ((1-pi_i) Delta_i)        = %s" % (worst1,))
    print("   smallest ratio  min_g [weighted average failure] / right side of (2)    = %s" % (worst2,))
    print("   (a ratio 1 means the lemma is attained; no ratio below 1 was found)")


# ----------------------------------------------------------------------------
# Part B: stochastic samplers
# ----------------------------------------------------------------------------
def rand_dist(ny, denom=6):
    while True:
        w = [random.randint(0, denom) for _ in range(ny)]
        if sum(w) > 0:
            return [F(a, sum(w)) for a in w]


def transcript_law(pr, P, nx, ny):
    """exact law of (r, D) when the sampler P answers; dict transcript -> prob,
    and the probability gamma_set(A) is computed by the caller."""
    law = {}
    for r in range(pr.nr):
        stack = [((), (), F(1, pr.nr))]
        while stack:
            qs, ys, p = stack.pop()
            if len(qs) == pr.T:
                law[(r, qs, ys)] = law.get((r, qs, ys), F(0)) + p
                continue
            x = pr.q(r, ys)
            if x is None:
                stack.append((qs + (None,), ys + (None,), p))
            else:
                for y in range(ny):
                    if P[x][y] > 0:
                        stack.append((qs + (x,), ys + (y,), p * P[x][y]))
    return law


def part_b(trials=3000):
    worst = None
    worst17 = None
    for trial in range(trials):
        nx = random.randint(3, 6)
        ny = random.randint(2, 3)
        A = set(random.sample(range(nx), random.randint(1, nx - 1)))
        P = [rand_dist(ny) for _ in range(nx)]
        P2 = [P[x] if x in A else rand_dist(ny) for x in range(nx)]
        T = random.randint(1, 4)
        pr = Protocol(nx, T, random.randint(1, 3), pskip=0.2)
        law1 = transcript_law(pr, P, nx, ny)
        law2 = transcript_law(pr, P2, nx, ny)
        gam1 = sum(p for (r, qs, ys), p in law1.items() if any(x is not None and x not in A for x in qs))
        gam2 = sum(p for (r, qs, ys), p in law2.items() if any(x is not None and x not in A for x in qs))
        assert gam1 == gam2, ("gamma differs between P and P'", gam1, gam2)
        keys = set(law1) | set(law2)
        tv = sum(abs(law1.get(k, F(0)) - law2.get(k, F(0))) for k in keys) / 2
        assert tv <= gam1, ("Lemma 1.5 violated: TV of transcript laws exceeds gamma", tv, gam1)
        if gam1 > 0:
            ratio = tv / gam1
            worst = ratio if worst is None else max(worst, ratio)
        # Theorem 1.6(4) for functions and Corollary 1.7: deterministic members f, f'
        f = tuple(random.randrange(ny) for _ in range(nx))
        xstar = random.choice([x for x in range(nx) if x not in A])
        f2 = list(f)
        for x in range(nx):
            if x not in A:
                f2[x] = random.randrange(ny)
        f2[xstar] = (f[xstar] + 1) % ny
        f2 = tuple(f2)
        Pf = [[F(1) if y == f[x] else F(0) for y in range(ny)] for x in range(nx)]
        Pf2 = [[F(1) if y == f2[x] else F(0) for y in range(ny)] for x in range(nx)]
        l1 = transcript_law(pr, Pf, nx, ny)
        l2 = transcript_law(pr, Pf2, nx, ny)
        gam = sum(p for (r, qs, ys), p in l1.items() if any(x is not None and x not in A for x in qs))
        # a random deployed answer law at xstar on Y u {bot}, as a function of the transcript
        ans = {}

        def answer_law(k):
            if k not in ans:
                ans[k] = rand_dist(ny + 1)      # last coordinate = bot
            return ans[k]
        R = [sum(p * answer_law(k)[y] for k, p in l1.items()) for y in range(ny + 1)]
        R2 = [sum(p * answer_law(k)[y] for k, p in l2.items()) for y in range(ny + 1)]
        fail_f = 1 - R[f[xstar]]
        fail_f2 = 1 - R2[f2[xstar]]
        assert fail_f + fail_f2 >= 1 - gam, ("Theorem 1.6(4) violated", fail_f, fail_f2, gam)
        s_f = 1 - R[f[xstar]] - R[ny]
        s_f2 = 1 - R2[f2[xstar]] - R2[ny]
        bound = 1 - gam - min(R[ny], R2[ny])
        assert s_f + s_f2 >= bound, ("Corollary 1.7 violated", s_f, s_f2, bound)
        slack = (s_f + s_f2) - bound
        worst17 = slack if worst17 is None else min(worst17, slack)
    print("Part B: Lemma 1.5, Theorem 1.6(4), Corollary 1.7 on %d random instances" % trials)
    print("   (stochastic samplers that agree on A; randomised adaptive protocols; exact laws)")
    print("   gamma is the same under P and P' in every instance")
    print("   largest ratio TV(transcript laws)/gamma = %s   (the lemma says <= 1)" % (worst,))
    print("   smallest slack in Corollary 1.7          = %s   (the corollary says >= 0)" % (worst17,))


if __name__ == "__main__":
    part_a()
    part_b()
    print("all checks passed")
