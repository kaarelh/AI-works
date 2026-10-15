"""rB2 (referee B): an explicit, exactly enumerable product class on the FULL truth table of a noisy
random parity (notes.md Section 4, Illustration; Cor 3.3; Prop 4.4 in class form; Remark 3.6).

Independent of checks/k2_parity_class.py (own codes and families).  Code lengths (prefix-free, Kraft
sum printed):
  tag 3 bits; rate code: 1 bit 'deterministic' (flip prob 0), else 1 + gamma(b) + (b-1) bits for
  q = j/2^b, j odd, 1 <= b <= BMAX; gamma(k) = 2*floor(log2 k) + 1 bits (Elias gamma).
  F0 constant Bern(q) label 1                         3 + rate (det: 3 + 2)
  F1 parity a' with flip rate q                       3 + d + rate
  F2 partial parity: v unknown LAST coordinates,       3 + gamma(v) + (d - v) + rate
     per-input mixture over completions (= q-noisy known parity where the last v input bits are 0,
     else 1/2)
  F3 parity a' + j memorised inputs (label f_a' xor 1 there), rate q elsewhere
                                                       3 + d + rate + gamma(j) + ceil(log2 C(N, j))
  F4 lookup table                                      3 + N
  F5 (two-kink instance only) parity a' + junta rule S subset {0,1}^m given by its index
     (label f_a' xor 1 on S x {0,1}^(d-m)), rate q elsewhere
                                                       3 + d + gamma(m) + gamma(|S|) + ceil(log2 C(2^m,|S|)) + rate
Set models (Prop 4.4 class form): all strings; A_v = {f_a' xor 1_E': a' = a on the first d-v
coordinates, |E'| = s0}; partial memo-sets {f_a xor 1_E': E' contains a named J subset E, |E'| = s0}.

Per instance: exact lower hull (floats, tolerance 1e-9) and lambda-MAP for all lambda; level of each
vertex; left steepness / right flatness at the good model for several windows; Cor 3.3 bounds in class
form (K := min two-part length in the class, kappa = 0); lambda = 1 MAP; set hull and set lambda-MAPs.
Seeded: numpy default_rng(777) for instances.
"""
import math
import numpy as np

rng = np.random.default_rng(777)
BMAX = 10
TOL = 1e-9


def gamma(k):
    return 2 * int(math.floor(math.log2(k))) + 1


