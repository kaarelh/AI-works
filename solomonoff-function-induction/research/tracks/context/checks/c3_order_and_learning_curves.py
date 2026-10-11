"""c3: order independence of the semimeasure-convention loss, and learning curves of mixtures
(notes.md, sections 2.4 and 5.1: Proposition 2.9, Proposition 2.10, Remark 2.11, Proposition 5.1).

Part 1 (Prop 5.1): a random finite "function semimeasure" = mixture of hypotheses, each a random partial
  function on a 6-point domain (undefined with prob 0.2 at each point, so mass can leak), plus product
  (private-randomness) hypotheses.  The cumulative loss sum_k -log2 nu(y_k | x_k, D_{k-1}) is computed
  for all 720 orderings:
    semimeasure convention  nu(y|x,D) = nu(D+(x,y)) / nu(D)              -> identical for all orders
    normalized convention   nu(y|x,D) = nu(D+(x,y)) / sum_y' nu(D+(x,y')) -> depends on the order
Part 2 (Prop 2.10, Remark 2.11): the toy mixture "truth f with weight w_f, plus N hypotheses each wrong
  at exactly one point of B, each with weight w".  Expected loss at step k under a uniformly random order
  increases with k; leave-one-out loss (= last step) exceeds the random-split average total/N.
Part 3 (Prop 2.9): random-split identity E_{order,k}[loss_k] = total/N checked by Monte Carlo on Part 1's
  mixture.
Seeded.
"""
import itertools
import math
import numpy as np

SEED = 2
rng = np.random.default_rng(SEED)
out = []

# ---------- Part 1 ----------
n_pts, n_lab = 6, 2
n_det = 40
UNDEF = -1
det = rng.integers(0, n_lab, size=(n_det, n_pts))
det[rng.random((n_det, n_pts)) < 0.2] = UNDEF          # partial functions: semimeasure loses mass
w_det = rng.random(n_det); w_det *= 0.7 / w_det.sum()
n_prod = 5
prod = rng.dirichlet(np.ones(n_lab), size=(n_prod, n_pts))  # product hypotheses (private randomness)
w_prod = rng.random(n_prod); w_prod *= 0.3 / w_prod.sum()

def nu(D):
    """D: dict x -> y. Mass of the mixture on the cylinder 'agrees with D'."""
    tot = 0.0
    for h in range(n_det):
        if all(det[h, x] == y for x, y in D.items()):
            tot += w_det[h]
    for h in range(n_prod):
        p = w_prod[h]
        for x, y in D.items():
            p *= prod[h, x, y]
        tot += p
    return tot

f_true = rng.integers(0, n_lab, size=n_pts)
semi, norm = [], []
for perm in itertools.permutations(range(n_pts)):
    D = {}
    ls = ln = 0.0
    for x in perm:
        num = nu({**D, x: int(f_true[x])})
        den_s = nu(D)
        den_n = sum(nu({**D, x: y}) for y in range(n_lab))
        ls += -math.log2(num / den_s)
        ln += -math.log2(num / den_n)
        D[x] = int(f_true[x])
    semi.append(ls); norm.append(ln)
semi, norm = np.array(semi), np.array(norm)
total = -math.log2(nu({x: int(f_true[x]) for x in range(n_pts)}) / nu({}))
out.append("Part 1: cumulative loss over all 720 orderings of a 6-point domain")
out.append(f"  semimeasure convention: min {semi.min():.12f}  max {semi.max():.12f}  (-log2 nu(f)/nu(empty) = {total:.12f})")
out.append(f"  normalized convention : min {norm.min():.6f}  max {norm.max():.6f}  spread {np.ptp(norm):.6f}")
out.append(f"  nu(empty) = {nu({}):.6f}; deficit at x=0: nu(empty) - sum_y nu(0->y) = {nu({}) - sum(nu({0: y}) for y in range(n_lab)):.4f} (mass of hypotheses undefined at 0)")

# ---------- Part 3 ----------
acc = []
for _ in range(20000):
    perm = rng.permutation(n_pts)
    k = rng.integers(0, n_pts)
    D = {int(x): int(f_true[x]) for x in perm[:k]}
    x = int(perm[k])
    acc.append(-math.log2(nu({**D, x: int(f_true[x])}) / nu(D)))
out.append("Part 3: random split (uniform order, uniform split point)")
out.append(f"  Monte Carlo E[loss] = {np.mean(acc):.4f} +- {np.std(acc) / math.sqrt(len(acc)):.4f};  total/N = {total / n_pts:.4f}")

# ---------- Part 2 ----------
out.append("Part 2: toy mixture, truth weight w_f and N one-exception hypotheses of weight w each")
for N, w_f, w in [(16, 1 / 17, 1 / 17), (16, 0.5, 0.5 / 16), (256, 1 / 257, 1 / 257), (1024, 0.9, 0.1 / 1024)]:
    # after k-1 revealed points (any order), the exception hypotheses still consistent are those whose
    # exceptional point is unrevealed: N-(k-1) of them.  So the loss at step k is order independent here.
    losses = [math.log2((w_f + w * (N - k + 1)) / (w_f + w * (N - k))) for k in range(1, N + 1)]
    tot = sum(losses)
    out.append(f"  N={N:5d} w_f={w_f:.4g} w={w:.4g}: total={tot:.4f} = -log2(w_f/(w_f+Nw)) "
               f"[{-math.log2(w_f / (w_f + N * w)):.4f}]; first step={losses[0]:.5f}; "
               f"last step (LOO)={losses[-1]:.4f}; random-split mean total/N={tot / N:.5f}; "
               f"monotone increasing: {all(a <= b + 1e-15 for a, b in zip(losses, losses[1:]))}")
out.append("  (For SFI the analogous weights need N exception hypotheses each as heavy as the truth; by Kraft,")
out.append("   N*w + w_f <= 1 forces N <= 2^{K}-1 when w = w_f = 2^{-K}; the first row is that extreme case.)")

txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
