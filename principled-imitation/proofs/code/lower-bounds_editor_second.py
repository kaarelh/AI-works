#!/usr/bin/env python3
"""Editor's checks, second round (16 November 2026), for proofs/lower-bounds.md.

Written after the second check (verification/lower-bounds-second.md).  It shares no code with the
earlier scripts.  Wherever the instances are small enough the law of the whole execution of a
protocol is computed exactly, in rational arithmetic, so that the inequalities are tested without
sampling noise.  The script stops at the first failed assertion.

Part A   Theorem 3.3 (Protocol AB) in the restated form, and Proposition 3.8(1): the exact law of
         the execution on random classes, for X0 = X1, X0 = all inputs that the scaffold can
         produce under arbitrary answers, and X0 = X.  Two families of instances; in the second
         the runs of the vote leave X1 (the case that the second check covered by one example).
Part A2  Proposition 3.8(2) on a human system that tolerates m faults (the sequential-majority
         scaffold of Proposition 5.6 with the region class).
Part B   Proposition 3.9 (the variant that asks only calls of its own runs): exact law.
Part C   Proposition 3.7 (rare-points class): the chain of inequalities, the exact number of
         rounds that Protocol R needs, and the comparison with R1 ("about a seventh").
Part D   Proposition 3.10 (Protocol R on the block class): the failure given the data by brute
         force over the runs, the bound 2L/N, and the exact failure at n = 4mN.
Part E   Proposition 4.6 (S2 with time bounds that grow with the round): exact failure on toy
         machines against the bound.
Part F   Proposition 5.6: (a) the key step on random scaffolds whose inputs depend on the answers;
         (b) tolerance of the sequential-majority scaffold by brute force over replacement rules.
Part G   Proposition 5.7: the counterexample, in exact rational arithmetic.
Part H   Proposition 7.2 and the sentences of the note that the second check questioned:
         arithmetic.
Part I   Remark 1.11 (a protocol without coins) on random instances.
Part J   Theorem 4.1(3): the protocol with n questions, and what "2aN questions suffice" means.
"""
import itertools
import math
import random
import time
from fractions import Fraction as Fr

T0 = time.time()
LN2 = math.log(2)


# ------------------------------------------------------------------------------------------------
# Scaffolds.  A scaffold is a pair (Zn, nxt): the top-level input z is uniform on range(Zn) (it
# stands for (z, rho)), and nxt(z, hist) is the input of the next call after the answers hist, or
# None for STOP.  The horizon L is enforced by nxt.
# ------------------------------------------------------------------------------------------------
def run(nxt, h, z):
    """The run on z when the function h (a tuple indexed by the inputs) answers every call."""
    hist, calls = (), []
    while True:
        x = nxt(z, hist)
        if x is None:
            return tuple(calls)
        calls.append((x, h[x]))
        hist += (h[x],)


def table_scaffold(rnd, nx, Zn, L, Y, stop_p):
    """A random scaffold whose inputs depend on the answers: a random table (z, answers) -> input."""
    table = {}
    for z in range(Zn):
        for j in range(L):
            for hist in itertools.product(Y, repeat=j):
                table[(z, hist)] = None if (j > 0 and rnd.random() < stop_p) else rnd.randrange(nx)
    return lambda z, hist: table.get((z, hist))


def produced_inputs(nxt, Zn, L, Y):
    """All inputs that the scaffold can produce when its calls are answered arbitrarily."""
    res = set()
    for z in range(Zn):
        stack = [()]
        while stack:
            hist = stack.pop()
            x = nxt(z, hist)
            if x is None:
                continue
            res.add(x)
            for y in Y:
                stack.append(hist + (y,))
    return res


def rand_weights(rnd, k):
    """k positive rational weights with sum at most 1."""
    v = [rnd.randint(1, 6) for _ in range(k)]
    return [Fr(a, sum(v) + rnd.choice([0, 0, 1, 3])) for a in v]


# ------------------------------------------------------------------------------------------------
# Part A.  Protocol AB, exactly.
# ------------------------------------------------------------------------------------------------
def ab_exact(H, w, fi, nxt, Zn, L, nx, Y, gamma, nB, X0, X1, outf=None):
    """Exact law of the execution of Protocol AB(gamma, nB) when the human is H[fi].

    A state is (V, a, b, ball): the set of consistent members, the number of steps of type (A),
    the number of audits at inputs of X0 that disagreed (the theorem's b), and the number of all
    audits that disagreed.  Returns the terminal law and the expectations the proofs use."""
    f = H[fi]
    X0s = sorted(X0)
    runs_f = [run(nxt, f, z) for z in range(Zn)]
    post_cache, run_cache = {}, {}

    def post(V):
        if V not in post_cache:
            W = sum(w[i] for i in V)
            post_cache[V] = [[sum(w[i] for i in V if H[i][x] == y) / W for y in Y] for x in range(nx)]
        return post_cache[V]

    def runs_of(h):
        if h not in run_cache:
            run_cache[h] = [run(nxt, h, z) for z in range(Zn)]
        return run_cache[h]

    layer = {(frozenset(range(len(H))), 0, 0, 0): Fr(1)}
    EU = EV = EOUT = Fr(0)
    info = dict(leaves_X1=False, part4_ok=True, audited_outside_X0=False)
    for _ in range(nB):
        new = {}
        for (V, a, b, ball), pr in layer.items():
            while True:                                    # steps of type (A)
                M = post(V)
                split = [x for x in X0s if max(M[x]) <= 1 - gamma]
                if not split:
                    break
                x = split[0]
                assert max(M[x]) < 1                       # an asked input is never asked again
                a += 1
                V = frozenset(i for i in V if H[i][x] == f[x])
            for x in X0s:                                  # a unique answer of weight above 1 - gamma
                assert sum(1 for q in M[x] if q > 1 - gamma) == 1
            h = tuple(Y[max(range(len(Y)), key=lambda j: (M[x][j], -j))] for x in range(nx))
            rh = runs_of(h)
            u = Fr(sum(rh[z] != runs_f[z] for z in range(Zn)), Zn)
            v = Fr(sum(sum(1 for (x, y) in rh[z] if f[x] != y) for z in range(Zn)), Zn)
            EU += pr * u
            EV += pr * v
            if outf is not None:
                EOUT += pr * Fr(sum(outf(z, rh[z]) != outf(z, runs_f[z]) for z in range(Zn)), Zn)
                info.setdefault("per_state", []).append((u, v, Fr(sum(outf(z, rh[z]) != outf(z, runs_f[z])
                                                                    for z in range(Zn)), Zn)))
            if L * gamma < 1:                              # Theorem 3.3(4), second half
                for z in range(Zn):
                    if not any(run(nxt, H[i], z) == rh[z] for i in V):
                        info["part4_ok"] = False
            for z in range(Zn):
                calls = rh[z]
                if any(x not in X1 for (x, _) in calls):
                    info["leaves_X1"] = True
                for J in range(1, L + 1):
                    p2 = pr / (Zn * L)
                    if len(calls) >= J:
                        x = calls[J - 1][0]
                        dis = int(h[x] != f[x])
                        if x not in X0:
                            info["audited_outside_X0"] = True
                        key = (frozenset(i for i in V if H[i][x] == f[x]), a,
                               b + (dis if x in X0 else 0), ball + dis)
                    else:
                        key = (V, a, b, ball)
                    new[key] = new.get(key, 0) + p2
        layer = new
    assert sum(layer.values()) == 1
    return layer, EU, EV, EOUT, info


