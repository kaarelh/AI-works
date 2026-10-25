"""Referee round 1 checks for ../A-discrete-model.md (independent code; runs in well under a minute).

  1. Theorem A1 table: recompute a few L_T and realizable bounds.
  2. Theorem A3.1: the par2 sample-size requirement quoted as n >= 2252.
  3. Population maj3 race (exact, uniform cube on d = 5), (LS) refit, toy library,
     depth unbounded: event times, number of gates per event, ties, kappa.
     Checks Proposition A2.2(2) (m = 3) and Proposition A4.2(1)-(2) ("fires at 6 Theta").
  4. Population MAJ_5 first event: m^2 = 25 gates at Theta / u_5; other clocks <= Theta/2.
  5. Minimum consistent circuit for maj3 with the toy library and a sign readout: is s* = 2?
  6. A1 (T^2 readout term) versus the BEHW symmetrization route: where is the crossover?
  7. Random correlated dictionaries: (SC) race with exits (Theorem A2.4 identity, Lemma 2.2(3)),
     and (LS) depth-one race (Theorem A2.3).
  8. The boolean-mask assignment in race_bounds.py Race.step (ordering of self.active).
  9. Proposition A3.4(3): first-occurrence validation with an adaptive memorizing learner (Monte Carlo).
"""
import itertools, math
import numpy as np
from scipy.optimize import nnls, linprog

np.set_printoptions(precision=4, suppress=True)
TOL = 1e-10

# ---------------------------------------------------------------- 1. A1 table
def log_phi(N, T):
    return math.log(2 * sum(math.comb(N - 1, i) for i in range(0, min(T, N - 1) + 1)))

def L_T(T, G=6, d=30, k=2, delta=0.05):
    W = sum(math.log(G) + k * math.log(d + t - 1) for t in range(1, T + 1))
    return W + log_phi(2 ** min(T, d), T) + math.log((T + 1) * (T + 2) / delta)

print("## 1. Theorem A1 realizable bound 1 - exp(-L_T/n), d=30, k=2, |G|=6, delta=0.05")
for T in [1, 3, 6, 10, 20, 30]:
    L = L_T(T)
    print(f"T={T:2d}  L_T={L:7.1f}  " + "  ".join(f"n={n}:{1-math.exp(-L/n):.3f}" for n in [64, 256, 1024, 4096, 16384])
          + f"   n(<=0.1)={math.ceil(L/-math.log(0.9))}  ratio n/T={math.ceil(L/-math.log(0.9))/T:.0f}")

# ---------------------------------------------------------------- 2. Theorem A3.1 constant for par2
print("\n## 2. Theorem A3.1 for par2: gamma=1/2, R=lambda*=1, T=1, M_0=2205, delta=0.05")
gam, R, lam, T, M0, dl = 0.5, 1.0, 1.0, 1, 2205, 0.05
eps = gam / (2 * (1 + math.sqrt(2 * T / lam)))
b1 = 2 * R ** 2 / eps ** 2 * math.log(4 * (M0 + 0 + 1) / dl)
b2 = 8 * (T + 1) ** 2 / lam ** 2 * math.log(4 * (T + 1) ** 3 / dl)
print(f"eps={eps:.5f}; condition 1: b >= {b1:.1f}; condition 2: b >= {b2:.1f}  -> n >= {math.ceil(max(b1, b2))} (note says 2252)")

# ---------------------------------------------------------------- population race machinery
def cube(d):
    return np.array(list(itertools.product([-1.0, 1.0], repeat=d)))

def AND(u, v):
    return np.where((u > 0) & (v > 0), 1.0, -1.0)

def bin_gates(u, v):
    return [("AND(a,b)", AND(u, v)), ("AND(~a,b)", AND(-u, v)), ("AND(a,~b)", AND(u, -v)),
            ("AND(~a,~b)", AND(-u, -v)), ("XOR", u * v)]

def key(v):
    w = v if v[0] > 0 else -v
    return tuple(np.round(w, 9))

