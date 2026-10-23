"""C1 numerical check: distillation certificates for the saved final Adam networks, two circuit-like classes.

For each saved network h = sign f (trained on S, |S| = n):
  1. Draw fresh *unlabelled* uniform inputs: U_infl (influence ranking), U_A (fit g), U_B (estimate disagreement).
     No labels outside S are used for the certificate.
  2. Rank coordinates by influence on h (on U_infl); keep the top R = 12.
  3. Candidates (selected using h and U_A only):
       Fourier-sign  F(k, T): g = sgn(h^(0) + sum of the T largest |h^(S)|, S nonempty, |S| <= k, S within the top R),
                     coefficients h^(S) estimated on U_A;  k = 1..4, T = 1..40.
       junta         J(r): the r most influential coordinates, truth table = majority of h per cell on U_A; r = 0..8.
  4. Theorem C1 (finite-list variant): with probability >= 1 - d1 - d2,
       err(h) <= klinv(err_S(g), (log|H_c| + log 1/pi(c) + log 1/d1)/n) + klinv(dis_B(h, g), log(K/d2)/m_B)
     simultaneously for all K candidates, with
       log|F(k,T)| <= log C(D_k, T) + log Phi(2^min(T, 30), T),  D_k = sum_{i=1..k} C(30, i)       (Prop C1.2)
       |J(r)|       = C(30, r) * 2^(2^r)  (functions on a fixed r-set; an upper bound for the r-juntas)  (Prop C1.4)
     prior pi(F, k, T) = (1/2)(1/4)/(T(T+1)),  pi(J, r) = (1/2)/9;  d1 = d2 = 0.025.
  5. Report the best certificate per network and the true error (on U_B, using the known target; reporting only).
Reads the sweep outputs read-only from $RESULTS.  Writes c1_fourier_cert.json / .txt.
"""
import os, sys, json, math, itertools, time
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
from scipy.optimize import minimize
import c_common as cc
import nn_train as nt

RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
d = 30
R_TOP, KMAX, TMAX, RJ, REFIT_TMAX = 12, 4, 40, 8, 16
M_INFL, M_A, M_B = 4000, 20000, 50000
D1 = D2 = 0.025
DK = [sum(math.comb(d, i) for i in range(1, k + 1)) for k in range(KMAX + 1)]


def fwd(p, X):
    h1 = np.maximum(X @ p["W1"].T + p["b1"], 0)
    h2 = np.maximum(h1 @ p["W2"].T + p["b2"], 0)
    return h2 @ p["a"]


def sgn(z):
    return np.where(z >= 0, 1.0, -1.0).astype(np.float32)


def char_mat(X, sets):
    C = np.ones((len(X), len(sets)), dtype=np.float32)
    for j, S in enumerate(sets):
        for i in S:
            C[:, j] *= X[:, i]
    return C


def logistic_refit(Z, h, w0, l2=1e-4):
    """weights (bias first) minimizing mean log(1 + exp(-h * (Z w))) + l2 |w|^2 on the unlabelled fit set."""
    Z1 = np.hstack([np.ones((len(Z), 1), dtype=np.float32), Z]).astype(np.float64)
    hh = h.astype(np.float64)

    def obj(w):
        m = hh * (Z1 @ w)
        lv = np.logaddexp(0, -m)
        s = -hh * 0.5 * (1 - np.tanh(m / 2))  # d/dm log(1+e^-m) = -sigmoid(-m)
        return lv.mean() + l2 * w @ w, Z1.T @ s / len(m) + 2 * l2 * w
    res = minimize(obj, w0.astype(np.float64) * 4, jac=True, method="L-BFGS-B", options=dict(maxiter=200))
    return res.x.astype(np.float32)


def ln_F(k, T):
    return cc.log_binom(DK[k], T) + cc.log_Phi(2 ** min(T, d), T)


def ln_J(r):
    return cc.log_binom(d, r) + (2 ** r) * math.log(2)


def junta_fit(hA, XA, coords):
    if not coords:
        return np.array([1.0 if hA.mean() >= 0 else -1.0])
    keys = ((XA[:, coords] > 0).astype(np.int64) * (2 ** np.arange(len(coords)))).sum(1)
    tab = np.ones(2 ** len(coords), dtype=np.float32)
    s = np.bincount(keys, weights=hA, minlength=2 ** len(coords))
    tab[s < 0] = -1.0
    return tab


def junta_eval(tab, X, coords):
    if not coords:
        return np.full(len(X), tab[0], dtype=np.float32)
    keys = ((X[:, coords] > 0).astype(np.int64) * (2 ** np.arange(len(coords)))).sum(1)
    return tab[keys]


