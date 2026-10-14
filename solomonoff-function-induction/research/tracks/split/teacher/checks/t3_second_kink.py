"""t3: structured errors create a second kink (notes.md, Section 4). Exact hulls on full truth tables
in an explicit prefix-coded product class (tcommon.py), extended by error envelopes.

Teacher: y* = f_a xor 1_E, E = S x {0,1}^(d-m), S = S1 u S2 with S1 = {z : first j bits of z are 0}
(a cheap subcube of 2^(m-j) cells) and S2 a uniformly random set of cells outside the 16-cell
zero subcube {z : first 4 bits 0} (so that S1 is the only cheap part).
Families (3-bit tag, then a prefix code; Kraft sum <= 1 by construction):
  F0, F1, F2, F5, F3, F4 as in t2 (constant, parity, partial parity, parity + named rule cells,
  parity + named inputs, full table);
  F6 envelope: parity a' + j' (g(j')) + RC(q_in) + RC(q_out): predicts f_a' xor 1 with flip rate
     q_in on the cells of the zero subcube {z : first j' bits 0}, and f_a' with flip rate q_out elsewhere;
  F7 envelope + named cells: parity a' + j' + jj (g(jj)) + index of jj cells outside the subcube
     (ceil(log binom(2^m - 2^(m-j'), jj))) + RC(q): predicts f_a' xor 1 on the subcube and the jj
     cells, rate q everywhere.
(A) d = 12, m = 8, p = 1/16 (16 error cells), |S1| = 0, 2, 4, 8, 16: the hull, the lambda-intervals
    of the good model (F1 with the true parity), of the envelope (F6/F7 with the true parity) and of
    the rule memoriser; the product structure function rho(alpha) at selected alpha.
(B) Rate blindness in the class: a fixed cheap rule (m = 5, S = 4 random cells, p = 1/8), d = 5..16:
    is the good model a vertex, and the model's secant (coin -> good model) against the rule's secant
    (good model -> rule memoriser).
Seeded: numpy default_rng(33).
"""
import math
import numpy as np
from tcommon import (TAG, gam, log2binom, rc_len, bern_fit, best_rate_fits, wht, parity_table, Hull,
                     add_rate_family)

rng = np.random.default_rng(33)


def build(d, m, a, cells_err):
    """exact hull on the full truth table; cells_err = boolean array over {0,1}^m (the rule S)."""
    N = 2 ** d
    xs = np.arange(N)
    cell = xs >> (d - m)
    fa = parity_table(a, d)
    ys = (fa ^ cells_err[cell].astype(np.int8)).astype(np.int8)
    n = N
    hull = Hull()
    add_rate_family(hull, TAG, int(ys.sum()), n, ("F0",))
    g = 1 - 2 * ys.astype(np.float64)
    W = wht(g)
    dis = np.rint((n - W) / 2).astype(np.int64)
    add_rate_family(hull, TAG + d, int(dis[a]), n, ("F1", a))
    for kk, arg in [(int(dis.min()), int(dis.argmin())), (int(dis.max()), int(dis.argmax()))]:
        add_rate_family(hull, TAG + d, kk, n, ("F1", arg))
    for v in range(1, d):
        sel = (xs & ((1 << v) - 1)) == 0
        n_in = int(sel.sum())
        gg = np.zeros(2 ** (d - v))
        gg[xs[sel] >> v] = 1 - 2 * ys[sel].astype(np.float64)
        disv = np.rint((n_in - wht(gg)) / 2).astype(np.int64)
        for (rl, f, q) in best_rate_fits(int(disv.min()), n_in):
            hull.add(TAG + gam(v) + (d - v) + rl, f + (n - n_in), ("F2", v, q))
    err = ys != fa
    n_err = int(err.sum())
    per_cell = N // 2 ** m
    s0 = int(cells_err.sum())
    # F5: parity a + j named rule cells (any j error cells remove per_cell errors each)
    for j in range(0, s0 + 1):
        base = TAG + d + gam(m) + gam(j) + math.ceil(log2binom(2 ** m, j))
        add_rate_family(hull, base, n_err - j * per_cell, n, ("F5", j))
    # F3: parity a + all error inputs named (endpoint of its family; intermediate j are never on the hull)
    for j in [0, n_err]:
        add_rate_family(hull, TAG + d + gam(j) + math.ceil(log2binom(N, j)), n_err - j, n, ("F3", j))
    hull.add(TAG + N, 0.0, ("F4",))
    # F6 / F7: envelopes with the zero subcube of every size
    for jp in range(0, m + 1):
        sub = np.zeros(2 ** m, dtype=bool)
        sub[: 2 ** (m - jp)] = True  # cells whose first jp bits (high-order) are 0: indices < 2^(m - jp)
        sub_cells = int(sub.sum())
        inside = sub[cell]
        n_in = int(inside.sum())
        # inside: target is f xor 1; disagreements = inside inputs that are NOT errors
        k_in = int((inside & ~err).sum())
        k_out = int((~inside & err).sum())
        n_out = n - n_in
        fin = best_rate_fits(k_in, n_in)
        fout = best_rate_fits(k_out, n_out) if n_out > 0 else [(1, 0.0, 0.0)]
        for (r1, f1, q1) in fin:
            for (r2, f2, q2) in fout:
                hull.add(TAG + d + gam(jp) + r1 + r2, f1 + f2, ("F6", jp, q1, q2))
        # F7: subcube + jj named error cells outside it, one rate everywhere
        out_err_cells = int((cells_err & ~sub).sum())
        for jj in range(0, out_err_cells + 1):
            kk = k_in + (k_out - jj * per_cell)
            base = TAG + d + gam(jp) + gam(jj) + math.ceil(log2binom(2 ** m - sub_cells, jj))
            add_rate_family(hull, base, kk, n, ("F7", jp, jj))
    return hull.build(), dict(n_err=n_err)


