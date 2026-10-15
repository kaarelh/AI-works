"""rB5: i.i.d. inputs WITH replacement (repeats) and per-query likelihoods: simulations of notes.md
Prop 3.2 (fixed lambda ends at the least-risk vertex; lambda = c n stops at the vertex of slope c),
for three label sources on {0,1}^10 (uniform inputs):
  (T) the teacher, junta errors: y* = f_a xor 1_S(cell), m = 6, p = 1/16 (4 cells of 64);
  (R) a sampler with FRESH noise: each query's label is f_a(x) flipped with probability 1/16, redrawn
      at every query (the per-query object of Prop 3.2 and iid Thm 3.1);
  (Z) FROZEN noise (Paper 2's def:setup:data): one Bernoulli(1/16) flip per distinct input, reused at
      every repeat. On a finite domain this is the teacher with m = d (idiosyncratic errors).
Class K of rB3 (families A, B, C, D, E, F), fits are per-query weighted counts. Schedules:
lambda = 2, lambda = 8, lambda_n = sqrt(n), and lambda = c n with c inside the good model's population
c-interval in K (computed below). 24 runs per source; n = 2^6 ... 2^22 along each run (counts grow
incrementally, so each run is one data sequence).
Reported: the fraction of runs whose lambda-MAP is the good model (true parity, any rate), a
memoriser (fit 0 or zero-rate rule/table), or other.
Seeded: numpy default_rng(5150).
"""
import math
import sys

import numpy as np

sys.dont_write_bytecode = True
from rBcommon import delta_len, ceil_log2comb, rate_options, lambda_set, union_span, parity_table, rate_len

rng = np.random.default_rng(5150)
TAG = 3
d, m, r = 10, 6, 4
N = 1 << d
p = 2.0 ** -r


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


def build(a, fa, w0, w1, mm):
    """points of class K for label weights w0[x], w1[x] (weight of queries at x with label 0 / 1);
    mm = the cell length used by family C. Fits are -log2 likelihood (total, or per sample if the
    weights sum to 1)."""
    xs = np.arange(N)
    n = float(w0.sum() + w1.sum())
    c_agree = np.where(fa == 0, w0, w1)     # weight of queries whose label is f_a(x)
    c_flip = np.where(fa == 0, w1, w0)      # weight of queries whose label is f_a(x) xor 1
    both = (c_agree > 0) & (c_flip > 0)     # some input seen with both labels: no deterministic fit
    pts = []

    def add(base, k, nn, desc, below_half=True):
        for (rl, f, q) in rate_options_real(k, nn, below_half):
            pts.append((base + rl, f, desc + (q,)))

    add(TAG, float(w1.sum()), n, ("A",), below_half=False)
    dis = (n - wht(w0 - w1)) / 2           # disagreement weight of every parity
    add(TAG + d, float(dis[a]), n, ("B", a))
    dd = dis.copy()
    dd[a] = n + 1
    add(TAG + d, float(dd.min()), n, ("B", int(dd.argmin())))
    cell = xs >> (d - mm)
    per = np.bincount(cell, weights=c_agree + c_flip, minlength=1 << mm)
    e_c = np.bincount(cell, weights=c_flip, minlength=1 << mm)
    gain = np.sort(per - 2 * e_c)
    cum = np.concatenate([[0.0], np.cumsum(gain)])
    k0 = float(c_flip.sum())
    for j in range(0, (1 << mm) + 1):
        if j > 0 and gain[j - 1] >= 0:
            break
        add(TAG + d + delta_len(mm) + delta_len(j + 1) + ceil_log2comb(1 << mm, j), max(0.0, k0 + float(cum[j])), n, ("C", j))
    for jp in range(0, d + 1):
        inside = (xs >> (d - jp)) == 0 if jp > 0 else np.ones(N, dtype=bool)
        n_in = float((c_agree + c_flip)[inside].sum())
        k_in, k_out = float(c_agree[inside].sum()), float(c_flip[~inside].sum())
        fin = rate_options_real(k_in, n_in, True) if n_in > 0 else [(1, 0.0, 0.0)]
        fout = rate_options_real(k_out, n - n_in, True) if n - n_in > 0 else [(1, 0.0, 0.0)]
        for (r1, f1, q1) in fin:
            for (r2, f2, q2) in fout:
                pts.append((TAG + d + delta_len(jp + 1) + r1 + r2, f1 + f2, ("D", jp, q1, q2)))
    gainx = np.sort((c_agree - c_flip)[c_flip > 0])     # naming x flips it: change = c_agree - c_flip
    cumx = np.concatenate([[0.0], np.cumsum(gainx)])
    for j in range(0, len(gainx) + 1):
        if j > 0 and gainx[j - 1] >= 0:
            break
        add(TAG + d + delta_len(j + 1) + ceil_log2comb(N, j), max(0.0, k0 + float(cumx[j])), n, ("E", j))
    if not both.any():
        pts.append((TAG + N, 0.0, ("F",)))
    return pts


