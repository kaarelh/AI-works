"""k2: hulls and lambda-MAPs for ALL lambda in an exactly enumerable product class on the full truth
table of a noisy random parity (notes.md Section 4, Illustration), with set models for comparison.

Class (prefix codes with Kraft sum <= 1, checked): a 3-bit family tag, then
  F0 constant Bernoulli(q);                      F1 parity a' (d bits) with flip rate q;
  F2 partial parity: a' known on its first d-v coordinates, per-input uniform mixture over the
     2^v completions, flip rate q;                F3 partial memoriser: parity a', a set M of j
     inputs (index among binom(N,j)) with the label f_a' xor 1 deterministic, rate q elsewhere;
  F4 the full lookup table (N bits);             F5 (part F only) parity a' plus a junta rule
     S in {0,1}^m (index among binom(2^m,s)): the target is f_a' xor 1 on S x {0,1}^(d-m),
     with rate q.
Rate code: 1 flag bit (deterministic) or flag + gamma(b) + (b-1) bits for q = j/2^b, j odd, b<=12.
Integer code gamma(k) = 2 floor(log2(k+1)) + 1 bits.
For each family and each choice of the length-determining parameters, the best fit over the
length-neutral parameters (the memorised set, the junta rule, the rate at a given precision) is
computed exactly (the fit is convex in q, so the best grid rate brackets the continuous optimum),
so the computed rho is the exact structure function of this class.

(A) Hull vertices, their lambda-intervals and the lambda-MAP for all lambda; brute-force check of
    the hull prediction on a dense lambda grid including every breakpoint +- 1e-9 relative.
(B) The good model's vertex: left steepness sigma, right steepness tau, the lambda-range (tau, sigma)
    on which the lambda-MAP is "parity + noise"; the MAP at lambda = 1.
(C) Thm 3.2 cross-check: from the class's own sigma (min secant to shorter programs) and the
    sufficiency-type right kink, predicted MAP lengths vs actual.
(D) Set models (parity known up to v coordinates + exactly s0 flips; partial-memoriser sets;
    trivial set; singleton): hull slopes; no kink near alpha ~ d; set lambda-MAPs.
(E) Several flip rates and d = 8, 10.
(F) Two kinks: teacher = parity xor (junta rule on S x {0,1}^(d-m)) xor sparse random flips;
    lambda-intervals of coin / parity+noise / parity+rule+noise / memoriser.
Deterministic: random.seed(2), numpy default_rng(2).
"""
import math
import random
import numpy as np

random.seed(2)
rng = np.random.default_rng(2)
TAG = 3
BMAX = 12


def gam(k):
    return 2 * int(math.floor(math.log2(k + 1))) + 1


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


def H2(q):
    return 0.0 if q in (0.0, 1.0) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


RATES = [(b, (1 + gam(b) + b - 1)) for b in range(1, BMAX + 1)]  # (precision, code length)
kraft_rate = 2.0 ** -1 + sum(2 ** (b - 1) * 2.0 ** -L for b, L in RATES)
assert kraft_rate <= 1.0


def bern_fit(k, n, q):
    """-log2 of q^k (1-q)^(n-k)."""
    if q == 0.0:
        return 0.0 if k == 0 else math.inf
    if q == 1.0:
        return 0.0 if k == n else math.inf
    return -(k * math.log2(q) + (n - k) * math.log2(1 - q))


def best_rate_fits(k, n):
    """[(rate code length, best fit, q)] for the deterministic flag and each precision b."""
    out = [(1, bern_fit(k, n, 0.0), 0.0)]
    qs = k / n if n else 0.0
    for b, L in RATES:
        den = 2 ** b
        lo = int(math.floor(qs * den))
        cands = set()
        for j in (lo - 1, lo, lo + 1, lo + 2):
            if 0 < j < den and j % 2 == 1:
                cands.add(j)
        if not cands:
            cands = {1, den - 1}
        best = min((bern_fit(k, n, j / den), j / den) for j in cands)
        out.append((L, best[0], best[1]))
    return out


def parity_table(d, a):
    N = 2 ** d
    x = np.arange(N, dtype=np.int64)
    v = x & a
    par = np.zeros(N, dtype=np.int64)
    while v.any():
        par ^= (v & 1)
        v >>= 1
    return par