def chain_instance(rnd):
    """Second family (after the example for Theorem 3.3(5)): core inputs 0..q-1, tail inputs after
    them.  Every member answers 1 at one core input.  The scaffold asks the core inputs in an order
    fixed by z as long as the answers are 0, stops at the first answer 1, and goes on to the tail
    only if all core answers are 0.  So no run of a member reaches the tail: X1 is the core."""
    q, s, t = rnd.choice([4, 5, 6]), rnd.choice([1, 2]), rnd.choice([1, 2])
    nx, L, Y = q + s, q + t, (0, 1)
    H = []
    for i in list(range(q)) + [rnd.randrange(q) for _ in range(rnd.choice([0, 1, 2, 3]))]:
        g = [0] * nx
        g[i] = 1
        for x in range(q, nx):
            g[x] = rnd.randint(0, 1)
        H.append(tuple(g))
    H = list(dict.fromkeys(H))
    Zn = rnd.choice([2, 3, 4])
    perms = [rnd.sample(range(q), q) for _ in range(Zn)]
    tail = {(z, hist): q + rnd.randrange(s) for z in range(Zn) for j in range(t)
            for hist in itertools.product(Y, repeat=j)}

    def nxt(z, hist):
        j = len(hist)
        if j < q:
            return None if any(hist) else perms[z][j]
        if any(hist[:q]) or j - q >= t:
            return None
        return tail[(z, hist[q:])]
    return H, rand_weights(rnd, len(H)), nxt, Zn, L, nx, Y


def generic_instance(rnd):
    nx, Zn, L = rnd.choice([5, 6, 7, 8]), rnd.choice([2, 3, 4]), rnd.choice([2, 3, 4])
    Y = rnd.choice([(0, 1), (0, 1), (0, 1, 2)])
    H = list(dict.fromkeys(tuple(rnd.choice(Y) for _ in range(nx)) for _ in range(rnd.choice([4, 5, 6, 7, 8]))))
    return H, rand_weights(rnd, len(H)), table_scaffold(rnd, nx, Zn, L, Y, 0.2), Zn, L, nx, Y


def part_a():
    print("Part A: Protocol AB (Theorem 3.3, restated form) and Proposition 3.8(1); exact law of the execution")
    rnd = random.Random(20261116)
    gammas = [Fr(1, 10), Fr(1, 8), Fr(1, 4), Fr(2, 5)]
    for fam, maker, count in (("generic", generic_instance, 90), ("chain", chain_instance, 90)):
        st = dict(cases=0, X1_proper=0, leaves=0, b_differs=0, ball_violates=0, ball_violates_under_hyp=0,
                  part4_cases=0, tight1=0, max_ratio2=0.0, nonvacuous2=0, outside=0, eq2=0)
        for _ in range(count):
            H, w, nxt, Zn, L, nx, Y = maker(rnd)
            fi = rnd.randrange(len(H))
            X1 = set()
            for g in H:
                for z in range(Zn):
                    X1 |= {x for (x, _) in run(nxt, g, z)}
            Xarb = produced_inputs(nxt, Zn, L, Y)
            assert X1 <= Xarb
            K = math.log2(1 / w[fi])
            W1 = sum(w)
            for X0name, X0 in (("X1", X1), ("Xarb", Xarb), ("X", set(range(nx)))):
                for gamma in gammas:
                    for nB in (2, 3, 8):
                        term, EU, EV, _, info = ab_exact(H, w, fi, nxt, Zn, L, nx, Y, gamma, nB, X0, X1)
                        st["cases"] += 1
                        st["X1_proper"] += X1 < X0
                        st["leaves"] += info["leaves_X1"]
                        st["outside"] += info["audited_outside_X0"]
                        Eb = sum(p * b for (V, a, b, ball), p in term.items())
                        Eball = sum(p * ball for (V, a, b, ball), p in term.items())
                        hyp = (Xarb <= X0) or (L * gamma < 1)          # hypothesis of Theorem 3.3(4)
                        for (V, a, b, ball), p in term.items():
                            # (1), exactly: (1-gamma)^a gamma^b W_1 >= w(f); so a ln(1/(1-g)) + b ln(1/g) <= K ln 2
                            assert (1 - gamma) ** a * gamma ** b * W1 >= w[fi]
                            assert a * math.log(1 / (1 - gamma)) + b * math.log(1 / gamma) <= K * LN2 + 1e-9
                            assert a <= K * LN2 / float(gamma) + 1e-9 and b <= K / math.log2(1 / gamma) + 1e-9
                            if (1 - gamma) ** a * gamma ** b * W1 == w[fi]:
                                st["tight1"] += 1
                            if b != ball:
                                st["b_differs"] += 1
                                assert not hyp                           # (4): b counts all disagreements
                            if (1 - gamma) ** a * gamma ** ball * W1 < w[fi]:
                                st["ball_violates"] += 1                 # (5): possible only without (4)
                                st["ball_violates_under_hyp"] += hyp
                        if hyp:
                            assert not info["audited_outside_X0"]        # (4), first half
                        if L * gamma < 1:
                            st["part4_cases"] += 1
                            assert info["part4_ok"] and not info["leaves_X1"]   # (4), second half
                        # proof of (2): E sum u_t <= L E[b]; Proposition 3.8(1): E sum v_t = L E[all disagreements]
                        assert EU <= L * Eb
                        assert EV == L * Eball
                        st["eq2"] += (EU == L * Eb and EU > 0)
                        bound2 = L * K / (nB * math.log2(1 / gamma))
                        assert float(EU) / nB <= bound2 + 1e-12          # claim (2)
                        if bound2 < 1:
                            st["nonvacuous2"] += 1
                            st["max_ratio2"] = max(st["max_ratio2"], float(EU) / nB / bound2)
        assert st["ball_violates_under_hyp"] == 0
        print(f"  family '{fam}': {st['cases']} cases (instance, X0, gamma, n_B); X1 a proper subset of X0 in {st['X1_proper']};"
              f" runs of the vote leave X1 in {st['leaves']}; an audited input outside X0 in {st['outside']}")
        print(f"     (1) holds on every path of every case, with equality on {st['tight1']} terminal states;"
              f" L*gamma < 1 in {st['part4_cases']} cases, (4) holds in all of them")
        print(f"     terminal states where the theorem's b differs from the count of all disagreements: {st['b_differs']};"
              f" where (1) with all disagreements fails: {st['ball_violates']} (none under the hypothesis of (4))")
        print(f"     E sum u_t <= L E[b] and E sum v_t = L E[all disagreements] hold exactly in every case"
              f" (the first with equality and E[b] > 0 in {st['eq2']});")
        print(f"     (2): the bound is below 1 in {st['nonvacuous2']} cases; largest failure/bound there {st['max_ratio2']:.3f}")
    # the example for Theorem 3.3(5), through the same engine
    H = [tuple(1 if (x == i or (x == 9 and i < 4)) else 0 for x in range(10)) for i in range(9)]
    w = [Fr(1, 9)] * 9

    def nxt(z, hist):
        j = len(hist)
        if j < 9:
            return None if any(hist) else j
        return 9 if (j == 9 and not any(hist)) else None
    X1 = set()
    for g in H:
        X1 |= {x for (x, _) in run(nxt, g, 0)}
    assert X1 == set(range(9))
    term, EU, EV, _, info = ab_exact(H, w, 0, nxt, 1, 10, 10, (0, 1), Fr(1, 8), 2, X1, X1)
    bad = [(a, b, ball, p) for (V, a, b, ball), p in term.items() if Fr(7, 8) ** a * Fr(1, 8) ** ball < Fr(1, 9)]
    assert bad == [(1, 0, 1, Fr(1, 10))]
    print(f"  example for (5): the path with (a, b, all disagreements) = (1, 0, 1) has probability 1/10;"
          f" (7/8)(1/8) = 7/64 < 1/9; (1) holds with the theorem's b; E sum u_t = {EU} <= L E[b] = {10 * sum(p * b for (V, a, b, ball), p in term.items())}")


