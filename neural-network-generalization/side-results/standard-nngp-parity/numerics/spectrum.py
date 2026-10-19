"""Exact spectra of standard-scaling tanh NNGP kernels on the Boolean cube (paper, Sections 2, 4, 7).

For each configuration this script computes, in exact-arithmetic-free but cancellation-free form:
  * the composite dual coefficients c_m of F (all >= 0) for m <= MMAX, and 1 - sum_{m<=MMAX} c_m.
    For tanh this "defect" (~1e-9) is quadrature error in the normalization; the true tail beyond
    MMAX is far smaller (c_m ~ e^{-c sqrt m}).  For the arcsine kernel it is a genuine truncated
    tail (~2e-2), so arcsine level masses are reliable only at low degree (we report q <= 33);
  * the D-cube eigenvalues a_j = sum_m c_m p_m(j) (walk representation, no cancellation);
  * the d-cube eigenvalues lambda_q = a_q + a_{q+1} and level masses binom(d,q) lambda_q;
and checks the statements used in the paper:
  (S1) lambda_q > 0 and nonincreasing in q;  pairing lambda_{2k} = lambda_{2k+1};
  (S2) lambda_{r+1} binom(D, r+2) <= tau_r for odd r                  (Lemma ratio);
  (S3) tau_s <= T(s) = sum_{m>s} c_m                                  (Lemma ratio);
  (S4) the first-layer coefficient lower bound of Lemma tanh-coefficients;
  (S5) the walk representation against a direct Gauss-Hermite evaluation of the kernel and a
       Krawtchouk transform at d = 10.
Results go to spectrum.json and spectrum.txt.
"""
import json, math, sys
import numpy as np
import mpmath as mp
from math import comb

mp.mp.dps = 40
MMAX = 600


def tanh_sq_mean(s):
    g = np.linspace(-40, 40, 400001)
    return float(np.trapezoid(np.tanh(s * g) ** 2 * np.exp(-g * g / 2), g) / math.sqrt(2 * math.pi))


def log_I_m(m, s):
    """log of I_m(s) = int_0^oo w^m exp(-s^2 w^2/2)/sinh(pi w/2) dw (log-space trapezoid around the peak)."""
    peak = math.sqrt(m) / s
    hi = peak + 40.0 / s + 40.0
    w = np.linspace(1e-12, hi, 200001)
    y = w * math.pi / 2
    logsinh = y + np.log1p(-np.exp(-2 * y)) - math.log(2)
    lf = m * np.log(w) - s * s * w * w / 2 - logsinh
    mx = lf.max()
    return mx + math.log(np.trapezoid(np.exp(lf - mx), w))


def tanh_layer(s, mmax=None):
    mmax = MMAX if mmax is None else mmax
    s = float(s)
    v = tanh_sq_mean(s)
    c = np.zeros(mmax + 1)
    lower_ok = True
    for m in range(1, mmax + 1, 2):
        logc = 2 * m * math.log(s) + 2 * log_I_m(m, s) - math.lgamma(m + 1) - math.log(v)
        c[m] = math.exp(logc)
        loglb = math.log(2 * math.sqrt(2 * math.pi) / (s * s * v * math.sqrt(m + 1))) - math.pi * math.sqrt(m + 1) / s
        if not logc >= loglb:
            lower_ok = False
    return c, v, lower_ok


def compose(outer, inner):
    mmax = len(inner) - 1
    res = np.zeros(mmax + 1)
    power = np.zeros(mmax + 1); power[0] = 1.0
    for k in range(1, mmax + 1):
        power = np.convolve(power, inner)[: mmax + 1]
        if outer[k] > 0:
            res += outer[k] * power
        if not power.any():
            break
    return res


