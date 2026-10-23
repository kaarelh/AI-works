"""Checks for revision 2 of ../A-discrete-model.md (after referee round 1).  Runs in about a minute.

  1. Theorem A1 thresholds: largest T with realizable bound <= 0.1 and < 1/2, and n/T for <= 0.1.
  2. Theorem A3.1 (par2) and Theorem A3.5 (reuse) sample/batch requirements.
  3. Library incoherence kappa_bar_1 of the toy depth-one library: population (exact, d = 8 cube,
     and the closed form d) and empirical (d = 30, several n); the time-only count bound of
     Corollary A2.5(a').
  4. Proposition A4.2(2): exact population utilities of all depth-two candidates against the residual
     -x1x2x3/2 after the first maj3 event (d = 4 cube, so that an irrelevant input is present); the
     Fourier lemma |hat(ab)(123)| <= 1/2; the 12-way tie; T_end = 21.
  5. Proposition A4.1 without the balance hypothesis: every toy-library gate as a target (population,
     d = 4 cube) and on random samples.
  6. race_bounds.Race (fixed version) on random correlated dictionaries in the (SC) variant, where
     gates leave the saturated set: Theorem A2.4 identity, S_m = <R, g_m>_n, |S| <= Theta, KKT, and the
     (SC) form of Theorem A2.3.
  7. A1 versus the BEHW symmetrization route (with the hypothesis n >= 8/eps).
  8. Monte Carlo: greedy argmax with reuse batches (and fresh batches) on par2 at small b, to show how
     conservative Theorems A3.1 / A3.5 are.
  9. Ranges quoted in Section 5, parsed from race_bounds.txt.
"""
import itertools, math, re, sys, os
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import race_bounds as rb

np.set_printoptions(precision=4, suppress=True)
DELTA = 0.05


def log_phi(N, T):
    """log(2 sum_{i<=T} C(N-1, i)) in floating point (rb.log_phi is exact but slow for N = 2^30, large T)."""
    M = N - 1
    terms = [0.0]                                   # log C(M, i), computed incrementally
    for i in range(1, min(T, M) + 1):
        terms.append(terms[-1] + math.log((M - i + 1) / i))
    m = max(terms)
    return math.log(2) + m + math.log(sum(math.exp(t - m) for t in terms))


assert all(abs(log_phi(2 ** min(T, 30), T) - rb.log_phi(2 ** min(T, 30), T)) < 1e-9 for T in range(1, 40))


def L_T(T, G=6, d=30, k=2, delta=DELTA):
    W = sum(math.log(G) + k * math.log(d + t - 1) for t in range(1, T + 1))
    return W + log_phi(2 ** min(T, d), T) + math.log((T + 1) * (T + 2) / delta)


def realizable(T, n):
    return 1 - math.exp(-L_T(T) / n)


# --------------------------------------------------------------------------- 1
print("## 1. Theorem A1 realizable bound 1-exp(-L_T/n) (d=30, k=2, |G|=6, delta=0.05)")
for n in [64, 256, 1024, 4096, 16384]:
    t01 = max([T for T in range(0, 800) if realizable(T, n) <= 0.1], default=None)
    t05 = max([T for T in range(0, 800) if realizable(T, n) < 0.5], default=None)
    print(f" n={n:5d}: largest T with bound <= 0.1: {t01};  largest T with bound < 0.5: {t05}")
ratios = []
for T in range(1, 11):
    nmin = math.ceil(L_T(T) / -math.log(0.9))
    ratios.append(nmin / T)
print(" n needed for bound <= 0.1, divided by T, T = 1..10: " + ", ".join(f"{r:.0f}" for r in ratios)
      + f";  max = {max(ratios):.1f}")

# --------------------------------------------------------------------------- 2
print("\n## 2. Theorem A3.1 and Theorem A3.5 for par2 (gamma = 1/2, R = lambda_* = 1, T = 1, M_0 = 2205)")
gam, R, lam, T, M0 = 0.5, 1.0, 1.0, 1, 2205
eps = gam / (2 * (1 + math.sqrt(2 * T / lam)))
N1 = M0 + 0 + 1                         # sum_{t<T} (M_t + t + 1)
N2 = (T + 1) ** 3
b1 = 2 * R ** 2 / eps ** 2 * math.log(4 * N1 / DELTA)
b2 = 8 * (T + 1) ** 2 / lam ** 2 * math.log(4 * N2 / DELTA)
print(f" A3.1: eps = {eps:.5f}; b >= {b1:.1f} and b >= {b2:.1f}  ->  b (or n, full batch) >= {math.ceil(max(b1, b2))}")
# A3.5: beta = n^-1/2 + b^-1/2 must satisfy R beta sqrt(2 log(8 N1/delta)) <= eps and
#        beta sqrt(2 log(8 N2/delta)) <= lambda_*/(2(T+1))
beta_max = min(eps / (R * math.sqrt(2 * math.log(8 * N1 / DELTA))),
               lam / (2 * (T + 1)) / math.sqrt(2 * math.log(8 * N2 / DELTA)))