class PopRaceLS:
    """Exact population (LS) clock race over the uniform cube, toy library, unbounded depth.
    Syntactic candidates are kept separately unless they compute the same function (up to sign)
    with the same availability time (those behave identically)."""

    def __init__(self, X, y, maxdepth=3):
        self.X, self.y, self.N = X, y, len(y)
        self.maxdepth = maxdepth
        self.src = [(f"x{i+1}", X[:, i], 0.0, 0) for i in range(X.shape[1])]   # name, vec, fire time, depth
        self.cand = {}            # (funckey, avail) -> dict
        self.fired = []
        self.t = 0.0
        for i in range(X.shape[1]):
            self._add(f"id(x{i+1})", X[:, i], 0.0, 1)
        for i, j in itertools.combinations(range(X.shape[1]), 2):
            self._add_pair(i, j)
        self.refit()

    def _add(self, name, v, avail, depth):
        if np.all(v == v[0]):
            return
        k = (key(v), round(avail, 9))
        if k in self.cand:
            self.cand[k]["mult"] += 1
            return
        self.cand[k] = dict(name=name, v=v.astype(float), avail=avail, S=0.0, fired=False, depth=depth, mult=1)

    def _add_pair(self, i, j):
        (na, a, ta, da), (nb, b, tb, db) = self.src[i], self.src[j]
        dep = 1 + max(da, db)
        if dep > self.maxdepth:
            return
        for nm, g in bin_gates(a, b):
            self._add(nm.replace("a", na).replace("b", nb), g, max(ta, tb), dep)

    def refit(self):
        F = [np.ones(self.N)] + [c["v"] for c in self.fired]
        F = np.stack(F, 1)
        coef, *_ = np.linalg.lstsq(F, self.y, rcond=None)
        self.f = F @ coef
        self.r = self.y - self.f

    def step(self):
        best, rows = np.inf, []
        for k, c in self.cand.items():
            if c["fired"] or c["avail"] > self.t + 1e-12:
                continue
            U = float(np.mean(self.r * c["v"]))
            c["U"] = U
            if U > TOL:
                dt = (1 - c["S"]) / U
            elif U < -TOL:
                dt = (1 + c["S"]) / -U
            else:
                dt = np.inf
            c["dt"] = dt
            best = min(best, dt)
        if not np.isfinite(best):
            return None
        firing = []
        for k, c in self.cand.items():
            if c["fired"] or c["avail"] > self.t + 1e-12:
                continue
            c["S"] += c["U"] * best
            if abs(c["dt"] - best) < 1e-9:
                firing.append(c)
        self.t += best
        newfuncs = set()
        for c in firing:
            c["fired"] = True
            c["S"] = float(np.sign(c["S"]))
            self.fired.append(c)
            self.src.append((f"[{c['name']}]", c["v"], self.t, c["depth"]))
            newfuncs.add(key(c["v"]))
        n0 = len(self.src) - len(firing)
        for jn in range(n0, len(self.src)):
            for i in range(jn):
                self._add_pair(i, jn)
            # identity on a fired gate is a duplicate of it: omitted (U = 0 forever in LS)
        self.refit()
        return firing, newfuncs

    def kappa(self):
        F = np.stack([c["v"] for c in self.fired], 1)
        Fc = F - F.mean(0)
        return float(np.linalg.eigvalsh(Fc.T @ Fc / self.N)[-1])

# ---------------------------------------------------------------- 3. population maj3
print("\n## 3. Population maj3 race (LS, exact on {-1,1}^5, toy library, depth <= 3)")
X = cube(5)
y = np.sign(X[:, 0] + X[:, 1] + X[:, 2])
race = PopRaceLS(X, y, maxdepth=3)
distinct = set()
for ev in range(4):
    out = race.step()
    if out is None:
        print("   race stopped: all utilities zero")
        break
    firing, nf = out
    distinct |= nf
    Us = sorted({round(abs(c["U"]), 6) for c in firing})
    print(f" event {ev+1}: t/Theta = {race.t:.4f}; {len(firing)} syntactic gates fire "
          f"({len(nf)} distinct functions up to sign), |U| = {Us}; depths {sorted({c['depth'] for c in firing})}; "
          f"cumulative distinct = {len(distinct)}; train residual ||r|| = {np.sqrt(np.mean(race.r**2)):.4f}; "
          f"kappa(pop) = {race.kappa():.3f}")
    if ev == 0:
        others = [abs(c["S"]) for c in race.cand.values() if not c["fired"]]
        print(f"   after event 1: max |S|/Theta of unfired candidates = {max(others):.4f} (claim: <= 1/2)")
        print(f"   refit f = (x1+x2+x3)/2 ? max|f - (x1+x2+x3)/2| = {np.max(np.abs(race.f - (X[:,0]+X[:,1]+X[:,2])/2)):.2e}")
        # max depth-2 utility against the residual -x1x2x3/2
        dep2 = [abs(np.mean(race.r * c["v"])) for c in race.cand.values() if not c["fired"] and c["depth"] == 2]
        dep1 = [abs(np.mean(race.r * c["v"])) for c in race.cand.values() if not c["fired"] and c["depth"] == 1]
        print(f"   residual utilities after event 1: max over depth-1 = {max(dep1):.4f}, max over depth-2 = {max(dep2):.4f}, "
              f"#depth-2 candidates attaining it = {sum(abs(u - max(dep2)) < 1e-9 for u in dep2)}")

