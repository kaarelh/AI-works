#!/usr/bin/env python3
"""Attack on Theorem 3.3 (Protocol AB) of research/prove/lower-bounds.md.

The first referee SIMULATED Protocol AB.  Here the protocol is evaluated
EXACTLY: the law of its whole random execution (the rehearsal seeds and the
audited call of every step of type (B)) is propagated through the space of
data sets, so the failure probability of the deployed function and the largest
number of questions over all paths are exact numbers, not estimates.

For a deterministic human the data are determined by the set S of asked inputs,
so a state is (S, number of (B) steps done, a, b_all, b_X0), where
   a     = number of steps of type (A),
   b_all = number of (B) steps at which the audited answer differed from h_t,
   b_X0  = the same, counting only audits at inputs that lie in X0.

Three choices of the set X0 are attacked:
   'all'     X0 = X                       (the case the theorem certainly covers)
   'members' X0 = inputs that occur in a run answered by some member of H
   'human'   X0 = inputs that occur in a run of the human system (of the true f)
For the last two, h_t(x) for x outside X0 is an answer of largest posterior
weight (smallest answer in case of a tie).  The theorem says "a set that
contains every input Pi can produce"; the run of h_t can leave such a set,
because h_t need not be a member of H.

Checked in every instance:
 (P)  the path inequality (1-gamma)^a * gamma^b >= w(f), with b = b_X0 and with b = b_all;
 (F)  failure of the deployed function <= L K / (n_B log2(1/gamma))      [claim (2)];
 (Q)  number of questions on every path <= n_B + K ln2 / gamma            [claim (1)].
"""
import math
import random
import sys
from fractions import Fraction as F

random.seed(3303)


class Scaffold:
    def __init__(self, nx, ny, L, nseeds, pstop=0.15):
        self.nx, self.ny, self.L, self.nseeds, self.pstop = nx, ny, L, nseeds, pstop
        self.next_tab = {}

    def nxt(self, seed, hist):
        key = (seed, hist)
        if key not in self.next_tab:
            if len(hist) >= self.L or (len(hist) > 0 and random.random() < self.pstop):
                self.next_tab[key] = None
            else:
                self.next_tab[key] = random.randrange(self.nx)
        return self.next_tab[key]

    def run(self, seed, f):
        hist = ()
        xs = []
        while True:
            x = self.nxt(seed, hist)
            if x is None:
                break
            xs.append(x)
            hist = hist + (f[x],)
        return tuple(xs), hist


def reach(sc, f):
    out = set()
    for s in range(sc.nseeds):
        out |= set(sc.run(s, f)[0])
    return out


def evaluate_ab(sc, H, w, fidx, gamma, nB, X0):
    """exact evaluation.  returns dict with failure, max questions, path checks."""
    f = H[fidx]
    nx, ny, L = sc.nx, sc.ny, sc.L
    wf = w[fidx]
    post_cache = {}

    def posterior(S):
        if S not in post_cache:
            V = [k for k, g in enumerate(H) if all(g[x] == f[x] for x in S)]
            W = sum(w[k] for k in V)
            M = [[sum(w[k] for k in V if H[k][x] == y) / W for y in range(ny)] for x in range(nx)]
            split = None
            for x in sorted(X0):
                if max(M[x]) <= 1 - gamma:
                    split = x
                    break
            h = tuple(max(range(ny), key=lambda y: (M[x][y], -y)) for x in range(nx))
            post_cache[S] = (M, split, h)
        return post_cache[S]

    frun = [sc.run(s, f) for s in range(sc.nseeds)]
    states = {(frozenset(), 0, 0, 0, 0): F(1)}
    done = {}
    sum_u = F(0)
    ok_X0 = True
    ok_all = True
    max_q = 0
    while states:
        new = {}
        for (S, k, a, ball, bx0), p in states.items():
            # path inequality at every reachable state
            if (1 - gamma) ** a * gamma ** bx0 < wf:
                ok_X0 = False
            if (1 - gamma) ** a * gamma ** ball < wf:
                ok_all = False
            if k == nB:
                done[(S, k, a, ball, bx0)] = done.get((S, k, a, ball, bx0), F(0)) + p
                continue
            M, split, h = posterior(S)
            if split is not None:
                key = (S | {split}, k, a + 1, ball, bx0)
                new[key] = new.get(key, F(0)) + p
                continue
            # step of type (B)
            u = F(0)
            for s in range(sc.nseeds):
                xs, ys = sc.run(s, h)
                if (xs, ys) != frun[s]:
                    u += F(1, sc.nseeds)
                for J in range(1, L + 1):
                    q = p * F(1, sc.nseeds * L)
                    if len(xs) >= J:
                        x = xs[J - 1]
                        dis = 1 if h[x] != f[x] else 0
                        key = (S | {x}, k + 1, a, ball + dis, bx0 + (dis if x in X0 else 0))
                    else:
                        key = (S, k + 1, a, ball, bx0)
                    new[key] = new.get(key, F(0)) + q
            sum_u += p * u
        states = new
    # number of questions on a path = a + (number of (B) steps that asked) <= a + nB
    max_a = max(a for (S, k, a, ball, bx0) in done)
    max_q = max_a + nB
    K = math.log2(1 / wf)
    fail = sum_u / nB
    return dict(fail=fail, bound=L * K / (nB * math.log2(1 / gamma)),
                max_q=max_q, q_bound=nB + K * math.log(2) / gamma,
                ok_X0=ok_X0, ok_all=ok_all, K=K, max_a=max_a)