print(f" A3.5: need n^-1/2 + b^-1/2 <= {beta_max:.5f}")
print(f"   n = b: n >= {math.ceil((2 / beta_max) ** 2)};  n -> infinity: b >= {math.ceil(beta_max ** -2)}")
for n in [4096, 16384, 10 ** 6]:
    rem = beta_max - n ** -0.5
    print(f"   n = {n}: b >= {math.ceil(rem ** -2) if rem > 0 else 'impossible'}")
print(f"   n = 16384, b = 64: n^-1/2 + b^-1/2 = {16384 ** -0.5 + 64 ** -0.5:.4f} (> {beta_max:.4f}: not covered)")


# --------------------------------------------------------------------------- 3
def depth1_gates(X):
    """All toy-library depth-one gates on the columns of X (identity, 4 AND types, XOR)."""
    n, d = X.shape
    cols = [X[:, i] for i in range(d)]
    for i, j in itertools.combinations(range(d), 2):
        cols += rb.binary_gates(X[:, i], X[:, j])
    return np.stack(cols, 1)


def merge_up_to_sign(G):
    seen, keep = set(), []
    for m in range(G.shape[1]):
        v = G[:, m]
        if np.all(v == v[0]):
            continue
        w = v if v[0] > 0 else -v
        key = np.packbits(w > 0).tobytes()
        if key in seen:
            continue
        seen.add(key)
        keep.append(m)
    return G[:, keep]


def top_centred_eig(G):
    G = G.astype(np.float32)
    n = G.shape[0]
    K = (G.T @ G).astype(np.float64) / n
    mu = G.mean(0).astype(np.float64)
    K -= np.outer(mu, mu)
    return float(np.linalg.eigvalsh(K)[-1])


print("\n## 3. Library incoherence kappa_bar_1 (centred Gram of all distinct depth-one toy gates)")
d8 = np.array(list(itertools.product([-1.0, 1.0], repeat=8)))
G8 = merge_up_to_sign(depth1_gates(d8))
print(f" population, d = 8 (exact, full cube): {G8.shape[1]} gates, kappa_bar_1 = {top_centred_eig(G8):.6f}  (closed form: d = 8)")
rng = np.random.default_rng(0)
kb = {}
for n in [64, 256, 1024, 4096, 16384]:
    X = rng.choice([-1.0, 1.0], size=(n, 30)).astype(np.int8)
    G = merge_up_to_sign(depth1_gates(X.astype(np.float32)).astype(np.int8))
    kb[n] = top_centred_eig(G)
    print(f" empirical, d = 30, n = {n:5d}: {G.shape[1]} distinct gates, kappa_bar_1 = {kb[n]:.2f}  (population: 30)")
print(" Corollary A2.5(a'): T(t) <= min(M_1, floor(kappa_bar_1 x^2)), x = ||R||_n/Theta <= tau/Theta, depth one;"
      " realizable A1 bound at that T:")
for n in [1024, 4096, 16384]:
    parts = []
    for x in [1.0, 1.5, 1.99]:
        Tb = min(2205, int(math.floor(kb[n] * x * x)))
        parts.append(f"x={x}: T<={Tb}, bound {realizable(Tb, n):.3f}")
    print(f"   n = {n:5d}: " + ";  ".join(parts))
print(f"   for comparison, A1 at the realized T: par2 (T = 1) {realizable(1, 4096):.3f} at n = 4096;"
      f" maj3 first event (T = 9) {realizable(9, 4096):.3f} at n = 4096")

