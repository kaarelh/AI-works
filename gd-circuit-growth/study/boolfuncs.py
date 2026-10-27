"""Suite of Boolean target functions on {-1,1}^d for the learning study.

Every target maps an (m, d) array of +-1 floats to an (m,) array of +-1 floats.
Coordinates are 0-indexed; x[:, 0] is "x1" in the write-up.  Each entry records
its relevant coordinates and a short description; `circuit_size` is the number
of fan-in-<=3 gates (AND/OR/XOR/MAJ/NOT-free with literal negations) in the
reference construction, used only as a rough complexity label.
"""
import numpy as np

def _and(*v):
    out = np.ones_like(v[0])
    for u in v:
        out = np.where(u > 0, out, -1.0)
    return out

def _or(*v):
    out = -np.ones_like(v[0])
    for u in v:
        out = np.where(u > 0, 1.0, out)
    return out

def _maj(*v):
    s = sum(v)
    return np.where(s > 0, 1.0, -1.0)  # odd arity only

def _xor(*v):
    out = np.ones_like(v[0])
    for u in v:
        out = out * u
    return out

def _sgn(s):
    return np.where(s > 0, 1.0, -1.0)


def _random_formula(rng, k, n_gates):
    """Random fan-in-2 circuit over k inputs with AND/OR/XOR gates and random
    literal negations; output is the last gate.  Returns (fn, description)."""
    ops = []
    for g in range(n_gates):
        pool = k + g
        a, b = rng.choice(pool, size=2, replace=False)
        # bias toward using recent gates so the output depends on most of the circuit
        if g > 0 and rng.random() < 0.7:
            a = k + g - 1
            if b == a:
                b = rng.integers(0, pool - 1)
        op = rng.choice(["and", "or", "xor"])
        na, nb = rng.random() < 0.5, rng.random() < 0.5
        ops.append((op, int(a), int(b), na, nb))

    def fn(x):
        vals = [x[:, i] for i in range(k)]
        for op, a, b, na, nb in ops:
            u = -vals[a] if na else vals[a]
            v = -vals[b] if nb else vals[b]
            vals.append({"and": _and, "or": _or, "xor": _xor}[op](u, v))
        return vals[-1]

    desc = "; ".join(f"g{k+i}={'~' if na else ''}{a}{op}{'~' if nb else ''}{b}"
                     for i, (op, a, b, na, nb) in enumerate(ops))
    return fn, desc


