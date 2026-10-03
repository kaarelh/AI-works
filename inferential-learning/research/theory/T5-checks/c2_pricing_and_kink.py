"""Check 2: (a) per-input pricing of mixtures with private randomness vs once-only pricing
with shared randomness; (b) the 'kink': product (private-randomness) models vs shared-
randomness models on a parity teacher with a random systematic-error set.

Instance: X = {0,1}^d, n = 2^d, uniform inputs, teacher y*(x) = <a,x> xor 1_E(x),
|E| = p n.  Model bits are explicit code lengths (d-u bits to pin a down to a list of 2^u
parities, log2 C(n,j) bits to name j error points), i.e. the finite/computable version."""
import numpy as np
from math import comb, log2
rng = np.random.default_rng(0)

d = 10; n = 2 ** d
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)], dtype=np.int64)
def parity(a): return (X @ a) % 2
def H(q): return 0.0 if q in (0, 1) else -(q*log2(q)+(1-q)*log2(1-q))

# ---------------- (a) pricing --------------------------------------------------
a = rng.integers(0, 2, d)
A_all = np.array([[(t >> i) & 1 for i in range(d)] for t in range(2 ** d)])
labels_all = (A_all @ X.T) % 2                      # 2^d x n table of all parity labelings
N = 200
idx = rng.integers(0, n, N); y = parity(a)[idx]
# function mixture (private randomness): xi(y|x) = fraction of parities giving y at x
frac1 = labels_all.mean(axis=0)                     # P(label=1 | x) under uniform prior
loss_fun = -np.sum(np.log2(np.where(y == 1, frac1[idx], 1 - frac1[idx])))
# sequential Bayes mixture (shared randomness): -log2( #consistent / 2^d )
consistent = np.all(labels_all[:, idx] == y, axis=1).sum()
loss_seq = d - log2(consistent)
minimax_fun = sum(log2(len(set(labels_all[:, i]))) for i in idx)
print(f"(a) N={N}, class = all 2^{d} parities, uniform weights 2^-{d}")
print(f"    function mixture (private randomness): {loss_fun:.1f} bits  "
      f"(minimax sum_i log|F(x_i)| = {minimax_fun:.1f})")
print(f"    Bayes mixture (shared randomness):     {loss_seq:.2f} bits  (<= d = {d})")

# ---------------- (b) kink ------------------------------------------------------
pE = 1 / 64; m = int(pE * n)
E = rng.choice(n, m, replace=False); e = np.zeros(n, int); e[E] = 1
ystar = (parity(a) + e) % 2
# basis order: list L_u = parities agreeing with a on the first d-u coordinates
prod_pts, seq_pts = [], []
for u in range(d + 1):
    free = list(range(d - u, d))
    L = []
    for t in range(2 ** u):
        b = a.copy()
        for k, i in enumerate(free): b[i] = (t >> k) & 1
        L.append(parity(b))
    L = np.array(L)                                  # 2^u x n
    q = (L == ystar).mean(axis=0)                    # fraction of list agreeing with y* at x
    hprob = (1 - pE) * q + pE * (1 - q)              # product mixture with flip noise
    R_prod = -np.mean(np.log2(hprob))
    agree = (L == ystar).sum(axis=1)                 # per-list-member agreements
    ll = agree * log2(1 - pE) + (n - agree) * log2(pE)      # log2 likelihood per member
    mx = ll.max(); codelen = -(mx + log2(np.exp2(ll - mx).sum()) - u)
    bits = d - u
    prod_pts.append((bits, R_prod, f"list 2^{u}"))
    seq_pts.append((bits, codelen / n, f"list 2^{u}"))
# error-memorising refinements of the good model (know j of the m error points)
err_pts = []
for j in range(0, m + 1, 2):
    rest = (m - j) / (n - j)
    err_pts.append((d + log2(comb(n, j)), (n - j) * H(rest) / n, f"good+{j} errs"))
coin = (0, 1.0, "coin")

print(f"\n(b) d={d}, n={n}, |E|={m} (p={pE}), H(p)={H(pE):.4f}")
print("    bits | product-model risk | shared-randomness code length / n")
for (b1, r1, _), (_, r2, _) in zip(prod_pts, seq_pts):
    print(f"    {b1:4d} | {r1:18.4f} | {r2:.4f}   (total bits seq = {b1 + n*r2:.1f})")

def hull(points):
    pts = sorted(set((round(b, 6), round(r, 9), nm) for b, r, nm in points))
    H_ = []
    for P in pts:
        while len(H_) >= 2:
            (x1, y1, _), (x2, y2, _) = H_[-2], H_[-1]
            if (x2 - x1) * (P[1] - y1) - (y2 - y1) * (P[0] - x1) <= 0: H_.pop()
            else: break
        H_.append(P)
    # keep only the decreasing part (lower-left boundary)
    out = [H_[0]]
    for P in H_[1:]:
        if P[1] < out[-1][1]: out.append(P)
    return out

for fam, pts in [("product (private randomness)", prod_pts), ("shared randomness", seq_pts)]:
    allp = pts + err_pts + [coin]
    hv = hull(allp)
    print(f"\n    lower convex hull, {fam}:")
    for b, r, nm in hv: print(f"      bits={b:8.1f}  risk={r:.5f}  {nm}")
    for lam in [0.5, 1.0, 1.5, 4.0, 50.0]:
        c = lam / n
        best = min(allp, key=lambda P: c * P[0] + P[1])
        print(f"      lambda={lam:5}: selected {best[2]:14s} (bits={best[0]:.1f}, risk={best[1]:.4f})")
