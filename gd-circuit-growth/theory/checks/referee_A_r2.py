"""Referee round 2 checks for ../A-discrete-model.md (revision 2).  Independent code (does not import
race_bounds.py or A_r2_checks.py).  Runs in a few minutes on one core.

  1. Corollary A2.5(a'): population kappa_bar_1 = d via the Fourier matrix (d = 6, 8, 10) and on the full
     cube (d = 7); empirical kappa_bar_1 at d = 30 for other seeds; the (a') bound values.
  2. Corollary A2.5(a'): sample-distinct versus X-distinct gate counts.  A depth-one (LS) race on a small
     sample WITHOUT merging candidates that coincide on the sample: number of X-distinct fired functions
     versus |F_{<=1}| and floor(kappa_bar_1 x^2); does the min-norm predictor on X use the extra gates?
  3. Proposition A4.2(1)-(2): s* = 3 for maj3 by exhaustive search on d = 4 (an irrelevant input present);
     independent recount of the depth-two utilities after the first event (12 / 20 / 55).
  4. Independent (SC) race with exits (NNLS refits) on dictionaries with exact and negated duplicates and on
     real-valued dictionaries: Lemma 2.2(3), Theorem A2.3(2) for Sat and for supp c, Theorem A2.4.
     Independent depth-one (LS) race: Theorem A2.3(1) with ||R||_n in place of tau, for random subsets B.
  5. Theorems A3.1 / A3.5 constants: par2 numbers; the n_eff restatement; when the second (Gram) condition
     dominates the first (the Summary's b >~ T R^2 log / (lambda gamma^2) omits it).
  6. Theorem A3.5 Monte Carlo on a small population greedy run with T = 2 and a utility gap (d = 4 cube):
     failure frequency at the theorem's (n, b), and at much smaller (n, b).
  7. The Monte Carlo of A_r2_checks.py section 8 (par2, b = 16): XOR(x1,x2) is *an* argmax by
     Proposition A4.1's inequality on every batch; how often is it the *unique* argmax (up to sign, as a
     function on {-1,1}^30)?
"""
import itertools, math, os, sys, time
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import numpy as np
from scipy.optimize import nnls
from scipy.sparse.linalg import eigsh

T0 = time.time()
DELTA = 0.05


def AND(u, v):
    return np.where((u > 0) & (v > 0), 1.0, -1.0).astype(np.asarray(u).dtype)


LIB2 = [("AND(a,b)", lambda a, b: AND(a, b)), ("AND(~a,b)", lambda a, b: AND(-a, b)),
        ("AND(a,~b)", lambda a, b: AND(a, -b)), ("AND(~a,~b)", lambda a, b: AND(-a, -b)),
        ("XOR(a,b)", lambda a, b: a * b)]


def depth_one(X, ordered=False):
    """toy library depth-one gates on the columns of X: identities, then 5 binary types per pair."""
    n, d = X.shape
    cols, names = [], []
    for i in range(d):
        cols.append(X[:, i]); names.append(f"x{i+1}")
    pairs = itertools.permutations(range(d), 2) if ordered else itertools.combinations(range(d), 2)
    for i, j in pairs:
        for nm, f in LIB2:
            cols.append(f(X[:, i], X[:, j])); names.append(nm.replace("a", f"x{i+1}").replace("b", f"x{j+1}"))
    return np.stack(cols, 1), names


def canon(v):
    """key of a +-1 vector up to sign"""
    w = v if v[0] > 0 else -v
    return np.packbits(np.asarray(w) > 0).tobytes()


def merge(G):
    seen, keep = set(), []
    for m in range(G.shape[1]):
        v = G[:, m]
        if np.all(v == v[0]):
            continue
        k = canon(np.ascontiguousarray(v))
        if k in seen:
            continue
        seen.add(k); keep.append(m)
    return keep


def top_eig_centred(G):
    Gc = G - G.mean(0)
    n, M = Gc.shape
    if n < M:
        K = (Gc @ Gc.T) / n                          # same nonzero spectrum
    else:
        Gf = Gc.astype(np.float32)
        K = (Gf.T @ Gf).astype(np.float64) / n
    if K.shape[0] > 600:
        return float(eigsh(K, k=1, which="LA", return_eigenvectors=False)[0])
    return float(np.linalg.eigvalsh(K)[-1])


