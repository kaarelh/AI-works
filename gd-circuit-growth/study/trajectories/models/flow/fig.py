"""Figure: learned fraction of the target's characters, networks (solid, seed mean) against the flow model (dashed).
    python fig.py <pred_dir> <out.png>"""
import os, sys, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__)); TR = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, TR)
from score import net_reference, CONDS
from analyze_traj import subsets, chi_matrix, target_on_cube

FNS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]


def main(pred_dir, out):
    fig, axs = plt.subplots(len(FNS), 4, figsize=(17, 3.1 * len(FNS)), sharex=True)
    for i, fn in enumerate(FNS):
        for j, cond in enumerate(CONDS):
            ax = axs[i, j]; ref = net_reference(fn, cond)
            pats, R = ref["pats"], ref["R"]; subs = subsets(len(R)); C = chi_matrix(pats, subs)
            y = target_on_cube(fn, pats, R); yhat = C.T @ y / len(y)
            supp = [k for k in range(len(subs)) if abs(yhat[k]) > 1e-9 and subs[k] != ()]
            # the largest characters of every degree (at most 3 per degree, 8 in all), so that every stage is shown
            by_deg = {}
            for k in sorted(supp, key=lambda k: -abs(yhat[k])):
                by_deg.setdefault(len(subs[k]), []).append(k)
            supp = [k for dg in sorted(by_deg) for k in by_deg[dg][:3]][:8]
            pr = np.load(os.path.join(pred_dir, f"{fn}__{cond}.npz"))
            cn = ref["f"] @ C / len(y); cm = pr["f"] @ C / len(y)
            for c, k in enumerate(supp):
                col = f"C{c}"; nm = "x" + "".join(str(R[q] + 1) for q in subs[k])
                ax.plot(np.maximum(ref["steps"], 0.7), cn[:, k] / yhat[k], color=col, lw=1.3, label=f"{nm} ({yhat[k]:+.3f})")
                ax.plot(np.maximum(pr["steps"], 0.7), cm[:, k] / yhat[k], color=col, lw=1.3, ls="--")
            ax.set_xscale("log"); ax.set_ylim(-0.15, 1.3); ax.axhline(1, color="0.7", lw=0.5); ax.axhline(0, color="0.7", lw=0.5)
            if i == 0:
                ax.set_title(cond if cond == "online" else f"fixed n = {cond}")
            if j == 0:
                ax.set_ylabel(fn); ax.legend(fontsize=6, loc="upper left")
            if i == len(FNS) - 1:
                ax.set_xlabel("training step")
    fig.suptitle("learned fraction of each target character: networks (solid, mean of 3 seeds) vs flow model (dashed)")
    fig.tight_layout(); fig.savefig(out, dpi=110)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
