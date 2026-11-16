"""Referee checks for research/prove-c/assumptions.md, part 1: exact enumeration of Protocol R.

Everything in this file is computed exactly (up to floating point) by enumerating all data
paths of the protocol on a small adaptive scaffold. No sampling.

  A  Lemma 0.1 / Lemma 0.2 / Theorem 2.1(a): the oracle inequality (0.4) for every member nu,
     for a human who is in the class, who is outside it, and who moves from round to round;
     hypotheses are semimeasures (missing mass = "no answer"), W < 1, runs can have no call.
  B  Theorem 2.1(b): with A2 the two sides are EQUAL:
     sum_t E Lambda(M^(t)) = L (ln(W/w(P)) - E ln(1/w_{D_n}(P))).
  C  Proposition 2.2: the bound with K_Pi (members that agree with the human on X_Pi).
  D  Theorem 3.2(b): E[R_t | F_{t-1}] = R_{t-1} (1 - d_t), i.e. E[G_n] <= 1 for
     G_n = sqrt(nu(D_n)/P(D_n)) exp(sum_t d_t), and E[sqrt(nu/P) prod 1/(1-d_t)] = 1.
  E  Theorem 3.2(a): Pr[run of round T meets Q and no earlier question in Q] <= L/n,
     for every subset Q of the inputs; the same quantity for the LAST mixture.
  F  Proposition 6.3: batches; and the referee's remark that on a scaffold whose inputs do
     not depend on the answers one batch is as good as n sequential rounds.
  G  Proposition 1.15(c): the variant in which the human's answer continues the run asks
     the same question law (checked through the law of the asked input).
  H  horizon 1, one round, a class with one member: edge cases.

Usage: python3 assumptions_check_exact.py
"""
import itertools
import math

LN2 = math.log(2.0)
NOANS = "~"          # the symbol "no answer" (missing mass of a semimeasure)


# ------------------------------------------------------------------------------------------
# kernels are dicts: x -> dict y -> prob   (sub-probability allowed; NOANS gets the rest)
def kl(p, q, x):
    """KL(p(.|x) || q(.|x)), p a probability on Y, q a sub-probability on Y."""
    tot = 0.0
    for y, py in p[x].items():
        if py <= 0:
            continue
        qy = q[x].get(y, 0.0)
        if qy <= 0:
            return math.inf
        tot += py * math.log(py / qy)
    return tot


def hell2(p, q, x):
    return 1.0 - sum(math.sqrt(py * q[x].get(y, 0.0)) for y, py in p[x].items())


class Scaffold:
    """z uniform on Z; next(z, answers) -> input or None; at most L calls."""

    def __init__(self, Z, nxt, L, X):
        self.Z, self.nxt, self.L, self.X = Z, nxt, L, X

    def runs(self, kernel, answerer_at=None):
        """Enumerate runs of a kernel: yields (prob, z, inputs, answers).
        kernel[x] is a dict y -> prob; missing mass goes to NOANS (one more answer)."""
        out = []

        def rec(z, ys, xs, pr):
            if pr == 0.0:
                return
            x = self.nxt(z, tuple(ys)) if len(ys) < self.L else None
            if x is None:
                out.append((pr, z, tuple(xs), tuple(ys)))
                return
            law = dict(kernel[x])
            rest = 1.0 - sum(law.values())
            if rest > 1e-15:
                law[NOANS] = rest
            for y, py in law.items():
                rec(z, ys + [y], xs + [x], pr * py)

        for z in self.Z:
            rec(z, [], [], 1.0 / len(self.Z))
        return out

    def visit(self, kernel):
        """d(x) = expected number of calls with input x in a run of the kernel."""
        d = {x: 0.0 for x in self.X}
        for pr, _z, xs, _ys in self.runs(kernel):
            for x in xs:
                d[x] += pr
        return d

    def meet(self, kernel, Q):
        return sum(pr for pr, _z, xs, _ys in self.runs(kernel) if any(x in Q for x in xs))


