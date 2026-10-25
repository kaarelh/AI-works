"""figure.png: model (dashed) vs networks (solid, seed mean) learned fraction of the largest target characters, for the
five calibration targets x four conditions.  python figure.py"""
import os, sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gates as G
import fit as F


def main(out=os.path.join(HERE, "figure.png")):
    fig, ax = plt.subplots(5, 4, figsize=(18, 19), sharex=True)
    for i, fn in enumerate(F.FNS):
        pred, ev, T = G.predict(fn)
        for j, cond in enumerate(G.CONDS):
            r = F.ref(fn, cond); C, yh, supp = r["C"], r["yh"], r["supp"]
            st, f = pred[cond]
            cm = f @ C / len(r["y"]); cn = r["f"] @ C / len(r["y"])
            # one curve per distinct (coefficient, escape event): largest coefficients first, at most 8
            order = sorted(supp, key=lambda q: -abs(yh[q]))
            seen, keep = set(), []
            evmap = {q: e for e, (_, _, _, js) in enumerate(ev) for q in js}
            for q in order:
                key = (round(yh[q], 4), evmap.get(q))
                if key not in seen:
                    seen.add(key); keep.append(q)
            for k, q in enumerate(keep[:8]):
                name = "x" + "".join(str(T["R"][a] + 1) for a in T["subs"][q])
                ax[i, j].plot(r["steps"], cn[:, q] / yh[q], color=f"C{k}", lw=1.3, label=f"{name} ({yh[q]:+.3g})")
                ax[i, j].plot(st, cm[:, q] / yh[q], color=f"C{k}", lw=1.3, ls="--")
            ax[i, j].set_xscale("log"); ax[i, j].set_ylim(-0.1, 1.4); ax[i, j].axhline(1, color="0.8", lw=0.5)
            ax[i, j].set_title(f"{fn}, {cond}", fontsize=10)
            if j == 0:
                ax[i, j].legend(fontsize=7, loc="upper left")
    for j in range(4):
        ax[-1, j].set_xlabel("training step")
    fig.suptitle("gates model (dashed) vs networks (solid): learned fraction of target characters", y=0.995)
    plt.tight_layout(); plt.savefig(out, dpi=70)


if __name__ == "__main__":
    main()
