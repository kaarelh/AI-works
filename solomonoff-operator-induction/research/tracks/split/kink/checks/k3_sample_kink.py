"""k3: a sample from nu has a kink at the shortest nu-equivalent length (notes.md Section 5).

Domain X0 = {0,1}^16 (M = 65536 inputs); n inputs drawn uniformly WITHOUT replacement; labels from
the true sampler nu = noisy parity (a*, p = 1/8), a program pi* of the class.
Class (prefix codes as in k2, Kraft sum <= 1): 3-bit tag, then
  F0 Bernoulli(q) constants; F1 parity a' (all 2^16) with rate q; F2 partial parities (a' known on
  its first 16-v coordinates, per-input mixture over the completions, rate q; all v, all prefixes);
  F3 partial memorisers for the parity a* (j named inputs, index among binom(M, j), label f xor 1
  deterministic there, rate q elsewhere); F4 the full table.
Rate code: deterministic flag, or q = j/2^b (j odd), b <= 12.

For each n and seed:
  * L0 = -log nu(D_n); rho_{D_n} at every length (exact for this class, via Walsh-Hadamard
    transforms for all parities); the left/right steepness of the point (l0, L0), l0 = l(pi*);
  * Lemma 5.2 (uniform Hellinger bound): S = min over F0, F1, F2 and the best F3 programs of
    (L(pi) - L0 - 2 log2(e) n h(pi) + 2 l(pi)) / 2, with h(pi) = E_mu Hel(nu, nu_pi) exact;
    the lemma says P[S <= -t] <= 2^-t;
  * Ville (Lemma split:ville, fixed n): T = min_alpha (rho(alpha) + alpha) - L0 (exact over the
    class); P[T <= -t] <= 2^-t;
  * Thm 5.4 predictions vs the actual hull: (l0, L0) a vertex, left steepness >= sigma_n bound,
    right steepness <= tau_L bound, and the lambda-MAP = pi* for lambda in the actual interval;
  * Cor 5.5 and Thm 5.6: the sample size n0(lambda, eps) after which every lambda-MAP is pi* w.p. >= 1-2eps,
    against the empirical frequency.
Also the margins gamma_- (programs shorter than l0) and gamma_L.
Seeded: numpy default_rng(3).
"""
import math
import numpy as np

rng = np.random.default_rng(3)
TAG, BMAX, d = 3, 12, 16
M = 2 ** d
LOG2E = math.log2(math.e)


def gam(k):
    return 2 * int(math.floor(math.log2(k + 1))) + 1


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


RATES = [(b, 1 + gam(b) + b - 1) for b in range(1, BMAX + 1)]


def rate_grid():
    """all rates with their code length (excluding the deterministic flag)."""
    out = []
    for b, L in RATES:
        for j in range(1, 2 ** b, 2):
            out.append((j / 2 ** b, L))
    return out


GRID = rate_grid()
GQ = np.array([q for q, _ in GRID])
GL = np.array([L for _, L in GRID])


def hel_bern(p, q):
    """squared Hellinger 1 - sum sqrt between Bern(p) and Bern(q) (q may be 0 or 1)."""
    return 1 - math.sqrt(p * q) - math.sqrt((1 - p) * (1 - q))


def fits_matrix(k, n):
    """fit of k 'events' among n under every grid rate: array [len(k), len(GRID)]."""
    k = np.asarray(k, dtype=float)[:, None]
    n = np.asarray(n, dtype=float)
    if n.ndim:
        n = n[:, None]
    return -(k * np.log2(GQ)[None, :] + (n - k) * np.log2(1 - GQ)[None, :])


def wht(v):
    v = v.astype(np.int64).copy()
    h = 1
    while h < len(v):
        v = v.reshape(-1, 2 * h)
        a, b = v[:, :h].copy(), v[:, h:].copy()
        v[:, :h], v[:, h:] = a + b, a - b
        v = v.reshape(-1)
        h *= 2
    return v


