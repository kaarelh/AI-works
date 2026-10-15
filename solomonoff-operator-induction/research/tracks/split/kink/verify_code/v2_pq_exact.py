"""v2: exact check of kink/notes-final.md section 5 in the per-query scheme (pq):
Lemma 5.1 (pq), Lemma 5.2, Lemma 5.3(a), (b), Theorem 5.4(i)-(iii), Corollary 5.5.

Written for `../../verify-kink.md`; shares no code with checks/k3, k6 or referee_code/.

Method.  Atomic input law mu on X = {0,1,2,3} with mu(3) = 0 (so programs may differ from nu at x = 3 and
still be equivalent), Y = {0,1}, fresh label at every query.  The per-query fit F(pi) and S_n depend on the
sample only through the counts of the six pairs (x, y) with mu(x) > 0, so every probability below is an
exact sum over count vectors with multinomial weights (float64; the bounds tested have slack far above
rounding).  Lemma 5.3(b) is a statement about all n at once; its finite-horizon form (max over m <= n) is
checked by enumerating every path of length n <= 7.

Classes.
  * B: a hand-built class (Kraft sum printed) with far programs up to length 5, two shortest equivalent
    programs of length 3 (they differ from nu only at the null input 3), nu itself at length 4, and near,
    sub-probability and deterministic programs at lengths 6-8.  Chosen so that the hypotheses of
    Thm 5.4(iii) and Cor 5.5 hold at the enumerated sample sizes.
  * C: 40 random classes (random kernels with zeros and sub-probabilities, random Kraft-valid lengths), each
    containing nu, for the probability bounds of Lemmas 5.1-5.3.
Seeded: numpy.random.default_rng(31) for class C.  Python 3.11.
"""
import itertools
import math

import numpy as np

LOG2E = math.log2(math.e)
MU = np.array([1 / 2, 3 / 8, 1 / 8, 0.0])
NU1 = np.array([1 / 8, 1 / 2, 7 / 8, 1 / 2])            # nu(1 | x)
CATS = [(x, y) for x in range(3) for y in (0, 1)]        # pairs with positive probability
Q = np.array([MU[x] * (NU1[x] if y == 1 else 1 - NU1[x]) for x, y in CATS])


def kern(p1, p0=None):
    """kernel on X as (nu_pi(1|x), nu_pi(0|x)) per x; p0 defaults to 1 - p1."""
    p1 = list(p1)
    p0 = [1 - a for a in p1] if p0 is None else list(p0)
    return np.array([p1, p0]).T                          # shape (4, 2): [x] -> (P(1), P(0))


TRUE = kern(NU1)


def hel_x(K):
    """Hellinger gap at each x: 1 - sum_y sqrt(nu nu_pi)."""
    return 1 - (np.sqrt(TRUE[:, 0] * K[:, 0]) + np.sqrt(TRUE[:, 1] * K[:, 1]))


def gamma(K):
    return float(np.dot(MU, hel_x(K)))


def neglog_cat(K):
    """-log2 nu_pi(y | x) for the six categories (inf where 0)."""
    out = []
    for x, y in CATS:
        v = K[x, 0] if y == 1 else K[x, 1]
        out.append(math.inf if v == 0 else -math.log2(v))
    return np.array(out)


def class_B():
    P = []
    t = NU1.copy()
    P.append(("A: det. 1 at x0", 2, kern([1, t[1], t[2], t[3]])))
    e = t.copy(); e[3] = 0.9
    P.append(("e3: nu except at null x3", 3, kern(e)))
    e2 = t.copy(); e2[3] = 0.1
    P.append(("e3b: nu except at null x3, sub-prob there", 3, kern(e2, [1 - t[0], 1 - t[1], 1 - t[2], 0.5])))
    P.append(("B: swapped rates", 3, kern([7 / 8, 1 / 2, 1 / 8, 1 / 2])))
    P.append(("pi*: nu", 4, kern(t)))
    P.append(("C: det. 1 at x0, det. 0 at x2", 4, kern([1, t[1], 0, t[3]])))
    P.append(("D: 0.97 at x0, 0.97 at x1", 5, kern([0.97, 0.97, t[2], t[3]])))
    for d0 in (-1 / 32, 1 / 32):
        P.append((f"near x0 {d0:+.4f}", 6, kern([t[0] + d0, t[1], t[2], t[3]])))
    P.append(("near x2 -1/32", 6, kern([t[0], t[1], t[2] - 1 / 32, t[3]])))
    P.append(("sub-prob 0.95 nu", 6, kern(0.95 * t, 0.95 * (1 - t))))
    for d0 in (-1 / 64, 1 / 64):
        P.append((f"near x0 {d0:+.4f}", 7, kern([t[0] + d0, t[1], t[2], t[3]])))
    P.append(("det. 1 at x1", 7, kern([t[0], 1, t[2], t[3]])))
    P.append(("det. 0 at x1", 7, kern([t[0], 0, t[2], t[3]])))
    P.append(("fully det. 0,1,1", 8, kern([0, 1, 1, 0])))
    P.append(("near x1 +1/64", 8, kern([t[0], t[1] + 1 / 64, t[2], t[3]])))
    P.append(("near x0,x2", 8, kern([t[0] + 1 / 64, t[1], t[2] - 1 / 64, t[3]])))
    P.append(("sub-prob 0.99 nu", 8, kern(0.99 * t, 0.99 * (1 - t))))
    return P