class Best:
    """the structure function of a class: for each length, the least fit and one program attaining it."""

    def __init__(self):
        self.d = {}

    def add(self, l, fit, lab):
        cur = self.d.get(l)
        if cur is None or fit < cur[0]:
            self.d[l] = (fit, lab)

    def add_arrays(self, ls, fits, labs):
        ls = np.asarray(ls)
        fits = np.asarray(fits, dtype=float)
        order = np.lexsort((fits, ls))
        ls, fits = ls[order], fits[order]
        labs = [labs[i] for i in order]
        uniq, first = np.unique(ls, return_index=True)
        for u, f in zip(uniq, first):
            self.add(int(u), float(fits[f]), labs[f])

    def points(self):
        return sorted((l, f, lab) for l, (f, lab) in self.d.items())


def rate_arrays(rem, n):
    """vectorised best_rate_fits: rem, n int arrays; returns list over rate options of
    (code length, fit array, q array)."""
    rem = np.asarray(rem, dtype=float)
    n = np.asarray(n, dtype=float)
    out = [(1, np.where(rem == 0, 0.0, np.inf), np.zeros_like(rem))]
    qs = np.where(n > 0, rem / np.maximum(n, 1), 0.0)
    for b, L in RATES:
        den = 2 ** b
        c1 = np.floor(qs * den)
        c1 = np.where(c1 % 2 == 0, c1 - 1, c1)
        best = np.full(rem.shape, np.inf)
        bq = np.zeros(rem.shape)
        for c in (c1, c1 + 2):
            c = np.clip(c, 1, den - 1)
            q = c / den
            with np.errstate(divide="ignore", invalid="ignore"):
                f = -(rem * np.log2(q) + (n - rem) * np.log2(1 - q))
            upd = f < best
            best = np.where(upd, f, best)
            bq = np.where(upd, q, bq)
        out.append((L, best, bq))
    return out


def build_class(d, ystar, with_junta=None, partial_mem=True):
    """list of (length, least fit, label): the exact structure function of the class."""
    N = 2 ** d
    B = Best()
    n1 = int(ystar.sum())
    for c in (0, 1):
        B.add(TAG + 2, 0.0 if (ystar == c).all() else math.inf, ("F0 const", c))
    for L, fit, q in best_rate_fits(n1, N)[1:]:
        B.add(TAG + L, fit, ("F0 Bern", q))
    tables = {ap: parity_table(d, ap) for ap in range(N)}
    mism = {ap: int((tables[ap] != ystar).sum()) for ap in range(N)}
    for ap in range(N):
        for L, fit, q in best_rate_fits(mism[ap], N):
            B.add(TAG + d + L, fit, ("F1", ap, q))
    for v in range(1, d + 1):
        known_mask = (1 << (d - v)) - 1
        xs = np.arange(N)[(np.arange(N) & ~known_mask) == 0]
        for pref in range(2 ** (d - v)):
            k = int((tables[pref][xs] != ystar[xs]).sum())
            for L, fit, q in best_rate_fits(k, len(xs)):
                B.add(TAG + gam(v) + (d - v) + L, fit + (N - len(xs)), ("F2", v, pref, q))
    if partial_mem:
        for ap in range(N):
            k = mism[ap]
            if k == 0:
                continue
            j = np.arange(1, k + 1)
            base = np.array([TAG + d + gam(int(jj)) + math.ceil(log2binom(N, int(jj))) for jj in j])
            for L, fit, q in rate_arrays(k - j, N - j):
                labs = [("F3", ap, int(jj), float(qq)) for jj, qq in zip(j, q)]
                B.add_arrays(base + L, fit, labs)
    B.add(TAG + gam(d) + N, 0.0, ("F4 table",))
    if with_junta is not None:
        for ap in range(N):
            dis = (tables[ap] != ystar).astype(np.int64)
            for m in range(1, with_junta + 1):
                blocks = dis.reshape(2 ** m, 2 ** (d - m)).sum(axis=1)
                gain = (2 * blocks - 2 ** (d - m))
                order = np.sort(gain)[::-1]
                for s in range(1, 2 ** m):
                    k = int(dis.sum() - order[:s].sum())
                    base = TAG + d + gam(m) + gam(s) + math.ceil(log2binom(2 ** m, s))
                    for L, fit, q in best_rate_fits(k, N):
                        B.add(base + L, fit, ("F5", ap, m, s, q))
    return B.points()


