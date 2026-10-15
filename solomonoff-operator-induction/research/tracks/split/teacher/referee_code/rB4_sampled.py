"""rB4: sampled data (inputs without replacement, labels from the teacher y* = f_a xor 1_S(cell)) in
referee B's class K (rB3), to test the sampled claims of notes.md Prop 3.3 and the reporting of
t2(B) per sample rather than by medians and modes.

Instance: d = 14, m = 8, p = 1/16 (16 error cells of 256), as in t2(B), but a fresh (a, S) and fresh
samples (40 per n). For each sample:
  * the good model's lambda-set [tau_n, sigma_n] (true parity, any rate), and tau_n / (n 2^-m);
  * the mean and the largest multiplicity of the sampled error cells;
  * whether the lambda-MAP is the good model at lambda = 2, at lambda = 4 n 2^-m (c = 4 * 2^-m) and at
    lambda = 16 n 2^-m;
  * the family of the lambda-MAP just below tau_n (the right neighbour).
Notes' claims tested: "the fixed lambda = 2 keeps the good model in every sample up to n = 2^m = 256";
"lambda = 4 n 2^-m keeps it at every n >= 64"; "the lower end tracks the error cells' multiplicity".
Seeded: numpy default_rng(777).
"""
import math
import sys
from collections import Counter

import numpy as np

sys.dont_write_bytecode = True
from rBcommon import (delta_len, ceil_log2comb, rate_options, lambda_set, union_span, map_at, parity_table,
                      rate_len, bern_bits)

rng = np.random.default_rng(777)
TAG = 3


def wht(v):
    a = v.astype(np.float64).copy()
    h, n = 1, a.shape[0]
    while h < n:
        a = a.reshape(-1, 2 * h)
        x, y = a[:, :h].copy(), a[:, h:].copy()
        a[:, :h], a[:, h:] = x + y, x - y
        a = a.reshape(n)
        h *= 2
    return a


def build_sample(d, m, a, xs, ys, fa):
    N = 1 << d
    n = len(xs)
    pts = []

    def add(base, k, nn, desc, extra=0.0, below_half=True):
        for (rl, f, q) in rate_options(k, nn, below_half=below_half):
            pts.append((base + rl, f + extra, desc + (q,)))

    add(TAG, int(ys.sum()), n, ("A",), below_half=False)
    g = np.zeros(N)
    g[xs] = 1 - 2 * ys.astype(np.float64)
    dis = np.rint((n - wht(g)) / 2).astype(np.int64)
    add(TAG + d, int(dis[a]), n, ("B", a))
    dd = dis.copy()
    dd[a] = n + 1
    add(TAG + d, int(dd.min()), n, ("B", int(dd.argmin())))
    err = ys != fa[xs]
    n_err = int(err.sum())
    cell = xs >> (d - m)
    per = np.bincount(cell, minlength=1 << m)
    e_c = np.bincount(cell[err], minlength=1 << m)
    gain = np.sort(per - 2 * e_c)
    cum = np.concatenate([[0], np.cumsum(gain)])
    for j in range(0, (1 << m) + 1):
        if j > 0 and gain[j - 1] >= 0:
            break
        add(TAG + d + delta_len(m) + delta_len(j + 1) + ceil_log2comb(1 << m, j), n_err + int(cum[j]), n, ("C", j))
    for jp in range(0, d + 1):
        inside = (xs >> (d - jp)) == 0 if jp > 0 else np.ones(n, dtype=bool)
        n_in = int(inside.sum())
        k_in, k_out = int((inside & ~err).sum()), int((~inside & err).sum())
        fin = rate_options(k_in, n_in) if n_in > 0 else [(1, 0.0, 0.0)]
        fout = rate_options(k_out, n - n_in) if n - n_in > 0 else [(1, 0.0, 0.0)]
        for (r1, f1, q1) in fin:
            for (r2, f2, q2) in fout:
                pts.append((TAG + d + delta_len(jp + 1) + r1 + r2, f1 + f2, ("D", jp, q1, q2)))
    for j in range(0, n_err + 1):
        add(TAG + d + delta_len(j + 1) + ceil_log2comb(N, j), n_err - j, n, ("E", j))
    pts.append((TAG + N, 0.0, ("F",)))
    for v in range(1, d):
        sel = (xs & ((1 << v) - 1)) == 0
        nin = int(sel.sum())
        if nin == 0:
            pts.append((TAG + delta_len(v) + (d - v) + 2, float(n), ("G", v, 0.5)))
            continue
        hi = xs[sel] >> v
        gg = np.zeros(1 << (d - v))
        gg[hi] = 1 - 2 * ys[sel].astype(np.float64)
        dv = np.rint((nin - wht(gg)) / 2).astype(np.int64)
        add(TAG + delta_len(v) + (d - v), int(dv.min()), nin, ("G", v), extra=float(n - nin))
    return pts, err, cell, e_c


