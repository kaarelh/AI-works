"""Accuracy of the tanh (L=2, unit gain) Hermite coefficients c_m used by spec.py.

spec.py integrates I_m = int_0^inf w^m e^{-w^2/2}/sinh(pi w/2) dw by a log-space trapezoid rule
whose log sinh uses log1p(-exp(-2x)).  Near w = 0 (which matters only for small m) this loses
relative accuracy to cancellation.  Here the same rule is run with log(-expm1(-2x)) instead
("tight"), and both are compared with 40-digit mpmath quadrature.  spec.py itself is unchanged,
because other scripts import it; its error (about 4e-10 relative, at m = 1 only) is far below
anything that matters.

Also: the mass beyond m = 4001 is estimated from the decay of log c_m.
"""
import numpy as np
import mpmath as mp
from scipy.special import gammaln, logsumexp
import spec


def log_Im_tight(m, sigma=1.0, npts=None):
    if npts is None:
        npts = 200001 if m < 50 else 6001
    ws = (-np.pi / 2 + np.sqrt(np.pi ** 2 / 4 + 4 * sigma ** 2 * m)) / (2 * sigma ** 2)
    lo = max(1e-12, ws - 40.0 / sigma)
    hi = ws + 40.0 / sigma
    w = np.linspace(lo, hi, npts)
    x = np.pi * w / 2
    logsinh = x + np.log(-np.expm1(-2 * x)) - np.log(2.0)
    lf = m * np.log(w) - sigma ** 2 * w ** 2 / 2 - logsinh
    dw = w[1] - w[0]
    wts = np.full(npts, np.log(dw))
    wts[0] += np.log(0.5)
    wts[-1] += np.log(0.5)
    return logsumexp(lf + wts)


v = spec.v_tanh(1.0)
mmax = 4001
lc_spec, _ = spec.log_coeffs(mmax)
lc_tight = np.full(mmax + 1, -np.inf)
for m in range(1, mmax + 1, 2):
    lc_tight[m] = 2 * log_Im_tight(m) - gammaln(m + 1) - np.log(v)

mp.mp.dps = 40
vm = mp.quad(lambda z: mp.tanh(z) ** 2 * mp.e ** (-z ** 2 / 2), [-mp.inf, 0, mp.inf]) / mp.sqrt(2 * mp.pi)
print(f"v: hermegauss(200) = {v:.17g},  mpmath = {mp.nstr(vm, 20)},  rel diff = {float((v - vm) / vm):.1e}")
print(" m   relerr(spec.py c_m)   relerr(tight c_m)    [vs 40-digit mpmath]")
for m in [1, 3, 5, 11, 101, 1001, 2001]:
    f = lambda w: w ** m * mp.e ** (-w ** 2 / 2) / mp.sinh(mp.pi * w / 2)
    sm = mp.sqrt(m)
    I = mp.quad(f, [0, sm / 2, sm, 2 * sm + 10, mp.inf])
    lcm = 2 * mp.log(I) - mp.loggamma(m + 1) - mp.log(vm)
    e_spec = float(mp.e ** (mp.mpf(lc_spec[m]) - lcm) - 1)
    e_tight = float(mp.e ** (mp.mpf(lc_tight[m]) - lcm) - 1)
    print(f"{m:4d}   {e_spec: .2e}            {e_tight: .2e}")

s_spec = np.exp(lc_spec).sum()
s_tight = np.exp(lc_tight).sum()
print(f"sum_(m<=4001) c_m:  spec.py = 1 - {1 - s_spec:.2e},   tight = 1 - {1 - s_tight:.2e}")
print(f"c_1: spec.py = {np.exp(lc_spec[1]):.15f}, tight = {np.exp(lc_tight[1]):.15f}, "
      f"(spec - tight)/tight = {np.exp(lc_spec[1] - lc_tight[1]) - 1:.2e}")
print(f"spec.py shortfall attributable to c_1: {np.exp(lc_tight[1]) - np.exp(lc_spec[1]):.2e}")
# decay of log c_m: fit log c_m ~ alpha - beta sqrt(m) on m in [3001, 4001]
ms = np.arange(3001, 4002, 2)
beta, alpha = np.polyfit(np.sqrt(ms), lc_tight[ms], 1)
beta = -beta
print(f"log c_m ~ {alpha:.2f} - {beta:.4f} sqrt(m) on [3001,4001];  log c_4001 = {lc_tight[4001]:.1f}")
M = 4001
# sum_{odd m > M} e^{alpha - beta sqrt m} <= (1/2) int_M^inf e^{alpha-beta sqrt x} dx = e^alpha (1+beta sqrt M) e^{-beta sqrt M}/beta^2
log_tail = alpha + np.log1p(beta * np.sqrt(M)) - beta * np.sqrt(M) - 2 * np.log(beta)
print(f"estimated mass beyond m = 4001: about 10^{log_tail / np.log(10):.0f}")
