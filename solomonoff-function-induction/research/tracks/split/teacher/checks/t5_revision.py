"""t5: revision checks for the teacher sub-track (notes-final.md, Sections 2-4).

t1-t4 and tcommon.py are left unchanged, so that the record the referees checked stays reproducible.
This script re-runs the parts of t2 that the referees questioned, with two corrections:
  * exact ceilings ceil(log2 C(n, k)) = (C(n, k) - 1).bit_length() (referee B, B-m3: tcommon's lgamma
    ceiling is one bit high when C(n, k) is a power of 2);
  * per-rate and per-sample reporting (referee A M1, m11; referee B B-m6, B-m7).
It imports t2's class builder read-only (sys.dont_write_bytecode) and replaces only log2binom in t2's
namespace by the exact ceiling (build_class uses log2binom only inside math.ceil).

(A) [A M1] Population objective at the example's sizes (d = 100, m = 20, p = 2^-10): among the programs
    "true parity + flip rate q", which q minimises c l + R on (2^-m, c_hi]?  R(q) = H(p) + KL(p || q).
    Code 1: tcommon's rate code RC (every q = j / 2^b, j odd, b <= 14, q < 1/2).
    Code 2: 2 log2 r' bits for q = 2^-r' only (the convention of kappa_g in def:teacher:instance).
(B) [A M1, A m10, B-m3, B-m4, B-m7] t2(A) with exact ceilings, per rate: full tables, d = 10, p = 1/16,
    m = 10, 8, 6, 4 (the same instances as t2(A): numpy default_rng(32), same draws), and m = 9, 7, 5
    (default_rng(55)). For each instance: the hull, the lambda-set of the true-parity family (any rate),
    of the rate-p member alone, the rule memoriser's secant from the rate-p member and its ratio to
    2^(d-m), and at m = 4 the lengths and secants that decide whether the good model is a vertex.
(C) [A M2, A m11, B-m6, B-m11(3)] t2(B) with exact ceilings and per-sample reporting: d = 14, m = 8,
    p = 1/16; the same instance and the same 20 samples per n as t2(B) (the draws of default_rng(32)
    continue after (B)'s first part). Per n: medians of the family's interval (tau_n, sigma_n), of the
    rate-p member's interval, of tau_n / (mean multiplicity of the sampled error cells), the max/mean
    multiplicity, and the fraction of samples whose lambda-MAP is the true parity (any rate / rate p) at
    lambda = 2, 4 n 2^-m and 16 n 2^-m.
(D) [A M4, B-M1] Frozen noise and the teacher's errors under two likelihoods, with i.i.d. uniform inputs
    WITH repeats on {0,1}^10 (n queries, n' distinct inputs):
      FQ: per-query likelihood against the frozen table (every query counted; referee B's rB5);
      FR: Paper 2's data-set likelihood (def:setup:data: each distinct input counted once).
    Sources: (T) teacher, junta errors m = 6, p = 1/16; (Z) frozen Bern(1/16) noise, one flip per input.
    Class K of referee B's rB3/rB5 (imported read-only from ../referee_code/rB5_iid_repeats.py, so that
    the only change from rB5 is the likelihood), and, for FR, also t2's class (a second, independent
    class). Schedules: lambda = 2, 8, 20, sqrt(n), and c n (FQ) or c n' (FR) with c the geometric mean
    of the instance's population c-interval. 24 runs per source; numpy default_rng(5151).
(E) [A m12] The envelope at |S1| = 16 in t3(A): its length against the good model's.
Seeded as stated per part.
"""
import math
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(1, os.path.join(HERE, "..", "referee_code"))

import numpy as np

import tcommon
import t2_reuse_factor as t2
from tcommon import TAG, gam, rc_len, bern_fit, parity_table


def clog2binom(n, k):
    """exact ceil(log2 C(n, k)) as an integer (math.ceil of it is itself)."""
    return (math.comb(n, k) - 1).bit_length()


t2.log2binom = clog2binom  # build_class calls math.ceil(log2binom(...)) only


def H(q):
    return 0.0 if q <= 0.0 or q >= 1.0 else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def KL(p, q):
    return p * math.log2(p / q) + (1 - p) * math.log2((1 - p) / (1 - q))


