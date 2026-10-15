"""r5 (referee): the combinatorial facts behind the referee's tape-length bound for the
deterministic program mixture W (referee.md, issue M2), which sharpens Prop 4.4 of the notes.

Claim (proved in referee.md):  for every function machine T with law nu, every data set D and every L,
    W(D) >= 2^{-K(T) - K(L) - O(1)} * nu^{(L)}(D),   nu^{(L)}(D) := lambda{ omega : omega_{1:L} certifies D },
because the deterministic programs "(T, L, w)", w in {0,1}^L, compute phi_w(x) := the label T certifies
for x on the finite tape w, and Pr_w[phi_w > D] = nu^{(L)}(D).  Since nu^{(L)} is nondecreasing in L,
L may be replaced by any L' >= L, so K(L) can be replaced by min_{L' >= L} K(L').
Special case (lookup table): F(x) = omega_{j(x)} gives Pr_w[phi_w > D] = 2^{-|D|} once L > max j(x).

Checked here, exactly:
  (a) random shared-randomness function machines on 5 inputs (per-input prefix-free certificate trees
      on ONE shared tape, depth <= 7): nu^{(L)}(D) is nondecreasing in L, equals nu(D) at L = 7, and
      equals the fraction of w in {0,1}^L with phi_w > D, for every D and L;
  (b) lookup table on {0,1}^{<=2} (7 inputs), every L >= 7: Pr_w[phi_w > D] = 2^{-|D|} for all D;
  (c) an illustration (NOT a computation of K): computable prefix-code lengths (Elias omega) of the
      three descriptions -- (n,k) for hashing, n for the lookup table, m = ceil(log2(n+1)) for the
      tower length L = 2^(2^m) >= 2^(n+1).  These are upper bounds on K up to additive constants.

Seed 20261011.  Output: r5_tape_length_bound_output.txt
"""
import itertools
import math
import random
from fractions import Fraction as Fr

DEPTH = 7
NX = 5
Y = (0, 1)


def random_tree(rng, depth):
    """prefix-free dict {w: label or None}: a random certificate tree for one input."""
    leaves = {}

    def grow(w):
        if len(w) == depth or (len(w) > 0 and rng.random() < 0.35):
            r = rng.random()
            leaves[w] = None if r < 0.15 else (0 if r < 0.55 else 1)
            return
        grow(w + "0")
        grow(w + "1")
    grow("")
    return leaves


def certified(tree, w):
    """label certified for this input by finite tape w (None if not yet / never)."""
    for i in range(len(w) + 1):
        if w[:i] in tree:
            return tree[w[:i]]
    return None


def check_a(rng, trials=30):
    bad = 0
    for _ in range(trials):
        trees = [random_tree(rng, DEPTH) for _ in range(NX)]
        tapes = {L: ["".join(b) for b in itertools.product("01", repeat=L)] for L in range(DEPTH + 1)}
        for vals in itertools.product((None,) + Y, repeat=NX):
            D = [(x, y) for x, y in enumerate(vals) if y is not None]
            seq = []
            for L in range(DEPTH + 1):
                cnt = sum(all(certified(trees[x], w) == y for x, y in D) for w in tapes[L])
                seq.append(Fr(cnt, 2 ** L))
            nu = seq[-1]  # depth DEPTH tape decides everything
            if any(seq[i + 1] < seq[i] for i in range(DEPTH)) or seq[DEPTH] != nu:
                bad += 1
    return bad


def check_b():
    inputs = ["", "0", "1", "00", "01", "10", "11"]
    j = {x: i for i, x in enumerate(inputs)}
    bad = 0
    for L in (7, 8, 9):
        tapes = list(itertools.product((0, 1), repeat=L))
        for vals in itertools.product((None, 0, 1), repeat=len(inputs)):
            D = [(x, y) for x, y in zip(inputs, vals) if y is not None]
            cnt = sum(all(w[j[x]] == y for x, y in D) for w in tapes)
            bad += Fr(cnt, 2 ** L) != Fr(1, 2 ** len(D))
    return bad


def omega_len(N):
    """length of the Elias omega code of N >= 1."""
    L = 1
    while N > 1:
        L += N.bit_length()
        N = N.bit_length() - 1
    return L


def main():
    rng = random.Random(20261011)
    lines = []
    lines.append(f"(a) 30 random shared-tape function machines, {NX} inputs, all 3^{NX} data sets, L=0..{DEPTH}: "
                 f"violations of [nu^(L) nondecreasing, nu^(DEPTH)=nu] = {check_a(rng)}")
    lines.append(f"(b) lookup table on {{0,1}}^<=2, L=7,8,9, all 3^7 data sets: violations of Pr_w = 2^-|D| : {check_b()}")
    lines.append("(c) prefix-code lengths (illustration of description costs, up to additive constants):")
    lines.append("    n      k     hash: omega(n)+omega(k)   lookup: omega(n)   tower: omega(ceil(log2(n+1)))")
    for n, k in [(10, 10), (100, 50), (1000, 1000), (10 ** 6, 10 ** 4), (10 ** 9, 10 ** 9)]:
        m = math.ceil(math.log2(n + 1))
        lines.append(f"    {n:<6} {k:<6} {omega_len(n) + omega_len(k):>10} {omega_len(n):>18} {omega_len(m):>22}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
