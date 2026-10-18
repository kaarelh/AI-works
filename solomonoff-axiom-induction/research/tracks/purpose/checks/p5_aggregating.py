"""p5_aggregating.py -- track `purpose`, target T5: mixability constants and the aggregating algorithm (AA) with
prefix-code weights.

Seed 20261017.  Writes p5_aggregating.out next to itself.

  A. Square loss (gamma - omega)^2 with outcomes omega in [-B, B]: eta-mixability means that for every distribution pi
     over predictions there is gamma with (gamma - omega)^2 <= g_pi(omega) := -(1/eta) ln E_pi exp(-eta (gamma' - omega)^2)
     for all omega in [-B, B].  For eta = c / B^2 we search for violating pi (two- and three-point, numerical
     optimisation of the infeasibility margin over an omega grid) and check Vovk's substitution
     gamma* = (g(-B) - g(B)) / (4B) at c = 1/2.  Expected: mixable iff c <= 1/2, i.e. eta <= 1/(2 B^2).
  B. Absolute loss on outcomes {0, 1}: for pi = (delta_0 + delta_1)/2, g(0) + g(1) < 1 for every eta > 0, so no gamma
     works (not mixable); the numbers.
  C. AA with weights w_k = 2^-l(k) (l = Elias-gamma code length of k + 1) over a countable family of point predictors,
     square loss, eta = 1/(2 B^2): the bound L_AA <= L_k + l(k) ln 2 / eta is checked for every k on random and
     adversarial-looking sequences; and the toy laws A, B of p4_toy.py as experts: AA under square loss concentrates on
     A, Bayes (log loss on fine cells) on B.
"""
import math
import os

import numpy as np
from scipy import optimize

SEED = 20261017
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def g_pi(pts, w, eta, om):
    # -(1/eta) ln sum_i w_i exp(-eta (pts_i - om)^2), stable
    a = -eta * (pts[None, :] - om[:, None]) ** 2
    m = a.max(axis=1, keepdims=True)
    return -(m[:, 0] + np.log(np.sum(w[None, :] * np.exp(a - m), axis=1))) / eta


def infeasibility(pts, w, eta, B, om):
    g = g_pi(pts, w, eta, om)
    r = np.sqrt(np.maximum(g, 0.0))
    return float(np.max(om - r) - np.min(om + r))     # > 0 means no gamma works


def partA(rng):
    out("\n== A. square loss on [-B, B], B = 1, eta = c / B^2: largest infeasibility margin found over pi (>0 = violation)")
    B = 1.0
    om = np.linspace(-B, B, 4001)
    for c in (0.40, 0.50, 0.505, 0.52, 0.55, 0.60, 0.70):
        eta = c / B ** 2
        best = -1e9

        def neg(x, k):
            pts = np.clip(x[:k], -B, B)
            ww = np.exp(x[k:])
            ww = ww / ww.sum()
            return -infeasibility(pts, ww, eta, B, om)
        for k in (2, 3):
            for _ in range(30):
                x0 = np.concatenate([rng.uniform(-B, B, k), rng.normal(0, 1.5, k)])
                r = optimize.minimize(neg, x0, args=(k,), method="Nelder-Mead",
                                      options={"xatol": 1e-9, "fatol": 1e-12, "maxiter": 4000})
                best = max(best, -r.fun)
        out("   c = %.3f: max infeasibility margin %+.3e" % (c, best))
    # Vovk's substitution at c = 1/2 on random pi
    eta = 0.5
    worst = -1e9
    for _ in range(2000):
        k = rng.integers(1, 6)
        pts = rng.uniform(-B, B, k)
        ww = rng.dirichlet(np.ones(k))
        g = g_pi(pts, ww, eta, om)
        gm, gp = g_pi(pts, ww, eta, np.array([-B, B]))
        gam = (gm - gp) / (4 * B)
        worst = max(worst, float(np.max((gam - om) ** 2 - g)))
    out("   c = 0.5, substitution gamma = (g(-B) - g(B))/(4B), 2000 random pi: max over omega of (gamma-omega)^2 - g(omega)"
        " = %+.3e (<= 0 up to rounding means the substitution works)" % worst)


def partB():
    out("\n== B. absolute loss, outcomes {0,1}, pi = (delta_0 + delta_1)/2: need gamma <= g(0) and 1 - gamma <= g(1)")
    for eta in (0.01, 0.1, 1.0, 10.0, 100.0):
        g = -math.log(0.5 * (1 + math.exp(-eta))) / eta
        out("   eta = %7.2f: g(0) + g(1) = %.6f < 1" % (eta, 2 * g))


def elias_gamma_len(n):          # n >= 1
    return 2 * int(math.floor(math.log2(n))) + 1


def aa_square(preds, ys, w, eta, B):
    """AA for square loss on [-B, B] with Vovk's substitution; preds: (T, K) expert predictions in [-B, B]."""
    T, K = preds.shape
    logw = np.log(w)
    L_aa = 0.0
    L = np.zeros(K)
    for t in range(T):
        p = preds[t]
        lw = logw - eta * L
        m = lw.max()
        ww = np.exp(lw - m)
        ww /= ww.sum()
        gm = -np.log(np.sum(ww * np.exp(-eta * (p + B) ** 2))) / eta
        gp = -np.log(np.sum(ww * np.exp(-eta * (p - B) ** 2))) / eta
        gam = (gm - gp) / (4 * B)
        L_aa += (gam - ys[t]) ** 2
        L += (p - ys[t]) ** 2
    return L_aa, L


