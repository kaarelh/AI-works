#!/usr/bin/env python3
"""Referee's independent check of Theorem 3.3 (Protocol AB) of
research/prove/lower-bounds.md, and of two additions made in the report
verification/lower-bounds-check.md.

The prover simulated Protocol AB only on the block class, with a shortcut
(a question whose answer is known is not asked) and a non-adaptive scaffold.
Here the protocol is implemented literally (X0 = X, steps (A) and (B) exactly
as in the statement), with the posterior computed exactly, on random finite
classes with non-uniform weights of total 0.9 and on scaffolds that are
adaptive (the next input depends on the previous answer), have internal
randomness and may stop early.

Part A checks, for Theorem 3.3:
  (1) on every path  a ln(1/(1-gamma)) + b ln(1/gamma) <= K ln 2;
  (2) E[failure of the deployed h] <= L K / (n_B log2(1/gamma)), where the
      failure of each h_t (probability over (z, rho) that its run differs from
      the run of f) is computed exactly by enumeration;
  and the referee's addition (report, entry on Theorem 3.3):
  (2') the same bound holds for the EXPECTED NUMBER of calls of the deployed
      run at whose input h differs from f ("faults"), because the audited call
      is uniform among L and a disagreement is exactly a fault at that call.
Part B checks recipe (3) of Theorem 3.3 on the same kind of instance.
Part C is the referee's supplement to Corollary 3.4(5): a class of K = d bits
  on which Protocol R (rehearsal with the Bayes mixture) needs about
  0.1 K L / eps questions, while d = K chosen questions give failure 0.
"""
import math, random
from math import comb, log, log2
import numpy as np


