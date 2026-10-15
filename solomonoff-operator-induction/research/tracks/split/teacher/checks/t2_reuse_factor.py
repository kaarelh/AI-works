"""t2: the lower end of the good model's lambda-interval is the reuse factor of the errors
(notes.md, Props 3.1-3.3). Exact hulls in an explicit prefix-coded product class.

Teacher: y* = f_a xor 1_E, E = S x {0,1}^(d-m), S a uniformly random subset of {0,1}^m of size
s0 = p 2^m, a uniform in {0,1}^d. Fits are total bits -log nu_pi(D) on the data set D.

Class (prefix codes, Kraft sum <= 1 by construction: 3-bit family tag, then a prefix code):
  F0 constant Bern(q);                         length 3 + RC(q)
  F1 parity a' with flip rate q;               length 3 + d + RC(q)
  F2 partial parity (first d-v coordinates of a', per-input mixture over the 2^v completions:
     prediction 1/2 unless the last v input bits are 0), rate q;   length 3 + g(v) + (d-v) + RC(q)
  F5 parity a' + rule T (j cells of {0,1}^m) : predicts f_a' xor 1_T with flip rate q;
     length 3 + d + g(m) + g(j) + ceil(log binom(2^m, j)) + RC(q)
  F3 parity a' + j named inputs (flipped) with rate q; length 3 + d + g(j) + ceil(log binom(2^d, j)) + RC(q)
  F4 the full lookup table on {0,1}^d;        length 3 + 2^d
  g(k) = 2 floor(log2(k+1)) + 1 (self-delimiting integer code, Kraft sum 1 over k >= 0);
  RC(q) = 1 for q = 0 (deterministic), else 1 + g(b) + (b-1) for q = j/2^b, j odd, b <= 12.
For each family and each length the least fit is computed exactly (the fit is convex in q, so the
best odd j at precision b is a neighbour of the empirical rate; the best T and the best named
inputs are the cells / inputs with the most errors), so the hull below is the exact hull of the class.

(A) Full truth tables, d = 10, p = 1/16, m in {10, 8, 6, 4}: the hull, the lambda-interval
    (tau, sigma) on which a lambda-MAP is 'parity a with noise' (F1 with a' = a), against the
    reuse factor 2^(d-m) (Prop 3.1).
(B) Sampled data, d = 14, m = 8, p = 1/16 (16 error cells of 256, 1024 error inputs): n inputs
    drawn uniformly without replacement, n = 2^5 .. 2^14, 20 seeds each. Reported per n (medians):
    the good model's interval (tau_n, sigma_n) in the explicit class; the secant of a covering
    fill-in (iid notes Lemma 5.2 length with kappa = 0, an assigned length, not a class member);
    tau_eff = max(tau_n, fill-in secant); the reuse statistics n/n' (n' = distinct cells hit),
    the mean and maximum multiplicity of the sampled error cells, n 2^-m; the full-memoriser
    secant; and the lambda-MAP family at lambda = 2 and at lambda = 4 n 2^-m.
Seeded: numpy default_rng(32).
"""
import math
import numpy as np

rng = np.random.default_rng(32)
from tcommon import (TAG, BMAX, LOG2, gam, log2binom, rc_len, bern_fit, best_rate_fits, wht,
                     parity_table, Hull, add_rate_family)


