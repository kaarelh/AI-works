"""Illustration (not evidence about asymptotics): the bounds of Section 6 at the
adaptive cutoff, for the tanh L=2 unit-gain kernel, with the unknown constants
set to A_delta in {1, 100}, C_delta = 1, C = 1, delta = 0.1, a = 1.

All quantities are per sample and in units of a^2/tau_r:
  prop62 = (1 - 10 tau_r/a^2) / (16 b_r + 4 C A_delta r H_r)    (Prop. obstruction)
  thmA   = delta * min{1/16, A_delta log(2 D_r)/(128 b_r)}       (Theorem A, without -log2/n)
  match  = 1/(b_r + r H_r)                                       (eq:matching with K=1)
  Kneed  = thmA/match   (the K that eq:matching would need to be compatible with Theorem A)
Route quantities (units a^2):
  headLB = 16 b_r * thmA     lower bound on the head estimate 8 tau + 16 b_r tau D/n
  clipLB = rho*sqrt(headLB)  lower bound on the clipped-parity output of the route
Spectral quantities: theta_r = W_{r+2}/sum_{odd j>=r+2} W_j, K' = n/C(D,r+2),
  n lambda_{r+1}/tau_r = theta_r K' (evaluated at the smallest n with cutoff r).
"""
import numpy as np
from scipy.special import gammaln
from spec import spectrum


def logbinom(n, k):
    return gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1)


def table(d, sp, Adel, Cdel=1.0, C=1.0, delta=0.1, a=1.0, rhos=(0.004, 0.008, 1 / 64, 0.03, 0.06)):
    D = d + 1
    W, A = sp['W'], sp['A']
    rows = []
    for rho in rhos:
        r = int(round(rho * d))
        if r % 2 == 0:
            r += 1
        if r < 1:
            continue
        ks = np.arange(0, r + 3)
        logDr = np.logaddexp.accumulate(logbinom(d, ks))
        H = np.log(np.e * D / r)
        tail = W[r + 2::2].sum()
        tau = A * tail
        theta = W[r + 2] / tail
        lognlo = np.log(Adel) + logDr[r] + np.log(np.log(2) + logDr[r])
        Kp = np.exp(lognlo - logbinom(D, r + 2))
        nlam_tau = theta * Kp
        b = Cdel * (1 + np.sqrt(d * r * H) + r * H)
        prop62 = (1 - 10 * tau / a ** 2) / (16 * b + 4 * C * Adel * r * H)
        thmA = delta * min(1 / 16, Adel * (np.log(2) + logDr[r]) / (128 * b))
        match = 1 / (b + r * H)
        headLB = 16 * b * thmA
        clipLB = (r / d) * np.sqrt(headLB)
        rows.append((d, r, r / d, tau, theta * np.sqrt(r), Kp, nlam_tau, prop62, thmA, thmA / prop62,
                     thmA / match, headLB, clipLB))
    return rows


if __name__ == "__main__":
    hdr = ("d", "r", "rho", "tau_r", "th*sqrt r", "K'=n/C", "n lam/tau", "prop62", "thmA", "A/62",
           "K_need", "headLB", "clipLB")
    out = []
    for d in [200, 400, 800, 1600, 3200]:
        sp = spectrum(d)
        for Adel in [1.0, 100.0]:
            out.append(f"--- d={d}  A_delta={Adel}  (A={sp['A']:.4f}, coefficient tail={sp['tail']:.1e})")
            out.append(" ".join(f"{h:>10s}" for h in hdr))
            for row in table(d, sp, Adel):
                out.append(" ".join(f"{v:10.3e}" if isinstance(v, float) else f"{v:10d}" for v in row))
    s = "\n".join(out)
    print(s)
