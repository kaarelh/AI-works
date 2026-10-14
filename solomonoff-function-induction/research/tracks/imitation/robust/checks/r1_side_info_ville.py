"""r1: the Ville deficiency with side information (notes Lemma 2.1, Theorem 2.2) and the privacy
dichotomy (notes Proposition 2.3).  Seeded: numpy default_rng(1).

World A (private coins).  x uniform on {0,...,7}; z uniform on {0,...,9} (environment, seen by the aliens);
the human answers y ~ Bern((x+1)/10) with fresh coins, independent of z.
World B (coupled coins).  Same x, z.  For each x a fixed set Z_x of exactly x+1 of the ten z-values is drawn
once; y = 1[z in Z_x].  So P(y=1 | x) = (x+1)/10 exactly (the human's kernel is calibrated), but y is a
deterministic function of (x, z): the human's "coin" is driven by the environment.

Class (Kraft sum <= 1, checked):
  human         nu_H(1|x) = (x+1)/10                                             l = 4
  env aliens    nu(1|x,z) = clip((x+1)/10 + delta*(2*[z < 5] - 1)), 3 deltas       l = 7 each
                nu(1|x,z) = clip((x+1)/10 + delta*(2*[z odd] - 1)), 3 deltas      l = 7 each
  table alien   a fixed random rate table r(x,z) in {1/16,...,15/16} (80 cells)  l = 4 + 80*4 = 324
  learner       history-aware: Krichevsky-Trofimov estimate per (x,z) cell       l = 6   (sees the past)
  oracle alien  the world-B truth y = 1[z in Z_x] (deterministic), clipped to 1-2^-20  l = 4 + 80 = 84
In world A every program predicts y_i from information independent of the human's coin given x_i, so the
mixture-to-human ratio is a supermartingale and P[delta* >= j] <= 2^-j (Lemma 2.1).  In world B privacy fails:
I(Y;Z|X) = mean_x H((x+1)/10) > 0 and the oracle alien gains about n*I bits (Proposition 2.3(ii)).
"""
import numpy as np

rng = np.random.default_rng(1)
NX, NZ = 8, 10
xs_all = np.arange(NX)
human = (xs_all + 1) / 10.0                      # nu_H(1|x)

# --- world B coupling: Z_x has exactly x+1 elements
ZB = np.zeros((NX, NZ), bool)
for x in range(NX):
    ZB[x, rng.choice(NZ, size=x + 1, replace=False)] = True
assert np.allclose(ZB.mean(axis=1), human)

# --- the class: static kernels on (x,z) as tables of P(y=1|x,z), plus the learner
static, lens, names = [], [], []
static.append(np.repeat(human[:, None], NZ, axis=1)); lens.append(4); names.append("human")
for kind in ("z<5", "z odd"):
    sgn = np.where(np.arange(NZ) < 5, 1, -1) if kind == "z<5" else np.where(np.arange(NZ) % 2 == 1, 1, -1)
    for dlt in (0.05, 0.1, 0.2):
        static.append(np.clip(human[:, None] + dlt * sgn[None, :], 0.01, 0.99)); lens.append(7)
        names.append(f"env[{kind},{dlt}]")
static.append(rng.integers(1, 16, size=(NX, NZ)) / 16.0); lens.append(4 + 80 * 4); names.append("table")
eps_or = 2.0 ** -20
static.append(np.where(ZB, 1 - eps_or, eps_or)); lens.append(4 + 80); names.append("oracle(B)")
static = np.stack(static)                         # (P, NX, NZ)
LEARNER_LEN = 6
lens_all = np.array(lens + [LEARNER_LEN], float)
names_all = names + ["learner(KT)"]
kraft = (2.0 ** -lens_all).sum()
print(f"Kraft sum of the class = {kraft:.6f} (must be <= 1)")
assert kraft <= 1


