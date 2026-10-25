"""Numerical sanity check of the A1/A2 bounds in ../A-discrete-model.md.

A toy discrete circuit-growth model ("clock race") on d=30 Boolean inputs.

Library G (up to negation, which the linear readout absorbs):
    identity x_a (fan-in 1, inputs only), AND(+-a, +-b) (4 sign patterns), XOR(a, b).
So |G| = 6 in the counting bound, fan-in k = 2.

Clock model, time measured in units of Theta = log(1/alpha) (the race is
scale-free in Theta: every event time is proportional to Theta):
  * candidate m has clock S_m(t) = int_{a_m}^t U_m(s) ds, U_m = <r, g_m>_n, where
    a_m is the time its last source fired;
  * a dormant candidate fires when |S_m| reaches 1;
  * LS variant: readout = least squares (with intercept) on all fired gates;
    candidates may read inputs and fired gates (depth grows);
  * SC variant (depth-1 dictionary only): sign-constrained least squares; the
    readout support is the set of saturated clocks with matching signs
    (Pesme-Flammarion-type recursion).
Candidates that coincide on the training sample with an existing candidate or
gate are merged (one representative is kept).

Outputs (stdout): per event, T, depth, tau/Theta, kappa, the A2 size and depth
bounds, train/test error, and the A1 Occam bounds; for SC also ||c||_1 versus
||R(t)||_n / Theta (Theorem A2.4) and the l1/Rademacher bound.

Run: python3 race_bounds.py > race_bounds.txt     (a few minutes, one core)

Revision 2 (after referee round 1): fixed the clock-sign assignment of active gates in
Race.step, made the (SC) exit step iterate to a fixed point, split delta between the two
Theorem A1' bounds, and added the (SC) size check |Sat| <= kappa_Sat (||R||_n/Theta)^2.
The exit branch itself is tested in A_r2_checks.py.
"""
import math, sys, itertools
import numpy as np
from scipy.optimize import nnls

D = 30
GSIZE, FANIN = 6, 2
DELTA = 0.05
rng_global = np.random.default_rng(0)

# ----------------------------------------------------------------- targets
def target(name, X):
    if name == "par2":
        return X[:, 0] * X[:, 1]
    if name == "par3":
        return X[:, 0] * X[:, 1] * X[:, 2]
    if name == "maj3":
        return np.sign(X[:, 0] + X[:, 1] + X[:, 2])
    if name == "and3":
        return np.where((X[:, 0] > 0) & (X[:, 1] > 0) & (X[:, 2] > 0), 1.0, -1.0)
    if name == "dnf3":
        a = (X[:, 0] > 0) & (X[:, 1] > 0) & (X[:, 2] > 0)
        b = (X[:, 3] > 0) & (X[:, 4] < 0) & (X[:, 5] > 0)
        c = (X[:, 6] > 0) & (X[:, 7] > 0) & (X[:, 8] < 0)
        return np.where(a | b | c, 1.0, -1.0)
    raise ValueError(name)

# ----------------------------------------------------------------- gates
def AND(u, v):
    return np.where((u > 0) & (v > 0), 1.0, -1.0)

def binary_gates(u, v):
    """The 5 binary library functions (up to negation) of two +-1 vectors."""
    return [AND(u, v), AND(-u, v), AND(u, -v), AND(-u, -v), u * v]

BIN_NAMES = ["AND(a,b)", "AND(~a,b)", "AND(a,~b)", "AND(~a,~b)", "XOR(a,b)"]

# ----------------------------------------------------------------- bounds
def kl(q, p):
    eps = 1e-300
    a = 0.0 if q == 0 else q * math.log(q / max(p, eps))
    b = 0.0 if q == 1 else (1 - q) * math.log((1 - q) / max(1 - p, eps))
    return a + b

def kl_inv_upper(q, c):
    """largest p >= q with kl(q||p) <= c"""
    lo, hi = q, 1.0
    if kl(q, 1 - 1e-15) <= c:
        return 1.0
    for _ in range(100):
        mid = (lo + hi) / 2
        if kl(q, mid) <= c:
            lo = mid
        else:
            hi = mid
    return lo

def log_phi(N, T):
    """log of Cover's count 2*sum_{i<=T} C(N-1, i): threshold readouts of N points in R^T."""
    s = sum(math.comb(N - 1, i) for i in range(0, min(T, N - 1) + 1))
    return math.log(2) + math.log(s)

