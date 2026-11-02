"""Where DFG's own cross-validation chose the forced variant (atlas cells, seed 0), what would the default variant's
final fit have given on the same rows?  DFG.fit runs the chosen variant as _fit(X, y, c, force, False, ridge, hi=True,
scale=0.5) at n <= 512; this refits the OTHER variant the same way (the fit rng is not used inside _fit).  Descriptive.
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python cv_counterfactual.py     writes results/cv/forced_vs_default.json"""
import os, sys, json, glob, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import dfg_hooks as H                                                  # noqa: E402

out, Tc = [], {}
for p in sorted(glob.glob(os.path.join(HERE, "results", "atlas", "*.json"))):
    r = json.load(open(p))
    for c in r["cells"]:
        if c["cv_errs"] is None:
            continue
        suite, name, n = r["suite"], r["target"], c["n"]
        T = Tc.setdefault(suite, H.targets(suite)); fn = T[name]["fn"]
        L = H.make_learner(); D = L.inner
        X, y = H.TH.train_data(fn, name, 0, n, 30); Xte, yte = H.TH.test_data(fn, name, 30)
        pi = np.random.default_rng([H.TH.fn_seed(name), 0, n, 77]).permutation(30)
        Xp = np.asarray(X, np.float64)[:, pi]; yy = np.asarray(y, np.float64); Zte = np.asarray(Xte, np.float64)[:, pi]
        res = {}
        for force in (False, True):
            o = D._fit(Xp, yy, D.c, force, False, D.ridge, hi=True, scale=0.5)
            res["forced" if force else "default"] = dict(err=float(np.mean(o["predict"](Zte) != yte)), size=int(o["info"]["size"]))
        chosen = "forced" if c["variant"] == 1 else "default"
        assert res[chosen]["err"] == c["err"], (name, n, res, c["err"])     # the chosen variant reproduces the cell
        out.append(dict(suite=suite, target=name, n=n, chosen=chosen, cv_errs=c["cv_errs"], **{k: v for k, v in res.items()}))
        print(name, n, chosen, c["cv_errs"], res, flush=True)
json.dump(out, open(os.path.join(HERE, "results", "cv", "forced_vs_default.json"), "w"), indent=1)