def kraft_check(d, junta=None):
    N = 2 ** d
    tot = 2.0 ** -TAG * (2 * 2.0 ** -2 + sum(2 ** (b - 1) * 2.0 ** -L for b, L in RATES))  # F0
    tot += 2.0 ** -TAG * kraft_rate                                                        # F1
    tot += 2.0 ** -TAG * sum(2.0 ** -gam(v) for v in range(1, d + 1)) * kraft_rate         # F2
    tot += 2.0 ** -TAG * sum(2.0 ** (math.log2(math.comb(N, j)) - gam(j) - math.ceil(log2binom(N, j)))
                             for j in range(1, N + 1)) * kraft_rate                        # F3
    tot += 2.0 ** -(TAG + gam(d))                                                          # F4
    if junta is not None:
        tot += 2.0 ** -TAG * sum(2.0 ** -gam(m) * sum(
            2.0 ** (math.log2(math.comb(2 ** m, s)) - gam(s) - math.ceil(log2binom(2 ** m, s)))
            for s in range(1, 2 ** m)) for m in range(1, junta + 1)) * kraft_rate
    return tot


def fmt(lab):
    if isinstance(lab, str):
        return lab
    t = lab[0]
    if t == "F1":
        return f"F1 a'={lab[1]} q={lab[2]:.4g}"
    if t == "F2":
        return f"F2 v={lab[1]} pref={lab[2]} q={lab[3]:.4g}"
    if t == "F3":
        return f"F3 a'={lab[1]} j={lab[2]} q={lab[3]:.4g}"
    if t == "F5":
        return f"F5 a'={lab[1]} m={lab[2]} s={lab[3]} q={lab[4]:.4g}"
    return " ".join(str(x) if not isinstance(x, float) else f"{x:.4g}" for x in lab)


def gift_wrap(points, tol=1e-9):
    fin = [(l, L, lab) for (l, L, lab) in points if L < math.inf]
    a0 = min(l for l, _, _ in fin)
    r0 = min(L for l, L, _ in fin if l == a0)
    V = [(a0, r0)]
    S = []
    while True:
        a, r = V[-1]
        right = [(l, L) for (l, L, _) in fin if l > a]
        if not right:
            break
        sl = max((r - L) / (l - a) for (l, L) in right)
        if sl <= tol:
            break
        anext = max(l for (l, L) in right if (r - L) / (l - a) >= sl * (1 - 1e-12) - 1e-12)
        V.append((anext, r - sl * (anext - a)))
        S.append(sl)
    labs = []
    for (a, r) in V:
        labs.append([lab for (l, L, lab) in fin if l == a and abs(L - r) <= 1e-7 * max(1, r)])
    return V, S, labs


def map_bruteforce(points, lam):
    fin = [(lam * l + L, (l, L, lab)) for (l, L, lab) in points if L < math.inf]
    best = min(j for j, _ in fin)
    arg = [x for j, x in fin if j <= best + 1e-9 * max(1.0, abs(best))]
    return best, arg


def vertex_for(V, S, lam):
    s = [math.inf] + S + [0.0]
    for i in range(len(V)):
        if s[i + 1] < lam < s[i]:
            return i
    return None


def report_hull(V, S, labs, title, maxrows=40):
    print(f"  {title}: {len(V)} vertices")
    s = [math.inf] + S + [0.0]
    for i, ((a, r), lab) in enumerate(zip(V, labs)):
        if i < maxrows or i == len(V) - 1:
            short = fmt(lab[0]) if lab else "?"
            print(f"    v{i:<3d} l={a:6.0f} fit={r:10.2f}  lambda in ({s[i+1]:10.4g}, {s[i]:10.4g})  "
                  f"[{len(lab)} prog] {short}")


def check_all_lambdas(points, V, S):
    lams = list(np.geomspace(1e-3, 1e6, 400))
    for sl in S:
        lams += [sl * (1 - 1e-7), sl * (1 + 1e-7)]
    bad = 0
    for lam in lams:
        _, arg = map_bruteforce(points, lam)
        i = vertex_for(V, S, lam)
        if i is None:
            continue
        a, r = V[i]
        if not all(l == a and abs(L - r) <= 1e-6 * max(1, r) for (l, L, _) in arg):
            bad += 1
    return len(lams), bad


def secants(points, a0, r0):
    left = [(r - r0) / (a0 - l) for (l, r, _) in points if l < a0 and r < math.inf]
    right = [(r0 - r) / (l - a0) for (l, r, _) in points if l > a0 and r < math.inf]
    return (min(left) if left else math.inf), max([0.0] + right)


