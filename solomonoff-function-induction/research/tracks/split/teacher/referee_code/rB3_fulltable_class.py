"""rB3: referee B's explicit product class on full truth tables, built independently of t2/t3, to test
Props 3.1, 2.4(iii), 4.1, 4.2 and the t2(A)/t3 tables in a different code.

Class K (3-bit family tag, then prefix codes; Elias delta for integers; rate code of rBcommon:
q = 0 costs 1 bit, q = j/2^b costs 1 + delta(b) + b - 1 bits; ceilings of log2 binomials are exact):
  A  constant: predicts 0 with prob 1 - q                          3 + R(q)
  B  parity a' + flip rate q                                         3 + d + R(q)
  C  parity a + rule T (cells = top m input bits; m, |T| coded) + q  3 + d + delta(m) + delta(|T|+1) + ceil log2 C(2^m,|T|) + R(q)
  D  parity a + subcube envelope {x : top j' bits 0} with two rates   3 + d + delta(j'+1) + R(q_in) + R(q_out)
     (predicts f_a xor 1 on the subcube, f_a off it)
  E  parity a + j named inputs (flipped) + q                         3 + d + delta(j+1) + ceil log2 C(N, j) + R(q)
  F  lookup table                                                     3 + N
  G  partial parity: top d - v coordinates of a (v coded), q on inputs whose low v bits are 0, 1/2 elsewhere
                                                                      3 + delta(v) + (d - v) + R(q)
Kraft sum <= 1 (tag + prefix codes). For C, D, E only the true parity a is used, and for B the true
parity and the best other parity; part (E) checks by exhaustion at d = 6, m = 4 (every parity, every
rule T) that this restriction does not change the lambda-set of the good model.
"Good model" = B with the true parity a, any rate; its lambda-set is reported as a union over rates and
per rate (rate p alone in brackets).

(A) Reuse factor: d = 10 and d = 12, p = 1/16, every m from d down to 5 (full tables, 3 seeds each).
(B) Noisy parity, m = d (idiosyncratic errors), d = 8, 10, 12, p = 1/32 and 1/16: does the window start at 1?
(C) Envelopes: d = 12, m = 8, p = 1/16, S = S1 (cheap subcube of 2^(m-j) cells) u S2 (random).
(D) Rate blindness: a fixed rule of 4 random cells at m = 5 (p = 1/8), d = 5..16.
(E) Exhaustive validation of the restriction to the true parity and to the greedy rule (d = 6, m = 4).
(F) Lengths of the single-cell rule against the good model's rate code (t2(A)'s m = 4 remark), both codes.
Seeded: numpy default_rng(4242).
"""
import math
import sys

import numpy as np

sys.dont_write_bytecode = True
from rBcommon import (delta_len, rate_len, ceil_log2comb, rate_options, bern_bits, lambda_set, union_span,
                      parity_table, H)

rng = np.random.default_rng(4242)
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