# ------------------------------------------------------------------------------------------------
# The sequential-majority scaffold of Proposition 5.6(b).  Answers may be 0, 1 or None (silence).
# ------------------------------------------------------------------------------------------------
def seqmaj(m, B, horizon=None, want_walk=False):
    """Returns (nxt, outf, L) for z = (R_1, ..., R_B); inputs are pairs (region, copy).  With
    `horizon` the cut at L = B(m+1)+m calls is replaced by a cut at that number."""
    L = B * (m + 1) + m
    cap = L if horizon is None else horizon

    def walk(z, hist):
        pos, vals = 0, []
        for bidx in range(B):
            cnt, c = {0: 0, 1: 0}, 0
            while max(cnt.values()) < m + 1:
                if c >= 2 * m + 1:
                    return ("cut", None, vals)              # a call beyond (R_b, 2m+1): outcome 0
                if pos == len(hist):
                    if pos >= cap:
                        return ("cut", None, vals)          # a call beyond the horizon: outcome 0
                    return ("call", (z[bidx], c), vals)
                y = hist[pos]
                pos += 1
                c += 1
                if y in cnt:
                    cnt[y] += 1
            vals.append(0 if cnt[0] >= m + 1 else 1)
        return ("end", None, vals)

    def nxt(z, hist):
        kind, x, _ = walk(z, hist)
        return x if kind == "call" else None

    def outf(z, hist):
        kind, _, vals = walk(z, hist)
        return max(vals) if kind == "end" else 0
    return (nxt, outf, L, walk) if want_walk else (nxt, outf, L)


def part_a2():
    print("Part A2: Proposition 3.8(2) on the sequential-majority scaffold (tolerates m faults), X0 = X")
    worst = 0.0
    cases = 0
    for (m, B, N0) in ((1, 2, 3), (2, 1, 3), (1, 1, 4)):
        nxt_p, outf_p, L = seqmaj(m, B)
        inputs = [(i, c) for i in range(N0) for c in range(2 * m + 1)]
        idx = {x: k for k, x in enumerate(inputs)}
        zs = list(itertools.product(range(N0), repeat=B))

        def nxt(z, hist):
            x = nxt_p(zs[z], hist)
            return None if x is None else idx[x]

        def outf(z, calls):
            return outf_p(zs[z], tuple(y for (_, y) in calls))
        H = [tuple(0 for _ in inputs)] + [tuple(1 if x[0] == i else 0 for x in inputs) for i in range(N0)]
        for w in ([Fr(1, N0 + 1)] * (N0 + 1), [Fr(1, 2)] + [Fr(1, 2 * N0 + 1)] * N0):
            for fi in range(len(H)):
                K = math.log2(1 / w[fi])
                for gamma in (Fr(1, 5), Fr(1, 3), Fr(9, 20)):
                    for nB in (1, 2, 4):
                        X = set(range(len(inputs)))
                        term, EU, EV, EOUT, info = ab_exact(H, w, fi, nxt, len(zs), L, len(inputs), (0, 1), gamma, nB, X, X, outf)
                        cases += 1
                        for (u, v, o) in info["per_state"]:
                            assert o <= v / (m + 1) and o <= u       # tolerance and Markov, state by state
                        bound = L * K / ((m + 1) * nB * math.log2(1 / gamma))
                        assert float(EOUT) / nB <= float(EV) / nB / (m + 1) + 1e-15 <= bound + 1e-12
                        if bound > 0:
                            worst = max(worst, float(EOUT) / nB / bound)
    print(f"  {cases} cases (three scaffolds, two priors, every member as the human, three gamma, three n_B):")
    print(f"     Pr[outcome of the deployed run wrong] <= E[faults]/(m+1) <= L K/((m+1) n_B log(1/gamma)) in all;"
          f" largest ratio of the first to the last: {worst:.3f}")


# ------------------------------------------------------------------------------------------------
# Part B.  Proposition 3.9: the variant that asks only calls of its own rehearsal runs.
# ------------------------------------------------------------------------------------------------
def variant_exact(H, w, fi, nxt, Zn, L, nx, Y, n):
    gamma = math.log(L) / L
    f = H[fi]
    runs_f = [run(nxt, f, z) for z in range(Zn)]
    layer = {(frozenset(range(len(H))), 0, 0): Fr(1)}
    EU = Fr(0)
    cache = {}
    for _ in range(n):
        new = {}
        for (V, a, b), pr in layer.items():
            if V not in cache:
                W = sum(w[i] for i in V)
                M = [[sum(w[i] for i in V if H[i][x] == y) / W for y in Y] for x in range(nx)]
                h = tuple(Y[max(range(len(Y)), key=lambda j: (M[x][j], -j))] for x in range(nx))
                split = frozenset(x for x in range(nx) if float(max(M[x])) <= 1 - gamma)
                cache[V] = (h, split, [run(nxt, h, z) for z in range(Zn)])
            h, split, rh = cache[V]
            u = Fr(sum(rh[z] != runs_f[z] for z in range(Zn)), Zn)
            EU += pr * u
            alpha = second = Fr(0)
            for z in range(Zn):
                calls = rh[z]
                sp = [x for (x, _) in calls if x in split]
                if sp:                                   # the first call with a split input is asked
                    alpha += Fr(1, Zn)
                    key = (frozenset(i for i in V if H[i][sp[0]] == f[sp[0]]), a + 1, b)
                    new[key] = new.get(key, 0) + pr / Zn
                    continue
                for J in range(1, L + 1):
                    if len(calls) >= J:
                        x = calls[J - 1][0]
                        dis = int(h[x] != f[x])
                        second += Fr(dis, Zn * L)
                        key = (frozenset(i for i in V if H[i][x] == f[x]), a, b + dis)
                    else:
                        key = (V, a, b)
                    new[key] = new.get(key, 0) + pr / (Zn * L)
            assert u <= alpha + L * second               # the step of the proof, state by state
        layer = new
    return layer, EU, gamma


