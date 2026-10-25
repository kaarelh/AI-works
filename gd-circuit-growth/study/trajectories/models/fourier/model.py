"""Fourier race: a character-level model of the sequence of functions a network passes through while it learns a
Boolean target (see MODEL.md for the rule, its motivation and its calibration).

The learned function at step t is   f_t(x) = sum_S  yhat_S * phi_S(t) * chi_S(x)   on the relevant cube, where yhat_S are
the target's Fourier coefficients and phi_S(t) in [0, 1] is the learned fraction of character S.  The phi_S are produced
by an event-driven race of "moves" on the lattice of characters:

  * a move takes a learned base (the empty set, a learned character U, or the whole bundle learned in one earlier
    move) and multiplies it by e input variables at once; it learns every residual character it reaches (a bundle);
  * each move accumulates progress at rate  G_n(t) * rho^(1/2) / tau,  rho = (strength of its bundle) / |residual|,
    tau = TAU * e^ALPHA * K^[gated] * K^[odd degree >= 3];   it fires when the progress reaches 1;
  * when it fires its characters rise along a logistic in the progress with slope e*ln(d) (saddle escape from an
    overlap d^(-1/2)), the residual is updated, the fired characters become bases, and the race goes on;
  * junta completion: after a move on already-active inputs that has order >= 2 or reaches degree >= 3, all remaining
    characters on the active inputs form one more (order-1, gated) move;
  * finite n: progress is throttled by memorisation, G_n(t) = 1/(1 + (t/T_c(n))^8), T_c(n) = EPOCHS * n / 64,
    and each fired bundle is learned only to the BBP fraction 1 - NBBP/(n rho^2).

Five fitted constants: TAU, ALPHA, K, NBBP, EPOCHS (values in PARAMS).
"""
import os, sys, itertools, math
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
if STUDY not in sys.path:
    sys.path.insert(0, STUDY)
from boolfuncs import make_suite

D = 30                 # input dimension
BATCH = 64             # minibatch size (sets the length of an epoch)
STEPS_MAX = 20000
LND = math.log(D)

# ---- the five fitted constants (fitted jointly on sparsepoly, stair5, mux, majpar, rmaj9 x 4 conditions; MODEL.md)
PARAMS = dict(
    TAU=44.2,          # time scale of a move: steps to fire for a fresh (root) one-input move at rho = 1
    ALPHA=2.0,         # cost exponent in the number e of inputs a move multiplies at once (fit 2.06, rounded)
    K=2.0,             # cost factor for a gated move (built on a learned feature) and for odd degree >= 3 (fit 2.00)
    NBBP=45.9,         # noise count of the finite-n (BBP-like) shrinkage
    EPOCHS=35.4,       # memorisation cutoff, in passes over the training set
)
# ---- fixed structural choices (not fitted)
STRUCT = dict(
    P_RHO=0.5,         # progress rate ~ rho^(1/2)
    GC=8.0,            # steepness of the memorisation cutoff
    CTRIG=1,           # junta completion also after a k = 0 move that reaches degree >= 3 (not only after e >= 2)
    DECAY=1,           # a bundle that loses members to other moves keeps progress in proportion to its strength
)

_SUITE = None
POP = np.array([bin(i).count("1") for i in range(2 ** 12)])


def suite():
    global _SUITE
    if _SUITE is None:
        _SUITE = make_suite(D)
    return _SUITE


def spectrum(fn, target=None):
    """Target on its relevant cube (itertools.product order) and its Fourier coefficients indexed by bitmask
    (bit i <-> i-th relevant variable).  target: optional dict(fn=callable, relevant=list) overriding the suite."""
    S = target or suite()[fn]
    R = list(S["relevant"]); r = len(R)
    pats = np.array(list(itertools.product([-1.0, 1.0], repeat=r)))
    X = np.ones((len(pats), D)); X[:, R] = pats
    y = np.asarray(S["fn"](X), dtype=np.float64)
    nm = 2 ** r
    chi = np.ones((len(pats), nm))
    for m in range(1, nm):
        sel = np.array([(m >> i) & 1 for i in range(r)], bool)
        chi[:, m] = np.prod(pats[:, sel], axis=1)
    yhat = chi.T @ y / len(y)
    yhat[np.abs(yhat) < 1e-12] = 0.0
    return dict(R=R, r=r, pats=pats, y=y, chi=chi, yhat=yhat)


def time_grid():
    return np.concatenate([[0.0], np.logspace(-0.3, math.log10(STEPS_MAX), 600)])


def _pair_strength(U, mem, rh, r):
    """Spectral norm of the matrix M_jk = residual coefficient of U * x_j * x_k (the best single pair-direction)."""
    M = np.zeros((r, r))
    for m in mem:
        x = int(m) ^ U
        ij = [i for i in range(r) if (x >> i) & 1]
        M[ij[0], ij[1]] = M[ij[1], ij[0]] = rh[m]
    return float(np.max(np.abs(np.linalg.eigvalsh(M))))