def log_W(T, d=D, G=GSIZE, k=FANIN):
    return sum(math.log(G) + k * math.log(d + t - 1) for t in range(1, T + 1))

def L_T(T, delta=DELTA, d=D):
    N = 2 ** min(T, d)
    return log_W(T) + log_phi(N, T) + math.log((T + 1) * (T + 2) / delta)

def occam_bounds(train_err, T, n):
    L = L_T(T)
    kl_b = kl_inv_upper(train_err, L / n)
    bern = train_err + math.sqrt(2 * train_err * L / n) + 2 * L / n
    hoef = train_err + math.sqrt(L / (2 * n))
    return kl_b, bern, hoef

# ----------------------------------------------------------------- race (LS, any depth)
class Race:
    def __init__(self, X, y, Xte, yte, variant="LS", depth1=False):
        self.X, self.y, self.Xte, self.yte = X, y, Xte, yte
        self.n = len(y)
        self.variant, self.depth1 = variant, depth1 or variant == "SC"
        self.t = 0.0                    # time in units of Theta
        self.tau = 0.0                  # int_0^t ||r||_n ds, same units
        self.R = np.zeros(self.n)       # int_0^t r(s) ds
        # candidate store
        self.cand_tr, self.cand_te, self.cand_name, self.cand_depth = [], [], [], []
        self.seen = set()
        # active gates (indices into the candidate store)
        self.active, self.sign = [], {}
        self.exits = 0                  # SC: number of gates that left the saturated set
        self.c0, self.c = float(np.mean(y)), np.zeros(0)
        self.r = y - self.c0
        # sources: inputs
        self.src_tr = [X[:, i] for i in range(D)]
        self.src_te = [Xte[:, i] for i in range(D)]
        self.src_name = [f"x{i+1}" for i in range(D)]
        self.src_depth = [0] * D
        for i in range(D):
            self._add_cand(X[:, i], Xte[:, i], f"x{i+1}", 1)
        for i, j in itertools.combinations(range(D), 2):
            self._add_pairs(i, j)
        self._finalize()

    def _key(self, v):
        v = v if v[0] > 0 else -v
        return np.packbits(v > 0).tobytes()

    def _add_cand(self, vtr, vte, name, depth):
        if np.all(vtr == vtr[0]):
            return
        key = self._key(vtr)
        if key in self.seen:
            return
        self.seen.add(key)
        self.cand_tr.append(vtr.astype(np.float32)); self.cand_te.append(vte.astype(np.int8))
        self.cand_name.append(name); self.cand_depth.append(depth)

    def _add_pairs(self, i, j):
        a, b = self.src_tr[i], self.src_tr[j]
        ta, tb = self.src_te[i], self.src_te[j]
        dep = 1 + max(self.src_depth[i], self.src_depth[j])
        for g, gt, nm in zip(binary_gates(a, b), binary_gates(ta, tb), BIN_NAMES):
            self._add_cand(g, gt, nm.replace("a", self.src_name[i]).replace("b", self.src_name[j]), dep)

    def _finalize(self):
        self.G = np.stack(self.cand_tr, 1).astype(np.float64)       # n x M
        self.S = np.zeros(len(self.cand_tr))
        self.avail = np.zeros(len(self.cand_tr))

    def _grow_store(self, start):
        new = np.stack(self.cand_tr[start:], 1).astype(np.float64) if len(self.cand_tr) > start else None
        if new is not None:
            self.G = np.concatenate([self.G, new], 1)
        self.S = np.concatenate([self.S, np.zeros(len(self.cand_tr) - len(self.S))])
        self.avail = np.concatenate([self.avail, np.full(len(self.cand_tr) - len(self.avail), self.t)])

    def refit(self):
        y = self.y
        if not self.active:
            self.c0, self.c = float(np.mean(y)), np.zeros(0)
        else:
            F = self.G[:, self.active]
            Fm = F.mean(0)
            Fc = F - Fm
            yc = y - y.mean()
            if self.variant == "LS":
                c, *_ = np.linalg.lstsq(Fc, yc, rcond=None)
            else:
                sg = np.array([self.sign[m] for m in self.active])
                cc, _ = nnls(Fc * sg, yc)
                c = cc * sg
            self.c = c
            self.c0 = float(y.mean() - Fm @ c)
        self.r = y - self.f_train()

    def f_train(self):
        if not self.active:
            return np.full(self.n, self.c0)
        return self.c0 + self.G[:, self.active] @ self.c

    def f_test(self):
        if not self.active:
            return np.full(len(self.yte), self.c0)
        Gt = np.stack([self.cand_te[m] for m in self.active], 1).astype(np.float64)
        return self.c0 + Gt @ self.c

    def step(self):
        """advance to the next event; returns False if the race has stopped"""
        U = self.G.T @ self.r / self.n
        dormant = np.ones(len(U), bool)
        if self.active:
            dormant[self.active] = False
        with np.errstate(divide="ignore", invalid="ignore"):
            dt = np.where(U > 1e-13, (1 - self.S) / U, np.where(U < -1e-13, (1 + self.S) / -U, np.inf))
        dt[~dormant] = np.inf
        if self.variant == "SC":
            # saturated clocks with zero weight and inward utility detach immediately (handled at refit)
            pass
        dtm = float(np.min(dt))
        if not np.isfinite(dtm):
            return False
        # advance clocks of all candidates (active ones have U = 0 in LS; in SC
        # active-with-positive-weight have U = 0 and zero-weight saturated ones are dormant)
        self.S = self.S + U * dtm
        if self.active:
            # keep active clocks exactly saturated.  (Revision 2: the earlier line
            # `self.S[~dormant] = [sign[m] for m in active]` assigned in index order while
            # `active` is in firing order, so active clocks could get the wrong sign.  Harmless
            # in LS; in SC it would corrupt the clock of a gate that later exits.)
            self.S[self.active] = np.array([self.sign[m] for m in self.active])
        self.R = self.R + self.r * dtm
        self.tau += np.sqrt(np.mean(self.r ** 2)) * dtm
        self.t += dtm
        fire = np.where(dt <= dtm * (1 + 1e-9) + 1e-12)[0]
        start = len(self.cand_tr)
        for m in fire:
            self.sign[int(m)] = 1.0 if self.S[m] > 0 else -1.0
            self.S[m] = self.sign[int(m)]
            self.active.append(int(m))
            if not self.depth1:
                # the new gate becomes a source
                self.src_tr.append(self.G[:, m]); self.src_te.append(self.cand_te[m].astype(np.float64))
                self.src_name.append(f"[{self.cand_name[m]}]"); self.src_depth.append(self.cand_depth[m])
                new = len(self.src_tr) - 1
                for j in range(new):
                    self._add_pairs(j, new)
        if len(self.cand_tr) > start or len(self.S) < len(self.cand_tr):
            self._grow_store(start)
        self.refit()
        if self.variant == "SC":
            # detach saturated gates whose weight is zero and whose utility points inward;
            # repeat the refit until no gate leaves (revision 2: previously a single pass)
            while True:
                keep = []
                for idx, m in enumerate(self.active):
                    if abs(self.c[idx]) < 1e-12 and self.sign[m] * (self.G[:, m] @ self.r) / self.n < -1e-12:
                        continue
                    keep.append(m)
                if len(keep) == len(self.active):
                    break
                self.exits += len(self.active) - len(keep)
                self.active = keep
                self.refit()
        return True

    def kappa(self):
        if not self.active:
            return 0.0
        F = self.G[:, self.active]
        Fc = F - F.mean(0)
        K = Fc.T @ Fc / self.n
        return float(np.linalg.eigvalsh(K)[-1])

    def depth(self):
        return max([self.cand_depth[m] for m in self.active], default=0)


