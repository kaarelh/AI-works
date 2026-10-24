"""Figures for the learning trajectories (reads trajectories/results/<fn>_<tag>.json from analyze_traj.py).

One row per target, columns: online, n = 16384, n = 2048, n = 512.  Lines: learned fraction phi_S(t) of each of the
target's Fourier characters (seed mean; the 8 largest in |yhat| plus any character with onset), the spurious mass on
characters outside the target's support and the dependence on irrelevant coordinates (both relative to Var y, dashed),
and the sign error of E[f | x_R] (dotted).  Writes figures/trajectories.png.
"""
import os, sys, json, numpy as np
import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "results"); FIG = os.path.join(os.path.dirname(HERE), "figures")
FNS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]
TITLE = {"sparsepoly": "sign(2x1 + x2x3 + x4x5x6)", "stair5": "sign(x1 + x1x2 + ... + x1..x5)",
         "mux": "x4 ? x1x2x3 : MAJ(x1,x2,x3)", "majpar": "MAJ(x1x2, x3x4, x5x6)", "rmaj9": "MAJ(MAJ3, MAJ3, MAJ3)"}


def load(fn, tag):
    p = os.path.join(RES, f"{fn}_{tag}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def mean_over(res, prefix, key):
    arr = [np.array(v[key]) for k, v in res["nets"].items() if k.startswith(prefix + "/")]
    return np.mean(arr, 0) if arr else None


def main(fns=FNS):
    cols = [("online", "online"), ("fixed", "16384"), ("fixed", "2048"), ("fixed", "512")]
    fig, axs = plt.subplots(len(fns), 4, figsize=(17, 3.0 * len(fns)), squeeze=False)
    for i, fn in enumerate(fns):
        for j, (tag, prefix) in enumerate(cols):
            ax = axs[i, j]; res = load(fn, tag)
            if res is None:
                ax.axis("off"); continue
            steps = np.maximum(np.array(res["steps"]), 0.7)
            sup = res["support"]
            order = sorted([s for s in sup if s != "1"], key=lambda s: -abs(sup[s]))
            shown = order[:8]
            cmap = plt.get_cmap("tab10")
            for c, s in enumerate(shown):
                phis = [np.array(v["phi"][s]) for k, v in res["nets"].items() if k.startswith(prefix + "/")]
                if phis:
                    ax.semilogx(steps, np.mean(phis, 0), color=cmap(c % 10), lw=1.3, label=f"{s} ({sup[s]:+.3g})")
            vy = sum(v ** 2 for s, v in sup.items() if s != "1")
            off = mean_over(res, prefix, "off"); irr = mean_over(res, prefix, "irr"); err = mean_over(res, prefix, "err")
            if off is not None:
                ax.semilogx(steps, off / vy, "k--", lw=0.9, label="spurious relevant mass / Var y")
                ax.semilogx(steps, irr / vy, "--", color="gray", lw=0.9, label="irrelevant dependence / Var y")
                ax.semilogx(steps, err, ":", color="k", lw=1.0, label="sign error of E[f|x_R]")
            ax.set_ylim(-0.15, 1.25); ax.axhline(1, color="gray", lw=0.4); ax.axhline(0, color="gray", lw=0.4)
            if i == 0:
                ax.set_title(("online" if tag == "online" else f"fixed n = {prefix}"), fontsize=10)
            if j == 0:
                ax.set_ylabel(TITLE[fn], fontsize=9)
            if j == 3 or (j == 0 and i == 0):
                ax.legend(fontsize=5.5, loc="upper left")
    for ax in axs[-1]:
        ax.set_xlabel("training step")
    fig.tight_layout(); fig.savefig(os.path.join(FIG, "trajectories.png"), dpi=110)


if __name__ == "__main__":
    main(sys.argv[1:] or FNS)