def log_phi(N, T):
    M = N - 1
    terms = [0.0]
    for i in range(1, min(T, M) + 1):
        terms.append(terms[-1] + math.log((M - i + 1) / i))
    mx = max(terms)
    return math.log(2) + mx + math.log(sum(math.exp(t - mx) for t in terms))


def L_T(T, G=6, d=30, k=2, delta=DELTA):
    W = sum(math.log(G) + k * math.log(d + t - 1) for t in range(1, T + 1))
    return W + log_phi(2 ** min(T, d), T) + math.log((T + 1) * (T + 2) / delta)


def realizable(T, n):
    return 1 - math.exp(-L_T(T) / n)


# =========================================================================== 1
print("## 1. Corollary A2.5(a'): library incoherence kappa_bar_1")
for d in [6, 8, 10]:
    chars = [(i,) for i in range(d)] + list(itertools.combinations(range(d), 2))
    idx = {c: j for j, c in enumerate(chars)}
    rows = []
    for i in range(d):
        a = np.zeros(len(chars)); a[idx[(i,)]] = 1; rows.append(a)
    for i, j in itertools.combinations(range(d), 2):
        for s, t in itertools.product([1, -1], repeat=2):       # AND(s x_i, t x_j) = (s x_i + t x_j + st x_i x_j - 1)/2
            a = np.zeros(len(chars)); a[idx[(i,)]] = s / 2; a[idx[(j,)]] = t / 2; a[idx[(i, j)]] = s * t / 2; rows.append(a)
        a = np.zeros(len(chars)); a[idx[(i, j)]] = 1; rows.append(a)  # XOR
    A = np.array(rows)
    ev = np.linalg.eigvalsh(A.T @ A)
    offdiag = np.max(np.abs(A.T @ A - np.diag(np.diag(A.T @ A))))
    print(f" Fourier route, d = {d}: {A.shape[0]} gates; max |off-diagonal of A^T A| = {offdiag:.1e};"
          f" diagonal values {sorted(set(np.round(np.diag(A.T @ A), 9)))}; top eigenvalue = {ev[-1]:.6f}")
d = 7
Xc = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
Gc_, _ = depth_one(Xc)
keep = merge(Gc_)
print(f" full cube d = 7: {len(keep)} distinct gates; kappa_bar_1(pop) = {top_eig_centred(Gc_[:, keep]):.6f} (claim: d = 7)")

kb = {}
for n in [4096, 16384]:
    vals = []
    for seed in [11, 12, 13]:
        rng = np.random.default_rng(seed)
        X = rng.choice([-1.0, 1.0], size=(n, 30)).astype(np.float32)
        G, _ = depth_one(X)
        kp = merge(G)
        vals.append(top_eig_centred(G[:, kp]))
        del G
    kb[n] = vals
    print(f" empirical d = 30, n = {n:5d}, seeds 11-13: kappa_bar_1 = {', '.join(f'{v:.2f}' for v in vals)}"
          f" (note: 34.97 / 32.42 for its seed)")
for n in [4096, 16384]:
    for x in [1.0, 1.5, 1.99]:
        Tb = [min(2205, int(math.floor(v * x * x))) for v in kb[n]]
        print(f"   (a') n = {n:5d}, x = {x}: T_bar = {Tb}, realizable A1 bound = "
              + ", ".join(f"{realizable(T, n):.3f}" for T in Tb))
print(f" A1 at T = 1: n = 4096 {realizable(1, 4096):.4f}, n = 16384 {realizable(1, 16384):.4f}")
print(f"  [{time.time() - T0:.0f}s]")