def popparity(x):
    x = x.copy()
    par = np.zeros_like(x)
    while x.any():
        par ^= x & 1
        x >>= 1
    return par


p = 1 / 8
astar = int(rng.integers(1, M))
ell0 = TAG + d + dict(RATES)[3]   # pi* = F1(a*, q=1/8): rate precision b=3
print(f"d={d}, M={M}, p={p}, a*={astar}, l0 = l(pi*) = {ell0}")

# ----- exact Hellinger gaps h(pi) for the families (independent of the sample) -----
Hs = np.array([hel_bern(p, q) for q in GQ])          # same orientation as the truth
Hd = np.array([hel_bern(p, 1 - q) for q in GQ])      # opposite orientation
Hhalf = hel_bern(p, 0.5)
# F0 Bern(q) of label 1: the truth gives label 1 w.p. p or 1-p on half of the inputs each
h_F0 = 0.5 * np.array([hel_bern(p, q) for q in GQ]) + 0.5 * np.array([hel_bern(1 - p, q) for q in GQ])
h_F1_true = Hs                       # a' = a*
h_F1_other = 0.5 * Hs + 0.5 * Hd     # a' != a*: f differs on exactly half of X0


def h_F2(v, same):
    """partial parity with v unknown top coordinates: on the 2^-v subcube it predicts a parity that
    equals the truth's restriction (same=True) or differs on half the subcube; elsewhere 1/2."""
    sub = Hs if same else 0.5 * Hs + 0.5 * Hd
    return 2.0 ** -v * sub + (1 - 2.0 ** -v) * Hhalf


def h_F3(j, q_idx):
    """memorises j inputs (label f xor 1 with probability 1), rate GQ elsewhere, parity a*."""
    return (j / M) * (1 - math.sqrt(p)) + (1 - j / M) * Hs[q_idx]


# every program of the class up to length LCAP, as (length, h, number of programs), exact
LCAP = 200
ENTRIES = []
hdet_true = 1 - math.sqrt(1 - p)                     # deterministic f_a*
hdet_other = 0.5 * (1 - math.sqrt(1 - p)) + 0.5 * (1 - math.sqrt(p))
for idx, (q, Lq) in enumerate(GRID):
    ENTRIES.append((TAG + Lq, h_F0[idx], 1))
    ENTRIES.append((TAG + d + Lq, h_F1_true[idx], 1))
    ENTRIES.append((TAG + d + Lq, h_F1_other[idx], M - 1))
ENTRIES.append((TAG + 2, hdet_other, 2))              # deterministic constants
ENTRIES.append((TAG + d + 1, hdet_true, 1))
ENTRIES.append((TAG + d + 1, hdet_other, M - 1))
for v in range(1, d + 1):
    base = TAG + gam(v) + (d - v)
    hs_true, hs_other = h_F2(v, True), h_F2(v, False)
    for idx, (q, Lq) in enumerate(GRID):
        ENTRIES.append((base + Lq, hs_true[idx], 1))
        ENTRIES.append((base + Lq, hs_other[idx], 2 ** (d - v) - 1))
    ENTRIES.append((base + 1, 2.0 ** -v * hdet_true + (1 - 2.0 ** -v) * Hhalf, 1))
    ENTRIES.append((base + 1, 2.0 ** -v * (0.5 * hdet_true + 0.5 * (1 - math.sqrt(p))) + (1 - 2.0 ** -v) * Hhalf,
                    2 ** (d - v) - 1))
for j in range(1, 40):
    base = TAG + d + gam(j) + math.ceil(log2binom(M, j))
    if base > LCAP:
        break
    cnt = math.comb(M, j)
    for idx, (q, Lq) in enumerate(GRID):
        ENTRIES.append((base + Lq, h_F3(j, idx), cnt))
    ENTRIES.append((base + 1, (j / M) * (1 - math.sqrt(p)) + (1 - j / M) * hdet_true, cnt))
