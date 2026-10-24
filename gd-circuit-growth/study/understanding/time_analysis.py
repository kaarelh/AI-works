"""What sets the networks' time to generalise?  Between-target comparison at large n (d = 30).

Network time: steps to test error <= 0.1 (first checkpoint), median over seeds and over n in {4096, 8192, 16384}.
Candidate predictors, all from the target alone (the analytic predictor's population greedy path at n = 16384, d = 30,
c = 2.25, a = 18), for the prefix i* of the path that first reaches population error <= 0.1:
  stages      i*
  sum_inv_rho sum_i 1/rho_i             (stagewise saddle-to-saddle time, utility ~ rho)
  max_inv_rho max_i 1/rho_i
  sum_inv_rho2 sum_i 1/rho_i^2
  leap_time   sum_i (d/a)^((k_i-2)+/2) / rho_i   (alignment-law time m0^-(k-2)/U with m0^2 = a/d)
  min_k       max_i k_i (largest leap on the path)
Also: race clock (median over the same cells), race gate count at fit, and the minimal model's derived clock.
"""
import os, sys, json
import numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.path.insert(0, STUDY)
import common as C
import minimal_predict as P

EV = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
race = C.load_eval(f"{EV}/race.npz"); mini = C.load_eval(f"{EV}/minimal.npz")
NBIG = [4096, 8192, 16384]
rows = {}
for fn in C.FNS:
    nn = C.nn_fixed(fn)
    idx = [list(nn["ns"]).index(n) for n in NBIG]
    t_nn = np.median(nn["steps_to_gen"][idx])
    ridx = [list(race["ns"]).index(n) for n in NBIG]
    rt = np.where(race["test_err"][fn][ridx] <= 0.1, race["time"][fn][ridx], np.nan)
    mt = np.where(mini["test_err"][fn][ridx] <= 0.1, mini["time"][fn][ridx], np.nan)
    Xr, y, rel = P.relevant_cube(fn, 30)
    run = P.population_run(Xr, y, 16384, 2.25, 18.0, 30)
    st = run["stages"]
    # i*: shortest prefix with population (noise-free) error <= 0.1
    istar = len(st)
    for i, s in enumerate(st):
        if s["err"] <= 0.1:
            istar = i + 1; break
    if istar == 0 or not st:
        istar = 0
    used = st[:istar]
    rho = np.array([np.sqrt(s["rho2"]) for s in used]) if used else np.array([])
    ks = np.array([s["k"] for s in used]) if used else np.array([0])
    # dense targets: the Hebbian unit alone may already reach error <= 0.1 (no stage needed); its "utility" is the
    # correlation of the Hebbian feature with y
    hcorr = np.sqrt(run["hnorm2"] / run["vy"]) if run["vy"] > 0 else 0.0
    if len(rho) == 0:
        rho = np.array([hcorr]) if hcorr > 0 else np.array([1.0])
    rows[fn] = dict(t_nn=float(t_nn), t_race=float(np.nanmedian(rt)), t_min=float(np.nanmedian(mt)),
                    gates_race=float(np.nanmedian(race["size"][fn][ridx])),
                    stages=int(istar), sum_inv_rho=float(np.sum(1 / rho)), max_inv_rho=float(np.max(1 / rho)),
                    sum_inv_rho2=float(np.sum(1 / rho ** 2)),
                    leap_time=float(np.sum((30 / 18.0) ** (np.maximum(ks[:len(rho)] - 2, 0) / 2) / rho)),
                    max_k=int(ks.max()), path=[(s["k"], round(s["rho2"], 3), round(s["err"], 3)) for s in used])
sp = C._spearman
keys = ["t_race", "t_min", "gates_race", "stages", "sum_inv_rho", "max_inv_rho", "sum_inv_rho2", "leap_time", "max_k"]
t = np.array([rows[f]["t_nn"] for f in C.FNS])
print("between-target Spearman with the networks' median steps to generalise (n >= 4096), 21 targets / HELDOUT 9:")
res = {}
for k in keys:
    v = np.array([rows[f][k] for f in C.FNS]); h = [C.FNS.index(f) for f in C.HELDOUT]
    ok = np.isfinite(v)
    res[k] = (sp(t[ok], v[ok]), sp(t[h], v[h]))
    print(f"  {k:12s} {res[k][0]:.2f}  {res[k][1]:.2f}")
print()
print("| fn | NN steps | race clock | stages | sum 1/rho | max k | path (k, rho2, err) |")
for f in sorted(C.FNS, key=lambda f: rows[f]["t_nn"]):
    r = rows[f]
    print(f"| {f} | {r['t_nn']:.0f} | {r['t_race']:.1f} | {r['stages']} | {r['sum_inv_rho']:.1f} | {r['max_k']} | {r['path']} |")
json.dump(dict(rows=rows, spearman=res), open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "time_analysis.json"), "w"), indent=1)