# =========================================================================== 2
print("\n## 2. Corollary A2.5(a'): gates distinct on X but equal on the sample (no merging)")
d = 6
Xcube = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
Gcube, names = depth_one(Xcube)
rng = np.random.default_rng(3)
worst = None
for trial in range(200):
    n = 4
    rows = rng.choice(len(Xcube), size=n, replace=False)
    Gs = Gcube[rows]
    y_cube = Xcube[:, 0] * Xcube[:, 1]                              # par2 target
    y = y_cube[rows]
    if np.all(y == y[0]):
        continue
    r = y - y.mean()
    U = Gs.T @ r / n
    umax = np.max(np.abs(U))
    fired = np.where(np.abs(np.abs(U) - umax) < 1e-12)[0]           # first event of the race on S
    Xdist = len({canon(np.ascontiguousarray(Gcube[:, m])) for m in fired})
    Sdist = len({canon(np.ascontiguousarray(Gs[:, m])) for m in fired})
    F1 = merge(Gs)
    kbar = top_eig_centred(Gs[:, F1])
    x = 1.0 / umax * math.sqrt(np.mean(r ** 2))                     # ||R||_n / Theta at the event (Theta = 1)
    Tbar = min(len(F1), int(math.floor(kbar * x * x)))
    # min-norm LS refit over all fired gates (no merging) vs over one representative per sample class
    F = np.column_stack([np.ones(n), Gs[:, fired]])
    c = np.linalg.pinv(F) @ y
    h_all = np.sign(np.column_stack([np.ones(len(Xcube)), Gcube[:, fired]]) @ c)
    reps, seen = [], set()
    for m in fired:
        k = canon(np.ascontiguousarray(Gs[:, m]))
        if k not in seen:
            seen.add(k); reps.append(m)
    c1 = np.linalg.pinv(np.column_stack([np.ones(n), Gs[:, reps]])) @ y
    h_rep = np.sign(np.column_stack([np.ones(len(Xcube)), Gcube[:, reps]]) @ c1)
    rec = (Xdist - Tbar, trial, Xdist, Sdist, len(F1), round(kbar, 2), round(x, 3), Tbar,
           float(np.mean(h_all != h_rep)))
    if worst is None or rec[0] > worst[0]:
        worst = rec
print(f" d = 6, n = 4, par2 target, first event, 200 samples: worst case X-distinct fired = {worst[2]},"
      f" sample-distinct fired = {worst[3]}, |F_<=1| = {worst[4]}, kappa_bar_1 = {worst[5]}, x = {worst[6]},"
      f" T_bar = {worst[7]}")
print(f"   X-distinct fired gates exceed T_bar by {worst[0]}; the min-norm predictor over all fired gates differs"
      f" from the one-representative predictor on {worst[8]:.3f} of the cube")
print("   => (a') bounds the sample-distinct count; it bounds A1's T only if the race merges candidates that"
      " coincide (up to sign) on the sample and the readout uses one representative per class.")

# =========================================================================== 3
print("\n## 3. Proposition A4.2: maj3 with the toy library on d = 4 (x4 irrelevant)")
X4 = np.array(list(itertools.product([-1.0, 1.0], repeat=4)))
maj = np.sign(X4[:, 0] + X4[:, 1] + X4[:, 2])
UN = [lambda a: a]
BIN = [f for _, f in LIB2]
inputs = [X4[:, i] for i in range(4)]
# threshold functions of 1 and 2 Boolean variables (sign readouts)
def thresh2(g1, g2):
    out = []
    for w0 in np.linspace(-3, 3, 13):
        for w1 in [-2, -1, 0, 1, 2]:
            for w2 in [-2, -1, 0, 1, 2]:
                v = w0 + 0.01 + w1 * g1 + w2 * g2
                out.append(np.where(v > 0, 1.0, -1.0))
    return out
one_gate = []
for a in inputs:
    one_gate.append(a)
for a, b in itertools.product(inputs, repeat=2):
    for f in BIN:
        one_gate.append(f(a, b))
found1 = any(np.array_equal(h, maj) for g in one_gate for h in [g, -g])
found2 = False
for g1 in one_gate:
    srcs = inputs + [g1]
    g2s = list(srcs) + [f(a, b) for a, b in itertools.product(srcs, repeat=2) for f in BIN]
    for g2 in g2s:
        for h in thresh2(g1, g2):
            if np.array_equal(h, maj):
                found2 = True; break
        if found2: break
    if found2: break
