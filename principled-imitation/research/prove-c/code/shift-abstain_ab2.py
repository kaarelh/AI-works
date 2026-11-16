#!/usr/bin/env python3
"""Checks for Section 5 of research/prove-c/shift-abstain.md (Ab2, the minimum rule).

(1) Theorem 5.1 on a small adaptive scaffold with random samplers, by exact enumeration
    of all runs: the law of the non-aborted runs of the minimum rule is dominated by the
    human system; TV(run law with aborted runs merged, human system) = P[abort];
    P[abort] <= integral of theta d(d_P);  max TV <= theta <= sum TV.
(2) Proposition 5.2: the three plausible sets (absolute, cumulative, ratio) are nested,
    the cumulative one has at most 1/alpha members, and the human leaves each of them at
    some time with probability at most alpha/w(P) (simulation).
(3) Theorem 5.6(b), first claim: after rehearsal, every member nu of the ratio set has
    sum_t h_t(nu) < Gamma with probability >= 1 - eta, where h_t(nu) is the expected squared
    Hellinger distance to the human at the asked call of round t (exact visit measures).
(4) Example 5.7(b): linear fill-ins of a fair coin make the frozen ratio rule abstain.
"""
import itertools
import math
import random


# ------------------------------------------------------------ a small scaffold
# X = {0,1,2,3,4}; Y = {0,1}; z uniform on {0,1,2}; call 1 at input z; call 2 at input 3 + y1.
XN = 5
Z = (0, 1, 2)
L = 2


def run_inputs(z, y1):
    return z, 3 + y1


def run_law(kern):
    """kern[x] = (prob of 0, prob of 1), possibly summing to less than 1 (the rest aborts).
    Returns {(z, y1, y2): prob} for completed runs and the abort probability."""
    law = {}
    abort = 0.0
    for z in Z:
        pz = 1.0 / len(Z)
        x1 = z
        abort += pz * (1 - sum(kern[x1]))
        for y1 in (0, 1):
            x2 = 3 + y1
            abort += pz * kern[x1][y1] * (1 - sum(kern[x2]))
            for y2 in (0, 1):
                law[(z, y1, y2)] = pz * kern[x1][y1] * kern[x2][y2]
    return law, abort


def visit_measure(kern):
    d = [0.0] * XN
    for z in Z:
        pz = 1.0 / len(Z)
        d[z] += pz
        for y1 in (0, 1):
            d[3 + y1] += pz * kern[z][y1]
    return d


def tv(p, q):
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def hell2(p, q):
    return 1.0 - sum(math.sqrt(a * b) for a, b in zip(p, q))


def check_dominance(trials, seed=0):
    rng = random.Random(seed)
    worst_dom = 0.0
    worst_tv = 0.0
    worst_ab = 0.0
    worst_theta = 0.0
    for _ in range(trials):
        m = rng.randrange(2, 6)
        C = []
        for _i in range(m):
            k = []
            for _x in range(XN):
                p = rng.random()
                k.append((p, 1 - p))
            C.append(k)
        P = C[0]                                   # the human is in C
        S = [tuple(min(nu[x][y] for nu in C) for y in (0, 1)) for x in range(XN)]
        theta = [1 - sum(S[x]) for x in range(XN)]
        lawS, abortS = run_law(S)
        lawP, _ = run_law(P)
        for key in lawP:
            worst_dom = max(worst_dom, lawS[key] - lawP[key])          # must be <= 0
        tvd = 0.5 * (sum(abs(lawS[k] - lawP[k]) for k in lawP) + abortS)
        worst_tv = max(worst_tv, abs(tvd - abortS))                    # must be 0
        dP = visit_measure(P)
        worst_ab = max(worst_ab, abortS - sum(t * d for t, d in zip(theta, dP)))   # <= 0
        for x in range(XN):
            lo = max(tv(nu[x], P[x]) for nu in C)
            hi = sum(tv(nu[x], P[x]) for nu in C)
            worst_theta = max(worst_theta, lo - theta[x], theta[x] - hi)           # <= 0
    return worst_dom, worst_tv, worst_ab, worst_theta


# ------------------------------------------------------------ plausible sets
def sets(post, alpha):
    order = sorted(range(len(post)), key=lambda i: -post[i])
    wmax = post[order[0]]
    absol = {i for i in range(len(post)) if post[i] >= alpha}
    ratio = {i for i in range(len(post)) if post[i] >= alpha * wmax}
    cum = set()
    acc = 0.0
    for i in order:
        acc += post[i]
        if post[i] >= alpha * acc:
            cum.add(i)
    return absol, cum, ratio


