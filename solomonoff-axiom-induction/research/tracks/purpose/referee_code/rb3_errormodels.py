"""rb3_errormodels.py -- referee B, track `purpose`, target T3 (independent code).

Seed 20261018.  Writes rb3_errormodels.out next to itself.

  A. T3.1: for 3000 random pairs of residual vectors, the ML-fitted Gaussian / Laplace / uniform / generalised
     Gaussian (p = 3) log losses, minimised NUMERICALLY over the scale (no closed form used), rank the pair exactly
     as RMS / mean |e| / max |e| / M_3 do; and the minimum equals the closed form.
  B. T3.2: H(C_U(e) | U) by Monte Carlo over (e, U) with exact cell probabilities from the distribution function,
     against h(e + V) - log2 Delta from the density of e + V computed on a fine grid.  Error laws include a singular
     (Cantor-type) law and a mixed atom + density law, which the developer did not test.
  C. T3.3(a): the coarse identity (1/Delta) int H2(F) and the properties D(e + c) = D(e), D(lambda e) = |lambda| D(e).
  D. T3.3(b): the fine limit for a bounded density, and the atomic case (rate = H(e) for Delta <= least gap, and
     what happens just above the least gap).
  E. P15: a 40-bin histogram law and a permutation of its bins: same h, different RMS; rates at fine and coarse Delta.
"""
import math
import os

import numpy as np
from scipy import optimize, special

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LOG2E = 1 / math.log(2)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


# ------------------------------------------------------------------------------------------------- A
def ml_loss(e, family, p=3.0):
    """minimum over the scale of the summed -log2 density of the residuals (location fixed at 0), numerically"""
    a = np.abs(e)
    if family == "uniform":
        return len(e) * math.log2(2 * a.max())          # monotone in delta >= max, so the infimum is at max
    def nll(logs):
        s = math.exp(logs)
        if family == "gauss":
            return float(np.sum(0.5 * (e / s) ** 2 + 0.5 * math.log(2 * math.pi * s * s))) * LOG2E
        if family == "laplace":
            return float(np.sum(a / s + math.log(2 * s))) * LOG2E
        if family == "gg":
            c = 2 * s * special.gamma(1 + 1 / p)
            return float(np.sum((a / s) ** p + math.log(c))) * LOG2E
    r = optimize.minimize_scalar(nll, bounds=(math.log(a.mean()) - 8, math.log(a.max()) + 8), method="bounded",
                                 options={"xatol": 1e-12})
    return r.fun


def part_A(rng):
    out("\n== A. fitted-scale error models rank by L^p norms [T3.1]")
    fams = [("gauss", lambda e: np.sqrt(np.mean(e ** 2))), ("laplace", lambda e: np.mean(np.abs(e))),
            ("uniform", lambda e: np.max(np.abs(e))), ("gg", lambda e: np.mean(np.abs(e) ** 3) ** (1 / 3))]
    agree = {f: 0 for f, _ in fams}
    cf_err = {f: 0.0 for f, _ in fams}
    npairs = 3000
    for _ in range(npairs):
        n = int(rng.integers(5, 60))
        kind = rng.integers(0, 3)
        e1 = rng.standard_normal(n) * rng.uniform(0.2, 3) if kind == 0 else rng.laplace(size=n) * rng.uniform(0.2, 3)
        e2 = rng.uniform(-1, 1, n) * rng.uniform(0.2, 3) if kind != 2 else rng.standard_t(2, n)
        for f, norm in fams:
            l1, l2 = ml_loss(e1, f), ml_loss(e2, f)
            agree[f] += (np.sign(l1 - l2) == np.sign(norm(e1) - norm(e2)))
            M = norm(e1)
            cf = {"gauss": n / 2 * math.log2(2 * math.pi * math.e * M * M), "laplace": n * math.log2(2 * math.e * M),
                  "uniform": n * math.log2(2 * M),
                  "gg": n * math.log2(2 * special.gamma(1 + 1 / 3) * (3 * math.e) ** (1 / 3) * M)}[f]
            cf_err[f] = max(cf_err[f], abs(cf - l1) / n)
    for f, _ in fams:
        out("   %-8s ranking agrees with its norm on %d / %d pairs; max |numerical min - closed form| per datum %.1e bits"
            % (f, agree[f], npairs, cf_err[f]))


# ------------------------------------------------------------------------------------------------- B, C, D
class Law:
    """a law on the reals given by a sampler and a vectorised CDF F(x) = P(e <= x) and left limit F(x-)"""
    def __init__(self, name, sample, cdf, cdf_left=None, support=(-1, 1)):
        self.name, self.sample, self.cdf = name, sample, cdf
        self.cdf_left = cdf_left or cdf
        self.support = support


