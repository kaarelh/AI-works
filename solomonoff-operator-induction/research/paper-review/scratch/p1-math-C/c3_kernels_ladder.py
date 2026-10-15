r"""c3 (reviewer p1-math-C): independent checks for nn.tex / app-nn.tex and comp.tex / app-comp.tex.

(a) rem:nn:oddparity(a): for the bias-free two-layer ReLU NNGP profile Psi1(rho)=(sqrt(1-rho^2)+rho(pi-arccos rho))/pi
    and NTK profile Psi1+rho*Psi0, Psi0=(pi-arccos rho)/pi, the Walsh eigenvalue Lambda_k = E_z[Psi(sum z/d) chi_S(z)],
    |S|=k, vanishes for odd k>=3 (d=8, exact enumeration of the cube).
(b) rem:nn:oddparity(c): for kernel ridge regression with these kernels and |S|=3, the unseen-point sum of g*chi_S equals
    minus the training sum, and the training sum y^T K (K+beta I)^{-1} y is >= 0 (d=8, random training sets, seed 5).
(c) thm:comp:ladder for formulas (leaves x_j, not x_j, 0, 1; AND/OR/XOR; size = #leaves), d = 3, 4: least-size consistent
    functions at the start of stage k are exactly the k-conjunctions; Occam (ties by truth-table index) mistakes.
(d) thm:comp:ladder for circuits of def:comp:circuits (16 two-input gates, inputs x_j, 0, 1, earlier gates), d = 4,
    stages k = 2, 3 (circuits of size <= 2 suffice): least-size consistent functions are the k-conjunctions.
Deterministic except (b) (seeded).
"""
import itertools
import math
import random

import numpy as np

OUT = []


def say(s=""):
    print(s)
    OUT.append(s)


def cube(d):
    return np.array(list(itertools.product([1, -1], repeat=d)), dtype=float)


def psi0(r):
    return (math.pi - np.arccos(np.clip(r, -1, 1))) / math.pi


def psi1(r):
    r = np.clip(r, -1, 1)
    return (np.sqrt(1 - r ** 2) + r * (math.pi - np.arccos(r))) / math.pi


def part_a(d=8):
    Z = cube(d)
    rho = Z.sum(axis=1) / d
    for name, psi in [("NNGP", psi1), ("NTK", lambda r: psi1(r) + r * psi0(r))]:
        h = psi(rho)
        lams = []
        for k in range(d + 1):
            chi = np.prod(Z[:, :k], axis=1) if k > 0 else np.ones(len(Z))
            lams.append(float(np.mean(h * chi)))
        odd = [abs(lams[k]) for k in range(3, d + 1, 2)]
        say(f"(a) {name} d={d}: Lambda_k = " + ", ".join(f"{l:.2e}" for l in lams)
            + f";  max |Lambda_k| over odd k>=3 = {max(odd):.1e}")
    # evenness identities
    r = np.linspace(-1, 1, 2001)
    e1 = np.max(np.abs((psi1(r) - psi1(-r)) - r))
    e2 = np.max(np.abs((r * psi0(r) + r * psi0(-r)) - r))
    say(f"(a) max |Psi1(r)-Psi1(-r)-r| = {e1:.1e};  max |r Psi0(r) - (-r)Psi0(-r) - r| = {e2:.1e}")


def part_b(d=8, ntrials=6):
    rng = random.Random(5)
    Z = cube(d)
    N = len(Z)
    S = [0, 1, 2]
    chi = np.prod(Z[:, S], axis=1)
    for name, psi in [("NNGP", psi1), ("NTK", lambda r: psi1(r) + r * psi0(r))]:
        Kfull = psi(Z @ Z.T / d)
        worst_id, min_train = 0.0, float("inf")
        for _ in range(ntrials):
            n = rng.choice([40, 100, 160, 200])
            idx = rng.sample(range(N), n)
            U = [i for i in range(N) if i not in set(idx)]
            K = Kfull[np.ix_(idx, idx)]
            y = chi[idx]
            beta = 1e-3 * np.mean(np.diag(K))
            alpha = np.linalg.solve(K + beta * np.eye(n), y)
            g = Kfull[:, idx] @ alpha
            train = float(g[idx] @ chi[idx])
            unseen = float(g[U] @ chi[U])
            worst_id = max(worst_id, abs(train + unseen) / max(1.0, abs(train)))
            min_train = min(min_train, train)
        say(f"(b) {name}: max relative |train sum + unseen sum| = {worst_id:.1e}; min training sum = {min_train:.3f} (>= 0)")


# ---------- formulas ----------
def truth_tables(d):
    pts = list(itertools.product([0, 1], repeat=d))
    return pts


def tt_var(d, j, pts):
    v = 0
    for i, p in enumerate(pts):
        if p[j]:
            v |= 1 << i
    return v


