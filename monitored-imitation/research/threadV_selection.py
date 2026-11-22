"""Thread V: exact-Bayes checks of the selection theorems for VSI (threadV-humanlike.md).

Run:  python3 threadV_selection.py > threadV_selection.out   (seconds; seeds fixed)

The learner is exact Bayes over a finite class with the majority decoder (ties go
to the larger label); no asks, so b = 1 and K' = floor(K). VSI's search uses the
schedule S, U, S, H with an empty list (H's turns go to S). A verifier is any
rule satisfying (A3'): it must accept a run whose first n0 steps are the human's
own; otherwise it may do anything. Every such verifier is represented by the
string of its free verdicts, so enumerating strings enumerates all verifiers.

A. Tightness (Theorem 2(b)). Product class of K habits: hypothesis nu_S writes 1
   at coordinate step i for i in S, the human writes 0 everywhere, uniform prior.
   Count the distinct output sequences over T problems, over all verifiers, and
   compare with C(T+K, K). Also report max over verifiers of sum_p log2(1+R_p).
B. Random clustered classes. Over all verifiers (all scripts), check:
   (i)   every rejection ends in a hit, and R <= K';
   (ii)  each output is the R_p-th run of the forced-correction path computed
         from the same history and search randomness (Theorem 2(a));
   (iii) the human is never refuted, so every committed label has mass >= w(P);
   (iv)  #distinct output sequences <= C(T+K', K').
C. Audits and the deviation-blind reference (Theorem 2(c)). Monte Carlo with
   several verifiers over T problems: E[R] + (beta/n) E[A] <= K' and
   E[LLR] <= K' log2(e(1+n/beta)), where A counts outputs with a committed mistake
   and LLR = R log2(1/q) + A log2(1/(1-q)), q = beta/(n+beta).
"""
import math
import random
from itertools import product

LOG2E = math.log2(math.e)


# ---------------------------------------------------------------- the learner
class Bayes:
    """Exact Bayes over a finite class; hypotheses are callables (x0, labels) -> label."""

    def __init__(self, hyps, weights, human):
        self.hyps, self.w, self.human = hyps, weights, human
        self.wP = weights[human]
        assert sum(weights) <= 1 + 1e-9
        self.K = math.log2(1 / self.wP)

    def masses(self, alive, s):
        m = {}
        for h in alive:
            y = self.hyps[h](*s)
            m[y] = m.get(y, 0.0) + self.w[h]
        return m

    def decode(self, alive, s):
        m = self.masses(alive, s)
        return max(m.items(), key=lambda kv: (kv[1], kv[0]))[0], m

    def add(self, alive, s, y):
        return frozenset(h for h in alive if self.hyps[h](*s) == y)

    def P(self, s):
        return self.hyps[self.human](*s)


def make_run(B, alive, x0, n, checks=None):
    labels, states, mistakes = (), [], set()
    for k in range(n):
        s = (x0, labels)
        y, m = B.decode(alive, s)
        p = B.P(s)
        if checks is not None:  # (iii): P alive, so P's label has mass >= w(P)
            checks["iii"] &= (B.human in alive) and m.get(p, 0) >= B.wP - 1e-15 and m[y] >= m.get(p, 0)
        if y != p:
            mistakes.add(k)
        states.append(s)
        labels = labels + (y,)
    return labels, states, mistakes


def human_chain(B, x0, n):
    labels = ()
    for _ in range(n):
        labels = labels + (B.P((x0, labels)),)
    return labels


def search(B, alive, states, mistakes, n, rng):
    """Schedule S,U,S,H with an empty list (H -> S). Returns (alive, hit, #queries)."""
    sched, j, q = ["S", "U", "S", "S"], 0, 0
    while True:
        kind = sched[q % 4]
        q += 1
        if kind == "S":
            if j >= n:
                return alive, False, q
            k, j = j, j + 1
        else:
            k = rng.randrange(n)
        alive = B.add(alive, states[k], B.P(states[k]))
        if k in mistakes:
            return alive, True, q


def omega(seed, p, i):
    return random.Random(seed * 1_000_003 + p * 10_007 + i)


