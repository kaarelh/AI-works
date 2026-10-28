"""The learned function of a target's block statistic, split by a second +-1 term tau (a weighted inner term or a
parity modulator), for the toy targets whose truth is not a function of one signed sum alone.  (Descriptive.)
For each (suite, target, n) the fit of eval_toy.py --perm (seed 0) is reproduced with hooks.fit_toy and the final DFG
member's value is averaged over the test inputs in each cell (t, tau), t = the true class's signed sum (signs as in
toy_structure's classes), tau = prod of x_j over the given inputs (original 0-indexed):
  rows [t, tau, count, mean target, mean DFG value]
usage: python toy_gfit.py <suite>:<target>:<n>:<tau inputs, comma-separated>[ ...] [--learner=path] [--tag=v3]
writes $INTERP_OUT/toy_g/<tag>/<suite>__<target>__n<n>.json"""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H

opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--") and "=" in a}
jobs = [a for a in sys.argv[1:] if not a.startswith("--")]
V3 = os.path.join(os.path.dirname(HERE), "hyb_portfolio3", "learner.py")
path = opt.get("learner", V3); tag = opt.get("tag", "v3"); HP = H.load_learner(path)
out_dir = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "toy_g", tag); os.makedirs(out_dir, exist_ok=True)
for job in jobs:
    su, tg, n, tau = job.split(":"); n = int(n); tau = [int(v) for v in tau.split(",")]
    T = H.targets(su)[tg]; cls = sorted(H.symmetry_classes(T["fn"], T["relevant"]), key=lambda c: -len(c["S"]))[0]
    r = H.fit_toy(HP, su, tg, n, 0); f = H.final_dfg(r, fallback=True)
    inv = np.argsort(r["pi"]); Z = r["Xte"]; val = f["value"](Z)
    sg = np.array([s if s is not None else 1 for s in cls["signs"]], float)
    t = Z[:, inv[cls["S"]]] @ sg; tv = np.prod(Z[:, inv[tau]], 1)
    rows = []
    for a in np.unique(t):
        for b in (-1.0, 1.0):
            m = (t == a) & (tv == b)
            if m.any():
                rows.append([float(a), float(b), int(m.sum()), round(float(np.mean(r["yte"][m])), 3), round(float(np.mean(val[m])), 3)])
    terms = [dict(kind=x["kind"], desc=x.get("desc"), S=x.get("S"), share=round(x["share"], 4)) for x in H.dfg_terms(r)[:8]]
    res = dict(suite=su, target=tg, n=n, seed=0, learner=path, cls=cls, tau=tau, err=r["err"],
               err_dfg=float(np.mean(np.where(val > 0, 1.0, -1.0) != r["yte"])), weights=r["info"].get("weights"),
               dfg_source="final" if f["n"] == n else f"out-of-fold fit on {f['n']} rows", terms=terms, rows=rows)
    json.dump(res, open(os.path.join(out_dir, f"{su}__{tg}__n{n}.json"), "w"), indent=1)
    print(su, tg, n, "err", round(r["err"], 4), "dfg", round(res["err_dfg"], 4), [x["desc"] or x["kind"] for x in terms[:3]], flush=True)
