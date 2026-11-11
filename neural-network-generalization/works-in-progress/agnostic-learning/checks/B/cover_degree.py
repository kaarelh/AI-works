"""ln|H_{K,a}| from paper.tex (Lemma compression + Proposition energy-cover, cube version of Remark cube):
 r = min{1, a sqrt(d)/(8 K^{L/2})},  s <= (1+2 sqrt(d)/r)^d,  D_T = max{1, ceil(log2 s)},
 lambda = a 2^{-L} K^{-(L-1)/2} / (4(L-1)),
 J = max{ceil(4K), ceil(256 lambda^{-4} [D_T + ln(L/lambda)])},
 Delta = a / (4(d+L+1)(2J^2)^L),  P = J(d+1) + (L-2)J^2 + J,  ln|H| <= P ln(1 + 2(J+1)/Delta).
All computed in log-space (the numbers overflow floats). Prints local log-log slopes in K and in 1/a."""
import math

def lnH(K, a, d, L):
    r = min(1.0, a * math.sqrt(d) / (8 * K ** (L / 2)))
    log2s = d * math.log2(1 + 2 * math.sqrt(d) / r)
    DT = max(1, math.ceil(log2s))
    lam = a * 2.0 ** (-L) * K ** (-(L - 1) / 2) / (4 * (L - 1))
    J = max(math.ceil(4 * K), math.ceil(256 * lam ** -4 * (DT + math.log(L / lam))))
    lnDelta = math.log(a) - math.log(4 * (d + L + 1)) - L * math.log(2 * J * J)
    lncount = math.log(2 * (J + 1)) - lnDelta              # ln(2(J+1)/Delta); the +1 is negligible
    P = J * (d + 1) + (L - 2) * J * J + J
    return P * lncount, J, P


def log_lnH(lnK, lna, d, L):
    """ln(ln|H_{K,a}|) computed entirely in log space (for huge K)."""
    import numpy as np
    sp = lambda u: float(np.logaddexp(0.0, u))              # ln(1+e^u)
    logr = min(0.0, lna + 0.5 * math.log(d) - math.log(8) - (L / 2) * lnK)
    log2s = d * sp(math.log(2 * math.sqrt(d)) - logr) / math.log(2)
    DT = max(1.0, math.ceil(log2s))
    lnlam = lna - L * math.log(2) - ((L - 1) / 2) * lnK - math.log(4 * (L - 1))
    lnJ = max(math.log(4) + lnK, math.log(256) - 4 * lnlam + math.log(DT + math.log(L) - lnlam))
    lnDelta = lna - math.log(4 * (d + L + 1)) - L * (math.log(2) + 2 * lnJ)
    lncount = sp(math.log(2) + lnJ - lnDelta)               # ln(1 + 2J/Delta) (J+1 ~ J)
    lnP = lnJ + (float(np.logaddexp(math.log(d + 2), math.log(L - 2) + lnJ)) if L > 2 else math.log(d + 2))
    return lnP + math.log(lncount)


if __name__ == "__main__":
  d = 10
  for L in [2, 3, 4]:
      print(f"L={L}, d={d}:   predicted leading degree in K: {2 if L == 2 else 4*(L-1)},  in 1/a: {4 if L == 2 else 8}")
      a = 0.05
      prev = None
      for K in [1e1, 1e2, 1e3, 1e4, 1e5, 1e6]:
          v, J, P = lnH(K, a, d, L)
          s = "" if prev is None else f"  local slope dln(lnH)/dlnK = {(math.log(v)-math.log(prev))/math.log(10):.3f}"
          print(f"   K={K:8.0e}  a={a}:  J={J:.3e}  P={P:.3e}  ln|H|={v:.3e}{s}")
          prev = v
      K = 100.0; prev = None
      for a in [0.1, 0.01, 0.001, 0.0001]:
          v, J, P = lnH(K, a, d, L)
          s = "" if prev is None else f"  local slope dln(lnH)/dln(1/a) = {(math.log(v)-math.log(prev))/math.log(10):.3f}"
          print(f"   K={K:8.0e}  a={a:6.0e}:  ln|H|={v:.3e}{s}")
          prev = v