def make_suite(d=30, n_random=4, seed=12345):
    S = {}

    def add(name, fn, rel, desc, size):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc, circuit_size=size)

    add("dict", lambda x: x[:, 0], [0], "x1", 0)
    add("and3", lambda x: _and(x[:, 0], x[:, 1], x[:, 2]), [0, 1, 2], "AND(x1,x2,x3)", 2)
    add("maj3", lambda x: _maj(x[:, 0], x[:, 1], x[:, 2]), [0, 1, 2], "MAJ(x1,x2,x3)", 1)
    add("maj9", lambda x: _maj(*[x[:, i] for i in range(9)]), range(9), "MAJ(x1..x9)", 1)
    w = np.random.default_rng(seed).standard_normal(10)
    add("thr10", lambda x, w=w: _sgn(x[:, :10] @ w), range(10), "sign(w.x[1..10]), Gaussian w", 1)
    add("par2", lambda x: _xor(x[:, 0], x[:, 1]), [0, 1], "x1 x2", 1)
    add("par3", lambda x: _xor(x[:, 0], x[:, 1], x[:, 2]), [0, 1, 2], "x1 x2 x3", 2)
    add("par4", lambda x: _xor(*[x[:, i] for i in range(4)]), range(4), "x1 x2 x3 x4", 3)
    add("stair5", lambda x: _sgn(sum(np.prod(x[:, :t + 1], axis=1) for t in range(5))), range(5),
        "sign(x1 + x1x2 + ... + x1..x5)", 9)
    add("majpar", lambda x: _maj(x[:, 0] * x[:, 1], x[:, 2] * x[:, 3], x[:, 4] * x[:, 5]), range(6),
        "MAJ(x1x2, x3x4, x5x6)", 4)
    add("parmaj", lambda x: _xor(_maj(x[:, 0], x[:, 1], x[:, 2]), _maj(x[:, 3], x[:, 4], x[:, 5])), range(6),
        "MAJ(x1,x2,x3) XOR MAJ(x4,x5,x6)", 3)
    add("mux", lambda x: np.where(x[:, 3] > 0, x[:, 0] * x[:, 1] * x[:, 2], _maj(x[:, 0], x[:, 1], x[:, 2])),
        range(4), "x4 ? x1x2x3 : MAJ(x1,x2,x3)", 5)
    add("dnf3", lambda x: _or(_and(x[:, 0], x[:, 1], x[:, 2]), _and(x[:, 3], -x[:, 4], x[:, 5]),
                              _and(x[:, 6], x[:, 7], -x[:, 8])), range(9),
        "(x1&x2&x3) | (x4&~x5&x6) | (x7&x8&~x9)", 7)
    # decision list: if x1 -> +1 elif ~x2 -> -1 elif x3 -> +1 elif x4 -> -1 elif x5 -> +1 else -1
    def dlist(x):
        out = -np.ones(len(x))
        for i, val in reversed(list(enumerate([1, -1, 1, -1, 1]))):
            lit = x[:, i] if i != 1 else -x[:, i]
            out = np.where(lit > 0, float(val), out)
        return out
    add("dlist5", dlist, range(5), "decision list x1:+ ~x2:- x3:+ x4:- x5:+ else -", 5)
    add("rmaj9", lambda x: _maj(_maj(x[:, 0], x[:, 1], x[:, 2]), _maj(x[:, 3], x[:, 4], x[:, 5]),
                                _maj(x[:, 6], x[:, 7], x[:, 8])), range(9), "MAJ of three MAJ3s", 4)
    add("andxor", lambda x: _and(x[:, 0] * x[:, 1], x[:, 2] * x[:, 3]), range(4), "AND(x1x2, x3x4)", 3)
    add("sparsepoly", lambda x: _sgn(2 * x[:, 0] + x[:, 1] * x[:, 2] + x[:, 3] * x[:, 4] * x[:, 5]), range(6),
        "sign(2x1 + x2x3 + x4x5x6)", 5)

    rng = np.random.default_rng(seed + 1)
    made = 0
    probe = np.random.default_rng(0).choice([-1.0, 1.0], size=(20000, d))
    while made < n_random:
        fn, desc = _random_formula(rng, 6, 6)
        y = fn(probe)
        # keep reasonably balanced formulas that depend on at least 5 of the 6 inputs
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(fn(probe) != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(6)]
        if sum(v > 0.02 for v in infl) < 5:
            continue
        add(f"rand{made}", fn, [i for i in range(6) if infl[i] > 0.02], "random 6-gate formula: " + desc, 6)
        made += 1
    return S


if __name__ == "__main__":
    S = make_suite()
    X = np.random.default_rng(0).choice([-1.0, 1.0], size=(50000, 30))
    for k, v in S.items():
        y = v["fn"](X)
        print(f"{k:11s} bias={y.mean():+.3f} rel={v['relevant']}  {v['desc']}")


def make_random_suite(d=30, count=20, seed=777):
    """Fresh random fan-in-2 formulas (AND/OR/XOR with random literal negations) on 4-8 inputs with 3-8 gates, kept if
    reasonably balanced and dependent on at least k-1 of their k inputs.  Used as an out-of-sample test of the models:
    none of these targets was seen while designing or calibrating them."""
    rng = np.random.default_rng(seed)
    probe = np.random.default_rng(1).choice([-1.0, 1.0], size=(20000, d))
    S = {}
    while len(S) < count:
        k = int(rng.integers(4, 9)); g = int(rng.integers(3, 9))
        fn, desc = _random_formula(rng, k, g)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(y != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(k)]
        rel = [i for i in range(k) if infl[i] > 0.01]
        if len(rel) < k - 1:
            continue
        S[f"rf{len(S):02d}"] = dict(fn=fn, relevant=rel, desc=f"random {g}-gate formula on {k} inputs: " + desc, circuit_size=g)
    return S