# --------------------------------------------------------------------------- 4
print("\n## 4. Proposition A4.2(2): population maj3 after the first event (d = 4 cube)")
X4 = np.array(list(itertools.product([-1.0, 1.0], repeat=4)))
x1, x2, x3, x4 = X4.T
AND = rb.AND
fired = {"x1": x1, "x2": x2, "x3": x3}
for (i, a), (j, b) in itertools.combinations([(1, x1), (2, x2), (3, x3)], 2):
    fired[f"AND(x{i},x{j})"] = AND(a, b)
    fired[f"AND(~x{i},~x{j})"] = AND(-a, -b)
assert len(fired) == 9
maj = np.sign(x1 + x2 + x3)
F = np.stack([np.ones(16)] + list(fired.values()), 1)
coef, *_ = np.linalg.lstsq(F, maj, rcond=None)
r = maj - F @ coef
print(f" residual after the 9-gate refit equals -x1x2x3/2: {np.allclose(r, -x1 * x2 * x3 / 2)}")
inputs = {"x1": x1, "x2": x2, "x3": x3, "x4": x4}
# depth-one candidates
U1 = [abs(np.mean(r * g)) for g in depth1_gates(X4).T]
print(f" max |U| over depth-one candidates: {max(U1):.2e}")
# depth-two candidates: phi(a, b) with a, b sources (inputs or fired), at least one fired
srcs = list(inputs.items()) + [(k, v) for k, v in fired.items() if k not in inputs]
fired_names = set(fired) - set(inputs)          # fired gates that are not literally inputs
# (the fired identity gates x1..x3 compute the same functions as the inputs; a candidate reading
#  only inputs and identity gates is a duplicate of a depth-one candidate, with U = 0)
chi123 = x1 * x2 * x3
cands, worst_ab = {}, 0.0
for (na, a), (nb, b) in itertools.combinations(srcs, 2):
    if na not in fired_names and nb not in fired_names:
        continue
    worst_ab = max(worst_ab, abs(np.mean(a * b * chi123)))
    for nm, g in zip(rb.BIN_NAMES, rb.binary_gates(a, b)):
        key = tuple(g if g[0] > 0 else -g)
        U = float(np.mean(r * g))
        cands.setdefault(key, (nm.replace("a", na).replace("b", nb), U))
vals = sorted({round(abs(U), 9) for _, U in cands.values()}, reverse=True)
print(f" max over source pairs of |hat(ab)(123)| = {worst_ab:.4f} (lemma: <= 1/2)")
for v in vals:
    names = [nm for nm, U in cands.values() if abs(abs(U) - v) < 1e-9]
    print(f"   |U| = {v:.4f}: {len(names)} distinct functions (up to sign)"
          + (": " + ", ".join(names) if v == vals[0] else ""))
top = [np.array(k) for k, (nm, U) in cands.items() if abs(abs(U) - vals[0]) < 1e-9]
ok_one = all(np.allclose(np.column_stack([F, g]) @ np.linalg.lstsq(np.column_stack([F, g]), maj, rcond=None)[0], maj)
             for g in top)
print(f" each maximizer alone completes the representation of maj3: {ok_one}")
allF = np.column_stack([F] + top)
print(f" distinct gate functions after the second event: 9 + {len(top)} = {9 + len(top)};"
      f" residual after refit on all: {np.max(np.abs(maj - allF @ np.linalg.lstsq(allF, maj, rcond=None)[0])):.1e}")
print(f" second event time: 2 Theta + Theta/{vals[0]:.2f} = {2 + 1 / vals[0]:.2f} Theta;"
      f" other clocks at that time <= {4 * vals[1]:.2f} Theta")

# --------------------------------------------------------------------------- 5
print("\n## 5. Proposition A4.1 without balance: library-gate targets")
G4 = merge_up_to_sign(depth1_gates(X4))
bad, min_gap, unbalanced = 0, np.inf, 0
for m in range(G4.shape[1]):
    y = G4[:, m]
    ybar = y.mean()
    unbalanced += abs(ybar) > 1e-12
    U = (y - ybar) @ G4 / len(y)
    var = 1 - ybar ** 2
    order = np.argsort(-np.abs(U))
    if abs(abs(U[order[0]]) - var) > 1e-12 or order[0] != m:
        bad += 1
    min_gap = min(min_gap, var - abs(U[order[1]]))
print(f" population, d = 4: {G4.shape[1]} targets ({unbalanced} unbalanced); target is the unique argmax with"
      f" |U| = Var(y) in all but {bad}; smallest gap Var(y) - second |U| = {min_gap:.4f}")