print(f" exhaustive (ordered sources with repeats, sign readout): 1-gate consistent: {found1}; 2-gate consistent: {found2}")
# depth-two utilities after the first event
fired = [X4[:, i] for i in range(3)]
for i, j in itertools.combinations(range(3), 2):
    fired += [AND(X4[:, i], X4[:, j]), AND(-X4[:, i], -X4[:, j])]
Fm = np.column_stack([np.ones(16)] + fired)
r = maj - Fm @ np.linalg.lstsq(Fm, maj, rcond=None)[0]
print(f" residual = -x1x2x3/2: {np.allclose(r, -X4[:, 0] * X4[:, 1] * X4[:, 2] / 2)}")
srcs = inputs + fired[3:]                     # identity gates duplicate inputs
fired_keys = {canon(np.ascontiguousarray(g)) for g in fired}
d1keys = {canon(np.ascontiguousarray(g)) for g in one_gate if not np.all(g == g[0])}
util, vec = {}, {}
for ia, ib in itertools.product(range(len(srcs)), repeat=2):
    if ia < 4 and ib < 4:
        continue                              # reads only inputs: a depth-one candidate
    for f in BIN:
        g = f(srcs[ia], srcs[ib])
        if np.all(g == g[0]):
            continue
        k = canon(np.ascontiguousarray(g))
        util[k] = abs(float(np.mean(r * g))); vec[k] = g
for ia in range(4, len(srcs)):
    k = canon(np.ascontiguousarray(srcs[ia]))
    util.setdefault(k, abs(float(np.mean(r * srcs[ia])))); vec.setdefault(k, srcs[ia])
vals = {}
for k, u in util.items():
    vals.setdefault(round(u, 9), []).append(k)
print(" depth-two candidates (distinct up to sign, incl. duplicates of depth-one or fired functions): "
      + "; ".join(f"|U| = {u}: {len(v)}" for u, v in sorted(vals.items(), reverse=True)))
new_only = {u: len([k for k in v if k not in d1keys and k not in fired_keys]) for u, v in vals.items()}
print(" excluding functions already computed at depth one or fired: "
      + "; ".join(f"|U| = {u}: {c}" for u, c in sorted(new_only.items(), reverse=True)))
top = [vec[k] for k in vals[max(vals)]]
print(f" each of the {len(top)} maximizers completes maj3: "
      f"{all(np.allclose(np.column_stack([Fm, g]) @ np.linalg.lstsq(np.column_stack([Fm, g]), maj, rcond=None)[0], maj) for g in top)}")
print(f"  [{time.time() - T0:.0f}s]")