# ------------------------------------------------------------------ instances
def make_instance(rng, nx, ny, nh, nr, L, stop_prob=0.08):
    base = [rng.randrange(ny) for _ in range(nx)]
    H = [tuple(base)]
    seen = {tuple(base)}
    while len(H) < nh:
        g = list(base)
        kind = rng.random()
        if kind < 0.6:                                   # a patch at 1 to 3 inputs
            for x in rng.sample(range(nx), rng.randint(1, 3)):
                g[x] = rng.randrange(ny)
        elif kind < 0.9:                                 # a patch on an interval
            lo = rng.randrange(nx); hi = min(nx, lo + rng.randint(2, max(2, nx // 2)))
            for x in range(lo, hi):
                g[x] = rng.randrange(ny)
        else:                                            # an unrelated function
            g = [rng.randrange(ny) for _ in range(nx)]
        g = tuple(g)
        if g not in seen:
            seen.add(g); H.append(g)
    w = [rng.random() ** 3 + 1e-3 for _ in H]
    s = sum(w) / 0.9
    w = [v / s for v in w]                               # total weight 0.9 < 1
    T = [[[(-1 if rng.random() < stop_prob else rng.randrange(nx)) for _ in range(ny)]
          for _ in range(nx)] for _ in range(nr)]
    return np.array(H), np.array(w), T


def run_of(g, z, r, T, L):
    """Inputs of the run in which the function g answers every call."""
    xs = []
    x = z
    for _ in range(L):
        xs.append(x)
        x = T[r][x][g[x]]
        if x < 0:
            break
    return xs


class Scaffold:
    def __init__(self, T, nx, L):
        self.T, self.nx, self.nr, self.L = T, nx, len(T), L
        self.cache = {}

    def stats(self, h, f):
        """(u, v): probability that the run of h differs from the run of f, and the
        expected number of calls of the run of h at whose input h differs from f."""
        key = (tuple(h), tuple(f))
        if key not in self.cache:
            diff = 0; faults = 0
            for z in range(self.nx):
                for r in range(self.nr):
                    xs = run_of(h, z, r, self.T, self.L)
                    k = sum(1 for x in xs if h[x] != f[x])
                    faults += k
                    # the runs differ iff some call of the h-run is a fault
                    # (cross-checked against the direct comparison below)
                    xf = run_of(f, z, r, self.T, self.L)
                    differ = (xs != xf) or any(h[x] != f[x] for x in xs)
                    assert differ == (k > 0)
                    diff += differ
            tot = self.nx * self.nr
            self.cache[key] = (diff / tot, faults / tot)
        return self.cache[key]


# ------------------------------------------------------------------ Protocol AB
def protocol_AB(H, w, onehot, f_idx, scaf, gamma, n_B, rng):
    """Literal implementation of Protocol AB(gamma, n_B) with X0 = X."""
    nh, nx = H.shape
    f = H[f_idx]
    alive = np.ones(nh, dtype=bool)
    a = b = questions = 0
    us = []; vs = []
    logW = [math.log(w.sum())]
    while len(us) < n_B:
        wa = w * alive
        W = wa.sum()
        M = np.tensordot(wa, onehot, axes=(0, 0)) / W          # (nx, ny)
        top = M.max(axis=1)
        split = np.nonzero(top <= 1 - gamma)[0]
        if len(split) > 0:                                     # step (A)
            x = int(split[0])
            a += 1; questions += 1
            alive &= (H[:, x] == f[x])
            factor = (w * alive).sum() / W
            assert factor <= 1 - gamma + 1e-12
            continue
        h = M.argmax(axis=1)                                   # step (B)
        assert np.all(top > 1 - gamma)
        u, v = scaf.stats(h, f)
        us.append(u); vs.append(v)
        z = rng.randrange(nx); r = rng.randrange(scaf.nr)
        xs = run_of(h, z, r, scaf.T, scaf.L)
        J = rng.randrange(scaf.L)
        if J < len(xs):
            x = xs[J]
            questions += 1
            if h[x] != f[x]:
                b += 1
                alive &= (H[:, x] == f[x])
                factor = (w * alive).sum() / W
                assert factor < gamma + 1e-12
            else:
                alive &= (H[:, x] == f[x])
    assert alive[f_idx]
    return a, b, questions, us, vs


def part_A():
    print("A. Protocol AB, literal, on random classes with adaptive scaffolds")
    print("   columns: K = log2(1/w(f)); max over trials of [a ln(1/(1-g)) + b ln(1/g)]/(K ln 2) (claim (1): <= 1);")
    print("   mean failure of the deployed h; mean number of faults of its run; the bound L K/(n_B log2(1/g));")
    print("   identity check: mean of sum_t v_t / L against mean of b (equal in expectation).")
    rng = random.Random(20261115)
    rows = 0
    for (nx, ny, nh, nr, L, gamma, n_B, trials) in (
            (12, 3, 60, 3, 4, 0.20, 60, 300),
            (20, 3, 150, 2, 6, 0.10, 120, 200),
            (16, 2, 100, 4, 8, 0.25, 80, 300),
            (24, 4, 200, 2, 5, 0.05, 150, 150),
            (10, 2, 40, 2, 12, 0.30, 100, 300)):
        H, w, T = make_instance(rng, nx, ny, nh, nr, L)
        onehot = (H[:, :, None] == np.arange(ny)[None, None, :]).astype(float)
        scaf = Scaffold(T, nx, L)
        for f_idx in (0, int(np.argmin(w)), rng.randrange(nh)):
            K = log2(1 / w[f_idx])
            worst1 = 0.0; fail = []; faults = []; sv = []; bs = []; qs = []
            for _ in range(trials):
                a, b, q, us, vs = protocol_AB(H, w, onehot, f_idx, scaf, gamma, n_B, rng)
                lhs = a * log(1 / (1 - gamma)) + b * log(1 / gamma)
                assert lhs <= K * log(2) + 1e-9
                worst1 = max(worst1, lhs / (K * log(2)))
                assert q <= n_B + K * log(2) / gamma + 1e-9
                assert all(u <= v + 1e-12 for u, v in zip(us, vs))
                fail.append(sum(us) / n_B); faults.append(sum(vs) / n_B)
                sv.append(sum(vs) / L); bs.append(b); qs.append(q)
            bound = L * K / (n_B * log2(1 / gamma))
            mf, mv = np.mean(fail), np.mean(faults)
            se = np.std(faults) / math.sqrt(trials)
            assert mf <= bound and mv <= bound + 3 * se
            idgap = abs(np.mean(sv) - np.mean(bs))
            idse = math.sqrt(np.var(sv) / trials + np.var(bs) / trials) + 1e-12
            assert idgap <= 4 * idse + 1e-9, (idgap, idse)
            rows += 1
            print(f"   nx={nx:2d} |H|={nh:3d} L={L:2d} g={gamma:.2f} n_B={n_B:3d}  K={K:5.2f}  (1): {worst1:.3f}"
                  f"  fail {mf:.4f}  faults {mv:.4f}  bound {bound:.4f}  sum v/L {np.mean(sv):.3f} vs b {np.mean(bs):.3f}")
    print(f"   {rows} instances; claims (1), (2) and (2') hold in all of them")
    print()


def part_B():
    print("B. Recipe (3) of Theorem 3.3: u = log2(L/eps) >= 4, gamma = u eps/L, n_B = ceil(L K/(eps (u - log2 u)))")
    rng = random.Random(7)
    for (nx, ny, nh, nr, L, eps, trials) in ((14, 3, 80, 2, 4, 0.25, 40), (18, 2, 120, 2, 8, 0.25, 30),
                                             (12, 3, 60, 3, 16, 0.5, 30)):
        H, w, T = make_instance(rng, nx, ny, nh, nr, L)
        onehot = (H[:, :, None] == np.arange(ny)[None, None, :]).astype(float)
        scaf = Scaffold(T, nx, L)
        f_idx = int(np.argmin(w))
        K = log2(1 / w[f_idx])
        u = log2(L / eps); assert u >= 4
        gamma = u * eps / L
        n_B = math.ceil(L * K / (eps * (u - log2(u))))
        fails = []; qmax = 0
        for _ in range(trials):
            a, b, q, us, vs = protocol_AB(H, w, onehot, f_idx, scaf, gamma, n_B, rng)
            fails.append(sum(us) / n_B); qmax = max(qmax, q)
        qbound = 1 + (u / (u - log2(u)) + log(2)) * K * L / (eps * u)
        assert qmax <= qbound and np.mean(fails) <= eps
        print(f"   L={L:2d} eps={eps:.2f} K={K:5.2f} gamma={gamma:.3f} n_B={n_B:4d}: questions max {qmax:4d}"
              f" <= {qbound:7.1f} <= 1 + 2.7 K L/(eps u) = {1 + 2.7 * K * L / (eps * u):7.1f};"
              f" failure {np.mean(fails):.4f} <= eps")
    print()


# ------------------------------------------------------------------ Part C
def R_failure_exact(d, L, q, n):
    """Rare-points class: inputs x0 and 1..d; every call is x0 with probability 1-q and a
    uniform point of [d] otherwise; the class is all 2^d functions [d] -> {0,1} (all are 0
    at x0), uniform weights, K = d.  Protocol R asks one call of each rehearsal run, i.e.
    one draw from the per-call law; the posterior is uniform on the values at the points
    not asked so far, so the mixture is wrong with probability 1/2 at such a point and
    right elsewhere.  Returns Pr[the run of M^(T) is unfaithful], T uniform on [n]."""
    tot = 0.0
    for t in range(1, n + 1):
        s = (1 - q / d) ** (t - 1)                      # Pr[a given point is unseen before round t]
        # |U_t| ~ Bin(d, s); E[1 - (1 - q|U|/(2d))^L]
        e = sum(comb(d, k) * s ** k * (1 - s) ** (d - k) * (1 - (1 - q * k / (2 * d)) ** L)
                for k in range(d + 1))
        tot += e
    return tot / n


def R_failure_mc(d, L, q, n, rng, reps=4000):
    acc = 0.0
    for _ in range(reps):
        T = rng.randrange(1, n + 1)
        seen = set()
        for _ in range(T - 1):
            if rng.random() < q:
                seen.add(rng.randrange(d))
        unseen = d - len(seen)
        acc += 1 - (1 - q * unseen / (2 * d)) ** L
    return acc / reps


def lazy_failure_curve(d, L, q, nmax):
    """Rare-points class, variant of Remark A3 (ask the first call of the rehearsal run whose
    input is split, here: an unseen rare point; otherwise a uniform call, which teaches nothing).
    The number k of unseen points is a pure death chain: a round finds one with probability
    1 - (1 - q k/d)^L.  The deployed plurality function answers 0 at unseen points (tie), the
    human is uniform on the class, so the run is unfaithful iff it visits an unseen point at which
    f is 1: probability E[1 - (1 - q W/d)^L], W ~ Bin(k, 1/2).  Returns F_t, t = 1..nmax (exact)."""
    g = [sum(comb(k, j) * 0.5 ** k * (1 - (1 - q * j / d) ** L) for j in range(k + 1)) for k in range(d + 1)]
    hit = [1 - (1 - q * k / d) ** L for k in range(d + 1)]
    pi = np.zeros(d + 1); pi[d] = 1.0
    garr = np.array(g); harr = np.array(hit)
    F = np.zeros(nmax)
    for t in range(nmax):
        F[t] = float(pi @ garr)
        move = pi * harr
        pi = pi - move
        pi[:-1] += move[1:]
    return F


def part_C():
    print("C. Supplement to Corollary 3.4(5) (report, Proposition A1): the rare-points class, q = 4 eps/L, K = d bits")
    print("   least number n of rounds with Pr[deployed run unfaithful] <= eps (exact formulas) for Protocol R and for")
    print("   the variant of Remark A3; lower bound for every protocol whose n questions are draws from the per-call law:")
    print("   ln(2(1-2eps)) (L d/(4 eps) - 1); R1's upper bound L K ln 2/eps; chosen questions: d.")
    print("     d    L   eps     R: least n   lower bound   L K ln2/eps   n eps/(K L)   A3: least n   chosen")
    rng = random.Random(3)
    for d, L, eps in ((8, 4, 0.125), (8, 8, 0.125), (16, 4, 0.125), (16, 16, 0.0625), (32, 8, 0.0625),
                      (32, 16, 0.03125)):
        q = 4 * eps / L
        lo, hi = 1, 2
        while R_failure_exact(d, L, q, hi) > eps:
            hi *= 2
        while hi - lo > 1:                               # failure is decreasing in n
            mid = (lo + hi) // 2
            if R_failure_exact(d, L, q, mid) > eps:
                lo = mid
            else:
                hi = mid
        n_star = hi if R_failure_exact(d, L, q, lo) > eps else lo
        lb = log(2 * (1 - 2 * eps)) * (L * d / (4 * eps) - 1)
        ub = L * d * log(2) / eps
        assert lb <= n_star <= ub + 1
        # the inequality behind the bound, at n_star: failure >= 2 eps (1 - 2 eps)(1 - q/d)^n
        assert R_failure_exact(d, L, q, n_star) >= 2 * eps * (1 - 2 * eps) * (1 - q / d) ** n_star
        mc = R_failure_mc(d, L, q, n_star, rng)
        assert abs(mc - R_failure_exact(d, L, q, n_star)) < 0.01
        F = lazy_failure_curve(d, L, q, n_star)
        running = np.cumsum(F) / np.arange(1, n_star + 1)
        n_lazy = int(np.nonzero(running <= eps)[0][0]) + 1
        a3_bound = d * L / (eps * log2(L / log(L)))      # Remark A3: K L/(eps log2(L/ln L)) rounds suffice
        assert n_lazy <= a3_bound
        print(f"   {d:3d}  {L:3d}  {eps:.4f}   {n_star:8d}     {lb:9.1f}    {ub:9.1f}       {n_star * eps / (d * L):.3f}"
              f"      {n_lazy:8d}   {d:6d}")
    print("   (for Protocol R the Monte Carlo simulation of the rounds agrees with the exact formula within 0.01)")
    print()


# ------------------------------------------------------------------ Part D
def part_D():
    """Protocol R on the block class of Theorem 3.1 (uniform weights).  A round asks a uniformly
    random cell of a uniformly random block.  In a block whose needle has not been found and in
    which k cells have been asked, the posterior is uniform on the other N - k cells, so the
    mixture's draw at a call is wrong with probability phi_k = 2 (N-k-1) / (N (N-k)) (the call is
    the needle and the draw says 0, or it is another unasked cell and the draw says 1); in a block
    whose needle was found the mixture is exact.  F_t := Pr[run of M^(t) unfaithful | data]."""
    print("D. Protocol R on the block class (N = L/(2 delta)): least n with Pr[deployed run unfaithful] <= delta")
    print("   (simulation of the rounds; the failure given the data is computed exactly)")
    print("     m     N    L   delta    least n    n/(m N)   Thm 3.1: (1-10d) m L/(8d)   R1: L K ln2/delta")
    rng = random.Random(11)
    for m, N, L in ((16, 128, 4), (32, 256, 8), (64, 256, 4)):
        delta = L / (2 * N)
        K = m * log2(N)
        horizon = int(4 * m * N)
        reps = 12
        avgF = np.zeros(horizon)
        for _ in range(reps):
            needle = [rng.randrange(N) for _ in range(m)]
            asked = [set() for _ in range(m)]
            found = [False] * m
            contrib = [1 - (1 - 2 * (N - 1) / (N * N)) ** L] * m     # per block, k = 0
            tot = sum(contrib)
            for t in range(horizon):
                avgF[t] += tot / m
                j = rng.randrange(m); c = rng.randrange(N)
                if found[j] or c in asked[j]:
                    continue
                if c == needle[j]:
                    found[j] = True; new = 0.0
                else:
                    asked[j].add(c); k = len(asked[j])
                    new = 1 - (1 - 2 * (N - k - 1) / (N * (N - k))) ** L
                tot += new - contrib[j]; contrib[j] = new
        avgF /= reps
        running = np.cumsum(avgF) / np.arange(1, horizon + 1)        # failure with T uniform on [n]
        ok = np.nonzero(running <= delta)[0]
        assert len(ok) > 0
        n_star = int(ok[0]) + 1
        lb = (1 - 10 * delta) * m * L / (8 * delta)
        ub = L * K * log(2) / delta
        assert lb <= n_star <= ub
        print(f"   {m:3d}  {N:4d}  {L:3d}  {delta:.4f}  {n_star:8d}    {n_star / (m * N):6.2f}      {lb:10.0f}"
              f"               {ub:10.0f}")
    print("   So on the block class Protocol R needs a constant times m N = K L/(2 delta log2(L/(2 delta))) questions:")
    print("   the block class does not separate Protocol R from the best protocol by more than a constant.")
    print()


# ------------------------------------------------------------------ Part E
def protocol_lazy(H, w, onehot, f_idx, scaf, gamma, n, rng):
    """Referee's variant (report, Remark A3): every question is a call of the protocol's own
    rehearsal run.  Step t: h := plurality function of the posterior (ties by argmax); draw
    (z, rho) and run the scaffold with h; if the run has a call whose input is split
    (max_y M(y|x) <= 1 - gamma), ask the first such call (type A); otherwise ask a uniformly
    chosen call J (type B).  n steps in all; deploy h of a uniformly chosen step."""
    nh, nx = H.shape
    f = H[f_idx]
    alive = np.ones(nh, dtype=bool)
    a = b = 0
    us = []
    for _ in range(n):
        wa = w * alive
        W = wa.sum()
        M = np.tensordot(wa, onehot, axes=(0, 0)) / W
        top = M.max(axis=1)
        h = M.argmax(axis=1)
        us.append(scaf.stats(h, f)[0])
        z = rng.randrange(nx); r = rng.randrange(scaf.nr)
        xs = run_of(h, z, r, scaf.T, scaf.L)
        split = [x for x in xs if top[x] <= 1 - gamma]
        if split:
            x = split[0]; a += 1
            alive &= (H[:, x] == f[x])
            assert (w * alive).sum() / W <= 1 - gamma + 1e-12
        else:
            J = rng.randrange(scaf.L)
            if J < len(xs):
                x = xs[J]
                if h[x] != f[x]:
                    b += 1
                    alive &= (H[:, x] == f[x])
                    assert (w * alive).sum() / W < gamma + 1e-12
                else:
                    alive &= (H[:, x] == f[x])
    return a, b, us


def part_E():
    print("E. Variant that asks only calls of its own rehearsal runs (report, Remark A3), gamma = ln L / L:")
    print("   claims: on every path a ln(1/(1-gamma)) + b ln(1/gamma) <= K ln 2, and")
    print("   Pr[deployed run unfaithful] <= (K ln 2/n) max{1/ln(1/(1-gamma)), L/ln(1/gamma)} <= K L/(n log2(L/ln L))")
    rng = random.Random(99)
    for (nx, ny, nh, nr, L, n, trials) in ((12, 3, 60, 3, 4, 400, 100), (20, 3, 150, 2, 6, 600, 80),
                                           (16, 2, 100, 4, 8, 500, 100), (10, 2, 40, 2, 12, 600, 100),
                                           (14, 3, 80, 2, 24, 500, 60)):
        gamma = log(L) / L
        H, w, T = make_instance(rng, nx, ny, nh, nr, L)
        onehot = (H[:, :, None] == np.arange(ny)[None, None, :]).astype(float)
        scaf = Scaffold(T, nx, L)
        for f_idx in (int(np.argmin(w)), rng.randrange(nh)):
            K = log2(1 / w[f_idx])
            fails = []; worst = 0.0; worst_obj = 0.0
            cap = K * log(2) * max(1 / log(1 / (1 - gamma)), L / log(1 / gamma))
            for _ in range(trials):
                a, b, us = protocol_lazy(H, w, onehot, f_idx, scaf, gamma, n, rng)
                lhs = a * log(1 / (1 - gamma)) + b * log(1 / gamma)
                assert lhs <= K * log(2) + 1e-9
                assert a + L * b <= cap + 1e-9               # the linear-programming step
                worst = max(worst, lhs / (K * log(2)))
                fails.append(sum(us) / n)
            bound = cap / n
            final = K * L / (n * log2(L / log(L)))
            assert np.mean(fails) <= bound <= final + 1e-12
            print(f"   nx={nx:2d} |H|={nh:3d} L={L:2d} gamma={gamma:.3f} n={n:3d} K={K:5.2f}: failure {np.mean(fails):.4f}"
                  f" <= {bound:.4f} <= {final:.4f};  Protocol R's bound L K ln2/n = {L * K * log(2) / n:.4f}")
    print()


if __name__ == "__main__":
    part_A(); part_B(); part_C(); part_D(); part_E()
    print("all checks passed")
