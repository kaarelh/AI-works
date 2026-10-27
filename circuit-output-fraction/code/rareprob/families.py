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
    """The same DNF written badly: each literal routed through up to `noise`
    XOR identities x = (x XOR r) XOR r, r a random other input variable (a
    draw with r = i is skipped), terms built as balanced trees, and the OR
    written as NOT(AND(NOT ...)).
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
    written as AND of XNORs with constants and R is a random circuit drawn on
    the remaining variables, resampled until Pr[R] >= 0.05 on 4096 samples; its
    output may depend on only some of them. Uniform p = 2^-k * Pr[R]."""
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
    C.set_output(C.THR(outs, [1] * k, t))
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


def dnf_exact(terms, D) -> float:
    """Exact Pr[DNF] by inclusion-exclusion over term subsets (m <= ~22)."""
    m = len(terms)
    if m > 22:
        raise ValueError("dnf_exact: inclusion-exclusion needs at most 22 terms")
    tot = 0.0
    # iterate subsets via Gray-code-free recursion with pruning of contradictions
    def rec(j, lits, sign_count):
        nonlocal tot
        for k in range(j, m):
            new = dict(lits)
            ok = True
            for i, b in terms[k]:
                if new.get(i, b) != b:
                    ok = False
                    break
                new[i] = b
            if not ok:
                continue
            pr = 1.0
            for i, b in new.items():
                pr *= D.lit_prob(i, b)
            tot += pr if sign_count % 2 == 0 else -pr
            rec(k + 1, new, sign_count + 1)

    rec(0, {}, 0)
    return tot


def linear_hash_trigger(n_body: int, k: int, rng: np.random.Generator, rows: int | None = None,
                        body_gates: int = 40):
    """R(x_body) AND [A x_S == A a] over F2, A a dense random (rows x k)
    matrix of full column rank, so the trigger is the subcube x_S = a written
    through a linear hash. Unit propagation cannot see the subcube (the XOR
    constraints are dense); a SAT solver (or Gaussian elimination) can.
    Returns (C, S, a, body_vars)."""
    rows = rows or k + 4
    n = k + n_body
    while True:
        A = rng.integers(0, 2, size=(rows, k))
        if np.linalg.matrix_rank(A.astype(float)) == k:
            # rank over GF(2) check
            M = A.copy() % 2
            r = 0
            for c in range(k):
                piv = [i for i in range(r, rows) if M[i, c]]
                if not piv:
                    break
                M[[r, piv[0]]] = M[[piv[0], r]]
                for i in range(rows):
                    if i != r and M[i, c]:
                        M[i] ^= M[r]
                r += 1
            if r == k:
                break
    S = list(range(k))
    a = rng.integers(0, 2, size=k)
    target = A.dot(a) % 2
    body = list(range(k, n))
    C = Circuit(n)
    checks = []
    for i in range(rows):
        cols = [S[j] for j in range(k) if A[i, j]]
        par = C.XOR(*cols) if len(cols) > 1 else cols[0]
        checks.append(par if target[i] else C.NOT(par))
    trig = C.AND(*checks)
    while True:
        Cr = Circuit(n)
        R = random_block_circuit(Cr, body, body_gates, rng)
        Cr.set_output(R)
        if Cr.eval_bits(rng.random((4096, n)) < 0.5).mean() >= 0.05:
            break
    m = list(range(n))
    for v in range(n, len(Cr.ops)):
        m.append(C.add(Cr.ops[v], [m[u] for u in Cr.args[v]], Cr.params[v]))
    C.set_output(C.AND(trig, m[R]))
    return C, S, [int(t) for t in a], body