def run_instance(d, s0, seed, partial_mem=True, verbose=True):
    rs = np.random.default_rng(seed)
    N = 2 ** d
    a = int(rs.integers(1, N))
    E = rs.choice(N, s0, replace=False)
    ystar = parity_table(d, a).copy()
    ystar[E] ^= 1
    p = s0 / N
    pts = build_class(d, ystar, partial_mem=partial_mem)
    V, S, labs = gift_wrap(pts)
    print("-" * 100)
    print(f"d={d} N={N} |E|={s0} (p={p:.4g}) a={a}: {len(pts)} (length, best-fit) entries; "
          f"Kraft sum of the class = {kraft_check(d):.4f}")
    if verbose:
        report_hull(V, S, labs, "product hull")
    nl, bad = check_all_lambdas(pts, V, S)
    print(f"  brute-force lambda-MAP vs hull prediction on {nl} lambdas: {bad} mismatches")
    # vertices that know the parity (F1 with a'=a, any rate): their union of lambda-intervals is the
    # range on which the lambda-MAP is "parity + noise"; the last of them has the best rate
    good = [i for i, lab in enumerate(labs) if any(x[0] == "F1" and x[1] == a for x in lab)]
    s = [math.inf] + S + [0.0]
    if good:
        gi = good[-1]
        assert good == list(range(good[0], good[-1] + 1))
        a0, r0 = V[gi]
        sig, tau = s[good[0]], s[gi + 1]
        lsec, rsec = secants(pts, a0, r0)
        print(f"  parity-knowing vertices v{good[0]}..v{gi}: lambda-MAP is 'parity + noise' exactly for "
              f"lambda in ({tau:.4g}, {sig:.4g}); best-rate one v{gi}: l={a0}, fit={r0:.2f} "
              f"(N H(p) = {N*H2(p):.2f}), its own interval ({s[gi+1]:.4g}, {s[gi]:.4g}) "
              f"[min left secant {lsec:.4g}, max right secant {rsec:.4g}]")
    else:
        print("  no vertex knows the parity")
        gi = None
        sig = tau = None
    _, arg1 = map_bruteforce(pts, 1.0)
    print(f"  lambda=1 MAP: {[fmt(x[2]) for x in arg1][:3]} l={arg1[0][0]} fit={arg1[0][1]:.2f}")
    for lam in (0.5, 0.9, 1.1, 1.5, 2, 5, 20, 100):
        _, arg = map_bruteforce(pts, lam)
        print(f"    lambda={lam:<5}: MAP {fmt(arg[0][2]):<28s} l={arg[0][0]:5.0f} fit={arg[0][1]:9.2f}")
    return dict(d=d, s0=s0, p=p, V=V, S=S, labs=labs, gi=gi, sig=sig, tau=tau, pts=pts, a=a, E=E,
                ystar=ystar)


print("=" * 100)
print("(A)-(C) product class on the full table of a noisy random parity")
res = run_instance(8, 16, seed=11)

# (C) Thm 3.2 cross-check with the class's own constants
print("-" * 100)
print("(C) kink theorem with the class's own constants (good model as reference point)")
pts, V, gi = res["pts"], res["V"], res["gi"]
a0, r0 = V[gi]
for w in (0, 2, 4, 8):
    left = [(r - r0) / (a0 - l) for (l, r, _) in pts if l < a0 - w and r < math.inf]
    sig_w = min(left) if left else math.inf
    right = [(r0 - r) / (l - a0) for (l, r, _) in pts if l > a0 + w and r < math.inf]
    tau_w = max([0.0] + right)
    ok = True
    worst = None
    for lam in np.geomspace(max(tau_w, 1e-3) * 1.0001, sig_w * 0.9999, 60) if sig_w > tau_w else []:
        _, arg = map_bruteforce(pts, lam)
        for (l, L, _) in arg:
            if not (a0 - w <= l <= a0 + w and L <= r0 + lam * (a0 - l) + 1e-6):
                ok = False
    print(f"  window w={w}: left steepness sigma_w={sig_w:.4g}, right flatness tau_w={tau_w:.4g}; "
          f"all lambda-MAPs for lambda in (tau_w, sigma_w) within [l0-w, l0+w] and fit bound: {ok}")

print("=" * 100)
print("(D) set models for the same data (lengths assigned by the same codes; log-sizes exact)")
d, s0, N = res["d"], res["s0"], 2 ** res["d"]
LE = log2binom(N, s0)
spts = []
VLEN = math.ceil(math.log2(d + 1))   # fixed-length code for v in {0..d}
for v in range(0, d + 1):   # A_v: parity known up to v coordinates, exactly s0 flips anywhere
    spts.append((TAG + VLEN + (d - v) + gam(s0), v + LE, f"A_v v={v}"))