ENTRIES = [e for e in ENTRIES if e[0] <= LCAP]
assert sum(1 for l, h, c in ENTRIES if h < 1e-15) == 1      # pi* is the only equivalent program


def margin(Lmax, strict=False):
    """least positive h among programs of length <= Lmax (< Lmax if strict)."""
    return min(h for l, h, c in ENTRIES if h > 1e-15 and (l < Lmax if strict else l <= Lmax))


def gamma_at(l):
    hs = [h for ll, h, c in ENTRIES if ll == l and h > 1e-15]
    return min(hs) if hs else math.inf


def W_near(lam, gamma, Llam):
    """sum over near programs (0 < h < gamma) with l0 < l <= L_lambda of 2^(-lambda (l - l0))."""
    return sum(c * 2.0 ** (-lam * (l - ell0)) for l, h, c in ENTRIES
               if 1e-15 < h < gamma and ell0 < l <= Llam)


gamma_minus = margin(ell0, strict=True)
gamma0 = margin(ell0)
print(f"margin gamma_- (programs shorter than l0) = {gamma_minus:.5f}; gamma_0 (length <= l0) = {gamma0:.5f}")
for L in [ell0, ell0 + 2, ell0 + 5, ell0 + 10, ell0 + 20]:
    print(f"margin gamma_L at L = {L}: {margin(L):.3e}")
print("margin profile gamma(l) for l < l0: " + ", ".join(f"{l}:{gamma_at(l):.3g}" for l in range(4, ell0)
                                                       if gamma_at(l) < math.inf))


x_all = np.arange(M)
f_star = popparity(x_all & astar)


# group boundaries of GRID by precision b (GL is constant within a group)
GSTART = np.r_[0, np.cumsum([2 ** (b - 1) for b, _ in RATES])[:-1]]
GLEN = np.array([L for _, L in RATES])


def per_precision_min(fitvec):
    return np.minimum.reduceat(fitvec, GSTART)