# =========================================================================== 4
def sc_race(G, y, theta=1.0, tmax=40.0, maxev=400, tol=1e-11):
    """(SC) race on a depth-one dictionary, own implementation: clocks integrated directly."""
    n, M = G.shape
    ybar = y.mean()
    S = np.zeros(M); R = np.zeros(n); t = tau = 0.0
    sat, sig = [], np.zeros(M)
    c = np.zeros(0); c0 = ybar
    out = dict(events=0, exits=0, ident=0.0, chain=-1.0, clock=0.0, over=0.0, kkt=0.0,
               sat=0.0, supp=0.0)

    def refit(sat):
        if not sat:
            return np.zeros(0), ybar
        Gs = G[:, sat]
        mu = Gs.mean(0)
        A = (Gs - mu) * sig[sat]
        w, _ = nnls(A, y - ybar)
        cc = w * sig[sat]
        return cc, ybar - cc @ mu

    def f_of(c, c0):
        return c0 + (G[:, sat] @ c if sat else 0.0)

    for ev in range(maxev):
        f = f_of(c, c0)
        rr = y - f
        U = G.T @ rr / n
        # exits: saturated, zero weight, utility pointing inward
        keep = [m for k, m in enumerate(sat) if not (abs(c[k]) < 1e-12 and sig[m] * U[m] < -tol)]
        if len(keep) < len(sat):
            out["exits"] += len(sat) - len(keep)
            ck = np.array([c[k] for k, m in enumerate(sat) if m in keep])
            sat = keep; c = ck
        dorm = np.ones(M, bool); dorm[sat] = False
        with np.errstate(divide="ignore", invalid="ignore"):
            dt = np.where(U > tol, (theta - S) / U, np.where(U < -tol, (theta + S) / (-U), np.inf))
        dt[~dorm] = np.inf
        dtm = float(np.min(dt))
        if not np.isfinite(dtm) or t + dtm > tmax:
            break
        S = S + U * dtm
        R = R + rr * dtm
        tau += math.sqrt(np.mean(rr ** 2)) * dtm
        t += dtm
        fire = np.where(dt <= dtm + 1e-9 * max(1.0, dtm))[0]
        for m in fire:
            sig[m] = 1.0 if S[m] > 0 else -1.0
            S[m] = sig[m] * theta
            sat.append(int(m))
        c, c0 = refit(sat)
        out["events"] += 1
        f = f_of(c, c0)
        rr = y - f
        U = G.T @ rr / n
        Rn = math.sqrt(np.mean(R ** 2))
        out["ident"] = max(out["ident"], abs(theta * np.sum(np.abs(c)) - np.mean(R * f)))
        out["chain"] = max(out["chain"], np.mean(R * f) - Rn * math.sqrt(1 - ybar ** 2), Rn - tau)
        out["clock"] = max(out["clock"], float(np.max(np.abs(S - G.T @ R / n))))
        out["over"] = max(out["over"], float(np.max(np.abs(S))) - theta)
        supp = [m for k, m in enumerate(sat) if abs(c[k]) > 1e-12]
        if supp:
            out["kkt"] = max(out["kkt"], float(np.max(np.abs(U[supp]))))
        def ratio(B):
            if not B:
                return 0.0
            Gb = G[:, B] - G[:, B].mean(0)
            kap = float(np.linalg.eigvalsh(Gb.T @ Gb / n)[-1])
            return len(B) / (kap * (Rn / theta) ** 2)
        out["sat"] = max(out["sat"], ratio(sat))
        out["supp"] = max(out["supp"], ratio(supp))
        # KKT sign condition on saturated zero-weight gates (after exits are removed next round)
    return out


def ls_race_depth1(G, y, theta=1.0, tmax=30.0, maxev=200, tol=1e-11, rng=None):
    n, M = G.shape
    S = np.zeros(M); R = np.zeros(n); t = tau = 0.0
    fired = []; sig = np.zeros(M)
    f = np.full(n, y.mean())
    worst = 0.0
    for ev in range(maxev):
        rr = y - f
        U = G.T @ rr / n
        dorm = np.ones(M, bool); dorm[fired] = False
        with np.errstate(divide="ignore", invalid="ignore"):
            dt = np.where(U > tol, (theta - S) / U, np.where(U < -tol, (theta + S) / (-U), np.inf))
        dt[~dorm] = np.inf
        dtm = float(np.min(dt))
        if not np.isfinite(dtm) or t + dtm > tmax:
            break
        S += U * dtm; R += rr * dtm; tau += math.sqrt(np.mean(rr ** 2)) * dtm; t += dtm
        for m in np.where(dt <= dtm + 1e-9 * max(1.0, dtm))[0]:
            sig[m] = np.sign(S[m]); S[m] = sig[m] * theta; fired.append(int(m))
        F = np.column_stack([np.ones(n), G[:, fired]])
        f = F @ np.linalg.lstsq(F, y, rcond=None)[0]
        Rn = math.sqrt(np.mean(R ** 2))
        for rep in range(5):
            if rep == 0:
                B = list(fired)
            else:
                B = [m for m in fired if rng.random() < 0.5]
            if not B:
                continue
            Gb = G[:, B] - G[:, B].mean(0)
            kap = float(np.linalg.eigvalsh(Gb.T @ Gb / n)[-1])
            worst = max(worst, len(B) / (kap * (Rn / theta) ** 2))
    return worst, len(fired)


