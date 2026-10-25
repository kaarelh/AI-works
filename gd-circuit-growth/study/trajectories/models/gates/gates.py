"""'gates': feature-level greedy growth model of the sequence of functions a network passes through while it learns a
Boolean target.  Predicts the conditional mean E[f_t(x) | x_R] on the relevant cube at every training step, from the
target alone.  See MODEL.md for the reasoning; summary:

STATE      a set of grown gates (first-layer ReLU features), each with a support (a set of relevant inputs) and the
           bundle of target characters it carries, plus the Hebbian linear unit (the readout's linear fit, which builds
           no first-layer feature) and the output mean.  Output = least squares of the target on the grown features,
           i.e. the projection of y on the characters of the grown bundles, each weighted by its growth fraction.
MOVES      every unlearned character U of the target has an order kappa(U): the number of pieces it must be assembled
           from at once, a piece being a single input or (a subset of) the support of an existing gate; kappa >= 2 for
           any product (sharpening an existing gate still needs a new ReLU threshold), kappa = 1 for linear characters.
           Characters of equal order that share inputs form one bundle, grown by one gate (all linear characters form
           the Hebbian bundle).  Utility rho_B = correlation of the current residual with the bundle's function.
TIMING     alignment race (saddle-to-saddle): every bundle of order >= 2 has an overlap m that grows in parallel with
           all others from m0 by the homogeneous alignment law
               dm/dt = eta * rho_B * m^(kappa - 1)
           and escapes at m = 1; the Hebbian bundle (order 1) is learned by the readout on the random first-layer
           features, at Adam's capped speed, and escapes at step T1.  After each escape the residual, the orders and
           the bundles are recomputed; a character whose order drops restarts from m0.  Time is in training steps.
SHAPE      the growth fraction of an escaped bundle is a logistic in time centred on its escape step T with width cw*T.
FINITE n   memorisation drive D_n(t) (fraction of the training residual not yet memorised) from an Adam-normalised
           decay D' = -(B / (c_mem n)) D / sqrt(vhat); the features run on the effective clock tau' = D / sqrt(vhat)
           (the same Adam normalisation), and the kernel background (NNGP eigenlearning on {-1,1}^30, no constant)
           learns a fraction L_deg(n) of each unlearned character as memorisation proceeds.
CONSTANT   the output mean moves at the derived speed V0 = N * lr_a * E[h2] per step.

Five fitted constants (ETA, T1, M0, CW, CMEM), fitted jointly on the five calibration targets x four conditions
(fit.py).  Run with OPENBLAS_NUM_THREADS=1.
"""
import os, sys, itertools
from math import comb
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
sys.path.insert(0, STUDY)
from boolfuncs import make_suite

SUITE = make_suite(30)
D, B, WIDTH = 30, 64, 128

# fitted constants (fit.py, joint fit on sparsepoly, stair5, mux, majpar, rmaj9 x online, 16384, 2048, 512)
ETA, T1, M0, CW, CMEM = 0.0198, 56.5, 0.0692, 0.198, 24.6
PARAMS = (ETA, T1, M0, CW, CMEM)

# derived (not fitted): speed of the output mean under Adam.  Every readout weight a_k moves by lr_a = 5e-4 per step
# in the direction of sign(E[r h2_k]) = sign(mean residual), so the mean output moves by N * lr_a * E[h2] per step;
# at initialisation E[h2] = E relu(N(0, 1/2)) = 0.282.
V0 = WIDTH * 5e-4 * 0.282

# structural switches (ablations only; the model is the default setting)
RESET = True          # a character whose order drops (a new gate offers a cheaper route) restarts alignment from M0
KERNEL = True         # kernel background at finite n
COMPOSE = True        # orders from composition with existing gates; False = order is the character's degree
BUNDLE = True         # characters of equal order sharing inputs grow together; False = every character on its own
CLOCK = "adam"        # finite-n feature clock: tau' = D / sqrt(vhat) ('adam') or tau' = D ('plain')
LAW = "hebb"          # the model: 'hebb' = drift eta*rho*m^(k-1) for orders >= 2, Hebbian bundle escapes at step T1
                      #   (the second parameter).  Older variants kept for the record: 'adam' = drift
                      #   eta*S(beta*rho*m^(k-1)), S(s) = s/sqrt(1+s^2), for every order; 'gf' = the same with S(s) = s
                      #   (second parameter = beta).

CONDS = ("online", "16384", "2048", "512")


# ---------------------------------------------------------------- target on its relevant cube

def target_cube(fn):
    R = SUITE[fn]["relevant"]; r = len(R)
    pats = np.array(list(itertools.product([-1.0, 1.0], repeat=r)))        # same order as run_traj.py
    X = np.ones((len(pats), D)); X[:, R] = pats
    y = SUITE[fn]["fn"](X).astype(np.float64)
    subs = [T for k in range(r + 1) for T in itertools.combinations(range(r), k)]
    C = np.stack([np.prod(pats[:, list(T)], axis=1) if T else np.ones(len(pats)) for T in subs], 1)
    yh = C.T @ y / len(y)
    return dict(R=R, r=r, pats=pats, y=y, subs=subs, C=C, yh=yh)