def formula_sizes(d, smax):
    pts = truth_tables(d)
    full = (1 << len(pts)) - 1
    leaves = set()
    for j in range(d):
        v = tt_var(d, j, pts)
        leaves.add(v)
        leaves.add(full ^ v)
    leaves.add(0)
    leaves.add(full)
    by_size = {1: set(leaves)}
    best = {f: 1 for f in leaves}
    for s in range(2, smax + 1):
        new = set()
        for a in range(1, s):
            b = s - a
            for f in by_size[a]:
                for g in by_size[b]:
                    new.add(f & g)
                    new.add(f | g)
                    new.add(f ^ g)
        by_size[s] = new
        for f in new:
            if f not in best:
                best[f] = s
    return pts, best


def ladder_occam(d, pts, best, kmax_size_known):
    """Simulate Occam (least size, ties by truth-table integer) on the ladder; return stage-wise mistakes."""
    target = 1 << pts.index(tuple([1] * d))
    data = {}

    def consistent(f):
        return all(((f >> i) & 1) == y for i, y in data.items())

    def occam():
        cands = [f for f in best if consistent(f)]
        m = min(best[f] for f in cands)
        return min(f for f in cands if best[f] == m), m

    mistakes = {}
    order = [tuple([1] * d), tuple([0] * d)]
    for p in order:
        i = pts.index(p)
        data[i] = 1 if p == tuple([1] * d) else 0
    stage_ok = True
    for k in range(1, d):
        level = [i for i, p in enumerate(pts) if sum(p) == k]
        # least-size consistent set at the start of stage k
        cands = [f for f in best if consistent(f)]
        m = min(best[f] for f in cands)
        least = sorted(f for f in cands if best[f] == m)
        conj = sorted(tt_conj(d, S, pts) for S in itertools.combinations(range(d), k))
        if least != conj:
            stage_ok = False
        cnt = 0
        remaining = list(level)
        while remaining:
            h, _ = occam()
            # pick an unrevealed level input on which h errs (label 0 there)
            errs = [i for i in remaining if ((h >> i) & 1) != 0]
            i = errs[0] if errs else remaining[0]
            if ((h >> i) & 1) != 0:
                cnt += 1
            data[i] = 0
            remaining.remove(i)
        mistakes[k] = cnt
    return stage_ok, mistakes


def tt_conj(d, S, pts):
    v = 0
    for i, p in enumerate(pts):
        if all(p[j] for j in S):
            v |= 1 << i
    return v


def part_c():
    for d in (3, 4):
        pts, best = formula_sizes(d, d)
        ok, mis = ladder_occam(d, pts, best, d)
        say(f"(c) formulas d={d}: least-size consistent = k-conjunctions at every stage: {ok}; "
            f"level mistakes {mis}; total {sum(mis.values())} (paper: >= 2^d-2 = {2 ** d - 2})")


# ---------- circuits ----------
def part_d(d=4):
    pts = truth_tables(d)
    npts = len(pts)
    full = (1 << npts) - 1
    base = [tt_var(d, j, pts) for j in range(d)] + [0, full]

    def gate(t, a, b):
        # gate type t in 0..15: output bit for (a_bit, b_bit) is bit (2a+b) of t
        r = 0
        for (ab, bb) in itertools.product([0, 1], repeat=2):
            if (t >> (2 * ab + bb)) & 1:
                ma = a if ab else (full ^ a)
                mb = b if bb else (full ^ b)
                r |= ma & mb
        return r

    funcs = {1: set(), 2: set()}
    for t in range(16):
        for a in base:
            for b in base:
                funcs[1].add(gate(t, a, b))
    # size 2: gate1 as above, gate2 with inputs from base + gate1
    for t1 in range(16):
        for a in base:
            for b in base:
                g1 = gate(t1, a, b)
                ins = base + [g1]
                for t2 in range(16):
                    for c in ins:
                        for e in ins:
                            funcs[2].add(gate(t2, c, e))
    best = {}
    for s in (1, 2):
        for f in funcs[s]:
            best.setdefault(f, s)
    one = pts.index(tuple([1] * d))
    for k in (2, 3):
        data = {one: 1}
        for i, p in enumerate(pts):
            if sum(p) < k:
                data[i] = 0
        cands = [f for f in best if all(((f >> i) & 1) == y for i, y in data.items())]
        m = min(best[f] for f in cands)
        least = sorted(f for f in cands if best[f] == m)
        conj = sorted(tt_conj(d, S, pts) for S in itertools.combinations(range(d), k))
        say(f"(d) circuits d={d}, stage k={k}: least consistent size {m} (paper: k-1={k - 1}); "
            f"least-size consistent = k-conjunctions: {least == conj}")


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    with open(__file__.replace(".py", ".out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
