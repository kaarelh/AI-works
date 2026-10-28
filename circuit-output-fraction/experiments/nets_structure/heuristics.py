"""Heuristic (NOT sound) estimators of p(s) = Pr_x[f(x) < s] for nets trained to
output 1, measured against the exact lower-tail curve of every net with an
exhaustive enumeration (suite nets: results/enum/*.json; nets trained here:
results/scaling_*.json).

Test levels per net: the net's own threshold t (exact p), and the levels
s = q_k (the k-th smallest value of f on the cube) for k = 1, 3, 10, 30, ...
with exact Pr[f <= q_k] = k / 2^d, as long as k / 2^d <= 0.05.

Estimators (all use only polynomially many evaluations of f or the weights):
  gauss      Phi((s - mu)/sigma), mu and sigma the exact mean and sd of f on the
             cube (a 1e4-sample estimate changes log10 p by < 0.1 at z <= 6;
             'gauss_mc' uses 1e4 samples).
  edgeworth  two-term Edgeworth expansion with the exact skewness and excess
             kurtosis (clipped below at 1e-300).
  mcfit      fit log Pr[f < s] = quadratic in s to the empirical lower tail of
             1e5 samples (levels with 10 ... 30000 samples below), extrapolate.
  ginput     CLT for the hidden pre-activations: Pr_{g ~ N(0, I_d)}[f(g) < s]
             (the Gaussian with the cube's first two moments), by subset
             simulation in Gaussian space (pCN moves; 2000 particles/level).
  sphere     the same with g uniform on the sphere of radius sqrt(d) (= |x|).
  poi_relu   presumption of independence over hidden units (one hidden layer):
             f = c + sum_j a_j relu(z_j) with z_j ~ N(b_j, |w_j|^2) INDEPENDENT;
             Lugannani-Rice saddlepoint for the lower tail.
  poi_even   the same in the even form f = c' + lam.x + sum_j (a_j/2)|z_j|, with
             lam.x and the |z_j| independent (lam.x with its exact cube law).
  lin_gauss  presumption of independence between the degree-1 (linear) Walsh part
             L = sum_i l_i x_i (exact cube law; l_i = E[f x_i] from 1e5 samples)
             and the rest of f (Gaussian, variance Var f - sum l_i^2); saddlepoint.
  poi_walsh  presumption of independence in the Walsh basis (d <= 20 only; needs
             the whole spectrum, so it is a diagnostic, not a usable estimator):
             f = sum_S fhat(S) eps_S with independent random signs eps_S.

usage: python3 heuristics.py [suite|own] [name-substring ...]
"""

import glob
import json
import math
import os
import sys

import numpy as np
from scipy.special import log_ndtr, ndtr
from scipy.stats import norm

from common import HERE, RES, load_net, save_json, suite_net

OWN = os.path.join(HERE, "cache", "own")


# ---------------------------------------------------------------- levels

def test_levels(row):
    d = row["d"]
    rk = np.array(row["tail_ranks"])
    q = np.array(row["tail_q"])
    out = []
    if row.get("p", row.get("p_exact", 0)) > 0 or True:
        F = row.get("F", row.get("fail_count"))
        out.append(dict(kind="threshold", s=row["threshold"], P=F / 2.0 ** d, k=F))
    k = 1
    while k / 2.0 ** d <= 0.05 and k <= rk.max():
        j = np.searchsorted(rk, k)
        if j < len(rk) and rk[j] == k:
            out.append(dict(kind="rank", s=float(q[j]), P=k / 2.0 ** d, k=int(k)))
        k = int(round(k * math.sqrt(10))) if k > 1 else 3
    return out


# ---------------------------------------------------------------- moment based

def gauss(s, mu, sd):
    return float(np.exp(log_ndtr((s - mu) / sd)))


def edgeworth(s, mu, sd, k3, k4):
    z = (s - mu) / sd
    he2, he3, he5 = z * z - 1, z ** 3 - 3 * z, z ** 5 - 10 * z ** 3 + 15 * z
    v = ndtr(z) - norm.pdf(z) * (k3 / 6 * he2 + k4 / 24 * he3 + k3 * k3 / 72 * he5)
    return float(max(v, 1e-300))


def mcfit(net, rng, n=100_000):
    X = rng.choice([-1.0, 1.0], size=(n, net.d))
    f = np.sort(net.forward(X))
    ks = np.unique(np.round(np.geomspace(10, 30000, 25)).astype(int))
    xs = f[ks - 1]
    ys = np.log(ks / n)
    A = np.vstack([np.ones_like(xs), xs - xs.mean(), (xs - xs.mean()) ** 2]).T
    coef, *_ = np.linalg.lstsq(A, ys, rcond=None)
    if coef[2] < 0:  # concave in s, as for a Gaussian lower tail; else fall back to linear
        pass
    else:
        A = A[:, :2]
        coef = np.append(np.linalg.lstsq(A, ys, rcond=None)[0], 0.0)
    m = xs.mean()

    def P(s):
        return float(min(1.0, np.exp(coef[0] + coef[1] * (s - m) + coef[2] * (s - m) ** 2)))
    return P