# ---------------------------------------------------------------------------------------------
# (A) the rate-p good model is not the population minimiser on all of the window
# ---------------------------------------------------------------------------------------------
def c_hi(d, m, r, kappa):
    p = 2.0 ** -r
    L1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa
    kg = 2 * math.log2(d) + 2 * math.log2(r) + kappa
    G = lambda j: 1 - math.log2(1 + 2.0 ** -j + 2 * p)
    ts = (d - L1) / 4
    Hp = H(p)
    if ts >= 2:
        return min((G(1) - Hp) / (8 + L1 + kg), (G(ts - 1) - Hp) / (d + kg))
    return (G(1) - Hp) / (d + kg)


def part_A():
    print("=" * 104)
    print("(A) [A M1] population minimiser among 'true parity + rate q' at d = 100, m = 20, p = 2^-10")
    d, m, r = 100, 20, 10
    p = 2.0 ** -r
    Hp = H(p)
    code1 = []  # (extra length, q); at a fixed precision b all q cost the same, and KL(p || q) is convex
    for b in range(1, 15):  # in q, so the best odd j is one of the odd neighbours of p 2^b
        x = p * 2 ** b
        for j in set(range(int(math.floor(x)) - 3, int(math.ceil(x)) + 4)):
            if j >= 1 and j % 2 == 1 and j / 2 ** b < 0.5:
                code1.append((rc_len(b), j / 2 ** b))
    code2 = [(2 * math.log2(rr), 2.0 ** -rr) for rr in range(2, 40)]
    for name, code in (("code 1 (tcommon RC, all q = j/2^b, b <= 14)", code1), ("code 2 (2 log2 r' for q = 2^-r')", code2)):
        for kappa in (0, 30):
            ch = c_hi(d, m, r, kappa)
            cs = [2.0 ** -m * (ch / 2.0 ** -m) ** (i / 20000) for i in range(1, 20001)]
            runs = []
            for c in cs:
                best = min(code, key=lambda t: (c * t[0] + Hp + KL(p, t[1]), t[0]))
                if not runs or runs[-1][0] != best[1]:
                    runs.append([best[1], c, c])
                else:
                    runs[-1][2] = c
            print(f"  {name}, kappa = {kappa}, window (2^-20, c_hi = {ch:.4e}]:")
            for q, lo, hi in runs:
                share = math.log(hi / lo) / math.log(ch / 2.0 ** -m)
                tag = "  <- rate p (the good model)" if q == p else ""
                print(f"      c in [{lo:.4e}, {hi:.4e}] ({100 * share:5.1f}% of the log-width): minimiser q = {q:.6g}{tag}")
    l1 = dict((q, L) for (L, q) in code1)
    print(f"  code 1: RC(2^-10) = {l1[2.0 ** -10]}, RC(2^-9) = {l1[2.0 ** -9]} bits; KL(p || 2^-9) = {KL(p, 2.0 ** -9):.6f} bits;"
          f" switch at c = KL / (length difference) = {KL(p, 2.0 ** -9) / (l1[2.0 ** -10] - l1[2.0 ** -9]):.4e}")
    print(f"  code 2: 2 log2(10) - 2 log2(9) = {2 * math.log2(10 / 9):.4f} bits; switch at c = {KL(p, 2.0 ** -9) / (2 * math.log2(10 / 9)):.4e}")