print("\n## 4. Independent (SC) race with exits; (LS) depth-one race")
rng = np.random.default_rng(7)
agg = dict(events=0, exits=0, ident=0.0, chain=-1.0, clock=0.0, over=0.0, kkt=0.0, sat=0.0, supp=0.0)
for trial in range(60):
    if trial % 2 == 0:                         # Boolean toy dictionary with exact and negated duplicates
        n, d = 48, 7
        X = rng.choice([-1.0, 1.0], size=(n, d))
        G0, _ = depth_one(X)
        G0 = G0[:, rng.choice(G0.shape[1], 40, replace=False)]
        G = np.column_stack([G0, G0[:, :6], -G0[:, 6:12]])
        y = np.sign(X[:, 0] + X[:, 1] * X[:, 2] + 0.8 * X[:, 3] + 0.3 + 0.2 * rng.standard_normal(n))
    else:                                      # real-valued correlated dictionary
        n, M = 36, 30
        Z = rng.standard_normal((n, 4))
        G = np.clip(Z @ rng.standard_normal((4, M)) * 0.6 + 0.6 * rng.standard_normal((n, M)), -1, 1)
        y = np.sign(Z[:, 0] - 0.7 * Z[:, 1] + 0.4 * rng.standard_normal(n) + 0.2)
    o = sc_race(G, y)
    for k in agg:
        agg[k] = agg[k] + o[k] if k in ("events", "exits") else max(agg[k], o[k])
print(f" (SC) 60 dictionaries: {agg['events']} events, {agg['exits']} exits")
print(f"   max |Theta ||c||_1 - <R,f>_n| = {agg['ident']:.1e}; max(<R,f> - ||R|| sqrt(1-ybar^2), ||R|| - tau) = {agg['chain']:.1e}")
print(f"   max |S_m - <R,g_m>_n| = {agg['clock']:.1e}; max(|S| - Theta) = {agg['over']:.1e}; max |U| on supp = {agg['kkt']:.1e}")
print(f"   Theorem A2.3(2): max |Sat|/(kappa_Sat x^2) = {agg['sat']:.3f}; max |supp|/(kappa_supp x^2) = {agg['supp']:.3f} (need <= 1)")
wl, nf = 0.0, 0
for trial in range(40):
    n, d = 40, 7
    X = rng.choice([-1.0, 1.0], size=(n, d))
    G0, _ = depth_one(X)
    G = np.column_stack([G0, G0[:, :8]])
    y = np.sign(X[:, 0] * X[:, 1] + 0.7 * X[:, 2] + 0.5 * X[:, 3] * X[:, 4] + 0.1 + 0.3 * rng.standard_normal(n))
    w, k = ls_race_depth1(G, y, rng=rng)
    wl = max(wl, w); nf += k
print(f" (LS) depth one, 40 dictionaries with duplicates, {nf} fired gates: max |B|/(kappa_B (||R||_n/Theta)^2)"
      f" over B = all fired and random subsets = {wl:.3f} (Theorem A2.3(1) refinement needs <= 1)")
print(f"  [{time.time() - T0:.0f}s]")

# =========================================================================== 5
print("\n## 5. Theorems A3.1 / A3.5: constants")


def a31(gam, R, lam, T, Msum, delta=DELTA):
    eps = gam / (2 * (1 + math.sqrt(2 * T / lam)))
    b1 = 2 * R ** 2 / eps ** 2 * math.log(4 * (Msum) / delta)
    b2 = 8 * (T + 1) ** 2 / lam ** 2 * math.log(4 * (T + 1) ** 3 / delta)
    return eps, b1, b2


eps, b1, b2 = a31(0.5, 1, 1, 1, 2205 + 1)
print(f" par2: eps = {eps:.5f}, b1 = {b1:.1f}, b2 = {b2:.1f} -> {math.ceil(max(b1, b2))}")
N1, N2 = 2206, 8
beta = min(eps / math.sqrt(2 * math.log(8 * N1 / DELTA)), 1 / (2 * 2) / math.sqrt(2 * math.log(8 * N2 / DELTA)))
print(f" A3.5 par2: beta_max = {beta:.5f}; n = b: {math.ceil((2 / beta) ** 2)}; n -> inf: b >= {math.ceil(beta ** -2)};"
      f" n = 16384: b >= {math.ceil((beta - 16384 ** -0.5) ** -2)}")