def one_run(n, rs):
    xs = rs.choice(M, n, replace=False)
    flip = rs.random(n) < p
    ys = f_star[xs] ^ flip.astype(np.int64)
    kstar = int(flip.sum())
    L0 = kstar * math.log2(1 / p) + (n - kstar) * math.log2(1 / (1 - p))
    best = {}  # length -> least fit

    def put(l, fit):
        if fit < best.get(l, math.inf):
            best[l] = fit

    def put_vec(base, fitvec):
        for Lb, fb in zip(GLEN, per_precision_min(fitvec)):
            put(base + int(Lb), float(fb))

    def slack(fitvec, hvec, lvec):
        return float(np.min((fitvec - L0 - 2 * LOG2E * n * hvec + 2 * lvec) / 2))

    S = math.inf
    # F0
    n1 = int(ys.sum())
    put(TAG + 2, 0.0 if n1 in (0, n) else math.inf)
    f0 = fits_matrix([n1], n)[0]
    put_vec(TAG, f0)
    S = min(S, slack(f0, h_F0, TAG + GL))
    # F1: mismatches of every parity via WHT; fit is linear in k, so extremes suffice per rate
    g = np.zeros(M, dtype=np.int64)
    g[xs] = 1 - 2 * ys
    k_all = (n - wht(g)) // 2
    k_true = int(k_all[astar])
    k_other = np.delete(k_all, astar)
    Ft = fits_matrix([k_true], n)[0]
    Fo = fits_matrix([int(k_other.min()), int(k_other.max())], n).min(axis=0)
    put_vec(TAG + d, np.minimum(Ft, Fo))
    put(TAG + d + 1, 0.0 if k_all.min() == 0 else math.inf)
    S = min(S, slack(Ft, h_F1_true, TAG + d + GL), slack(Fo, h_F1_other, TAG + d + GL))
    # F2: partial parities (unknown coordinates = the top v bits)
    for v in range(1, d + 1):
        sub = (xs >> (d - v)) == 0
        nsub = int(sub.sum())
        base = TAG + gam(v) + (d - v)
        if nsub == 0:
            put(base + 1, float(n))
            fv = np.zeros(len(GRID)) + n
            S = min(S, slack(fv, h_F2(v, True), base + GL), slack(fv, h_F2(v, False), base + GL))
            put_vec(base, fv)
            continue
        gsub = np.zeros(2 ** (d - v), dtype=np.int64)
        gsub[xs[sub]] = 1 - 2 * ys[sub]
        ksub = (nsub - wht(gsub)) // 2
        pref_true = astar & ((1 << (d - v)) - 1)
        Ftv = fits_matrix([int(ksub[pref_true])], nsub)[0] + (n - nsub)
        kot = np.delete(ksub, pref_true)
        S = min(S, slack(Ftv, h_F2(v, True), base + GL))
        allf = Ftv
        if len(kot):
            Fov = fits_matrix([int(kot.min()), int(kot.max())], nsub).min(axis=0) + (n - nsub)
            S = min(S, slack(Fov, h_F2(v, False), base + GL))
            allf = np.minimum(Ftv, Fov)
        put_vec(base, allf)
        put(base + 1, (n - nsub) + (0.0 if ksub.min() == 0 else math.inf))
    # F3 (parity a*): memorise j of the kstar sample flips
    for j in range(1, kstar + 1):
        base = TAG + d + gam(j) + math.ceil(log2binom(M, j))
        fj = fits_matrix([kstar - j], n - j)[0]
        put_vec(base, fj)
        put(base + 1, 0.0 if j == kstar else math.inf)
        hj = (j / M) * (1 - math.sqrt(p)) + (1 - j / M) * Hs
        S = min(S, slack(fj, hj, base + GL))
    put(TAG + gam(d) + M, 0.0)
    pts = sorted((l, f) for l, f in best.items() if f < math.inf)
    T = min(f + l for l, f in pts) - L0
    left = [(f - L0) / (ell0 - l) for l, f in pts if l < ell0]
    right = [(L0 - f) / (l - ell0) for l, f in pts if l > ell0]
    sminus = min(left)
    splus = max([0.0] + right)
    is_vertex = all(f > L0 - 1e-9 for l, f in pts if l < ell0) and abs(best.get(ell0, math.inf) - L0) < 1e-6 \
        and sminus > splus
    lflat = max(l for l, _ in pts)
    for l, f in pts:
        if l > ell0 and f < L0 - 1e-9:
            lflat = l - 1
            break
    return dict(L0=L0, S=S, T=T, sminus=sminus, splus=splus, is_vertex=is_vertex, kstar=kstar, lflat=lflat)


