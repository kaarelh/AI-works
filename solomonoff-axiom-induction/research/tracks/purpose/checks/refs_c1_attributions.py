"""refs_c1_attributions.py -- reference checker, track "purpose" (2026-10-17).

Numerical sanity checks of three formal statements that refs-report.md attributes to the literature. These checks
do not verify the attributions (that was done by search); they check that the statements, as we transcribe them,
are true, so that the developer does not inherit a transcription error.

(1) Square loss lambda(y, g) = (y - g)^2 with outcomes y in [-B, B] is eta-mixable for eta = 1/(2 B^2) (the [0, 1]
    constant eta = 2 of Haussler--Kivinen--Warmuth 1998 / Cesa-Bianchi--Lugosi 2006 Sec. 3.6, rescaled by the
    affine map y = -B + 2B y', which multiplies the loss by 4B^2 and so divides eta by 4B^2), and is NOT
    eta-mixable for eta slightly larger. Test: for random finite pools (predictions g_i in [-B, B], weights w_i),
    the generalised prediction G(y) = -(1/eta) ln sum_i w_i exp(-eta (y - g_i)^2) must be dominated by a single
    prediction: there is g with (y - g)^2 <= G(y) for every y in [-B, B]. We use Vovk's substitution
    g* = (G(-B) - G(B)) / (4B) and also minimise over g (bounded convex scalar minimisation).
(2) The aggregating-algorithm bound with prior weights (Vovk 2001, Lemma 1, as restated in the RHUL thesis):
    Loss_T(AA) <= -(1/eta) ln sum_k w_k exp(-eta Loss_T(k)) <= Loss_T(k) + ln(1/w_k)/eta, for a pool of constant
    predictors with weights w_k proportional to 2^-k, on a seeded random outcome sequence.
(3) Gneiting--Raftery 2007: CRPS integral form int (F(t) - 1{t >= x})^2 dt equals the kernel form
    E|X - x| - (1/2) E|X - X'| (negatively oriented here), for discrete forecasts; and the author's example
    (uniform on 5 nearby vs 5 scattered values, both containing the outcome) has equal log score and different CRPS.

Seed: numpy default_rng(20261017). Output: refs_c1_attributions.out (same folder).
"""
import numpy as np
from scipy.optimize import minimize_scalar

rng = np.random.default_rng(20261017)
out_lines = []


def say(s=""):
    print(s)
    out_lines.append(s)


# ---------------------------------------------------------------------------------------------------------------
# (1) mixability constant of square loss on [-B, B]
# ---------------------------------------------------------------------------------------------------------------
def G(y, g, w, eta):
    # generalised prediction, computed stably
    a = -eta * (y[:, None] - g[None, :]) ** 2 + np.log(w)[None, :]
    m = a.max(axis=1, keepdims=True)
    return -(m[:, 0] + np.log(np.exp(a - m).sum(axis=1))) / eta


def worst_gap(g, w, eta, B, ygrid, ggrid=None):
    """min over predictions gamma of max over y of (y - gamma)^2 - G(y); <= 0 iff the pool is dominated.
    gamma -> max_y [(y - gamma)^2 - G(y)] is convex (a max of convex functions), so a bounded scalar minimisation
    finds its minimum; we also report the value at Vovk's substitution g* = (G(-B) - G(B)) / (4B)."""
    Gy = G(ygrid, g, w, eta)
    f = lambda gam: ((ygrid - gam) ** 2 - Gy).max()
    res = minimize_scalar(f, bounds=(-B, B), method="bounded", options={"xatol": 1e-12})
    sub = (G(np.array([-B]), g, w, eta)[0] - G(np.array([B]), g, w, eta)[0]) / (4 * B)
    return min(res.fun, f(sub)), f(sub)