# n_eff restatement: A3.1 with b -> n_eff and delta -> delta/2
neff = (16384 ** -0.5 + 6225 ** -0.5) ** -2
_, c1, c2 = a31(0.5, 1, 1, 1, 2206, DELTA / 2)
print(f" n_eff(16384, 6225) = {neff:.1f}; A3.1 requirement at delta/2: {max(c1, c2):.1f} (restatement consistent: {neff >= max(c1, c2)})")
for (gam, R, lam, T) in [(0.5, 1, 1, 1), (0.5, 1, 1, 10), (0.5, 1, 0.3, 10), (0.25, 1, 0.5, 5), (0.5, 1, 0.5, 30)]:
    Msum = sum(6 * (30 + t) ** 2 + t + 1 for t in range(T))
    e, b1, b2 = a31(gam, R, lam, T, Msum)
    print(f"   gamma={gam}, R={R}, lambda={lam}, T={T}: first (utility) condition b >= {b1:.3g}; second (Gram) condition"
          f" b >= {b2:.3g}; {'second dominates' if b2 > b1 else 'first dominates'}")
print(f"  [{time.time() - T0:.0f}s]")

# =========================================================================== 6
print("\n## 6. Theorem A3.5 Monte Carlo: population greedy run on the d = 4 cube")
X4 = np.array(list(itertools.product([-1.0, 1.0], repeat=4)))


def candidates(circuit_funcs):
    """distinct (up to sign, on the cube) non-constant candidates over inputs and the circuit's gates."""
    srcs = [X4[:, i] for i in range(4)] + list(circuit_funcs)
    out, seen = [], set(canon(np.ascontiguousarray(g)) for g in circuit_funcs)
    for g in srcs[:4]:
        k = canon(np.ascontiguousarray(g))
        if k not in seen:
            seen.add(k); out.append(g)
    for a, b in itertools.combinations_with_replacement(range(len(srcs)), 2):
        for f in BIN:
            g = f(srcs[a], srcs[b])
            if np.all(g == g[0]):
                continue
            k = canon(np.ascontiguousarray(g))
            if k not in seen:
                seen.add(k); out.append(g)
    return out


def pop_greedy(y, T):
    C, info = [], []
    for t in range(T + 1):
        F = np.column_stack([np.ones(16)] + C)
        coef = np.linalg.lstsq(F, y, rcond=None)[0]
        r = y - F @ coef
        K = F.T @ F / 16
        lam = float(np.linalg.eigvalsh(K)[0])
        if t == T:
            info.append(dict(lam=lam, R=float(np.max(np.abs(r))), M=0, gap=None))
            break
        cand = candidates(C)
        U = np.array([np.mean(r * g) for g in cand])
        o = np.argsort(-np.abs(U))
        gap = abs(U[o[0]]) - abs(U[o[1]])
        info.append(dict(lam=lam, R=float(np.max(np.abs(r))), M=len(cand), gap=gap, best=cand[o[0]]))
        C.append(cand[o[0]])
    return C, info


best = None
for coeffs in itertools.product([3, 2, 1, -1], repeat=3):
    y = np.sign(coeffs[0] * X4[:, 0] * X4[:, 1] + coeffs[1] * X4[:, 2] + coeffs[2] * X4[:, 3] + 0.5)
    if abs(y.mean()) > 0.9:
        continue
    C, info = pop_greedy(y, 2)
    gaps = [i["gap"] for i in info[:-1]]
    if min(gaps) > 1e-9:
        cand = (min(gaps), coeffs, C, info, y)
        if best is None or cand[0] > best[0]:
            best = cand