def build_class(d, m, a, S, xs, ys, with_F4=True):
    """exact hull of the class on the data set {(x, y)}; xs are distinct inputs in {0,1}^d."""
    N = 2 ** d
    n = len(xs)
    hull = Hull()
    ones = int(ys.sum())
    # F0
    add_rate_family(hull, TAG, ones, n, ("F0",))
    # F1: all parities via WHT
    g = np.zeros(N)
    g[xs] = 1 - 2 * ys.astype(np.float64)
    W = wht(g)
    dis = np.rint((n - W) / 2).astype(np.int64)  # disagreements of each parity a'
    # for each rate precision the best a' is the one with fewest (or most) disagreements
    k_true = int(dis[a])
    add_rate_family(hull, TAG + d, k_true, n, ("F1", a))  # first, so that ties keep the true parity
    for kk, a_arg in [(int(dis.min()), int(dis.argmin())), (int(dis.max()), int(dis.argmax()))]:
        add_rate_family(hull, TAG + d, kk, n, ("F1", a_arg))
    # F2: partial parities
    for v in range(1, d):
        low = xs & ((1 << v) - 1)  # the last v bits: low-order bits are the 'rest'
        sel = low == 0
        n_in = int(sel.sum())
        n_out = n - n_in
        if n_in == 0:
            hull.add(TAG + gam(v) + (d - v) + rc_len(1), float(n_out), ("F2", v, None, 0.5))
            continue
        hi_x = xs[sel] >> v
        gg = np.zeros(2 ** (d - v))
        gg[hi_x] = 1 - 2 * ys[sel].astype(np.float64)
        Wv = wht(gg)
        disv = np.rint((n_in - Wv) / 2).astype(np.int64)
        kk = int(disv.min())
        for (rl, f, q) in best_rate_fits(kk, n_in):
            hull.add(TAG + gam(v) + (d - v) + rl, f + n_out, ("F2", v, int(disv.argmin()), q))
    # error inputs among the data (relative to the true parity a)
    fa = parity_table(a, d)
    err = ys != fa[xs]
    n_err = int(err.sum())
    # F5: parity a + j rule cells (the j cells with the most sampled errors)
    cell = xs >> (d - m)  # the first m bits are the high-order bits
    cnt = np.bincount(cell[err], minlength=2 ** m)
    top = np.sort(cnt)[::-1]
    cum = np.concatenate([[0], np.cumsum(top)])
    for j in range(0, len(S) + 1):
        kk = n_err - int(cum[j])
        base = TAG + d + gam(m) + gam(j) + math.ceil(log2binom(2 ** m, j))
        add_rate_family(hull, base, kk, n, ("F5", j))
    # F3: parity a + j named error inputs
    for j in sorted(set([0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, n_err] + list(range(0, min(n_err, 64) + 1)))):
        if j > n_err:
            continue
        base = TAG + d + gam(j) + math.ceil(log2binom(N, j))
        add_rate_family(hull, base, n_err - j, n, ("F3", j))
    if with_F4:
        hull.add(TAG + N, 0.0, ("F4",))
    return hull, dict(n_err=n_err, cnt=cnt, k_true=k_true)


def is_good(desc, a):
    return desc[0] == "F1" and desc[1] == a


def part_A():
    print("=" * 100)
    print("(A) full truth tables, d = 10, p = 1/16: the good model's lambda-interval vs the reuse factor 2^(d-m)")
    d, r = 10, 4
    N = 2 ** d
    for m in [10, 8, 6, 4]:
        s0 = 2 ** (m - r)
        for rep in range(2):
            a = int(rng.integers(1, N))
            S = np.sort(rng.choice(2 ** m, size=s0, replace=False))
            xs = np.arange(N)
            inS = np.isin(xs >> (d - m), S)
            ys = (parity_table(a, d) ^ inS.astype(np.int8)).astype(np.int8)
            hull, info = build_class(d, m, a, S, xs, ys)
            hull.build()
            iv = hull.union_interval(lambda desc: is_good(desc, a))
            ivs = (f"({iv[0]:.3f}, {iv[1]:.2f})" if iv is not None
                   else "empty: the good model is not a vertex (the error rule's rate exceeds the model's)")
            print(f"  m={m:2d} s0={s0:3d} |E|={info['n_err']:4d} rep={rep}: hull has {len(hull.V)} vertices; "
                  f"good model's lambda-interval = {ivs}; reuse factor 2^(d-m) = {2 ** (d - m)}")
            if rep == 0 or iv is None:
                for i, (l, f, desc) in enumerate(hull.V):
                    lo, hi = hull.interval(i)
                    print(f"      v{i}: l={l:5d} fit={f:9.2f} lambda in ({lo:9.4g}, {hi:9.4g})  {desc}")