def build(d, m, a, cells_err, families="ABCDEFG"):
    """points (length, fit, desc) of class K on the full truth table of y = f_a xor 1_S(cell)."""
    N = 1 << d
    xs = np.arange(N)
    cell = xs >> (d - m)
    fa = parity_table(a, d)
    ys = (fa ^ cells_err[cell].astype(np.int8)).astype(np.int8)
    pts = []

    def add(base, k, n, desc, extra=0.0, below_half=True):
        for (rl, f, q) in rate_options(k, n, below_half=below_half):
            pts.append((base + rl, f + extra, desc + (q,)))

    if "A" in families:
        add(TAG, int(ys.sum()), N, ("A",), below_half=False)
    if "B" in families:
        dis = np.rint((N - wht(1 - 2 * ys.astype(np.float64))) / 2).astype(np.int64)
        add(TAG + d, int(dis[a]), N, ("B", a))
        dd = dis.copy()
        dd[a] = N + 1
        add(TAG + d, int(dd.min()), N, ("B", int(dd.argmin())))
    err = ys != fa
    n_err = int(err.sum())
    if "C" in families:
        per = np.bincount(cell, minlength=1 << m)
        e_c = np.bincount(cell[err], minlength=1 << m)
        gain = np.sort(per - 2 * e_c)  # flipping cell z changes the disagreements by per_z - 2 e_z
        cum = np.concatenate([[0], np.cumsum(gain)])
        for j in range(0, (1 << m) + 1):
            k = n_err + int(cum[j])
            if j > 0 and gain[j - 1] >= 0:
                break
            base = TAG + d + delta_len(m) + delta_len(j + 1) + ceil_log2comb(1 << m, j)
            add(base, k, N, ("C", j))
    if "D" in families:
        for jp in range(0, d + 1):
            inside = (xs >> (d - jp)) == 0 if jp > 0 else np.ones(N, dtype=bool)
            n_in = int(inside.sum())
            k_in = int((inside & ~err).sum())    # inside, the target is f_a xor 1
            k_out = int((~inside & err).sum())
            fin = rate_options(k_in, n_in)
            fout = rate_options(k_out, N - n_in) if N - n_in > 0 else [(1, 0.0, 0.0)]
            for (r1, f1, q1) in fin:
                for (r2, f2, q2) in fout:
                    pts.append((TAG + d + delta_len(jp + 1) + r1 + r2, f1 + f2, ("D", jp, q1, q2)))
    if "E" in families:
        for j in range(0, n_err + 1):
            base = TAG + d + delta_len(j + 1) + ceil_log2comb(N, j)
            add(base, n_err - j, N, ("E", j))
    if "F" in families:
        pts.append((TAG + N, 0.0, ("F",)))
    if "G" in families:
        for v in range(1, d):
            sel = (xs & ((1 << v) - 1)) == 0
            k = int((ys[sel] != fa[sel]).sum())
            add(TAG + delta_len(v) + (d - v), k, int(sel.sum()), ("G", v), extra=float(N - int(sel.sum())))
    return pts


def good(a):
    return lambda desc: desc[0] == "B" and desc[1] == a


def report_good(pts, a, p):
    ivs = lambda_set(pts, good(a))
    span = union_span(ivs)
    per_rate = sorted(((iv[0], iv[1], iv[4][2]) for iv in ivs), key=lambda t: -t[2])
    rate_p = [t for t in per_rate if abs(t[2] - p) < 1e-12]
    return span, per_rate, rate_p


def fmt_span(span):
    if span is None:
        return "empty (not a lambda-MAP for any lambda)"
    return f"[{span[0]:.3f}, {span[1]:.2f}]" + ("" if span[2] else " (not connected)")


def right_neighbour(pts, a, lam_lo):
    """the lambda-MAPs just below the lower end of the good model's set."""
    ms = [v for v in __import__("rBcommon").map_at(pts, lam_lo * 0.999)]
    return sorted(set((l, round(f, 2), str(dsc[:2])) for (_, l, f, dsc) in ms))


def part_A():
    print("=" * 110)
    print("(A) reuse factor on full tables, p = 1/16: lower end of the good model's lambda-set against 2^(d-m)")
    r = 4
    p = 2.0 ** -r
    for d in (10, 12):
        N = 1 << d
        for m in range(d, 4, -1):
            s0 = 1 << (m - r) if m >= r else 0
            for rep in range(3):
                a = int(rng.integers(1, N))
                cells = np.zeros(1 << m, dtype=bool)
                cells[rng.choice(1 << m, size=s0, replace=False)] = True
                pts = build(d, m, a, cells)
                span, per_rate, rate_p = report_good(pts, a, p)
                Fg = bern_bits(s0 << (d - m), N, p)
                lg = TAG + d + rate_len(r)
                lmem = TAG + d + delta_len(m) + delta_len(s0 + 1) + ceil_log2comb(1 << m, s0) + rate_len(0)
                sec = Fg / (lmem - lg)
                rp = f"[{rate_p[0][0]:.3f}, {rate_p[0][1]:.2f}]" if rate_p else "none"
                print(f"  d={d:2d} m={m:2d} s0={s0:4d} rep={rep}: good model {fmt_span(span):>22}; rate p alone {rp:>18}; "
                      f"2^(d-m)={1 << (d - m):4d}; memoriser secant {sec:8.3f} = 2^(d-m) x {sec / (1 << (d - m)):.3f}")
                if rep == 0 and span is not None:
                    print("        per rate: " + "; ".join(f"q={q:g}: [{lo:.3f}, {hi:.2f}]" for (lo, hi, q) in per_rate))


