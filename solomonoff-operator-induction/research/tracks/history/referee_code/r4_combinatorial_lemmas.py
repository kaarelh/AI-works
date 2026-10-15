"""r4 (referee): independent checks of combinatorial steps in the history notes.

 (a) Prop 4.5(iii) lemma (SFI^set): two DIFFERENT orders of the same set that end with the same element
     can never both be consistent with one deterministic set-hypothesis g (labels y_1 = eps,
     y_i = x_{i-1}).  This is the backward-reconstruction step; it implies "at most n orders".
     c6 checked n <= 5 by maximum clique; here n = 6, 7 by checking every pair of orders with the same
     last element for a conflicting requirement on g, plus an explicit compatible family of size n.
 (b) Lemma B (block codes -> binary semimeasure) on random finite instances: nu_bin(z0) + nu_bin(z1)
     <= nu_bin(z) for every binary z, and nu_bin(code(b)) = nu(b), exact rationals.  nu is built as in
     Thm 4.6(b): nu(x_1 y_1 ... ) = rho'(x || y) * rho(y || x) from two random chronological semimeasures.
 (c) Prop 4.5(i): log2 C(n, floor(n/2)) >= n - log2(n+1) for 2 <= n <= 400.
 (d) Thm 5.4(c) arithmetic: log2(2^{2m}(2^m-1)) - log2(2^m + 2^{3m/2}) >= 3m/2 - 2 for m = 1..60.
Seed 4242.  Output saved to r4_combinatorial_lemmas.out.
"""
import itertools, math, random
from fractions import Fraction as Fr

SEED = 4242
rng = random.Random(SEED)
out = []

# ---------------------------------------------------------------- (a)
def requirements(order):
    req = {(frozenset(), order[0]): "eps"}
    for i in range(1, len(order)):
        req[(frozenset(order[:i]), order[i])] = order[i - 1]
    return req


def compatible(r1, r2):
    return all(r2.get(k, v) == v for k, v in r1.items())


for n in (6, 7):
    orders = list(itertools.permutations(range(n)))
    by_last = {}
    for o in orders:
        by_last.setdefault(o[-1], []).append(o)
    bad = 0
    pairs = 0
    for last, group in by_last.items():
        reqs = [requirements(o) for o in group]
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                pairs += 1
                if compatible(reqs[i], reqs[j]):
                    bad += 1
    # explicit compatible family: orders (k, k+1, ..., n-1, 0, ..., k-1)? check greedily for one family of size n
    fam = [tuple(range(k + 1, n)) + tuple(range(0, k + 1)) for k in range(n)]  # rotations, last element k
    fam = [o for o in fam if len(set(o)) == n]
    ok_family = all(compatible(requirements(a), requirements(b)) for a, b in itertools.combinations(fam, 2))
    out.append(f"(a) n={n}: {pairs} pairs of distinct orders with equal last element; compatible pairs: {bad} (claim: 0); "
               f"rotation family of size {len(fam)} pairwise compatible: {ok_family}")
    assert bad == 0

# ---------------------------------------------------------------- (b)
XS = ["", "0", "1"]   # input alphabet (strings)
YS = ["", "1", "01"]  # label alphabet (strings)
DEPTH = 2             # number of (x, y) rounds


def code(s):
    return "1" * len(s) + "0" + s


def rand_chrono(cond_alph, out_alph, depth):
    """random chronological semimeasure: value on (out_1..out_k || cond_1..cond_k), exact rationals"""
    rho = {((), ()): Fr(1)}
    frontier = [((), ())]
    for k in range(depth):
        new = []
        for outs, conds in frontier:
            base = rho[(outs, conds)]
            for c in cond_alph:
                w = [rng.randint(0, 4) for _ in out_alph]
                tot = sum(w) + rng.randint(0, 3)  # leave a deficit
                if tot == 0:
                    tot = 1
                for o, wi in zip(out_alph, w):
                    key = (outs + (o,), conds + (c,))
                    rho[key] = base * Fr(wi, tot)
                    new.append(key)
        frontier = new
    return rho


