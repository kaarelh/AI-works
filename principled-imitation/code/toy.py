"""A toy closed system: summing a list by a tree of pairwise additions, with an imitated adder.

The "human" is the function f(a, b) = (a + b) mod M. A task is a list of 2^h small numbers; the
scaffold adds them in a balanced binary tree, one call (a, b) per internal node, L = 2^h - 1 calls.
Deeper calls see larger numbers than any top-level question would contain: the shift produced by
task decomposition.

The imitator is the Bayes mixture over a finite class of functions with description-length
weights. The class contains f, hypotheses that are simpler than f and agree with it on small
numbers, guards ("f, except something else when a property holds"), and point patches.

Regimes for the n questions put to the human:
  naive      pairs of small numbers (what one would ask without thinking of the decomposition);
  rehearsal  Protocol R: run the tree with the current mixture (a fresh posterior draw at each
             call), then ask the human one uniformly chosen call of that run;
  one-mind   as rehearsal, but one posterior draw answers the whole run;
  map        as rehearsal, but the current highest-weight consistent hypothesis answers the run.

For the rehearsal regimes the quantity of the theorems is the behaviour of the rehearsal runs
themselves (deployment uses the imitator of a uniformly random round):
  Theorem R1: sum over rounds of E[#calls where the answer differs from f]  <=  L K ln 2;
  Theorem R4: sum over rounds of Pr[run differs from the human system's]    <=  2 L K ln 2.

Usage: python3 toy.py [trials]
"""
import sys

import numpy as np

M = 32          # numbers are residues mod M
SMALL = 4       # leaves and naive questions use numbers below SMALL


def build_class():
    """Returns (names, lengths, table) with table[h, a * M + b] = value of hypothesis h."""
    a, b = np.divmod(np.arange(M * M), M)
    f = (a + b) % M
    names, lengths, rows = [], [], []

    def add(name, length, values):
        names.append(name)
        lengths.append(length)
        rows.append(np.asarray(values) % M)

    LF = 10
    add("f: (a+b) mod M", LF, f)
    add("saturating: min(a+b, M-1)", 8, np.minimum(a + b, M - 1))
    add("small only: a+b if a,b < 4, else 0", 7, np.where((a < SMALL) & (b < SMALL), a + b, 0))
    alts = {"0": 0 * a, "a": a, "b": b, "max": np.maximum(a, b), "f+1": f + 1}
    for t in (2, 4, 8, 16):
        conds = {f"a>={t}": a >= t, f"b>={t}": b >= t, f"a+b>={t}": a + b >= t,
                 f"a,b>={t}": (a >= t) & (b >= t)}
        for cn, c in conds.items():
            for an, alt in alts.items():
                add(f"guard [{cn}] -> {an}", LF + 8, np.where(c, alt, f))
    for cn, c in {"a,b odd": (a % 2 == 1) & (b % 2 == 1), "a=b": a == b}.items():
        for an, alt in alts.items():
            add(f"guard [{cn}] -> {an}", LF + 6, np.where(c, alt, f))
    for u in range(M):
        for v in range(M):
            add(f"patch ({u},{v})", LF + 12, np.where((a == u) & (b == v), f + 1, f))
    return names, np.array(lengths, dtype=float), np.stack(rows)


NAMES, LENGTHS, TABLE = build_class()
PRIOR = 2.0 ** (-LENGTHS)
PRIOR /= PRIOR.sum()
F = TABLE[0]
K_BITS = -np.log2(PRIOR[0])


def run_tree(rng, h, answer):
    """Runs the scaffold. answer(x) maps an array of inputs to an array of answers.
    Returns (inputs of all calls, answers, root)."""
    vals = rng.integers(0, SMALL, size=2 ** h)
    xs, ys = [], []
    while len(vals) > 1:
        x = vals[0::2] * M + vals[1::2]
        y = answer(x)
        xs.append(x)
        ys.append(y)
        vals = y
    return np.concatenate(xs), np.concatenate(ys), vals[0]


def mixture_answerer(rng, w):
    cum = np.cumsum(w)
    cum /= cum[-1]
    return lambda x: TABLE[np.minimum(np.searchsorted(cum, rng.random(len(x))), len(w) - 1), x]