def rate_options_real(k, n, below_half):
    """rate options for real weights (k = disagreement weight, n = total weight)."""
    out = []
    if k <= 1e-12:
        out.append((rate_len(0), 0.0, 0.0))
    for b in range(1, 15):
        M = 1 << b
        x = (k / n) * M if n > 0 else M / 2
        best = None
        for j in range(int(math.floor(x)) - 2, int(math.ceil(x)) + 3):
            if 1 <= j < M and j % 2 == 1 and (not below_half or 2 * j <= M):
                q = j / M
                f = -(k * math.log2(q) + (n - k) * math.log2(1 - q))
                if best is None or f < best[0]:
                    best = (f, q)
        if best:
            out.append((rate_len(b), best[0], best[1]))
    return out


def classify(desc, a):
    if desc[0] == "B" and desc[1] == a:
        return "good"
    if desc[0] == "F" or (desc[0] in ("C", "E", "D") and desc[-1] == 0.0):
        return "memo"
    return "other"


def lam_map(pts, lam):
    best = min(pts, key=lambda t: lam * t[0] + t[1])
    return best[2]


def population_window(a, fa, flip_prob_x, mm):
    """the good model's interval in c for the population objective (weights mu = 2^-d); flip_prob_x[x]
    is the probability that the label at x is f_a(x) xor 1 (0/1 for deterministic sources)."""
    w_flip = flip_prob_x / N
    w_agree = (1 - flip_prob_x) / N
    w1 = np.where(fa == 0, w_flip, w_agree)
    w0 = np.where(fa == 0, w_agree, w_flip)
    pts = build(a, fa, w0, w1, mm)
    span = union_span(lambda_set(pts, lambda dsc: dsc[0] == "B" and dsc[1] == a))
    return span


def run_source(kind, runs=24):
    ns = [1 << e for e in range(6, 23, 2)]
    schedules = [("lam=2", lambda n: 2.0), ("lam=8", lambda n: 8.0), ("sqrt(n)", lambda n: math.sqrt(n))]
    results = {}
    cwin = []
    for run in range(runs):
        a = int(rng.integers(1, N))
        fa = parity_table(a, d)
        xs = np.arange(N)
        if kind == "T":
            cells = np.zeros(1 << m, dtype=bool)
            cells[rng.choice(1 << m, size=1 << (m - r), replace=False)] = True
            flip_x = cells[xs >> (d - m)].astype(float)
            mm = m
        elif kind == "Z":
            flip_x = (rng.random(N) < p).astype(float)
            mm = d
        else:
            flip_x = np.full(N, p)
            mm = m
        span = population_window(a, fa, flip_x, mm)
        c_mid = math.sqrt(span[0] * span[1]) if span and span[0] > 0 else (span[1] / 4 if span else None)
        cwin.append((span, c_mid))
        sch = schedules + ([("c n", lambda n, c=c_mid: c * n)] if c_mid else [])
        cnt = np.zeros(N)
        cflip = np.zeros(N)
        prev = 0
        for n in ns:
            add = rng.multinomial(n - prev, np.full(N, 1.0 / N))
            if kind == "R":
                fl = rng.binomial(add, p)
            else:
                fl = add * flip_x
            cnt += add
            cflip += fl
            prev = n
            c_agree = cnt - cflip
            w1 = np.where(fa == 0, cflip, c_agree)
            w0 = np.where(fa == 0, c_agree, cflip)
            pts = build(a, fa, w0, w1, mm)
            for (name, f) in sch:
                cls = classify(lam_map(pts, f(n)), a)
                results.setdefault((name, n), []).append(cls)
    return ns, results, cwin


def main():
    for kind, title in (("T", "(T) teacher, junta errors m = 6, p = 1/16"),
                        ("R", "(R) sampler with fresh noise per query, p = 1/16"),
                        ("Z", "(Z) frozen noise: one flip per distinct input, p = 1/16 (Paper 2's object)")):
        ns, res, cwin = run_source(kind)
        print("=" * 110)
        print(title)
        spans = [s for (s, c) in cwin if s]
        print(f"  population c-interval of the good model in K (over runs): lower end in [{min(s[0] for s in spans):.3g}, "
              f"{max(s[0] for s in spans):.3g}], upper end in [{min(s[1] for s in spans):.3g}, {max(s[1] for s in spans):.3g}]; "
              f"2^-m = {2.0 ** -m:.3g}, 2^-d = {2.0 ** -d:.3g}; c n uses the geometric mean of the run's interval")
        names = ["lam=2", "lam=8", "sqrt(n)", "c n"]
        print(f"  {'n':>8} | " + " | ".join(f"{nm:>22}" for nm in names) + "   (fractions good / memo / other)")
        for n in ns:
            cells_ = []
            for nm in names:
                v = res.get((nm, n), [])
                if not v:
                    cells_.append(f"{'-':>22}")
                    continue
                g = v.count("good") / len(v)
                mo = v.count("memo") / len(v)
                ot = v.count("other") / len(v)
                cells_.append(f"{g:6.2f} / {mo:5.2f} / {ot:5.2f}")
            print(f"  {n:8d} | " + " | ".join(cells_) + f"   (n / N = {n / N:g})")


if __name__ == "__main__":
    main()