def network(L, gain, s1=1.0, s=1.0, sv=1.0):
    q = s1 ** 2
    F, A, checks = None, None, []
    first = None
    for layer in range(1, L):
        c, v, ok = tanh_layer(math.sqrt(q))
        checks.append(ok)
        if first is None:
            first = c
        F = c if F is None else compose(c, F)
        if gain == "unit":
            A, q = sv ** 2 * v, s ** 2 * v
        else:
            A, q = 1.0, 1.0
    return F, A, checks


def arcsine(L, mmax=MMAX):
    c = np.zeros(mmax + 1)
    for k in range((mmax - 1) // 2 + 1):
        m = 2 * k + 1
        c[m] = float(2 / mp.pi * mp.binomial(2 * k, k) / (4 ** k * m))
    F = c
    for _ in range(L - 2):
        F = compose(c, F)
    return F


def walk(D, mmax):
    p = np.zeros((mmax + 1, D + 1)); p[0, 0] = 1.0
    j = np.arange(D + 1)
    for m in range(mmax):
        nxt = np.zeros(D + 1)
        nxt[1:] += j[1:] / D * p[m, :-1]
        nxt[:-1] += (D - j[:-1]) / D * p[m, 1:]
        p[m + 1] = nxt
    return p


def spectra(F, D):
    p = walk(D, len(F) - 1)
    a = F @ p                     # a_j = sum_m c_m p_m(j)
    d = D - 1
    lam = a[:-1] + a[1:]          # lambda_q, q = 0..d
    return a, lam


def check(F, D, name):
    d = D - 1
    a, lam = spectra(F, D)
    trunc = 1.0 - F.sum()
    # worst truncation error bound for a_j: trunc * max_{m>mmax} p_m(j) <= trunc * 2^{2-D} (mixed walk)
    mono = all(lam[q] >= lam[q + 1] * (1 - 1e-12) for q in range(d))
    pos = bool((lam > 0).all())
    pair = max(abs(lam[2 * k] - lam[2 * k + 1]) / lam[2 * k] for k in range(d // 2) if 2 * k + 1 <= d)
    level = np.array([comb(d, q) * lam[q] for q in range(d + 1)])
    tau = np.array([level[q + 1:].sum() for q in range(d + 1)])
    T = np.array([F[s + 1:].sum() + trunc for s in range(d + 1)])
    ratio_ok, tail_ok = True, True
    worst_ratio = 0.0
    for r in range(1, d - 1, 2):
        if tau[r] <= 0:
            continue
        rr = lam[r + 1] * comb(D, r + 2) / tau[r]
        worst_ratio = max(worst_ratio, rr)
        if rr > 1 + 1e-9:
            ratio_ok = False
    for s_ in range(d + 1):
        if tau[s_] > T[s_] * (1 + 1e-9) + 1e-300:
            tail_ok = False
    return {
        "name": name, "d": d, "D": D, "truncation_mass": trunc,
        "positive": pos, "monotone": mono, "pairing_rel_err": float(pair),
        "ratio_bound_holds": ratio_ok, "max_ratio": worst_ratio, "tail_bound_holds": tail_ok,
        "log10_level_mass": [float(np.log10(x)) for x in level],
        "log10_matrix_min_eig": float(np.log10(lam.min()) + d * np.log10(2)),
        "tau": [float(x) for x in tau[:12]],
        "T": [float(x) for x in T[:12]],
    }


def direct_kernel_check(L, gain, d=10, s1=1.0, s=1.0, sv=1.0, deg=120):
    """Gauss-Hermite evaluation of the layer recursion at the d+1 correlation values, Krawtchouk transform."""
    x, w = np.polynomial.hermite_e.hermegauss(deg); w = w / w.sum()
    D = d + 1
    rho = np.array([(1.0 + (d - 2 * h)) / D for h in range(d + 1)])   # (1+x.y)/D at Hamming distance h
    q = s1 ** 2
    cov = q * rho
    A = None
    for layer in range(1, L):
        vals = []
        for cxy in cov:
            r = cxy / q
            r = min(max(r, -1.0), 1.0)
            u = math.sqrt(q) * x[:, None]
            vv = math.sqrt(q) * (r * x[:, None] + math.sqrt(max(1 - r * r, 0.0)) * x[None, :])
            vals.append(float((w[:, None] * w[None, :] * np.tanh(u) * np.tanh(vv)).sum()))
        var = float((w * np.tanh(math.sqrt(q) * x) ** 2).sum())
        if gain == "unit":
            A = sv ** 2 * var
            cov = s ** 2 * np.array(vals); q = s ** 2 * var
        else:
            A = 1.0
            cov = np.array(vals) / var; q = 1.0
    kvals = (A * np.array(vals) / var) if gain == "unit" else cov  # output covariance at each distance
    if gain == "unit":
        kvals = sv ** 2 * np.array(vals)
    def kraw(j, h):
        return sum((-1) ** l * comb(h, l) * comb(d - h, j - l) for l in range(j + 1))
    lam = [sum(kvals[h] * comb(d, h) * kraw(j, h) for h in range(d + 1)) / 2 ** d / comb(d, j) for j in range(d + 1)]
    return np.array(lam), A


def main():
    out = {"MMAX": MMAX, "configs": []}
    lines = []
    configs = [("tanh unit gain L=2", 2, "unit"), ("tanh unit gain L=3", 3, "unit"),
               ("tanh unit gain L=4", 4, "unit"), ("tanh specified gain L=3", 3, "specified")]
    Fs = {}
    for name, L, gain in configs:
        F, A, lower_ok = network(L, gain)
        Fs[name] = (F, A, L, gain)
        out["configs"].append({"name": name, "A": A, "first_layer_lower_bound_holds": lower_ok,
                               "c": {str(m): float(F[m]) for m in (1, 3, 5, 9, 17, 33, 65, 129, 257, 513)}})
        lines.append(f"{name}: A={A:.6f}, coefficient lower bound (Lemma tanh-coefficients) holds at every layer: {all(lower_ok)}")
        lines.append("   c_m: " + ", ".join(f"m={m}:{F[m]:.3e}" for m in (1, 3, 9, 33, 129, 513)))
    Fs["arcsine L=2"] = (arcsine(2), 1.0, 2, None)
    lines.append("   arcsine L=2 c_m: " + ", ".join(f"m={m}:{Fs['arcsine L=2'][0][m]:.3e}" for m in (1, 3, 9, 33, 129, 513)))
    out["spectra"] = []
    for name, (F, A, L, gain) in Fs.items():
        for D in (21, 41, 81, 161):
            r = check(F, D, name)
            out["spectra"].append(r)
            lines.append(f"{name}, d={D-1}: positive={r['positive']} monotone={r['monotone']} pairing_err={r['pairing_rel_err']:.1e} "
                         f"ratio(S2)={r['ratio_bound_holds']} (max {r['max_ratio']:.3f}) tail(S3)={r['tail_bound_holds']} "
                         f"1-sum(c)={r['truncation_mass']:.1e} log10 min matrix eig={r['log10_matrix_min_eig']:.2f}")
            lm = r["log10_level_mass"]
            idx = [1, 3, 5, 9, 17, 33, 65, (D - 1) // 2, D - 2]
            lines.append("      log10 level mass binom(d,q)lambda_q at q=" + ", ".join(f"{q}:{lm[q]:.2f}" for q in idx if q <= D - 1))
    # direct check
    out["direct"] = []
    for name, L, gain in configs:
        lam_direct, A = direct_kernel_check(L, gain)
        F = Fs[name][0]
        _, lam = spectra(F, 11)
        lam = Fs[name][1] * lam
        rel = float(np.max(np.abs(lam - lam_direct) / np.abs(lam)))
        out["direct"].append({"name": name, "max_rel_diff_d10": rel})
        lines.append(f"direct Gauss-Hermite/Krawtchouk check at d=10, {name}: max relative eigenvalue difference {rel:.2e}")
    json.dump(out, open("spectrum.json", "w"), indent=1)
    open("spectrum.txt", "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
