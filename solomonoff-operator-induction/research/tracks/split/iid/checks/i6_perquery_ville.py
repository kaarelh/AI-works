"""i6: the Ville deficiency for the per-query likelihood with repeated inputs (notes-final Lemma 2.2), and the
MAP length bound of Thm 4.1(i), pathwise.  Seeded: numpy default_rng(6).
[Labels updated to the notes-final numbering and notation (l0, E0) on 2026-10-13; computations unchanged.]

Inputs uniform on X = {0,...,7} (so inputs repeat), labels fresh per query from the truth
nu(1|x) = (x+1)/10.  Class: the truth (l = 6), Bernoulli(j/16) samplers that ignore x (j = 1..15,
l = 6), "x-threshold" samplers nu_t(1|x) = 0.8 if x >= t else 0.2 (t = 0..7, l = 7), and 8 deterministic
programs y = [x >= t] (l = 5).  Kraft sum < 1.  xi(seq) = sum_pi 2^{-l(pi)} prod_i nu_pi(y_i|x_i).
4000 runs of n = 3000: empirical P[delta* >= j] against 2^{-j}, with delta* = sup_n log2(xi/nu).
For lambda in {1.25, 2, 4} it checks on every path and every n that every lambda-MAP has length
<= (lambda l0 + delta*)/(lambda - 1) (l0 = 6).
"""
import numpy as np

rng = np.random.default_rng(6)
X = np.arange(8)
truth = (X + 1) / 10
progs, lens = [truth], [6]
for j in range(1, 16):
    progs.append(np.full(8, j / 16)); lens.append(6)
for t in range(8):
    progs.append(np.where(X >= t, 0.8, 0.2)); lens.append(7)
for t in range(8):
    progs.append((X >= t).astype(float)); lens.append(5)
P1 = np.stack(progs); lens = np.array(lens, float)
assert (2.0 ** -lens).sum() <= 1, (2.0 ** -lens).sum()
with np.errstate(divide="ignore"):
    L1, L0 = np.log2(P1), np.log2(1 - P1)
runs, n = 4000, 3000
dstar = np.empty(runs)
viol = 0
for r in range(runs):
    xs = rng.integers(0, 8, size=n)
    ys = rng.random(n) < truth[xs]
    inc = np.where(ys[None, :], L1[:, xs], L0[:, xs])        # (programs, n) per-step log-likelihoods
    cum = np.cumsum(inc, axis=1)                              # log2 prod nu_pi
    lognu = cum[0]
    with np.errstate(invalid="ignore"):
        W = -lens[:, None] + cum
        mx = W.max(axis=0)
        logxi = mx + np.log2(np.exp2(W - mx[None, :]).sum(axis=0))
    ds = max(0.0, float(np.max(logxi - lognu)))
    dstar[r] = ds
    for lam in (1.25, 2.0, 4.0):
        J = lam * lens[:, None] - cum
        m = J.min(axis=0)
        maps = J <= m[None, :] + 1e-9
        maxlen = np.where(maps, lens[:, None], 0).max(axis=0)
        if np.any(maxlen > (lam * 6 + ds) / (lam - 1) + 1e-9):
            viol += 1
for j in [1, 2, 3, 4, 6]:
    print(f"  j={j}: empirical P[delta* >= j] = {np.mean(dstar >= j):.4f}   <= 2^-j = {2.0 ** -j:.4f}")
print(f"  paths x lambda with a MAP longer than (lambda l0 + delta*)/(lambda-1): {viol} (must be 0)")