def check_sets(trials, seed=1):
    rng = random.Random(seed)
    for _ in range(trials):
        n = rng.randrange(1, 40)
        raw = [rng.random() ** rng.choice([1, 3, 8]) + 1e-12 for _ in range(n)]
        s = sum(raw)
        post = [r / s for r in raw]
        alpha = rng.choice([0.01, 0.05, 0.2, 0.5])
        a, c, r = sets(post, alpha)
        assert a <= c <= r
        assert len(c) <= 1 / alpha + 1e-9
        assert len(c) >= 1
    return trials


def ville_sim(alpha, reps, T, seed=2):
    """Class: coins.  The human answers 1 with probability 0.5 at the single input;
    alternatives answer 1 with probabilities 0.3, 0.4, 0.6, 0.7.  w(P) = 0.05, the rest shared.
    Frequency of {exists t <= T: P not in the set} for the three sets."""
    rng = random.Random(seed)
    ps = [0.5, 0.3, 0.4, 0.6, 0.7]
    w = [0.05] + [0.95 / 4] * 4
    out = [0, 0, 0]
    for _ in range(reps):
        logw = [math.log(x) for x in w]
        left = [False, False, False]
        for _t in range(T):
            y = 1 if rng.random() < 0.5 else 0
            for i, p in enumerate(ps):
                logw[i] += math.log(p if y else 1 - p)
            mx = max(logw)
            post = [math.exp(l - mx) for l in logw]
            s = sum(post)
            post = [v / s for v in post]
            a, c, r = sets(post, alpha)
            for j, st in enumerate((a, c, r)):
                if 0 not in st:
                    left[j] = True
            if all(left):
                break
        for j in range(3):
            out[j] += left[j]
    return [o / reps for o in out]


# ------------------------------------------------------------ Theorem 5.6 (ii)
def check_hellinger_step(reps, n, alpha, eta, seed=3):
    rng0 = random.Random(seed)
    # a fixed class of 10 samplers; member 0 is the human
    vals = (0.15, 0.5, 0.85)
    cls = []
    for _ in range(10):
        cls.append([(v, 1 - v) for v in (rng0.choice(vals) for _x in range(XN))])
    raw = [rng0.random() + 0.2 for _ in cls]
    s = sum(raw)
    w = [r / s for r in raw]
    P = cls[0]
    S_half = sum(math.sqrt(x) for x in w)
    Gamma = math.log(S_half) + 0.5 * math.log(1 / (alpha * w[0])) + math.log(1 / eta)
    rng = random.Random(seed + 1)
    viol = 0
    maxratio = 0.0
    for _ in range(reps):
        logw = [math.log(x) for x in w]
        hsum = [0.0] * len(cls)
        for _t in range(n):
            mx = max(logw)
            post = [math.exp(l - mx) for l in logw]
            sp = sum(post)
            post = [v / sp for v in post]
            M = [tuple(sum(pw * nu[x][y] for pw, nu in zip(post, cls)) for y in (0, 1)) for x in range(XN)]
            d = visit_measure(M)
            for i, nu in enumerate(cls):
                hsum[i] += sum(d[x] * hell2(nu[x], P[x]) for x in range(XN)) / L
            # one rehearsal run of the mixture and one asked call
            z = rng.choice(Z)
            y1 = 0 if rng.random() < M[z][0] else 1
            xs = run_inputs(z, y1)
            J = rng.randrange(L)
            xq = xs[J]
            y = 0 if rng.random() < P[xq][0] else 1
            for i, nu in enumerate(cls):
                logw[i] += math.log(nu[xq][y])
        mx = max(logw)
        members = [i for i in range(len(cls)) if logw[i] >= mx + math.log(alpha)]
        worst = max(hsum[i] for i in members)
        maxratio = max(maxratio, worst / Gamma)
        if worst >= Gamma:
            viol += 1
    return viol / reps, Gamma, maxratio