def random_instance():
    nx = random.randint(5, 9)
    ny = random.randint(2, 3)
    L = random.randint(1, 4)
    sc = Scaffold(nx, ny, L, random.randint(2, 8))
    nH = random.randint(3, 12)
    H = set()
    base = tuple(random.randrange(ny) for _ in range(nx))
    while len(H) < nH:
        if random.random() < 0.5:
            g = list(base)                      # near-copies of one function: many small patches
            for _ in range(random.randint(1, 2)):
                g[random.randrange(nx)] = random.randrange(ny)
            H.add(tuple(g))
        else:
            H.add(tuple(random.randrange(ny) for _ in range(nx)))
    H = sorted(H)
    raw = [random.randint(1, 20) for _ in H]
    tot = sum(raw) + random.randint(0, 10)       # total weight <= 1, sometimes < 1
    w = [F(r, tot) for r in raw]
    return sc, H, w


def main():
    gammas = [F(1, 3), F(1, 4), F(1, 8), F(1, 16), F(49, 100)]
    stats = {v: dict(n=0, viol_F=0, viol_Q=0, viol_PX0=0, viol_Pall=0, maxratio=0.0) for v in ('all', 'members', 'human')}
    example = None
    for trial in range(700):
        sc, H, w = random_instance()
        gamma = random.choice(gammas)
        nB = random.choice([1, 2, 5, 12])
        for fidx in random.sample(range(len(H)), min(3, len(H))):
            for variant in ('all', 'members', 'human'):
                if variant == 'all':
                    X0 = set(range(sc.nx))
                elif variant == 'members':
                    X0 = set()
                    for g in H:
                        X0 |= reach(sc, g)
                else:
                    X0 = reach(sc, H[fidx])
                res = evaluate_ab(sc, H, w, fidx, gamma, nB, X0)
                st = stats[variant]
                st['n'] += 1
                if float(res['fail']) > res['bound'] * (1 + 1e-12) + 1e-15:
                    st['viol_F'] += 1
                if res['max_q'] > res['q_bound'] + 1e-9:
                    st['viol_Q'] += 1
                if not res['ok_X0']:
                    st['viol_PX0'] += 1
                if not res['ok_all']:
                    st['viol_Pall'] += 1
                    if example is None and variant != 'all':
                        example = (variant, trial, fidx, gamma, nB)
                if res['bound'] > 0:
                    st['maxratio'] = max(st['maxratio'], float(res['fail']) / res['bound'])
    print("Protocol AB, exact evaluation on random instances (classes with unequal weights, total weight <= 1;")
    print("scaffolds whose inputs depend on the answers, with early stopping; three humans per instance)")
    print("%-9s %7s %12s %12s %16s %17s %22s" % ('X0', 'cases', 'failure>(2)', 'questions>(1)', 'path ineq, b_X0', 'path ineq, b_all', 'max failure/bound(2)'))
    for v in ('all', 'members', 'human'):
        st = stats[v]
        print("%-9s %7d %12d %12d %16d %17d %22.4f" % (v, st['n'], st['viol_F'], st['viol_Q'], st['viol_PX0'], st['viol_Pall'], st['maxratio']))
    print("columns 3 to 6 count violations.")
    assert stats['all']['viol_F'] == 0 and stats['all']['viol_Q'] == 0
    assert stats['all']['viol_PX0'] == 0 and stats['all']['viol_Pall'] == 0
    for v in ('members', 'human'):
        assert stats[v]['viol_F'] == 0 and stats[v]['viol_Q'] == 0 and stats[v]['viol_PX0'] == 0
    if example:
        print("first instance in which the path inequality with b_all fails for a smaller X0:", example)

    # ---- recipe (3) of the theorem, exact, on small instances
    print()
    print("Recipe (3): L/eps >= 16, u = log2(L/eps), gamma = u eps/L, n_B = ceil(L K/(eps (u - log2 u)))")
    print("   L   eps      K     gamma    n_B   exact failure   eps      max questions   1+2.7KL/(eps log2(L/eps))")
    random.seed(77)
    for (L, eps) in [(1, F(1, 16)), (2, F(1, 8)), (2, F(1, 16)), (4, F(1, 8)), (3, F(1, 16))]:
        for rep in range(3):
            nx = random.randint(6, 9)
            ny = 2
            sc = Scaffold(nx, ny, L, random.randint(3, 8), pstop=0.1)
            H = set()
            base = tuple(random.randrange(ny) for _ in range(nx))
            H.add(base)
            while len(H) < random.randint(5, 14):
                g = list(base)
                for _ in range(random.randint(1, 2)):
                    j = random.randrange(nx)
                    g[j] = 1 - g[j]
                H.add(tuple(g))
            H = sorted(H)
            w = [F(1, len(H))] * len(H)
            fidx = random.randrange(len(H))
            K = math.log2(len(H))
            u = math.log2(L / eps)
            gamma = F(int(round(u)), 1) * eps / L if abs(u - round(u)) < 1e-12 else F(u).limit_denominator(10 ** 6) * eps / L
            nB = max(1, math.ceil(L * K / (float(eps) * (u - math.log2(u)))))
            res = evaluate_ab(sc, H, w, fidx, gamma, nB, set(range(nx)))
            qb = 1 + 2.7 * K * L / (float(eps) * u)
            print("  %2d  %-7s %5.2f  %-7s %5d   %.6f       %.4f   %6d          %9.1f" % (L, eps, K, gamma, nB, float(res['fail']), float(eps), res['max_q'], qb))
            assert float(res['fail']) <= float(eps) + 1e-12
            assert res['max_q'] <= qb + 1e-9

    designed_example()
    print("all checks passed")