def part_b():
    print("Part B: Proposition 3.9 (questions are calls of the protocol's own runs); exact law of the execution")
    rnd = random.Random(39)
    cases = nonvac = 0
    worst = worstpot = 0.0
    for _ in range(120):
        nx, Zn, L = rnd.choice([5, 6, 7, 8]), rnd.choice([2, 3, 4]), rnd.choice([3, 4, 5])
        Y = rnd.choice([(0, 1), (0, 1), (0, 1, 2)]) if L < 5 else (0, 1)
        H = list(dict.fromkeys(tuple(rnd.choice(Y) for _ in range(nx)) for _ in range(rnd.choice([4, 6, 8]))))
        w = rand_weights(rnd, len(H))
        nxt = table_scaffold(rnd, nx, Zn, L, Y, 0.15)
        fi = rnd.randrange(len(H))
        K = math.log2(1 / w[fi])
        for n in (3, 8, 20):
            term, EU, gamma = variant_exact(H, w, fi, nxt, Zn, L, nx, Y, n)
            cases += 1
            for (V, a, b), p in term.items():
                pot = a * math.log(1 / (1 - gamma)) + b * math.log(1 / gamma)
                assert pot <= K * LN2 + 1e-9
                worstpot = max(worstpot, pot / (K * LN2))
            EaLb = sum(p * (a + L * b) for (V, a, b), p in term.items())
            assert EU <= EaLb
            assert float(EaLb) <= K * LN2 * L / math.log(L / math.log(L)) + 1e-9
            bound = K * L / (n * math.log2(L / math.log(L)))
            assert float(EU) / n <= bound + 1e-12
            if bound < 1:
                nonvac += 1
                worst = max(worst, float(EU) / n / bound)
    print(f"  {cases} cases: a ln(1/(1-g)) + b ln(1/g) <= K ln 2 on every path (largest ratio {worstpot:.3f});"
          f" u_t <= alpha_t + L Pr[disagreement of the second kind] in every state;")
    print(f"     E sum u_t <= E[a + L b] <= K ln 2 L/ln(L/ln L) exactly; the bound K L/(n log2(L/ln L)) is below 1 in {nonvac} cases,"
          f" largest failure/bound there {worst:.3f}")
    for L in (3, 4, 10, 1000):
        g = math.log(L) / L
        assert g < 0.5 and abs(max(1 / math.log(1 / (1 - g)), L / math.log(1 / g)) - L / math.log(L / math.log(L))) < 1e-9
    print(f"  ln(L/ln L) = {math.log(3 / math.log(3)):.4f} at L = 3 and {math.log(1000 / math.log(1000)):.3f} at L = 1000")


# ------------------------------------------------------------------------------------------------
# Part C.  Proposition 3.7: the rare-points class.
# ------------------------------------------------------------------------------------------------
def rare_curves(d, L, eps, nmax):
    """Protocol R on the rare-points class: F[n-1] = Pr[run of M^(T) unfaithful], T uniform on [n].
    A point that was not asked is answered by a fair coin at every call, so the failure given u
    unasked points is 1 - (1 - q u/(2d))^L, the same for every member."""
    q = 4 * eps / L
    dist = [1.0] + [0.0] * d                 # law of the number of distinct points asked so far
    F, cum = [], 0.0
    for t in range(1, nmax + 1):
        cum += sum(pr * (1 - (1 - q * (d - a) / (2 * d)) ** L) for a, pr in enumerate(dist))
        F.append(cum / t)
        new = [0.0] * (d + 1)
        for a, pr in enumerate(dist):
            new[a] += pr * (1 - q * (d - a) / d)
            if a < d:
                new[a + 1] += pr * q * (d - a) / d
        dist = new
    return F


def rare_variant(d, L, eps, nmax, worst_member):
    """The variant of Proposition 3.9 on the same class: a round finds an unasked point with
    probability 1 - (1 - q u/d)^L; the deployed vote answers 0 (first in the order) at an unasked
    point.  Failure for the member that is 1 everywhere on [d] (worst_member), or on average over
    the members."""
    q = 4 * eps / L
    dist = [0.0] * d + [1.0]                 # law of the number u of unasked points
    F, cum = [], 0.0
    for t in range(1, nmax + 1):
        if worst_member:
            cum += sum(pr * (1 - (1 - q * u / d) ** L) for u, pr in enumerate(dist))
        else:
            cum += sum(pr * sum(math.comb(u, j) * 0.5 ** u * (1 - (1 - q * j / d) ** L) for j in range(u + 1))
                       for u, pr in enumerate(dist) if pr > 0)
        F.append(cum / t)
        new = [0.0] * (d + 1)
        for u, pr in enumerate(dist):
            hit = 1 - (1 - q * u / d) ** L
            new[u] += pr * (1 - hit)
            if u > 0:
                new[u - 1] += pr * hit
        dist = new
    return F


def part_c():
    print("Part C: Proposition 3.7 (rare-points class)")
    worst = 1e9
    for eps in (Fr(1, 8), Fr(1, 10), Fr(1, 20), Fr(1, 100), Fr(1, 10 ** 4), Fr(1, 10 ** 8)):
        for L in (1, 2, 3, 7, 100, 10 ** 5):
            for d in (1, 2, 3, 10, 10 ** 4):
                lhs = math.log(2 * (1 - 2 * float(eps))) * (L * d / (4 * float(eps)) - 1)
                worst = min(worst, lhs - (0.1 * d * L / float(eps) - 0.4))
                assert Fr(L * d) / (4 * eps) >= 2                  # so that (c - 0.4)(Ld/(4 eps) - 1) >= 0
    assert worst >= 0 and math.log(1.5) > 0.4
    print(f"  ln(2(1-2eps))(Ld/(4eps) - 1) - (0.1 K L/eps - 0.4) >= {worst:.4f} >= 0 on the grid; ln 1.5 = {math.log(1.5):.5f}")
    print("     d    L    eps    R: least n   n eps/(K L)   bound of (a)   ceil(L K ln2/eps)   variant 3.9: least n (average member, worst member)")
    for (d, L, eps) in ((8, 4, 0.125), (8, 8, 0.125), (16, 4, 0.125), (16, 16, 0.0625), (32, 8, 0.0625), (32, 16, 0.03125)):
        q = 4 * eps / L
        up = math.ceil(L * d * LN2 / eps)
        F = rare_curves(d, L, eps, up)
        for n in range(1, up + 1):                                 # the inequality of (a) for Protocol R
            assert F[n - 1] >= 2 * eps * (1 - 2 * eps) * (1 - q / d) ** n - 1e-12
        nR = next(n for n in range(1, up + 1) if F[n - 1] <= eps)
        lb = math.log(2 * (1 - 2 * eps)) * (L * d / (4 * eps) - 1)
        assert lb <= nR <= up
        Fa = rare_variant(d, L, eps, up, False)
        Fw = rare_variant(d, L, eps, up, True)
        na = next(n for n in range(1, up + 1) if Fa[n - 1] <= eps)
        nw = next(n for n in range(1, up + 1) if Fw[n - 1] <= eps)
        assert nw <= d * L / (eps * math.log2(L / math.log(L)))    # the guarantee of Proposition 3.9
        print(f"   {d:3d}  {L:3d}  {eps:.4f}   {nR:8d}      {nR * eps / (d * L):.3f}        {lb:8.1f}        {up:8d}"
              f"            {na:5d} = {na * eps / d:.2f} K/eps,  {nw:5d} = {nw * eps / d:.2f} K/eps")
    x1 = 0.4 / (0.1 - LN2 / 7)
    x2 = (0.4 + 1 / 7) / (0.1 - LN2 / 7)
    print(f"  0.1/ln 2 = {0.1 / LN2:.4f} = 1/{LN2 / 0.1:.3f}; 0.1 x - 0.4 >= (x ln 2)/7 iff x = K L/eps >= {x1:.1f};"
          f" 0.1 x - 0.4 >= (x ln 2 + 1)/7 iff x >= {x2:.1f}")
    assert 408 < x1 < 409 and 554 < x2 < 555
    # against the bound of Theorem 3.3(3): 0.1 x - 0.4 > 1 + 2.7 x/log2(L/eps) needs log2(L/eps) > 27
    for lg in (20, 26.9, 27):
        assert all(0.1 * x - 0.4 <= 1 + 2.7 * x / lg for x in (1e2, 1e6, 1e12, 1e18))
    assert 0.1 * 1e12 - 0.4 > 1 + 2.7 * 1e12 / 27.001
    print("  0.1 x - 0.4 > 1 + 2.7 x/log2(L/eps) is impossible for log2(L/eps) <= 27 and holds for large x above 27")