def random_class(rng):
    P = [("pi*: nu", int(rng.integers(1, 6)), kern(NU1))]
    m = int(rng.integers(4, 16))
    for _ in range(m):
        p1 = rng.random(4)
        p1[rng.random(4) < 0.1] = 0.0
        p1[rng.random(4) < 0.1] = 1.0
        mass = np.where(rng.random(4) < 0.3, rng.uniform(0.5, 1.0, 4), 1.0)
        K = kern(p1 * mass, (1 - p1) * mass)
        if rng.random() < 0.2:                            # an equivalent program (differs only at x3)
            K = TRUE.copy(); K[3] = [rng.random() * 0.5, rng.random() * 0.5]
        P.append(("rnd", int(rng.integers(1, 9)), K))
    kr = sum(2.0 ** -l for _, l, _ in P)
    if kr > 1:                                            # shift lengths until Kraft <= 1
        sh = math.ceil(math.log2(kr))
        P = [(nm, l + sh, K) for nm, l, K in P]
    return P


def count_vectors(n):
    """all 6-tuples of nonnegative ints summing to n, with log multinomial weights."""
    vs = []
    for c in itertools.combinations(range(n + 5), 5):
        prev, v = -1, []
        for b in c:
            v.append(b - prev - 1)
            prev = b
        v.append(n + 5 - prev - 1)
        vs.append(v)
    V = np.array(vs, dtype=np.int64)
    lw = np.array([math.lgamma(n + 1) - sum(math.lgamma(k + 1) for k in v) for v in vs])
    return V, lw


def setup(P):
    lens = np.array([l for _, l, _ in P])
    NL = np.array([neglog_cat(K) for _, _, K in P])      # (programs, 6)
    gam = np.array([gamma(K) for _, _, K in P])
    equiv = gam < 1e-15
    return lens, NL, gam, equiv


def fits(V, NL):
    """F[v, pi] = sum_c V[v, c] * NL[pi, c], with 0 * inf = 0."""
    F = np.zeros((V.shape[0], NL.shape[0]))
    np.seterr(invalid="ignore")                          # 0 * inf inside the masked branch
    for c in range(6):
        col = NL[:, c][None, :]
        k = V[:, c][:, None]
        F += np.where(k > 0, k * np.where(np.isinf(col), np.inf, col), 0.0)
    return F


def probs(V, lw):
    lq = np.log(Q)
    return np.exp(lw + V @ lq)


def S_of(V):
    """S_n = F(nu), computed by the same routine as every other fit (so equivalent programs tie exactly)."""
    return fits(V, neglog_cat(TRUE)[None, :])[:, 0]


print("=" * 100)
P = class_B()
lens, NL, gam, equiv = setup(P)
kraft = float(np.sum(2.0 ** -lens))
lstar = int(lens[equiv].min())
Estar = np.where(equiv & (lens == lstar))[0]
print(f"class B: {len(P)} programs, Kraft sum {kraft:.6f}; l* = {lstar}; E* = {[P[i][0] for i in Estar]}")
for (nm, l, K), g in zip(P, gam):
    print(f"    l={l}  gamma={g:.5f}  {nm}")
assert kraft <= 1


def gamma_eq(l):
    sel = (lens == l) & ~equiv
    return float(gam[sel].min()) if sel.any() else math.inf


def gamma_le(L):
    sel = (lens <= L) & ~equiv
    return float(gam[sel].min()) if sel.any() else math.inf


