"""Full learner on validation rows: train pool[:n] (seed-0 pool), score pool[50000:60000].  Dev only.
usage: run_val.py <module:Class[:json]> <ds> <n> [tag]"""
import sys, time, json, numpy as np
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/part10"); sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/part9")
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/hybrid")
import common
DATA = common.SH.DATA
spec, ds, n = sys.argv[1], sys.argv[2], int(sys.argv[3]); tag = sys.argv[4] if len(sys.argv) > 4 else spec
L = common.load_learner(spec)
D = DATA.load(ds); pool, te = DATA.splits(D, 0); tr = pool[:n]; va = pool[50000:60000]
t0 = time.process_time()
fit = L.fit(D["X"][tr], D["y"][tr], list(D["types"]), D["C"], np.random.default_rng([0, n, 4242]))
cpu = time.process_time() - t0
err = float(np.mean(np.asarray(fit["predict"](D["X"][va])) != D["y"][va]))
inf = fit.get("info", {})
print(json.dumps(dict(tag=tag, ds=ds, n=n, val_err=err, cpu=round(cpu, 1), budget_frac=round(inf.get("budget_frac", -1), 3),
                      ggbt_oof=inf.get("member_oof_err", {}).get("ggbt"), stack_oof=inf.get("stack_oof_err"),
                      w_ggbt=inf.get("weights", {}).get("ggbt"), rounds=inf.get("ggbt_rounds"),
                      t_ggbt=inf.get("times", {}).get("ggbt"))), flush=True)
