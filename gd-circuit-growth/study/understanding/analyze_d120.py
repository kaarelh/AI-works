"""Score the frozen d = 120 predictions (predictions_d120.json) against the d = 120 networks.
n* = training-set size at which the seed-mean test error reaches 0.1 (log-interpolated, common.sample_complexity),
read at the protocol's 20000-step checkpoint and at 40000 steps.  Refinement runs (results_d120_refine) are merged
into the n grid when present."""
import os, sys, json
import numpy as np
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
os.environ.setdefault("DIM", "120")
import common as C
SP = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
HERE = os.path.dirname(os.path.abspath(__file__))
pred = json.load(open(f"{HERE}/predictions_d120.json"))


def load(fn, step):
    rows = {}
    for d in ("results_d120", "results_d120_refine"):
        p = f"{SP}/{d}/fixed_adam_{fn}.npz"
        if not os.path.exists(p):
            continue
        z = np.load(p); c = list(z["step"]).index(step)
        for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"])):
            rows.setdefault(int(n), {})[int(s)] = (float(z["test_err"][c, j]), float(z["train_err"][c, j]))
            hit = np.where(z["test_err"][:, j] <= 0.1)[0]
            rows[int(n)].setdefault("t", {})[int(s)] = float(z["step"][hit[0]]) if len(hit) else np.inf
    ns = np.array(sorted(rows))
    te = np.array([[rows[n][s][0] for s in (0, 1)] for n in ns])
    tg = np.array([[rows[n]["t"][s] for s in (0, 1)] for n in ns])
    return ns, te, tg


NN60 = {"par2": 427, "par3": 3410, "maj9": 625, "mux": 2848}
out = {}
print("| target | NN n* (20k steps) | NN n* (40k) | d=60 NN n* | exponent 60->120 | predictor | race (4 streams) | no-leap | Occam |")
for fn in pred["pred"]:
    r = {}
    for step in (20000, 40000):
        ns, te, tg = load(fn, step)
        r[step] = C.sample_complexity(ns, te.mean(1))
    ns, te, tg = load(fn, 20000)
    rs = [v["nstar"] for v in pred["race"][fn].values()]
    pr = pred["pred"][fn]
    ex = np.log2(r[20000] / NN60[fn])
    out[fn] = dict(nn20=r[20000], nn40=r[40000], curve=dict(zip(map(int, ns), te.mean(1).tolist())),
                   steps=dict(zip(map(int, ns), np.median(tg, 1).tolist())), pred=pr, race=rs, exp=ex)
    print(f"| {fn} | {r[20000]:.0f} | {r[40000]:.0f} | {NN60[fn]} | {ex:.2f} | {pr['search']:.0f} | "
          f"{min(rs):.0f}-{max(rs):.0f} (gm {np.exp(np.mean(np.log(rs))):.0f}) | {pr['noleap']:.0f} | {pr['occam']:.0f} |")
    print("    curve (20k):", " ".join(f"{n}:{e:.2f}" for n, e in zip(ns, te.mean(1))))
    print("    steps to gen:", " ".join(f"{n}:{t:.0f}" for n, t in zip(ns, np.median(tg, 1))))
for k in ("search", "noleap", "occam"):
    e = [abs(np.log2(pred["pred"][f][k] / out[f]["nn20"])) for f in out]
    print(f"mean |log2| error, {k}: {np.mean(e):.2f}   per target " + " ".join(f"{f}:{v:.2f}" for f, v in zip(out, e)))
e = [abs(np.log2(np.exp(np.mean(np.log(out[f]['race']))) / out[f]["nn20"])) for f in out]
print(f"mean |log2| error, race (geometric mean of streams): {np.mean(e):.2f}   " + " ".join(f"{f}:{v:.2f}" for f, v in zip(out, e)))
json.dump(out, open(f"{HERE}/d120_results.json", "w"), indent=1, default=float)