print("=" * 100)
print("(1) Lemma 5.1 (pq): E sqrt(Lambda_n) = (1 - gamma)^n and E Lambda_n <= 1, exactly over count vectors")
worst_id = worst_m = 0.0
for n in range(1, 9):
    V, lw = count_vectors(n)
    pr = probs(V, lw)
    assert abs(pr.sum() - 1) < 1e-12
    F = fits(V, NL)
    S = S_of(V)
    Lam = np.exp2(S[:, None] - F)
    Es = pr @ np.sqrt(Lam)
    El = pr @ Lam
    worst_id = max(worst_id, float(np.max(np.abs(Es - (1 - gam) ** n))))
    worst_m = max(worst_m, float(El.max()))
    # equivalent programs: Lambda = 1 on every count vector of positive probability
    assert np.all(Lam[:, equiv] == 1.0)
print(f"  class B, n = 1..8: max |E sqrt(Lambda_n) - (1-gamma)^n| = {worst_id:.2e}; max E Lambda_n = {worst_m:.6f} (<= 1);"
      " equivalent programs have Lambda_n = 1 on every sample (asserted)")
assert worst_id < 1e-12 and worst_m <= 1 + 1e-12

print("=" * 100)
print("(2) Lemmas 5.2 and 5.3(a): exact failure probabilities against eps (class B, and 40 random classes C)")


def lemma_fail(V, lw, lens, NL, gam, n, eps):
    pr = probs(V, lw)
    F = fits(V, NL)
    S = S_of(V)
    a52 = 2 * LOG2E * n * gam[None, :] - 2 * lens[None, :] - 2 * math.log2(1 / eps)
    fail52 = np.any(F - S[:, None] <= a52, axis=1)
    fail53 = np.any(F <= S[:, None] - lens[None, :] - math.log2(1 / eps), axis=1)
    return float(pr[fail52].sum()), float(pr[fail53].sum())


rows = []
for n in (2, 4, 8, 12, 16):
    V, lw = count_vectors(n)
    for eps in (0.9, 0.5, 0.2, 0.05):
        f52, f53 = lemma_fail(V, lw, lens, NL, gam, n, eps)
        rows.append((n, eps, f52, f53))
        assert f52 <= eps and f53 <= eps
print("  class B: n, eps, Pr[Lemma 5.2 event fails], Pr[Lemma 5.3(a) event fails]")
for n, eps, a, b in rows:
    print(f"    n={n:2d} eps={eps:4.2f}: {a:.5f}  {b:.5f}")
rng = np.random.default_rng(31)
worst52 = worst53 = 0.0
ncase = 0
for k in range(40):
    Pc = random_class(rng)
    lc, NLc, gc, _ = setup(Pc)
    for n in (1, 3, 6, 10):
        V, lw = count_vectors(n)
        for eps in (0.9, 0.5, 0.2):
            f52, f53 = lemma_fail(V, lw, lc, NLc, gc, n, eps)
            worst52 = max(worst52, f52 / eps)
            worst53 = max(worst53, f53 / eps)
            ncase += 1
print(f"  40 random classes C, {ncase} (class, n, eps) cases: largest Pr[fail]/eps is {worst52:.4f} (Lemma 5.2) and "
      f"{worst53:.4f} (Lemma 5.3(a)); <= 1 required")
assert worst52 <= 1 and worst53 <= 1

print("=" * 100)
print("(3) Lemma 5.3(b), finite horizon: Pr[max_{m<=n} delta_m >= j] <= 2^-j, all paths of length 7 (class B)")
n = 7
paths = np.array(list(itertools.product(range(6), repeat=n)))
lp = np.log(Q)[paths].sum(axis=1)
ppath = np.exp(lp)
ratio = np.zeros((len(P), 6))
for i, (_, _, K) in enumerate(P):
    for c, (x, y) in enumerate(CATS):
        ratio[i, c] = (K[x, 0] if y == 1 else K[x, 1]) / (NU1[x] if y == 1 else 1 - NU1[x])
w = 2.0 ** -lens
cur = np.ones((paths.shape[0], len(P)))
mx = np.full(paths.shape[0], math.log2(w.sum()))
for m in range(n):
    cur = cur * ratio[:, paths[:, m]].T
    mx = np.maximum(mx, np.log2(cur @ w))
for j in (0.5, 1, 2, 3, 4):
    pj = float(ppath[mx >= j].sum())
    print(f"    j={j}: Pr = {pj:.5f}  vs 2^-j = {2 ** -j:.5f}")
    assert pj <= 2 ** -j

print("=" * 100)
print("(4) Theorem 5.4 (i)-(iii) and Corollary 5.5, class B: on the events of Lemmas 5.2 and 5.3(a), every")
print("    conclusion is checked on every count vector; exact probabilities of the conclusions are reported")


