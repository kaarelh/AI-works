"""r3 (referee): how tight is Thm 5.4(c) (E[L_F] >= 3m/2 - 2 on uniform GF(2^m) triples)?

For fixed m, restrict the universal function machine to F = GF(2^m): U^omega|_F is a random partial
function F -> F (outputs outside F count as undefined; extending it to a total function can only
increase every probability).  Hence, with no additive constant,

    E[L_F(D_abr)] >= OPT_m := min over distributions w on functions G: F -> F of E_(a,b,r)[-log2 w(G contains D_abr)],

and conversely E[L_F] <= OPT_m + K(w*) + O(1) <= OPT_m + K(m) + O(1) (the optimum is computable from m).
So OPT_m is E[L_F] up to K(m) + O(1).  This script computes OPT_m for m = 2, 3:

 * shift symmetry (G -> G + c maps D_abr to D_{a,b,r+c}) and concavity give an optimal w that is
   shift-invariant, so E[-log w(D)] = m + E_(a,b)[-log W(a,b)],  W(a,b) := w0{G0 : G0(a)+G0(b) = ab},
   with w0 a distribution on functions with G0(0) = 0 and (a,b) a uniform ordered pair, a != b;
 * W depends on w0 only through the set ("mask") of unordered pairs {a,b} that G0 satisfies, so the
   problem is a maximum-likelihood mixture over the distinct masks; solved by EM, with a Frank-Wolfe
   duality gap giving a certified bracket for OPT_m.
Compared against the notes' bounds 3m/2 - 2 (Thm 5.4(c)) and log2(#triples / max_G N(G)), and against
xi's loss m (Thm 5.4(a)).  Deterministic (seed recorded as 0).  Output: r3_gf_optimal_mixture.out.
"""
import itertools, math
import numpy as np

SEED = 0
IRRED = {2: 0b111, 3: 0b1011}


def gmul(a, b, m):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> m:
            a ^= IRRED[m]
    return r


def masks_for(m):
    q = 1 << m
    pairs = [(a, b) for a in range(q) for b in range(a + 1, q)]
    prod = np.array([gmul(a, b, m) for a, b in pairs], dtype=np.int64)
    pa = np.array([a for a, _ in pairs]); pb = np.array([b for _, b in pairs])
    total = q ** (q - 1)
    uniq = set()
    chunk = 1 << 17
    weights = 1 << np.arange(len(pairs), dtype=np.uint64)
    for start in range(0, total, chunk):
        idx = np.arange(start, min(start + chunk, total), dtype=np.int64)
        G = np.zeros((len(idx), q), dtype=np.int64)
        v = idx.copy()
        for j in range(1, q):
            G[:, j] = v % q
            v //= q
        ok = (G[:, pa] ^ G[:, pb]) == prod[None, :]
        mk = (ok.astype(np.uint64) * weights[None, :]).sum(axis=1)
        uniq.update(np.unique(mk).tolist())
    return pairs, sorted(uniq)


def maximal(masks):
    masks = sorted(set(masks), key=lambda x: -bin(x).count("1"))
    keep = []
    for mk in masks:
        if not any((mk | k) == k for k in keep):
            keep.append(mk)
    return keep


def em(pairs, masks, iters=20000):
    P = len(pairs)
    A = np.array([[(mk >> p) & 1 for mk in masks] for p in range(P)], dtype=float)  # P x M
    w = np.ones(len(masks)) / len(masks)
    for it in range(iters):
        W = A @ w
        grad = A.T @ (1.0 / W) / P  # d/dw of mean log W (nats)
        w = w * grad
        w /= w.sum()
    W = A @ w
    val = np.mean(-np.log2(W))           # achieved E[-log2 W]
    gap_nats = (A.T @ (1.0 / W) / P).max() - 1.0  # Frank-Wolfe gap for max mean ln W
    return val, gap_nats / math.log(2), w, A


print("m | #fns (G(0)=0) | distinct masks | maximal | max N(G) | OPT_m bracket (bits) | 3m/2-2 | log2(#triples/maxN) | xi loss m")
for m in (2, 3):
    q = 1 << m
    pairs, masks = masks_for(m)
    keep = maximal(masks)
    maxN = 2 * max(bin(k).count("1") for k in keep)  # ordered pairs
    val, gap, w, A = em(pairs, keep)
    lo, hi = m + val - gap, m + val
    triples = q * (q - 1) * q
    print(f"{m} | {q ** (q - 1)} | {len(masks)} | {len(keep)} | {maxN} | [{lo:.5f}, {hi:.5f}] | {1.5 * m - 2:.3f} | "
          f"{math.log2(triples / maxN):.3f} | {m}")
    # sanity: the uniform-random-function value (each label uniform) is 2m
    assert lo <= 2 * m + 1e-9
    assert lo >= 1.5 * m - 2 - 1e-9 and lo >= math.log2(triples / maxN) - 1e-9
    support = np.sum(w > 1e-6)
    print(f"   optimal mixture uses {support} maximal masks; gap to xi's loss m is {lo - m:.4f} .. {hi - m:.4f} bits "
          f"(notes' guaranteed gap: >= m/2 - 2 = {m / 2 - 2:.3f})")
print("ALL CHECKS PASSED")
