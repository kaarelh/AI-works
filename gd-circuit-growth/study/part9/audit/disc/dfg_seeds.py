"""Audit: DFG v1.2 alone on dev symmetric targets (dlsymdev), inputs permuted, seed 0: frozen default vs no eigenvector
seeds in the sum-block search (sum_seeds=(0, 3, 2)); and how many v1.1 spectral (u.x)^2 features end up in the model.
usage: dfg_seeds.py n target,target,..."""
import os, sys, importlib.util, numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.dont_write_bytecode = True
sys.path.insert(0, STUDY); sys.path.insert(0, os.path.join(STUDY, "discrete_learner"))
import harness as TH, boolfuncs as BF
spec = importlib.util.spec_from_file_location("dfg12", os.path.join(STUDY, "part9", "p9_sum", "dfg12.py"))
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
n = int(sys.argv[1]); tg = sys.argv[2].split(","); S = BF.make_dl_symdev_suite(30)
for name in tg:
    fn = S[name]["fn"]; X, y = TH.train_data(fn, name, 0, n, 30); Xt, yt = TH.test_data(fn, name, 30)
    row = []
    for lab, kw in (("default", {}), ("no-eig", dict(sum_seeds=(0, 3, 2))), ("no-sums", dict(sums=False))):
        rng = np.random.default_rng([TH.fn_seed(name), 0, n, 77]); pi = rng.permutation(30)
        out = M.DFG(readout="logit", **kw).fit(X[:, pi].astype(np.float64), y.astype(np.float64), rng)
        e = float(np.mean(out["predict"](Xt[:, pi]) != yt))
        log = out["info"].get("log", []); nq = sum(b == "quad" for r in log for b in r.get("blocks", []))
        nb = len(out["info"].get("blocks", []))
        row.append(f"{lab}: err {e:.3f}, sum blocks {nb}, quad-block acceptances {nq}")
    print(f"{name} n={n}: " + " | ".join(row), flush=True)