def rand_chrono_inputs(depth):
    """rho'(x_1..x_k || y_1..y_{k-1}): inputs given previous labels, exact rationals, with deficits"""
    rho = {((), ()): Fr(1)}
    level = [((), ())]
    for k in range(depth):
        nxt = []
        for xs, ys in level:
            ylist = [()] if k == 0 else [(y,) for y in YS]
            for yext in ylist:
                ys2 = ys + yext
                w = [rng.randint(0, 4) for _ in XS]
                tot = sum(w) + rng.randint(0, 3) or 1
                for x, wi in zip(XS, w):
                    key = (xs + (x,), ys2)
                    rho[key] = rho[(xs, ys)] * Fr(wi, tot)
                    nxt.append(key)
        level = nxt
    return rho


worst_semi = None
mismatch = 0
for inst in range(6):
    rho = rand_chrono(XS, YS, DEPTH)        # labels given inputs
    rhop = rand_chrono_inputs(DEPTH)        # inputs given previous labels
    # nu on block sequences b = (x1, y1, x2, y2, ...) possibly ending after an x-block
    nu = {}
    def blocks_rec(b):
        k = len(b)
        xs = tuple(b[0::2]); ys = tuple(b[1::2])
        if k % 2 == 1:  # ends with x-block: rho'(x_{1:j} || y_{1:j-1}) * rho(y_{1:j-1} || x_{1:j-1})
            val = rhop[(xs, ys)] * rho[(ys, xs[:-1])]
        else:
            val = rhop[(xs, ys[:-1])] * rho[(ys, xs)] if k > 0 else Fr(1)
        nu[b] = val
        if k < 2 * DEPTH:
            for s in (XS if k % 2 == 0 else YS):
                blocks_rec(b + (s,))
    blocks_rec(())
    # semimeasure on block sequences
    for b, v in nu.items():
        kids = [nu[c] for c in nu if len(c) == len(b) + 1 and c[:len(b)] == b]
        if kids and sum(kids) > v:
            mismatch += 1
    codes = {b: "".join(code(s) for s in b) for b in nu}
    def nu_bin(z):
        tot = Fr(0)
        for b, cb in codes.items():
            if cb.startswith(z) and (len(b) == 0 or not codes[b[:-1]].startswith(z)):
                tot += nu[b]
        return tot
    maxlen = max(len(c) for c in codes.values())
    for L in range(0, maxlen):
        for bits in itertools.product("01", repeat=L):
            z = "".join(bits)
            lhs = nu_bin(z + "0") + nu_bin(z + "1")
            d = lhs - nu_bin(z)
            worst_semi = d if worst_semi is None else max(worst_semi, d)
        if L > 13:
            break
    for b, cb in codes.items():
        if nu_bin(cb) != nu[b]:
            mismatch += 1
out.append(f"(b) Lemma B, 6 random instances (nu = rho' * rho), binary z up to length 14: "
           f"max nu_bin(z0)+nu_bin(z1)-nu_bin(z) = {worst_semi} (claim: <= 0); "
           f"block-semimeasure or nu_bin(code(b)) != nu(b) failures: {mismatch} (claim: 0)")
assert worst_semi <= 0 and mismatch == 0

# ---------------------------------------------------------------- (c)
worst_c = min(math.log2(math.comb(n, n // 2)) - (n - math.log2(n + 1)) for n in range(2, 401))
out.append(f"(c) min over 2<=n<=400 of log2 C(n,floor(n/2)) - (n - log2(n+1)) = {worst_c:.4f} (claim: >= 0)")
assert worst_c >= 0

# ---------------------------------------------------------------- (d)
worst_d = min(math.log2(2 ** (2 * m) * (2 ** m - 1)) - math.log2(2 ** m + 2 ** (1.5 * m)) - (1.5 * m - 2)
              for m in range(1, 61))
out.append(f"(d) min over 1<=m<=60 of [log2(2^2m (2^m-1)) - log2(2^m + 2^(3m/2))] - (3m/2 - 2) = {worst_d:.4f} (claim: >= 0)")
assert worst_d >= 0

for l in out:
    print(l)
print("ALL CHECKS PASSED")
