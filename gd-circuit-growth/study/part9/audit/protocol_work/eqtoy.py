import sys, os, importlib.util, numpy as np
sys.dont_write_bytecode = True
ST = "/home/user/AI-works/gd-circuit-growth/study"
sys.path.insert(0, os.path.join(ST, "part9")); sys.path.insert(0, os.path.join(ST, "hybrid"))
import common
sp = importlib.util.spec_from_file_location("th", os.path.join(ST, "discrete_learner", "harness.py")); TH = importlib.util.module_from_spec(sp); sp.loader.exec_module(TH)
import boolfuncs
from hyb_portfolio2.learner import Learner as V2
from p9_sum.learner import Learner as PS
S = boolfuncs.make_dl_symdev_suite(30)
for fn, n in (("symxpar", 256), ("thrsum", 128)):
    t = S[fn]; rng = np.random.default_rng(123); X = rng.choice([-1.0, 1.0], size=(n, 30)); y = t["fn"](X)
    Xq = np.random.default_rng(7).choice([-1.0, 1.0], size=(2000, 30))
    P = []
    for L in (V2, PS):
        f = TH.Permuted(common.ToyAdapter(L())).fit(X, y, np.random.default_rng([5, n]))
        P.append((np.asarray(f["predict"](Xq)), f["flops"]))
    print(fn, n, "identical predictions", bool(np.all(P[0][0] == P[1][0])), "identical flops", P[0][1] == P[1][1], "err", float(np.mean(P[0][0] != t["fn"](Xq))), flush=True)