# ------------------------------------------------------------------------------------------------
# Part D.  Proposition 3.10: Protocol R on the block class.
# ------------------------------------------------------------------------------------------------
def block_fail_bruteforce(N, L, k):
    """Block j, needle at cell 0 not asked, cells 1..k asked (answered 0).  Exact probabilities that
    the outcome of a run of the per-call mixture is wrong, and that the run is unfaithful."""
    fail = unf = Fr(0)
    pone = Fr(1, N - k)                                  # mixture answers 1 at an unasked cell
    for cells in itertools.product(range(N), repeat=L):
        c = sum(1 for u in cells if u == 0 or u > k)     # calls at unasked cells (needle included)
        zero = (1 - pone) ** c                           # Pr[all answers 0]
        truth = int(0 in cells)
        fail += (zero if truth else 1 - zero)
        faithful = Fr(1)
        for u in cells:
            faithful *= pone if u == 0 else (1 - pone if u > k else 1)
        unf += 1 - faithful
    return fail / N ** L, unf / N ** L


def part_d():
    print("Part D: Proposition 3.10 (Protocol R on the block class)")
    cnt = 0
    for N in range(2, 8):
        for L in range(1, 4):
            for k in range(N):
                fail, unf = block_fail_bruteforce(N, L, k)
                c0 = Fr(k, N) + Fr((N - k - 1) ** 2, N * (N - k))
                assert fail == 2 * ((1 - Fr(1, N)) ** L - c0 ** L)                   # closed form
                assert unf == 1 - (1 - Fr(2 * (N - k - 1), N * (N - k))) ** L
                assert fail <= unf <= Fr(2 * L, N)                                   # the bound of the proof
                cnt += 1
    print(f"  brute force over all runs, N <= 7, L <= 3, every k: {cnt} cases; failure = 2[(1-1/N)^L - c0^L] <= Pr[unfaithful] <= 2L/N")
    print("     m     N    L    delta    failure at n = 4mN   Pr[unfaithful] at 4mN   least n: failure, unfaithful (in units of mN)")
    cases = 0
    for (m, N, L) in [(1, 2, 1), (1, 3, 1), (2, 4, 2), (3, 5, 2), (1, 8, 1), (5, 12, 3), (2, 20, 4), (3, 40, 4),
                      (16, 128, 4), (32, 256, 8), (64, 256, 4), (4, 1000, 10)]:
        delta = L / (2 * N)
        fk = [2 * ((1 - 1 / N) ** L - (k / N + (N - k - 1) ** 2 / (N * (N - k))) ** L) for k in range(N)]
        uk = [1 - (1 - 2 * (N - k - 1) / (N * (N - k))) ** L for k in range(N)]
        dist = [1.0] + [0.0] * (N - 1)                   # needle unasked, k other cells of the block asked
        n = 4 * m * N
        cf = cu = 0.0
        nf = nu = None
        for t in range(1, n + 1):
            cf += sum(p * a for p, a in zip(dist, fk))
            cu += sum(p * a for p, a in zip(dist, uk))
            if nf is None and cf / t <= delta:
                nf = t
            if nu is None and cu / t <= delta:
                nu = t
            new = [0.0] * N
            for k, p in enumerate(dist):
                new[k] += p * (1 - (N - k) / (m * N))    # the question is not an unasked cell of this block
                if k + 1 < N:
                    new[k + 1] += p * (N - 1 - k) / (m * N)
            dist = new
        assert cf / n <= cu / n + 1e-12 and cu / n <= delta + 1e-12 and nf is not None and nu is not None
        cases += 1
        print(f"  {m:4d} {N:5d} {L:4d}   {delta:.5f}      {cf / n:.6f}             {cu / n:.6f}              {nf / (m * N):.3f}, {nu / (m * N):.3f}"
              f"   ({nf}, {nu})")
    print(f"  in all {cases} cases the failure and the probability of an unfaithful run are at most delta at n = 4mN")


