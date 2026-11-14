"""A property imitator on the tree of additions: no class of hypotheses, only tests.

The imitator keeps, for each test B (a set of question-answer pairs) of a weighted family, the
running difference S(B) = #(its own audited answers in B) - #(the human's answers in B), and
answers a question x with a y that minimises  sum_B pi(B) sinh(eta S(B)) 1[(x, y) in B]:
it produces what the human has produced more often than it has. For every sequence of questions,

    |S_n(B)| <= ln(2 / pi(B)) / eta + n eta / 2     for all tests B at once

(potential sum_B pi(B) cosh(eta S(B)); it grows by a factor of at most cosh(eta) per round).
Nothing is assumed about the human. Here the human adds mod M and, in the noisy variant, adds 1
more with probability NOISE.

Rehearsal as in toy.py: run the tree with the current rule, ask the human one uniformly chosen
call. Reported: the largest |S_n(B)| / n over the family against the bound; the rate at which the
audited answers are exact sums; the rate of exact roots. The first rate is the frequency of a
test of the family and must match the human's. The second is a property of whole runs, which
tests of single calls do not control: with a noisy human it does not match the human system's.

Usage: python3 toy_property.py
"""
import numpy as np

M = 8
SMALL = 2
NOISE = 0.1


def build_tests():
    """Returns (names, weights, tests) with tests[k, x, y] = 1 if (x, y) is in test k."""
    x = np.arange(M * M)
    a, b = np.divmod(x, M)
    A, B, Y = a[:, None], b[:, None], np.arange(M)[None, :]
    base = {}
    for c in range(M):
        base[f"y={c}"] = (Y == c) & (A >= 0), 4
        base[f"y-a-b={c}"] = ((Y - A - B) % M == c), 5
        base[f"y-a={c}"] = ((Y - A) % M == c), 5
        base[f"y-b={c}"] = ((Y - B) % M == c), 5
    base["y even"] = (Y % 2 == 0) & (A >= 0), 3
    base["y>=a"] = (Y >= A), 4
    base["y=max(a,b)"] = (Y == np.maximum(A, B)), 5
    conds = {"all": (a >= 0, 0), "a<4": (a < 4, 2), "b<4": (b < 4, 2), "a>=4": (a >= 4, 2),
             "b>=4": (b >= 4, 2), "a=b": (a == b, 2), "a+b>=M": (a + b >= M, 3)}
    for u in range(M):
        conds[f"a={u}"] = (a == u, 5)
        conds[f"b={u}"] = (b == u, 5)
    names, lengths, tests = [], [], []
    for bn, (bset, bl) in base.items():
        for cn, (cset, cl) in conds.items():
            names.append(f"[{cn}] {bn}")
            lengths.append(bl + cl)
            tests.append(bset & cset[:, None])
    w = 2.0 ** (-np.array(lengths, dtype=float))
    return names, w / w.sum(), np.stack(tests).astype(float)


NAMES, PI, TESTS = build_tests()


def human(rng, x, noise):
    a, b = np.divmod(x, M)
    return (a + b + (rng.random(np.shape(x)) < noise)) % M


def run_tree(rng, h, rule, noise):
    vals = rng.integers(0, SMALL, size=2 ** h)
    truth = vals.sum() % M
    xs = []
    while len(vals) > 1:
        x = vals[0::2] * M + vals[1::2]
        xs.append(x)
        vals = rule[x]
    return np.concatenate(xs), vals[0], truth


def human_system_exact_roots(rng, h, noise, runs=20000):
    """Rate of exact roots when the human answers every call."""
    ok = 0
    for _ in range(runs):
        vals = rng.integers(0, SMALL, size=2 ** h)
        truth = vals.sum() % M
        while len(vals) > 1:
            vals = human(rng, vals[0::2] * M + vals[1::2], noise)
        ok += vals[0] == truth
    return ok / runs


def rehearse(rng, h, n, noise):
    eta = 1.0 / np.sqrt(n)
    S = np.zeros(len(PI))
    L = 2 ** h - 1
    exact_call = np.zeros(n)
    exact_root = np.zeros(n)
    for t in range(n):
        score = np.tensordot(PI * np.sinh(eta * S), TESTS, axes=1)       # [x, y]
        rule = score.argmin(axis=1)
        xs, root, truth = run_tree(rng, h, rule, noise)
        x = xs[rng.integers(0, L)]
        ya, yh = rule[x], human(rng, x, noise)
        S += TESTS[:, x, ya] - TESTS[:, x, yh]
        a, b = divmod(int(x), M)
        exact_call[t] = ya == (a + b) % M
        exact_root[t] = root == truth
    return S, eta, exact_call, exact_root


if __name__ == "__main__":
    rng = np.random.default_rng(3)
    print(f"{len(PI)} tests on {M}x{M} questions and {M} answers; tree of depth 3 (L = 7)\n")
    for noise in (0.0, NOISE):
        print(f"== human: (a+b) mod {M}" + (f", plus 1 with probability {noise}" if noise else "") + " ==")
        print(f"human system: exact sums at a call {1 - noise:.4f}, exact roots "
              f"{human_system_exact_roots(rng, 3, noise):.4f}")
        print(f"{'n':>7}  {'max |S_n(B)|/n':>15}  {'bound for that B':>17}  {'exact sums among audited':>25}  "
              f"{'exact roots':>12}   (rates over the last half of the rounds)")
        for n in (1000, 8000, 64000):
            S, eta, ec, er = rehearse(rng, 3, n, noise)
            k = int(np.argmax(np.abs(S)))
            bound = (np.log(2 / PI[k]) / eta + n * eta / 2) / n
            print(f"{n:7d}  {abs(S[k]) / n:15.4f}  {bound:17.4f}  {ec[n // 2:].mean():25.4f}  "
                  f"{er[n // 2:].mean():12.4f}   worst test: {NAMES[k]}")
        print()
