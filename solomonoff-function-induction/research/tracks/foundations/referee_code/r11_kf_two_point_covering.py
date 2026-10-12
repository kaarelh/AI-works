"""r11 (referee, second pass): the combinatorics behind "K_F versus -log W" on two-point data.

Context (referee.md, issue M1): Problem 4.6(a) of notes.md asks whether -log W(D) = K_F(D) + O(1).
The referee's argument has two halves:
  * lower bound: if every two-point binary data set on M inputs had K_F < g, the fewer than 2^g
    programs of length < g would form a family of functions that "covers" every two-point
    labelled set, i.e. shows all four label patterns on every pair of inputs.  Such a family
    needs at least log_3 M members (pigeonhole, as in Prop 4.3); the exact minimum is given by
    Kleitman-Spencer's 2-independent families.
  * upper bound: W loses only K(padded tape length) on fair-coin labels (lookup table), so
    -log W(D) <= 2 + K(ceil(log2(n+1))) + O(1) on every two-point binary D with n-bit inputs.
This script checks the combinatorial facts exactly on small cases; the complexity terms are not
computable and are not checked here.

(a) For ground sets of size N = 3..8 (N = number of functions), the largest number M of inputs
    that N binary functions can 2-cover (every pair of distinct inputs shows all four patterns
    00,01,10,11) is computed by an exact maximum-clique search and compared with the
    Kleitman-Spencer value C(N-1, floor(N/2)-1) (reference unverified; snippet only).
(b) For N <= 5, allowing *partial* functions (value 0, 1 or undefined) does not increase M.
(c) The pigeonhole bound used in the referee's lower bound: two inputs with equal colour
    (vector of values in {0,1,*}) cannot be separated as (0,1); so M <= 3^N.  Table of the
    exact minimum N(M) for M = 2^n against n / log2(3).
(d) The covering bound for the single shortest program with k labels: a family of
    N > 2^k * ln(#labelled k-sets) random functions covers all labelled k-subsets with positive
    probability.  Seeded greedy coverings for M = 8, 16 inputs and k = 2, 3 are compared with
    this bound and with the trivial lower bound 2^k.

Deterministic except (d) (seed 20261012).  Output: r11_kf_two_point_covering_output.txt
"""
import itertools
import math
import random


def two_indep(a, b, N):
    full = (1 << N) - 1
    return (a & b) and (a & ~b & full) and (~a & b & full) and (~a & ~b & full)


def max_clique(adj, verts):
    """Tomita-style branch and bound with greedy colouring; adj[v] is a bitset of neighbours."""
    best = [0, []]

    def colour_sort(P):
        order, bounds = [], []
        U = P
        c = 0
        while U:
            c += 1
            Q = U
            while Q:
                v = (Q & -Q).bit_length() - 1
                Q &= ~(1 << v)
                Q &= ~adj[v]
                U &= ~(1 << v)
                order.append(v)
                bounds.append(c)
        return order, bounds

    def expand(R, P):
        order, bounds = colour_sort(P)
        for i in range(len(order) - 1, -1, -1):
            if len(R) + bounds[i] <= best[0]:
                return
            v = order[i]
            R2 = R + [v]
            P2 = P & adj[v]
            if P2:
                expand(R2, P2)
            elif len(R2) > best[0]:
                best[0], best[1] = len(R2), R2
            P &= ~(1 << v)

    P = 0
    for v in verts:
        P |= 1 << v
    expand([], P)
    return best[0], best[1]


def max_family_total(N):
    # complementing a member preserves 2-independence, so wlog no member contains element N-1
    verts = [a for a in range(1, 1 << (N - 1))]
    idx = {a: i for i, a in enumerate(verts)}
    adj = [0] * len(verts)
    for a, b in itertools.combinations(verts, 2):
        if two_indep(a, b, N):
            adj[idx[a]] |= 1 << idx[b]
            adj[idx[b]] |= 1 << idx[a]
    size, _ = max_clique(adj, range(len(verts)))
    return size