# ---------------------------------------------------------------------------------------------
# (B) t2(A) per rate, exact ceilings
# ---------------------------------------------------------------------------------------------
def describe_full_table(d, m, r, a, S, verbose):
    N = 2 ** d
    p = 2.0 ** -r
    s0 = 2 ** (m - r)
    xs = np.arange(N)
    inS = np.isin(xs >> (d - m), S)
    ys = (parity_table(a, d) ^ inS.astype(np.int8)).astype(np.int8)
    hull, info = t2.build_class(d, m, a, S, xs, ys)
    hull.build()
    fam = [i for i, v in enumerate(hull.V) if v[2][0] == "F1" and v[2][1] == a]
    famI = (min(hull.interval(i)[0] for i in fam), max(hull.interval(i)[1] for i in fam)) if fam else None
    rp = [i for i in fam if hull.V[i][2][2] == p]
    rpI = (min(hull.interval(i)[0] for i in rp), max(hull.interval(i)[1] for i in rp)) if rp else None
    lg = TAG + d + rc_len(r)
    Fg = bern_fit(info["n_err"], N, p)
    lmem = TAG + d + gam(m) + gam(s0) + clog2binom(2 ** m, s0) + 1
    sec = Fg / (lmem - lg)
    out = dict(famI=famI, rpI=rpI, sec=sec, theta=sec / 2 ** (d - m), lg=lg, lmem=lmem, Fg=Fg, hull=hull)
    fmt = lambda I: "none" if I is None else f"({I[0]:.4g}, {I[1]:.4g})"
    print(f"  m={m:2d} s0={s0:3d}: family (true parity, any rate) {fmt(famI)}; rate p alone {fmt(rpI)}; "
          f"2^(d-m) = {2 ** (d - m)}; memoriser secant from the rate-p member = {sec:.4g} = 2^(d-m) x {sec / 2 ** (d - m):.4f}")
    if verbose:
        for i, (l, f, desc) in enumerate(hull.V):
            lo, hi = hull.interval(i)
            print(f"      v{i}: l={l:5d} fit={f:9.2f} lambda in ({lo:9.4g}, {hi:9.4g})  {desc}")
    return out


def part_B(rng32):
    print("=" * 104)
    print("(B) [A M1, B-m3, B-m4, B-m7] t2(A) with exact ceilings, per rate; full tables, d = 10, p = 1/16")
    d, r = 10, 4
    N = 2 ** d
    for m in [10, 8, 6, 4]:  # the draws of t2(A), in its order
        s0 = 2 ** (m - r)
        for rep in range(2):
            a = int(rng32.integers(1, N))
            S = np.sort(rng32.choice(2 ** m, size=s0, replace=False))
            o = describe_full_table(d, m, r, a, S, verbose=(rep == 0))
            if m == 4 and rep == 0:
                coin_l, coin_f = TAG + rc_len(1), float(N)
                print(f"      m = 4: lengths coin {coin_l}, good model (rate p) {o['lg']}, one-cell rule memoriser {o['lmem']}"
                      f" (= good model + {o['lmem'] - o['lg']} bits)")
                print(f"      model secant coin -> good = {(coin_f - o['Fg']) / (o['lg'] - coin_l):.2f}; rule secant good -> rule"
                      f" = {o['Fg'] / (o['lmem'] - o['lg']):.2f}: the good model is not a vertex because the rule's secant is larger")
    rng55 = np.random.default_rng(55)
    for m in [9, 7, 5]:
        s0 = 2 ** (m - r)
        a = int(rng55.integers(1, N))
        S = np.sort(rng55.choice(2 ** m, size=s0, replace=False))
        describe_full_table(d, m, r, a, S, verbose=(m == 5))