say("(1) Square loss on [-B, B]: eta-mixability at eta = c/(2B^2)")
ygrid_n = 2001
for B in (1.0, 3.0):
    ygrid = np.linspace(-B, B, ygrid_n)
    ggrid = None
    for c in (1.0, 1.05, 1.2):
        eta = c / (2 * B * B)
        worst_grid, worst_sub = -np.inf, -np.inf
        for trial in range(400):
            n = rng.integers(2, 6)
            g = rng.uniform(-B, B, n)
            if trial % 2 == 0:  # endpoint pools are the hardest case
                g[:2] = [-B, B]
            w = rng.dirichlet(np.ones(n))
            a, b = worst_gap(g, w, eta, B, ygrid, ggrid)
            worst_grid, worst_sub = max(worst_grid, a), max(worst_sub, b)
        # the two-endpoint pool with weights p, 1-p, scanned over p
        for p in np.linspace(0.01, 0.99, 99):
            a, b = worst_gap(np.array([-B, B]), np.array([p, 1 - p]), eta, B, ygrid, ggrid)
            worst_grid, worst_sub = max(worst_grid, a), max(worst_sub, b)
        verdict = "dominated in every pool tried (consistent with mixable)" if worst_grid <= 1e-9 * B * B \
            else "some pool NOT dominated (not mixable)"
        say(f"  B={B:g} eta={c:g}/(2B^2): max over pools of [min_gamma max_y gap] = {worst_grid:+.3e}; "
            f"at Vovk's substitution: {worst_sub:+.3e} -> {verdict}")

# ---------------------------------------------------------------------------------------------------------------
# (2) aggregating-algorithm bound with prior weights 2^-k
# ---------------------------------------------------------------------------------------------------------------
say("")
say("(2) Aggregating algorithm, square loss on [-B, B], pool of K constant predictors, weights w_k ~ 2^-k")
B = 1.0
eta = 1 / (2 * B * B)
K = 40
preds = rng.uniform(-B, B, K)
w = 2.0 ** -np.arange(1, K + 1)
w = w / w.sum()
T = 2000
# outcomes: noisy around 0.37, clipped to [-B, B]
ys = np.clip(0.37 + 0.4 * rng.standard_normal(T), -B, B)
logw = np.log(w).copy()
L_aa = 0.0
L_k = np.zeros(K)
for y in ys:
    # substitution: g* = (G(-B) - G(B)) / (4B) with the current normalised weights
    wn = np.exp(logw - logw.max())
    wn = np.maximum(wn / wn.sum(), 1e-300)
    gm = G(np.array([-B]), preds, wn, eta)[0]
    gp = G(np.array([B]), preds, wn, eta)[0]
    gamma = (gm - gp) / (4 * B)
    L_aa += (y - gamma) ** 2
    lk = (y - preds) ** 2
    L_k += lk
    logw = logw - eta * lk
a = np.log(w) - eta * L_k
mix = -(a.max() + np.log(np.exp(a - a.max()).sum())) / eta
bounds = L_k + np.log(1 / w) / eta
say(f"  T={T}, K={K}: Loss(AA) = {L_aa:.4f}; mixture term -(1/eta) ln sum w_k e^(-eta L_k) = {mix:.4f}; "
    f"min_k [L_k + ln(1/w_k)/eta] = {bounds.min():.4f}; best expert loss = {L_k.min():.4f}")
say(f"  Loss(AA) <= mixture term: {L_aa <= mix + 1e-9}; mixture term <= every L_k + ln(1/w_k)/eta: "
    f"{bool(np.all(mix <= bounds + 1e-9))}")

# ---------------------------------------------------------------------------------------------------------------
# (3) CRPS: integral form = kernel form; the author's 5-values example
# ---------------------------------------------------------------------------------------------------------------
say("")
say("(3) CRPS (negatively oriented): integral form vs kernel form, discrete uniform forecasts")


def crps_kernel(vals, x):
    v = np.asarray(vals, float)
    return np.abs(v - x).mean() - 0.5 * np.abs(v[:, None] - v[None, :]).mean()


def crps_integral(vals, x):
    """exact: (F(t) - 1{t >= x})^2 is piecewise constant between the sorted points vals + [x]."""
    v = np.sort(np.asarray(vals, float))
    pts = np.sort(np.append(v, x))
    total = 0.0
    for a, b in zip(pts[:-1], pts[1:]):
        t = 0.5 * (a + b)
        F = np.searchsorted(v, t, side="right") / len(v)
        H = 1.0 if t >= x else 0.0
        total += (F - H) ** 2 * (b - a)
    return total


x = 0.0
near = [-2, -1, 0, 1, 2]
scattered = [-40, -17, 0, 23, 51]
for name, vals in (("nearby   ", near), ("scattered", scattered)):
    k = crps_kernel(vals, x)
    i = crps_integral(vals, x)
    logscore = -np.log2(1 / len(vals))
    say(f"  {name} {vals}: log score = {logscore:.4f} bits; CRPS kernel = {k:.6f}; CRPS integral = {i:.6f}; "
        f"|diff| = {abs(k - i):.2e}")

with open(__file__.replace(".py", ".out"), "w") as f:
    f.write("\n".join(out_lines) + "\n")