def log2C(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


def H(p):
    return 0.0 if p in (0, 1) else -p * math.log2(p) - (1 - p) * math.log2(1 - p)


RATES = [(0.0, 1)]  # (flip prob, code length); deterministic: 1 bit
for b in range(1, BMAX + 1):
    for j in range(1, 2 ** b, 2):
        RATES.append((j / 2 ** b, 1 + gamma(b) + b - 1))


def kraft_rates():
    return sum(2.0 ** -c for _, c in RATES)


def fit_counts(mis, tot, q):
    """-log2 likelihood of tot labels of which mis disagree with the predicted bit, flip prob q."""
    if q == 0.0:
        return 0.0 if mis == 0 else math.inf
    return -(mis * math.log2(q) + (tot - mis) * math.log2(1 - q))


def wht(v):
    h = v.astype(np.int64).copy()
    n = len(h)
    s = 1
    while s < n:
        h = h.reshape(-1, 2, s)
        a, b = h[:, 0, :].copy(), h[:, 1, :].copy()
        h[:, 0, :], h[:, 1, :] = a + b, a - b
        h = h.reshape(n)
        s *= 2
    return h


def mismatches_all(y, d):
    """m(a') = #{x: y(x) != <a',x>} for all a' (index = integer of a', bit k = coordinate k)."""
    s = 1 - 2 * y.astype(np.int64)  # (-1)^y
    c = wht(s)  # sum_x (-1)^{y(x) + <a',x>}
    N = 2 ** d
    return (N - c) // 2


def parity_table(a, d):
    x = np.arange(2 ** d)
    return np.array([bin(int(a) & int(xx)).count("1") & 1 for xx in x], dtype=np.int64)


def build(d, y, a_true, rule=None):
    """return list of programs (length, fit, label, u) with best fits per (family, parameters)."""
    N = 2 ** d
    progs = []
    n1 = int(y.sum())
    # F0
    for q, c in RATES:
        if q == 0.0:
            for val in (0, 1):
                L = 0.0 if (n1 == N * val) else math.inf
                progs.append((3 + 1 + 1, L, f"F0 const {val}", 0.5))
            continue
        L = -(n1 * math.log2(q) + (N - n1) * math.log2(1 - q))
        progs.append((3 + c, L, f"F0 Bern({q:g})", 0.5))
    # F1
    m = mismatches_all(y, d)
    order = np.argsort(m)
    a_best, a_worst = int(order[0]), int(order[-1])
    for q, c in RATES:
        for ap in {a_best, a_worst, a_true}:
            L = fit_counts(int(m[ap]), N, q)
            u = (1 - q) if ap == a_true else 0.5
            progs.append((3 + d + c, L, f"F1 a'={ap} q={q:g}", u))
    # F2 (last v coordinates unknown): zero-tail inputs are x < 2^(d-v) when coordinate k = bit k and
    # the 'last' coordinates are the high bits
    for v in range(1, d + 1):
        Nh = 2 ** (d - v)
        ysub = y[:Nh]
        if d - v >= 1:
            msub = mismatches_all(ysub, d - v)
        else:
            msub = np.array([int(ysub[0] != 0)])
        best_prefix = int(np.argmin(msub))
        true_prefix = a_true & (Nh - 1)
        for q, c in RATES:
            for pre in {best_prefix, true_prefix}:
                L = (N - Nh) * 1.0 + fit_counts(int(msub[pre]), Nh, q)
                u = (2.0 ** -v) * (1 - q) + (1 - 2.0 ** -v) * 0.5 if pre == true_prefix else 0.5
                progs.append((3 + gamma(v) + (d - v) + c, L, f"F2 v={v} pre={pre} q={q:g}", u))
    # F3 (best parity a' = a_best, also a_true): memorise j of its mismatches
    for ap in {a_best, a_true}:
        mm = int(m[ap])
        for j in range(1, mm + 1):
            base = 3 + d + gamma(j) + math.ceil(log2C(N, j) - 1e-12)
            for q, c in RATES:
                L = fit_counts(mm - j, N - j, q)
                if not math.isfinite(L):
                    continue
                u = ((N - j) / N) * (1 - q) if ap == a_true else 0.5
                progs.append((base + c, L, f"F3 a'={ap} j={j} q={q:g}", u))
    # F4
    progs.append((3 + N, 0.0, "F4 table", float(np.mean(y == parity_table(a_true, d)))))
    # F5 junta rule
    if rule is not None:
        mrule, S = rule
        inS = np.array([(x & (2 ** mrule - 1)) in S for x in range(N)])
        f = parity_table(a_true, d)
        pred = f ^ inS.astype(np.int64)
        mis = int((pred != y).sum())
        base = 3 + d + gamma(mrule) + gamma(len(S)) + math.ceil(log2C(2 ** mrule, len(S)) - 1e-12)
        for q, c in RATES:
            L = fit_counts(mis, N, q)
            u = float(np.mean((1 - q) * (~inS) + q * inS))
            progs.append((base + c, L, f"F5 a'={a_true} rule m={mrule} |S|={len(S)} q={q:g}", u))
    # keep only finite fits
    return [p for p in progs if math.isfinite(p[1])]


def hull(points):
    """vertices (indices into points) of the lower-left convex hull; points = list of (l, L)."""
    pts = sorted(set((l, L) for l, L in points))
    # Pareto
    par = []
    best = math.inf
    for l in sorted(set(l for l, _ in pts)):
        Lm = min(L for ll, L in pts if ll == l)
        if Lm < best - TOL:
            par.append((l, Lm))
            best = Lm
    # lower hull by monotone chain on Pareto points (they are decreasing in L)
    H_ = []
    for p in par:
        while len(H_) >= 2:
            (x1, y1), (x2, y2) = H_[-2], H_[-1]
            # remove H_[-1] if it is on or above segment H_[-2] -> p
            if (y2 - y1) * (p[0] - x1) >= (p[1] - y1) * (x2 - x1) - TOL:
                H_.pop()
            else:
                break
        H_.append(p)
    return H_


def analyse(name, d, p, y, a_true, rule=None, verbose=True):
    N = 2 ** d
    progs = build(d, y, a_true, rule)
    pts = [(l, L) for l, L, _, _ in progs]
    V = hull(pts)
    S = [(V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0]) for i in range(1, len(V))]
    out = {}

    def who(v):
        return [pr for pr in progs if pr[0] == v[0] and abs(pr[1] - v[1]) < TOL]

    def map_at(lam):
        J = [lam * l + L for l, L in pts]
        mn = min(J)
        return [progs[i] for i in range(len(progs)) if J[i] <= mn + 1e-7]

    # brute-force check of the vertex intervals
    sig = [math.inf] + S + [0.0]
    mism = 0
    for i, v in enumerate(V):
        lo, hi = sig[i + 1], sig[i]
        for lam in ([lo * 1.00001 + 1e-7, (lo + hi) / 2, hi * 0.99999] if math.isfinite(hi) else [lo + 1e-6, lo + 10, lo * 10 + 100]):
            if lam <= 0:
                continue
            got = set((pr[0], round(pr[1], 6)) for pr in map_at(lam))
            if got != {(v[0], round(v[1], 6))}:
                mism += 1
    out["mismatch"] = mism
    if verbose:
        print(f"--- {name}: d={d} N={N} p={p:g} |E|={int(round(p * N)) if rule is None else '-'} a={a_true}; "
              f"{len(progs)} programs; Kraft(rate code)={kraft_rates():.4f}")
        print(f"    product hull: {len(V)} vertices; brute-force interval mismatches: {mism}")
        for i, v in enumerate(V):
            lab = who(v)[0]
            lev = next((t for t in range(1, 40) if lab[3] > 0.5 + 2.0 ** (-t - 1)), math.inf)
            print(f"      v{i}: l={v[0]:4d} L={v[1]:10.2f}  lambda in ({sig[i + 1]:9.4g}, {sig[i]:9.4g})  "
                  f"level={lev}  {lab[2]}")
    # good model
    lg = 3 + d + next(c for q, c in RATES if abs(q - p) < 1e-15)
    Lg = fit_counts(int(round(p * N)), N, p) if rule is None else None
    if rule is None:
        K = min(l + L for l, L in pts)
        b0 = lg + Lg - K
        out.update(lg=lg, Lg=Lg, K=K, b0=b0)
        res = []
        for w in (0, 1, 2, 3, 5, 8):
            sh = [(L - Lg) / (lg - l) for l, L in pts if l < lg - w]
            sw = min(sh)
            th = [(Lg - L) / (l - lg) for l, L in pts if l > lg + w]
            tw = max([0.0] + th)
            # Cor 3.3(b) check on a lambda grid in (1, sw)
            ok = True
            ngrid = 0
            if sw > 1:
                for lam in np.unique(np.concatenate([np.geomspace(1.0001, sw * 0.9999, 60), [1 + (sw - 1) / 2]])):
                    for pr in map_at(lam):
                        l, L = pr[0], pr[1]
                        c1 = lg - w - 1e-9 <= l <= lg + b0 / (lam - 1) + 1e-9
                        c2 = Lg - lam * b0 / (lam - 1) - 1e-6 <= L <= Lg + lam * w + 1e-6
                        c3 = l + L - K <= b0 + (lam - 1) * w + 1e-6
                        ok = ok and c1 and c2 and c3
                    ngrid += 1
            res.append((w, sw, tw, ok, ngrid))
        out["kinks"] = res
        if verbose:
            print(f"    good model (a, q=p): l_g={lg}, fit=N H(p)={Lg:.2f}; class K=min(l+L)={K:.2f}; b0={b0:.2f}")
            for w, sw, tw, ok, ng in res:
                print(f"      window {w}: left steepness {sw:8.4g}, right flatness {tw:6.4f}; "
                      f"Cor 3.3(b) bounds on {ng} lambdas in (1, sigma): {ok}")
    # level-1 (parity-knowing) lambda range and exact-rate range
    # 'parity + noise': a vertex whose programs include the true parity with a flip rate and nothing
    # memorised (family F1, a' = a); the memoriser (L = 0) and partial memorisers are excluded
    lev1 = [i for i, v in enumerate(V) if any(pr[2].startswith(f"F1 a'={a_true} ") for pr in who(v))]
    if lev1:
        lo = sig[max(lev1) + 1]
        hi = sig[min(lev1)]
        out["lev1"] = (lo, hi)
    exact = [i for i, v in enumerate(V) if any(("q=%g" % p) in pr[2] and pr[2].startswith("F1") for pr in who(v))]
    out["exact"] = (sig[exact[0] + 1], sig[exact[0]]) if exact else None
    m1 = map_at(1.0)
    out["lam1"] = sorted(set(pr[2] for pr in m1))
    if verbose:
        print(f"    parity + noise (F1, a'=a) vertices: lambda in {out.get('lev1')}; exact-rate good model: lambda in {out['exact']}")
        print(f"    lambda = 1 MAP: {out['lam1']}")
    return out, progs, V, S