# ------------------------------------------------------------------------------------------------
# Part E.  Proposition 4.6: S2 with time bounds that grow with the round, on toy machines.
# ------------------------------------------------------------------------------------------------
def part_e():
    print("Part E: Proposition 4.6 on toy machines (programs = binary strings of length <= 2, weights 2^(-2|p|-1))")
    rnd = random.Random(46)
    progs = [""] + ["0", "1"] + ["00", "01", "10", "11"]
    pi = [2.0 ** (-2 * len(p) - 1) for p in progs]
    worst = worst_pot = 0.0
    nonvac = total = 0
    for inst in range(40):
        nx, Zn, L, Tmax = rnd.choice([4, 5, 6]), rnd.choice([3, 4, 5]), rnd.choice([1, 2, 3]), rnd.choice([3, 6, 12])
        Y = (0, 1)
        H = list(dict.fromkeys(tuple(rnd.choice(Y) for _ in range(nx)) for _ in range(rnd.choice([3, 4, 6]))))
        wts = [float(a) for a in rand_weights(rnd, len(H))]
        fi = max(range(len(H)), key=lambda i: wts[i]) if inst % 2 else rnd.randrange(len(H))
        f = H[fi]
        K = math.log2(1 / wts[fi])
        nxt = table_scaffold(rnd, nx, Zn, L, Y, 0.2)
        # each program: a joint law of (halting time in 1..Tmax, output z); it halts with probability one
        law = []
        for p in progs:
            cells = {(t, z): rnd.random() ** 3 for t in range(1, Tmax + 1) for z in range(Zn)}
            if rnd.random() < 0.5:                         # a slow program: most mass at late times
                for (t, z) in cells:
                    cells[(t, z)] *= 10.0 ** t
            tot = sum(cells.values())
            law.append({key: v / tot for key, v in cells.items()})
        n = rnd.choice([10, 40, 120])
        kind = rnd.choice(["slow", "fast", "const"])
        b = [1 + (t // (n // 3 + 1) if kind == "slow" else (t if kind == "fast" else 0)) for t in range(1, n + 1)]
        assert all(b[i] <= b[i + 1] for i in range(n - 1))
        cache = {}

        def analyse(V):
            """For the mixture of the consistent set V: for each z, the probability u that its run is
            unfaithful, the expected number beta of unfaithful calls, and the law of the next V."""
            if V in cache:
                return cache[V]
            W = sum(wts[i] for i in V)
            M = [[sum(wts[i] for i in V if H[i][x] == y) / W for y in Y] for x in range(nx)]
            res = []
            for z in range(Zn):
                u_faithful, beta, trans = 1.0, 0.0, {}
                for (x, y) in run(nxt, f, z):
                    u_faithful *= M[x][y]
                stack = [((), 1.0)]
                while stack:                               # the tree of the mixture's own run
                    hist, pr = stack.pop()
                    x = nxt(z, hist)
                    j = len(hist)
                    if x is None:                          # the run has j calls; audits J > j ask nothing
                        trans[V] = trans.get(V, 0.0) + pr * (L - j) / L
                        continue
                    beta += pr * (1 - M[x][f[x]])
                    V2 = frozenset(i for i in V if H[i][x] == f[x])
                    trans[V2] = trans.get(V2, 0.0) + pr / L   # this call is the audited one
                    for yi, y in enumerate(Y):
                        if M[x][yi] > 0:
                            stack.append((hist + (y,), pr * M[x][yi]))
                res.append((1 - u_faithful, beta, trans))
            cache[V] = res
            return res

        dist = {frozenset(range(len(H))): 1.0}
        fail = [0.0] * len(progs)
        pot = 0.0
        tau_sum = [0.0] * len(progs)
        for t in range(1, n + 1):
            xi = [sum(pi[k] * sum(v for (tt, z2), v in law[k].items() if tt <= b[t - 1] and z2 == z) for k in range(len(progs)))
                  for z in range(Zn)]
            Dz = [[sum(v for (tt, z2), v in law[k].items() if z2 == z) for z in range(Zn)] for k in range(len(progs))]
            Dt = [[sum(v for (tt, z2), v in law[k].items() if z2 == z and tt <= b[t - 1]) for z in range(Zn)] for k in range(len(progs))]
            tau = [1 - sum(Dt[k]) for k in range(len(progs))]
            new = {}
            for V, pr in dist.items():
                res = analyse(V)
                pot += pr * sum(xi[z] * res[z][1] for z in range(Zn))
                for k in range(len(progs)):
                    fk = sum(Dz[k][z] * res[z][0] for z in range(Zn))
                    fail[k] += pr * fk
                    # the step of the proof: E_D u <= E_{D^(t)} beta + tau, and D^(t) <= xi^(t)/pi
                    assert fk <= sum(Dt[k][z] * res[z][1] for z in range(Zn)) + tau[k] + 1e-12
                    assert all(Dt[k][z] <= xi[z] / pi[k] + 1e-12 for z in range(Zn))
                stay = 1 - sum(xi)
                new[V] = new.get(V, 0.0) + pr * stay
                for z in range(Zn):
                    for V2, q in res[z][2].items():
                        new[V2] = new.get(V2, 0.0) + pr * xi[z] * q
            dist = new
            for k in range(len(progs)):
                tau_sum[k] += tau[k]
        assert abs(sum(dist.values()) - 1) < 1e-9
        assert pot <= L * K * LN2 + 1e-9                     # sum_t E sum_z xi^(t)(z) beta_t(z) <= L K ln 2
        worst_pot = max(worst_pot, pot / (L * K * LN2))
        for k in range(len(progs)):
            bound = L * K * LN2 / (pi[k] * n) + tau_sum[k] / n
            assert fail[k] / n <= bound + 1e-12
            total += 1
            if bound < 1:
                nonvac += 1
                worst = max(worst, fail[k] / n / bound)
    print(f"  40 machines, 7 programs each ({total} pairs of machine and task law): the bound holds in all;"
          f" it is below 1 in {nonvac}, largest failure/bound there {worst:.3f}")
    print(f"     sum over rounds of E sum_z xi(z) beta(z) <= L K ln 2 (largest ratio {worst_pot:.3f}); the two steps of the proof hold in every state")
    print("  weights: sum over l <= 60 of 2^l 2^(-2l-1) =", float(sum(Fr(2 ** l, 2 ** (2 * l + 1)) for l in range(61))))


# ------------------------------------------------------------------------------------------------
# Part F.  Proposition 5.6.
# ------------------------------------------------------------------------------------------------
YEXT = (0, 1, None)


def outcomes_with_replacements(nxt, outf, f, z, m, maxlen=None):
    """All outcomes of the run of f on z under rules that replace at most m answers by any element
    of Y or by silence; also the largest number of calls of such a run."""
    res, longest = set(), [0]

    def rec(hist, used):
        x = nxt(z, hist)
        if x is None:
            res.add(outf(z, hist))
            longest[0] = max(longest[0], len(hist))
            return
        rec(hist + (f[x],), used)
        if used < m:
            for y in YEXT:
                if y != f[x]:
                    rec(hist + (y,), used + 1)
    rec((), 0)
    return res, longest[0]


def part_f():
    print("Part F: Proposition 5.6")
    # (b): the sequential-majority scaffold tolerates m faults; never more than B(m+1)+m calls
    for (m, B, N0) in ((0, 1, 2), (0, 3, 3), (1, 1, 2), (1, 2, 3), (1, 3, 2), (2, 1, 3), (2, 2, 2), (3, 1, 2), (3, 2, 2), (2, 3, 2)):
        nxt_p, outf_p, L = seqmaj(m, B)
        nxt_free, outf_free, _ = seqmaj(m, B, horizon=10 ** 6)       # the same scaffold without the cut at L
        inputs = [(i, c) for i in range(N0) for c in range(2 * m + 1)]
        members = [{x: 0 for x in inputs}] + [{x: int(x[0] == i) for x in inputs} for i in range(N0)]
        breaks = False
        for f in members:
            for z in itertools.product(range(N0), repeat=B):
                hist = ()
                while nxt_p(z, hist) is not None:
                    hist += (f[nxt_p(z, hist)],)
                true = outf_p(z, hist)
                assert len(hist) == B * (m + 1)                       # exactly m+1 calls in each block
                res, longest = outcomes_with_replacements(nxt_free, outf_free, f, z, m)
                assert res == {true} and longest <= L                  # tolerant; the run is never cut off
                res2, _ = outcomes_with_replacements(nxt_p, outf_p, f, z, m)
                assert res2 == {true}
                res3, _ = outcomes_with_replacements(nxt_p, outf_p, f, z, m + 1)
                breaks |= (res3 != {true})
        assert breaks                                                  # m+1 replacements can change the outcome
    print("  (b) ten triples (m, B, N0), every member, every z, every rule with at most m replacements (answers 0, 1 or silence):")
    print("      the outcome is the human system's, the run has at most B(m+1)+m calls, and m+1 replacements can change the outcome")
    # (a): the key step, on random scaffolds whose inputs depend on the answers
    rnd = random.Random(56)
    pairs = differ = strict = tolerant = 0
    for _ in range(150):
        nx, Zn, L = rnd.choice([4, 5, 6]), rnd.choice([3, 4, 6]), rnd.choice([2, 3, 4])
        table = {}
        outs = {}
        coarse = rnd.random() < 0.7
        for z in range(Zn):
            for j in range(L + 1):
                for hist in itertools.product(YEXT, repeat=j):
                    if j < L:
                        table[(z, hist)] = None if (j > 0 and rnd.random() < 0.15) else rnd.randrange(nx)
                    outs[(z, hist)] = rnd.randrange(2) if coarse else hist
        nxt = lambda z, hist: table.get((z, hist))
        outf = lambda z, hist: outs[(z, hist)]
        for _ in range(4):
            f0 = tuple(rnd.randint(0, 1) for _ in range(nx))
            Di = set(rnd.sample(range(nx), rnd.randint(1, 3)))
            fi = tuple(1 - f0[x] if x in Di else f0[x] for x in range(nx))
            pairs += 1
            # tolerance level of the human system of f_i: the largest m such that no rule with at most m
            # replacements changes the outcome for any z
            level = 0
            while level < L and all(outcomes_with_replacements(nxt, outf, fi, z, level + 1)[0] ==
                                    {outcomes_with_replacements(nxt, outf, fi, z, 0)[0].pop()} for z in range(Zn)):
                level += 1
            tolerant += level >= 1
            Delta = Ec = Fr(0)
            for z in range(Zn):
                hist0 = ()
                c = 0
                while nxt(z, hist0) is not None:
                    x = nxt(z, hist0)
                    c += x in Di
                    hist0 += (f0[x],)
                o0 = outf(z, hist0)
                oi = outcomes_with_replacements(nxt, outf, fi, z, 0)[0].pop()
                Ec += Fr(c, Zn)
                if oi != o0:
                    differ += 1
                    Delta += Fr(1, Zn)
                    r = next(r for r in range(L + 1) if o0 in outcomes_with_replacements(nxt, outf, fi, z, r)[0])
                    assert r <= c                      # c replacements turn the run of f_i into that of f_0
                    assert c >= level + 1              # so tolerance of `level` faults forces c >= level + 1
                    strict += (r < c)
            assert Delta <= Ec / (level + 1)
    print(f"  (a) {pairs} pairs (f_0, f_i) on 150 random scaffolds: in the {differ} cases (pair, z) with different outcomes, the least")
    print(f"      number of replacements that turns the outcome of f_i into that of f_0 is at most the number c of calls of the run")
    print(f"      of f_0 in D_i (smaller in {strict}).  The tolerance level of f_i is at least 1 for {tolerant} of these pairs, so the")
    print(f"      consequences c >= level + 1 and Pr[outcomes differ] <= E[c]/(level+1) are tested with level = 0 here and with")
    print(f"      level = m >= 1 on the tolerant systems of the next line")
    # (a) on tolerant systems: sequential majority with a random function of the block values as outcome
    tol = 0
    for (m, B, N0) in ((1, 2, 3), (2, 2, 2), (1, 3, 2)):
        nxt_p, _, L = seqmaj(m, B)
        _, _, _, walk = seqmaj(m, B, want_walk=True)
        inputs = [(i, c) for i in range(N0) for c in range(2 * m + 1)]
        for _ in range(6):
            gtab = {vals: rnd.randrange(2) for vals in itertools.product((0, 1), repeat=B)}

            def outf(z, hist):
                kind, _, vals = walk(z, hist)
                return gtab[tuple(vals)] if kind == "end" else 0
            base = [rnd.randint(0, 1) for _ in range(N0)]
            f0 = {x: base[x[0]] for x in inputs}
            total = Fr(0)
            for i in range(N0):
                fi = {x: (1 - base[i] if x[0] == i else base[x[0]]) for x in inputs}
                for z in itertools.product(range(N0), repeat=B):
                    oi = outcomes_with_replacements(nxt_p, outf, fi, z, 0)[0].pop()
                    assert outcomes_with_replacements(nxt_p, outf, fi, z, m)[0] == {oi}     # f_i tolerates m faults
                    hist0, c = (), 0
                    while nxt_p(z, hist0) is not None:
                        x = nxt_p(z, hist0)
                        c += (x[0] == i)
                        hist0 += (f0[x],)
                    if outf(z, hist0) != oi:
                        assert c >= m + 1
                        total += Fr(1, N0 ** B)
                        tol += 1
            assert total <= Fr(L, m + 1)                # sum_i Pr[out_{f_i} != out_{f_0}] <= L/(m+1)
    print(f"      18 tolerant systems (sequential majority, a random function of the block values as outcome): {tol} cases with")
    print(f"      different outcomes, each with at least m+1 calls of the run of f_0 in the patch; sum_i Delta_i <= L/(m+1)")
    for (dl, Bp) in ((0.01, 7.0), (0.05, 20.0), (0.2, 3.5)):
        assert max(N - dl * N * N / Bp for N in range(1, 2000)) <= Bp / (4 * dl) + 1e-9


# ------------------------------------------------------------------------------------------------
# Part G.  Proposition 5.7: the counterexample.
# ------------------------------------------------------------------------------------------------
def excess_exact(theta, n):
    """2 theta (1/n) sum_t E[w_t]: w_t the posterior weight of P_+ after t-1 answers of P_-."""
    pm, pp = Fr(1, 2) - theta, Fr(1, 2) + theta
    r = pp / pm
    dist = [Fr(1)]                                       # law of the number of ones among the answers so far
    tot = Fr(0)
    for t in range(1, n + 1):
        s = t - 1
        tot += sum(p / (1 + r ** (s - 2 * k)) for k, p in enumerate(dist))
        dist = [(dist[k] * (1 - pm) if k <= s else 0) + (dist[k - 1] * pm if k >= 1 else 0) for k in range(s + 2)]
    return 2 * theta * tot / n


def excess_float(theta, n):
    pm = 0.5 - theta
    lr = math.log((0.5 + theta) / (0.5 - theta))
    dist = [1.0]
    tot = 0.0
    for t in range(1, n + 1):
        s = t - 1
        tot += sum(p / (1 + math.exp(min(700.0, lr * (s - 2 * k)))) for k, p in enumerate(dist) if p > 1e-300)
        nd = [0.0] * (s + 2)
        for k, p in enumerate(dist):
            nd[k] += p * (1 - pm)
            nd[k + 1] += p * pm
        dist = nd
    return 2 * theta * tot / n


def part_g():
    print("Part G: Proposition 5.7, the counterexample (K = 1, L = 1)")
    for (theta, n, want) in ((Fr(1, 20), 20, 0.0457), (Fr(1, 20), 60, 0.0389), (Fr(1, 10), 60, 0.0451)):
        e = excess_exact(theta, n)
        assert abs(float(e) - want) < 5e-5 and abs(float(e) - excess_float(float(theta), n)) < 1e-12
        assert float(e) > LN2 / n and float(e) <= math.sqrt(LN2 / (2 * n))
        print(f"  theta = {theta}, n = {n}: excess failure {float(e):.6f} (exact rational); ln 2/n = {LN2 / n:.6f}; sqrt(ln 2/(2n)) = {math.sqrt(LN2 / (2 * n)):.6f}")
    for (theta, n, want) in ((0.02, 2000, None), (0.02, 5000, 0.00343), (0.01, 5000, 0.00500)):
        e = excess_float(theta, n)
        assert want is None or abs(e - want) < 5e-6
        assert e <= math.sqrt(LN2 / (2 * n))
        print(f"  theta = {theta}, n = {n}: excess failure {e:.6f}; ratio to ln 2/n = {e * n / LN2:.1f}; sqrt(ln 2/(2n)) = {math.sqrt(LN2 / (2 * n)):.6f}")
    rs = []
    for n in (100, 400, 1600):
        e = excess_float(1 / (2 * math.sqrt(n)), n)
        rs.append(e * n / LN2 / math.sqrt(n))
    assert max(rs) - min(rs) < 0.01
    print(f"  theta = 1/(2 sqrt n): ratio to ln 2/n divided by sqrt n = {rs[0]:.3f}, {rs[1]:.3f}, {rs[2]:.3f} at n = 100, 400, 1600 (unbounded ratio)")


# ------------------------------------------------------------------------------------------------
# Part H.  Arithmetic of Proposition 7.2 and of the sentences of the note that were questioned.
# ------------------------------------------------------------------------------------------------
def part_h():
    print("Part H: arithmetic")
    for dl in (Fr(1, 100), Fr(1, 20), Fr(1, 6), Fr(6, 25)):
        for F in (Fr(1, 100), Fr(1, 5), Fr(1, 4) - dl, Fr(1, 4) - dl - Fr(1, 10 ** 6), Fr(1, 4), Fr(3)):
            assert (4 * F / (1 - 4 * dl) < 1) == (F < Fr(1, 4) - dl)
    rnd = random.Random(72)
    for _ in range(2000):
        r, L, K = rnd.randint(1, 10 ** 6), rnd.randint(1, 5000), rnd.uniform(0.01, 1e9)
        dl = rnd.uniform(1e-6, 0.25)
        F = r * dl
        n = math.ceil(L * K * LN2 / dl)
        A = r * L / n
        assert A >= F / (K * LN2 + dl / L) * (1 - 1e-12)
        k = rnd.randint(0, 50)
        nk = math.ceil(L * K * LN2 / ((k + 1) * dl))
        assert r * L / nk >= F / (K * LN2 / (k + 1) + dl / L) * (1 - 1e-12)
    L, dl, K = 1000, 0.01, 1e9
    nR, nAB = L * K * LN2 / dl, 1 + 2.7 * K * L / (dl * math.log2(L / dl))
    nblk, nnd = (1 - 10 * dl) * K * L / (8 * dl * math.log2(L / (2 * dl))), L / (4 * dl) - L
    print(f"  L = 1000, delta = 0.01, K = 1e9: questions R {nR:.3g}, AB {nAB:.3g}, block class {nblk:.3g}, needle class {nnd:.0f};"
          f" failed runs allowed at break-even {dl * nR / L:.3g}, {dl * nAB / L:.3g}, {dl * nblk / L:.3g}, {dl * nnd / L:.2f}")
    assert abs(dl * nR / L - K * LN2) < 1 and abs(dl * nblk / L - (1 - 10 * dl) * K / (8 * math.log2(L / (2 * dl)))) < 1
    print(f"  saving of Theorem 3.3(3) against L K ln 2/eps: ln 2 log2(L/eps)/2.7 = {LN2 * 4 / 2.7:.3f} at L/eps = 16,"
          f" {LN2 * math.log2(1e6) / 2.7:.2f} at 1e6, {LN2 * math.log2(1e9) / 2.7:.2f} at 1e9")
    for m in range(0, 60):                                # the paragraph after Proposition 3.8
        for ratio in (16, 17.5, 100, 1e6):
            Ld = ratio * (m + 1)                          # L/delta
            assert math.log2(Ld / (2 * (2 * m + 1)) + 1) <= math.log2(Ld / (m + 1))
    print("  F < 1/4 - delta iff 4F/(1 - 4 delta) < 1; r L/ceil(L K ln 2/((k+1) delta)) >= F/(K ln 2/(k+1) + delta/L) on 2000 random points;")
    print("  log2(L/(2(2m+1) delta) + 1) <= log2(L/((m+1) delta)) whenever L/((m+1) delta) >= 16, m < 60")


# ------------------------------------------------------------------------------------------------
# Part I.  Remark 1.11: a protocol without coins.
# ------------------------------------------------------------------------------------------------
def part_i():
    print("Part I: Remark 1.11 (a protocol without coins)")
    rnd = random.Random(111)
    cnt = pos = 0
    for _ in range(300):
        nx, Zn, L, T = rnd.choice([5, 6, 8]), rnd.choice([3, 4, 6]), rnd.choice([2, 3, 4]), rnd.choice([1, 2, 3, 4])
        Y = (0, 1)
        f0 = tuple(rnd.choice(Y) for _ in range(nx))
        qtab = {}

        def question(answers):                             # the protocol: a function of the answers so far
            if answers not in qtab:
                qtab[answers] = None if (len(answers) >= T or (answers and rnd.random() < 0.2)) else rnd.randrange(nx)
            return qtab[answers]

        def transcript(f):
            ans, qs = (), []
            while question(ans) is not None:
                x = question(ans)
                qs.append(x)
                ans += (f[x],)
            return tuple(qs), ans
        S = set(transcript(f0)[0])
        f1 = tuple(f0[x] if x in S else 1 - f0[x] for x in range(nx))
        assert transcript(f1) == transcript(f0)            # the same transcript, so the same deployed system
        nxt = table_scaffold(rnd, nx, Zn, L, Y, 0.2)
        leave = Fr(sum(any(x not in S for (x, _) in run(nxt, f0, z)) for z in range(Zn)), Zn)
        ans = lambda f, z: tuple(y for (_, y) in run(nxt, f, z))     # the outcome: the list of the answers
        differ = Fr(sum(ans(f0, z) != ans(f1, z) for z in range(Zn)), Zn)
        assert differ == leave
        for _ in range(5):                                 # arbitrary deployed systems (functions of z here)
            g = [rnd.choice([ans(f0, z), ans(f1, z), None]) for z in range(Zn)]
            fail0 = Fr(sum(g[z] != ans(f0, z) for z in range(Zn)), Zn)
            fail1 = Fr(sum(g[z] != ans(f1, z) for z in range(Zn)), Zn)
            assert fail0 + fail1 >= leave
        cnt += 1
        pos += leave > 0
    print(f"  {cnt} random protocols without coins: f' has the transcript of f_0; the outcomes differ exactly when the run of f_0 leaves S"
          f" (probability > 0 in {pos}); Fail(f_0) + Fail(f') >= that probability for every deployed system tried")


# ------------------------------------------------------------------------------------------------
# Part J.  Theorem 4.1(3).
# ------------------------------------------------------------------------------------------------
def part_j():
    print("Part J: Theorem 4.1(3), the protocol with n questions for N shifts")
    for N in range(1, 7):
        for n in range(0, N + 1):
            subsets = list(itertools.combinations(range(N), n))
            best = None
            for i in range(N):                              # shift i
                for j in [None] + list(range(N)):           # the member: f_0 (None) or f_j
                    s = Fr(0)
                    for I in subsets:
                        if j is not None and j in I:
                            s += 1                          # the human is identified
                        elif i in I:
                            s += 1                          # answer 0 on Q_i is right for f_0 and for f_j, j != i
                        else:
                            s += Fr(1, 2)                   # a fair coin on Q_i
                    s /= len(subsets)
                    best = s if best is None else min(best, s)
            assert best == Fr(1, 2) + Fr(n, 2 * N)
    for N in (1, 2, 3, 7, 10):
        for a in (Fr(1, 100), Fr(1, 7), Fr(1, 3), Fr(49, 100), Fr(1, 2)):
            n = math.ceil(2 * a * N)
            assert n <= N and Fr(n, 2 * N) >= a             # ceil(2aN) questions give the advantage a
            lo, x = math.floor(2 * a * N), 2 * a * N
            lam = x - lo                                    # mix the protocols with lo and lo+1 questions
            assert (1 - lam) * Fr(lo, 2 * N) + lam * Fr(min(lo + 1, N), 2 * N) == a or lam == 0
    print("  for N <= 6 and every n <= N the least success probability over shifts and members is exactly 1/2 + n/(2N);")
    print("  so ceil(2aN) questions give the advantage a, and a mixture of the protocols with floor(2aN) and ceil(2aN)")
    print("  questions gives it with 2aN questions in expectation")


if __name__ == "__main__":
    for part in (part_a, part_a2, part_b, part_c, part_d, part_e, part_f, part_g, part_h, part_i, part_j):
        part()
        print()
    print(f"all checks passed  [{time.time() - T0:.0f} s]")