def max_family_partial(N):
    # an input is a pair (A,B) of disjoint subsets of [N]: A = functions giving 0, B = giving 1
    verts = []
    for code in itertools.product((0, 1, 2), repeat=N):
        A = sum(1 << i for i, c in enumerate(code) if c == 0)
        B = sum(1 << i for i, c in enumerate(code) if c == 1)
        verts.append((A, B))
    n = len(verts)
    adj = [0] * n
    for i in range(n):
        A1, B1 = verts[i]
        for j in range(i + 1, n):
            A2, B2 = verts[j]
            if (A1 & A2) and (A1 & B2) and (B1 & A2) and (B1 & B2):
                adj[i] |= 1 << j
                adj[j] |= 1 << i
    size, _ = max_clique(adj, range(n))
    return size


def greedy_cover(M, k, rng, pool=4000):
    targets = set()
    for S in itertools.combinations(range(M), k):
        for lab in itertools.product((0, 1), repeat=k):
            targets.add((S, lab))
    fam = []
    while targets:
        best, best_cov = None, -1
        cands = [rng.getrandbits(M) for _ in range(pool)]
        for f in cands:
            cov = 0
            for S, lab in targets:
                if all(((f >> s) & 1) == l for s, l in zip(S, lab)):
                    cov += 1
            if cov > best_cov:
                best, best_cov = f, cov
        fam.append(best)
        targets = {(S, lab) for S, lab in targets
                   if not all(((best >> s) & 1) == l for s, l in zip(S, lab))}
    return len(fam)


def main():
    out = []
    ks = {}
    out.append("(a) largest M such that N binary total functions 2-cover M inputs (exact max clique)")
    for N in range(3, 9):
        m = max_family_total(N)
        ksv = math.comb(N - 1, N // 2 - 1) if N >= 2 else 0
        ks[N] = m
        out.append(f"    N={N}: M_max={m}   Kleitman-Spencer C(N-1,floor(N/2)-1)={ksv}   "
                   f"match={m == ksv}")
    out.append("(b) partial functions allowed (values 0, 1, undefined)")
    for N in range(3, 6):
        mp = max_family_partial(N)
        out.append(f"    N={N}: M_max(partial)={mp}   M_max(total)={ks[N]}   equal={mp == ks[N]}")
    out.append("(c) minimum number N of functions that 2-cover M = 2^n inputs, versus pigeonhole n/log2(3)")
    for n in range(1, 8):
        M = 2 ** n
        Nmin = None
        for N in range(2, 60):
            val = ks.get(N, math.comb(N - 1, N // 2 - 1))
            if val >= M:
                Nmin = N
                break
        src = "exact" if Nmin in ks else "K-S formula"
        out.append(f"    n={n}: M={M}  N_min={Nmin} ({src})  log2 N_min={math.log2(Nmin):.3f}  "
                   f"pigeonhole lower bound n/log2(3)={n / math.log2(3):.3f}  holds={Nmin >= n / math.log2(3)}")
    out.append("    So some two-point binary data set on n-bit inputs needs a function family of size N_min,")
    out.append("    hence a program of length >= log2(N_min) - 1 (fewer than 2^g programs have length < g).")
    out.append("(d) greedy coverings of all labelled k-subsets (seed 20261012) versus bounds")
    rng = random.Random(20261012)
    for M in (8, 16):
        for k in (2, 3):
            g = greedy_cover(M, k, rng)
            nsets = math.comb(M, k) * 2 ** k
            ub = math.floor(2 ** k * math.log(nsets)) + 1
            out.append(f"    M={M} k={k}: greedy family size={g}   union-bound size 2^k ln(#sets)+1={ub}   "
                       f"lower bound 2^k={2 ** k}   greedy<=union bound: {g <= ub}")
    text = "\n".join(out) + "\n"
    print(text, end="")
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(text)


if __name__ == "__main__":
    main()