def make_poly_suite(d=30):
    """Real-valued polynomial targets for the composition test (regression, square loss; every term has coefficient 1/2).
    Asked by the user: is s + x1x2 + x3x4 + x1x2x3x4 easier than s + x1x2x3x4 (s = x1+x2+x3+x4)?  Both are leap 1, so
    leap complexity cannot tell them apart; the question is whether intermediate features (x1x2, x3x4) that are useful
    on their own make the degree-4 term cheaper to learn.  Controls: pairs that do not compose into x1x2x3x4, pairs
    alone, no linear part (leap 2), the parity alone (leap 4), the linear part alone."""
    S = {}
    s = lambda x: x[:, 0] + x[:, 1] + x[:, 2] + x[:, 3]
    p4 = lambda x: x[:, 0] * x[:, 1] * x[:, 2] * x[:, 3]

    def add(name, fn, desc):
        S[name] = dict(fn=lambda x, f=fn: 0.5 * f(x), relevant=[0, 1, 2, 3], desc=desc, circuit_size=None)

    add("compA", lambda x: s(x) + x[:, 0] * x[:, 1] + x[:, 2] * x[:, 3] + p4(x), "s + x1x2 + x3x4 + x1x2x3x4 (composing pairs)")
    add("compB", lambda x: s(x) + p4(x), "s + x1x2x3x4 (no intermediate pairs)")
    add("compC", lambda x: s(x) + x[:, 0] * x[:, 1] + x[:, 1] * x[:, 2] + p4(x), "s + x1x2 + x2x3 + x1x2x3x4 (pairs that do not compose)")
    add("compD", lambda x: s(x) + x[:, 0] * x[:, 1] + x[:, 2] * x[:, 3], "s + x1x2 + x3x4 (no degree-4 term)")
    add("compE", lambda x: x[:, 0] * x[:, 1] + x[:, 2] * x[:, 3] + p4(x), "x1x2 + x3x4 + x1x2x3x4 (no linear part; leap 2)")
    add("compF", lambda x: p4(x), "x1x2x3x4 (leap 4)")
    add("compL", lambda x: s(x), "s (linear only)")
    # added after the first results: pairs on other variables (same number of terms, nothing to compose with), one pair
    add("compG", lambda x: s(x) + x[:, 4] * x[:, 5] + x[:, 6] * x[:, 7] + p4(x), "s + x5x6 + x7x8 + x1x2x3x4 (pairs outside the support)")
    add("compH", lambda x: s(x) + x[:, 0] * x[:, 1] + p4(x), "s + x1x2 + x1x2x3x4 (one pair)")
    for k in ("compG",):
        S[k]["relevant"] = list(range(8))
    return S


def make_dl_heldout_suite(d=30, seed=4242):
    """Held-out targets for the discrete-learner comparison (study/discrete_learner), fixed before the learner was tuned
    on them: dense halfspaces, compositions of majorities, a larger parity, the classic 6-multiplexer, a longer
    staircase, an intersection of halfspaces, and fresh random formulas on 6-8 inputs."""
    S = {}

    def add(name, fn, rel, desc):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc)

    add("maj15", lambda x: _maj(*[x[:, i] for i in range(15)]), range(15), "MAJ(x1..x15)")
    w = np.random.default_rng(seed).standard_normal(d)
    add("thr30", lambda x, w=w: _sgn(x @ w), range(d), "sign(w.x), Gaussian w on all inputs")
    add("majxor", lambda x: _maj(*[x[:, i] for i in range(5)]) * _maj(*[x[:, i] for i in range(5, 10)]), range(10),
        "MAJ(x1..x5) XOR MAJ(x6..x10)")
    add("majmaj5", lambda x: _maj(*[_maj(*[x[:, 5 * j + i] for i in range(5)]) for j in range(3)]), range(15),
        "MAJ of three MAJ5s")
    add("par5", lambda x: _xor(*[x[:, i] for i in range(5)]), range(5), "x1 x2 x3 x4 x5")
    add("mux6", lambda x: np.choose(((x[:, 0] > 0) * 2 + (x[:, 1] > 0)).astype(int), [x[:, 2], x[:, 3], x[:, 4], x[:, 5]]),
        range(6), "6-multiplexer: address x1 x2, data x3..x6")
    add("stair6", lambda x: _sgn(sum(np.prod(x[:, :t + 1], axis=1) for t in range(6)) + 0.5), range(6),
        "sign(x1 + x1x2 + ... + x1..x6 + 1/2)")
    g = np.random.default_rng(seed + 1).standard_normal((2, 10))
    add("inter2", lambda x, g=g: _and(_sgn(x[:, :10] @ g[0]), _sgn(x[:, :10] @ g[1])), range(10),
        "AND of two Gaussian halfspaces on x1..x10")
    add("majpar5", lambda x: _maj(*[x[:, 2 * i] * x[:, 2 * i + 1] for i in range(5)]), range(10), "MAJ of five pairs x1x2..x9x10")
    rng = np.random.default_rng(seed + 2)
    probe = np.random.default_rng(2).choice([-1.0, 1.0], size=(20000, d))
    made = 0
    while made < 3:
        k = int(rng.integers(6, 9)); gts = int(rng.integers(5, 9))
        fn, desc = _random_formula(rng, k, gts)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(y != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(k)]
        rel = [i for i in range(k) if infl[i] > 0.01]
        if len(rel) < k - 1:
            continue
        add(f"hrf{made}", fn, rel, f"random {gts}-gate formula on {k} inputs: " + desc)
        made += 1
    return S


