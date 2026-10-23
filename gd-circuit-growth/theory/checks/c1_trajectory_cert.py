"""C1 along training: certified circuit size and certificate at every saved checkpoint, from saved predictions only.

The study saves, at 15 checkpoints, the network's signs on 4096 test inputs that are independent of S.  Their
labels are NOT used.  Split them into U_A (first 2048: estimate Fourier coefficients of h, rank coordinates, fit
juntas) and U_B (last 2048: estimate disagreement).  Candidates as in c1_fourier_cert.py, but with all characters of
degree <= 3 on all 30 coordinates (no network access is needed):
  Fourier-sign F(k, T), k <= 3, T <= 30 (estimated coefficients as weights); juntas on the top r <= 8 coordinates,
  coordinates ranked by estimated low-degree influence sum_{S ni i, |S|<=3} h^(S)^2.
Theorem C1 (b): union over the K candidates and the 15 checkpoints in the disagreement term; Occam term as in
c1_fourier_cert.py (pi(F,k,T) = (1/2)(1/3)/(T(T+1)), pi(J,r) = (1/2)/9), d1 = d2 = 0.025.
"""
import os, sys, json, math, itertools
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import c_common as cc
import nn_train as nt

RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
d, KMAX, TMAX, RJ = 30, 3, 30, 8
D1 = D2 = 0.025
DK = [sum(math.comb(d, i) for i in range(1, k + 1)) for k in range(KMAX + 1)]
SETS = [S for k in range(1, KMAX + 1) for S in itertools.combinations(range(d), k)]


def chars(X):
    C = np.ones((len(X), len(SETS)), dtype=np.float32)
    for j, S in enumerate(SETS):
        for i in S:
            C[:, j] *= X[:, i]
    return C


def sgn(z):
    return np.where(z >= 0, 1.0, -1.0).astype(np.float32)


def junta(hA, XA, coords, X):
    if not coords:
        return np.full(len(X), 1.0 if hA.mean() >= 0 else -1.0, dtype=np.float32)
    w = 2 ** np.arange(len(coords))
    kA = ((XA[:, coords] > 0).astype(np.int64) * w).sum(1)
    tab = np.ones(2 ** len(coords), dtype=np.float32)
    tab[np.bincount(kA, weights=hA, minlength=len(tab)) < 0] = -1.0
    return tab[((X[:, coords] > 0).astype(np.int64) * w).sum(1)]


def main(fns=("dnf3", "mux", "stair5", "majpar", "maj9", "thr10", "maj3", "par3"), ns=(2048, 16384)):
    out = []
    for fn in fns:
        z = np.load(os.path.join(RESULTS, f"fixed_adam_{fn}.npz"))
        Xte, yte = nt.make_test(fn)
        XA, XB = Xte[:2048], Xte[2048:]
        CA, CB = chars(XA), chars(XB)
        for n in ns:
            j = [i for i, (n_, s_) in enumerate(zip(z["net_n"], z["net_s"])) if n_ == n and s_ == 0][0]
            X, y = nt.make_data(fn, int(z["seeds"][0]), int(z["ns"].max()))
            X, y = X[:n], y[:n]
            preds = z["pred"][:, j, :].astype(np.float32)
            preds = np.where(preds == 0, 1.0, preds)
            K = KMAX * TMAX + RJ + 1
            eps_u = math.log(K * len(z["step"]) / D2) / len(XB)
            for c_i, st in enumerate(z["step"]):
                hA, hB = preds[c_i, :2048], preds[c_i, 2048:]
                coef = CA.T @ hA / len(hA)
                c0 = float(hA.mean())
                infl = np.zeros(d)
                for jj, S in enumerate(SETS):
                    for i in S:
                        infl[i] += coef[jj] ** 2
                order = list(np.argsort(-infl))
                best = None
                tops = {}
                for k in range(1, KMAX + 1):
                    idx = [jj for jj, S in enumerate(SETS) if len(S) <= k]
                    tops[k] = sorted(idx, key=lambda jj: -abs(coef[jj]))[:TMAX]
                cols = sorted(set(jj for k in tops for jj in tops[k]))
                CSsub = np.ones((len(X), len(cols)), dtype=np.float32)
                for a, jj in enumerate(cols):
                    for i in SETS[jj]:
                        CSsub[:, a] *= X[:, i]
                pos = {jj: a for a, jj in enumerate(cols)}
                for k in range(1, KMAX + 1):
                    idx = tops[k]
                    for T in range(1, TMAX + 1):
                        sel = idx[:T]
                        selS = [pos[jj] for jj in sel]
                        gS = sgn(c0 + CSsub[:, selS] @ coef[sel]); gB = sgn(c0 + CB[:, sel] @ coef[sel])
                        lnH = cc.log_binom(DK[k], T) + cc.log_Phi(2 ** min(T, d), T)
                        lnpi = math.log(0.5 / 3 / (T * (T + 1)))
                        b = cc.klinv_upper(float(np.mean(gS != y)), (lnH - lnpi + math.log(1 / D1)) / n) + \
                            cc.klinv_upper(float(np.mean(gB != hB)), eps_u)
                        if best is None or b < best[0]:
                            best = (b, f"F({k},{T})", lnH)
                for r in range(RJ + 1):
                    coords = sorted(order[:r])
                    gS = junta(hA, XA, coords, X); gB = junta(hA, XA, coords, XB)
                    lnH = cc.log_binom(d, r) + 2 ** r * math.log(2)
                    b = cc.klinv_upper(float(np.mean(gS != y)), (lnH + math.log(18) + math.log(1 / D1)) / n) + \
                        cc.klinv_upper(float(np.mean(gB != hB)), eps_u)
                    if b < best[0]:
                        best = (b, f"J({r})", lnH)
                row = dict(fn=fn, n=n, step=int(st), test_err=float(np.mean(preds[c_i] != yte)), cert=best[0],
                           cls=best[1], lnH=best[2])
                out.append(row)
                print(f"{fn:7s} n={n:5d} step={int(st):5d} test_err={row['test_err']:.3f} cert={best[0]:.3f} "
                      f"class={best[1]:8s} lnH={best[2]:6.1f}", flush=True)
    with open(os.path.join(HERE, "c1_trajectory_cert.json"), "w") as fh:
        json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()
