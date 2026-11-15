#!/usr/bin/env python3
"""Checks for Section 4 of research/prove-c/shift-abstain.md (Ab1, the threshold rule).

(1) Theorem 4.1: on every sequence of asked inputs,
        W*log2(1/eta) + A*log2(1/(1-eta)) <= log2(Wtot/w(f)),
    W = rounds at which the rule would answer wrongly, A = rounds at which it abstains.
    Exhaustive over all orders of the inputs for random small classes with random weights.
(2) Example 4.2: classes that attain each count.
(3) Proposition 4.3(b): threshold rule with audits at rate q on an adaptive input rule.
(4) Theorem 4.4: rehearsal driven by the threshold rule, halting at the first abstention.
    Exact enumeration of all random choices for a small scaffold:
        sum_t ( log2(1/eta) E[W_t] + log2(1/(1-eta)) P[abort_t] ) <= L*K.
(5) Theorem 4.5: needle class, OR scaffold, deployed systems that may abstain.  Linear
    programme for the smallest silent-failure level given the abstention level a under the
    zero function, against ((N0-n)p - L a)/(N0+L).
(6) Proposition 4.7 (human with a modal answer) by simulation; Proposition 4.8 (identity).
"""
import itertools
import math
import random
from fractions import Fraction

import numpy as np
from scipy.optimize import linprog


def threshold_rule(post, hyps, x, eta):
    """post: list of posterior weights (need not be normalised to 1: semimeasure mixture
    is not used here, all hypotheses are functions).  Returns the answer or None."""
    tot = sum(post)
    mass = {}
    for wgt, h in zip(post, hyps):
        if wgt > 0:
            mass[h[x]] = mass.get(h[x], 0.0) + wgt
    for y, m in mass.items():
        if m >= (1 - eta) * tot - 1e-15:
            return y
    return None


def check_theorem_41(trials, seed=0):
    rng = random.Random(seed)
    worst = 0.0
    count = 0
    for _ in range(trials):
        nx = rng.randrange(3, 6)
        nh = rng.randrange(2, 9)
        ny = rng.randrange(2, 4)
        hyps = [tuple(rng.randrange(ny) for _ in range(nx)) for _ in range(nh)]
        raw = [rng.random() ** 3 + 1e-6 for _ in range(nh)]
        scale = rng.uniform(0.3, 1.0) / sum(raw)       # total weight below 1 is allowed
        w = [r * scale for r in raw]
        Wtot = sum(w)
        eta = rng.choice([0.05, 0.1, 0.2, 0.3, 0.45])
        for fi in range(nh):
            f = hyps[fi]
            budget = math.log2(Wtot / w[fi])
            for order in itertools.permutations(range(nx)):
                post = list(w)
                Wc = Ac = 0
                for x in order:
                    ans = threshold_rule(post, hyps, x, eta)
                    if ans is None:
                        Ac += 1
                    elif ans != f[x]:
                        Wc += 1
                    post = [p if h[x] == f[x] else 0.0 for p, h in zip(post, hyps)]
                used = Wc * math.log2(1 / eta) + Ac * math.log2(1 / (1 - eta))
                assert used <= budget + 1e-9, (used, budget)
                worst = max(worst, used / budget if budget > 0 else 0.0)
                count += 1
    return count, worst


def example_42(K, eta):
    """(a) k = floor(K/log2(1/eta)) wrong rounds; (b) abstentions for eta' slightly above eta."""
    k = int(math.floor(K / math.log2(1 / eta) + 1e-12))
    Wtot = 2.0 ** (-K) / eta ** k
    assert Wtot <= 1 + 1e-12
    R = Wtot
    w_g = []
    for _ in range(k):
        w_g.append((1 - eta) * R)
        R = eta * R
    w_f = R
    # hypotheses: f = 0 on x_1..x_k ; g_i = indicator of x_i
    hyps = [tuple([0] * k)] + [tuple(1 if j == i else 0 for j in range(k)) for i in range(k)]
    post = [w_f] + w_g
    wrong = 0
    for x in range(k):
        ans = threshold_rule(post, hyps, x, eta)
        if ans is not None and ans != 0:
            wrong += 1
        post = [p if h[x] == 0 else 0.0 for p, h in zip(post, hyps)]
    # (b)
    etap = eta * 1.0001
    kb = int(math.floor(K / math.log2(1 / (1 - etap)) + 1e-12))
    R = 1.0
    w_g = []
    for _ in range(kb):
        w_g.append(etap * R)
        R = (1 - etap) * R
    w_f = R                       # >= 2^-K
    absts = 0
    mass_alive = 1.0
    for i in range(kb):
        # posterior at x_i: g_i has mass w_g[i], the rest (f and later g) answers 0
        m1 = w_g[i] / mass_alive
        if not (m1 >= 1 - eta or 1 - m1 >= 1 - eta):
            absts += 1
        mass_alive *= (1 - etap)          # multiplicative update: no cancellation
    return k, wrong, K / math.log2(1 / eta), kb, absts, K / math.log2(1 / (1 - eta)), math.log2(1 / w_f)