def cantor_cdf(x, levels=18):
    """distribution function of the middle-thirds Cantor law on [-1, 1] (affine image of [0, 1])"""
    y = (np.asarray(x, float) + 1) / 2
    y = np.clip(y, 0, 1)
    res = np.zeros_like(y)
    scale = 0.5
    cur = y.copy()
    for _ in range(levels):
        d = np.floor(cur * 3)
        d = np.clip(d, 0, 2)
        res += np.where(d == 2, scale, 0.0)
        mid = d == 1
        res += np.where(mid, scale, 0.0)
        cur = np.where(mid, 0.0, cur * 3 - d)
        scale *= 0.5
        # once in the middle third, the CDF is flat at the value reached; freeze
        cur = np.where(mid, -1.0, cur)
        cur = np.where(cur < 0, -1.0, cur)
    return np.where(y >= 1, 1.0, res)


def cantor_sample(rng, n, levels=30):
    digits = rng.integers(0, 2, size=(n, levels)) * 2
    y = (digits * (3.0 ** -np.arange(1, levels + 1))).sum(axis=1)
    return 2 * y - 1


def laws():
    L = []
    L.append(Law("triangular[-1,1]", lambda r, n: r.triangular(-1, 0, 1, n),
                 lambda x: np.where(x < -1, 0, np.where(x < 0, 0.5 * (x + 1) ** 2, np.where(x < 1, 1 - 0.5 * (1 - x) ** 2, 1)))))
    L.append(Law("beta(2,5) on [0,1]", lambda r, n: r.beta(2, 5, n),
                 lambda x: special.betainc(2, 5, np.clip(x, 0, 1)), support=(0, 1)))
    # mixed: atom 0.3 at 0.2, plus 0.7 uniform on [-1, 1]
    def mixcdf(x):
        return 0.7 * np.clip((x + 1) / 2, 0, 1) + 0.3 * (x >= 0.2)
    def mixcdf_left(x):
        return 0.7 * np.clip((x + 1) / 2, 0, 1) + 0.3 * (x > 0.2)
    L.append(Law("0.3 atom@0.2 + 0.7 U[-1,1]", lambda r, n: np.where(r.random(n) < 0.3, 0.2, r.uniform(-1, 1, n)),
                 mixcdf, mixcdf_left))
    L.append(Law("Cantor law on [-1,1] (singular)", lambda r, n: cantor_sample(r, n), cantor_cdf))
    return L


def H_cell_given_U_mc(law, Delta, rng, n=400000):
    """Monte Carlo over (e, U): grid {k Delta - U}; cell of e is [k Delta - U, (k+1) Delta - U); its probability is
    F((k+1)Delta - U -) - F(k Delta - U -)  (cells are left-closed)"""
    e = law.sample(rng, n)
    U = rng.uniform(0, Delta, n)
    k = np.floor((e + U) / Delta)
    lo, hi = k * Delta - U, (k + 1) * Delta - U
    p = law.cdf_left(hi) - law.cdf_left(lo)
    v = -np.log2(np.maximum(p, 1e-300))
    return float(v.mean()), float(v.std() / math.sqrt(n))


def h_eV_grid(law, Delta, m=400000):
    """h(e + V), V ~ U(0, Delta]: density f(y) = P(y - Delta <= e < y) / Delta, integrated on a fine grid"""
    a, b = law.support
    ys = np.linspace(a, b + Delta, m + 1)
    mid = 0.5 * (ys[:-1] + ys[1:])
    f = (law.cdf_left(mid) - law.cdf_left(mid - Delta)) / Delta
    with np.errstate(divide="ignore", invalid="ignore"):
        g = np.where(f > 0, -f * np.log2(f), 0.0)
    return float(g.sum() * (ys[1] - ys[0]))


def D_coarse(law, m=400000):
    a, b = law.support
    ts = np.linspace(a, b, m + 1)
    mid = 0.5 * (ts[:-1] + ts[1:])
    F = law.cdf(mid)
    with np.errstate(divide="ignore", invalid="ignore"):
        H = np.where((F > 0) & (F < 1), -F * np.log2(F) - (1 - F) * np.log2(1 - F), 0.0)
    return float(H.sum() * (ts[1] - ts[0]))


def part_BCD(rng):
    out("\n== B/C. H(cell | U) (Monte Carlo, n = 4e5, +- 1 SE) against h(e+V) - log2 Delta (grid) [T3.2, T3.3(a)]")
    out("   %-32s %6s | %16s | %10s | %10s" % ("law", "Delta", "MC E_U H", "h(e+V)-lgD", "D(e)/Delta"))
    worst_z = 0.0
    for law in laws():
        a, b = law.support
        D = D_coarse(law)
        for Delta in (0.02, 0.1, 0.5, 1.0, 2.0, 4.0):
            mc, se = H_cell_given_U_mc(law, Delta, rng)
            hv = h_eV_grid(law, Delta) - math.log2(Delta)
            coarse = D / Delta if Delta >= (b - a) else float("nan")
            worst_z = max(worst_z, abs(mc - hv) / max(se, 1e-9))
            out("   %-32s %6.2f | %8.5f +- %.5f | %10.5f | %10.5f" % (law.name, Delta, mc, se, hv, coarse))
    out("   largest |MC - formula| / SE = %.2f" % worst_z)
    # C: translation and scale properties of D
    law = laws()[1]
    D0 = D_coarse(law)
    shifted = Law("shift", None, lambda x: law.cdf(x - 0.37), support=(0.37, 1.37))
    scaled = Law("scale", None, lambda x: law.cdf(x / 2.5), support=(0, 2.5))
    out("   D(beta) = %.6f, D(beta + 0.37) = %.6f, D(2.5 beta) / 2.5 = %.6f" % (D0, D_coarse(shifted), D_coarse(scaled) / 2.5))