def part_B():
    print("=" * 110)
    print("(B) noisy parity, m = d (idiosyncratic errors), full table: the window starts near lambda = 1")
    for d in (8, 10, 12):
        for r in (5, 4):
            p = 2.0 ** -r
            N = 1 << d
            a = int(rng.integers(1, N))
            cells = np.zeros(N, dtype=bool)
            cells[rng.choice(N, size=N >> r, replace=False)] = True
            pts = build(d, d, a, cells)
            span, per_rate, rate_p = report_good(pts, a, p)
            print(f"  d={d:2d} p=1/{1 << r:2d} (|E|={N >> r:4d}): good model {fmt_span(span)}; "
                  f"G_1 - H(p) = {1 - math.log2(1.5 + 2 * p) - H(p):+.4f}")
            if span is not None:
                below = __import__("rBcommon").map_at(pts, span[0] * 0.99)
                print(f"        just below the lower end the MAP is {sorted(set(str(v[3][:2]) for v in below))}; "
                      f"just above the upper end: {sorted(set(str(v[3][:2]) for v in __import__('rBcommon').map_at(pts, span[1] * 1.01)))}")


def part_C():
    print("=" * 110)
    print("(C) envelopes: d = 12, m = 8, p = 1/16 (16 error cells); S1 = cheap subcube, S2 random cells outside the 16-cell zero subcube")
    d, m, r = 12, 8, 4
    N = 1 << d
    a = int(rng.integers(1, N))
    for j in (None, 7, 6, 5, 4):
        cells = np.zeros(1 << m, dtype=bool)
        n1 = 0 if j is None else 1 << (m - j)
        cells[:n1] = True
        S2 = rng.choice(np.arange(1 << (m - 4), 1 << m), size=16 - n1, replace=False)
        cells[S2] = True
        pts = build(d, m, a, cells)
        span, per_rate, _ = report_good(pts, a, 1 / 16)
        env = lambda_set(pts, lambda ds: ds[0] == "D" and ds[1] > 0)
        envs = "; ".join(f"D(j'={iv[4][1]}, q_in={iv[4][2]:g}, q_out={iv[4][3]:g}): [{iv[0]:.2f}, {iv[1]:.2f}]" for iv in env)
        print(f"  |S1|={n1:2d}: good model {fmt_span(span):>18}; envelope vertices: {envs if envs else 'none'}")


def part_D():
    print("=" * 110)
    print("(D) rate blindness: a fixed rule of 4 random cells at m = 5 (p = 1/8) as d grows")
    m = 5
    cells = np.zeros(1 << m, dtype=bool)
    cells[rng.choice(1 << m, size=4, replace=False)] = True
    for d in range(5, 17):
        a = int(rng.integers(1, 1 << d))
        pts = build(d, m, a, cells)
        span, per_rate, _ = report_good(pts, a, 1 / 8)
        print(f"  d={d:2d}: good model {fmt_span(span)}")


def pareto(pts):
    best = {}
    for (l, f, dsc) in pts:
        if f < math.inf and (l not in best or f < best[l][0] - 1e-12):
            best[l] = (f, dsc)
    return [(l, f, dsc) for l, (f, dsc) in sorted(best.items())]


def hull_signature(pts):
    """all points that are lambda-MAPs for some lambda, with their lambda-intervals (descriptions dropped)."""
    ivs = lambda_set(pareto(pts), lambda dsc: True)
    # drop the degenerate interval [0, 0] (at lambda = 0 every zero-fit program is a MAP)
    return sorted((iv[2], round(iv[3], 6), round(iv[0], 6), round(iv[1], 6)) for iv in ivs if iv[1] > 1e-9)