def mixture(H, w, data, X, Y):
    """Posterior weights and the mixture kernel after the data list (tuple of (x, y))."""
    lik = []
    for nu in H:
        l = 1.0
        for x, y in data:
            l *= nu[x].get(y, 0.0)
        lik.append(l)
    xi = sum(wi * li for wi, li in zip(w, lik))
    if xi <= 0:
        post = [wi / sum(w) for wi in w]       # convention M_D := M_empty
        xi = 0.0
    else:
        post = [wi * li / xi for wi, li in zip(w, lik)]
    M = {x: {y: sum(pi * nu[x].get(y, 0.0) for pi, nu in zip(post, H)) for y in Y} for x in X}
    return post, M, xi


def enumerate_protocol(sc, H, w, human, n, X, Y, batch=1):
    """Exact enumeration of Protocol R (or of its batch version).
    human(t) -> kernel of the human of round t (a sampler: probability on Y).
    Returns a list of (prob, data, per-round records)."""
    L = sc.L
    paths = [(1.0, (), ())]
    for t in range(1, n + 1):
        new = []
        for pr, data, rec in paths:
            # the mixture of the round: of the data before the current batch
            if batch == 1:
                frozen = data
            else:
                start = ((t - 1) // batch) * batch          # rounds before this batch
                frozen = rec[start - 1][5] if start >= 1 else ()
            post, M, xi = mixture(H, w, frozen, X, Y)
            d = sc.visit(M)
            P_t = human(t)
            ask_none = 1.0 - sum(d.values()) / L
            r_base = (M, d, P_t, post)
            if ask_none > 1e-15:
                new.append((pr * ask_none, data, rec + ((r_base, None, None, None, None, data),)))
            for x in X:
                if d[x] <= 0:
                    continue
                for y, py in P_t[x].items():
                    if py <= 0:
                        continue
                    nd = data + ((x, y),)
                    new.append((pr * d[x] / L * py, nd, rec + ((r_base, x, y, None, None, nd),)))
        paths = new
    return paths


def lam(d, P, C, X):
    """sum_x d(x) KL(P || C)(x)."""
    tot = 0.0
    for x in X:
        if d[x] > 0:
            k = kl(P, C, x)
            if k == math.inf:
                return math.inf
            tot += d[x] * k
    return tot


# ------------------------------------------------------------------------------------------
def make_scaffold():
    # inputs: 'a' (call 1), then 'b0'/'b1' depending on the answer, then 'c' if the two
    # answers agree; a run whose top-level input is z = 2 makes no call at all.
    X = ['a', 'b0', 'b1', 'c']

    def nxt(z, ys):
        if z == 2:
            return None
        if len(ys) == 0:
            return 'a'
        if ys[0] == NOANS:
            return None
        if len(ys) == 1:
            return 'b0' if ys[0] == 0 else 'b1'
        if len(ys) == 2:
            return 'c' if ys[1] == ys[0] else None
        return None

    return Scaffold([0, 1, 2], nxt, 3, X), X


def bern(p):
    return {0: 1.0 - p, 1: p}


def part_ABCD():
    sc, X = make_scaffold()
    Y = [0, 1]
    P = {'a': bern(0.7), 'b0': bern(0.2), 'b1': bern(0.9), 'c': bern(0.5)}
    nu1 = {'a': bern(0.4), 'b0': bern(0.5), 'b1': bern(0.6), 'c': {0: 0.3, 1: 0.5}}   # semimeasure at c
    nu2 = {'a': {0: 0.2, 1: 0.6}, 'b0': bern(0.1), 'b1': bern(0.99), 'c': bern(0.05)}  # semimeasure at a
    nu3 = {'a': bern(0.7), 'b0': bern(0.2), 'b1': bern(0.9), 'c': bern(0.5)}           # equals P on X_Pi
    P2 = {'a': bern(0.55), 'b0': bern(0.3), 'b1': bern(0.8), 'c': bern(0.6)}           # a second human
    n = 4
    L = sc.L
    print("== A, B: Protocol R on an adaptive scaffold with L = 3 (runs of 0 to 3 calls), n = 4,")
    print("   exact enumeration; hypotheses include semimeasures; W < 1")
    for label, H, w, human, idxP in (
        ("human in the class (A2)", [P, nu1, nu2], [0.05, 0.5, 0.3], lambda t: P, 0),
        ("human outside the class", [nu1, nu2], [0.5, 0.3], lambda t: P, None),
        ("moving human (P for t <= 2, P2 after), outside", [nu1, nu2, P2], [0.4, 0.3, 0.1],
         lambda t: P if t <= 2 else P2, None),
    ):
        paths = enumerate_protocol(sc, H, w, human, n, X, Y)
        W = sum(w)
        tot_pr = sum(p for p, _d, _r in paths)
        lhs = 0.0
        rhs_div = [0.0] * len(H)
        for pr, data, rec in paths:
            for (M, d, P_t, post), x, y, *_ in rec:
                lhs += pr * lam(d, P_t, M, X)
                for i, nu in enumerate(H):
                    rhs_div[i] += pr * lam(d, P_t, nu, X)
        print(f"  {label}: total probability {tot_pr:.12f}; number of data paths {len(paths)}")
        print(f"    left side of (0.4)  sum_t E sum_j KL(P_t || M^(t)) = {lhs:.6f}")
        for i in range(len(H)):
            rhs = L * math.log(W / w[i]) + rhs_div[i]
            ok = "holds" if lhs <= rhs + 1e-9 else "VIOLATED"
            print(f"    member {i}: L ln(W/w) + sum_t E sum_j KL(P_t || nu) = {rhs:.6f}   ({ok})")
        if idxP is not None:
            # Theorem 2.1(b): equality with the information gained about the human
            e_surprise = 0.0
            for pr, data, rec in paths:
                post, _M, _xi = mixture(H, w, data, X, Y)
                e_surprise += pr * math.log(1.0 / post[idxP])
            exact = L * (math.log(W / w[idxP]) - e_surprise)
            print(f"    Theorem 2.1(b): L (ln(W/w(P)) - E ln(1/w_Dn(P))) = {exact:.6f}"
                  f"   (difference from the left side {abs(exact - lhs):.2e})")

    print("== C: Proposition 2.2 (K_Pi): the class {nu1, nu2, nu3, nu4}; nu3 and nu4 equal the")
    print("   human on all inputs of the scaffold, the human itself is not a member")
    H = [nu1, nu2, nu3, dict(nu3)]
    w = [0.5, 0.3, 0.02, 0.03]
    paths = enumerate_protocol(sc, H, w, lambda t: P, n, X, Y)
    lhs = sum(pr * lam(r[0][1], r[0][2], r[0][0], X) for pr, _d, rec in paths for r in rec)
    wPi = 0.05
    print(f"    sum_t E Lambda(M^(t)) = {lhs:.6f} <= L ln(W/w_Pi) = {L * math.log(sum(w) / wPi):.6f}"
          f"   ({'holds' if lhs <= L * math.log(sum(w) / wPi) + 1e-9 else 'VIOLATED'})")

    print("== D: Theorem 3.2(b), class {P, nu1, nu2}, weights (0.05, 0.5, 0.3), n = 4")
    H = [P, nu1, nu2]
    w = [0.05, 0.5, 0.3]
    paths = enumerate_protocol(sc, H, w, lambda t: P, n, X, Y)
    for i in (1, 2):
        nu = H[i]
        EG = 0.0
        Eexact = 0.0
        for pr, data, rec in paths:
            ratio = 1.0
            for x, y in data:
                ratio *= nu[x].get(y, 0.0) / P[x][y]
            sd = 0.0
            prod = 1.0
            for (M, d, P_t, post), *_ in rec:
                dt = sum(d[x] * hell2(P, nu, x) for x in X) / L
                sd += dt
                prod *= 1.0 / (1.0 - dt)
            EG += pr * math.sqrt(ratio) * math.exp(sd)
            Eexact += pr * math.sqrt(ratio) * prod
        print(f"    member {i}: E[G_n] = {EG:.6f} (<= 1);  E[sqrt(nu(D)/P(D)) prod_t 1/(1-d_t)] = {Eexact:.9f} (= 1)")


def part_E():
    print("== E: Theorem 3.2(a). Scaffold: a chain of L calls; call j+1 is made only if call j")
    print("   was answered 1 (the human's answer). Class: f = 1 everywhere, and for each link j a")
    print("   member that answers 0 at link j, with weights 0.99/L each and w(f) = 0.01.")
    print("   (Exact dynamic programme over the set of unrefuted members.)")
    for L in (3, 5, 8):
        X = [f"x{j}" for j in range(1, L + 1)]

        def nxt(z, ys, L=L):
            if len(ys) == 0:
                return "x1"
            if ys[-1] != 1:
                return None
            return f"x{len(ys) + 1}" if len(ys) < L else None

        sc = Scaffold([0], nxt, L, X)
        f = {x: {1: 1.0} for x in X}
        H = [f]
        w = [0.01]
        for j in range(1, L + 1):
            g = {x: ({0: 1.0} if x == f"x{j}" else {1: 1.0}) for x in X}
            H.append(g)
            w.append(0.99 / L)
        Y = [0, 1]
        cache = {}

        def info(alive):
            # alive: frozenset of indices j of unrefuted wrong members (f is always alive)
            if alive not in cache:
                data = tuple((f"x{j}", 1) for j in range(1, L + 1) if j not in alive)
                _post, M, _xi = mixture(H, w, data, X, Y)
                cache[alive] = (M, sc.visit(M))
            return cache[alive]

        subsets = [frozenset(s) for r in range(1, L + 1) for s in itertools.combinations(X, r)]
        if L > 5:
            subsets = [frozenset([x]) for x in X] + [frozenset(X[j:]) for j in range(L)]
        for n in (10, 30, 100):
            worst = (0.0, None)
            worst_last = (0.0, None)
            for Q in subsets:
                dist = {(frozenset(range(1, L + 1)), False): 1.0}
                tot = 0.0
                for t in range(1, n + 2):
                    new = {}
                    step = 0.0
                    for (alive, seen), pr in dist.items():
                        M, d = info(alive)
                        if not seen:
                            step += pr * sc.meet(M, Q)
                        none = 1.0 - sum(d.values()) / L
                        if none > 0:
                            new[(alive, seen)] = new.get((alive, seen), 0.0) + pr * none
                        for j in range(1, L + 1):
                            x = f"x{j}"
                            if d[x] > 0:
                                key = (alive - {j}, seen or (x in Q))
                                new[key] = new.get(key, 0.0) + pr * d[x] / L
                    if t <= n:
                        tot += step
                    else:
                        last = step
                    dist = new
                tot /= n
                if tot > worst[0]:
                    worst = (tot, sorted(Q))
                if last > worst_last[0]:
                    worst_last = (last, sorted(Q))
            print(f"    L = {L}, n = {n:3d}: max over Q of Pr[round T meets Q, no earlier question in Q]"
                  f" = {worst[0]:.5f} at Q = {worst[1]};  L/n = {L / n:.5f}"
                  f"   ({'holds' if worst[0] <= L / n + 1e-12 else 'VIOLATED'})")
            print(f"      the same for the last mixture M^(n+1): max = {worst_last[0]:.5f} at Q = {worst_last[1]}"
                  f"   (ratio to L/(n+1): {worst_last[0] * (n + 1) / L:.2f})")


def chain_last_round():
    """The idealised chain: link l+1 is learned in a round with probability 1/L (the run stops
    there and J hits it). After all links 1..L-1 are learned the run reaches the last call,
    whose input is Q; it is asked with probability 1/L per round.  Exact Markov chain."""
    print("   idealised chain (an unlearned link is answered wrongly with certainty), Q = {last input}:")
    for L in (10, 40, 160):
        best = (0.0, 0)
        avg_ok = True
        # state l = number of learned links among 1..L-1 ; alive = q not yet asked
        dist = [0.0] * L
        dist[0] = 1.0
        cum = 0.0
        nmax = 4 * L * L
        for t in range(1, nmax + 1):
            meet = dist[L - 1]                 # probability: run of round t meets Q, q unasked
            cum += meet
            if cum / t > L / t + 1e-12:
                avg_ok = False
            val = meet * t / L                 # last mixture after t - 1 rounds, against L/(t-1+1)
            if val > best[0]:
                best = (val, t - 1)
            new = [0.0] * L
            for l in range(L - 1):
                new[l] += dist[l] * (1 - 1 / L)
                new[l + 1] += dist[l] / L
            new[L - 1] += dist[L - 1] * (1 - 1 / L)   # q asked with prob 1/L: leaves the event
            dist = new
        print(f"    L = {L:4d}: sum_t Pr[round t meets Q unasked] = {cum:.3f} (<= L = {L});"
              f" last mixture: max_n Pr * (n+1)/L = {best[0]:.2f} at n = {best[1]}"
              f"  (sqrt(L) = {math.sqrt(L):.1f});  bound for round T {'holds' if avg_ok else 'VIOLATED'}")


def part_F():
    print("== F: Proposition 6.3 (batches), same scaffold and class as in A (human in the class)")
    sc, X = make_scaffold()
    Y = [0, 1]
    P = {'a': bern(0.7), 'b0': bern(0.2), 'b1': bern(0.9), 'c': bern(0.5)}
    nu1 = {'a': bern(0.4), 'b0': bern(0.5), 'b1': bern(0.6), 'c': {0: 0.3, 1: 0.5}}
    nu2 = {'a': {0: 0.2, 1: 0.6}, 'b0': bern(0.1), 'b1': bern(0.99), 'c': bern(0.05)}
    H, w = [P, nu1, nu2], [0.05, 0.5, 0.3]
    L = sc.L
    bound = L * math.log(sum(w) / w[0])
    for b, S in ((1, 4), (2, 2), (4, 1)):
        paths = enumerate_protocol(sc, H, w, lambda t: P, b * S, X, Y, batch=b)
        tot = 0.0
        for pr, data, rec in paths:
            for s in range(S):
                (M, d, P_t, post), *_ = rec[s * b]
                tot += pr * lam(d, P_t, M, X)
        print(f"    batches of {b} rounds, S = {S}: sum_s E Lambda(M^[s]) = {tot:.6f} <= L ln(W/w(P)) = {bound:.6f}"
              f"   ({'holds' if tot <= bound + 1e-9 else 'VIOLATED'})")
    print("   referee's remark: a scaffold whose inputs do not depend on the answers; all n questions")
    print("   are drawn and answered in ONE batch, and the mixture of a uniformly chosen prefix is deployed")
    Xn = ['u', 'v', 'w']

    def nxt(z, ys):
        seq = [('u', 'v'), ('v', 'w'), ('u', 'w')][z]
        return seq[len(ys)] if len(ys) < 2 else None

    sc2 = Scaffold([0, 1, 2], nxt, 2, Xn)
    Pn = {'u': bern(0.7), 'v': bern(0.2), 'w': bern(0.9)}
    a1 = {'u': bern(0.4), 'v': bern(0.5), 'w': bern(0.6)}
    a2 = {'u': bern(0.2), 'v': bern(0.1), 'w': bern(0.99)}
    Hn, wn = [Pn, a1, a2], [0.05, 0.5, 0.45]
    n = 5
    # one batch: questions i.i.d. from the visit law / L (it does not depend on the answerer)
    d = sc2.visit(Pn)
    Ln = sc2.L
    paths = [(1.0, ())]
    tot = 0.0
    for t in range(1, n + 1):
        new = []
        for pr, data in paths:
            _post, M, _xi = mixture(Hn, wn, data, Xn, Y)
            tot += pr * lam(sc2.visit(M), Pn, M, Xn)
            for x in Xn:
                for y, py in Pn[x].items():
                    new.append((pr * d[x] / Ln * py, data + ((x, y),)))
        paths = new
    bound = Ln * math.log(sum(wn) / wn[0])
    print(f"    sum over the prefixes t = 1..{n} of E Lambda(M of the first t-1 answers) = {tot:.6f}"
          f" <= L ln(W/w(P)) = {bound:.6f}   ({'holds' if tot <= bound + 1e-9 else 'VIOLATED'})")


def part_G():
    print("== G: Proposition 1.15(c): law of the asked input when the human's answer continues the run")
    sc, X = make_scaffold()
    P = {'a': bern(0.7), 'b0': bern(0.2), 'b1': bern(0.9), 'c': bern(0.5)}
    M = {'a': bern(0.35), 'b0': bern(0.6), 'b1': bern(0.15), 'c': bern(0.8)}
    L = sc.L
    d = sc.visit(M)
    # variant: J drawn first; calls before J answered by M, call J by the human, later calls by M
    law = {x: 0.0 for x in X}
    for J in range(1, L + 1):
        out = []

        def rec(z, ys, xs, pr):
            x = sc.nxt(z, tuple(ys)) if len(ys) < L else None
            if x is None:
                out.append((pr, tuple(xs)))
                return
            k = P if len(ys) + 1 == J else M
            for y, py in k[x].items():
                rec(z, ys + [y], xs + [x], pr * py)

        for z in sc.Z:
            rec(z, [], [], 1.0 / len(sc.Z))
        for pr, xs in out:
            if len(xs) >= J:
                law[xs[J - 1]] += pr / L
    diff = max(abs(law[x] - d[x] / L) for x in X)
    print(f"    max_x |Pr[x asked in the variant] - d_M(x)/L| = {diff:.2e}")


def part_H():
    print("== H: edge cases")
    # horizon 1, a single input, one round; class with the human only
    X = ['x']
    sc = Scaffold([0], lambda z, ys: 'x' if len(ys) == 0 else None, 1, X)
    P = {'x': bern(0.3)}
    for H, w, lab in (([P], [0.25], "class = {P}, W = 0.25"),
                      ([P, {'x': bern(0.9)}], [0.25, 0.75], "class = {P, Bern(0.9)}")):
        for n in (1, 2):
            paths = enumerate_protocol(sc, H, w, lambda t: P, n, X, [0, 1])
            lhs = sum(pr * lam(r[0][1], r[0][2], r[0][0], X) for pr, _d, rec in paths for r in rec)
            print(f"    L = 1, n = {n}, {lab}: sum_t E Lambda = {lhs:.6f} <= ln(W/w(P)) = {math.log(sum(w) / w[0]):.6f}")
    # a class of two functions and a human who changes (Example 1.13): posterior undefined
    f = {'x': {0: 1.0}}
    g = {'x': {1: 1.0}}
    paths = enumerate_protocol(sc, [f, g], [0.5, 0.5], lambda t: f if t == 1 else g, 2, X, [0, 1])
    bad = sum(pr for pr, data, _r in paths if mixture([f, g], [0.5, 0.5], data, X, [0, 1])[2] == 0.0)
    print(f"    Example 1.13 (f in round 1, g in round 2, one input): Pr[xi(D_2) = 0] = {bad:.3f}")


if __name__ == "__main__":
    import sys
    which = sys.argv[1] if len(sys.argv) > 1 else "ABCDEFGH"
    if "A" in which:
        part_ABCD()
    if "E" in which:
        part_E()
        chain_last_round()
    if "F" in which:
        part_F()
    if "G" in which:
        part_G()
    if "H" in which:
        part_H()