def audits_sim(K, eta, q, reps, seed=0):
    """All 2^K functions on K inputs, uniform prior, f = 0.  Input a_i is shown until it has
    been asked.  Rule: with probability q ask; otherwise answer the label of posterior mass
    >= 1-eta if there is one (ties to label 1), else abstain; abstentions are asked."""
    rng = random.Random(seed)
    silent = 0
    for _ in range(reps):
        for _i in range(K):
            while True:
                if rng.random() < q:
                    break
                # posterior at a_i is (1/2, 1/2): abstains iff 1/2 < 1 - eta
                if 0.5 >= 1 - eta:
                    silent += 1          # answers 1, wrong, not asked
                else:
                    break                # abstains, and the abstention is asked
    return silent / reps


def rehearsal_exact(hyps, w, f_index, Z, calls, L, n, eta):
    """Exact expectations for Protocol R driven by the threshold rule.
    hyps: functions on X (tuples); Z: list of top-level inputs (uniform);
    calls(z, answers) -> next input or None.  Enumerates all (z_t, J_t), t <= n."""
    f = hyps[f_index]
    K = math.log2(1 / w[f_index])
    total = 0.0          # sum over rounds of log2(1/eta) E W_t + log2(1/(1-eta)) P[abort_t]
    sumW = [0.0] * n
    sumA = [0.0] * n
    pz = 1.0 / len(Z)

    def rec(t, post, prob):
        nonlocal total
        if t == n:
            return
        for z in Z:
            answers = []
            xs = []
            Wt = 0
            abort = 0
            while True:
                x = calls(z, answers)
                if x is None or len(xs) >= L:
                    break
                xs.append(x)
                ans = threshold_rule(post, hyps, x, eta)
                if ans is None:
                    abort = 1
                    break
                if ans != f[x]:
                    Wt += 1
                answers.append(ans)
            sumW[t] += prob * pz * Wt
            sumA[t] += prob * pz * abort
            for J in range(1, L + 1):
                pr = prob * pz / L
                if J <= len(xs):
                    xq = xs[J - 1]
                    newpost = tuple(p if h[xq] == f[xq] else 0.0 for p, h in zip(post, hyps))
                else:
                    newpost = post
                rec(t + 1, newpost, pr)

    rec(0, tuple(w), 1.0)
    lhs = sum(math.log2(1 / eta) * a + math.log2(1 / (1 - eta)) * b for a, b in zip(sumW, sumA))
    return lhs, L * K, sumW, sumA


