"""figures/ablation_curves.png: test error vs n for the network and the most informative race ablations."""
import os, sys
import numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C

EVALS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
FIG = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "figures")
SHOW = [("base", "race (calibrated)", "#2ca02c", "-"), ("greedy", "greedy (no race)", "#ff7f0e", "--"),
        ("oracle-search", "noise-free search", "#9467bd", ":"), ("indep-search", "independent search sample", "#8c564b", "-."),
        ("K2", "orders <= 2", "#d62728", "--"), ("depth1", "depth 1", "#e377c2", ":")]
FNS = ["par3", "par4", "stair5", "sparsepoly", "majpar", "mux", "maj9", "rmaj9"]

fig, axs = plt.subplots(2, 4, figsize=(12, 5.4), sharex=True, sharey=True)
for ax, fn in zip(axs.ravel(), FNS):
    nn = C.nn_fixed(fn, "adam")
    ax.semilogx(nn["ns"], nn["test_err"].mean(1), "o-", color="#1f77b4", ms=3, lw=2.2, label="network (Adam)")
    for nm, lab, c, ls in SHOW:
        p = os.path.join(EVALS, f"race-abl-{nm}.npz")
        if os.path.exists(p):
            r = C.load_eval(p)
            ax.semilogx(r["ns"], np.nanmean(r["test_err"][fn], 1), ls, color=c, lw=1.3, label=lab)
    ax.axhline(0.1, color="k", lw=0.4, ls=":"); ax.set_title(fn + (" *" if fn in C.HELDOUT else ""), fontsize=9)
h, l = axs[0, 0].get_legend_handles_labels()
fig.legend(h, l, loc="lower center", ncol=len(l), fontsize=7.5, frameon=False)
fig.supxlabel("training-set size n  (* = held-out function)", y=0.06); fig.supylabel("test error")
fig.tight_layout(rect=(0, 0.07, 1, 1)); fig.savefig(os.path.join(FIG, "ablation_curves.png"), dpi=110)
print("wrote", os.path.join(FIG, "ablation_curves.png"))