def main():
    d, m, r = 14, 8, 4
    N, p = 1 << d, 2.0 ** -r
    a = int(rng.integers(1, N))
    cells = np.zeros(1 << m, dtype=bool)
    cells[rng.choice(1 << m, size=1 << (m - r), replace=False)] = True
    allx = np.arange(N)
    fa = parity_table(a, d)
    ystar = (fa ^ cells[allx >> (d - m)].astype(np.int8)).astype(np.int8)
    is_good = lambda dsc: dsc[0] == "B" and dsc[1] == a
    print(f"d = {d}, m = {m}, p = 1/16, a = {a}, S = {[int(z) for z in np.flatnonzero(cells)]}; 40 samples per n")
    hdr = (f"{'n':>6} | {'tau_n: min':>10} {'median':>7} {'max':>7} | {'tau/(n2^-m)':>11} | {'sigma_n med':>11} | "
           f"{'err mult mean/max (med)':>23} | {'good@2':>6} {'good@4n/2^m':>11} {'good@16n/2^m':>12} | right neighbour (counts)")
    print(hdr)
    for e in range(5, 15):
        n = 1 << e
        rows = []
        for s in range(40):
            xs = np.sort(rng.choice(N, size=n, replace=False))
            ys = ystar[xs]
            pts, err, cell, e_c = build_sample(d, m, a, xs, ys, fa)
            span = union_span(lambda_set(pts, is_good))
            tau, sig = (span[0], span[1]) if span else (math.nan, math.nan)
            mult = e_c[e_c > 0]
            gm = lambda lam: any(is_good(v[3]) for v in map_at(pts, lam))
            if span:
                below = map_at(pts, tau * 0.995) if tau > 0 else []
                rn = sorted(set(v[3][0] for v in below if not is_good(v[3])))
                rn = "+".join(rn) if rn else "-"
            else:
                rn = "none(good never MAP)"
            rows.append((tau, sig, float(mult.mean()) if len(mult) else 0.0, int(mult.max()) if len(mult) else 0,
                         gm(2.0), gm(4 * n / 2 ** m), gm(16 * n / 2 ** m), rn))
        taus = np.array([r_[0] for r_ in rows])
        med = lambda j: float(np.nanmedian([r_[j] for r_ in rows]))
        fr = lambda j: sum(1 for r_ in rows if r_[j]) / len(rows)
        cnt = Counter(r_[7] for r_ in rows)
        print(f"{n:6d} | {np.nanmin(taus):10.3f} {np.nanmedian(taus):7.3f} {np.nanmax(taus):7.3f} | "
              f"{np.nanmedian(taus) / (n / 2 ** m):11.3f} | {med(1):11.2f} | {med(2):11.2f} / {med(3):9.0f} | "
              f"{fr(4):6.2f} {fr(5):11.2f} {fr(6):12.2f} | {dict(cnt)}")
    print("good@x = fraction of the 40 samples in which a lambda-MAP at lambda = x is the true parity (any rate).")
    print("right neighbour: family of the lambda-MAP just below tau_n (C = parity + rule cells, E = named inputs,")
    print("D = envelope); 'none' = the good model is not a lambda-MAP for any lambda in that sample.")


if __name__ == "__main__":
    main()