rng = np.random.default_rng(5)
bad_s, trials = 0, 0
for trial in range(200):
    n = int(rng.choice([16, 32, 64]))
    X = rng.choice([-1.0, 1.0], size=(n, 10))
    Gs = depth1_gates(X)
    m = int(rng.integers(0, Gs.shape[1]))
    y = Gs[:, m]
    if np.all(y == y[0]):
        continue
    trials += 1
    U = (y - y.mean()) @ Gs / n
    var = 1 - y.mean() ** 2
    eq = np.all(np.abs(Gs - y[:, None]) < 1e-12, 0) | np.all(np.abs(Gs + y[:, None]) < 1e-12, 0)
    if not (np.all(np.abs(np.abs(U[eq]) - var) < 1e-12) and np.all(np.abs(U[~eq]) < var - 1e-12)):
        bad_s += 1
print(f" samples (d = 10, n in {{16, 32, 64}}): {trials} library-gate targets; violations of"
      f" '|U| = Var_n(y) exactly for g = +-y on the sample, < Var_n(y) otherwise': {bad_s}")


# --------------------------------------------------------------------------- 6
class DictRace(rb.Race):
    """race_bounds.Race in the (SC) variant on an arbitrary depth-one dictionary G (n x M, |g| <= 1)."""

    def __init__(self, G, y):
        self.X = self.Xte = None
        self.y, self.yte = y, y
        self.n = len(y)
        self.variant, self.depth1 = "SC", True
        self.t = self.tau = 0.0
        self.R = np.zeros(self.n)
        self.cand_tr = [G[:, m] for m in range(G.shape[1])]
        self.cand_te = [G[:, m] for m in range(G.shape[1])]
        self.cand_name = [f"g{m}" for m in range(G.shape[1])]
        self.cand_depth = [1] * G.shape[1]
        self.active, self.sign, self.exits = [], {}, 0
        self.c0, self.c = float(np.mean(y)), np.zeros(0)
        self.r = y - self.c0
        self.G = G.astype(np.float64)
        self.S = np.zeros(G.shape[1])
        self.avail = np.zeros(G.shape[1])


print("\n## 6. race_bounds.Race (fixed) in the (SC) variant on random correlated dictionaries")
rng = np.random.default_rng(1)
worst = dict(ident=0.0, clock=0.0, over=0.0, kkt=0.0, size=0.0)
exits, events = 0, 0
for trial in range(40):
    n, M = 40, 25
    base = rng.standard_normal((n, 5))
    G = np.tanh(base @ rng.standard_normal((5, M)) * 0.7 + 0.5 * rng.standard_normal((n, M)))
    y = np.sign(base[:, 0] + 0.5 * base[:, 1] * base[:, 2] + 0.3 * rng.standard_normal(n))
    race = DictRace(G, y)
    for ev in range(400):
        if race.t > 60 or not race.step():
            break
        events += 1
        f = race.f_train()
        Rn = float(np.sqrt(np.mean(race.R ** 2)))
        worst["ident"] = max(worst["ident"], abs(np.sum(np.abs(race.c)) - float(np.mean(race.R * f))))
        worst["clock"] = max(worst["clock"], float(np.max(np.abs(race.S - race.G.T @ race.R / n))))
        worst["over"] = max(worst["over"], float(np.max(np.abs(race.S))) - 1)
        U = race.G.T @ race.r / n
        if race.active:
            sup = [m for idx, m in enumerate(race.active) if abs(race.c[idx]) > 1e-12]
            worst["kkt"] = max(worst["kkt"], float(np.max(np.abs(U[sup]), initial=0.0)))
            worst["size"] = max(worst["size"], len(race.active) / (race.kappa() * Rn ** 2))
        assert np.sum(np.abs(race.c)) <= Rn * math.sqrt(1 - y.mean() ** 2) + 1e-8 and Rn <= race.tau + 1e-9
    exits += race.exits
print(f" 40 trials, {events} events, {exits} exits from the saturated set")
print(f"   max | ||c||_1 - <R,f>_n | = {worst['ident']:.1e} (Theorem A2.4, Theta = 1);"
      f" max |S_m - <R,g_m>_n| = {worst['clock']:.1e}; max(|S| - Theta) = {worst['over']:.1e};"
      f" max |U_m| on the support = {worst['kkt']:.1e}")
print(f"   max over events of |Sat| / (kappa_Sat ||R||_n^2) = {worst['size']:.3f} ((SC) form of Theorem A2.3 needs <= 1)")

