"""Referee 5: checks of the arithmetic and of Proposition 5's accounting outside E6.

Part 1. The ask budget: K / log2(1/(1-alpha)) against "about 0.69 K / alpha" (Proposition 5,
        answers 2 and 7, Section 7).
Part 2. Corollary 3's round count, (K+1) * ceil((D+1) ln((K+1)(K+2)/delta) / (rho eps)), divided
        by K: it grows like log K, so the count is O(K log K) for fixed eps, delta, D, rho.
Part 3. Remark 1 / Section 4: the factor min{n, (D+1)n/(sigma+1)} against chained imitation's n0.
Part 4. Proposition 5 on random hypothesis classes (not E6): append-only notebooks under a
        hidden clock (the state is the notebook itself, so an empty label repeats the state),
        hypotheses that are random perturbations of a deterministic human P, a prior with
        w(P) = 2^-K0, and a "nothing bizarre" check (an entry 'c' is bizarre; P never writes it on
        a passing notebook, so (M1), (M2), (M-prefix) hold). Protocol SI-ABC with the check is run
        for many rounds on an adversarially simple problem sequence, and on every path:
          * every ask pays more than log2(1/(1-alpha)) bits, and #asks * log2(1/(1-alpha)) <= K;
          * the flip of a run that fails the check is a committed step and a mistake;
          * every hit (uniform or flip query on a committed mistake) has xi(P) <= alpha under the
            data D_t u A_<k, and each round pays at least [bits of A_<k] + [hit] log2(1/alpha);
          * #hits * log2(1/alpha) <= K.
        alpha ranges over 0.05 ... 0.7, so the case alpha > 1/2 is included.
Usage: python3 referee5_theory_checks.py
"""

import math
import random
import zlib
from math import log2


def dh(x):
    """A deterministic hash (Python's str hash is salted per process)."""
    return zlib.crc32(repr(x).encode())

# ---------------------------------------------------------------- Part 1
print("Part 1: ask budget per unit of K")
print("  alpha   1/log2(1/(1-alpha))   ln2/alpha   0.69/alpha   exact <= 0.69/alpha?")
for alpha in (0.001, 0.005, 0.0089, 0.01, 0.05, 0.1, 0.2, 0.3, 0.5):
    exact = 1 / log2(1 / (1 - alpha))
    print(f"  {alpha:<7} {exact:12.3f}          {math.log(2) / alpha:9.3f}   {0.69 / alpha:9.3f}"
          f"    {exact <= 0.69 / alpha}")
print("  (exact <= ln2/alpha for every alpha in (0,1), since ln(1/(1-alpha)) >= alpha)")

# ---------------------------------------------------------------- Part 2
print("\nPart 2: Corollary 3's rounds / K, for eps = 0.01, delta = 0.05, D = 1, rho = 1/2")
for K in (10, 100, 1000, 10**4, 10**5, 10**6):
    r = (K + 1) * math.ceil((1 + 1) * math.log((K + 1) * (K + 2) / 0.05) / (0.5 * 0.01))
    print(f"  K = {K:>8}: rounds = {r:.3e}, rounds/K = {r / K:9.0f}")

# ---------------------------------------------------------------- Part 3
print("\nPart 3: guaranteed factor min{n, (D+1)n/(sigma+1)} vs chained imitation's n0, rho = 1/2")
for n0 in (8, 16, 40):
    sigma = n0
    n = n0 + sigma
    for D in (0, 1, 2, 4, 8, n0 - 1):
        f = min(n, (D + 1) * n / (sigma + 1))
        print(f"  n0 = {n0:2d}, D = {D:2d}: factor {f:6.2f}, gain over chained imitation n0/factor = {n0 / f:5.2f}"
              f"{'   (D < sigma but no gain)' if D < sigma and n0 / f <= 1 else ''}")

# ---------------------------------------------------------------- Part 4
LAB = ["", "a", "b", "c"]          # "" = write nothing; "c" is a bizarre entry


def passes(y):
    return "c" not in y[1:]


def make_world(seed, n, nhyp, K0):
    rnd = random.Random(seed)
    cache = {}

    def P(y):
        if y not in cache:
            r = random.Random(dh((seed, "P", y)))
            if passes(y):
                cache[y] = r.choice(["", "a", "b", "a", "b"])   # never 'c' on a passing notebook
            else:
                cache[y] = r.choice(LAB)
        return cache[y]

    # hypotheses come in families that share a perturbation of P (so a heavy family can make
    # the decoder confidently wrong), plus individual noise
    fams = [(rnd.choice([0.1, 0.3, 0.5]), rnd.random()) for _ in range(6)]
    hyps = [(rnd.randrange(len(fams)), rnd.choice([0.0, 0.05, 0.2]), rnd.random())
            for _ in range(nhyp)]
    raw = [rnd.random() ** 4 for _ in range(nhyp)]
    s = sum(raw)
    w = [(1 - 2 ** -K0) * x / s for x in raw]
    hcache = {}

    def H(i, y):
        key = (i, y)
        if key not in hcache:
            f, rate, salt = hyps[i]
            frate, fsalt = fams[f]
            rf = random.Random(dh((seed, "fam", f, fsalt, y)))
            lab = rf.choice(LAB) if rf.random() < frate else P(y)
            r = random.Random(dh((seed, i, salt, y)))
            if r.random() < rate:
                lab = r.choice(LAB)
            hcache[key] = lab
        return hcache[key]

    return P, H, w


