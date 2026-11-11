"""Sanity check for the referee's symmetry extension of A.r1 Proposition 6.6(a).

Claim checked (referee's Observation S-1): let the prior be invariant under
v -> -v (readout sign flip), e.g. mu_{N,gamma} at any finite scale or mu_sigma
at any sigma>0.  Take the non-centred cube law D^{eta0}_d and a sample on which
EVERY atom carries both labels +1 and -1.  For rho>1 the TUBE set is
U = {w : max_x |z_w(x)| < rho-1}, which is invariant under v -> -v.  Hence
  * the posterior mean of z_w (and of clip z_w) is exactly 0;
  * a Gibbs draw satisfies E_x (z-eta0)^2 <= eps with posterior probability <= 1/2
    whenever eps < eta0^2 (the event and its mirror are disjoint);
  * the posterior-averaged excess E_Pi E_x (z-eta0)^2 is >= eta0^2 (Jensen).
No sigma -> 0 limit is used.  We check this by rejection sampling at a tiny size,
and contrast it with a sample on which one atom carries a single label.
"""
import numpy as np

rng = np.random.default_rng(20261111)

d, H, N = 2, 2, 4          # depth L = H+1 = 3, width 4
M = 2 ** d
X = np.array([[s1, s2] for s1 in (-1, 1) for s2 in (-1, 1)], dtype=float)
Xbar = np.hstack([np.ones((M, 1)), X])       # (M, d+1)
eta0, rho, eps = 0.5, 1.3, 0.2              # eps < eta0^2 = 0.25


def draw_prior(n_draws, kind, gamma=1.0, sigma=0.3):
    """Return outputs z (n_draws, M) of prior draws."""
    if kind == "finite":
        s1 = np.sqrt(N ** (1 - gamma) / d)
        s2 = np.sqrt(N ** (-gamma))
        s3 = np.sqrt(N ** (-gamma - 1))
    else:  # strong prior at a fixed sigma (no limit)
        s1 = sigma * np.sqrt(N / d)
        s2 = sigma
        s3 = sigma / np.sqrt(N)
    W1 = rng.normal(0, s1, size=(n_draws, N, d + 1))
    W2 = rng.normal(0, s2, size=(n_draws, N, N))
    v = rng.normal(0, s3, size=(n_draws, N))
    h1 = np.tanh(np.einsum("bij,mj->bmi", W1, Xbar))          # (b, M, N)
    h2 = np.tanh(np.einsum("bij,bmj->bmi", W2, h1))           # (b, M, N)
    return np.einsum("bi,bmi->bm", v, h2)                      # (b, M)


def sample_labels(n):
    xs = rng.integers(0, M, size=n)
    ys = np.where(rng.random(n) < (1 + eta0) / 2, 1.0, -1.0)
    return xs, ys


def tube_mask(z, xs, ys):
    # |z(x_i) - y_i| < rho for all i ; evaluate per atom using the label set present
    ok = np.ones(z.shape[0], dtype=bool)
    for x in range(M):
        labs = set(ys[xs == x].tolist())
        for y in labs:
            ok &= np.abs(z[:, x] - y) < rho
    return ok


def report(z_acc, tag):
    mean = z_acc.mean(axis=0)
    se = z_acc.std(axis=0) / np.sqrt(len(z_acc))
    exc = ((z_acc - eta0) ** 2).mean(axis=1)                  # E_x (z-eta0)^2 per draw
    mir = ((z_acc + eta0) ** 2).mean(axis=1)
    clip = np.clip(z_acc, -1, 1)
    print(f"[{tag}] accepted draws: {len(z_acc)}")
    print(f"   posterior mean of z at the {M} atoms: " + ", ".join(f"{m:+.4f}" for m in mean)
          + "   (std. err. " + ", ".join(f"{s:.4f}" for s in se) + ")")
    print(f"   posterior mean of clip z: " + ", ".join(f"{m:+.4f}" for m in clip.mean(axis=0)))
    print(f"   Pi[E_x(z-eta0)^2 <= eps] = {np.mean(exc <= eps):.4f};  mirror Pi[E_x(z+eta0)^2 <= eps] = {np.mean(mir <= eps):.4f}")
    print(f"   posterior-averaged excess E_Pi E_x(z-eta0)^2 = {exc.mean():.4f}  (eta0^2 = {eta0**2:.4f})")
    print(f"   excess of the posterior mean E_x(mean-eta0)^2 = {((mean - eta0) ** 2).mean():.4f}")


for kind in ("finite", "strong"):
    # (1) a sample where every atom carries both labels
    while True:
        xs, ys = sample_labels(200)
        if all(len(set(ys[xs == x].tolist())) == 2 for x in range(M)):
            break
    acc = []
    total = 0
    while sum(len(a) for a in acc) < 40000:
        z = draw_prior(200000, kind)
        total += len(z)
        acc.append(z[tube_mask(z, xs, ys)])
    z_acc = np.vstack(acc)
    label = "mu_{N,gamma}, gamma=1, N=4" if kind == "finite" else "mu_sigma, sigma=0.3 (no limit), N=4"
    print(f"=== prior {label}; rho={rho}; eta0={eta0}; every atom carries both labels ===")
    print(f"   acceptance rate {sum(len(a) for a in acc)/total:.4f}")
    report(z_acc, "all atoms conflicting")

    # (2) contrast: one atom carries only the label +1 (symmetry broken)
    xs2, ys2 = xs.copy(), ys.copy()
    ys2[xs2 == 0] = 1.0
    acc = []
    total = 0
    while sum(len(a) for a in acc) < 40000:
        z = draw_prior(200000, kind)
        total += len(z)
        acc.append(z[tube_mask(z, xs2, ys2)])
    z_acc = np.vstack(acc)
    report(z_acc, "atom 0 carries only +1 (contrast)")
    print()

# (3) probability that every atom carries both labels, exact by inclusion-exclusion
#     over the set of atoms whose labels agree is messy; use Monte Carlo plus the union bound
print("=== Pr[every atom of C_d carries both labels] for D^{eta0}_d (Monte Carlo, 20000 reps) vs union bound ===")
for dd in (1, 2, 3, 4):
    MM = 2 ** dd
    for n in (16 * MM, 32 * MM, 64 * MM):
        reps = 20000
        xs = rng.integers(0, MM, size=(reps, n))
        ys = rng.random((reps, n)) < (1 + eta0) / 2
        allboth = np.ones(reps, dtype=bool)
        for x in range(MM):
            at = xs == x
            has_pos = (at & ys).any(axis=1)
            has_neg = (at & ~ys).any(axis=1)
            allboth &= has_pos & has_neg
        ub = min(1.0, 2 * MM * np.exp(-n * (1 - eta0) / (2 * MM)))
        print(f"   d={dd} n={n:5d}: Pr[not all conflicting] MC={1-allboth.mean():.4f}   union bound 2M e^(-n(1-eta0)/(2M)) = {ub:.4f}")