def lp_theorem_45(N0, L, n, a_star):
    """Minimise sigma = max over members of the silent-failure probability, over randomised
    protocols that ask a set S of cells while all answers are 0 (E|S| <= n) and deployed
    systems with outcomes in {0, 1, abstain}, subject to abstention probability <= a_star
    under the zero function."""
    zs = list(itertools.product(range(N0), repeat=L))
    pzv = 1.0 / len(zs)
    subsets = [frozenset(s) for r in range(N0 + 1) for s in itertools.combinations(range(N0), r)]
    nS, nz = len(subsets), len(zs)
    # variables: pi[S], y[S,z,o] for o in (0,1,abst), sigma
    def iy(si, zi, o):
        return nS + (si * nz + zi) * 3 + o
    nvar = nS + nS * nz * 3 + 1
    isig = nvar - 1
    c = np.zeros(nvar)
    c[isig] = 1.0
    A_eq, b_eq, A_ub, b_ub = [], [], [], []
    row = np.zeros(nvar)
    row[:nS] = 1
    A_eq.append(row)
    b_eq.append(1.0)
    for si in range(nS):
        for zi in range(nz):
            row = np.zeros(nvar)
            for o in range(3):
                row[iy(si, zi, o)] = 1
            row[si] = -1
            A_eq.append(row)
            b_eq.append(0.0)
    row = np.zeros(nvar)                      # expected number of questions
    for si, S in enumerate(subsets):
        row[si] = len(S)
    A_ub.append(row)
    b_ub.append(n)
    row = np.zeros(nvar)                      # abstention under f0
    for si in range(nS):
        for zi in range(nz):
            row[iy(si, zi, 2)] = pzv
    A_ub.append(row)
    b_ub.append(a_star)
    row = np.zeros(nvar)                      # silent failure under f0: outputs 1
    for si in range(nS):
        for zi in range(nz):
            row[iy(si, zi, 1)] = pzv
    row[isig] = -1
    A_ub.append(row)
    b_ub.append(0.0)
    for cidx in range(N0):                    # silent failure under f_c
        row = np.zeros(nvar)
        for si, S in enumerate(subsets):
            if cidx in S:
                continue                      # the protocol has found c: no failure
            for zi, z in enumerate(zs):
                if cidx in z:
                    row[iy(si, zi, 0)] = pzv  # truth 1, output 0
                else:
                    row[iy(si, zi, 1)] = pzv  # truth 0, output 1
        row[isig] = -1
        A_ub.append(row)
        b_ub.append(0.0)
    res = linprog(c, A_ub=np.array(A_ub), b_ub=np.array(b_ub), A_eq=np.array(A_eq),
                  b_eq=np.array(b_eq), bounds=[(0, None)] * nvar, method="highs")
    assert res.status == 0, res.message
    p = 1 - (1 - 1 / N0) ** L
    bound = max(0.0, ((N0 - n) * p - L * a_star) / (N0 + L))
    return res.fun, bound


def modal_sim(eps0, eta, reps, T, seed=0):
    """Human: answers f(x) = 0 with probability 1 - eps0, else 1 (fresh at each question).
    Class: for each c in {0,1}^5 the sampler with modal answer c[x] at input x and noise
    eps0; uniform prior (K = 5 bits).  Inputs cycle through the 5 inputs.  Counts asked
    rounds at which the rule would answer the non-modal label, and abstention rounds."""
    rng = random.Random(seed)
    cs = list(itertools.product((0, 1), repeat=5))
    wrong = absts = 0
    for _ in range(reps):
        logw = [0.0] * len(cs)
        for t in range(T):
            x = t % 5
            mx = max(logw)
            wts = [math.exp(l - mx) for l in logw]
            s = sum(wts)
            m0 = sum(wt * ((1 - eps0) if c[x] == 0 else eps0) for wt, c in zip(wts, cs)) / s
            if m0 >= 1 - eta:
                pass
            elif 1 - m0 >= 1 - eta:
                wrong += 1
            else:
                absts += 1
            y = 1 if rng.random() < eps0 else 0
            for i, c in enumerate(cs):
                pr = (1 - eps0) if c[x] == y else eps0
                logw[i] += math.log(pr)
    return wrong / reps, absts / reps


def check_prop_48(N, seed=0):
    """Random rule r_t(. ; past answers) on N rounds.  A = expected abstentions under fair
    coins; S_b = silent mass against the deterministic member g_b.  Identity: A = N - 2 E_b S_b."""
    rng = random.Random(seed)
    rule = {}
    for t in range(N):
        for past in itertools.product((0, 1), repeat=t):
            a, b = rng.random(), rng.random()
            s = a + b + rng.random()
            rule[past] = (a / s, b / s)          # mass on answers 0 and 1; the rest abstains
    A = 0.0
    ES = 0.0
    for b in itertools.product((0, 1), repeat=N):
        pb = 2.0 ** (-N)
        for t in range(N):
            r0, r1 = rule[b[:t]]
            A += pb * (1 - r0 - r1)
            ES += pb * (r1 if b[t] == 0 else r0)
    return A, N - 2 * ES