def set_models(d, p, y, a_true, verbose=True):
    N = 2 ** d
    s0 = int(round(p * N))
    LE = log2C(N, s0)
    sets = [(3 + gamma(d), float(N), "all strings")]
    for v in range(0, d + 1):
        sets.append((3 + gamma(d) + gamma(v + 1) + (d - v) + gamma(s0), v + LE, f"A_v v={v}"))
    for j in range(1, s0 + 1):
        sets.append((3 + gamma(d) + d + gamma(s0) + gamma(j) + math.ceil(log2C(N, j) - 1e-12),
                     log2C(N - j, s0 - j), f"memo-set j={j}"))
    sets.append((3 + N, 0.0, "singleton"))
    pts = [(l, L) for l, L, _ in sets]
    V = hull(pts)
    S = [(V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0]) for i in range(1, len(V))]
    Kset = min(l + L for l, L in pts)
    A0 = next(s for s in sets if s[2] == f"A_v v={d}")
    defA0 = A0[0] + A0[1] - Kset
    # Prop 4.4 class form: every left kink at alpha0 > len(A0) + w has sigma <= 1 + def/(alpha0 - len(A0))
    worst = -math.inf
    nk = 0
    for a in range(0, max(l for l, _ in pts) + 2):
        r = min([L for l, L in pts if l <= a], default=math.inf)
        if not math.isfinite(r):
            continue
        for w in (0, 1, 3):
            if not a - w > A0[0]:
                continue
            sh = [(L - r) / (a - l) for l, L in pts if l < a - w]
            sstar = min(sh)
            bound = 1 + defA0 / (a - A0[0])
            worst = max(worst, sstar - bound)
            nk += 1
    if verbose:
        sig = [math.inf] + S + [0.0]
        print(f"    set hull: {len(V)} vertices")
        for i, v in enumerate(V):
            lab = [s[2] for s in sets if s[0] == v[0] and abs(s[1] - v[1]) < TOL][0]
            print(f"      v{i}: K={v[0]:4d} log|A|={v[1]:10.2f} lambda in ({sig[i + 1]:9.4g}, {sig[i]:9.4g})  {lab}")
        for lam in (1.01, 1.1, 1.5, 2, 5, 20):
            J = [lam * l + L for l, L in pts]
            i = int(np.argmin(J))
            print(f"      set lambda-MAP at lambda={lam:<5}: {sets[i][2]}")
        print(f"    Prop 4.4 (class form): def(A_0) = {defA0:.2f}; over {nk} (alpha0, w) left kinks, "
              f"max(sigma* - bound) = {worst:.3g} (<= 0 required)")
    return worst