def run_trial(seed, alpha, n=8, nhyp=40, K0=8.0, rounds=1500, problems=40):
    """A product prior over problems: problem p has its own class (P_p, hypotheses, weights),
    so K = problems * K0 and W(D) is the product of the per-problem masses."""
    worlds = [make_world(1000 * seed + p, n, nhyp, K0) for p in range(problems)]
    wP = 2 ** -K0
    alive = [[True] * nhyp for _ in range(problems)]

    def Wp(p):
        P, H, w = worlds[p]
        return sum(wi for wi, a in zip(w, alive[p]) if a) + wP

    K = problems * log2(1 / wP)            # Phi(empty) <= K, since W(empty) = 1
    asks = hits = flips = 0
    bad = dict(ask_bits=0, flip_not_committed=0, flip_not_mistake=0, hit_xi=0, round_bits=0)
    min_round_ratio = math.inf
    rnd = random.Random(seed + 7)

    def masses(p, y):
        P, H, w = worlds[p]
        m = {lab: 0.0 for lab in LAB}
        for i in range(nhyp):
            if alive[p][i]:
                m[H(i, y)] += w[i]
        m[P(y)] += wP
        return m

    def add(p, y, lab):
        P, H, w = worlds[p]
        for i in range(nhyp):
            if alive[p][i] and H(i, y) != lab:
                alive[p][i] = False

    for t in range(rounds):
        p = rnd.randrange(problems)
        P = worlds[p][0]
        W_start = Wp(p)
        y = ("p%d" % p,)
        states, labels, asked, info = [], [], [], []
        ask_bits = []
        for k in range(n):
            m = masses(p, y)
            W = sum(m.values())
            best = max(LAB, key=lambda lab: (m[lab], -LAB.index(lab)))
            mu = m[best] / W
            truth = P(y)
            if mu < 1 - alpha:
                b = log2(W / m[truth])
                if not b > log2(1 / (1 - alpha)) - 1e-12:
                    bad["ask_bits"] += 1
                ask_bits.append((k, b))
                add(p, y, truth)
                lab = truth
                asked.append(True)
                asks += 1
                info.append(None)
            else:
                lab = best
                asked.append(False)
                info.append(m[truth] / W)          # xi(P) under D_t u A_<k
            states.append(y)
            labels.append(lab)
            y = y + ((lab,) if lab else ())
        # the check (find the flip), or a uniform query
        if not passes(y):
            flip = next(k for k in range(n) if passes(states[k]) and
                        not passes(states[k] + ((labels[k],) if labels[k] else ())))
            flips += 1
            if asked[flip]:
                bad["flip_not_committed"] += 1
            if labels[flip] == P(states[flip]):
                bad["flip_not_mistake"] += 1
            k = flip
        else:
            k = rnd.randrange(n)
        hit = (not asked[k]) and labels[k] != P(states[k])
        if hit:
            hits += 1
            if info[k] > alpha + 1e-12:
                bad["hit_xi"] += 1
        add(p, states[k], P(states[k]))
        rb = log2(W_start / Wp(p))
        lower = sum(b for (kk, b) in ask_bits if kk < k) + (log2(1 / alpha) if hit else 0.0)
        if lower > 0:
            min_round_ratio = min(min_round_ratio, rb / lower)
        if rb < lower - 1e-9:
            bad["round_bits"] += 1
    total_bits = sum(log2(1 / Wp(p)) for p in range(problems))
    return dict(K=K, asks=asks, hits=hits, flips=flips, total_bits=total_bits, bad=bad,
                ask_ok=asks * log2(1 / (1 - alpha)) <= K + 1e-9,
                hit_ok=hits * log2(1 / alpha) <= K + 1e-9,
                min_round_ratio=min_round_ratio)


print("\nPart 4: Proposition 5's accounting on random hypothesis classes (SI-ABC with the check)")
for alpha in (0.05, 0.1, 0.3, 0.5, 0.7):
    agg = dict(ask_bits=0, flip_not_committed=0, flip_not_mistake=0, hit_xi=0, round_bits=0)
    tot = dict(asks=0, hits=0, flips=0, ask_fail=0, hit_fail=0, trials=0)
    mr = math.inf
    worst_ask = worst_hit = 0.0
    for seed in range(20):
        r = run_trial(seed, alpha)
        for k2 in agg:
            agg[k2] += r["bad"][k2]
        tot["asks"] += r["asks"]
        tot["hits"] += r["hits"]
        tot["flips"] += r["flips"]
        tot["ask_fail"] += not r["ask_ok"]
        tot["hit_fail"] += not r["hit_ok"]
        tot["trials"] += 1
        mr = min(mr, r["min_round_ratio"])
        worst_ask = max(worst_ask, r["asks"] * log2(1 / (1 - alpha)) / r["K"])
        worst_hit = max(worst_hit, r["hits"] * log2(1 / alpha) / r["K"])
    print(f"  alpha = {alpha}: {tot['trials']} trials, asks {tot['asks']}, hits {tot['hits']} (of which flips {tot['flips']}); "
          f"violations {agg}; paths with asks*log2(1/(1-a)) > K: {tot['ask_fail']}, "
          f"with hits*log2(1/a) > K: {tot['hit_fail']}; max asks*log2(1/(1-a))/K {worst_ask:.2f}, "
          f"max hits*log2(1/a)/K {worst_hit:.2f}; min round bits / lower bound {mr:.3f}")