for j in range(1, s0 + 1):  # partial-memoriser sets: parity known, j flips named, s0-j anywhere else
    spts.append((TAG + d + gam(j) + math.ceil(log2binom(N, j)) + gam(s0),
                 log2binom(N - j, s0 - j), f"memo-set j={j}"))
spts.append((TAG + gam(d), float(N), "all strings"))
spts.append((TAG + gam(d) + N, 0.0, "singleton"))
SV, SS, slabs = gift_wrap(spts)
report_hull(SV, SS, slabs, "set-model hull")
# set structure function vs product structure function on a grid of alpha
def struct(points, alpha):
    vals = [L for (l, L, _) in points if l <= alpha and L < math.inf]
    return min(vals) if vals else math.inf
print("  alpha : product rho_D(alpha)   set h_z(alpha)")
for alpha in [5, 8, 10, 12, 14, 16, 18, 20, 24, 30, 40, 60, 100, 150]:
    print(f"   {alpha:4d} : {struct(res['pts'], alpha):12.2f}   {struct(spts, alpha):12.2f}")
for lam in (1.05, 1.2, 1.5, 2, 5, 20):
    _, arg = map_bruteforce(spts, lam)
    print(f"  set lambda-MAP at lambda={lam:<5}: {fmt(arg[0][2]):<16s} l={arg[0][0]} log|A|={arg[0][1]:.2f}")
# largest left steepness of the set hull at any vertex with alpha in [TAG+gam(d)+3, d+TAG+gam(s0)]
s = [math.inf] + SS + [0.0]
mid = [(i, SV[i][0], s[i]) for i in range(len(SV)) if TAG + VLEN + gam(s0) < SV[i][0] <= d + TAG + VLEN + gam(s0)]
print(f"  set-hull vertices with alpha in (A_d's length, A_0's length]: "
      + ", ".join(f"v{i} (alpha={al}, left slope {sl:.3f})" for i, al, sl in mid))

print("=" * 100)
print("(E) other flip rates and d")
summary = []
for (d_, s_, seed) in [(8, 8, 21), (8, 32, 22), (8, 48, 23), (10, 32, 24), (10, 64, 25), (10, 128, 26)]:
    r = run_instance(d_, s_, seed, partial_mem=True, verbose=False)
    summary.append((d_, s_, r["p"], r["sig"], r["tau"]))
print("  summary: d, |E|, p, good-model lambda-range (tau, sigma), N(1-H(p))/d for scale")
for d_, s_, p_, sg, ta in summary:
    if sg is None:
        print(f"   d={d_:2d} |E|={s_:4d} p={p_:.4f}: good model not a vertex")
    else:
        print(f"   d={d_:2d} |E|={s_:4d} p={p_:.4f}: ({ta:.4g}, {sg:.4g})   N(1-H(p))/d = {2**d_*(1-H2(p_))/d_:.4g}")

print("=" * 100)
print("(F) two kinks: parity xor junta rule (m=6, |S|=2, so 1/32 of inputs) xor 16 random flips")
d, m = 8, 6
N = 2 ** d
rs = np.random.default_rng(31)
a = int(rs.integers(1, N))
Srule = rs.choice(2 ** m, 2, replace=False)
ystar = parity_table(d, a).copy()
blk = np.arange(N) >> (d - m)
ystar[np.isin(blk, Srule)] ^= 1
flips = rs.choice(N, 16, replace=False)
ystar[flips] ^= 1
pts = build_class(d, ystar, with_junta=m, partial_mem=True)
print(f"  Kraft sum of the class = {kraft_check(d, junta=m):.4f}; {len(pts)} entries")
V, S, labs = gift_wrap(pts)
report_hull(V, S, labs, "product hull (two kinks)")
nl, bad = check_all_lambdas(pts, V, S)
print(f"  brute-force lambda-MAP vs hull prediction on {nl} lambdas: {bad} mismatches")
for lam in (0.5, 1.0, 1.2, 1.5, 2, 3, 5, 10, 20, 50):
    _, arg = map_bruteforce(pts, lam)
    print(f"    lambda={lam:<5}: MAP {fmt(arg[0][2]):<34s} l={arg[0][0]:5.0f} fit={arg[0][1]:9.2f}")