class ChainScaffold:
    """One seed.  Calls 1..9 at inputs 0..8 as long as every answer so far is 0;
    after a nonzero answer the run stops; if all nine answers are 0, call 10 is
    at input 9 (the input x* below)."""
    nx, ny, L, nseeds = 10, 2, 10, 1

    def run(self, seed, f):
        xs, ys = [], []
        for x in range(9):
            xs.append(x)
            ys.append(f[x])
            if f[x] != 0:
                return tuple(xs), tuple(ys)
        xs.append(9)
        ys.append(f[9])
        return tuple(xs), tuple(ys)


def designed_example():
    """An instance in which the path inequality of claim (1), counted over ALL
    disagreements, fails when X0 is the set of inputs that occur in runs of members
    of H: the plurality function h is not a member, its run reaches the input 9,
    which no member's run reaches, and the posterior at 9 is split 5 : 4."""
    sc = ChainScaffold()
    H = []
    for i in range(9):
        g = [0] * 10
        g[i] = 1
        g[9] = 1 if i < 4 else 0
        H.append(tuple(g))
    w = [F(1, 9)] * 9
    gamma = F(1, 8)
    X0_members = set()
    for g in H:
        X0_members |= reach(sc, g)
    print()
    print("Designed example (9 members, weight 1/9 each, gamma = 1/8, L = 10, one seed, human = member 0):")
    print("   inputs that occur in runs of members:", sorted(X0_members), "; the run of the plurality function also reaches input 9")
    for name, X0 in (("X0 = inputs of members' runs", X0_members), ("X0 = all ten inputs", set(range(10)))):
        for nB in (1, 3, 10):
            res = evaluate_ab(sc, H, w, 0, gamma, nB, X0)
            print("   %-30s n_B=%2d: failure %.5f <= bound (2) %.5f ; max questions %d <= %.2f ; path inequality with b_X0: %s, with b_all: %s"
                  % (name, nB, float(res['fail']), res['bound'], res['max_q'], res['q_bound'],
                     "holds" if res['ok_X0'] else "FAILS", "holds" if res['ok_all'] else "FAILS"))
            assert float(res['fail']) <= res['bound'] + 1e-12 and res['max_q'] <= res['q_bound'] + 1e-9 and res['ok_X0']
    print("   (with b_all the product is (7/8)^1 (1/8)^1 = 7/64 < 1/9 = w(f): the audit at input 9 removed only 5/9 of the weight)")


if __name__ == "__main__":
    main()
