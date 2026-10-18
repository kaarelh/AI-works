"""p3_errormodels.py -- track `purpose`, target T3: error densities as purposes, and the entropy rate of SAI's best
calibrated error model in the paper's regime R.

Seed 20261017.  Writes p3_errormodels.out next to itself.  Logarithms base 2, losses in bits.

Parts
  A. Location-scale error models with the scale fitted by maximum likelihood: the minimum over s of
     sum_j -log2 p_s(e_j) against the closed forms
        Gaussian      n/2 log2(2 pi e sigma^2),  sigma^2 = mean e^2              (RMS)
        Laplace       n log2(2 e b),             b = mean |e|                    (mean absolute error)
        uniform       n log2(2 delta),           delta = max |e|                 (maximum error)
        gen. Gaussian n log2(2 Gamma(1+1/p) (p e)^(1/p) M_p), M_p = (mean |e|^p)^(1/p)
     (e here is Euler's number inside the logarithms).
  B. The dithered-cell identity (T3 Lemma): for a uniform dither of a grid of width Delta,
        E_u H(cell of e | u) = h(e + V) - log2 Delta,   V ~ Unif[0, Delta) independent of e,
     checked by quadrature over the dither against the entropy of the smoothed density, for continuous, arcsine,
     atomic and mixed error laws; and in the coarse regime against (1/Delta) int H2(F_e(t)) dt.
  C. Distance-blindness at fine resolution: rearranging the error law (permuting histogram bins, or moving atoms)
     leaves h and the fine-Delta rate unchanged, while RMS, mean |e| and max |e| change.
"""
import math
import os

import numpy as np
from scipy import optimize, special

