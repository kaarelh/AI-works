"""Affine structure: presolve, affine-union envelopes, XPT arguments, biased
product distributions. Writes results/affine.json and results/affine_log.txt.

E1  120 inputs, 45 parity checks built from AND/OR/NOT XOR gadgets, AND a
    random 3-DNF on 15 other inputs (p ~ 1.5e-14).
E2  600 inputs, 100 dense random parity checks (native XOR gates) AND a
    3-DNF: a family on which every DNNF envelope has size * K >= c 2^88
    (with probability >= 1 - 2^-99 over the checks), while the affine
    envelope has K = O(1).
E3  The same kind of event at a size where DFSB can run (n = 36, m = 12;
    m > n/6, so this illustrates the barrier rather than instantiating it):
    DFSB versus the affine methods.
E4  Two-round Feistel trigger [L XOR f(R) = t] AND side condition, with a
    nonlinear round function: triangular presolve (p = 2^-40 * q).
E5  2-of-3 checksums through a threshold gate: the abstract interpretation
    sees nothing (threshold gates are opaque), an XPT argument splitting on
    two checks gives three affine leaves.
E6  Biased inputs Bern(1/3): banded LDPC checks (linear-order DP, exact
    masses) versus the copies gadget of the NP-hardness reduction (width
    above the cap: the method stays sound and becomes loose).
E7  Coverage: repeated runs against exact values.

Ground truths are computed without rareprob.affine: closed forms with a local
GF(2) rank (E1, E2, E3, E4), local GF(2) elimination on the raw check rows and
inclusion-exclusion (E5), an exact rational sweep over the bands (E6a),
enumeration of the 2^24-element coset (E6b), brute force in rational arithmetic
(E7). Every containment check is exact.
"""

import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from fractions import Fraction  # noqa
from itertools import product as iprod  # noqa

from rareprob import Circuit, Product  # noqa
from rareprob.exact import exact_prob_rational  # noqa
from rareprob.affine import (Affine, LinearOrderDP, affine_envelope, affine_envelope_estimate,  # noqa
                             presolve, presolve_estimate, xpt_check, xpt_honest, xpt_verify)
from rareprob.stats import mc_samples_needed  # noqa

OUT = os.path.join(os.path.dirname(__file__), "results")
LOG = []