# ---------------------------------------------------------------- enumeration
def enumerate_verifiers(B, problems, n, n0, seed, path_check=True):
    """DFS over all (A3') verifiers. Returns list of (outputs, R, Rp) and the checks."""
    T = len(problems)
    hc = {x0: human_chain(B, x0, n) for x0 in set(problems)}
    checks = {"i": True, "ii": True, "iii": True}
    leaves = []

    def fc_path(alive, p):
        x0, path, i = problems[p], [], 0
        while True:
            labels, states, mist = make_run(B, alive, x0, n)
            path.append(labels)
            if not mist:
                return path
            alive, hit, _ = search(B, alive, states, mist, n, omega(seed, p, i))
            i += 1

    def go(alive, p, i, outs, R, Rp, path):
        if p == T:
            leaves.append((tuple(outs), R, tuple(Rp)))
            return
        if i == 0 and path_check:
            path = fc_path(alive, p)
        x0 = problems[p]
        labels, states, mist = make_run(B, alive, x0, n, checks)
        forced = labels[:n0] == hc[x0][:n0]
        # accept
        if path_check:
            checks["ii"] &= (i < len(path) and path[i] == labels)
        go(alive, p + 1, 0, outs + [labels], R, Rp + [i], None)
        # reject (only if allowed by A3')
        if not forced:
            a2, hit, _ = search(B, alive, states, mist, n, omega(seed, p, i))
            checks["i"] &= hit
            go(a2, p, i + 1, outs, R + 1, Rp, path)

    go(frozenset(range(len(B.hyps))), 0, 0, [], 0, [], None)
    return leaves, checks


# ---------------------------------------------------------------- part A
def product_class(K, n):
    hyps, weights = [], []
    for S in product([0, 1], repeat=K):
        hyps.append(lambda x0, labels, S=S: (S[len(labels)] if len(labels) < K else 0))
        weights.append(2.0 ** (-K))
    return Bayes(hyps, weights, human=0)  # S = (0,...,0) is index 0


def part_a():
    print("A. Tightness of the lifetime bound: product class of K habits, all (A3') verifiers")
    print("   %3s %3s %10s %12s %10s %14s %14s" % ("K", "T", "#outputs", "C(T+K,K)", "log2 #", "K log2(e(1+T/K))", "max sum log2(1+R_p)"))
    for K, T in [(1, 4), (2, 4), (2, 8), (3, 5), (3, 8), (4, 6)]:
        n = K + 2
        B = product_class(K, n)
        leaves, checks = enumerate_verifiers(B, list(range(T)), n, n0=K, seed=1)
        distinct = len(set(l[0] for l in leaves))
        bound = math.comb(T + K, K)
        smax = max(sum(math.log2(1 + r) for r in l[2]) for l in leaves)
        print("   %3d %3d %10d %12d %10.2f %14.2f %14.2f   checks %s" % (
            K, T, distinct, bound, math.log2(distinct), K * math.log2(math.e * (1 + T / K)), smax,
            "ok" if all(checks.values()) else checks))
    print("   (#outputs = C(T+K,K) exactly: the bound is attained; sum log2(1+R_p) <= K log2 e"
          " stays bounded while log2 # grows like K log2(T/K).)")


# ---------------------------------------------------------------- part B / C class
def random_class(rng, m=3, n=6, labels=3, fam=10, per=3, p_fam=0.6, p_ind=0.1, wP=2 ** -8):
    keys = [(x0, k, prev) for x0 in range(m) for k in range(n) for prev in range(-1, labels)]
    base = {key: rng.randrange(labels) for key in keys}

    def alt(y):
        return rng.choice([z for z in range(labels) if z != y])

    tables = [dict(base)]
    for _ in range(fam):
        dev = {key: alt(base[key]) for key in keys if rng.random() < p_fam}
        for _ in range(per):
            t = dict(base)
            t.update(dev)
            for key in keys:
                if rng.random() < p_ind:
                    t[key] = alt(base[key])
            tables.append(t)
    raw = [rng.random() ** 2 for _ in tables[1:]]
    z = sum(raw)
    weights = [wP] + [(1 - wP) * r / z for r in raw]

    def mk(t):
        return lambda x0, lab: t[(x0, len(lab), lab[-1] if lab else -1)]

    return Bayes([mk(t) for t in tables], weights, human=0)


