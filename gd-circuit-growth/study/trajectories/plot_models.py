"""Held-out targets: network trajectories against the three frozen models.

Rows: held-out targets. Columns: online and fixed n = 2048. Solid: the networks' learned fraction of each of the
target's 5 largest Fourier characters (seed mean); dashed: the 'fourier' model; dotted: the 'flow' model; dash-dot: the
'gates' model.  Writes figures/trajectories_heldout.png.
"""
import os, sys, numpy as np
import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from score import net_reference, interp_logstep
from analyze_traj import subsets, chi_matrix, target_on_cube

PRED = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/pred_heldout"
FNS = ["andxor", "dlist5", "parmaj", "dnf3", "rand1", "rand3"]
STY = {"fourier": "--", "flow": ":", "gates": "-."}


def main():
    fig, axs = plt.subplots(len(FNS), 2, figsize=(11, 2.5 * len(FNS)), squeeze=False)
    for i, fn in enumerate(FNS):
        for j, cond in enumerate(("online", "2048")):
            ax = axs[i, j]; ref = net_reference(fn, cond)
            pats, R = ref["pats"], ref["R"]; subs = subsets(len(R)); C = chi_matrix(pats, subs)
            y = target_on_cube(fn, pats, R); yh = C.T @ y / len(y)
            names = ["".join(f"x{R[q] + 1}" for q in T) for T in subs]
            top = [k for k in np.argsort(-np.abs(yh)) if subs[k] != () and abs(yh[k]) > 1e-9][:5]
            steps = np.maximum(ref["steps"], 0.7); cmap = plt.get_cmap("tab10")
            cn = ref["f"] @ C / len(y)
            for c, k in enumerate(top):
                ax.semilogx(steps, cn[:, k] / yh[k], color=cmap(c), lw=1.6, label=f"{names[k]} ({yh[k]:+.3g})")
                for m, ls in STY.items():
                    p = os.path.join(PRED, m, f"{fn}__{cond}.npz")
                    if os.path.exists(p):
                        z = np.load(p); fm = interp_logstep(z["steps"].astype(float), z["f"].astype(float), ref["steps"])
                        ax.semilogx(steps, (fm @ C / len(y))[:, k] / yh[k], ls, color=cmap(c), lw=1.0)
            ax.set_ylim(-0.15, 1.3); ax.axhline(1, color="gray", lw=0.4)
            if i == 0:
                ax.set_title(f"{cond if cond == 'online' else 'fixed n = 2048'} (solid: networks; dashed: fourier; dotted: flow; dash-dot: gates)", fontsize=8)
            if j == 0:
                ax.set_ylabel(fn, fontsize=9)
            ax.legend(fontsize=5.5, loc="upper left")
    for ax in axs[-1]:
        ax.set_xlabel("training step")
    fig.tight_layout(); fig.savefig(os.path.join(os.path.dirname(HERE), "figures", "trajectories_heldout.png"), dpi=110)


if __name__ == "__main__":
    main()