def log(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    LOG.append(s)


# ------------------------------------------- ground truths independent of affine.py
def bits_of(mask):
    return [i for i in range(mask.bit_length()) if (mask >> i) & 1]


def gf2_solve(rows):
    """Gaussian elimination on [(mask, rhs)]: (consistent, rank, particular
    solution, kernel basis) for the system mask . y = rhs."""
    piv = {}                                   # pivot bit -> (mask, rhs), fully reduced
    for r, b in rows:
        for p, (r2, b2) in piv.items():
            if (r >> p) & 1:
                r, b = r ^ r2, b ^ b2
        if r == 0:
            if b:
                return False, len(piv), None, None
            continue
        p = r.bit_length() - 1
        for q in list(piv):
            r2, b2 = piv[q]
            if (r2 >> p) & 1:
                piv[q] = (r2 ^ r, b2 ^ b)
        piv[p] = (r, b)
    width = max([r.bit_length() for r, _ in rows] + [0])
    y0 = 0
    for p, (r, b) in piv.items():
        if b:
            y0 |= 1 << p                       # free coordinates 0, pivot = rhs
    kernel = []
    for f in range(width):
        if f in piv:
            continue
        v = 1 << f
        for p, (r, _) in piv.items():
            if (r >> f) & 1:
                v |= 1 << p
        kernel.append(v)
    return True, len(piv), y0, kernel


def rank_gf2(rows):
    return gf2_solve([(r, 0) for r in rows])[1]


def gxor(C, a, b):
    return C.AND(C.OR(a, b), C.NOT(C.AND(a, b)))


def xor_tree(C, lits):
    cur = lits[0]
    for l in lits[1:]:
        cur = gxor(C, cur, l)
    return cur


def random_dnf(C, vars_, terms, width, rng):
    ts = []
    for _ in range(terms):
        idx = rng.choice(vars_, width, replace=False)
        ts.append(C.AND(*[int(i) if rng.random() < 0.5 else C.NOT(int(i)) for i in idx]))
    return C.OR(*ts) if len(ts) > 1 else ts[0]


def eval_rate(C, D, rng, N=1 << 16):
    X = D.sample_packed(N, rng)
    t = time.time()
    reps = 0
    while time.time() - t < 0.5:
        C.eval_packed(X)
        reps += 1
    return reps * N / (time.time() - t)


def summarize(name, e, p, secs):
    """p: the exact value (an exact float or a Fraction); the containment check is exact."""
    r = dict(method=name, lo=e.lo, hi=e.hi, ratio=(e.hi / e.lo if e.lo > 0 else None),
             contains=bool(e.lo <= p <= e.hi) if p is not None else None, samples=e.samples,
             seconds=secs, note=e.note)
    rs = f"{r['ratio']:.4f}" if r["ratio"] is not None else "inf"
    log(f"  {name:28s} [{e.lo:.4e}, {e.hi:.4e}] ratio {rs} contains={r['contains']} "
        f"samples={e.samples} {secs:.2f}s  ({e.note})")
    return r


def mc_row(C, D, p, eps, delta, rng):
    N = mc_samples_needed(p, eps, delta)
    rate = eval_rate(C, D, rng)
    log(f"  Monte Carlo: {N:.3e} samples for the same guarantee; at {rate:.3e} evaluations/s "
        f"that is {N / rate:.3e} s")
    return dict(samples=N, evals_per_second=rate, seconds=N / rate)


def window_sweep(rows, n, q, k_pre, pred):
    """Exact Pr[pred(x_0..x_{k_pre-1}) and every check], x_i ~ Bern(q) i.i.d.
    (q a Fraction), for checks rows = [(S, rhs)] given by their coordinate
    lists: a sweep over the coordinates whose state is the prefix (until it is
    complete, then pred's value) and the parities of the open checks."""
    first = [min(S) for S, _ in rows]
    last = [max(S) for S, _ in rows]
    member = [set(S) for S, _ in rows]
    F = {((), ()): Fraction(1)}
    openc = []
    for i in range(n):
        newc = openc + [j for j in range(len(rows)) if first[j] == i]
        G = {}
        for (pre, st), f in F.items():
            par = dict(zip(openc, st))
            for j in newc:
                par.setdefault(j, 0)
            for x, pr in ((0, 1 - q), (1, q)):
                pp = dict(par)
                if x:
                    for j in newc:
                        if i in member[j]:
                            pp[j] ^= 1
                if any(last[j] == i and pp[j] != rows[j][1] for j in newc):
                    continue
                npre = pre + (x,) if i < k_pre else pre
                if i == k_pre - 1:
                    if not pred(npre):
                        continue
                    npre = ("ok",)
                key = (npre, tuple(pp[j] for j in newc if last[j] != i))
                G[key] = G.get(key, 0) + f * pr
        openc = [j for j in newc if last[j] != i]
        F = G
    return sum(F.values(), Fraction(0))


def coset_probability(rows, n0, q, k):
    """Exact sum over y in {H y = s} of q^(k|y|) (1-q)^(k(n0-|y|)) by
    enumerating the coset (2^(n0 - rank) points) and counting weights."""
    ok, r, y0, kernel = gf2_solve(rows)
    if not ok:
        return Fraction(0)
    pts = np.array([y0], dtype=np.uint64)
    for v in kernel:
        pts = np.concatenate([pts, pts ^ np.uint64(v)])
    counts = np.bincount(np.bitwise_count(pts).astype(np.int64), minlength=n0 + 1)
    return sum((int(c) * q ** (k * w) * (1 - q) ** (k * (n0 - w)) for w, c in enumerate(counts) if c),
               Fraction(0))


# ------------------------------------------------------------------ E1
def e1(rng):
    log("E1: 120 inputs, 45 gadget parity checks AND a 3-DNF on 15 inputs")
    n, m, kres = 120, 45, 15
    C = Circuit(n)
    rows, checks = [], []
    for _ in range(m):
        S = set(int(i) for i in rng.choice(np.arange(kres, n), 8, replace=False))
        S |= set(int(i) for i in rng.choice(n, 2, replace=False))
        S = sorted(S)
        rows.append(sum(1 << i for i in S))
        g = xor_tree(C, S)
        checks.append(g if rng.random() < 0.5 else C.NOT(g))
    R = random_dnf(C, np.arange(kres), 6, 3, rng)
    C.set_output(C.AND(R, *checks))
    # independent ground truth: if H restricted to the non-residual columns has
    # full rank m, then x_R is uniform given Hx = s, so p = 2^-m Pr[R]
    mask = ((1 << n) - 1) ^ ((1 << kres) - 1)
    assert rank_gf2(rows) == m and rank_gf2([r & mask for r in rows]) == m
    # Pr[R] by enumeration of the residual block: evaluate C's gate R on 2^15 points
    X = np.zeros((1 << kres, n), dtype=bool)
    X[:, :kres] = ((np.arange(1 << kres)[:, None] >> np.arange(kres)) & 1).astype(bool)
    sub = Circuit(n, list(C.ops), list(C.args), list(C.params), R)
    prR = float(sub.eval_bits(X).mean())
    p = 2.0 ** -m * prR
    log(f"  gates {len(C.ops) - n}, exact p = 2^-45 * {prR:.4f} = {p:.4e}")
    out = dict(n=n, m=m, gates=len(C.ops) - n, p=p, prR=prR, rows=[])
    eps, delta = 0.05, 0.01
    t = time.time()
    P = presolve(C)
    tp = time.time() - t
    log(f"  presolve: rank {P.rank} in {tp:.2f}s, reduced circuit {len(P.reduced.ops) - n} gates")
    t = time.time()
    e = presolve_estimate(C, None, eps, delta, rng, pre=P)
    out["rows"].append(summarize("presolve + MC residual", e, p, time.time() - t + tp))
    t = time.time()
    env = affine_envelope(C)
    Z = sum(2.0 ** -V.rank for V in env)
    e = affine_envelope_estimate(C, None, eps, delta, rng)
    r = summarize("affine envelope (KLM)", e, p, time.time() - t)
    r["K"] = Z / p
    r["pieces"] = len(env)
    log(f"  affine envelope: {len(env)} pieces, Z = {Z:.4e}, K = Z/p = {Z / p:.3f}")
    out["rows"].append(r)
    out["mc"] = mc_row(C, Product.uniform(n), p, eps, delta, rng)
    return out


# ------------------------------------------------------------------ E2
def dense_parity_instance(n, m, kres, rng, terms=6):
    C = Circuit(n)
    rows, checks = [], []
    while True:
        rows = [int(sum(1 << i for i in range(n) if rng.random() < 0.5)) for _ in range(m)]
        mask = ((1 << n) - 1) ^ ((1 << kres) - 1)
        if rank_gf2(rows) == m and rank_gf2([r & mask for r in rows]) == m:
            break
    for r in rows:
        g = C.XOR(*bits_of(r))
        checks.append(g if rng.random() < 0.5 else C.NOT(g))
    R = random_dnf(C, np.arange(kres), terms, 3, rng)
    C.set_output(C.AND(R, *checks))
    sub = Circuit(n, list(C.ops), list(C.args), list(C.params), R)
    X = np.zeros((1 << kres, n), dtype=bool)
    X[:, :kres] = ((np.arange(1 << kres)[:, None] >> np.arange(kres)) & 1).astype(bool)
    prR = float(sub.eval_bits(X).mean())
    return C, rows, prR


def e2(rng):
    log("E2: 600 inputs, 100 dense random parity checks AND a 3-DNF on 16 inputs")
    n, m, kres = 600, 100, 16
    C, rows, prR = dense_parity_instance(n, m, kres, rng)
    p = 2.0 ** -m * prR
    log(f"  exact p = 2^-100 * {prR:.4f} = {p:.4e};  c = Pr[C | V] = {prR:.4f}")
    lam = m - 12
    bound = prR * 2.0 ** lam
    log(f"  barrier: on the event of cor:random-parity (probability >= 1 - 2^(1-n/6) = 1 - 2^-99 for a")
    log(f"  uniform H), lambda_bal >= m - 12 = {lam}, so every smooth envelope circuit of C with fan-in-two")
    log(f"  products and leaves on <= 2n/3 inputs has |G| * K >= c 2^{lam} = {bound:.3e}")
    out = dict(n=n, m=m, p=p, c=prR, lambda_bal_lower=lam, dnnf_size_times_K_lower=bound, rows=[])
    eps, delta = 0.05, 0.01
    t = time.time()
    e = presolve_estimate(C, None, eps, delta, rng)
    out["rows"].append(summarize("presolve + MC residual", e, p, time.time() - t))
    t = time.time()
    env = affine_envelope(C)
    Z = sum(2.0 ** -V.rank for V in env)
    e = affine_envelope_estimate(C, None, eps, delta, rng)
    r = summarize("affine envelope (KLM)", e, p, time.time() - t)
    r["K"], r["pieces"] = Z / p, len(env)
    log(f"  affine envelope: {len(env)} pieces, K = {Z / p:.3f}")
    out["rows"].append(r)
    out["mc"] = mc_row(C, Product.uniform(n), p, eps, delta, rng)
    return out


# ------------------------------------------------------------------ E3
def e3(rng, budget_seconds=240):
    from rareprob.dfsb import dfsb_estimate
    log("E3: DNNF-based procedures versus affine methods on a dense parity event (n = 36, m = 12)")
    n, m, kres = 36, 12, 10
    C, rows, prR = dense_parity_instance(n, m, kres, rng, terms=4)
    p = 2.0 ** -m * prR
    D = Product.uniform(n)
    log(f"  exact p = 2^-12 * {prR:.4f} = {p:.4e}")
    out = dict(n=n, m=m, p=p, rows=[])
    eps, delta = 0.1, 0.05
    for name, f in [("presolve + MC residual", lambda: presolve_estimate(C, D, eps, delta, rng)),
                    ("affine envelope (KLM)", lambda: affine_envelope_estimate(C, D, eps, delta, rng))]:
        t = time.time()
        e = f()
        out["rows"].append(summarize(name, e, p, time.time() - t))
    t = time.time()
    e = dfsb_estimate(C, D, eps=eps, delta=delta, rng=rng, node_budget=400, max_leaf_samples=2 * 10**5)
    out["rows"].append(summarize("DFSB (node budget 400)", e, p, time.time() - t))
    out["mc"] = mc_row(C, D, p, eps, delta, rng)
    return out


# ------------------------------------------------------------------ E4
def e4(rng):
    log("E4: Feistel trigger [L XOR f(R) = t] AND side condition, k = 40, nonlinear f")
    k, extra = 40, 12
    n = 2 * k + extra
    C = Circuit(n)
    L, Rv = list(range(k)), list(range(k, 2 * k))
    t = rng.integers(0, 2, k)

    def lit(i):
        return int(i) if rng.random() < 0.5 else C.NOT(int(i))

    conj = []
    for j in range(k):
        terms = [C.AND(lit(a), lit(b), lit(c)) for a, b, c in (rng.choice(Rv, 3, replace=False) for _ in range(4))]
        f = C.OR(*terms)
        g = gxor(C, L[j], f)
        conj.append(g if t[j] else C.NOT(g))
    side_vars = list(range(2 * k, n))
    side = random_dnf(C, np.array(side_vars), 4, 3, rng)
    C.set_output(C.AND(side, *conj))
    sub = Circuit(n, list(C.ops), list(C.args), list(C.params), side)
    X = np.zeros((1 << extra, n), dtype=bool)
    X[:, 2 * k:] = ((np.arange(1 << extra)[:, None] >> np.arange(extra)) & 1).astype(bool)
    q = float(sub.eval_bits(X).mean())
    p = 2.0 ** -k * q   # the round function is arbitrary: Pr[L = t + f(R)] = 2^-k for every R
    log(f"  exact p = 2^-40 * {q:.4f} = {p:.4e}")
    out = dict(k=k, n=n, p=p, rows=[])
    eps, delta = 0.05, 0.01
    t0 = time.time()
    P = presolve(C)
    log(f"  presolve: {len(P.rref)} affine rows, {len(P.solved)} solved-form conjuncts")
    e = presolve_estimate(C, None, eps, delta, rng, pre=P)
    out["rows"].append(summarize("triangular presolve", e, p, time.time() - t0))
    out["solved"] = len(P.solved)
    t0 = time.time()
    e = affine_envelope_estimate(C, None, eps, delta, rng, max_samples=10**5)
    out["rows"].append(summarize("affine envelope (KLM)", e, p, time.time() - t0))
    out["mc"] = mc_row(C, Product.uniform(n), p, eps, delta, rng)
    return out


# ------------------------------------------------------------------ E5
def e5(rng):
    log("E5: 2-of-3 checksums through a threshold gate (XPT argument)")
    n, kres, rowsper = 90, 10, 14
    C = Circuit(n)
    blocks, hs = [], []
    for b in range(3):
        rows = []
        gs = []
        for _ in range(rowsper):
            S = [int(i) for i in rng.choice(np.arange(kres, n), 12, replace=False)]
            g = xor_tree(C, S)
            pos = rng.random() < 0.5
            gs.append(g if pos else C.NOT(g))
            rows.append((sum(1 << i for i in S), int(pos)))   # the check says parity(x_S) = pos
        blocks.append(rows)
        hs.append(C.AND(*gs))
    maj = C.THR(hs, [1, 1, 1], 2)
    R = random_dnf(C, np.arange(kres), 4, 3, rng)
    C.set_output(C.AND(maj, R))
    # exact p: R is independent of the checks (disjoint inputs); the 2-of-3
    # event's probability by inclusion-exclusion over the three subspaces
    sub = Circuit(n, list(C.ops), list(C.args), list(C.params), R)
    X = np.zeros((1 << kres, n), dtype=bool)
    X[:, :kres] = ((np.arange(1 << kres)[:, None] >> np.arange(kres)) & 1).astype(bool)
    prR = float(sub.eval_bits(X).mean())
    # inclusion-exclusion over the three subspaces, from the raw check rows
    # (local GF(2) elimination, independent of the module under test)
    def mass(sel):
        ok, r, _, _ = gf2_solve([row for i in sel for row in blocks[i]])
        return Fraction(1, 2 ** r) if ok else Fraction(0)
    p2of3 = mass([0, 1]) + mass([0, 2]) + mass([1, 2]) - 2 * mass([0, 1, 2])
    p_exact = p2of3 * Fraction(prR)  # prR = count / 2^10, exact
    p = float(p_exact)
    log(f"  exact p = Pr[2 of 3] * Pr[R] = {p2of3:.4e} * {prR:.4f} = {p:.4e}")
    out = dict(n=n, p=p, rows=[])
    eps, delta = 0.05, 0.01
    t0 = time.time()
    e = affine_envelope_estimate(C, None, eps, delta, rng, max_samples=10**5)
    out["rows"].append(summarize("affine envelope (KLM)", e, p_exact, time.time() - t0))
    t0 = time.time()
    arg = xpt_honest(C, [("gate", hs[0]), ("gate", hs[1])])
    leaves, st = xpt_check(C, arg)
    log(f"  XPT argument: {st['nodes']} nodes, {st['open']} open leaves, {st['closed']} closed")
    e = xpt_verify(C, None, arg, eps, delta, rng)
    out["rows"].append(summarize("XPT argument + KLM", e, p_exact, time.time() - t0))
    out["xpt"] = st
    out["argument_bytes"] = len(json.dumps(arg))
    out["mc"] = mc_row(C, Product.uniform(n), p, eps, delta, rng)
    return out


# ------------------------------------------------------------------ E6
def e6(rng):
    log("E6: biased inputs Bern(1/3)")
    out = {}
    # (a) banded LDPC: every check on a window of 8 consecutive inputs
    n, m = 300, 100
    C = Circuit(n)
    V = Affine()
    checks = []
    x0 = rng.random(n) < 1 / 3
    rows_a = []
    for j in range(m):
        lo = int(j * (n - 8) / m)
        S = [lo + d for d in range(8) if rng.random() < 0.6] or [lo]
        rhs = int(sum(x0[S]) & 1)  # consistent with a point of the support
        g = C.XOR(*S)
        checks.append(g if rhs else C.NOT(g))
        V.add(sum(1 << i for i in S), rhs)
        rows_a.append((S, rhs))
    R = C.OR(C.AND(0, 1), C.AND(2, 3, 4), C.AND(C.NOT(5), 6))
    C.set_output(C.AND(R, *checks))
    D = Product(np.full(n, 1 / 3))
    t0 = time.time()
    dp = LinearOrderDP(V, D)
    log(f"  (a) banded LDPC n={n}, m={m} (rank {V.rank}): D(V) = {dp.mass:.4e} by the linear-order DP, "
        f"width 2^{dp.width}, {time.time() - t0:.2f}s")
    # exact p by an exact rational sweep over the coordinates (independent of
    # the module): the state is (x_0..x_6 while they are being read, then the
    # value of R) and the parities of the checks whose window is open
    t0 = time.time()
    p_exact = window_sweep(rows_a, n, Fraction(1 / 3), 7,
                           lambda xs: (xs[0] and xs[1]) or (xs[2] and xs[3] and xs[4]) or ((not xs[5]) and xs[6]))
    p = float(p_exact)
    # cross-check with the module's dynamic program (conditioning on x_0..x_6)
    pr = 0.0
    for bits in iprod([0, 1], repeat=7):
        xs = dict(enumerate(bits))
        if not ((xs[0] and xs[1]) or (xs[2] and xs[3] and xs[4]) or ((not xs[5]) and xs[6])):
            continue
        W = V.copy()
        if all(W.add(1 << i, b) for i, b in xs.items()):
            pr += LinearOrderDP(W, D).mass
    log(f"  exact p = {p:.6e} (exact rational sweep, {time.time() - t0:.1f}s); "
        f"the module's DP gives {pr:.6e} (rel. diff {abs(pr / p - 1):.1e})")
    ra = dict(n=n, m=m, p=p, mass_V=dp.mass, width=dp.width, rows=[])
    eps, delta = 0.05, 0.01
    t0 = time.time()
    e = affine_envelope_estimate(C, D, eps, delta, rng)
    ra["rows"].append(summarize("affine envelope (DP pieces)", e, p_exact, time.time() - t0))
    t0 = time.time()
    e = presolve_estimate(C, D, eps, delta, rng, max_samples=2 * 10**5)
    ra["rows"].append(summarize("presolve, biased pivots", e, p_exact, time.time() - t0))
    ra["mc"] = mc_row(C, D, p, eps, delta, rng)
    out["banded"] = ra
    # (b) the copies gadget: AND of copy equalities and [H x_0 = s], dense H
    n0, m0, k = 36, 12, 6
    N = n0 * k
    C = Circuit(N)
    Hrows = [int(sum(1 << i for i in range(n0) if rng.random() < 0.5)) for _ in range(m0)]
    xs = rng.random(n0) < 0.5
    conj = []
    W = Affine()
    for r in Hrows:
        S = [i * k for i in bits_of(r)]
        rhs = int(sum(xs[bits_of(r)]) & 1)
        g = C.XOR(*S)
        conj.append(g if rhs else C.NOT(g))
        W.add(sum(1 << s for s in S), rhs)
    for i in range(n0):
        for c in range(1, k):
            g = C.XOR(i * k, i * k + c)
            conj.append(C.NOT(g))
            W.add((1 << (i * k)) | (1 << (i * k + c)), 0)
    C.set_output(C.AND(*conj))
    D = Product(np.full(N, 1 / 3))
    t0 = time.time()
    pb_exact = coset_probability([(r, int(sum(xs[bits_of(r)]) & 1)) for r in Hrows], n0, Fraction(1 / 3), k)
    pb = float(pb_exact)
    log(f"  (b) copies gadget n0={n0}, m0={m0}, k={k} (N={N}): exact p = {pb:.6e} by enumerating the coset "
        f"({time.time() - t0:.1f}s)")
    t0 = time.time()
    dpb = LinearOrderDP(W, D, max_width=16)
    log(f"  the linear-order DP has width 2^{dpb.width} and gives {dpb.mass:.6e} (rel. diff "
        f"{abs(dpb.mass / pb - 1):.1e}, {time.time() - t0:.1f}s); the hardness reduction needs width ~ m0 -> infinity")
    rb = dict(n0=n0, m0=m0, k=k, N=N, p=pb, width=dpb.width, rows=[])
    for cap in (6, 16):
        t0 = time.time()
        e = affine_envelope_estimate(C, D, eps, delta, rng, max_width=cap, max_samples=2 * 10**5)
        rb["rows"].append(summarize(f"affine envelope, width cap {cap}", e, pb_exact, time.time() - t0))
    out["copies"] = rb
    return out


# ------------------------------------------------------------------ E7
def e7(rng):
    log("E7: coverage against exact values (n = 16, eps = 0.1, delta = 0.05)")
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code", "tests"))
    from test_affine import random_mixed_circuit  # noqa
    n = 16
    res = {}
    for name in ("presolve (uniform)", "presolve (product)", "affine envelope (uniform)",
                 "affine envelope (product)"):
        res[name] = dict(runs=0, misses=0, tight=0)
    for trial in range(150):
        C = random_mixed_circuit(n, rng, int(rng.integers(2, 6)), int(rng.integers(2, 14)))
        for prod in (False, True):
            D = Product(rng.choice([0.5, 0.5, 0.3, 0.7], n)) if prod else Product.uniform(n)
            p = exact_prob_rational(C, D)  # a Fraction: the comparison is exact
            for nm, f in (("presolve", presolve_estimate), ("affine envelope", affine_envelope_estimate)):
                e = f(C, D, 0.1, 0.05, rng, max_samples=2 * 10**5)
                key = f"{nm} ({'product' if prod else 'uniform'})"
                res[key]["runs"] += 1
                res[key]["misses"] += int(not (e.lo <= p <= e.hi))
                res[key]["tight"] += int(e.lo > 0 and e.hi <= 1.1 * e.lo)
    for k, v in res.items():
        log(f"  {k:28s} runs {v['runs']}, intervals missing p: {v['misses']}, tight: {v['tight']}")
    return res


def main():
    rng = np.random.default_rng(2026)
    t = time.time()
    res = {}
    for name, f in [("E1", e1), ("E2", e2), ("E4", e4), ("E5", e5), ("E6", e6), ("E3", e3), ("E7", e7)]:
        t0 = time.time()
        res[name] = f(rng)
        log(f"  [{name} took {time.time() - t0:.1f}s]\n")
    res["total_seconds"] = time.time() - t
    log(f"total {res['total_seconds']:.1f}s")
    os.makedirs(OUT, exist_ok=True)
    json.dump(res, open(os.path.join(OUT, "affine.json"), "w"), indent=1, default=float)
    open(os.path.join(OUT, "affine_log.txt"), "w").write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        rng = np.random.default_rng(2026)
        for name in sys.argv[1:]:
            globals()[name.lower()](rng)
    else:
        main()