def certify(p, X, y, rng, target_fn):
    n = len(X)
    Ui = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(M_INFL, d))
    UA = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(M_A, d))
    UB = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(M_B, d))
    hi = sgn(fwd(p, Ui))
    infl = np.zeros(d)
    for j in range(d):
        Xf = Ui.copy(); Xf[:, j] *= -1
        infl[j] = np.mean(sgn(fwd(p, Xf)) != hi)
    order = list(np.argsort(-infl))
    top = sorted(order[:R_TOP])
    hA, hB = sgn(fwd(p, UA)), sgn(fwd(p, UB))
    true_err = float(np.mean(hB != target_fn(UB)))
    # Fourier candidates
    sets = [S for k in range(1, KMAX + 1) for S in itertools.combinations(top, k)]
    CA = char_mat(UA, sets)
    coef = CA.T @ hA / M_A
    c0 = float(hA.mean())
    CB, CS = char_mat(UB, sets), char_mat(X, sets)
    cands = []
    for k in range(1, KMAX + 1):
        idx = [j for j, S in enumerate(sets) if len(S) <= k]
        idx = sorted(idx, key=lambda j: -abs(coef[j]))
        for T in range(1, min(TMAX, len(idx)) + 1):
            sel = idx[:T]
            gB = sgn(c0 + CB[:, sel] @ coef[sel])
            gS = sgn(c0 + CS[:, sel] @ coef[sel])
            cands.append(dict(fam="F", k=k, T=T, sets=[list(map(int, sets[j])) for j in sel],
                              lnH=ln_F(k, T), lnpi=math.log(0.5 * 0.25 / (T * (T + 1))),
                              errS=float(np.mean(gS != y)), dis=float(np.mean(gB != hB)), fit="fourier"))
            if k <= 2 and T <= REFIT_TMAX:
                w = logistic_refit(CA[:, sel], hA, np.concatenate([[c0], coef[sel]]))
                gB = sgn(w[0] + CB[:, sel] @ w[1:])
                gS = sgn(w[0] + CS[:, sel] @ w[1:])
                cands.append(dict(fam="F", k=k, T=T, sets=[list(map(int, sets[j])) for j in sel],
                                  lnH=ln_F(k, T), lnpi=math.log(0.5 * 0.25 / (T * (T + 1))),
                                  errS=float(np.mean(gS != y)), dis=float(np.mean(gB != hB)), fit="logistic"))
    for r in range(0, RJ + 1):
        coords = sorted(order[:r])
        tab = junta_fit(hA, UA, coords)
        cands.append(dict(fam="J", r=r, coords=list(map(int, coords)), lnH=ln_J(r), lnpi=math.log(0.5 / (RJ + 1)),
                          errS=float(np.mean(junta_eval(tab, X, coords) != y)),
                          dis=float(np.mean(junta_eval(tab, UB, coords) != hB))))
    K = len(cands)
    for c in cands:
        c["occam"] = cc.klinv_upper(c["errS"], (c["lnH"] - c["lnpi"] + math.log(1 / D1)) / n)
        c["dis_up"] = cc.klinv_upper(c["dis"], math.log(K / D2) / M_B)
        c["bound"] = c["occam"] + c["dis_up"]
    best = min(cands, key=lambda c: c["bound"])
    bestF = min([c for c in cands if c["fam"] == "F"], key=lambda c: c["bound"])
    bestJ = min([c for c in cands if c["fam"] == "J"], key=lambda c: c["bound"])
    return dict(true_err=true_err, best=best, bestF=bestF, bestJ=bestJ, K=K, top_infl=[float(v) for v in
                np.sort(infl)[::-1][:12]])


def main(fns, ns=(256, 2048, 16384)):
    rows = []
    for fn in fns:
        P = np.load(os.path.join(RESULTS, f"params_fixed_adam_{fn}.npz"))
        Rz = np.load(os.path.join(RESULTS, f"fixed_adam_{fn}.npz"))
        seeds = list(Rz["seeds"]); nmax = int(Rz["ns"].max())
        data = {s: nt.make_data(fn, int(seeds[s]), nmax) for s in range(len(seeds))}
        tfn = nt.SUITE[fn]["fn"]
        for i in range(len(Rz["net_n"])):
            n = int(Rz["net_n"][i]); s = int(Rz["net_s"][i])
            if n not in ns:
                continue
            p = {k: P[k][i].astype(np.float32) for k in ["W1", "b1", "W2", "b2", "a"]}
            X, y = data[s][0][:n], data[s][1][:n]
            rng = np.random.default_rng([nt._fn_seed(fn), s, n, 777])
            t0 = time.time()
            out = certify(p, X, y, rng, lambda Z: tfn(Z).astype(np.float32))
            b, bF, bJ = out["best"], out["bestF"], out["bestJ"]
            row = dict(fn=fn, n=n, seed=s, true_err=out["true_err"], bound=b["bound"],
                       bestF=dict((k, bF[k]) for k in ["k", "T", "sets", "lnH", "errS", "dis", "occam", "bound", "fit"]),
                       bestJ=dict((k, bJ[k]) for k in ["r", "coords", "lnH", "errS", "dis", "occam", "bound"]))
            rows.append(row)
            print(f"{fn:7s} n={n:5d} s={s} true={out['true_err']:.4f} | best={b['bound']:.3f} | "
                  f"Fourier[{bF['fit'][:3]}] k={bF['k']} T={bF['T']:2d} lnH={bF['lnH']:6.1f} errS={bF['errS']:.3f} dis={bF['dis']:.4f} "
                  f"-> {bF['bound']:.3f} | junta r={bJ['r']} lnH={bJ['lnH']:7.1f} errS={bJ['errS']:.3f} "
                  f"dis={bJ['dis']:.4f} -> {bJ['bound']:.3f}  ({time.time() - t0:.1f}s)", flush=True)
    with open(os.path.join(HERE, "c1_fourier_cert.json"), "w") as fh:
        json.dump(rows, fh, indent=1)


if __name__ == "__main__":
    fns = sys.argv[1].split(",") if len(sys.argv) > 1 else \
        ["dict", "and3", "maj3", "maj9", "thr10", "par2", "par3", "par4", "dnf3", "majpar", "mux", "parmaj", "stair5"]
    main(fns)