def part_D_atoms():
    out("\n== D. atomic errors and the fine limit [T3.3(b)]")
    # atoms at 0, 1, 3 with probs .5 .3 .2 -> least gap 1
    xs, ps = np.array([0.0, 1.0, 3.0]), np.array([0.5, 0.3, 0.2])
    H = float(-(ps * np.log2(ps)).sum())
    def rate(Delta, m=200001):
        ys = np.linspace(-0.5, 3.5 + Delta, m)
        mid = 0.5 * (ys[:-1] + ys[1:])
        f = sum(p * ((mid - Delta <= x) & (x < mid)) for x, p in zip(xs, ps)) / Delta
        with np.errstate(divide="ignore", invalid="ignore"):
            g = np.where(f > 0, -f * np.log2(f), 0)
        return float(g.sum() * (ys[1] - ys[0])) - math.log2(Delta)
    out("   atoms {0,1,3} w.p. {.5,.3,.2}: H = %.5f; rate at Delta = 0.01, 0.5, 1.0, 1.5, 2.0, 3.0: %s" % (
        H, ", ".join("%.5f" % rate(D) for D in (0.01, 0.5, 1.0, 1.5, 2.0, 3.0))))
    # fine limit for a bounded density: triangular, h = 1/2 log2 e  (in bits: h(tri[-1,1]) = 1/(2 ln 2))
    tri = laws()[0]
    h_true = 0.5 * LOG2E
    vals = [(D, h_eV_grid(tri, D) - math.log2(D) - (h_true - math.log2(D))) for D in (0.5, 0.1, 0.02, 0.004)]
    out("   triangular[-1,1]: h = %.5f bits; rate - (h - log2 Delta) at Delta = %s" % (
        h_true, ", ".join("%g: %.5f" % v for v in vals)))
    cant = laws()[3]
    vals = [(D, h_eV_grid(cant, D, m=2000000) - math.log2(D)) for D in (0.5, 0.1, 0.02, 0.004)]
    out("   Cantor law (no density): rate at Delta = %s; ratio to log2(1/Delta): %s (log3 2 = %.4f)" % (
        ", ".join("%g: %.4f" % v for v in vals), ", ".join("%.3f" % (r / math.log2(1 / D)) for D, r in vals),
        math.log(2) / math.log(3)))


def part_E(rng):
    out("\n== E. histogram law vs a permutation of its bins (P15)")
    B, L = 40, 2.0
    w = 2 * L / B
    edges = -L + w * np.arange(B + 1)
    mids = 0.5 * (edges[:-1] + edges[1:])
    p = np.exp(-0.5 * (mids / 0.7) ** 2) + 0.05
    p /= p.sum()
    perm = rng.permutation(B)
    for name, pp in (("histogram", p), ("bins permuted", p[perm])):
        rms = math.sqrt(float(np.sum(pp * (mids ** 2 + w * w / 12))))
        mae = float(np.sum(pp * np.array([np.mean(np.abs(np.linspace(a, a + w, 2001))) for a in edges[:-1]])))
        h = float(-(pp * np.log2(pp / w)).sum())
        cum = np.concatenate([[0], np.cumsum(pp)])
        law = Law(name, None, lambda x, cum=cum: np.interp(x, edges, cum, left=0, right=1), support=(-L, L))
        r = {D: h_eV_grid(law, D) - math.log2(D) for D in (w / 64, w / 8, 1.0, 2 * L)}
        out("   %-14s RMS %.4f mean|e| %.4f h %.4f | rate-(h-lgD) at w/64 %.4f, w/8 %.4f | rate at 1: %.4f, coarse(2L): %.4f"
            % (name, rms, mae, h, r[w / 64] - (h - math.log2(w / 64)), r[w / 8] - (h - math.log2(w / 8)), r[1.0],
               r[2 * L]))


def main():
    rng = np.random.default_rng(SEED)
    out("# rb3_errormodels.py seed=%d numpy %s (referee B, independent of checks/p3_errormodels.py)" % (SEED, np.__version__))
    part_A(rng)
    part_BCD(rng)
    part_D_atoms()
    part_E(rng)
    out("\n# done")
    with open(os.path.join(HERE, "rb3_errormodels.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