# ---------------------------------------------------------------- 4. MAJ_5 first event
print("\n## 4. Population MAJ_5, first event (d = 6)")
X6 = cube(6)
y5 = np.sign(X6[:, :5].sum(1))
race5 = PopRaceLS(X6, y5, maxdepth=1)
firing, nf = race5.step()
u5 = math.comb(4, 2) / 2 ** 4
others = [abs(c["S"]) for c in race5.cand.values() if not c["fired"]]
print(f" t/Theta = {race5.t:.4f} (1/u_5 = {1/u5:.4f}); gates fired = {len(firing)} (m^2 = 25); "
      f"max other clock = {max(others):.4f}; kappa(pop) of the 25 = {race5.kappa():.3f}; (tau/Theta)^2 = {race5.t**2:.3f}")
lin = (u5 * X6[:, :5].sum(1))
print(f" refit equals u_5 * sum x_i: {np.allclose(race5.f, lin)}; sign(refit) == MAJ_5: {np.all(np.sign(race5.f) == y5)}")

# ---------------------------------------------------------------- 5. s*(maj3)
print("\n## 5. Smallest consistent circuit for maj3 (toy library, sign readout)")
X3 = cube(3)
y3 = np.sign(X3.sum(1))
def threshold_ok(feats, target):
    A = -(target[:, None] * np.hstack([np.ones((len(target), 1)), feats]))
    res = linprog(np.zeros(feats.shape[1] + 1), A_ub=A, b_ub=-np.ones(len(target)),
                  bounds=[(None, None)] * (feats.shape[1] + 1), method="highs")
    return res.status == 0
def gates_on(srcs):
    out = [s for s in srcs]  # identity
    for a, b in itertools.combinations(srcs, 2):
        out += [g for _, g in bin_gates(a, b)]
    return out
inputs = [X3[:, i] for i in range(3)]
found1 = any(threshold_ok(g[:, None], y3) for g in gates_on(inputs))
found2 = None
for g1 in gates_on(inputs):
    for g2 in gates_on(inputs + [g1]):
        if threshold_ok(np.stack([g1, g2], 1), y3):
            found2 = (g1, g2); break
    if found2: break
print(f" 1-gate circuit exists: {found1};  2-gate circuit exists: {found2 is not None}")

# ---------------------------------------------------------------- 6. A1 vs BEHW
print("\n## 6. A1 realizable bound vs the BEHW symmetrization route (|G|=6, d=30, k=2, delta=0.05)")
def behw_eps(T, n, delta=0.05):
    # P(exists consistent h with err > eps) <= 2 Pi(2n) 2^{-eps n / 2}, Pi(2n) <= |W_T| Phi(2n, T), union over T
    W = sum(math.log(6) + 2 * math.log(30 + t - 1) for t in range(1, T + 1))
    logPi = W + log_phi(2 * n, T)
    return 2 * (math.log(2) + logPi + math.log((T + 1) * (T + 2) / delta)) / (n * math.log(2))
for n in [1024, 4096, 16384]:
    cross = None
    for T in range(1, 200):
        a1 = 1 - math.exp(-L_T(T) / n)
        bw = behw_eps(T, n)
        if a1 > bw and cross is None:
            cross = T
    print(f" n={n:5d}: A1 smaller than BEHW for T < {cross}  (note: 'whenever T <~ log2(2n)' = {math.log2(2*n):.0f});"
          f" at T=10: A1={1-math.exp(-L_T(10)/n):.3f}, BEHW={behw_eps(10, n):.3f}")

