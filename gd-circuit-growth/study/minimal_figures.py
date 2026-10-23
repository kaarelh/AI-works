"""Figures for MINIMAL-MODEL.md from minimal_report.json and the saved evaluations.
    python3 minimal_figures.py  ->  figures/minimal_nstar.png, figures/minimal_dscale.png"""
import os, sys, json, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
R = json.load(open(os.path.join(HERE, "minimal_report.json")))
FIG = os.path.join(HERE, "figures")
cap = 2 * 16384
fns = C.FNS
nn = np.array([R["d30"][f]["nn"] for f in fns]); held = np.array([f in C.HELDOUT for f in fns])
series = [("analytic predictor", np.array([R["d30"][f]["pred"] for f in fns]), "#d62728", "s"),
          ("minimal model", np.array([R["d30"][f].get("model", np.nan) for f in fns]), "#ff7f0e", "o"),
          ("race model", np.array([R["d30"][f].get("race", np.nan) for f in fns]), "#2ca02c", "^")]
fig, ax = plt.subplots(figsize=(5, 4.6))
for lab, v, col, mk in series:
    v = np.minimum(v, cap)
    ax.scatter(nn[held], v[held], color=col, marker=mk, s=28, label=lab + " (held-out)")
    ax.scatter(nn[~held], v[~held], facecolors="none", edgecolors=col, marker=mk, s=28)
for f, x, y in zip(fns, nn, np.minimum(series[0][1], cap)):
    ax.annotate(f, (x, y), fontsize=5, alpha=0.6, xytext=(2, 2), textcoords="offset points")
ax.plot([20, cap], [20, cap], "k:", lw=0.8)
for s in (0.5, 2):
    ax.plot([20, cap], [20 * s, cap * s], color="0.8", lw=0.6)
ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlabel("n* of the network (d = 30)"); ax.set_ylabel("n* predicted / of the model")
ax.legend(fontsize=6); ax.set_title("open = calibration function; grey = factor 2", fontsize=8)
fig.tight_layout(); fig.savefig(os.path.join(FIG, "minimal_nstar.png"), dpi=130); plt.close(fig)

DS = list(R["dscale"]); ds = [15, 30, 60]
fig, axs = plt.subplots(1, len(DS), figsize=(2.1 * len(DS), 2.5), sharey=True)
for ax, f in zip(axs, DS):
    row = R["dscale"][f]
    g = lambda key: [row[str(d)].get(key) if row[str(d)].get(key) is not None else np.nan for d in ds]
    ax.loglog(ds, g("nn"), "o-", color="#1f77b4", lw=2, ms=4, label="network")
    ax.loglog(ds, g("pred"), "s--", color="#d62728", ms=3, label="predictor")
    ax.loglog(ds, g("model"), "x:", color="#ff7f0e", ms=4, label="minimal model")
    ax.loglog(ds, g("occam"), ":", color="0.5", label="Occam-law predictor")
    ax.set_title(f, fontsize=9); ax.set_xticks(ds); ax.set_xticklabels([str(d) for d in ds]); ax.minorticks_off()
axs[0].set_ylabel("n*"); axs[0].legend(fontsize=5); fig.supxlabel("input dimension d", fontsize=9)
fig.tight_layout(); fig.savefig(os.path.join(FIG, "minimal_dscale.png"), dpi=130); plt.close(fig)
# learning curves: network, minimal model, analytic predictor, race
EV = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
mres = C.load_eval(os.path.join(EV, "minimal.npz")) if os.path.exists(os.path.join(EV, "minimal.npz")) else None
rres = C.load_eval(os.path.join(EV, "race.npz"))
cols = 7; rows = int(np.ceil(len(fns) / cols))
fig, axs = plt.subplots(rows, cols, figsize=(2.6 * cols, 2.2 * rows), sharex=True, sharey=True)
for ax, f in zip(axs.ravel(), fns):
    ax.semilogx(C.NS, R["d30"][f]["nn_curve"], "o-", color="#1f77b4", ms=3, lw=2, label="network")
    ax.semilogx(C.NS, R["d30"][f]["pred_curve"], "--", color="#d62728", lw=1.2, label="analytic predictor")
    if mres is not None:
        ax.semilogx(mres["ns"], mres["test_err"][f].mean(1), "-", color="#ff7f0e", lw=1.2, label="minimal model")
    ax.semilogx(rres["ns"], rres["test_err"][f].mean(1), ":", color="#2ca02c", lw=1.0, label="race")
    ax.axhline(0.1, color="k", lw=0.4, ls=":"); ax.set_title(f + (" *" if f in C.HELDOUT else ""), fontsize=9)
for ax in axs.ravel()[len(fns):]:
    ax.axis("off")
axs.ravel()[0].legend(fontsize=6); fig.supxlabel("training-set size n  (* = held-out function)"); fig.supylabel("test error")
fig.tight_layout(); fig.savefig(os.path.join(FIG, "minimal_curves.png"), dpi=110); plt.close(fig)
print("figures written")