def partC(rng):
    out("\n== C. AA with prefix-code weights w_k = 2^-l(k), square loss on [-B, B], B = 1, eta = 1/(2 B^2) = 0.5")
    B, eta = 1.0, 0.5
    K = 200
    w = np.array([2.0 ** -elias_gamma_len(k + 1) for k in range(K)])
    out("   sum of weights over the first %d experts: %.4f (<= 1, Kraft)" % (K, w.sum()))
    T = 3000
    for name in ("random walk", "alternating extremes", "noisy constant 0.37"):
        if name == "random walk":
            ys = np.clip(np.cumsum(rng.normal(0, 0.05, T)), -B, B)
        elif name == "alternating extremes":
            ys = np.where(np.arange(T) % 2 == 0, B, -B).astype(float)
        else:
            ys = np.clip(0.37 + 0.2 * rng.normal(size=T), -B, B)
        # experts: constant predictors c_k on a grid, and 'previous outcome' predictors with shrinkage
        consts = np.linspace(-B, B, K // 2)
        prev = np.concatenate([[0.0], ys[:-1]])
        shr = np.linspace(0, 1, K - K // 2)
        preds = np.concatenate([np.tile(consts, (T, 1)), prev[:, None] * shr[None, :]], axis=1)
        L_aa, L = aa_square(preds, ys, w, eta, B)
        slack = L + np.log(1 / w) / eta - L_aa
        kbest = int(np.argmin(L))
        out("   %-22s L_AA = %9.3f; best expert k=%3d L = %9.3f (bound %9.3f); min over k of (L_k + ln(1/w_k)/eta - L_AA)"
            " = %+.4f (>= 0: bound holds for all k)" % (name, L_AA if False else L_aa, kbest, L[kbest],
                                                       L[kbest] + math.log(1 / w[kbest]) / eta, float(slack.min())))

    out("\n   toy laws of p4_toy.py as experts (truth q_t uniform on [-1000, 1000]; outcomes and predictions in [-B, B],")
    out("   B = 1002): A predicts q_t + U[-1,1]; B predicts q_t exactly w.p. 0.8, q_t +- 1000 otherwise (clipped)")
    B = 1002.0
    eta = 1 / (2 * B * B)
    T = 4000
    q = rng.uniform(-1000, 1000, T)
    eA = rng.uniform(-1, 1, T)
    sB = rng.random(T)
    eB = np.where(sB < 0.1, -1000.0, np.where(sB < 0.2, 1000.0, 0.0))
    pA = np.clip(q + eA, -B, B)
    pB = np.clip(q + eB, -B, B)
    preds = np.stack([pA, pB], axis=1)
    w = np.array([0.5, 0.5])
    L_aa, L = aa_square(preds, q, w, eta, B)
    out("   square loss: L_A = %.1f, L_B = %.4g, L_AA = %.1f (bound L_A + ln 2/eta = %.4g); final AA weight on A: %.6f" % (
        L[0], L[1], L_aa, L[0] + math.log(2) / eta, 1 / (1 + math.exp(-eta * (L[1] - L[0])))))
    # log loss on fine cells of width Delta: the calibrated forecasts of A and B (their error laws), Bayes posterior
    for Delta in (0.1, 1.0, 1.5, 2.0):
        # A: cell probability for its uniform error model, averaged exactly is the rate of p4_toy; here per datum
        # with a random dither: P_A(cell) = |cell cap [q + eA - 1, q + eA + 1]| / 2 ; P_B(cell) = sum of atom masses
        u = rng.uniform(0, Delta, T)
        lo = np.floor((q + u) / Delta) * Delta - u
        hi = lo + Delta
        cA = np.clip(np.minimum(hi, pA + 1) - np.maximum(lo, pA - 1), 0, None) / 2.0
        mB = np.zeros(T)
        for off, pr in ((0.0, 0.8), (1000.0, 0.1), (-1000.0, 0.1)):
            v = (q + eB) - off            # B's forecast atoms: f_B - e for e in {0, +-1000} with these masses
            mB += pr * ((v >= lo) & (v < hi))
        LA_log = float(np.sum(-np.log2(np.maximum(cA, 1e-300))))
        LB_log = float(np.sum(-np.log2(np.maximum(mB, 1e-300))))
        out("   log loss on dithered cells, Delta = %.1f: A %.1f bits, B %.1f bits; Bayes posterior odds B:A = 2^%.1f" % (
            Delta, LA_log, LB_log, LA_log - LB_log))


def main():
    rng = np.random.default_rng(SEED)
    out("# p5_aggregating.py seed=%d numpy %s" % (SEED, np.__version__))
    partA(rng)
    partB()
    partC(rng)
    out("\n# done")
    with open(os.path.join(HERE, "p5_aggregating.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
