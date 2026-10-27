"""The integration-rule numbers of PROTOCOL.md for p10_hier from the result files (dev cells, seed 0).
v2's numbers: standard_tasks/results/p9_gates-dev__{qd_dev,fashion_mnist}.json (p9_gates = v2 on images) and
hyb_portfolio2__{qd_a,qd_b}.json.  usage: python compare_dev.py [tag]"""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import common
RES = os.path.join(STUDY, "standard_tasks", "results"); CELLS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p9/cells"
tag = sys.argv[1] if len(sys.argv) > 1 else "p10_hier-dev"
V2 = {"qd_dev": "p9_gates-dev", "fashion_mnist": "p9_gates-dev", "qd_a": "hyb_portfolio2", "qd_b": "hyb_portfolio2"}
CELLS8 = [("qd_dev", 1000), ("qd_dev", 10000), ("fashion_mnist", 1000), ("fashion_mnist", 10000),
          ("qd_a", 3000), ("qd_a", 10000), ("qd_b", 3000), ("qd_b", 10000)]


def v2cell(ds, n):
    r = json.load(open(os.path.join(RES, f"{V2[ds]}__{ds}.json"))); i = r["ns"].index(n); j = r["seeds"].index(0)
    return r["err"][i][j], r["cpu_seconds"][i][j], r["flops"][i][j]


def mine(ds, n):
    f = os.path.join(CELLS, f"{tag}__{ds}", f"n{n}_s0.json")
    return json.load(open(f)) if os.path.exists(f) else None


def frac(ds, n, fl):
    d, C = 784, 10
    return fl / common.budget_real(np.zeros((n, d)), ["continuous"] * d, C, n)


rows, lr = [], []
print("| set | n | v2 err | p10_hier err | log2 ratio | v2 CPU s | p10_hier CPU s | v2 budget frac | p10_hier budget frac | ggbt oof (v2 / new) | ggbt weight |")
print("|---|---|---|---|---|---|---|---|---|---|---|")
for ds, n in CELLS8 + [("qd_a", 60000)]:
    e2, c2, f2 = v2cell(ds, n); m = mine(ds, n)
    if m is None:
        print(f"| {ds} | {n} | {e2:.4f} | (pending) | | {c2:.0f} | | {frac(ds, n, f2):.2f} | | | |"); continue
    r = np.log2(m["err"] / e2)
    if (ds, n) in CELLS8:
        lr.append(r)
    inf = m.get("info", {}); go = inf.get("member_oof_err", {}).get("ggbt"); gw = inf.get("weights", {}).get("ggbt")
    print(f"| {ds} | {n} | {e2:.4f} | {m['err']:.4f} | {r:+.3f} | {c2:.0f} | {m['cpu']:.0f} | {frac(ds, n, f2):.2f} | "
          f"{frac(ds, n, m['flops']):.2f} | – / {go} | {gw} |")
print(f"\nmean log2(err / v2 err) over the {len(lr)} small cells done: {np.mean(lr):+.4f}" if lr else "")
m = mine("qd_a", 60000)
if m:
    print(f"qd_a n=60000: err {m['err']:.4f} (v2 0.1197; limit {0.1197 * 1.05:.4f}), CPU {m['cpu']:.0f} s (v2 1757; limit "
          f"{1.5 * 1757:.0f}), budget fraction {frac('qd_a', 60000, m['flops']):.3f}")