def main():
    print("rB2: explicit product class on the full noisy-parity table (referee B)")
    print(f"rate-code Kraft sum {kraft_rates():.4f}; family tags 3 bits; total Kraft <= 5/8 * max family Kraft <= 1")
    summary = []
    for d, p in [(6, 1 / 16), (8, 1 / 16), (8, 1 / 32), (8, 1 / 8), (8, 3 / 16), (10, 1 / 32), (10, 1 / 16), (10, 1 / 8), (10, 3 / 16)]:
        for rep in range(2):
            N = 2 ** d
            a = int(rng.integers(1, N))
            E = rng.choice(N, size=int(round(p * N)), replace=False)
            y = parity_table(a, d)
            y[E] ^= 1
            verbose = rep == 0
            out, progs, V, S = analyse(f"instance d={d} p={p:g} rep={rep}", d, p, y, a, verbose=verbose)
            worst = set_models(d, p, y, a, verbose=verbose)
            k0 = out["kinks"][0]
            summary.append((d, p, rep, out.get("lev1"), out["exact"], k0[1], k0[2], out["lam1"], out["mismatch"], worst))
    print()
    print("summary: d, p, rep | parity+noise lambda range | exact-rate (pi_g) range | sigma_0, tau_0 at pi_g | lambda=1 MAP | mismatches | Prop4.4 slack")
    for d, p, rep, l1, ex, s0, t0, lam1, mm, worst in summary:
        l1s = f"({l1[0]:.4g}, {l1[1]:.4g})" if l1 else "none"
        exs = f"({ex[0]:.4g}, {ex[1]:.4g})" if ex else "never a vertex"
        print(f"  d={d:2d} p={p:<7g} rep={rep} | {l1s:20s} | {exs:20s} | {s0:7.4g}, {t0:6.4f} | {lam1[0][:28]:28s} | {mm} | {worst:.3g}")
    # set models: dependence of the set kink at alpha ~ d on the code for v (O(log d) terms)
    print()
    print("set models, A_v family only (A_0 := A_v with v = d, all parities; A_{v=0} knows the parity):")
    print("  slope of the set hull between A_0 and the parity-knowing set, and the set lambda-range of the")
    print("  parity-knowing set, under two prefix codes for v: Elias gamma(v+1) (this script) and a fixed")
    print("  ceil(log2(d+1))-bit code (checks/k2_parity_class.py)")
    for d in (8, 10, 12, 16, 20, 24, 30):  # lgamma differences lose precision beyond d ~ 30
        for code in ("gamma", "fixed"):
            N = 2 ** d
            s0 = N // 16
            LE = log2C(N, s0)
            vlen = (lambda v: gamma(v + 1)) if code == "gamma" else (lambda v: math.ceil(math.log2(d + 1)))
            pts = [(3 + gamma(d), float(N))] + [(3 + gamma(d) + vlen(v) + (d - v) + gamma(s0), v + LE) for v in range(d + 1)]
            pts += [(3 + gamma(d) + d + gamma(s0) + gamma(j) + math.ceil(log2C(N, j) - 1e-12), log2C(N - j, s0 - j))
                    for j in sorted(set([1, 2, 4, 8, s0 // 4, s0 // 2, s0]))]
            pts.append((3 + N, 0.0))
            V = hull(pts)
            Sl = [(V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0]) for i in range(1, len(V))]
            sig = [math.inf] + Sl + [0.0]
            know = (3 + gamma(d) + vlen(0) + d + gamma(s0), LE)
            iv = [i for i, v in enumerate(V) if v[0] == know[0] and abs(v[1] - know[1]) < 1e-9]
            rng_ = f"({sig[iv[0] + 1]:.6f}, {sig[iv[0]]:.6f})" if iv else "not a vertex"
            print(f"    d={d:3d} p=1/16 code={code:5s}: parity-knowing set is a set-hull vertex for lambda in {rng_}; "
                  f"Prop 4.4-type scale 1 + 2log2(d)/d = {1 + 2 * math.log2(d) / d:.3f}")
    # two-kink instance: parity xor junta rule xor random flips
    print()
    d, mrule = 8, 5
    N = 2 ** d
    a = int(rng.integers(1, N))
    S = set(int(s) for s in rng.choice(2 ** mrule, size=2, replace=False))
    y = parity_table(a, d)
    inS = np.array([(x & (2 ** mrule - 1)) in S for x in range(N)])
    y = y ^ inS.astype(np.int64)
    E = rng.choice(N, size=12, replace=False)
    y[E] ^= 1
    out, progs, V, Sl = analyse(f"two-kink instance: rule m={mrule} |S|=2 plus 12 random flips", d, 0.0, y, a,
                                rule=(mrule, S), verbose=True)


if __name__ == "__main__":
    main()
