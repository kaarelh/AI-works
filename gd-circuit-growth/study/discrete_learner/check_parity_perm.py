"""Parity n* of DFG v1.1 with inputs permuted per fit (harness.Permuted), at d = 30, 60, 120 on n = 16..1024.
Output: results/parity_perm.txt.  usage: python check_parity_perm.py <d>"""
import sys, json, numpy as np
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/discrete_learner")
import harness as H
from dfg import DFG
d = int(sys.argv[1]); out = {}
T, rdir, _ = H.suite_targets("designed", d)
seeds = [0, 1, 2] if d == 30 else [0, 1]
fns = [f for f in ["par2", "par3", "par4"] if H.nn_reference(f, rdir) is not None]
res = H.evaluate(H.Permuted(DFG(readout="logit")), suite="designed", fns=fns, d=d, seeds=seeds, ns=H.NS[:7], verbose=False)
for f, r in res["fns"].items():
    e = np.nanmean(np.array(r["err"]), 1); out[f] = dict(nstar=H.nstar(H.NS[:7], e), err=[round(v, 3) for v in e])
print(d, json.dumps(out))