def spn_trigger(n_body: int, k: int, rounds: int, rng: np.random.Generator, body_gates: int = 40):
    """R(x_body) AND [SPN(x_S) == y]: a substitution-permutation network on
    k = 4j bits (random bijective 4-bit S-boxes, random invertible dense
    GF(2) linear layers, random round constants), compared with a fixed
    output y = SPN(a). The trigger set is the single point x_S = a, but
    neither unit propagation nor Gaussian elimination can see it; a CDCL
    solver finds and refutes alternatives. Returns (C, S, a, body_vars)."""
    if k % 4:
        raise ValueError("spn_trigger: k must be a multiple of 4")
    n = k + n_body
    S = list(range(k))
    body = list(range(k, n))
    sboxes = [rng.permutation(16) for _ in range(rounds * (k // 4))]

    def inv_matrix():
        while True:
            M = rng.integers(0, 2, size=(k, k))
            A = M.copy()
            r = 0
            for c in range(k):
                piv = [i for i in range(r, k) if A[i, c]]
                if not piv:
                    break
                A[[r, piv[0]]] = A[[piv[0], r]]
                for i in range(k):
                    if i != r and A[i, c]:
                        A[i] ^= A[r]
                r += 1
            if r == k:
                return M

    mats = [inv_matrix() for _ in range(rounds)]
    consts = [rng.integers(0, 2, size=k) for _ in range(rounds)]
    a = rng.integers(0, 2, size=k)

    def spn_eval(bits):
        b = np.array(bits) % 2
        for r in range(rounds):
            out = []
            for j in range(k // 4):
                v = int(b[4 * j] + 2 * b[4 * j + 1] + 4 * b[4 * j + 2] + 8 * b[4 * j + 3])
                w = sboxes[r * (k // 4) + j][v]
                out += [(w >> t) & 1 for t in range(4)]
            b = (mats[r].dot(np.array(out)) + consts[r]) % 2
        return b

    y = spn_eval(a)
    C = Circuit(n)
    one = C.const(1)
    wires = list(S)
    for r in range(rounds):
        out = []
        for j in range(k // 4):
            ins = wires[4 * j: 4 * j + 4]
            box = sboxes[r * (k // 4) + j]
            # each output bit as an OR of minterms over the 4 inputs
            lit = {(t, bv): (ins[t] if bv else C.NOT(ins[t])) for t in range(4) for bv in (0, 1)}
            for t in range(4):
                terms = []
                for v in range(16):
                    if (box[v] >> t) & 1:
                        terms.append(C.AND(*[lit[(u, (v >> u) & 1)] for u in range(4)]))
                out.append(C.OR(*terms))
        new = []
        for i in range(k):
            cols = [out[j] for j in range(k) if mats[r][i, j]]
            g = C.XOR(*cols) if len(cols) > 1 else cols[0]
            if consts[r][i]:
                g = C.XOR(g, one)
            new.append(g)
        wires = new
    checks = [w if y[i] else C.NOT(w) for i, w in enumerate(wires)]
    trig = C.AND(*checks)
    while True:
        Cr = Circuit(n)
        R = random_block_circuit(Cr, body, body_gates, rng)
        Cr.set_output(R)
        if Cr.eval_bits(rng.random((4096, n)) < 0.5).mean() >= 0.05:
            break
    m = list(range(n))
    for v in range(n, len(Cr.ops)):
        m.append(C.add(Cr.ops[v], [m[u] for u in Cr.args[v]], Cr.params[v]))
    C.set_output(C.AND(trig, m[R]))
    return C, S, [int(t) for t in a], body


def dnf_of_blocks(m: int, L: int, b: int, n: int, rng: np.random.Generator, gates: int = 8):
    """OR of m terms, each an AND of L random dense circuits on disjoint
    b-variable blocks (blocks of different terms may overlap). Returns
    (C, terms) with terms[i] = list of (vars, circuit-copy) for exact checks."""
    C = Circuit(n)
    tgates = []
    for _ in range(m):
        vs = rng.choice(n, size=L * b, replace=False)
        outs = []
        for j in range(L):
            blk = [int(v) for v in vs[j * b:(j + 1) * b]]
            while True:
                Cb = Circuit(n)
                g = random_block_circuit(Cb, blk, gates, rng)
                Cb.set_output(g)
                X = ((np.arange(1 << b)[:, None] >> np.arange(b)) & 1).astype(bool)
                full = np.zeros((1 << b, n), dtype=bool)
                full[:, blk] = X
                pj = Cb.eval_bits(full).mean()
                if 0.2 <= pj <= 0.8:
                    break
            mp = list(range(n))
            for v in range(n, len(Cb.ops)):
                mp.append(C.add(Cb.ops[v], [mp[u] for u in Cb.args[v]], Cb.params[v]))
            outs.append(mp[g])
        tgates.append(C.AND(*outs))
    C.set_output(C.OR(*tgates))
    return C


def chain_cnf_clauses(n: int, w: int, rng: np.random.Generator, order=None):
    """Clauses on sliding windows of width w along a variable order (pathwidth <= w)."""
    order = list(rng.permutation(n)) if order is None else order
    return [[(int(v), int(rng.integers(0, 2))) for v in order[s:s + w]] for s in range(n - w + 1)]


def or_of_chain_cnfs(n: int, t: int, w: int, rng: np.random.Generator, small_cone_safe: bool = True):
    """OR of t CNFs, each with sliding-window clauses of width w along its own
    random variable order. Context width O(w); exact counting #P-hard in general.
    The AND of each CNF is built as a left-deep chain of binary ANDs (a path
    dtree), which is what makes the context width small."""
    C = Circuit(n)
    tops = []
    for _ in range(t):
        cls = chain_cnf_clauses(n, w, rng)
        gs = [C.OR(*[C.lit(i, b) for i, b in c]) for c in cls]
        acc = gs[0]
        for g in gs[1:]:
            acc = C.AND(acc, g)
        tops.append(acc)
    return C.set_output(C.OR(*tops))
