"""Resumable learning-curve evaluation, one (n, seed) cell at a time (the session's container restarts every hour or two).
Same protocol as standard_tasks/harness.evaluate (same splits, same per-fit rng, test error, FLOPs, process CPU time); each
finished cell is saved under the scratch cell directory, so a rerun skips it.  When every cell is done the cells are
merged into standard_tasks/results/<name>__<dataset>.json in harness format.
usage: python eval_cells.py <module:Class[:kwargs]> <dataset> [--img] [--ns=...] [--seeds=...] [--tag=name]
  --img: 3 seeds for n <= 10000, seed 0 only for n >= 30000 (the Part 8 / 9 image protocol; other seeds NaN).
Fits with n >= 30000 hold a file lock, so that at most one runs at a time across processes (memory)."""
import os, sys, json, time, hashlib, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import common
SH = common.SH; DATA = SH.DATA
CELLS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p9/cells"
spec, ds = sys.argv[1], sys.argv[2]
opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[3:] if a.startswith("--") and "=" in a}
img = "--img" in sys.argv
L = common.load_learner(spec); name = opt.get("tag", L.name)
MD5 = hashlib.md5(open(sys.modules[type(L).__module__].__file__, "rb").read()).hexdigest()   # learner file, per cell
D = DATA.load(ds)
grid = [int(v) for v in opt["ns"].split(",")] if "ns" in opt else [n for n in DATA.grid(D) if n <= len(D["y"]) - D["n_test"]]
seeds = [int(v) for v in opt.get("seeds", "0,1,2").split(",")]
cdir = os.path.join(CELLS, f"{name}__{ds}"); os.makedirs(cdir, exist_ok=True)
for n in grid:
    for s in seeds:
        if img and n >= 30000 and s != 0:
            continue
        f = os.path.join(cdir, f"n{n}_s{s}.json")
        if os.path.exists(f):
            continue
        pool, te = DATA.splits(D, s); tr = pool[:n]
        lk = None
        if n >= 30000:                                   # large fits one at a time across processes (memory)
            import fcntl
            lk = open(os.path.join(CELLS, "large.lock"), "w"); fcntl.flock(lk, fcntl.LOCK_EX)
            if os.path.exists(f):
                fcntl.flock(lk, fcntl.LOCK_UN); lk.close(); continue
        t0 = time.process_time()
        fit = L.fit(D["X"][tr], D["y"][tr], list(D["types"]), D["C"], np.random.default_rng([s, n, 4242]))
        cpu = time.process_time() - t0
        err = float(np.mean(np.asarray(fit["predict"](D["X"][te])) != D["y"][te]))
        json.dump(dict(n=n, seed=s, err=err, flops=float(fit.get("flops", np.nan)), cpu=cpu, md5=MD5), open(f + ".tmp", "w"))
        os.replace(f + ".tmp", f)
        if lk is not None:
            fcntl.flock(lk, fcntl.LOCK_UN); lk.close()
        print(f"  {ds} n={n} seed={s} err={err:.4f} flops={fit.get('flops', float('nan')):.3g} cpu={cpu:.1f}s", flush=True)
err = np.full((len(grid), len(seeds)), np.nan); fl = np.full_like(err, np.nan); cpu = np.full_like(err, np.nan)
for a, n in enumerate(grid):
    for b, s in enumerate(seeds):
        f = os.path.join(cdir, f"n{n}_s{s}.json")
        if os.path.exists(f):
            c = json.load(open(f)); err[a, b], fl[a, b], cpu[a, b] = c["err"], c["flops"], c["cpu"]
r = dict(learner=name, dataset=ds, ns=grid, seeds=seeds, err=err.tolist(), flops=fl.tolist(), cpu_seconds=cpu.tolist(),
         note="eval_cells.py" + ("; n >= 30000: seed 0 only" if img else ""), learner_md5=MD5,
         cell_md5=sorted({json.load(open(os.path.join(cdir, g))).get("md5", "not recorded") for g in os.listdir(cdir) if g.endswith(".json")}))
json.dump(r, open(os.path.join(SH.RES, f"{name}__{ds}.json"), "w"))
print(ds, "merged", [round(float(np.nanmean(e)), 4) for e in err], flush=True)
