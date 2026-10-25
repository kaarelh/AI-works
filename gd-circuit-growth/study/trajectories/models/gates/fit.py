"""Joint fit of the five constants (ETA, BETA, M0, CW, CMEM) on the five calibration targets x four conditions.
Objective: mean traj + 0.1 * mean onset (the two scores of trajectories/score.py, onset in decades), Nelder-Mead in
log-parameters.  Also runs the ablations reported in MODEL.md (each refitted with the same procedure).

    OPENBLAS_NUM_THREADS=1 python fit.py [full|nocompose|nobundle|nokernel|nomem|plainclock|adamlaw|gf|loo_<fn>] [maxiter]
"""
import os, sys, json, time
import numpy as np
from scipy.optimize import minimize
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.dirname(os.path.dirname(HERE)))
import gates as G
import score as SC
from analyze_traj import subsets, chi_matrix, target_on_cube

FNS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]
_REF = {}


def ref(fn, cond):
    if (fn, cond) not in _REF:
        r = SC.net_reference(fn, cond)
        pats, R = r["pats"], r["R"]; C = chi_matrix(pats, subsets(len(R)))
        y = target_on_cube(fn, pats, R); yh = C.T @ y / len(y)
        supp = [j for j in range(C.shape[1]) if abs(yh[j]) > 1e-9 and j > 0]
        r.update(C=C, y=y, yh=yh, supp=supp, vy=max(np.var(y), 1e-9), on=SC.onsets(r["steps"], r["f"], C, yh, supp))
        _REF[(fn, cond)] = r
    return _REF[(fn, cond)]


def score_pred(fn, cond, st_m, f_m):
    """Same numbers as score.py's score_one, without the file round trip."""
    r = ref(fn, cond); steps = r["steps"]; m = steps >= 1
    fm = SC.interp_logstep(np.asarray(st_m, float), np.asarray(f_m, float), steps)
    traj = float(np.mean(np.sum((fm[m] - r["f"][m]) ** 2, 1) / len(r["y"])) / r["vy"])
    on_m = SC.onsets(steps, fm, r["C"], r["yh"], r["supp"])
    errs = []
    for j in r["supp"]:
        a, b = on_m[j], r["on"][j]
        if a is None and b is None:
            continue
        errs.append(1.0 if (a is None) != (b is None) else abs(np.log10(a) - np.log10(b)))
    return traj, (float(np.mean(errs)) if errs else np.nan)


def evaluate(params, mode="full", fns=None):
    res = {}
    for fn in (fns or FNS):
        pred, _, _ = G.predict(fn, params)
        for cond, (st, f) in pred.items():
            if mode == "nomem" and cond != "online":
                st, f = pred["online"]
            res[(fn, cond)] = score_pred(fn, cond, st, f)
    return res


def objective(res):
    return np.mean([v[0] for v in res.values()]) + 0.1 * np.nanmean([v[1] for v in res.values()])


def main(mode="full", maxiter=300):
    if mode == "nocompose":
        G.COMPOSE = False
    elif mode == "nobundle":
        G.BUNDLE = False
    elif mode == "nokernel":
        G.KERNEL = False
    elif mode == "adamlaw":                     # one Adam-saturated alignment law for every order (no separate T1)
        G.LAW = "adam"
        if len(sys.argv) <= 3:
            sys.argv.append("0.033,0.89,0.043,0.2,24")
    elif mode == "gf":                          # one gradient-flow alignment law for every order (no separate T1)
        G.LAW = "gf"
        if len(sys.argv) <= 3:
            sys.argv.append("0.033,0.89,0.043,0.2,24")
    elif mode == "plainclock":
        G.CLOCK = "plain"
    x0 = np.log(G.PARAMS) if len(sys.argv) <= 3 else np.log([float(v) for v in sys.argv[3].split(",")])
    fns = None
    if mode.startswith("loo_"):
        fns = [f_ for f_ in FNS if f_ != mode[4:]]
    f = lambda lp: objective(evaluate(np.exp(lp), mode, fns))
    t0 = time.time()
    r = minimize(f, x0, method="Nelder-Mead", options=dict(maxiter=maxiter, xatol=1e-3, fatol=1e-5))
    p = np.exp(r.x); res = evaluate(p, mode)          # all five targets (for loo_<fn>: <fn> is held out of the fit)
    out = dict(mode=mode, params=dict(zip(["ETA", "BETA", "M0", "CW", "CMEM"], map(float, p))), objective=float(r.fun),
               traj=float(np.mean([v[0] for v in res.values()])), onset=float(np.nanmean([v[1] for v in res.values()])),
               per_cond={c: [float(np.mean([v[0] for (f_, c_), v in res.items() if c_ == c])),
                             float(np.nanmean([v[1] for (f_, c_), v in res.items() if c_ == c]))] for c in G.CONDS},
               cells={f"{f_}|{c_}": [float(v[0]), float(v[1])] for (f_, c_), v in res.items()},
               seconds=time.time() - t0)
    print(json.dumps(out, indent=1))
    json.dump(out, open(os.path.join(HERE, f"fit_{mode}.json"), "w"), indent=1)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "full", int(sys.argv[2]) if len(sys.argv) > 2 else 300)
