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