gam, coeffs, C, info, y = best
T = 2
R = max(i["R"] for i in info)
lam = min(i["lam"] for i in info)
Msum = sum(i["M"] + t + 1 for t, i in enumerate(info[:-1]))
exact = np.allclose(np.column_stack([np.ones(16)] + C) @ np.linalg.lstsq(np.column_stack([np.ones(16)] + C), y, rcond=None)[0], y)
eps = gam / (2 * (1 + math.sqrt(2 * T / lam)))
N1, N2 = Msum, (T + 1) ** 3
beta = min(eps / (R * math.sqrt(2 * math.log(8 * N1 / DELTA))), lam / (2 * (T + 1)) / math.sqrt(2 * math.log(8 * N2 / DELTA)))
nb = math.ceil((2 / beta) ** 2)
print(f" target sgn({coeffs[0]} x1x2 + {coeffs[1]} x3 + {coeffs[2]} x4 + 0.5): gap = {gam:.4f}, R = {R:.3f}, lambda_* = {lam:.3f},"
      f" sum (M_t+t+1) = {Msum}, exact representation after T = 2: {exact}")
print(f"   Theorem A3.5 needs n^-1/2 + b^-1/2 <= {beta:.5f}, e.g. n = b = {nb}")


def eg_reuse(y, n, b, T, rng):
    """reuse protocol on the 16-point cube via counts: S ~ Mult(n, 1/16); each B_t ~ Mult(b, S/n)."""
    Scount = rng.multinomial(n, np.full(16, 1 / 16))
    Ccur = []
    for t in range(T + 1):
        w = rng.multinomial(b, Scount / n) / b
        F = np.column_stack([np.ones(16)] + Ccur)
        sw = np.sqrt(w)
        coef = np.linalg.lstsq(F * sw[:, None], y * sw, rcond=None)[0]
        r = y - F @ coef
        if t == T:
            return Ccur, np.sign(F @ coef)
        cand = candidates(Ccur)
        U = np.array([np.sum(w * r * g) for g in cand])
        Ccur.append(cand[int(np.argmax(np.abs(U)))])


rng = np.random.default_rng(6)
for (n, b, reps) in [(nb, nb, 200), (256, 64, 400), (64, 16, 400)]:
    fail_c = fail_p = 0
    for _ in range(reps):
        Cg, pred = eg_reuse(y, n, b, T, rng)
        same = all(any(np.array_equal(g, h) or np.array_equal(g, -h) for h in C) for g in Cg)
        fail_c += not same
        fail_p += not np.array_equal(pred, y)
    print(f"   reuse protocol n = {n}, b = {b}: circuit differs from C_T in {fail_c}/{reps} runs; final predictor != y in {fail_p}/{reps}")
print(f"  [{time.time() - T0:.0f}s]")

# =========================================================================== 7
print("\n## 7. par2 first greedy step at small b: unique argmax?")
rng = np.random.default_rng(9)
XORcol = 30 + 4                                 # identities, then pair (1,2): AND, AND, AND, AND, XOR
for (n, b) in [(64, 16), (256, 16), (1024, 64)]:
    an_arg = uniq = 0
    reps = 200
    for _ in range(reps):
        X = rng.choice([-1.0, 1.0], size=(n, 30))
        Z = X[rng.integers(0, n, size=b)]
        G, _ = depth_one(Z)
        yb = Z[:, 0] * Z[:, 1]
        U = np.abs((yb - yb.mean()) @ G / b)
        is_arg = U[XORcol] >= U.max() - 1e-12
        an_arg += is_arg
        ties = np.where(U >= U.max() - 1e-12)[0]
        uniq += is_arg and len(ties) == 1
    print(f" reuse n = {n}, b = {b}: XOR(x1,x2) is an argmax in {an_arg}/{reps} runs (forced by |U| <= Var_b(y));"
          f" unique argmax in {uniq}/{reps}")
rng = np.random.default_rng(10)
for b in [16, 32, 64]:
    uniq, reps = 0, 400
    for _ in range(reps):
        Z = rng.choice([-1.0, 1.0], size=(b, 30))
        G, _ = depth_one(Z)
        yb = Z[:, 0] * Z[:, 1]
        U = np.abs((yb - yb.mean()) @ G / b)
        ties = np.where(U >= U.max() - 1e-12)[0]
        uniq += (len(ties) == 1 and ties[0] == XORcol)
    print(f" fresh b = {b}: XOR(x1,x2) is the unique argmax in {uniq}/{reps} runs")
print(f"\n[total {time.time() - T0:.0f}s]")