class Race:
    def __init__(self, sp, n, prm, st):
        self.sp, self.n, self.prm, self.st = sp, n, prm, st
        self.r = sp["r"]; self.yhat = sp["yhat"]; self.nm = 2 ** self.r
        self.chars = np.array([m for m in range(1, self.nm) if self.yhat[m] != 0.0], dtype=int)
        nm = self.nm
        self.level = np.zeros(nm); self.fired = np.zeros(nm, bool)
        self.gam = np.full(nm, LND)            # slope of the rise in progress units
        self.frozen = np.zeros(nm)             # progress rate after firing
        self.Pc = np.zeros(nm)                 # progress of fired characters
        self.rho_end = np.zeros(nm)
        self.cands = {}                        # key -> progress
        self.ev_sets = {}                      # event id -> (members, normalised target coefficients)
        self.comp_sets = {}                    # completion id -> members
        self.s_last = {}                       # key -> bundle strength at the previous update
        self.events = []

    # -------------------------------------------------------------- rules
    def bbp(self, rho2):
        if self.n is None:
            return 1.0
        return max(0.0, 1.0 - self.prm["NBBP"] / (self.n * max(rho2, 1e-12)))

    def tau(self, e, gated, odd):
        p, a = self.prm, self.st
        return (p["TAU"] * e ** p["ALPHA"] * (p["K"] if gated and a.get("GATE", 1) else 1.0)
                * (p["K"] if odd and a.get("ODD", 1) else 1.0))

    def active(self):
        a = 0
        for m in self.chars[self.fired[self.chars]]:
            a |= int(m)
        return a

    def add_char_base(self, U):
        for e in range(1, self.r + 1):
            self.cands.setdefault(("X", U, e), 0.0)

    def add_event_base(self, mem):
        if len(mem) < 2 or not self.st.get("EVBASE", 1):
            return
        c = self.yhat[mem] / np.sqrt(np.sum(self.yhat[mem] ** 2))
        eid = len(self.ev_sets)
        self.ev_sets[eid] = (np.array(mem, int), c)
        self.cands.setdefault(("D", eid, 1), 0.0)

    def candidates(self):
        """Members, strength rho, rate and slope of every live move under the current residual."""
        yhat, r, nm = self.yhat, self.r, self.nm
        rh = yhat * (1.0 - self.level); rh[0] = 0.0
        rn = math.sqrt(max(np.sum(rh ** 2), 1e-12))
        unf = self.chars[~self.fired[self.chars]]
        live = np.zeros(nm, bool); live[unf] = True
        act = self.active()
        out = []
        if len(unf) == 0:
            return out
        for key in self.cands:
            kind = key[0]
            if kind == "X":
                _, U, e = key
                mem = unf[POP[unf ^ U] == e]
                if U == 0 and self.st.get("ROOTNEW", 1):
                    mem = mem[(mem & act) == 0]          # root moves build on new inputs only
                if len(mem) == 0:
                    continue
                s = float(np.sqrt(np.sum(rh[mem] ** 2)))     # total strength of the bundle: sets its speed
                if e == 1 or not self.st.get("DIRBBP", 1):  # strength of its best single direction: sets the
                    s_dir = s                                # finite-n (BBP) level
                elif e == 2:
                    s_dir = _pair_strength(U, mem, rh, r)
                else:
                    s_dir = float(np.max(np.abs(rh[mem])))
                gated = U != 0
            elif kind == "D":
                emem, ec = self.ev_sets[key[1]]
                F = np.zeros((nm, r))
                for j in range(r):
                    F[emem ^ (1 << j), j] += ec
                F[0] = 0.0
                coef, *_ = np.linalg.lstsq(F, rh, rcond=None)
                proj = F @ coef
                s = s_dir = float(np.sqrt(np.sum(proj ** 2)))
                mem = unf[(np.abs(F[unf]).sum(1) > 0) & (np.abs(proj[unf]) > 1e-9)]
                if len(mem) == 0:
                    continue
                e, gated = 1, True
            else:  # "C": junta completion
                mem = self.comp_sets[key[1]]
                mem = mem[live[mem]]
                if len(mem) == 0:
                    continue
                s = s_dir = float(np.sqrt(np.sum(rh[mem] ** 2)))
                e, gated = 1, True
            if s <= 1e-12:
                continue
            w = rh[mem] ** 2
            odd = bool(np.sum(w[(POP[mem] % 2 == 1) & (POP[mem] >= 3)]) > 0.5 * np.sum(w)) if kind != "C" else False
            rho = min(s / rn, 1.0)
            rate = rho ** self.st["P_RHO"] / self.tau(e, gated, odd)
            if self.st.get("DECAY", 0):                  # bundle lost members to other moves: keep only the
                s_old = self.s_last.get(key)             # alignment that still points at the residual
                if s_old is not None and s < s_old:
                    self.cands[key] *= s / s_old
                self.s_last[key] = s
            out.append(dict(key=key, mem=mem, rho=rho, rho_dir=min(s_dir / rn, 1.0), rate=rate, e=e))
        return out

    # -------------------------------------------------------------- dynamics
    def run(self):
        tg = time_grid(); nm = self.nm
        if self.n is None:
            G = np.ones(len(tg))
        else:
            Tc = self.prm["EPOCHS"] * self.n / BATCH
            G = 1.0 / (1.0 + (tg / Tc) ** self.st["GC"])
        self.add_char_base(0)
        cs = self.candidates()
        outP = np.zeros((len(tg), nm))
        for k in range(len(tg)):
            t = tg[k]; dt = tg[k] - tg[k - 1] if k else 0.0
            for c in cs:
                self.cands[c["key"]] += G[k] * c["rate"] * dt
            fm = self.fired & (self.frozen > 0)
            self.Pc[fm] += self.frozen[fm] * G[k] * dt
            ready = sorted([c for c in cs if self.cands[c["key"]] >= 1.0], key=lambda c: -self.cands[c["key"]])
            if ready:
                newly = []
                act_before = self.active()
                for c in ready:
                    mem = [int(m) for m in c["mem"] if not self.fired[m]]
                    if not mem:
                        continue
                    key, e, rho = c["key"], c["e"], c["rho"]
                    linear_stage = key == ("X", 0, 1)
                    lev = 1.0 if linear_stage else self.bbp(c["rho_dir"] ** 2)
                    for m in mem:
                        self.fired[m] = True; self.level[m] = lev
                        self.frozen[m] = c["rate"]; self.Pc[m] = self.cands[key]; self.gam[m] = e * LND
                    newly.append((mem, e, all((m & ~act_before) == 0 for m in mem)))
                    self.events.append(dict(t=float(t), key=key, e=e, rho=float(rho), members=mem, level=lev))
                for mem, e, k0 in newly:
                    for m in mem:
                        self.add_char_base(m)
                    self.add_event_base(mem)
                    nonlin = e >= 2 or (self.st.get("CTRIG", 0) == 1 and max(POP[m] for m in mem) >= 3)
                    if k0 and nonlin and self.st.get("COMPLETION", 1):   # gate on active inputs: rest of junta one step away
                        act = self.active()
                        rest = [int(m) for m in self.chars if not self.fired[m] and (int(m) & ~act) == 0]
                        if rest:
                            cid = len(self.comp_sets)
                            self.comp_sets[cid] = np.array(rest, int)
                            self.cands[("C", cid, 1)] = 0.0
                cs = self.candidates()
            # progress of every character
            best = np.zeros(nm); bg = np.full(nm, LND); br = np.zeros(nm)
            for c in cs:
                p = self.cands[c["key"]]
                sel = c["mem"][p > best[c["mem"]]]
                best[sel] = p; bg[sel] = c["e"] * LND; br[sel] = c["rho_dir"]
            unf = self.chars[~self.fired[self.chars]]
            outP[k, unf] = best[unf]
            upd = unf[best[unf] > 0]
            self.gam[upd] = bg[upd]; self.rho_end[upd] = br[upd]
            fr = self.chars[self.fired[self.chars]]
            outP[k, fr] = self.Pc[fr]
        phi = np.zeros((len(tg), nm))
        T0 = self.prm["TAU"] / math.sqrt(D)
        phi[:, 0] = 1.0 - np.exp(-tg / T0)
        for m in self.chars:
            g = self.gam[m]
            lo = 1.0 / (1.0 + math.exp(g))
            x = 1.0 / (1.0 + np.exp(-g * (outP[:, m] - 1.0)))
            lev = self.level[m] if self.fired[m] else self.bbp(self.rho_end[m] ** 2)
            phi[:, m] = np.clip((x - lo) / (1.0 - lo), 0.0, None) * lev
        return tg, phi


def simulate(sp, n, prm=None, st=None, return_events=False):
    race = Race(sp, n, prm or PARAMS, st or STRUCT)
    tg, phi = race.run()
    return (tg, phi, race.events) if return_events else (tg, phi)


def predict(fn, cond, prm=None, sp=None, st=None):
    """Predicted E[f | x_R] on the relevant cube: (steps [T], f [T, 2^r])."""
    sp = sp or spectrum(fn)
    n = None if cond == "online" else int(cond)
    tg, phi = simulate(sp, n, prm, st)
    return tg, (phi * sp["yhat"][None, :]) @ sp["chi"].T