def run(name, n, variant="LS", tmax=12.0, Tmax=60, seed=0, verbose=True, out=sys.stdout):
    rng = np.random.default_rng([seed, n, sum(map(ord, name))])
    X = rng.choice([-1.0, 1.0], size=(n, D)); y = target(name, X)
    Xte = rng.choice([-1.0, 1.0], size=(20000, D)); yte = target(name, Xte)
    race = Race(X, y, Xte, yte, variant=variant)
    rows = []
    first_interp = None
    while race.t < tmax and len(race.active) < Tmax:
        if not race.step():
            break
        ftr, fte = race.f_train(), race.f_test()
        tr_err = float(np.mean(np.where(ftr > 0, 1, -1) != y))
        te_err = float(np.mean(np.where(fte > 0, 1, -1) != yte))
        T = len(race.active)
        kap = race.kappa()
        row = dict(t=race.t, tau=race.tau, T=T, depth=race.depth(), kappa=kap,
                   size_bound=kap * race.tau ** 2, depth_bound=race.tau,
                   train_loss=0.5 * float(np.mean((ftr - y) ** 2)), train_err=tr_err, test_err=te_err)
        row["kl"], row["bern"], row["hoef"] = occam_bounds(tr_err, T, n)
        if variant == "SC":
            l1 = float(np.sum(np.abs(race.c)))
            Rn = float(np.sqrt(np.mean(race.R ** 2)))
            ident = float(np.mean(race.R * ftr))           # should equal ||c||_1 (Theta = 1)
            # Theorem A1' with F = depth-1 dictionary, B = ||c||_1, |c0| <= 1 + B
            B = l1
            j = max(0, math.ceil(math.log2(max(B, 1.0))))
            Bj = 2.0 ** j
            assert abs(race.c0) <= 1 + Bj + 1e-9
            logF2 = math.log(2 * race.G.shape[1])          # |F| = #depth-1 candidates (merged)
            pij = 1.0 / ((j + 1) * (j + 2))
            rad = (1 + Bj) / math.sqrt(n) + Bj * math.sqrt(2 * logF2 / n)
            # revision 2: confidence pi_j * delta / 2 for each of the two bounds, so that both
            # hold jointly with probability >= 1 - delta
            conf = math.sqrt(math.log(2 / (pij * DELTA)) / (2 * n))
            clip_tr = 0.5 * float(np.mean((np.clip(ftr, -1, 1) - y) ** 2))
            clip_te = 0.5 * float(np.mean((np.clip(fte, -1, 1) - yte) ** 2))
            sq_bound = clip_tr + 4 * rad + 2 * conf
            th = 0.5
            ramp_tr = float(np.mean(np.clip(1 - y * ftr / th, 0, 1)))
            ramp_bound = ramp_tr + (2 / th) * rad + conf
            row.update(l1=l1, R_over_Theta=Rn, ident=ident, tau_bound=race.tau, B=B, clip_tr=clip_tr,
                       clip_te=clip_te, sq_bound=sq_bound, ramp_bound=ramp_bound,
                       # revision 2: (SC) form of Theorem A2.3, |Sat| <= kappa_Sat (||R||_n/Theta)^2
                       sc_size=kap * Rn ** 2, exits=race.exits,
                       clock_err=float(np.max(np.abs(race.S - race.G.T @ race.R / race.n))))
        rows.append(row)
        if first_interp is None and tr_err == 0:
            first_interp = row
        if row["train_loss"] < 1e-20:
            break
    if verbose:
        print(f"\n### {name}  n={n}  variant={variant}  (#depth-1 candidates after merging: {race.G.shape[1] if variant=='SC' else 'n/a'})", file=out)
        if variant == "LS":
            print(f"{'t/Th':>6} {'tau/Th':>6} {'T':>3} {'dep':>3} {'kappa':>6} {'k*tau^2':>8} {'trLoss':>7} {'trErr':>6} {'teErr':>6} {'A1-kl':>6} {'A1-bern':>7}", file=out)
            for r in rows:
                print(f"{r['t']:6.2f} {r['tau']:6.2f} {r['T']:3d} {r['depth']:3d} {r['kappa']:6.2f} {r['size_bound']:8.2f} "
                      f"{r['train_loss']:7.4f} {r['train_err']:6.3f} {r['test_err']:6.3f} {min(1,r['kl']):6.3f} {min(1,r['bern']):7.3f}", file=out)
        else:
            print(f"{'t/Th':>6} {'tau/Th':>6} {'T':>3} {'||c||1':>7} {'<R,f>':>7} {'|R|/Th':>7} {'clipTr':>7} {'clipTe':>7} {'A1psq':>6} {'trErr':>6} {'teErr':>6} {'A1pramp':>7}", file=out)
            for r in rows:
                print(f"{r['t']:6.2f} {r['tau']:6.2f} {r['T']:3d} {r['l1']:7.3f} {r['ident']:7.3f} {r['R_over_Theta']:7.3f} "
                      f"{r['clip_tr']:7.4f} {r['clip_te']:7.4f} {min(9.99,r['sq_bound']):6.3f} {r['train_err']:6.3f} {r['test_err']:6.3f} {min(9.99,r['ramp_bound']):7.3f}", file=out)
    return rows, first_interp