def part_b():
    print()
    print("B. Random clustered classes (31 hypotheses in 10 families, w(P) = 2^-8, n = 6, n0 = 4), all (A3') verifiers")
    print("   %5s %3s %3s %8s %10s %12s %8s  %s" % ("class", "K'", "T", "#leaves", "#outputs", "C(T+K',K')", "max R", "checks i/ii/iii"))
    rng = random.Random(20261122)
    worst = 0.0
    for c in range(12):
        B = random_class(rng)
        Kp = math.floor(B.K + 1e-9)
        problems = [rng.randrange(3) for _ in range(5)]
        leaves, checks = enumerate_verifiers(B, problems, n=6, n0=4, seed=c)
        distinct = len(set(l[0] for l in leaves))
        bound = math.comb(len(problems) + Kp, Kp)
        maxR = max(l[1] for l in leaves)
        ok_iv = distinct <= bound and maxR <= Kp
        worst = max(worst, distinct / bound)
        print("   %5d %3d %3d %8d %10d %12d %8d  %s %s %s %s" % (
            c, Kp, len(problems), len(leaves), distinct, bound, maxR,
            checks["i"], checks["ii"], checks["iii"], "iv ok" if ok_iv else "iv FAIL"))
    print("   largest ratio #outputs / C(T+K',K') = %.3f" % worst)


def part_c():
    print()
    print("C. Audits and the deviation-blind reference: E[R]+(beta/n)E[A] <= K', E[LLR] <= K' log2(e(1+n/beta))")
    n, n0, reps = 6, 4, 200
    verifiers = {
        "lenient (accepts all)": lambda dev, r: True,
        "strict (rejects every deviation)": lambda dev, r: not dev,
        "coin 1/2 on deviations": lambda dev, r: (not dev) or r.random() < 0.5,
        "blind spot (passes late deviations)": None,  # set below
    }
    print("   %-36s %5s %5s %8s %8s %10s %10s %10s" % ("verifier", "beta", "T", "E[R]", "E[A]", "E[R]+bA/n", "E[LLR]", "bound"))
    rng0 = random.Random(77)
    classes = [random_class(rng0) for _ in range(reps)]
    for beta in (1.0, 0.25):
        q = beta / (n + beta)
        for name in verifiers:
            for T in (50, 400):
                sR = sA = sL = 0.0
                Kp_sum = 0.0
                for rep, B in enumerate(classes):
                    Kp = math.floor(B.K + 1e-9)
                    Kp_sum += Kp
                    rng = random.Random(1000 + rep)
                    vr = random.Random(5000 + rep)
                    alive = frozenset(range(len(B.hyps)))
                    hc = {x0: human_chain(B, x0, n) for x0 in range(3)}
                    R = A = 0
                    for p in range(T):
                        x0 = rng.randrange(3)
                        i = 0
                        while True:
                            labels, states, mist = make_run(B, alive, x0, n)
                            forced = labels[:n0] == hc[x0][:n0]
                            dev = not forced
                            if name.startswith("blind"):
                                acc = (not dev) or min(mist) >= 2
                            else:
                                acc = verifiers[name](dev, vr)
                            if forced or acc:
                                break
                            alive, hit, _ = search(B, alive, states, mist, n, omega(rep, p, i))
                            assert hit
                            R += 1
                            i += 1
                        if mist:
                            A += 1
                        if rng.random() < beta:  # audit: a uniform step of the output
                            k = rng.randrange(n)
                            alive = B.add(alive, states[k], B.P(states[k]))
                    sR += R
                    sA += A
                    sL += R * math.log2(1 / q) + A * math.log2(1 / (1 - q))
                ER, EA, EL, EK = sR / reps, sA / reps, sL / reps, Kp_sum / reps
                print("   %-36s %5.2f %5d %8.2f %8.2f %10.2f %10.2f %10.2f" % (
                    name, beta, T, ER, EA, ER + beta * EA / n, EL, EK * math.log2(math.e * (1 + n / beta))))
    print("   (bound column: mean K' x log2(e(1+n/beta)); mean K' = %.2f. Neither column grows with T.)"
          % (sum(math.floor(B.K + 1e-9) for B in classes) / reps))


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