# ---------------------------------------------------------------- 7. random dictionaries: SC and LS
print("\n## 7. Random correlated dictionaries: (SC) race with exits, (LS) depth-one race")
def run_SC(G, y, tmax=60.0, maxev=400):
    n, M = G.shape
    S = np.zeros(M); sat = np.zeros(M, bool); sig = np.zeros(M)
    t = tau = 0.0; Rint = np.zeros(n)
    c0 = y.mean(); c = np.zeros(M); r = y - c0
    worst = dict(ident=0.0, clockR=0.0, overshoot=0.0, kkt=0.0); exits = 0; ev = 0
    def refit():
        idx = np.where(sat)[0]
        if len(idx) == 0:
            return y.mean(), np.zeros(M)
        F = G[:, idx]; Fm = F.mean(0)
        cc, _ = nnls((F - Fm) * sig[idx], y - y.mean())
        cf = np.zeros(M); cf[idx] = cc * sig[idx]
        return y.mean() - Fm @ cf[idx], cf
    while t < tmax and ev < maxev:
        U = G.T @ r / n
        moving = ~sat
        with np.errstate(divide="ignore", invalid="ignore"):
            dt = np.where(U > TOL, (1 - S) / U, np.where(U < -TOL, (1 + S) / -U, np.inf))
        dt[~moving] = np.inf
        # saturated with c=0 and inward utility move too (they are not in Sat by definition: handled below)
        dtm = float(dt.min())
        if not np.isfinite(dtm):
            break
        S[moving] += U[moving] * dtm
        Rint += r * dtm; tau += np.sqrt(np.mean(r ** 2)) * dtm; t += dtm
        fire = np.where(dt <= dtm * (1 + 1e-12) + 1e-14)[0]
        S[fire] = np.sign(S[fire]); sig[fire] = S[fire]; sat[fire] = True
        while True:
            c0, c = refit(); r = y - c0 - G @ c
            U = G.T @ r / n
            leave = np.where(sat & (np.abs(c) < 1e-12) & (sig * U < -1e-12))[0]
            if len(leave) == 0:
                break
            sat[leave] = False; exits += len(leave)
        ev += 1
        f = c0 + G @ c
        worst["ident"] = max(worst["ident"], abs(np.abs(c).sum() - np.mean(Rint * f)))
        worst["clockR"] = max(worst["clockR"], np.max(np.abs(S - G.T @ Rint / n)))
        worst["overshoot"] = max(worst["overshoot"], np.max(np.abs(S)) - 1)
        worst["kkt"] = max(worst["kkt"], np.max(np.abs(U[np.abs(c) > 1e-12]), initial=0.0))
        assert np.abs(c).sum() <= np.sqrt(np.mean(Rint ** 2)) * np.sqrt(1 - y.mean() ** 2) + 1e-8
        assert np.sqrt(np.mean(Rint ** 2)) <= tau + 1e-9
    return worst, exits, ev, np.abs(c).sum(), tau

def run_LS(G, y, tmax=30.0, maxev=300):
    n, M = G.shape
    S = np.zeros(M); fired = np.zeros(M, bool); t = tau = 0.0
    r = y - y.mean(); worst_ratio = 0.0; ev = 0
    while t < tmax and ev < maxev and fired.sum() < min(n - 2, M):
        U = G.T @ r / n
        with np.errstate(divide="ignore", invalid="ignore"):
            dt = np.where(U > TOL, (1 - S) / U, np.where(U < -TOL, (1 + S) / -U, np.inf))
        dt[fired] = np.inf
        dtm = float(dt.min())
        if not np.isfinite(dtm):
            break
        S[~fired] += U[~fired] * dtm; tau += np.sqrt(np.mean(r ** 2)) * dtm; t += dtm
        fire = np.where(dt <= dtm * (1 + 1e-12) + 1e-14)[0]
        fired[fire] = True; S[fire] = np.sign(S[fire])
        F = np.hstack([np.ones((n, 1)), G[:, fired]])
        coef, *_ = np.linalg.lstsq(F, y, rcond=None); r = y - F @ coef
        Fc = G[:, fired] - G[:, fired].mean(0)
        kap = np.linalg.eigvalsh(Fc.T @ Fc / n)[-1]
        T = fired.sum()
        worst_ratio = max(worst_ratio, T / (kap * tau ** 2))
        ev += 1
    return worst_ratio, ev, fired.sum()