# ---------------------------------------------------------------- composition order

def _popcount(m):
    return bin(m).count("1")


def _cover(U, gates):
    """Minimal number of pieces covering U, a piece being a single input or a subset of one gate's support."""
    best = _popcount(U)
    G = list({g & U for g in gates if _popcount(g & U) >= 2})
    for k in range(1, min(len(G), best) + 1):
        if k >= best:
            break
        for comb_ in itertools.combinations(G, k):
            cov = 0
            for g in comb_:
                cov |= g
            parts = k + _popcount(U & ~cov)
            if parts < best:
                best = parts
    return best


def kappa(U, gates):
    n = _popcount(U)
    if n <= 1:
        return n
    if not COMPOSE:
        return n
    return max(2, _cover(U, gates))


# ---------------------------------------------------------------- Adam-normalised alignment law

_UG = np.logspace(-8, 0, 800)
_LUG = np.log(_UG)


def _cumI(a, k):
    """J(u) = int_u^1 sqrt(1 + (a v^k)^2) / (a v^k) dv on the grid _UG: eta x (time to align from overlap u)."""
    v = _UG
    h = (np.sqrt(1.0 + (a * v ** k) ** 2) if LAW == "adam" else 1.0) / (a * v ** k)
    seg = 0.5 * (h[1:] * v[1:] + h[:-1] * v[:-1]) * np.diff(_LUG)
    return np.concatenate([np.cumsum(seg[::-1])[::-1], [0.0]])


def _time_to(m, a, k):
    return float(np.interp(np.log(m), _LUG, _cumI(a, k)))


def _advance(m, a, k, s):
    """overlap reached from m after alignment work s = eta * dt."""
    J = _cumI(a, k)
    Jt = float(np.interp(np.log(m), _LUG, J)) - s
    if Jt <= 0:
        return 1.0
    return float(np.exp(np.interp(-Jt, -J, _LUG)))


# ---------------------------------------------------------------- the race

def _bundles(rem, kap):
    out = []
    lin = [m for m in rem if kap[m] == 1]
    if lin:
        out += [(1, lin)] if BUNDLE else [(1, [m]) for m in lin]
    for k in sorted(set(kap.values()) - {1}):
        ms = [m for m in rem if kap[m] == k]
        if not BUNDLE:
            out += [(k, [m]) for m in ms]
            continue
        seen = set()
        for m in ms:
            if m in seen:
                continue
            comp, stack = [], [m]
            seen.add(m)
            while stack:
                u = stack.pop(); comp.append(u)
                for v in ms:
                    if v not in seen and (v & u):
                        seen.add(v); stack.append(v)
            out.append((k, comp))
    return out


def skeleton(T, eta=ETA, beta=T1, m0=M0, tol=1e-9, max_events=400):
    """Event-driven alignment race over the target's characters.  Returns the escape events
    (t_escape, t_available, kappa, [character indices]) in model time = training steps (online)."""
    subs, yh = T["subs"], T["yh"]
    masks = [sum(1 << i for i in S) for S in subs]
    idx = {m: j for j, m in enumerate(masks)}
    act = [m for j, m in enumerate(masks) if m and abs(yh[j]) > tol]
    mo = {m: m0 for m in act}
    kap_prev = {m: None for m in act}
    t_av = {m: 0.0 for m in act}
    learned, gates, events = set(), [], []
    t = 0.0
    while len(learned) < len(act) and len(events) < max_events:
        rem = [m for m in act if m not in learned]
        kap = {m: kappa(m, gates) for m in rem}
        for m in rem:
            if kap_prev[m] is not None and kap[m] < kap_prev[m]:
                t_av[m] = t
                if RESET:
                    mo[m] = m0
            kap_prev[m] = kap[m]
        r2 = sum(yh[idx[m]] ** 2 for m in rem)
        cand = []
        for k, comp in _bundles(rem, kap):
            rho = np.sqrt(sum(yh[idx[m]] ** 2 for m in comp) / r2)
            mm = max(mo[m] for m in comp)
            if LAW == "hebb":
                if k == 1:
                    cand.append(((1.0 - mm) * beta / (1.0 - m0), k, comp, None, mm))
                else:
                    cand.append((_time_to(mm, rho, k - 1) / eta, k, comp, rho, mm))
            else:
                a = beta * rho
                cand.append((_time_to(mm, a, k - 1) / eta, k, comp, a, mm))
        dt, k, comp, a, mm = min(cand, key=lambda z: z[0])
        dt = max(dt, 0.0)
        t += dt
        for _, kc, cc, ac, mc in cand:
            if ac is None:
                m2 = min(1.0, mc + (1.0 - m0) * dt / beta)
            else:
                m2 = _advance(mc, ac, kc - 1, eta * dt)
            for m in cc:
                mo[m] = m2
        learned |= set(comp)
        events.append((t, max(t_av[m] for m in comp), k, [idx[m] for m in comp]))
        if k >= 2:
            sup = 0
            for m in comp:
                sup |= m
            gates.append(sup)
    return events