def part_A():
    print("=" * 104)
    print("(A) d = 12, m = 8, p = 1/16 (16 error cells): a cheap subcube S1 of |S1| cells plus |S2| = 16 - |S1| random cells")
    d, m, r = 12, 8, 4
    N, s0 = 2 ** d, 2 ** (m - r)
    a = int(rng.integers(1, N))
    for j in [None, 7, 6, 5, 4]:
        cells = np.zeros(2 ** m, dtype=bool)
        n1 = 0 if j is None else 2 ** (m - j)
        cells[:n1] = True
        rest = np.arange(2 ** (m - 4), 2 ** m)  # S2 is drawn outside the 16-cell zero subcube
        S2 = rng.choice(rest, size=s0 - n1, replace=False)
        cells[S2] = True
        hull, info = build(d, m, a, cells)
        good = hull.union_interval(lambda ds: ds[0] == "F1" and ds[1] == a)
        envs = [i for i, v in enumerate(hull.V) if v[2][0] in ("F6", "F7") and v[2][1] not in (0,)]
        print("-" * 104)
        print(f"  |S1| = {n1:2d} (j = {j}), |S2| = {s0 - n1:2d}; hull vertices:")
        for i, (l, f, desc) in enumerate(hull.V):
            lo, hi = hull.interval(i)
            print(f"      v{i}: l={l:5d} fit={f:9.2f} lambda in ({lo:9.4g}, {hi:9.4g})  {desc}")
        gs = f"({good[0]:.3f}, {good[1]:.2f})" if good else "empty (not a vertex)"
        print(f"    good model's lambda-interval: {gs};  reuse factor 2^(d-m) = {2 ** (d - m)}")
        if envs:
            for i in envs:
                lo, hi = hull.interval(i)
                kind = "full memoriser (fit 0)" if hull.V[i][1] == 0.0 else "envelope"
                print(f"    {kind} vertex v{i} {hull.V[i][2]}: lambda in ({lo:.3f}, {hi:.2f})")
        # structure function at selected lengths
        alphas = [10, 20, 26, 28, 30, 32, 35, 40, 50, 60, 80, 100, 120]
        rho = []
        for al in alphas:
            vals = [f for (l, (f, _)) in hull.best.items() if l <= al]
            rho.append(min(vals) if vals else math.inf)
        print("    rho(alpha): " + "  ".join(f"{al}:{v:.0f}" for al, v in zip(alphas, rho)))


def part_B():
    print("=" * 104)
    print("(B) a fixed cheap rule (m = 5, S = 4 random cells of 32, p = 1/8) as the model grows: rate blindness")
    m, s0 = 5, 4
    cells = np.zeros(2 ** m, dtype=bool)
    cells[rng.choice(2 ** m, size=s0, replace=False)] = True
    print(f"  S = {[int(z) for z in np.flatnonzero(cells)]}")
    print("  (3-point secants: coin -> F1(a, 1/8) and F1(a, 1/8) -> rule memoriser, the three-hypothesis criterion of")
    print("   prop:limits:rateblind(i); the exact interval of the class can differ by a few bits of code length)")
    for d in range(5, 17):
        N = 2 ** d
        a = int(rng.integers(1, N))
        hull, info = build(d, m, a, cells)
        good = hull.union_interval(lambda ds: ds[0] == "F1" and ds[1] == a)
        # secants: coin -> good model F1(a, q = 1/8), good model -> rule memoriser (F5, j = s0, q = 0)
        p = 1 / 8
        Fg_true = bern_fit(N // 8, N, p)
        lg_true = TAG + d + rc_len(3)
        lmem = TAG + d + gam(m) + gam(s0) + math.ceil(log2binom(2 ** m, s0)) + 1
        lcoin = TAG + rc_len(1)
        model_sec = (N - Fg_true) / (lg_true - lcoin)
        rule_sec = Fg_true / (lmem - lg_true)
        gs = f"({good[0]:.2f}, {good[1]:.2f})" if good else "empty"
        print(f"  d={d:2d} N={N:6d}: good-model interval {gs:>16}; 3-point secants: model {model_sec:9.2f}, "
              f"rule {rule_sec:9.2f}, model > rule: {str(model_sec > rule_sec):5s}; "
              f"MAP at lambda = 2^(d-m)+1: {hull.map_at(2.0 ** (d - m) + 1)[2][0]}")


if __name__ == "__main__":
    part_A()
    part_B()
