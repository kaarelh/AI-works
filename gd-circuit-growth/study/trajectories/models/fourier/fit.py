"""Calibration of the five constants of the Fourier-race model (model.PARAMS).

Objective: J = 10 * mean traj + mean onset over the 5 calibration targets x 4 conditions (the metrics of
trajectories/score.py, computed in memory against the same network references).  Nelder-Mead in log-parameters
from several starting points.  Each evaluation of all 20 (target, condition) pairs takes about 0.6 s.

    python fit.py                       # multi-start fit on all five targets
    python fit.py --loo                 # leave-one-target-out: fit on four, score the fifth
"""
import os, sys, json, time
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import numpy as np
from scipy.optimize import minimize

HERE = os.path.dirname(os.path.abspath(__file__))
TRAJ = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE); sys.path.insert(0, TRAJ); sys.path.insert(0, os.path.dirname(TRAJ))
import model as M
from score import net_reference, interp_logstep, onsets, CONDS
from analyze_traj import subsets, chi_matrix, target_on_cube

CALIB = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]
NAMES = ["TAU", "ALPHA", "K", "NBBP", "EPOCHS"]
STARTS = [dict(TAU=44, ALPHA=2.04, K=1.87, NBBP=41, EPOCHS=31.6), dict(TAU=30, ALPHA=2.5, K=2.2, NBBP=30, EPOCHS=25),
          dict(TAU=55, ALPHA=1.6, K=1.6, NBBP=55, EPOCHS=40), dict(TAU=40, ALPHA=2.2, K=2.4, NBBP=45, EPOCHS=28)]
W_TRAJ = 10.0


def load_refs(fns):
    refs = {}
    for fn in fns:
        for cond in CONDS:
            ref = net_reference(fn, cond)
            pats, R = ref["pats"], ref["R"]
            subs = subsets(len(R)); C = chi_matrix(pats, subs)
            y = target_on_cube(fn, pats, R); yhat = C.T @ y / len(y)
            supp = [j for j in range(len(subs)) if abs(yhat[j]) > 1e-9 and subs[j] != ()]
            refs[(fn, cond)] = dict(steps=ref["steps"], f=ref["f"], C=C, y=y, vy=max(np.var(y), 1e-9), yhat=yhat,
                                    supp=supp, on_n=onsets(ref["steps"], ref["f"], C, yhat, supp))
    return refs


def score_one(ref, psteps, pf):
    """traj and onset exactly as in score.py."""
    steps = ref["steps"]; m = steps >= 1
    fm = interp_logstep(psteps, pf, steps)
    traj = float(np.mean(np.sum((fm[m] - ref["f"][m]) ** 2, 1) / len(ref["y"])) / ref["vy"])
    on_m = onsets(steps, fm, ref["C"], ref["yhat"], ref["supp"])
    errs = []
    for j in ref["supp"]:
        a, b = on_m[j], ref["on_n"][j]
        if a is None and b is None:
            continue
        errs.append(1.0 if (a is None) != (b is None) else abs(np.log10(a) - np.log10(b)))
    return traj, (float(np.mean(errs)) if errs else float("nan"))


def evaluate(prm, refs, fns, sps):
    tr, on = [], []
    for fn in fns:
        for cond in CONDS:
            st, f = M.predict(fn, cond, prm, sps[fn])
            a, b = score_one(refs[(fn, cond)], st, f)
            tr.append(a); on.append(b)
    return float(np.mean(tr)), float(np.nanmean(on))


def fit(fns, refs, sps, starts=STARTS, maxfev=160, verbose=True):
    best = (1e9, None)
    for s0 in starts:
        x0 = np.log([s0[k] for k in NAMES])

        def obj(x):
            prm = dict(zip(NAMES, np.exp(x)))
            mt, mo = evaluate(prm, refs, fns, sps)
            return W_TRAJ * mt + mo
        res = minimize(obj, x0, method="Nelder-Mead", options=dict(maxfev=maxfev, xatol=0.005, fatol=1e-4,
                       initial_simplex=np.array([x0] + [x0 + 0.2 * np.eye(5)[i] for i in range(5)])))
        if verbose:
            print(f"  start {s0} -> J {res.fun:.4f}", {k: round(float(v), 3) for k, v in zip(NAMES, np.exp(res.x))}, flush=True)
        if res.fun < best[0]:
            best = (res.fun, dict(zip(NAMES, [float(v) for v in np.exp(res.x)])))
    return best


def main():
    loo = "--loo" in sys.argv
    refs = load_refs(CALIB); sps = {fn: M.spectrum(fn) for fn in CALIB}
    t0 = time.time()
    if not loo:
        J, prm = fit(CALIB, refs, sps)
        mt, mo = evaluate(prm, refs, CALIB, sps)
        print("BEST", json.dumps({k: round(v, 3) for k, v in prm.items()}), f"J {J:.4f} traj {mt:.4f} onset {mo:.4f}",
              f"time {time.time() - t0:.0f}s")
        return
    out = {}
    for held in CALIB:
        train = [f for f in CALIB if f != held]
        J, prm = fit(train, refs, sps, starts=STARTS[:2], maxfev=120, verbose=False)
        tr_h, on_h = evaluate(prm, refs, [held], sps)
        tr_f, on_f = evaluate(M.PARAMS, refs, [held], sps)
        out[held] = dict(params={k: round(v, 3) for k, v in prm.items()}, held_traj=tr_h, held_onset=on_h,
                         full_traj=tr_f, full_onset=on_f)
        print(f"held out {held:10s}: traj {tr_h:.4f} onset {on_h:.4f}  (with all-five constants: traj {tr_f:.4f} onset {on_f:.4f})",
              {k: round(v, 2) for k, v in prm.items()}, flush=True)
    json.dump(out, open(os.path.join(HERE, "loo.json"), "w"), indent=1)
    print(f"time {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main()
