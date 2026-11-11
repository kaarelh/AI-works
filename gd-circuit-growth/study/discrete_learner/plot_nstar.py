"""Figure: DFG's n* against the networks' n*, every target of every suite (log-log).  Writes figures/dfg_nstar.png.

Series (colour and marker): blind held-out runs (held-out 2 with v1.1, held-out 1 with frozen v1 without the degree-5/6
search); development suites at d = 30 (designed, random; frozen v1); other input dimensions (d = 15 v1, d = 60 and 120
v1.1).  A target DFG never learns is drawn at the top edge.  Dashed: equal data; dotted: 3x and 10x less data.
"""
import os, json, numpy as np
import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
import harness as H

HERE = os.path.dirname(os.path.abspath(__file__)); RES = os.path.join(HERE, "results")
FIG = os.path.join(os.path.dirname(HERE), "figures", "dfg_nstar.png")
SERIES = [
    ("blind held-out", "#2a78d6", "o", ["dfg-v1.1-perm__dlheld2", "dfg-c1.0-Khi4__dlheld"]),
    ("development, d = 30", "#eb6834", "s", ["dfg-c1.0__designed", "dfg-c1.0__random"]),
    ("d = 15, 60, 120", "#1baf7a", "^", ["dfg-c1.0__designed_d15", "dfg-v1.1__designed_d60", "dfg-v1.1__designed_d120"]),
]
TOP = 3e4


def points(key):
    r = json.load(open(os.path.join(RES, key + ".json"))); out = []
    for f, v in r["fns"].items():
        ln = H.nstar(r["ns"], np.nanmean(np.array(v["err"]), 1))
        nn = H.nstar(H.NS, np.nanmean(np.array(v["nn_err"]), 1))
        if np.isfinite(nn):
            out.append((nn, ln if np.isfinite(ln) else TOP, f, not np.isfinite(ln)))
    return out


def main():
    fig, ax = plt.subplots(figsize=(6.2, 5.6))
    ax.set_facecolor("#fcfcfb"); fig.patch.set_facecolor("#fcfcfb")
    g = np.array([10, 1e5])
    ax.plot(g, g, "--", color="#52514e", lw=1.0, label="equal data")
    for fac in (3, 10):
        ax.plot(g, g / fac, ":", color="#9a9893", lw=0.9)
        ax.text(6e4, 6e4 / fac * 1.12, f"{fac}x less", fontsize=7, color="#52514e", ha="right")
    for name, col, mk, keys in SERIES:
        P = [p for k in keys if os.path.exists(os.path.join(RES, k + ".json")) for p in points(k)]
        x = [p[0] for p in P]; y = [p[1] for p in P]
        ax.scatter(x, y, s=34, marker=mk, color=col, edgecolor="#fcfcfb", linewidth=1.0, label=f"{name} ({len(P)} targets)", zorder=3)
        for p in P:
            if p[3]:
                ax.annotate(f"{p[2]}: DFG never", (p[0], p[1]), xytext=(4, -10), textcoords="offset points", fontsize=7, color="#0b0b0b")
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(30, 6e4); ax.set_ylim(10, 5e4)
    ax.set_xlabel("networks' n* (samples to reach test error 0.1)", fontsize=9)
    ax.set_ylabel("DFG's n*", fontsize=9)
    ax.set_title("DFG against gradient descent: data needed, every target", fontsize=10, color="#0b0b0b")
    ax.grid(True, which="major", color="#e6e5e1", lw=0.6); ax.tick_params(labelsize=8, colors="#52514e")
    for s in ax.spines.values():
        s.set_color("#c8c7c2")
    ax.legend(fontsize=7.5, loc="upper left", frameon=False)
    fig.tight_layout(); fig.savefig(FIG, dpi=130)
    print(FIG)


if __name__ == "__main__":
    main()
