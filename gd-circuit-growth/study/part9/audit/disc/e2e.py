"""Audit (discreteness lens): end-to-end column-permutation check of the frozen hyb_portfolio2 image member.
Fits the learner on dev data (train = pool[:n], evaluation on validation pool rows pool[50000:50000+nv]; no test rows)
three times: A unpermuted, B columns permuted (same rng), C unpermuted with another rng seed (natural seed variability).
usage: e2e.py ds n members(comma list or 'all') [nv]"""
import os, sys, time, json, importlib.util, numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("v2_learner", os.path.join(STUDY, "part9", "hyb_portfolio2", "learner.py"))
LM = importlib.util.module_from_spec(spec); spec.loader.exec_module(LM)
DATA = LM.common.SH.DATA
ds, n = sys.argv[1], int(sys.argv[2]); mem = None if sys.argv[3] == "all" else set(sys.argv[3].split(","))
nv = int(sys.argv[4]) if len(sys.argv) > 4 else 2000
D = DATA.load(ds); pool, _ = DATA.splits(D, 0)
X = D["X"][pool[:n]].copy(); y = D["y"][pool[:n]].copy(); Xv = D["X"][pool[50000:50000 + nv]].copy(); yv = D["y"][pool[50000:50000 + nv]].copy()
C, types = D["C"], list(D["types"]); del D
perm = np.random.default_rng(1).permutation(X.shape[1])


def run(Xtr, Xva, s):
    L = LM.Learner(members=mem); t = time.process_time()
    f = L.fit(Xtr, y, types, C, np.random.default_rng([s, n, 4242]))
    p = np.asarray(f["predict"](Xva)); return p, f, time.process_time() - t


pA, fA, tA = run(X, Xv, 0)
pB, fB, tB = run(X[:, perm], Xv[:, perm], 0)
pC, fC, tC = run(X, Xv, 1)
out = dict(ds=ds, n=n, members=sorted(mem) if mem else "all",
           err=dict(A=float(np.mean(pA != yv)), B=float(np.mean(pB != yv)), C=float(np.mean(pC != yv))),
           agree_AB=float(np.mean(pA == pB)), agree_AC=float(np.mean(pA == pC)), cpu=[round(tA, 1), round(tB, 1), round(tC, 1)],
           flops_same=bool(fA["flops"] == fB["flops"]),
           weights=dict(A=fA["info"]["weights"], B=fB["info"]["weights"], C=fC["info"]["weights"]),
           member_oof_err=dict(A=fA["info"]["member_oof_err"], B=fB["info"]["member_oof_err"], C=fC["info"]["member_oof_err"]),
           ggbt_rounds=[f["info"].get("ggbt_rounds") for f in (fA, fB, fC)])
print(json.dumps(out, indent=1))