def make_dl_heldout2_suite(d=30, seed=5151):
    """Second held-out suite for the discrete-learner comparison, written after DFG v1.1 was committed (0220cf04), so it
    is blind for v1.1: a dense halfspace on 20 inputs, a wide majority, a parity times a majority, a 4-term 2-DNF, a
    symmetric even function, and two fresh random formulas on 7-8 inputs."""
    S = {}

    def add(name, fn, rel, desc):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc)

    w = np.random.default_rng(seed).standard_normal(20)
    add("thr20", lambda x, w=w: _sgn(x[:, :20] @ w), range(20), "sign(w.x[1..20]), Gaussian w")
    add("maj21", lambda x: _maj(*[x[:, i] for i in range(21)]), range(21), "MAJ(x1..x21)")
    add("xmaj", lambda x: x[:, 0] * x[:, 1] * _maj(x[:, 2], x[:, 3], x[:, 4]), range(5), "x1 x2 MAJ(x3,x4,x5)")
    add("dnf4x2", lambda x: _or(_and(x[:, 0], x[:, 1]), _and(x[:, 2], x[:, 3]), _and(x[:, 4], x[:, 5]), _and(x[:, 6], x[:, 7])),
        range(8), "(x1&x2) | (x3&x4) | (x5&x6) | (x7&x8)")
    add("sym8", lambda x: np.where(np.abs(x[:, :8].sum(1)) >= 4, 1.0, -1.0), range(8), "|x1 + ... + x8| >= 4")
    rng = np.random.default_rng(seed + 2)
    probe = np.random.default_rng(3).choice([-1.0, 1.0], size=(20000, d))
    made = 0
    while made < 2:
        k = int(rng.integers(7, 9)); gts = int(rng.integers(6, 10))
        fn, desc = _random_formula(rng, k, gts)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(y != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(k)]
        rel = [i for i in range(k) if infl[i] > 0.01]
        if len(rel) < k - 1:
            continue
        add(f"h2rf{made}", fn, rel, f"random {gts}-gate formula on {k} inputs: " + desc)
        made += 1
    return S


