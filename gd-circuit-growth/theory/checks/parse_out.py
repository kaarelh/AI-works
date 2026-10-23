"""Recover eval_saved.json rows from the printed lines of eval_saved.out (the first evaluation run was
stopped by its time limit before writing its JSON).  Group-wise squared displacements, needed for the KL
split, are recomputed from the saved parameters (cheap; no Monte Carlo)."""
import os, re, sys, json
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import nnbounds as nb
import nn_train as nt
import jax

RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
pat = re.compile(r"(\w+)\s+n=\s*(\d+) s=(\d+) train_err=([\d.]+) test_err=([\d.]+) \| path=\s*([\d.]+) bnd=\s*([\d.]+) "
                 r"\(gamma=([\d.]+)\) \| P_F=\s*([\d.]+) bnd=\s*([\d.]+) \| spec 24rho/n: init-ref\s+([\d.]+) zero-ref\s+([\d.]+) "
                 r"\| PB: KL=\s*([\d.]+) sig=\[([^\]]+)\] gibbs=([\d.]+) R\(Q\)<=([\d.]+) dis=([\d.]+) det<=([\d.]+)")
rows = []
for line in open(os.path.join(HERE, sys.argv[1] if len(sys.argv) > 1 else "eval_saved_part1.out")):
    m = pat.search(line)
    if not m:
        continue
    g = m.groups()
    r = dict(fn=g[0], n=int(g[1]), seed=int(g[2]), train_err=float(g[3]), test_err=float(g[4]), path=float(g[5]),
             path_bound=float(g[6]), path_gamma=float(g[7]), PF=float(g[8]), frob_bound=float(g[9]),
             spec_uncapped_init=float(g[10]), spec_uncapped_zero=float(g[11]), pb_KL=float(g[12]),
             pb_sig=[float(v) for v in g[13].split()], pb_gibbs=float(g[14]), pb_RQ=float(g[15]), pb_dis=float(g[16]),
             pb_det=float(g[17]), source="eval_saved_part1.out")
    rows.append(r)
cache = {}
for r in rows:
    if r["fn"] not in cache:
        cache[r["fn"]] = (np.load(os.path.join(RESULTS, f"params_fixed_adam_{r['fn']}.npz")),
                          np.load(os.path.join(RESULTS, f"fixed_adam_{r['fn']}.npz")))
    P, R = cache[r["fn"]]
    i = [k for k in range(len(R["net_n"])) if R["net_n"][k] == r["n"] and R["seeds"][R["net_s"][k]] == r["seed"]][0]
    p = {k: P[k][i].astype(np.float32) for k in ["W1", "b1", "W2", "b2", "a"]}
    p0 = {k: np.array(v, dtype=np.float32) for k, v in nt.init_params(jax.random.PRNGKey(1000 * r["seed"] + 7)).items()}
    r["dist2"] = [float(v) for v in nb.group_sq_dist(p, p0)]
    r["W1"] = float(np.linalg.norm(p["W1"])); r["W2"] = float(np.linalg.norm(p["W2"])); r["a"] = float(np.linalg.norm(p["a"]))
with open(os.path.join(HERE, "eval_saved.json"), "a") as f:
    for r in rows:
        f.write(json.dumps(r) + "\n")
print(len(rows), "rows recovered")