SEED = 20261017
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LOG2E = 1 / math.log(2)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = np.clip(np.asarray(x, float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


# ---------------------------------------------------------------- A
def partA(rng):
    out("\n== A. ML scale in location-scale error families: numerical minimum vs closed form (bits)")
    samples = {"Gaussian sample": rng.normal(0, 1.3, 5000),
               "Laplace sample": rng.laplace(0, 0.7, 5000),
               "arcsine (sinusoid) sample": np.sin(2 * np.pi * rng.random(5000))}
    for name, e in samples.items():
        n = e.size
        a = np.abs(e)

        def L_gauss(ls):
            s = math.exp(ls)
            return float(np.sum(e ** 2 / (2 * s * s) * LOG2E + 0.5 * math.log2(2 * math.pi * s * s)))

        def L_lap(ls):
            b = math.exp(ls)
            return float(np.sum(a / b * LOG2E + math.log2(2 * b)))

        def L_gg(ls, p):
            s = math.exp(ls)
            return float(np.sum((a / s) ** p * LOG2E + math.log2(2 * special.gamma(1 + 1 / p) * s)))
        g_num = optimize.minimize_scalar(L_gauss, bounds=(-8, 8), method="bounded", options={"xatol": 1e-12}).fun
        g_cf = n / 2 * math.log2(2 * math.pi * math.e * np.mean(e ** 2))
        l_num = optimize.minimize_scalar(L_lap, bounds=(-8, 8), method="bounded", options={"xatol": 1e-12}).fun
        l_cf = n * math.log2(2 * math.e * np.mean(a))
        u_cf = n * math.log2(2 * np.max(a))      # uniform: L(delta) = n log2(2 delta) for delta >= max|e|, infinite below
        p = 4.0
        gg_num = optimize.minimize_scalar(lambda ls: L_gg(ls, p), bounds=(-8, 8), method="bounded",
                                          options={"xatol": 1e-12}).fun
        Mp = np.mean(a ** p) ** (1 / p)
        gg_cf = n * math.log2(2 * special.gamma(1 + 1 / p) * (p * math.e) ** (1 / p) * Mp)
        out("   %-26s Gaussian %.4f / %.4f | Laplace %.4f / %.4f | uniform %.4f | gen.Gauss p=4 %.4f / %.4f" % (
            name, g_num, g_cf, l_num, l_cf, u_cf, gg_num, gg_cf))
    # p -> infinity limit of the generalized-Gaussian constant
    for p in (2, 8, 32, 128, 1024):
        out("   constant 2 Gamma(1+1/p) (p e)^(1/p) at p = %4d: %.6f   (p=1: 2e = %.6f; p=2: sqrt(2 pi e) = %.6f; limit 2)" % (
            p, 2 * special.gamma(1 + 1 / p) * (p * math.e) ** (1 / p), 2 * math.e, math.sqrt(2 * math.pi * math.e)))


# ---------------------------------------------------------------- B
class ErrLaw:
    """an error law given by a CDF F (vectorised, right-continuous) on [-L, L]"""

    def __init__(self, name, F, L, atoms=()):
        self.name, self.F, self.L, self.atoms = name, F, L, atoms


def cell_entropy_over_dither(law, Delta, M=4000):
    """E_u H(cell | u), cells [k Delta - u, (k+1) Delta - u), u ~ Unif[0, Delta): midpoint rule in u."""
    tot = 0.0
    kmin = math.floor(-law.L / Delta) - 2
    kmax = math.ceil(law.L / Delta) + 2
    ks = np.arange(kmin, kmax + 1)
    for i in range(M):
        u = (i + 0.5) / M * Delta
        lo = ks * Delta - u
        hi = (ks + 1) * Delta - u
        # P(lo <= e < hi) = F(hi-) - F(lo-) ; use F at points shifted down by a hair for left limits
        p = law.F(hi - 1e-12) - law.F(lo - 1e-12)
        p = p[p > 1e-300]
        tot += float(-np.sum(p * np.log2(p)))
    return tot / M


def smoothed_entropy(law, Delta, N=400001):
    """h(e + V), V ~ Unif[0, Delta): density f(y) = (F(y) - F(y - Delta)) / Delta, trapezoid rule."""
    y = np.linspace(-law.L - 1e-9, law.L + Delta + 1e-9, N)
    f = (law.F(y) - law.F(y - Delta)) / Delta
    with np.errstate(divide="ignore", invalid="ignore"):
        g = np.where(f > 0, -f * np.log2(f), 0.0)
    return float(np.trapezoid(g, y))


def coarse_formula(law, N=400001):
    t = np.linspace(-law.L, law.L, N)
    return float(np.trapezoid(H2(law.F(t)), t))


def partB():
    out("\n== B. E_u H(cell | u) against h(e + V) - log2 Delta, and against (1/Delta) int H2(F_e) when Delta >= 2 max|e|")
    laws = [
        ErrLaw("uniform[-1,1]", lambda x: np.clip((x + 1) / 2, 0, 1), 1.0),
        ErrLaw("arcsine (sinusoid)", lambda x: np.where(x < -1, 0.0, np.where(x >= 1, 1.0,
                                                          0.5 + np.arcsin(np.clip(x, -1, 1)) / math.pi)), 1.0),
        ErrLaw("atoms -1,0,1 (0.1,0.8,0.1)", lambda x: 0.1 * (x >= -1) + 0.8 * (x >= 0) + 0.1 * (x >= 1), 1.0,
               atoms=(-1, 0, 1)),
        ErrLaw("0.9 U[-.05,.05] + 0.1 U[-4,4]",
               lambda x: 0.9 * np.clip((x + 0.05) / 0.1, 0, 1) + 0.1 * np.clip((x + 4) / 8, 0, 1), 4.0),
    ]
    out("   %-30s %7s | %10s %10s | %10s" % ("error law", "Delta", "E_u H", "h(e+V)-logD", "coarse"))
    for law in laws:
        for Delta in (0.05, 0.25, 1.0, 2.0, 4.0, 8.0, 16.0):
            a = cell_entropy_over_dither(law, Delta)
            b = smoothed_entropy(law, Delta) - math.log2(Delta)
            c = coarse_formula(law) / Delta if Delta >= 2 * law.L else float("nan")
            out("   %-30s %7.2f | %10.5f %10.5f | %10.5f" % (law.name, Delta, a, b, c))
    # the paper's per-straddle constants c_F = (1/(2 eps)) int H2(F_e) dt with eps = max|e| = 1
    arc = laws[1]
    out("   per-straddle c_F (band [-1,1]): uniform |e| %.4f (paper 0.7213), sinusoid %.4f (paper's Gibbs bound 0.8510 on a"
        " test half)" % (coarse_formula(laws[0]) / 2, coarse_formula(arc) / 2))
    out("   fine limit: h(arcsine on [-1,1]) = log2(pi/2) = %.5f bits; h(U[-1,1]) = 1 bit; atoms: H = %.5f bits" % (
        math.log2(math.pi / 2), float(-np.sum(np.array([.1, .8, .1]) * np.log2([.1, .8, .1])))))


# ---------------------------------------------------------------- C
def partC(rng):
    out("\n== C. rearrangement: a 40-bin histogram error law and a bin permutation of it (same masses, other places)")
    e = np.sin(2 * np.pi * rng.random(200000)) + 0.15 * rng.normal(size=200000)
    L = float(np.max(np.abs(e)))
    edges = np.linspace(-L, L, 41)
    cnt, _ = np.histogram(e, bins=edges)
    p = cnt / cnt.sum()
    w = edges[1] - edges[0]
    perm = rng.permutation(40)
    centers = (edges[:-1] + edges[1:]) / 2

    def stats_of(pp):
        rms = math.sqrt(float(np.sum(pp * (centers ** 2 + w * w / 12))))
        mae = float(np.sum(pp * np.abs(centers)))          # bin-centre approximation
        mx = float(np.max(np.abs(centers[pp > 0]) + w / 2))
        h = float(-np.sum(pp[pp > 0] * np.log2(pp[pp > 0]))) + math.log2(w)
        return rms, mae, mx, h

    for name, pp in (("histogram", p), ("bins permuted", p[perm])):
        rms, mae, mx, h = stats_of(pp)
        law = ErrLaw(name, lambda x, pp=pp: np.interp(x, edges, np.concatenate([[0.0], np.cumsum(pp)])), L)
        r = {D: cell_entropy_over_dither(law, D, M=2000) for D in (w / 64, w / 8, w / 2, 1.0, 2 * L + 0.01)}
        out("   %-14s RMS %.4f  mean|e| %.4f  max %.4f | h = %.4f bits | rate - (h - log2 Delta) at Delta = w/64: %.4f,"
            " w/8: %.4f | rate at w/2: %.4f, 1: %.4f, coarse (Delta = 2L): %.4f" % (
                name, rms, mae, mx, h, r[w / 64] - (h - math.log2(w / 64)), r[w / 8] - (h - math.log2(w / 8)),
                r[w / 2], r[1.0], r[2 * L + 0.01]))
    out("   (as Delta -> 0 both rates approach h - log2 Delta = H(bins) + log2(w/Delta), and h is the same; the permutation")
    out("    changes the rate only through the smoothing at bin edges, O(Delta/w) bits; at coarser Delta the rates differ,")
    out("    and the coarse rate (1/Delta) int H2(F) sees where the mass is, at scales up to Delta)")


def main():
    rng = np.random.default_rng(SEED)
    out("# p3_errormodels.py seed=%d numpy %s" % (SEED, np.__version__))
    partA(rng)
    partB()
    partC(rng)
    out("\n# done")
    with open(os.path.join(HERE, "p3_errormodels.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