# ---------------------------------------------------------------- finite training sets

def mem_drive(n, c_mem=CMEM, T=20000, b2=0.999):
    """D_n(t), t = 0..T: fraction of the training residual not yet memorised, and the Adam-normalised drive
    A_n(t) = D_n / sqrt(vhat) that both memorisation and feature growth receive.  vhat = bias-corrected EMA_{b2} of D^2
    (Adam's own second-moment average): when every gradient shrinks by D, Adam's step shrinks by D / sqrt(vhat).
    Memorisation: D' = -(B / (c_mem n)) A.  n = None (online): D = A = 1."""
    if n is None:
        return np.ones(T + 1), np.ones(T + 1)
    k = B / (c_mem * n)
    Dn = np.ones(T + 1); A = np.ones(T + 1); e = 0.0
    for t in range(1, T + 1):
        e = b2 * e + (1 - b2) * Dn[t - 1] ** 2
        inv = 1.0 / np.sqrt(e / (1 - b2 ** t))
        A[t - 1] = Dn[t - 1] * inv
        Dn[t] = Dn[t - 1] * np.exp(-k * inv)
    A[T] = A[T - 1]
    return Dn, A


_LK = {}


def kernel_learnability(n, d=D, L=2):
    """Eigenlearning learnability L_j(n) = lam_j / (lam_j + kappa_n) of degree-j characters for ridgeless regression on
    n samples with the NNGP kernel of the L-hidden-layer ReLU network on {-1,1}^d; kappa_n solves
    n = sum_j C(d, j) lam_j / (lam_j + kappa_n).  No fitted constant."""
    if (n, d) in _LK:
        return _LK[(n, d)]
    from scipy.optimize import brentq

    def arccos1(c):
        c = np.clip(c, -1, 1)
        return (np.sqrt(1 - c * c) + (np.pi - np.arccos(c)) * c) / (2 * np.pi)
    ms = np.arange(d + 1); kv = (d - 2 * ms) / d
    for _ in range(L):
        kv = arccos1(kv) / arccos1(1.0)
    pm = np.array([comb(d, m) for m in ms], float) / 2.0 ** d

    def kraw(j, m):
        return sum((-1) ** i * comb(m, i) * comb(d - m, j - i) for i in range(j + 1))
    lam = np.array([sum(pm[m] * kv[m] * kraw(j, m) for m in ms) / comb(d, j) for j in range(d + 1)])
    lam = np.maximum(lam, 1e-30)
    mult = np.array([comb(d, j) for j in range(d + 1)], float)
    ka = brentq(lambda x: np.sum(mult * lam / (lam + x)) - n, 1e-30, 1e6)
    _LK[(n, d)] = lam / (lam + ka)
    return _LK[(n, d)]


# ---------------------------------------------------------------- the function at every step

def trajectory(T, events, steps, n=None, cw=CW, c_mem=CMEM):
    """Predicted E[f_t | x_R] on the cube [len(steps), 2^r] for training-set size n (None = online)."""
    y, C, yh, subs = T["y"], T["C"], T["yh"], T["subs"]
    Dn, An = mem_drive(n, c_mem)
    drive = An if CLOCK == "adam" else Dn
    tau_full = np.concatenate([[0.0], np.cumsum(0.5 * (drive[1:] + drive[:-1]))])
    st = np.asarray(steps, float)
    tau = np.interp(st, np.arange(len(Dn)), tau_full)
    Dt = np.interp(st, np.arange(len(Dn)), Dn)
    frac = np.zeros((len(st), len(yh)))                    # growth fraction of every character
    for tf, ta, k, js in events:
        frac[:, js] = (1.0 / (1.0 + np.exp(-np.clip((tau - tf) / (cw * tf), -50, 50))))[:, None]
    if n is not None and KERNEL:
        deg = np.array([len(S) for S in subs])
        kern = kernel_learnability(n)[deg][None, :] * (1.0 - frac) * (1.0 - Dt)[:, None]
        kern[:, 0] = 0.0
        frac = frac + kern
    frac[:, 0] = np.minimum(1.0, V0 * st / max(abs(yh[0]), 1e-12))   # output mean
    return (frac * yh[None, :]) @ C.T


def steps_grid():
    return np.unique(np.round(np.logspace(0, np.log10(20000), 300)))


def predict(fn, params=PARAMS, conds=CONDS):
    eta, beta, m0, cw, c_mem = params
    T = target_cube(fn)
    ev = skeleton(T, eta, beta, m0)
    st = steps_grid()
    out = {cond: (st, trajectory(T, ev, st, n=None if cond == "online" else int(cond), cw=cw, c_mem=c_mem))
           for cond in conds}
    return out, ev, T