# ---------------------------------------------------------------------------------------------
# (C) t2(B) per sample, exact ceilings
# ---------------------------------------------------------------------------------------------
def part_C(rng32):
    print("=" * 104)
    print("(C) [A M2, A m11, B-m6] t2(B) with exact ceilings, per sample: d = 14, m = 8, p = 1/16 (16 of 256 cells)")
    d, m, r = 14, 8, 4
    N, s0 = 2 ** d, 2 ** (m - r)
    p = 2.0 ** -r
    a = int(rng32.integers(1, N))
    S = np.sort(rng32.choice(2 ** m, size=s0, replace=False))
    allx = np.arange(N)
    ystar = (parity_table(a, d) ^ np.isin(allx >> (d - m), S).astype(np.int8)).astype(np.int8)
    print(f"  a={a}, S={[int(z) for z in S]} (the instance of t2(B)); 20 samples per n (the samples of t2(B))")
    print(f"  {'n':>6} | {'tau_n':>6} {'sig_n':>7} | {'rate-p: lo':>10} {'hi':>7} | {'tau/mult':>8} {'max/mean':>8} | "
          f"{'fam@2':>5} {'p@2':>5} | {'fam@4n/2^m':>10} {'p@4n/2^m':>8} | {'fam@16n/2^m':>11} | right neighbour")
    for e in range(5, 15):
        n = 2 ** e
        rows = []
        for s in range(20):
            xs = np.sort(rng32.choice(N, size=n, replace=False))
            ys = ystar[xs]
            hull, info = t2.build_class(d, m, a, S, xs, ys, with_F4=False)
            hull.build()
            fam = [i for i, v in enumerate(hull.V) if v[2][0] == "F1" and v[2][1] == a]
            tau, sig = (min(hull.interval(i)[0] for i in fam), max(hull.interval(i)[1] for i in fam)) if fam else (math.nan, math.nan)
            rp = [i for i in fam if hull.V[i][2][2] == p]
            rlo, rhi = (min(hull.interval(i)[0] for i in rp), max(hull.interval(i)[1] for i in rp)) if rp else (math.nan, math.nan)
            errcells = info["cnt"][info["cnt"] > 0]
            mult = float(errcells.mean()) if len(errcells) else math.nan
            mx = float(errcells.max()) if len(errcells) else math.nan
            right = hull.V[fam[-1] + 1][2][0] if fam and fam[-1] + 1 < len(hull.V) else "-"

            def at(lam):
                desc = hull.map_at(lam)[2]
                return (desc[0] == "F1" and desc[1] == a), (desc[0] == "F1" and desc[1] == a and desc[2] == p)

            f2, p2 = at(2.0)
            f4, p4 = at(4 * n / 2 ** m)
            f16, _ = at(16 * n / 2 ** m)
            rows.append((tau, sig, rlo, rhi, tau / mult, mx / mult, f2, p2, f4, p4, f16, right))
        med = lambda j: float(np.nanmedian([row[j] for row in rows]))
        frac = lambda j: sum(1 for row in rows if row[j]) / len(rows)
        rn = {}
        for row in rows:
            rn[row[11]] = rn.get(row[11], 0) + 1
        print(f"  {n:6d} | {med(0):6.3f} {med(1):7.2f} | {med(2):10.3f} {med(3):7.2f} | {med(4):8.3f} {med(5):8.3f} | "
              f"{frac(6):5.2f} {frac(7):5.2f} | {frac(8):10.2f} {frac(9):8.2f} | {frac(10):11.2f} | {rn}")
    print("  tau_n, sig_n: the family's interval (true parity, any rate); rate-p lo/hi: the interval of the rate-p member")
    print("  (nan: never a lambda-MAP); tau/mult: tau_n over the mean multiplicity of the sampled error cells; max/mean:")
    print("  largest over mean multiplicity; fam@x / p@x: fraction of samples whose lambda-MAP at lambda = x is the true")
    print("  parity at any rate / at rate p; right neighbour: family of the hull vertex just right of the family.")