rng = np.random.default_rng(1)
agg = dict(ident=0.0, clockR=0.0, overshoot=0.0, kkt=0.0); tot_exits = 0; worst_ls = 0.0
for trial in range(40):
    n, M = 40, 25
    base = rng.standard_normal((n, 5))
    G = np.tanh(base @ rng.standard_normal((5, M)) * 0.7 + 0.5 * rng.standard_normal((n, M)))   # correlated, |g| <= 1
    y = np.sign(base[:, 0] + 0.5 * base[:, 1] * base[:, 2] + 0.3 * rng.standard_normal(n))
    w, ex, ev, l1, tau = run_SC(G, y)
    for k in agg:
        agg[k] = max(agg[k], w[k])
    tot_exits += ex
    wr, _, _ = run_LS(G, y)
    worst_ls = max(worst_ls, wr)
print(f" SC (40 trials): total exits from the saturated set = {tot_exits};")
print(f"   max | ||c||_1 - <R,f>_n | = {agg['ident']:.2e} (Theorem A2.4, Theta=1); max |S_m - <R,g_m>_n| = {agg['clockR']:.2e};")
print(f"   max (|S|-Theta) = {agg['overshoot']:.2e} (Lemma 2.2(3)); max |U_m| on support = {agg['kkt']:.2e}; chain <= ||R|| <= tau asserted")
print(f" LS (40 trials): max over events of T / (kappa tau^2) = {worst_ls:.3f} (Theorem A2.3 needs <= 1)")

# ---------------------------------------------------------------- 8. mask ordering in race_bounds.py
print("\n## 8. race_bounds.py: S[~dormant] = [sign[m] for m in active] assigns in index order, not in 'active' order")
S = np.zeros(6); active = [4, 1]; sign = {4: 1.0, 1: -1.0}
dormant = np.ones(6, bool); dormant[active] = False
S[~dormant] = np.array([sign[m] for m in active])
print(f" active={active}, sign={sign} -> S[1]={S[1]}, S[4]={S[4]} (should be -1, +1). "
      "Harmless in LS (fired clocks unused); in SC it would corrupt the clock of a gate that later exits.")

# ---------------------------------------------------------------- 9. first-occurrence validation
print("\n## 9. Proposition A3.4(3): first-occurrence validation, adaptive memorizer, Monte Carlo")
# domain of 50 points, label = fixed random function; learner predicts the stored label if seen, else majority of seen labels
rngm = np.random.default_rng(2)
Dsz, n, K, reps = 50, 30, 20, 20000
lab = rngm.choice([-1, 1], size=Dsz, p=[0.3, 0.7])
gaps = []
for rep in range(reps):
    zs = rngm.integers(0, Dsz, size=n)           # training set S (iid from uniform over the domain)
    seen_labels = {}                              # memory: x -> y
    k = 0; firsts = set(); gap = 0.0
    while k < K:
        i = int(rngm.integers(0, n))
        x = int(zs[i])
        if i not in firsts:
            firsts.add(i); k += 1
            # predictor before this draw
            maj = 1 if sum(seen_labels.values()) >= 0 else -1
            pred = np.array([seen_labels.get(u, maj) for u in range(Dsz)])
            Lh = np.mean(pred != lab)
            gap += Lh - float(pred[x] != lab[x])
        seen_labels[x] = int(lab[x])
    gaps.append(gap / K)
gaps = np.array(gaps)
print(f" mean of (1/K) sum [L(h_s_k) - loss on first occurrence] = {gaps.mean():.4f} +- {gaps.std()/np.sqrt(reps):.4f} (should be ~0);"
      f" P(gap > sqrt(log(1/0.05)/(2K))) = {np.mean(gaps > math.sqrt(math.log(20)/(2*K))):.4f} (should be <= 0.05)")