def run(world, n, rng):
    x = rng.integers(0, NX, n)
    z = rng.integers(0, NZ, n)
    if world == "A":
        y = (rng.random(n) < human[x]).astype(int)
    else:
        y = ZB[x, z].astype(int)
    p1 = static[:, x, z]                                     # (P, n)
    ll = np.where(y[None, :] == 1, np.log2(p1), np.log2(1 - p1))
    # KT learner per (x,z) cell, sequential (vectorised: counts in the same cell before step i)
    cell = x * NZ + z
    order = np.argsort(cell, kind="stable")
    cs, ys = cell[order], y[order]
    start = np.r_[True, cs[1:] != cs[:-1]]
    grp = np.cumsum(start) - 1
    first = np.flatnonzero(start)
    pos = np.arange(n) - first[grp]                         # number of earlier samples in the cell
    c1 = np.cumsum(ys) - ys                                  # earlier ones overall ...
    c1 = c1 - (np.cumsum(ys) - ys)[first][grp]               # ... minus those before the cell's block
    num = np.where(ys == 1, c1 + 0.5, pos - c1 + 0.5)
    llk = np.empty(n)
    llk[order] = np.log2(num / (pos + 1.0))
    ll = np.vstack([ll, llk[None, :]])
    cum = np.cumsum(ll, axis=1)                              # log2 likelihoods, (P+1, n)
    lnu = cum[0]                                             # the human (row 0)
    W = cum - lnu[None, :] - lens_all[:, None]               # log2 of 2^-l * ratio
    mx = W.max(axis=0)
    logxi_ratio = mx + np.log2(np.exp2(W - mx[None, :]).sum(axis=0))
    dstar = max(0.0, logxi_ratio.max())                       # sup_n delta_n (delta_0 = log Kraft <= 0)
    gains = cum - lnu[None, :]                               # L_n(nu_H) - L_n(pi)
    return dstar, gains, y


print("\n(A) World A (private coins): tail of the Ville deficiency, 3000 runs of n = 2000")
n, runs = 2000, 3000
dst = np.empty(runs)
maxgain_minus_len = np.full((runs, len(names_all)), -np.inf)
viol = 0
for r in range(runs):
    d, g, _ = run("A", n, rng)
    dst[r] = d
    gm = g.max(axis=1) - lens_all
    maxgain_minus_len[r] = gm
    if (gm > d + 1e-9).any():
        viol += 1
for j in (1, 2, 3, 4, 6, 8):
    print(f"  j={j}: P_emp[delta* >= j] = {np.mean(dst >= j):.4f}   2^-j = {2.0**-j:.4f}")
print(f"  runs in which some program's sup_n gain exceeds its length + delta*: {viol} (must be 0)")
print("  per program: mean over runs of sup_n [gain - length]  (gain = L_n(human) - L_n(program)):")
for k, nm in enumerate(names_all):
    print(f"    {nm:16s} l={lens_all[k]:6.0f}  mean sup(gain - l) = {maxgain_minus_len[:, k].mean():9.2f}"
          f"   max over runs = {maxgain_minus_len[:, k].max():9.2f}")

print("\n(B) World B (coins coupled to z): I(Y;Z|X) and the oracle alien's gain")
def H2(p):
    p = np.asarray(p, float)
    with np.errstate(divide="ignore", invalid="ignore"):
        h = -p * np.log2(p) - (1 - p) * np.log2(1 - p)
    return np.nan_to_num(h)
I = H2(human).mean()
print(f"  I(Y;Z|X) = mean_x H((x+1)/10) = {I:.4f} bits per sample")
k_or = names_all.index("oracle(B)")
k_le = names_all.index("learner(KT)")
for r in range(3):
    d, g, _ = run("B", n, rng)
    for nn in (50, 100, 200, 500, 1000, 2000):
        print(f"  run {r}, n={nn:5d}: gain(oracle) = {g[k_or, nn-1]:8.1f} (n*I = {nn*I:7.1f}),"
              f" gain(learner) = {g[k_le, nn-1]:8.1f}, log2(xi/nu_H) = {d:.0f} (sup over n<=2000)")
    # fixed-lambda selection between human and oracle
    for lam in (2.0, 4.0):
        J_h = lam * lens_all[0]
        diff = lam * (lens_all[k_or] - lens_all[0]) - g[k_or]       # J(oracle) - J(human)
        sw = np.argmax(diff < 0) + 1 if (diff < 0).any() else None
        print(f"    lambda={lam}: oracle first beats the human at n = {sw}"
              f" (predicted ~ lambda*Delta/I = {lam*(lens_all[k_or]-lens_all[0])/I:.0f})")

print("\n(C) World A, the history-aware learner (l = 6 > human's 4): its gain - length stays bounded;")
print("    its regret against the human grows like (cells/2) log(n/cells), so the human wins at fixed lambda.")
d, g, _ = run("A", 20000, rng)
for nn in (100, 1000, 5000, 20000):
    print(f"  n={nn:6d}: gain(learner) = {g[k_le, nn-1]:8.2f}  (regret = {-g[k_le, nn-1]:.1f};"
          f" 40*log2(n/80) = {40*np.log2(nn/80):.0f})")