def part_E():
    print("=" * 110)
    print("(E) exhaustive check at d = 8, m = 4 (every parity a' and every rule T in family C, every parity in B):")
    print("    the whole MAP path (every point that is a lambda-MAP for some lambda, with its lambda-interval)")
    print("    of the restricted class (true parity, greedy rules) against the exhaustive class, for lambda > 0")
    d, m = 8, 4
    N = 1 << d
    for (r, nerr) in ((4, 1), (3, 2), (2, 4)):
        for rep in range(2):
            a = int(rng.integers(1, N))
            cells = np.zeros(1 << m, dtype=bool)
            cells[rng.choice(1 << m, size=nerr, replace=False)] = True
            restricted = build(d, m, a, cells)
            xs = np.arange(N)
            cell = xs >> (d - m)
            ys = (parity_table(a, d) ^ cells[cell].astype(np.int8)).astype(np.int8)
            full = [pt for pt in restricted if pt[2][0] not in ("B", "C")]
            masks = np.arange(1 << (1 << m), dtype=np.int64)
            pop = np.bitwise_count(masks)
            for ap in range(N):
                fap = parity_table(ap, d)
                dis = ys != fap
                for (rl, f, q) in rate_options(int(dis.sum()), N):
                    full.append((TAG + d + rl, f, ("B", ap, q)))
                per = np.bincount(cell, minlength=1 << m)
                e_c = np.bincount(cell[dis], minlength=1 << m)
                k = np.full(masks.shape, int(dis.sum()), dtype=np.int64)
                for z in range(1 << m):
                    k += ((masks >> z) & 1) * int(per[z] - 2 * e_c[z])
                for j in range(0, (1 << m) + 1):
                    kmin = int(k[pop == j].min())
                    base = TAG + d + delta_len(m) + delta_len(j + 1) + ceil_log2comb(1 << m, j)
                    for (rl, f, q) in rate_options(kmin, N):
                        full.append((base + rl, f, ("C", j, ap, q)))
            hr, hf = hull_signature(restricted), hull_signature(full)
            span = union_span(lambda_set(restricted, good(a)))
            print(f"  p=1/{1 << r} ({nerr} error cells) rep={rep}: MAP-path points restricted {len(hr)}, exhaustive {len(hf)}; "
                  f"identical: {hr == hf}; good model {fmt_span(span)}")


def part_F():
    print("=" * 110)
    print("(F) t2(A), m = 4 (one error cell of 16, d = 10, p = 1/16): extra length of the single-cell rule memoriser over")
    print("    the good model's rate code, and the secants that decide whether the good model is a vertex")
    # prover's code: gam(k) = 2 floor(log2(k+1)) + 1; RC(0) = 1, RC(2^-b) = 1 + gam(b) + (b - 1)
    gam = lambda k: 2 * int(math.floor(math.log2(k + 1))) + 1
    rule_extra_prover = gam(4) + gam(1) + 4 + 1 - (1 + gam(4) + 3)
    rule_extra_mine = delta_len(4) + delta_len(2) + 4 + rate_len(0) - rate_len(4)
    Fg = bern_bits(64, 1024, 1 / 16)
    print(f"  prover's code: rule memoriser minus good model = {rule_extra_prover} bits (with exact ceiling); "
          f"mine: {rule_extra_mine} bits; the rule is longer, not cheaper")
    lcoin, lg = 3 + (1 + gam(1)), 3 + 10 + (1 + gam(4) + 3)  # prover's coin (q = 1/2) and good model
    print(f"  prover's code: model secant (coin -> good) = {(1024 - Fg) / (lg - lcoin):.2f}, rule secant (good -> rule) = "
          f"{Fg / rule_extra_prover:.2f}: the good model is not a vertex because the rule's secant is larger")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    part_D()
    part_E()
    part_F()