def secants(F, S):
    """left steepness s_- and right slope s_+ at (l*, S) for every count vector."""
    left = lens < lstar
    right = lens > lstar
    with np.errstate(invalid="ignore"):
        sl = (F[:, left] - S[:, None]) / (lstar - lens[left])[None, :]
        sr = (S[:, None] - F[:, right]) / (lens[right] - lstar)[None, :]
    s_minus = sl.min(axis=1) if left.any() else np.full(F.shape[0], np.inf)
    s_plus = np.maximum(0.0, sr.max(axis=1))
    return s_minus, s_plus


def map_set(F, lam):
    J = lam * lens[None, :] + F
    m = J.min(axis=1, keepdims=True)
    return np.isclose(J, m, rtol=0, atol=1e-9) | (J == m)


isE = np.zeros(len(P), dtype=bool)
isE[Estar] = True
for eps in (0.5, 0.25):
    for n in (8, 12, 16, 20, 24, 28, 32, 36):
        V, lw = count_vectors(n)
        pr = probs(V, lw)
        F = fits(V, NL)
        S = S_of(V)
        L1e = math.log2(1 / eps)
        ev52 = ~np.any(F - S[:, None] <= 2 * LOG2E * n * gam[None, :] - 2 * lens[None, :] - 2 * L1e, axis=1)
        ev53 = ~np.any(F <= S[:, None] - lens[None, :] - L1e, axis=1)
        both = ev52 & ev53
        s_minus, s_plus = secants(F, S)
        # (i) the profile steepness sigma_n and the second form
        num = [(2 * LOG2E * n * gamma_eq(l) - 2 * l - 2 * L1e) / (lstar - l) for l in range(lstar)]
        sig_n = min(num)
        A = 2 * LOG2E * n * min(gamma_eq(l) for l in range(lstar)) - 2 * L1e
        line = f"  eps={eps} n={n:2d}: sigma_n={sig_n:7.3f}"
        if sig_n > 0:
            assert np.all(s_minus[ev52] >= sig_n - 1e-9), "Thm 5.4(i)"
            line += f" (i) holds on the event, Pr[s_- >= sigma_n] = {pr[s_minus >= sig_n - 1e-9].sum():.4f}"
            if A >= 2 * lstar:
                assert sig_n >= A / lstar - 1e-12
        # (ii) right kinks for several tau
        for tau in (1.25, 2.0, 5.0):
            wnd = (lstar + L1e) / (tau - 1)
            sel = lens > lstar + wnd
            if sel.any():
                ok = np.all(F[:, sel] >= S[:, None] - tau * (lens[sel] - lstar)[None, :] - 1e-9, axis=1)
                assert np.all(ok[ev53]), "Thm 5.4(ii)"
        # (iii) flat part, secants, vertex, MAP set = E*
        for lbar in (4, 5):
            g = gamma_le(lbar)
            if n > (lbar + L1e) / (LOG2E * g):
                tau_l = 1 + (lstar + L1e) / (lbar - lstar)
                short = (lens <= lbar)
                flat_ok = np.all(~(short[None, :] & (F <= S[:, None] + 1e-12)) | equiv[None, :], axis=1)
                assert np.all(flat_ok[both]), "Thm 5.4(iii) flat part"
                assert np.all(s_plus[both] < tau_l), "Thm 5.4(iii) secants"
                concl = flat_ok & (s_plus < tau_l)
                if sig_n > tau_l:
                    for lam in np.linspace(tau_l, sig_n, 5)[1:-1]:
                        ms = map_set(F, lam)
                        good = np.all(ms == isE[None, :], axis=1)
                        assert np.all(good[both]), "Thm 5.4(iii) MAP set"
                        concl &= good
                    assert np.all((s_plus[both] < tau_l) & (s_minus[both] > tau_l))
                line += f"; (iii) lbar={lbar}: applies, tau={tau_l:.2f}, Pr[concl.] = {pr[concl].sum():.4f} >= {1 - 2 * eps}"
                assert pr[concl].sum() >= 1 - 2 * eps
        # Cor 5.5
        for lam in (1.5, 2.0, 3.0, 4.0):
            lbl = lstar + (lstar + L1e) / (lam - 1)
            g = gamma_le(lbl)
            if 2 * LOG2E * n * g > max(0.0, 2 - lam) * lbl + lam * lstar + 2 * L1e:
                ms = map_set(F, lam)
                good = np.all(ms == isE[None, :], axis=1)
                assert np.all(good[both]), "Cor 5.5"
                assert pr[good].sum() >= 1 - 2 * eps
                line += f"; Cor 5.5 lam={lam}: Pr = {pr[good].sum():.4f}"
        line += f"; Pr[both events] = {pr[both].sum():.4f}"
        print(line)
print("  every assertion passed")