# ---------------------------------------------------------------- subset simulation in Gaussian space

def sus_curve(fun, d, s_min, rng, N=2000, p0=0.1, max_levels=60, steps=10):
    """Returns a function P(s) estimating Pr_g[fun(g) < s], g ~ N(0, I_d), for
    s >= the last level reached (levels go down until below s_min or P < 1e-30)."""
    g = rng.standard_normal((N, d))
    y = fun(g)
    segs = []  # (upper level, factor, sorted y)
    factor = 1.0
    upper = np.inf
    rho = 0.8
    for _ in range(max_levels):
        ys = np.sort(y)
        segs.append((upper, factor, ys))
        thr = ys[int(p0 * N) - 1]
        if thr <= s_min or factor * p0 < 1e-30 or ys[0] == ys[-1]:
            break
        keep = y <= thr
        frac = keep.mean()
        seeds, sy = g[keep], y[keep]
        n0 = len(seeds)
        reps = int(math.ceil(N / n0))
        cur = np.repeat(seeds, reps, axis=0)[:N]
        cy = np.repeat(sy, reps)[:N]
        acc_tot = 0.0
        for _ in range(steps):
            prop = rho * cur + math.sqrt(1 - rho * rho) * rng.standard_normal(cur.shape)
            py = fun(prop)
            ok = py <= thr
            cur[ok], cy[ok] = prop[ok], py[ok]
            acc_tot += ok.mean()
        acc = acc_tot / steps
        rho = min(0.995, max(0.05, rho + (0.1 if acc < 0.25 else -0.1 if acc > 0.45 else 0.0)))
        g, y = cur, cy
        factor *= frac
        upper = thr

    def P(s):
        """Deepest level whose conditioning threshold is >= s; 0 if no sample of
        that level lies below s."""
        best = None
        for up, fac, ys in segs:
            if up >= s:
                best = (fac, ys)
        fac, ys = best
        return float(fac * np.searchsorted(ys, s, side="left") / len(ys))
    return P


# ---------------------------------------------------------------- presumption of independence

def _log_mgf_relu(lam, m, sg):
    # log E exp(lam relu(Z)), Z ~ N(m, sg^2)
    a = log_ndtr(-m / sg)
    b = lam * m + 0.5 * lam * lam * sg * sg + log_ndtr(m / sg + lam * sg)
    return np.logaddexp(a, b)


def _log_mgf_abs(lam, m, sg):
    a = lam * m + 0.5 * lam * lam * sg * sg + log_ndtr(m / sg + lam * sg)
    b = -lam * m + 0.5 * lam * lam * sg * sg + log_ndtr(-m / sg + lam * sg)
    return np.logaddexp(a, b)


def poi_cgf(net, form):
    W, b = net.Ws[0], net.bs[0]
    a, c = net.Ws[1][0], float(net.bs[1][0])
    sg = np.linalg.norm(W, axis=1)
    if form == "relu":
        def K(th):
            return th * c + float(np.sum(_log_mgf_relu(th * a, b, sg)))
    else:
        lam = 0.5 * (a[:, None] * W).sum(axis=0)
        cp = c + 0.5 * float(a @ b)

        def K(th):
            return th * cp + float(np.sum(_log_mgf_abs(th * a / 2, b, sg))) + float(np.sum(np.logaddexp(th * lam, -th * lam) - math.log(2)))
    return K


def lugannani_rice_lower(K, s, scale):
    """Pr[S <= s] for S with CGF K, by the saddlepoint (theta < 0 for the lower tail)."""
    h = 1e-4 / scale

    def K1(t):
        return (K(t + h) - K(t - h)) / (2 * h)

    def K2(t):
        return (K(t + h) - 2 * K(t) + K(t - h)) / (h * h)
    mean = K1(0.0)
    if s >= mean:
        return None
    lo, hi = -1.0 / scale, 0.0
    while K1(lo) > s:
        lo *= 2
        if lo < -1e8 / scale:
            return 0.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if K1(mid) > s:
            hi = mid
        else:
            lo = mid
    th = 0.5 * (lo + hi)
    w2 = 2 * (th * s - K(th))
    if w2 <= 0:
        return float(ndtr((s - mean) / math.sqrt(max(K2(0.0), 1e-300))))
    w = -math.sqrt(w2)
    u = th * math.sqrt(max(K2(th), 1e-300))
    if abs(w) < 1e-3:
        return float(ndtr(w))
    val = ndtr(w) + norm.pdf(w) * (1 / w - 1 / u)
    if not (val > 0):
        # far tail: use the leading term of the expansion, exp(-w^2/2)/(|u| sqrt(2 pi))
        val = math.exp(-0.5 * w2) / (abs(u) * math.sqrt(2 * math.pi))
    return float(val)