def make_dl_heldout3_suite(d=30, seed=6161):
    """Third held-out Boolean suite (Part 8: a hybrid discrete learner), fixed before any hybrid was designed: a CNF,
    a symmetric even function, a decision list, an integer-weight threshold, a parity OR a conjunction, a sparse
    polynomial with a degree-4 term, a majority of mixed gates, the 11-multiplexer, and two fresh random formulas."""
    S = {}

    def add(name, fn, rel, desc):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc)

    add("cnf3", lambda x: _and(_or(x[:, 0], x[:, 1], x[:, 2]), _or(-x[:, 3], x[:, 4], x[:, 5]), _or(x[:, 6], -x[:, 7], x[:, 8])),
        range(9), "(x1|x2|x3) & (~x4|x5|x6) & (x7|~x8|x9)")
    add("sym9", lambda x: np.where(np.abs(x[:, :9].sum(1)) <= 1, 1.0, -1.0), range(9), "|x1 + ... + x9| <= 1")

    def dlist8(x):
        out = np.ones(len(x))
        for i, val in reversed(list(enumerate([-1, 1, 1, -1, 1, -1, -1, 1]))):
            lit = x[:, i] if i % 3 != 1 else -x[:, i]
            out = np.where(lit > 0, float(val), out)
        return out
    add("dlist8", dlist8, range(8), "decision list on 8 literals")
    wint = np.array([3, 2, 2, 1, 1, 1, 1, 1, 1], float)
    add("thrint", lambda x, w=wint: _sgn(x[:, :9] @ w), range(9), "sign(3x1 + 2x2 + 2x3 + x4 + ... + x9)")
    add("par3or", lambda x: _or(_xor(x[:, 0], x[:, 1], x[:, 2]), _and(x[:, 3], x[:, 4])), range(5), "(x1 x2 x3) | (x4 & x5)")
    add("poly4", lambda x: _sgn(x[:, 0] * x[:, 1] + x[:, 2] * x[:, 3] * x[:, 4] + 0.5 * x[:, 5] + x[:, 6] * x[:, 7] * x[:, 8] * x[:, 9]),
        range(10), "sign(x1x2 + x3x4x5 + x6/2 + x7x8x9x10)")
    add("mixmaj", lambda x: _maj(x[:, 0] * x[:, 1], _and(x[:, 2], x[:, 3]), _or(x[:, 4], x[:, 5])), range(6),
        "MAJ(x1 x2, x3 & x4, x5 | x6)")
    add("mux11", lambda x: np.choose(((x[:, 0] > 0) * 4 + (x[:, 1] > 0) * 2 + (x[:, 2] > 0)).astype(int),
                                     [x[:, 3 + k] for k in range(8)]), range(11), "11-multiplexer: address x1..x3, data x4..x11")
    rng = np.random.default_rng(seed + 2)
    probe = np.random.default_rng(4).choice([-1.0, 1.0], size=(20000, d))
    made = 0
    while made < 2:
        k = int(rng.integers(7, 10)); gts = int(rng.integers(6, 10))
        fn, desc = _random_formula(rng, k, gts)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(y != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(k)]
        rel = [i for i in range(k) if infl[i] > 0.01]
        if len(rel) < k - 1:
            continue
        add(f"h3rf{made}", fn, rel, f"random {gts}-gate formula on {k} inputs: " + desc)
        made += 1
    return S


def _pm(b):
    return np.where(b, 1.0, -1.0)


def make_dl_symdev_suite(d=30, seed=7171):
    """Part 9 DEVELOPMENT suite for sum features (symmetric functions and functions of signed sums of inputs).
    Development data only; the held-out counterpart is make_dl_heldout4_suite."""
    S = {}

    def add(name, fn, rel, desc):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc)
    s = lambda x, k, a=0: x[:, a:a + k].sum(1)
    add("sym7", lambda x: _pm(np.abs(s(x, 7)) <= 1), range(7), "|x1 + ... + x7| <= 1")
    add("ex3of8", lambda x: _pm(s(x, 8) == -2), range(8), "exactly 3 of x1..x8 are +1")
    add("band11", lambda x: _pm(np.isin(np.abs(s(x, 11)), [3, 5])), range(11), "|x1 + ... + x11| in {3, 5}")
    add("far9", lambda x: _pm(np.abs(s(x, 9)) >= 5), range(9), "|x1 + ... + x9| >= 5")
    sg = np.array([1, -1, 1, -1, 1, 1, -1, 1, 1], float)
    add("ssym9", lambda x, sg=sg: _pm(np.abs(x[:, :9] @ sg) <= 1), range(9), "|x1 - x2 + x3 - x4 + x5 + x6 - x7 + x8 + x9| <= 1")
    add("symxpar", lambda x: _pm(np.abs(s(x, 6)) <= 2) * x[:, 6] * x[:, 7], range(8), "[|x1+...+x6| <= 2] xor (x7 x8)")
    add("twosym", lambda x: _pm((np.abs(s(x, 5)) <= 1) == (np.abs(s(x, 5, 5)) >= 3)), range(10),
        "[|x1+...+x5| <= 1] == [|x6+...+x10| >= 3]")
    add("thrsum", lambda x: _sgn(s(x, 6) + 3 * x[:, 6] * x[:, 7] + 0.5), range(8), "sign(x1+...+x6 + 3 x7 x8 + 1/2)")
    return S


