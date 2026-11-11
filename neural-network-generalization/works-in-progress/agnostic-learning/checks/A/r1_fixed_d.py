"""research-notes/A-tight-conditioning-fails.md (script added in revision 1), Proposition 5.2 (fixed dimension): the cube example is consistent at every width.

Part 1 (simulation of the bound). For S ~ D_d^n (x uniform on {-1,1}^d, fair labels), put
  Delta0 = sum_x k_x ybar_x^2 = sum_x S_x^2 / k_x,   k_min = min_x k_x.
On {k_min >= 1}, every w with F_c(w) <= F_c(0) + t (in particular every near-minimizer, every width) has
  excess = (1/M) sum_x z_w(x)^2 <= U1 := (1/M) (sqrt((Delta0 + c t)/k_min) + sqrt(Delta0/k_min))^2
                                 <= U2 := 2 (2 Delta0 + c t) / (M k_min).
With probability >= 1 - delta' - M exp(-n/(8M)):  U2 <= HP := (8 M/delta' + 4 c t)/n.
We report medians of U1, U2, the empirical frequency of {U2 <= HP}, the guaranteed level, and beta(lambda).

Part 2 (illustration). L-BFGS on F_c at small d with n = lambda M; checks F(found) <= F(0) + t and
excess(found) <= U1 (floating point; an illustration, not a proof).
"""
import itertools, math
import numpy as np
from scipy.optimize import minimize
from scipy import stats

def beta_poi(lam):
    # E[1/K; K >= 1], K ~ Poisson(lam); summed directly (the closed form overflows for large lam)
    k = np.arange(1, int(lam + 40 * math.sqrt(lam) + 200))
    return float(np.sum(stats.poisson.pmf(k, lam) / k))

c, t, deltap = 1.0, 1.0, 0.05
rng = np.random.default_rng(20261111)
print("Part 1: simulated width-uniform upper bound on the excess of every near-minimizer (c = t = 1, delta' = 0.05)")
print(f"{'d':>2} {'lam':>5} {'reps':>5} {'P(k_min>=1)':>11} {'med U1':>9} {'med U2':>9} {'HP bnd':>9} "
      f"{'freq U2<=HP':>11} {'guarantee':>9} {'beta(lam)':>9}")
for d in (4, 6, 8):
    M = 2 ** d
    for lam in (1, 4, 16, 64, 256, 1024):
        n = lam * M
        reps = 400 if n <= 2 ** 16 else 100
        U1s, U2s, cov, seen_all = [], [], 0, 0
        HP = (8 * M / deltap + 4 * c * t) / n
        for _ in range(reps):
            idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
            k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=ys, minlength=M)
            kmin = k.min()
            if kmin >= 1:
                seen_all += 1
                D0 = float(np.sum(S ** 2 / k))
                U1 = (math.sqrt((D0 + c * t) / kmin) + math.sqrt(D0 / kmin)) ** 2 / M
                U2 = 2 * (2 * D0 + c * t) / (M * kmin)
                assert U1 <= U2 + 1e-12
            else:
                U1 = U2 = math.inf
            U1s.append(U1); U2s.append(U2); cov += (U2 <= HP)
        guar = max(0.0, 1 - deltap - M * math.exp(-n / (8 * M)))
        print(f"{d:>2} {lam:>5} {reps:>5} {seen_all / reps:>11.3f} {np.median(U1s):>9.4f} {np.median(U2s):>9.4f} "
              f"{HP:>9.4f} {cov / reps:>11.3f} {guar:>9.3f} {beta_poi(lam):>9.5f}")

# ---------------- Part 2: optimiser illustration ----------------
def run(d, H, N, lam, c, seed, restarts=2, t=1.0):
    rng = np.random.default_rng(seed)
    M = 2 ** d; n = lam * M
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=d))); Xb = np.hstack([np.ones((M, 1)), X])
    idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=ys, minlength=M)
    seen = k > 0; ybar = np.zeros(M); ybar[seen] = S[seen] / k[seen]
    shapes = [(N, d + 1)] + [(N, N)] * (H - 1) + [(N,)]; sizes = [int(np.prod(s)) for s in shapes]
    def unpack(p):
        out, o = [], 0
        for sh, sz in zip(shapes, sizes):
            out.append(p[o:o + sz].reshape(sh)); o += sz
        return out
    def fg(p):
        Ws = unpack(p); W1, mids, v = Ws[0], Ws[1:-1], Ws[-1]
        hs = [Xb]; h = np.tanh(Xb @ W1.T); hs.append(h)
        for Wl in mids:
            h = np.tanh(h @ Wl.T); hs.append(h)
        z = h @ v; r = z - ybar
        kap = (d / N) * np.sum(W1 ** 2) + sum(np.sum(Wl ** 2) for Wl in mids) + N * np.sum(v ** 2)
        F = kap + np.sum(k * r ** 2) / c
        dz = 2 * k * r / c
        gv = hs[-1].T @ dz + 2 * N * v
        delta = np.outer(dz, v) * (1 - hs[-1] ** 2)
        gm = []
        for li in range(len(mids) - 1, -1, -1):
            hprev = hs[li + 1]
            gm.insert(0, delta.T @ hprev + 2 * mids[li])
            delta = (delta @ mids[li]) * (1 - hprev ** 2)
        gW1 = delta.T @ Xb + 2 * (d / N) * W1
        return F, np.concatenate([gW1.ravel()] + [x.ravel() for x in gm] + [gv]), z, kap
    best = None
    for _ in range(restarts):
        p0 = np.concatenate([rng.normal(0, 1.0, size=(N, d + 1)).ravel()] +
                            [rng.normal(0, 1 / math.sqrt(N), size=(N, N)).ravel() for _ in range(H - 1)] +
                            [rng.normal(0, 1 / N, size=N)])
        res = minimize(lambda p: fg(p)[:2], p0, jac=True, method="L-BFGS-B", options={"maxiter": 20000, "maxfun": 40000})
        F, _, z, kap = fg(res.x)
        if best is None or F < best[0]:
            best = (F, z, kap)
    F, z, kap = best
    F0 = float(np.sum(k * ybar ** 2)) / c     # F_c(0) minus the constant W/c (same convention as F)
    kmin = k.min()
    D0 = float(np.sum(k * ybar ** 2))
    U1 = (math.sqrt((D0 + c * t) / kmin) + math.sqrt(D0 / kmin)) ** 2 / M if kmin >= 1 else math.inf
    exc = float(np.mean(z ** 2))
    print(f"  d={d} H={H} N={N} lam={lam} c={c:g} seed={seed}: k_min={int(kmin)}, F(found)-F(0)={F - F0:+.3f} "
          f"(<= t: {F <= F0 + t}), kappa={kap:.2f}, excess(found)={exc:.4f} <= U1={U1:.4f}: {exc <= U1}, "
          f"beta(lam)={beta_poi(lam):.4f}")

print("\nPart 2: L-BFGS illustration (F and kappa computed without the constant W/c)")
for (d, H, N, lam, seed) in [(4, 2, 32, 16, 1), (4, 2, 32, 64, 2), (5, 2, 48, 16, 3), (5, 3, 32, 64, 4)]:
    run(d, H, N, lam, 1.0, seed)
