"""n* on the merged (factor-2 + quarter-octave refinement) grids, at the 20000-step checkpoint, seed-mean test error,
log-interpolated as in common.sample_complexity.  Prints coarse and refined n* and the d-exponents."""
import os, sys, json
import numpy as np
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
import common as C
SP = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"


def load(fn, d, step=20000, refine=True):
    base = SP + "/results" + ("" if d == 30 else f"_d{d}")
    dirs = [base] + ([base + "_refine"] if refine else []) if d != 30 else [base] + ([SP + "/results_d30_refine"] if refine else [])
    rows = {}
    for dd in dirs:
        p = f"{dd}/fixed_adam_{fn}.npz"
        if not os.path.exists(p):
            continue
        z = np.load(p); c = list(z["step"]).index(step)
        for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"])):
            rows.setdefault(int(n), {})[int(s)] = float(z["test_err"][c, j])
    ns = np.array(sorted(rows))
    seeds = sorted(set.intersection(*[set(rows[n]) for n in ns]))
    te = np.array([[rows[n][s] for s in seeds] for n in ns])
    return ns, te, seeds


out = {}
for fn, ds in (("par3", (15, 30, 60, 120)), ("mux", (120,))):
    for d in ds:
        r = {}
        for ref in (False, True):
            ns, te, seeds = load(fn, d, refine=ref)
            r[ref] = C.sample_complexity(ns, te.mean(1))
        ns, te, seeds = load(fn, d)
        out[f"{fn}@{d}"] = dict(coarse=r[False], refined=r[True], seeds=seeds,
                                curve={int(n): float(e) for n, e in zip(ns, te.mean(1))})
        print(f"{fn} d={d}: coarse {r[False]:.0f}  refined {r[True]:.0f}  seeds {seeds}  curve "
              + " ".join(f"{n}:{e:.2f}" for n, e in zip(ns, te.mean(1)) if 0.0 < e < 0.5 or True))
p = [out[f"par3@{d}"]["refined"] for d in (15, 30, 60, 120)]
q = [out[f"par3@{d}"]["coarse"] for d in (15, 30, 60, 120)]
print("par3 refined local exponents 15-30-60-120:", " ".join(f"{np.log2(p[i+1]/p[i]):.2f}" for i in range(3)),
      "| coarse:", " ".join(f"{np.log2(q[i+1]/q[i]):.2f}" for i in range(3)))
print("par3 refined LS exponent over 15..120:", f"{np.polyfit(np.log([15,30,60,120]), np.log(p), 1)[0]:.2f}",
      "coarse:", f"{np.polyfit(np.log([15,30,60,120]), np.log(q), 1)[0]:.2f}")
json.dump(out, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refined_nstar.json"), "w"), indent=1)