def make_dl_heldout4_suite(d=30, seed=8181):
    """Fourth held-out Boolean suite (Part 9: sum features), fixed before any Part 9 design: symmetric functions and
    functions of signed sums of different sizes and accept-sets, mixtures with parities and gates, and three
    non-symmetric controls (two fresh random formulas and a DNF)."""
    S = {}

    def add(name, fn, rel, desc):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc)
    s = lambda x, k, a=0: x[:, a:a + k].sum(1)
    add("sym11", lambda x: _pm(np.abs(s(x, 11)) <= 1), range(11), "|x1 + ... + x11| <= 1")
    add("ex4of9", lambda x: _pm(s(x, 9) == -1), range(9), "exactly 4 of x1..x9 are +1")
    add("tail13", lambda x: _pm(np.abs(s(x, 13)) >= 5), range(13), "|x1 + ... + x13| >= 5")
    add("band10", lambda x: _pm(np.abs(s(x, 10)) == 2), range(10), "|x1 + ... + x10| = 2")
    sg = np.array([1, 1, -1, 1, -1, -1, 1, -1], float)
    add("ssym8", lambda x, sg=sg: _pm(x[:, :8] @ sg == 0), range(8), "x1 + x2 - x3 + x4 - x5 - x6 + x7 - x8 = 0")
    add("symxor", lambda x: _pm(np.abs(s(x, 7)) <= 1) * x[:, 7], range(8), "[|x1+...+x7| <= 1] xor x8")
    add("symand", lambda x: _and(_pm(np.abs(s(x, 6)) <= 2), _or(x[:, 6], x[:, 7])), range(8),
        "[|x1+...+x6| <= 2] & (x7 | x8)")
    add("sumpar", lambda x: _sgn(s(x, 5) + 2 * x[:, 5] * x[:, 6] + 2 * x[:, 7] * x[:, 8] * x[:, 9]), range(10),
        "sign(x1+...+x5 + 2 x6 x7 + 2 x8 x9 x10)")
    add("majsym", lambda x: _maj(_pm(np.abs(s(x, 5)) <= 1), x[:, 5] * x[:, 6], x[:, 7]), range(8),
        "MAJ([|x1+...+x5| <= 1], x6 x7, x8)")
    add("dnf3x3", lambda x: _or(_and(x[:, 0], -x[:, 1], x[:, 2]), _and(x[:, 3], x[:, 4], -x[:, 5]), _and(-x[:, 6], x[:, 7], x[:, 8])),
        range(9), "(x1 & ~x2 & x3) | (x4 & x5 & ~x6) | (~x7 & x8 & x9)")
    rng = np.random.default_rng(seed + 2)
    probe = np.random.default_rng(5).choice([-1.0, 1.0], size=(20000, d))
    made = 0
    while made < 2:
        k = int(rng.integers(7, 10)); gts = int(rng.integers(6, 10))
        fn, desc = _random_formula(rng, k, gts)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(y != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(k)]
        rel = [i for i in range(k) if infl[i] > 0.01]
        if len(rel) < k - 1:
            continue
        add(f"h4rf{made}", fn, rel, f"random {gts}-gate formula on {k} inputs: " + desc)
        made += 1
    return S