def part_B():
    print("=" * 100)
    print("(B) sampled data, d = 14, m = 8, p = 1/16 (16 of 256 cells are errors): medians over 20 samples")
    d, m, r = 14, 8, 4
    N, s0 = 2 ** d, 2 ** (m - r)
    p = 2.0 ** -r
    a = int(rng.integers(1, N))
    S = np.sort(rng.choice(2 ** m, size=s0, replace=False))
    allx = np.arange(N)
    inS_all = np.isin(allx >> (d - m), S)
    ystar = (parity_table(a, d) ^ inS_all.astype(np.int8)).astype(np.int8)
    LS = log2binom(2 ** m, s0)
    lg = TAG + d + rc_len(r)  # the good model F1(a, q = p): b = r, j = 1
    lmem = TAG + d + gam(m) + gam(s0) + math.ceil(LS) + 1
    print(f"  a={a}, S={[int(z) for z in S]}; L_S={LS:.2f}; good model length {lg}; full memoriser length {lmem}")
    hdr = (f"  {'n':>6} | {'tau_n':>7} {'sigma_n':>8} | {'fill sec':>8} {'tau_eff':>8} | {'n/n_cells':>9} "
           f"{'err mult':>8} {'max mult':>8} {'n 2^-m':>7} | {'mem sec':>8} | {'MAP@2':>6} {'MAP@4n/2^m':>10} {'good@2':>6}")
    print(hdr)
    for e in range(5, 15):
        n = 2 ** e
        rows = []
        for s in range(20):
            xs = np.sort(rng.choice(N, size=n, replace=False))
            ys = ystar[xs]
            hull, info = build_class(d, m, a, S, xs, ys, with_F4=False)
            hull.build()
            iv = hull.union_interval(lambda desc: is_good(desc, a))
            tau_n, sig_n = (iv if iv is not None else (math.nan, math.nan))
            # good model's fit and the covering fill-in (iid Lemma 5.2, kappa = 0)
            k = info["n_err"]
            Fg = bern_fit(k, n, p)
            R = math.ceil(Fg)
            lfill = lg + R + 3 * math.log2(n + 1) + 3 * math.log2(d + 3) + 2 * math.log2(R + 1)
            fill_sec = Fg / (lfill - lg)
            cells = xs >> (d - m)
            ncell = len(np.unique(cells))
            errcells = info["cnt"][info["cnt"] > 0]
            mult = float(errcells.mean()) if len(errcells) else 0.0
            maxm = int(errcells.max()) if len(errcells) else 0
            mem_sec = Fg / (lmem - lg)
            m2 = hull.map_at(2.0)[2][0]
            mc = hull.map_at(4 * n / 2 ** m)[2][0]
            good2 = is_good(hull.map_at(2.0)[2], a)
            rows.append((tau_n, sig_n, fill_sec, max(tau_n, fill_sec), n / ncell, mult, maxm, n / 2 ** m, mem_sec, m2, mc, good2))
        med = lambda j: float(np.nanmedian([row[j] for row in rows]))
        mode = lambda j: max(set(row[j] for row in rows), key=[row[j] for row in rows].count)
        fr = sum(row[11] for row in rows) / len(rows)
        print(f"  {n:6d} | {med(0):7.3f} {med(1):8.2f} | {med(2):8.3f} {med(3):8.3f} | {med(4):9.3f} "
              f"{med(5):8.2f} {med(6):8.0f} {med(7):7.3f} | {med(8):8.3f} | {mode(9):>6} {mode(10):>10} {fr:6.2f}")
    print("  columns: tau_n, sigma_n = good model's lambda-interval in the explicit class; fill sec = secant from the")
    print("  good model to a covering fill-in (assigned length); tau_eff = max(tau_n, fill sec); n/n_cells = samples per")
    print("  distinct cell hit; err mult / max mult = mean / max number of sampled inputs in a sampled error cell;")
    print("  mem sec = secant to the full rule memoriser; MAP@x = family of the lambda-MAP (mode over samples) in the")
    print("  explicit class; good@2 = fraction of samples whose 2-MAP is F1 with the true parity.")


if __name__ == "__main__":
    part_A()
    part_B()