if __name__ == "__main__":
    out = sys.stdout
    print("# Toy clock-race model: A1/A2 sanity check (time in units of Theta = log 1/alpha; delta = 0.05)", file=out)
    print("# Columns: t/Th = time; tau/Th = int ||r||_n dt (A2 'effective time'); T = #gates; dep = depth;", file=out)
    print("# kappa = top eigenvalue of the centred Gram matrix of active gates; k*tau^2 = A2.3 size bound;", file=out)
    print("# A1-kl / A1-bern = Theorem A1 bounds (kl inversion / Bernstein form) on the test 0-1 error.", file=out)
    summary = []
    for name in ["par2", "maj3", "and3", "dnf3", "par3"]:
        for n in [64, 256, 1024, 4096]:
            rows, fi = run(name, n, "LS", tmax=10.0 if name != "par3" else 4.0, Tmax=40)
            # checks of the proved inequalities
            ok_size = all(r["T"] <= r["size_bound"] + 1e-9 for r in rows)
            ok_depth = all(r["depth"] <= r["depth_bound"] + 1e-9 for r in rows)
            ok_A1 = all(r["test_err"] <= r["kl"] + 0.01 for r in rows)
            summary.append((name, n, fi, rows[-1] if rows else None, ok_size, ok_depth, ok_A1))
    print("\n## Proposition A2.6 check (par3): first firing time vs the proved lower bound Theta/(2 eps)", file=out)
    for name, n, fi, last, a, b, c in summary:
        if name != "par3":
            continue
        M1 = 2205
        eps = math.sqrt(2 * math.log(2 * (M1 + 1) / DELTA) / n)
        rows, _ = run(name, n, "LS", tmax=40.0, Tmax=1, verbose=False)
        print(f"  n={n:5d}: first firing at t/Theta = {rows[0]['t']:.2f};  bound 1/(2 eps) = {1/(2*eps):.2f};"
              f"  heuristic sqrt(n/(2 log 2M)) = {math.sqrt(n/(2*math.log(2*M1))):.2f}", file=out)
    print("\n## Summary (LS race): first zero-train-error event and last event", file=out)
    print(f"{'target':>6} {'n':>5} | {'T@0':>4} {'t/Th':>5} {'teErr':>6} {'A1-kl':>6} | {'T_end':>5} {'t/Th':>5} {'teErr':>6} {'A1-kl':>6} | size depth A1 ok", file=out)
    for name, n, fi, last, a, b, c in summary:
        s1 = f"{fi['T']:4d} {fi['t']:5.2f} {fi['test_err']:6.3f} {min(1,fi['kl']):6.3f}" if fi else f"{'-':>4} {'-':>5} {'-':>6} {'-':>6}"
        s2 = f"{last['T']:5d} {last['t']:5.2f} {last['test_err']:6.3f} {min(1,last['kl']):6.3f}" if last else ""
        print(f"{name:>6} {n:5d} | {s1} | {s2} | {a} {b} {c}", file=out)
    print("\n## SC race on the depth-1 dictionary: check of Theorem A2.4 (||c||_1 = <R,f>_n/Theta <= ||R||_n/Theta <= tau/Theta)", file=out)
    for name in ["maj3", "and3", "par2"]:
        for n in [256, 4096]:
            rows, _ = run(name, n, "SC", tmax=10.0, Tmax=40)
            ok = all(abs(r["l1"] - r["ident"]) < 1e-6 and r["l1"] <= r["R_over_Theta"] + 1e-9 and r["R_over_Theta"] <= r["tau"] + 1e-9 for r in rows)
            print(f"  identity and inequalities hold at every event: {ok}", file=out)
            ok_sc = all(r["T"] <= r["sc_size"] + 1e-9 for r in rows)
            print(f"  (SC) size bound |Sat| <= kappa_Sat (||R||_n/Theta)^2 at every event: {ok_sc}; "
                  f"max |S_m - <R,g_m>_n| = {max(r['clock_err'] for r in rows):.1e}; "
                  f"exits from the saturated set: {rows[-1]['exits'] if rows else 0}", file=out)
            print(f"  (A1psq: Theorem A1' bound on test clipped square loss; A1pramp: Theorem A1' bound on test 0-1 error, theta = 1/2)", file=out)
