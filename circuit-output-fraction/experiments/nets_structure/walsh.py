"""Walsh-Fourier spectrum of f on {-1,+1}^d (d <= 24, exact).

f(x) = sum_S fhat(S) chi_S(x). Records, for each net:
  * W_k = sum_{|S| = k} fhat(S)^2 for k = 0..d (spectral weight by degree; the
    variance of f is sum_{k >= 1} W_k),
  * the participation ratio PR = (sum_{S != 0} fhat^2)^2 / sum_{S != 0} fhat^4 (the
    effective number of characters carrying the variance) and the largest
    single share max fhat^2 / Var f,
  * the exact correlation function rho(h) = Corr(f(x), f(y)) for |x - y| = h,
    rho(h) = sum_k W_k K_k(h) / C(d,h) / Var f with K_k the Krawtchouk polynomial,
  * the even/odd split (odd degrees = odd part of f),
  * the exact cumulants of f and those of the "presumption of independence in
    the Walsh basis" model sum_S fhat(S) eps_S with independent signs eps_S
    (kappa_4 = -2 sum fhat^4, odd cumulants 0).

usage: python3 walsh.py [name ...]   (default: the d = 24 suite nets)
"""

import math
import sys

import numpy as np

from common import all_f, save_json, suite, suite_net


def fwht(a):
    """In-place normalised Walsh-Hadamard transform (index bit i <-> x_i)."""
    n = a.shape[0]
    h = 1
    while h < n:
        a = a.reshape(-1, 2, h)
        x, y = a[:, 0, :].copy(), a[:, 1, :]
        a[:, 0, :] = x + y
        a[:, 1, :] = x - y
        a = a.reshape(n)
        h *= 2
    return a / n


def krawtchouk(d):
    """K[k, h] = sum_{|S|=k} chi_S(x) chi_S(y) for |x - y| = h."""
    K = np.zeros((d + 1, d + 1))
    for h in range(d + 1):
        for k in range(d + 1):
            K[k, h] = sum((-1) ** j * math.comb(h, j) * math.comb(d - h, k - j) for j in range(0, min(h, k) + 1))
    return K


def spectrum(f, d):
    fh = fwht(f.copy())
    # bit i of index S set <-> -1 ... sign convention irrelevant for squares
    # (all_inputs uses bit 1 -> x = +1, so the transform gives fhat up to signs)
    deg = np.zeros(len(fh), dtype=np.int64)
    idx = np.arange(len(fh), dtype=np.int64)
    for i in range(d):
        deg += (idx >> i) & 1
    sq = fh * fh
    W = np.bincount(deg, weights=sq, minlength=d + 1)
    var = W[1:].sum()
    sq0 = sq.copy()
    sq0[0] = 0
    pr = var ** 2 / (sq0 ** 2).sum()
    K = krawtchouk(d)
    rho = [sum(W[k] * K[k, h] / math.comb(d, k) for k in range(1, d + 1)) / var for h in range(d + 1)]
    kappa4_poi = -2 * (sq0 ** 2).sum()
    order = np.argsort(sq0)[::-1][:10]
    top = [dict(deg=int(deg[i]), share=float(sq0[i] / var)) for i in order]
    return W, var, pr, rho, kappa4_poi, top, float(sq0.max() / var)


def main():
    names = sys.argv[1:] or [r["name"] for r in suite() if r["d"] <= 24]
    rows = []
    for name in names:
        net = suite_net(name)
        d = net.d
        f = all_f(net)
        mu, sd = f.mean(), f.std()
        y = (f - mu) / sd
        k3, k4 = float((y ** 3).mean()), float((y ** 4).mean() - 3)
        W, var, pr, rho, k4poi, top, maxshare = spectrum(f, d)
        odd = float(W[1::2].sum() / var)
        mean_deg = float((np.arange(d + 1)[1:] * W[1:]).sum() / var)
        row = dict(name=name, d=d, mean=float(mu), var=float(var), W=(W / var).tolist(), W0=float(W[0]),
                   mean_degree=mean_deg, odd_share=odd, participation=float(pr), max_share=maxshare,
                   rho=rho, skew=k3, exkurt=k4, exkurt_poi_walsh=float(k4poi / var ** 2), top=top)
        rows.append(row)
        print(name, "mean deg %.2f" % mean_deg, "odd %.3f" % odd, "PR %.0f" % pr, "max share %.4f" % maxshare,
              "W1..6", np.round(W[1:7] / var, 3), "rho1..4", np.round(rho[1:5], 3), "exkurt %.3f (PoI %.4f)" % (k4, k4poi / var ** 2),
              flush=True)
        save_json(rows, "walsh.json")


if __name__ == "__main__":
    main()