def make_dl_heldout5_suite(d=30, seed=9393):
    """Fifth held-out Boolean suite (Part 9), generated at random AFTER the sum-feature builder froze its design (that
    builder had seen dlheld4's source code; see study/part9/PROTOCOL.md).  Targets are drawn by rejection sampling from a
    fixed generative family, not hand-picked: 8 functions of a signed sum t = sum_{i<k} s_i x_i (k uniform in 5..13, random
    signs, a random accept set of t-values with acceptance probability in [0.25, 0.75]), each optionally combined (prob 1/2)
    with a random gate on 1-2 further inputs (XOR with a character, AND / OR with a literal); 2 thresholds of a signed sum
    plus an integer multiple of a random character; 2 random formulas (controls).  Balance: |mean| <= 0.5."""
    S = {}
    rng = np.random.default_rng(seed)
    probe = np.random.default_rng(6).choice([-1.0, 1.0], size=(20000, d))
    from math import comb

    def add(name, fn, rel, desc):
        S[name] = dict(fn=fn, relevant=list(rel), desc=desc)
    made = 0
    while made < 8:
        k = int(rng.integers(5, 14)); sg = rng.choice([-1.0, 1.0], size=k)
        vals = np.arange(-k, k + 1, 2); pv = np.array([comb(k, (v + k) // 2) for v in vals], float) / 2 ** k
        A = vals[rng.random(len(vals)) < 0.5]
        if not (0.25 <= pv[np.isin(vals, A)].sum() <= 0.75):
            continue
        base = lambda x, k=k, sg=sg, A=A: _pm(np.isin(x[:, :k] @ sg, A))
        mode = rng.choice(["none", "xor", "and", "or"], p=[0.5, 1 / 6, 1 / 6, 1 / 6])
        if mode == "none":
            fn, rel, extra = base, list(range(k)), ""
        elif mode == "xor":
            m = int(rng.integers(1, 3)); T = list(range(k, k + m))
            fn = lambda x, base=base, T=T: base(x) * np.prod(x[:, T], 1); rel = list(range(k + m)); extra = f" xor chi{tuple(i + 1 for i in T)}"
        else:
            sgn = float(rng.choice([-1.0, 1.0]))
            fn = (lambda x, base=base, k=k, sgn=sgn: _and(base(x), sgn * x[:, k])) if mode == "and" else \
                 (lambda x, base=base, k=k, sgn=sgn: _or(base(x), sgn * x[:, k]))
            rel = list(range(k + 1)); extra = f" {mode} {'' if sgn > 0 else '~'}x{k + 1}"
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        add(f"h5s{made}", fn, rel, f"[sum_(i<={k}) s_i x_i in {A.tolist()}], s = {sg.astype(int).tolist()}" + extra)
        made += 1
    made = 0
    while made < 2:
        k = int(rng.integers(5, 10)); sg = rng.choice([-1.0, 1.0], size=k); m = int(rng.integers(2, 4)); w = int(rng.integers(2, 4))
        T = list(range(k, k + m))
        fn = lambda x, k=k, sg=sg, T=T, w=w: _sgn(x[:, :k] @ sg + w * np.prod(x[:, T], 1) + 0.5)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        add(f"h5t{made}", fn, list(range(k + m)), f"sign(sum_(i<={k}) s_i x_i + {w} chi{tuple(i + 1 for i in T)} + 1/2), s = {sg.astype(int).tolist()}")
        made += 1
    made = 0
    while made < 2:
        k = int(rng.integers(7, 10)); gts = int(rng.integers(6, 10))
        fn, desc = _random_formula(rng, k, gts)
        y = fn(probe)
        if abs(y.mean()) > 0.5:
            continue
        infl = [np.mean(y != fn(probe * np.where(np.arange(d) == i, -1.0, 1.0))) for i in range(k)]
        rel = [i for i in range(k) if infl[i] > 0.01]
        if len(rel) < k - 1:
            continue
        add(f"h5rf{made}", fn, rel, f"random {gts}-gate formula on {k} inputs: " + desc)
        made += 1
    return S


def make_dl_heldout6_suite(d=30):
    """Sixth held-out Boolean suite (Part 9, Amendment 3): 12 targets drawn from a random family written, before any run,
    by an agent blind to the sum-feature design, from the pre-registered description of the held-out suite
    (part9/heldout6/FAMILY.md; definitions in part9/heldout6/suite.py)."""
    import importlib.util, os
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "part9", "heldout6", "suite.py")
    sp = importlib.util.spec_from_file_location("heldout6_suite", p); m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m.make_dl_heldout6_suite(d)


def _heldout6_family(d, seed, prefix):
    """A fresh draw from dlheld6's family (part9/heldout6/FAMILY.md, written blind to the sum-feature design), renamed."""
    import importlib.util, os
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "part9", "heldout6", "suite.py")
    sp = importlib.util.spec_from_file_location("heldout6_suite", p); m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return {prefix + k[len("h6_"):]: v for k, v in m.make_dl_heldout6_suite(d, seed=seed).items()}


def make_dl_famdev_suite(d=30):
    """Part 10 DEVELOPMENT suite: a draw (seed 61616) from dlheld6's family; targets fd_00 ... fd_11."""
    return _heldout6_family(d, 61616, "fd_")


def make_dl_heldout7_suite(d=30):
    """Part 10 HELD-OUT suite, fixed before any Part 10 design: a draw (seed 70707) from dlheld6's family; f7_00 ... f7_11."""
    return _heldout6_family(d, 70707, "f7_")

