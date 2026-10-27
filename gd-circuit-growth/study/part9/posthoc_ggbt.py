"""POST-HOC ablation of hyb_portfolio2's ggbt member (discreteness audit D3; run after the held-out results were read, so it
explains and is not evidence).  Question: is ggbt's gain over Part 8's tree member carried by its feature bank (pooled
subset sums, prototype pairs) or by its longer, early-stopped boosting?  ggbt alone is refitted with the frozen
fit_ggbt on the n training rows of seed 0 (the whole training set; inside v2 it sees the stacker's training part), in
four variants, and scored on the test set:
  full        the frozen bank [x, pooled sums at k = 4, 9, 16, 300 prototype-pair projections], early stopping (150-400 rounds)
  raw         x only (no pooled sums, no pairs), the same schedule
  pooled      [x, pooled sums], no pairs, the same schedule
  full_100    the frozen bank with 100 rounds (the schedule of v1's gbt member)
LightGBM runs with force_col_wise=True, which the gates builder found to leave predictions bit-identical (speed only).
usage: python posthoc_ggbt.py <dataset> [n]      writes posthoc/ggbt_<dataset>_n<n>.json"""
import os, sys, json, time, importlib.util, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "standard_tasks"))
import data as DATA
import lightgbm as lgb
sp = importlib.util.spec_from_file_location("hp2", os.path.join(HERE, "hyb_portfolio2", "learner.py"))
HP = importlib.util.module_from_spec(sp); sp.loader.exec_module(HP)
_train = lgb.train
lgb.train = lambda params, *a, **k: _train(dict(params, force_col_wise=True), *a, **k)

ds = sys.argv[1]; n = int(sys.argv[2]) if len(sys.argv) > 2 else 60000; seed = 0
D = DATA.load(ds); pool, te = DATA.splits(D, seed); tr = pool[:n]
X, y, C = D["X"][tr], D["y"][tr], D["C"]
As, _ = HP.pool_sets(X, (4, 9, 16)); Ag = np.concatenate([As[k] for k in (4, 9, 16)], 1)
empty = np.zeros((X.shape[1], 0), np.float32)
V = {"full": dict(A=Ag, n_pairs=300), "raw": dict(A=empty, n_pairs=0), "pooled": dict(A=Ag, n_pairs=0),
     "full_100": dict(A=Ag, n_pairs=300, fixed_rounds=100)}
os.makedirs(os.path.join(HERE, "posthoc"), exist_ok=True)
out_p = os.path.join(HERE, "posthoc", f"ggbt_{ds}_n{n}.json")
out = json.load(open(out_p)) if os.path.exists(out_p) else dict(dataset=ds, n=n, seed=seed, note=__doc__.split("\n")[0], variants={})
for name, kw in V.items():
    if name in out["variants"]:
        continue
    t0 = time.process_time()
    m, fl, rounds = HP.fit_ggbt(X, y, C, kw["A"], np.random.default_rng([seed, 9]), seed, n_pairs=kw["n_pairs"],
                                fixed_rounds=kw.get("fixed_rounds"))
    err = float(np.mean(np.argmax(m.proba(D["X"][te]), 1) != D["y"][te]))
    out["variants"][name] = dict(err=err, rounds=int(rounds), flops=float(fl), cpu=time.process_time() - t0,
                                 columns=int(X.shape[1] + kw["A"].shape[1] + kw["n_pairs"]))
    json.dump(out, open(out_p, "w"), indent=1)
    print(f"{ds} n={n} {name}: err={err:.4f} rounds={rounds} cpu={time.process_time() - t0:.0f}s", flush=True)
