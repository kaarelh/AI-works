"""Benchmark circuit families with known or computable output probabilities."""

from __future__ import annotations

import numpy as np

from .circuit import Circuit


def random_dnf_terms(n: int, m: int, w: int, rng: np.random.Generator):
    terms = []
    for _ in range(m):
        S = rng.choice(n, size=w, replace=False)
        terms.append([(int(i), int(rng.integers(0, 2))) for i in S])
    return terms


def dnf_circuit(n: int, terms) -> Circuit:
    C = Circuit(n)
    ts = [C.AND(*[C.lit(i, b) for i, b in t]) for t in terms]
    return C.set_output(C.OR(*ts))


def obfuscated_dnf_circuit(n: int, terms, rng: np.random.Generator, noise: int = 2) -> Circuit:
    """The same DNF written badly: literals routed through XOR identities
    x = (x XOR r) XOR r with random helper inputs r, terms built as balanced
    trees, and the OR written as NOT(AND(NOT ...)).
    """
    C = Circuit(n)
    lit_cache = {}

    def lit(i, b):
        if (i, b) in lit_cache:
            return lit_cache[(i, b)]
        g = C.lit(i, b)
        for _ in range(noise):
            r = int(rng.integers(0, n))
            if r == i:
                continue
            g = C.XOR(C.XOR(g, r), r)
        lit_cache[(i, b)] = g
        return g

    def tree_and(gs):
        while len(gs) > 1:
            gs = [C.AND(gs[k], gs[k + 1]) if k + 1 < len(gs) else gs[k] for k in range(0, len(gs), 2)]
        return gs[0]

    ts = [tree_and([lit(i, b) for i, b in t]) for t in terms]
    return C.set_output(C.NOT(C.AND(*[C.NOT(t) for t in ts])))


def random_block_circuit(C: Circuit, vars_, gates: int, rng: np.random.Generator) -> int:
    """A random fan-in-2 circuit over the given input variables; returns its output gate."""
    pool = list(vars_)
    for _ in range(gates):
        a, b = rng.choice(len(pool), size=2, replace=len(pool) < 2)
        op = rng.choice(["AND", "OR", "XOR", "NAND"])
        x, y = pool[a], pool[b]
        if op == "NAND":
            g = C.NOT(C.AND(x, y))
        else:
            g = C.add(op, (x, y))
        pool.append(g)
    return pool[-1]


def independent_blocks(k: int, b: int, gates: int, rng: np.random.Generator):
    """AND of k random circuits on disjoint blocks of b variables.
    Returns (circuit, exact p under uniform D, per-block probabilities)."""
    n = k * b
    C = Circuit(n)
    outs, probs = [], []
    for j in range(k):
        vs = list(range(j * b, (j + 1) * b))
        while True:
            Cb = Circuit(n)
            g = random_block_circuit(Cb, vs, gates, rng)
            Cb.set_output(g)
            X = ((np.arange(1 << b)[:, None] >> np.arange(b)) & 1).astype(bool)
            full = np.zeros((1 << b, n), dtype=bool)
            full[:, vs] = X
            pj = Cb.eval_bits(full).mean()
            if 0.05 <= pj <= 0.95:
                break
        # copy block into C
        m = {i: i for i in range(n)}
        for v in range(n, len(Cb.ops)):
            m[v] = C.add(Cb.ops[v], [m[a] for a in Cb.args[v]], Cb.params[v])
        outs.append(m[g])
        probs.append(pj)
    C.set_output(C.AND(*outs))
    return C, float(np.prod(probs)), probs


def trigger_circuit(n: int, k: int, rng: np.random.Generator, body_gates: int = 60):
    """Backdoor-style circuit: R(x) AND [x_S = t] where the trigger test is
    written as AND of XNORs with constants and R is a random dense circuit on
    the remaining variables. Uniform p = 2^-k * Pr[R]."""
    S = rng.choice(n, size=k, replace=False)
    t = rng.integers(0, 2, size=k)
    rest = [i for i in range(n) if i not in set(S.tolist())]
    C = Circuit(n)
    one = C.const(1)
    checks = []
    for i, b in zip(S, t):
        # [x_i == b] written as NOT(XOR(x_i, b))
        checks.append(C.NOT(C.XOR(int(i), one if b else C.const(0))))
    trig = C.AND(*checks)
    while True:  # resample the body until it is dense (Pr[R] >= 0.05)
        Cr = Circuit(n)
        R = random_block_circuit(Cr, rest, body_gates, rng)
        Cr.set_output(R)
        if Cr.eval_bits(rng.random((4096, n)) < 0.5).mean() >= 0.05:
            break
    m = list(range(n))
    for v in range(n, len(Cr.ops)):
        m.append(C.add(Cr.ops[v], [m[a] for a in Cr.args[v]], Cr.params[v]))
    R = m[R]
    C.set_output(C.AND(trig, R))
    return C, [(int(i), int(b)) for i, b in zip(S, t)], rest, R


def threshold_of_blocks(k: int, b: int, gates: int, t: float, rng: np.random.Generator):
    """[sum_j B_j(x_{block j}) >= t] for random block circuits B_j."""
    n = k * b
    C = Circuit(n)
    outs = []
    for j in range(k):
        vs = list(range(j * b, (j + 1) * b))
        outs.append(random_block_circuit(C, vs, gates, rng))
    C.set_output(C.THR(outs, [1.0] * k, t))
    return C, outs


def chain_circuit(n: int, rng: np.random.Generator, width: int = 3):
    """A 'path-like' circuit of bounded treewidth: y_i = f_i(y_{i-1}, x_i..x_{i+width-1}),
    output = AND_i y_i ... (rare, exponentially small p, treewidth O(width))."""
    C = Circuit(n)
    prev = C.const(1)
    ys = []
    for i in range(n - width + 1):
        win = list(range(i, i + width))
        g = random_block_circuit(C, win + [prev], 4, rng)
        ys.append(g)
        prev = g
    return C.set_output(C.AND(*ys))
