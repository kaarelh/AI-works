"""Part 11: DFG v1.3 alone on a standard (tabular) dataset, through the standard-task harness API.

DFG is a learner for +-1 inputs and two classes.  It runs only where every column is binary or categorical and C = 2
(of the study's 26 tabular sets: kr_vs_kp and mushroom).  Encoding = v3's DFG view: binary -> +-1, categorical ->
one-hot over the values seen in training, as +-1 (harness.encode_standard, then sign).  Labels {0, 1} -> {-1, +1}.
The fit is DFG(readout="logit").fit, unchanged (its own budget: shares of one toy-network run at this d).
usage: python dfg_real.py kr_vs_kp,mushroom
"""
import os, sys
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "discrete_learner"))
import eval_dfg                                                       # noqa: E402  (loads the frozen dfg13)
import importlib.util                                                 # noqa: E402
_sh = importlib.util.spec_from_file_location("std_harness", os.path.join(STUDY, "standard_tasks", "harness.py"))
SH = importlib.util.module_from_spec(_sh); sys.path.insert(0, os.path.join(STUDY, "standard_tasks")); _sh.loader.exec_module(SH)


class Learner:
    def __init__(self):
        self.name = "dfg13"; self.dfg = eval_dfg.load_dfg13().DFG(readout="logit")

    def fit(self, X, y, types, C, rng, budget=None):
        assert C == 2 and all(t in ("binary", "categorical") for t in types), "DFG runs on binary/categorical, C = 2"
        X = np.asarray(X); dom = [np.unique(X[:, j]) if t == "categorical" else None for j, t in enumerate(types)]
        enc = lambda A: np.where(SH.encode_standard(np.asarray(A), types, ref=X, domain=dom) > 0, 1.0, -1.0)
        yy = np.where(np.asarray(y) == 1, 1.0, -1.0)
        if yy.min() == yy.max():
            c = int(np.asarray(y)[0]); return dict(predict=lambda Z: np.full(len(Z), c), flops=0.0)
        out = self.dfg.fit(enc(X), yy, rng); pr = out["predict"]
        return dict(predict=lambda Z: (np.asarray(pr(enc(Z))) > 0).astype(np.int64), flops=out["flops"], info=out.get("info"))


if __name__ == "__main__":
    SH.evaluate(Learner(), sys.argv[1].split(","))