def one_answerer(idx):
    return lambda x: TABLE[idx, x]


def update(w, x, y):
    w = np.where(TABLE[:, x] == y, w, 0.0)
    return w / w.sum()


def rehearsal(rng, h, n, driver):
    """Protocol R and its variants. Returns per-round arrays: unfaithful calls, unfaithful run."""
    w = PRIOR.copy()
    L = 2 ** h - 1
    bad_calls = np.zeros(n)
    bad_run = np.zeros(n)
    for t in range(n):
        if driver == "rehearsal":
            ans = mixture_answerer(rng, w)
        elif driver == "one-mind":
            ans = one_answerer(rng.choice(len(w), p=w))
        else:                                   # "map": highest prior weight among the consistent
            ans = one_answerer(int(np.argmax(np.where(w > 0, PRIOR, 0))))
        xs, ys, _ = run_tree(rng, h, ans)
        wrong = ys != F[xs]
        bad_calls[t] = wrong.sum()
        bad_run[t] = wrong.any()
        j = rng.integers(0, L)
        w = update(w, xs[j], F[xs[j]])
    return bad_calls, bad_run


def naive(rng, h, n, test_runs):
    """n questions on pairs of small numbers, then deployment with the frozen mixture."""
    w = PRIOR.copy()
    for _ in range(n):
        x = rng.integers(0, SMALL) * M + rng.integers(0, SMALL)
        w = update(w, x, F[x])
    ans = mixture_answerer(rng, w)
    bad_calls = bad_run = 0.0
    for _ in range(test_runs):
        xs, ys, _ = run_tree(rng, h, ans)
        wrong = ys != F[xs]
        bad_calls += wrong.sum()
        bad_run += wrong.any()
    return bad_calls / test_runs, bad_run / test_runs, w


if __name__ == "__main__":
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    rng = np.random.default_rng(1)
    print(f"class: {len(NAMES)} functions on {M}x{M} inputs; K = log2(1/w(f)) = {K_BITS:.2f} bits; "
          f"K ln 2 = {K_BITS * np.log(2):.2f}")
    print(f"trials per cell: {trials}\n")

    print("== naive questions (pairs of numbers below 4), then deployment on the tree ==")
    print(f"{'depth':>5} {'L':>4} {'n':>6}   unfaithful calls per run   Pr[run unfaithful]   heaviest hypotheses left")
    for h in (2, 4, 6):
        for n in (100, 10000):
            res = [naive(rng, h, n, 50) for _ in range(max(trials // 4, 5))]
            w = res[0][2]
            top = ", ".join(f"{NAMES[i].split(':')[0]} ({w[i]:.2f})" for i in np.argsort(-w)[:3])
            print(f"{h:5d} {2 ** h - 1:4d} {n:6d}   {np.mean([r[0] for r in res]):24.2f}   "
                  f"{np.mean([r[1] for r in res]):18.3f}   {top}")

    for driver, thm in (("rehearsal", "R1"), ("one-mind", "R4"), ("map", "none")):
        print(f"\n== {driver}: one question per run, on a uniformly chosen call of the run ==")
        print(f"{'depth':>5} {'L':>4} {'n':>6}   sum over rounds of      sum over rounds of      average over rounds")
        print(f"{'':>5} {'':>4} {'':>6}   unfaithful calls        Pr[run unfaithful]      of Pr[run unfaithful]")
        for h in (2, 4, 6):
            L = 2 ** h - 1
            n_max = 6400
            calls = np.zeros(n_max)
            runs = np.zeros(n_max)
            for _ in range(trials):
                c, r = rehearsal(rng, h, n_max, driver)
                calls += c / trials
                runs += r / trials
            for n in (100, 400, 1600, 6400):
                print(f"{h:5d} {L:4d} {n:6d}   {calls[:n].sum():16.2f}        {runs[:n].sum():16.2f}        "
                      f"{runs[:n].mean():12.4f}")
            print(f"{'':>17}   bound L K ln 2 = {L * K_BITS * np.log(2):8.1f}   bound 2 L K ln 2 = "
                  f"{2 * L * K_BITS * np.log(2):8.1f}")