eps = 0.05
NS = [64, 256, 1024, 4096, 16384]
SEEDS = 200
print("=" * 100)
print(f"{SEEDS} samples per n; eps = {eps}")
summary = {}
for n in NS:
    rs = np.random.default_rng(1000 + n)
    runs = [one_run(n, rs) for _ in range(SEEDS)]
    Sv = np.array([r["S"] for r in runs])
    Tv = np.array([r["T"] for r in runs])
    sm = np.array([r["sminus"] for r in runs])
    sp = np.array([r["splus"] for r in runs])
    vert = np.array([r["is_vertex"] for r in runs])
    summary[n] = runs
    lfl = np.array([r["lflat"] for r in runs])
    print(f"n={n:6d}: vertex at (l0, L0) in {vert.mean()*100:5.1f}% of samples; rho = L0 on [l0, l_flat] with "
          f"median l_flat = {np.median(lfl):.0f} (min {lfl.min()})")
    print(f"          "
          f"left steepness median {np.median(sm):9.2f} (min {sm.min():8.2f}); "
          f"right steepness median {np.median(sp):.3f} (max {sp.max():.3f})")
    for t in [1, 2, 3, 4, 6]:
        print(f"     t={t}: P[S <= -t] = {np.mean(Sv <= -t):.3f}, P[T <= -t] = {np.mean(Tv <= -t):.3f}  (bound 2^-t = {2.0**-t:.3f})")
    # Theorem 5.4 bounds on the left steepness (only meaningful when positive)
    A = 2 * LOG2E * n * gamma_minus - 2 * math.log2(1 / eps)
    sig_bound = A / ell0 if A >= 2 * ell0 else float("nan")
    ok = np.mean(sm >= sig_bound) if not math.isnan(sig_bound) else float("nan")
    prof = min((2 * LOG2E * n * gamma_at(l) - 2 * l - 2 * math.log2(1 / eps)) / (ell0 - l)
               for l in range(0, ell0) if gamma_at(l) < math.inf)
    okp = np.mean(sm >= prof)
    print(f"     Thm 5.4 left-steepness bounds: uniform sigma_n = {sig_bound:.2f} (holds in "
          f"{ok*100 if ok==ok else float('nan'):.1f}%), profile {prof:.2f} (holds in {okp*100:.1f}%); guaranteed >= {100*(1-eps):.0f}%")
    for L in [ell0 + 5, ell0 + 10, ell0 + 20]:
        gL = margin(L)
        need = (L + math.log2(1 / eps)) / (LOG2E * gL)
        tauL = 1 + (ell0 + math.log2(1 / eps)) / (L - ell0)
        okr = np.mean(sp <= tauL)
        print(f"     L={L}: gamma_L={gL:.2e}, flat part guaranteed once n > {need:.3g}; right-steepness bound "
              f"tau_L = {tauL:.3f} holds in {okr*100:.1f}%")

print("=" * 100)
print("Cor 5.5 (single margin) and Thm 5.6 (near/far split): sample sizes after which every lambda-MAP is pi*")
print("  with probability >= 1 - 2 eps (Cor 5.5) or >= 1 - 2 eps - W_near (Thm 5.6, gamma = gamma_0),")
print("  against the empirical frequency that pi*'s point is the unique lambda-MAP point")
for lam in [1.5, 2, 4, 8]:
    Llam = ell0 + (ell0 + math.log2(1 / eps)) / (lam - 1)
    gL = margin(Llam)
    n0 = (max(0.0, 2 - lam) * Llam + lam * ell0 + 2 * math.log2(1 / eps)) / (2 * LOG2E * gL)
    n0near = (max(0.0, 2 - lam) * Llam + lam * ell0 + 2 * math.log2(1 / eps)) / (2 * LOG2E * gamma0)
    Wn = W_near(lam, gamma0, Llam)
    freq = []
    for n in NS:
        hit = np.mean([(r["is_vertex"] and r["splus"] < lam < r["sminus"]) for r in summary[n]])
        freq.append(f"n={n}: {hit:.3f}")
    print(f"  lambda={lam}: L_lambda={Llam:.1f}; Cor 5.5: gamma_L={gL:.2e}, n0={n0:.3g}; Thm 5.6: n0={n0near:.4g}, "
          f"W_near={Wn:.3g}, guaranteed prob >= {1 - 2*eps - Wn:.3f}")
    print("        empirical: " + ", ".join(freq))
    opts = []
    for g in [gamma0, 5e-3, 2e-3, 1e-3, 5e-4, 2e-4, 1e-4]:
        n0g = (max(0.0, 2 - lam) * Llam + lam * ell0 + 2 * math.log2(1 / eps)) / (2 * LOG2E * g)
        opts.append(f"gamma={g:.0e}: n0={n0g:.3g}, prob>={1 - 2*eps - W_near(lam, g, Llam):.3f}")
    print("        Thm 5.6 for smaller gamma: " + "; ".join(opts))