def lin_gauss_cgf(net, mu, var, rng, n=100_000):
    X = rng.choice([-1.0, 1.0], size=(n, net.d))
    f = net.forward(X)
    ell = (X * (f - f.mean())[:, None]).mean(axis=0)
    vr = max(var - float(ell @ ell), 1e-12 * var)

    def K(th):
        x = np.abs(th * ell)
        return th * mu + 0.5 * th * th * vr + float(np.sum(x + np.log1p(np.exp(-2 * x)) - math.log(2)))
    return K


def walsh_cgf(net):
    from common import all_f
    from walsh import fwht
    f = all_f(net)
    fh = fwht(f.copy())
    mu = fh[0]
    c = np.abs(fh[1:])
    c = c[c > 1e-12 * c.max()]

    def K(th):
        x = np.abs(th * c)
        return th * mu + float(np.sum(x + np.log1p(np.exp(-2 * x)) - math.log(2)))
    return K


# ---------------------------------------------------------------- driver

def evaluate(net, row, rng):
    d = net.d
    mu, sd = row["mean"], row["std"]
    k3, k4 = row["skew"], row["exkurt"]
    levels = test_levels(row)
    X = rng.choice([-1.0, 1.0], size=(10000, d))
    fm = net.forward(X)
    mu_mc, sd_mc = float(fm.mean()), float(fm.std())
    P_fit = mcfit(net, rng)
    s_min = min(L["s"] for L in levels)
    P_g = sus_curve(lambda G: net.forward(G), d, s_min - 1e-9, rng)
    P_sph = sus_curve(lambda G: net.forward(G * (math.sqrt(d) / np.linalg.norm(G, axis=1))[:, None]), d,
                      s_min - 1e-9, rng)
    Ks = {}
    if len(net.Ws) == 2:
        Ks = {"poi_relu": poi_cgf(net, "relu"), "poi_even": poi_cgf(net, "even")}
    Ks["lin_gauss"] = lin_gauss_cgf(net, mu, sd * sd, rng)
    if d <= 20:
        Ks["poi_walsh"] = walsh_cgf(net)
    out = []
    for L in levels:
        s = L["s"]
        e = dict(L)
        e["z"] = (mu - s) / sd
        e["gauss"] = gauss(s, mu, sd)
        e["gauss_mc"] = gauss(s, mu_mc, sd_mc)
        e["edgeworth"] = edgeworth(s, mu, sd, k3, k4)
        e["mcfit"] = P_fit(s)
        e["ginput"] = P_g(s)
        e["sphere"] = P_sph(s)
        for nm, K in Ks.items():
            e[nm] = lugannani_rice_lower(K, s, sd)
        out.append(e)
    return out


METHODS = ["gauss", "gauss_mc", "edgeworth", "mcfit", "lin_gauss", "ginput", "sphere", "poi_relu", "poi_even", "poi_walsh"]


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else "suite"
    subs = sys.argv[2:]
    rng = np.random.default_rng(5)
    rows = []
    if which == "suite":
        for path in sorted(glob.glob(os.path.join(RES, "enum", "*.json"))):
            r = json.load(open(path))
            if subs and not any(s in r["name"] for s in subs):
                continue
            r["F"] = r["fail_count"]
            rows.append((suite_net(r["name"]), r))
    else:
        for path in sorted(glob.glob(os.path.join(RES, "scaling_*.json"))):
            if path.endswith("summary.json"):
                continue
            for r in json.load(open(path)):
                if subs and not any(s in r["name"] or s == r["config"] for s in subs):
                    continue
                rows.append((load_net(os.path.join(OWN, r["name"] + ".npz")), r))
    res = []
    outname = f"heuristics_{which}.json" if not subs else f"heuristics_{which}_{'_'.join(subs)}.json"
    for net, r in rows:
        ev = evaluate(net, r, rng)
        res.append(dict(name=r["name"], d=r["d"], loss=r["loss"], widths=r["widths"], step=r.get("step"), levels=ev))
        th = ev[0]
        msg = " ".join(f"{m}={th[m]:.1e}" for m in METHODS if th.get(m) is not None)
        print(r["name"], f"p={th['P']:.2e} z={th['z']:.2f}", msg, flush=True)
        save_json(res, outname)


if __name__ == "__main__":
    main()