# --------------------------------------------------------------------------- 7
print("\n## 7. A1 realizable bound versus the BEHW route 2 Pi(2n) 2^(-eps n/2) (needs n >= 8/eps)")


def behw_eps(T, n, delta=DELTA):
    W = sum(math.log(6) + 2 * math.log(30 + t - 1) for t in range(1, T + 1))
    return 2 * (math.log(2) + W + log_phi(2 * n, T) + math.log((T + 1) * (T + 2) / delta)) / (n * math.log(2))


for n in [1024, 4096, 16384]:
    worse = [T for T in range(1, 1500) if realizable(T, n) > behw_eps(T, n)]
    a05 = max(T for T in range(1, 1500) if realizable(T, n) < 0.5)
    b1 = max(T for T in range(1, 1500) if behw_eps(T, n) < 1)
    print(f" n = {n:5d}: T in 1..1499 where A1 is larger: {worse if worse else 'none'};"
          f" A1 < 1/2 for T <= {a05}, BEHW < 1 for T <= {b1}; at T = 10: A1 {realizable(10, n):.3f}, BEHW {behw_eps(10, n):.3f}"
          f" (n >= 8/eps holds: {n >= 8 / behw_eps(10, n)})")

# --------------------------------------------------------------------------- 8
print("\n## 8. Greedy argmax, first step on par2, small batches (does it pick XOR(x1,x2)?)")
rng = np.random.default_rng(8)
XOR_COL = None
for n, b in [(64, 16), (64, 64), (256, 16), (256, 64), (1024, 64)]:
    hits_reuse = hits_fresh = 0
    reps = 200
    for rep in range(reps):
        X = rng.choice([-1.0, 1.0], size=(n, 30))
        idx = rng.integers(0, n, size=b)
        XB = X[idx]
        Xf = rng.choice([-1.0, 1.0], size=(b, 30))
        for Z, tag in [(XB, "reuse"), (Xf, "fresh")]:
            G = depth1_gates(Z)
            y = Z[:, 0] * Z[:, 1]
            U = np.abs((y - y.mean()) @ G / b)
            # column of XOR(x1, x2): identities (30) then 5 gates per pair in combinations order; pair (0,1) first
            ok = U[30 + 4] >= U.max() - 1e-12
            if tag == "reuse":
                hits_reuse += ok
            else:
                hits_fresh += ok
    print(f" n = {n:5d}, b = {b:3d}: XOR(x1,x2) is an argmax in {hits_reuse / reps:.3f} of reuse runs,"
          f" {hits_fresh / reps:.3f} of fresh-batch runs")

# --------------------------------------------------------------------------- 9
print("\n## 9. Ranges for Section 5, parsed from race_bounds.txt")
path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "race_bounds.txt")
txt = open(path).read()
blocks = re.split(r"\n### ", txt)
ls_kappa, ls_kappa256, loose = [], [], {}
sc_sq, sc_ramp = [], []
for blk in blocks[1:]:
    head = blk.split("\n", 1)[0]
    mm = re.match(r"(\w+)\s+n=(\d+)\s+variant=(\w+)", head)
    if not mm:
        continue
    name, n, var = mm.group(1), int(mm.group(2)), mm.group(3)
    lines = [l for l in blk.split("\n")[2:] if re.match(r"\s*\d", l)]
    for l in lines:
        v = l.split()
        if var == "LS":
            T, kap, kt2 = int(v[2]), float(v[4]), float(v[5])
            ls_kappa.append(kap)
            if n >= 256:
                ls_kappa256.append(kap)
            loose.setdefault(name, []).append(kt2 / T)
        elif var == "SC" and n == 4096:
            sc_sq.append(float(v[8])); sc_ramp.append(float(v[11]))
print(f" (LS) kappa over all events: [{min(ls_kappa):.2f}, {max(ls_kappa):.2f}]; n >= 256: [{min(ls_kappa256):.2f}, {max(ls_kappa256):.2f}]")
for name, L in loose.items():
    print(f"   A2.3 looseness kappa tau^2 / (Theta^2 T), {name}: [{min(L):.2f}, {max(L):.2f}]")
print(f" (SC) Theorem A1' at n = 4096 (delta split): clipped-square bound [{min(sc_sq):.2f}, {max(sc_sq):.2f}];"
      f" ramp 0-1 bound [{min(sc_ramp):.2f}, {max(sc_ramp):.2f}]")