def main():
    cnt, worst = check_theorem_41(trials=300, seed=11)
    print(f"(1) Theorem 4.1: {cnt} (class, human, order) cases checked; "
          f"largest used/budget = {worst:.4f} (never above 1)")
    print()
    print("(2) Example 4.2: counts attained")
    for K, eta in ((20, 0.25), (20, 0.1), (40, 0.01)):
        k, wrong, bw, kb, absts, ba, Kf = example_42(K, eta)
        print(f"   K={K} eta={eta}: wrong rounds {wrong} (bound {bw:.2f});  "
              f"abstentions {absts} (bound {ba:.2f}; class with log2(1/w(f)) = {Kf:.2f})")
    print()
    print("(3) threshold rule with audits (Proposition 4.3(b)): silent errors, K = 8")
    for eta, q in ((0.5, 0.25), (0.5, 0.05), (0.3, 0.25)):
        v = audits_sim(8, eta, q, reps=40000, seed=2)
        bound = (1 - q) * 8 / (q * math.log2(1 / eta))
        print(f"   eta={eta} q={q}: simulated {v:8.3f}   bound (1-q)K/(q log2(1/eta)) = {bound:8.3f}")
    print()

    print("(4) Theorem 4.4: rehearsal driven by the threshold rule (exact enumeration)")
    # X = {0..5}; scaffold: z in {0,1,2}; call 1 at input z; call 2 at input 3 + (answer of call 1 mod 2)
    # ... call 3 at input 5.
    rng = random.Random(4)
    X = 6
    L = 3
    Z = [0, 1, 2]

    def calls(z, answers):
        j = len(answers)
        if j == 0:
            return z
        if j == 1:
            return 3 + (answers[0] % 2)
        if j == 2:
            return 5
        return None

    for trial in range(4):
        nh = 6
        hyps = [tuple(rng.randrange(2) for _ in range(X)) for _ in range(nh)]
        raw = [rng.random() ** 2 + 0.01 for _ in range(nh)]
        w = [r / sum(raw) for r in raw]
        for eta in (0.1, 0.3):
            fi = trial % nh
            lhs, bound, sW, sA = rehearsal_exact(hyps, w, fi, Z, calls, L, n=4, eta=eta)
            assert lhs <= bound + 1e-9
            print(f"   class {trial}, eta={eta}: sum_t [log2(1/eta) E W_t + log2(1/(1-eta)) P(abort_t)] "
                  f"= {lhs:.4f} <= L*K = {bound:.4f};  E W_t = {[round(v, 3) for v in sW]}, "
                  f"P(abort_t) = {[round(v, 3) for v in sA]}")
    print()

    print("(5) Theorem 4.5: smallest silent-failure level (LP) against ((N0-n)p - L a)/(N0+L)")
    print(f"   {'N0':>3} {'L':>2} {'n':>4} {'a':>5} {'LP':>8} {'bound':>8}")
    for N0, L5 in ((4, 2), (5, 2), (4, 3)):
        for n in (0, 1, 2.5):
            for a in (0.0, 0.2, 0.5):
                val, bound = lp_theorem_45(N0, L5, n, a)
                assert val >= bound - 1e-7, (N0, L5, n, a, val, bound)
                print(f"   {N0:>3} {L5:>2} {n:>4} {a:>5} {val:>8.4f} {bound:>8.4f}")
    print()

    print("(6) Proposition 4.7 (human with modal answer 1-eps0; K = 5 bits), expected counts on 400 asked rounds")
    for eps0, eta in ((0.02, 0.2), (0.05, 0.2), (0.05, 0.1)):
        wr, ab = modal_sim(eps0, eta, reps=4000, T=400, seed=9)
        h = -(eps0 * math.log(eps0) + (1 - eps0) * math.log(1 - eps0))
        bw = 5 * math.log(2) / ((1 - eps0) * math.log(1 / eta) - h)
        ba = 2 * eta * 5 * math.log(2) / (eta - eps0) ** 2
        print(f"   eps0={eps0} eta={eta}: non-modal answers {wr:6.3f} (bound {bw:6.3f});  "
              f"abstentions {ab:7.3f} (bound {ba:7.3f})")
    A, rhs = check_prop_48(6, seed=3)
    print(f"    Proposition 4.8, identity A = N - 2 E_b S_b for a random rule, N = 6: {A:.6f} = {rhs:.6f}")


if __name__ == "__main__":
    main()