def check_fillins(d, c0, reps, seed=4):
    """Example 5.7(b): the human is a fair coin at every input of {0,1}^d (weight 1/2); the
    other hypotheses are the 2^d linear functions over GF(2) (weight 2^-(d+1) each).
    After n = d - c0 questions at uniformly random inputs: number of consistent linear
    functions, their posterior weight relative to the coin, and the abstention probability
    theta of the minimum rule over the ratio set with alpha = 2^-c0 at a fresh random input."""
    rng = random.Random(seed)
    n = d - c0
    indep = 0
    count_ok = 0
    theta_sum = 0.0
    theta_min = 1.0
    for _ in range(reps):
        xs = [rng.getrandbits(d) for _ in range(n)]
        ys = [rng.getrandbits(1) for _ in range(n)]
        cons = [s for s in range(2 ** d)
                if all((bin(s & x).count("1") & 1) == y for x, y in zip(xs, ys))]
        # rank of xs over GF(2)
        basis = []
        for x in xs:
            for b in basis:
                x = min(x, x ^ b)
            if x:
                basis.append(x)
        if len(basis) == n:
            indep += 1
            if len(cons) == 2 ** c0:
                count_ok += 1
            # ratio set with alpha = 2^-c0 : the coin and all consistent linear functions
            # (relative posterior weight 2^(n-d) = 2^-c0 each)
            x = rng.getrandbits(d)
            vals = {bin(s & x).count("1") & 1 for s in cons}
            if len(vals) == 2:
                theta = 1.0                      # S = 0 for both answers
            else:
                theta = 0.5                      # S gives 1/2 to the common answer
            theta_sum += theta
            theta_min = min(theta_min, theta)
    return indep / reps, count_ok / max(indep, 1), theta_sum / max(indep, 1), theta_min


def main():
    wd, wt, wa, wth = check_dominance(trials=20000, seed=5)
    print("(1) Theorem 5.1, 20000 random instances (5 inputs, adaptive scaffold of 2 calls, 2 to 5 samplers):")
    print(f"    max of [law of a completed run under the rule - under the human]: {wd:.2e} (<= 0)")
    print(f"    max |TV - P(abort)|: {wt:.2e};  max [P(abort) - int theta d d_P]: {wa:.2e} (<= 0)")
    print(f"    max violation of  max_nu TV <= theta <= sum_nu TV: {wth:.2e} (<= 0)")
    print()
    k = check_sets(20000)
    print(f"(2) plausible sets: absolute <= cumulative <= ratio and |cumulative| <= 1/alpha in {k} random posteriors")
    print("    frequency with which the human leaves the set at some time (w(P) = 0.05):")
    for alpha in (0.005, 0.02):
        fr = ville_sim(alpha, reps=20000, T=400)
        print(f"    alpha={alpha}: absolute {fr[0]:.4f}, cumulative {fr[1]:.4f}, ratio {fr[2]:.4f};"
              f"  bound alpha/w(P) = {alpha / 0.05:.3f}")
    print()
    print("(3) Theorem 5.6(b), first claim: frequency of {some member nu of the ratio set has sum_t h_t(nu) >= Gamma}")
    for n, alpha, eta in ((40, 0.3, 0.5), (40, 0.05, 0.25), (150, 0.3, 0.25)):
        fr, Gam, mr = check_hellinger_step(reps=4000, n=n, alpha=alpha, eta=eta)
        print(f"    n={n} alpha={alpha} eta={eta}: frequency {fr:.4f} (bound {eta}); Gamma = {Gam:.3f}; "
              f"largest observed sum/Gamma = {mr:.3f}")

    print()
    print("(4) Example 5.7(b), linear fill-ins of a fair coin (K = 1 bit):")
    for d, c0 in ((8, 2), (10, 3)):
        fi, ok, th, thmin = check_fillins(d, c0, reps=6000)
        exact = 1.0
        for i in range(d - c0):
            exact *= 1 - 2.0 ** (i - d)
        print(f"    d={d} c0={c0} n={d - c0}: asked inputs independent in {fi:.3f} of 6000 runs "
              f"(exact probability {exact:.3f}, lower bound 1 - 2^-c0 = {1 - 2.0 ** (-c0):.3f});")
        print(f"        given independence: exactly 2^c0 consistent linear functions in {ok:.3f} of the runs; "
              f"mean abstention probability at a random input {th:.3f} (exact value 1 - 2^-c0/2 = "
              f"{1 - 2.0 ** (-c0) / 2:.3f}), smallest {thmin}")

if __name__ == "__main__":
    main()