# ---------------------------------------------------------------------------------------------
# (D) frozen noise and junta errors under FQ and FR
# ---------------------------------------------------------------------------------------------
def part_D():
    import rB5_iid_repeats as K5  # referee B's class K; read-only import
    print("=" * 104)
    print("(D) [A M4, B-M1] i.i.d. uniform inputs with repeats on {0,1}^10; FQ (per-query likelihood against the frozen")
    print("    table) against FR (Paper 2's data-set likelihood, each distinct input once). Class K of rB5, and t2's class (FR).")
    rng = np.random.default_rng(5151)
    d, m_rule, r = 10, 6, 4
    N = 2 ** d
    p = 2.0 ** -r
    ns = [1 << e for e in range(6, 23, 2)]
    runs = 24

    def cls(desc, a):
        if desc[0] == "B" and desc[1] == a:
            return "goodp" if desc[-1] == p else "good"
        if desc[0] == "F" or (desc[0] in ("C", "E", "D") and desc[-1] == 0.0):
            return "memo"
        return "other"

    def cls_t2(desc, a):
        if desc[0] == "F1" and desc[1] == a:
            return "goodp" if desc[2] == p else "good"
        if desc[0] == "F4" or (desc[0] in ("F5", "F3") and desc[-1] == 0.0):
            return "memo"
        return "other"

    for kind in ("T", "Z"):
        res = {}
        spans = []
        for run in range(runs):
            a = int(rng.integers(1, N))
            fa = parity_table(a, d)
            xs = np.arange(N)
            if kind == "T":
                cells = np.zeros(1 << m_rule, dtype=bool)
                cells[rng.choice(1 << m_rule, size=1 << (m_rule - r), replace=False)] = True
                flip = cells[xs >> (d - m_rule)]
                mm = m_rule
                Sset = np.flatnonzero(cells)
            else:
                flip = rng.random(N) < p
                mm = d
                Sset = np.flatnonzero(flip)
            span = K5.population_window(a, fa, flip.astype(float), mm)
            cmid = math.sqrt(span[0] * span[1])
            spans.append(span)
            ylab = (fa ^ flip.astype(np.int8)).astype(np.int8)
            cnt = np.zeros(N)
            prev = 0
            for n in ns:
                cnt += rng.multinomial(n - prev, np.full(N, 1.0 / N))
                prev = n
                seen = cnt > 0
                nd = int(seen.sum())
                # FQ: per-query weights; FR: one per distinct input
                for obj, wt in (("FQ", cnt), ("FR", seen.astype(float))):
                    w1 = np.where(ylab == 1, wt, 0.0)
                    w0 = np.where(ylab == 0, wt, 0.0)
                    pts = K5.build(a, fa, w0, w1, mm)
                    scale = n if obj == "FQ" else nd
                    for name, lam in (("2", 2.0), ("8", 8.0), ("20", 20.0), ("sqrt n", math.sqrt(n)), ("c n", cmid * scale)):
                        res.setdefault((obj, "K", name, n), []).append(cls(K5.lam_map(pts, lam), a))
                # FR in t2's class (an independent class): distinct inputs only
                xd = np.flatnonzero(seen)
                hull, _ = t2.build_class(d, mm, a, Sset, xd, ylab[xd], with_F4=True)
                hull.build()
                for name, lam in (("2", 2.0), ("8", 8.0), ("20", 20.0), ("sqrt n", math.sqrt(n)), ("c n", cmid * nd)):
                    res.setdefault(("FR", "t2", name, n), []).append(cls_t2(hull.map_at(lam)[2], a))
        title = "(T) teacher, junta errors m = 6, p = 1/16" if kind == "T" else "(Z) frozen noise, one Bern(1/16) flip per input"
        lo = min(s[0] for s in spans), max(s[0] for s in spans)
        hi = min(s[1] for s in spans), max(s[1] for s in spans)
        print("-" * 104)
        print(f"  {title}: population c-interval of the family in K: lower end in [{lo[0]:.4g}, {lo[1]:.4g}], upper end in "
              f"[{hi[0]:.4g}, {hi[1]:.4g}] (2^-m = {2.0 ** -m_rule:.4g}, 2^-d = {2.0 ** -d:.4g})")
        names = ["2", "8", "20", "sqrt n", "c n"]
        for obj, klass in (("FQ", "K"), ("FR", "K"), ("FR", "t2")):
            print(f"    {obj} in class {klass}: fraction of runs whose lambda-MAP is the true parity (any rate) / a memoriser;"
                  f" 'c n' uses {'n' if obj == 'FQ' else 'n distinct'}")
            print(f"    {'n':>8} | " + " | ".join(f"{'lam=' + nm:>13}" for nm in names))
            for n in ns:
                cells_ = []
                for nm in names:
                    v = res[(obj, klass, nm, n)]
                    g = sum(1 for x in v if x in ("good", "goodp")) / len(v)
                    mo = v.count("memo") / len(v)
                    cells_.append(f"{g:5.2f} / {mo:5.2f}")
                print(f"    {n:8d} | " + " | ".join(f"{c:>13}" for c in cells_) + f"   (n / N = {n / N:g})")


# ---------------------------------------------------------------------------------------------
# (E) the envelope's length in t3(A), |S1| = 16
# ---------------------------------------------------------------------------------------------
def part_E():
    print("=" * 104)
    print("(E) [A m12] t3(A), d = 12, m = 8, |S1| = 16 (j' = 4): envelope F6 against the good model F1(a, 1/16)")
    d = 12
    env = TAG + d + gam(4) + 1 + 1
    good = TAG + d + rc_len(4)
    print(f"  F6 length = 3 + d + g(j') + RC(0) + RC(0) = 3 + {d} + {gam(4)} + 1 + 1 = {env}; "
          f"F1 length = 3 + d + RC(1/16) = 3 + {d} + {rc_len(4)} = {good}")
    print(f"  beyond the parity: envelope {env - TAG - d} bits (g(j') = {gam(4)} and two deterministic flags), "
          f"good model {good - TAG - d} bits")


if __name__ == "__main__":
    part_A()
    rng32 = np.random.default_rng(32)
    part_B(rng32)
    part_C(rng32)
    part_D()
    part_E()
