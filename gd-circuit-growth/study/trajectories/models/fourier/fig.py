"""Figure: learned fraction of each target character, network (solid, seed mean) vs Fourier-race model (dashed).

    python fig.py [out.png]       (default: fig_traj.png next to this file)
"""
import os, sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.dirname(os.path.dirname(HERE)))
import model as M
from score import net_reference, CONDS
from analyze_traj import subsets, chi_matrix, target_on_cube

FNS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]


def main(out):
    fig, axes = plt.subplots(len(FNS), 4, figsize=(18, 3.1 * len(FNS)), sharex=True)
    for a, fn in enumerate(FNS):
        sp = M.spectrum(fn)
        for b, cond in enumerate(CONDS):
            ax = axes[a, b]
            ref = net_reference(fn, cond)
            pats, R = ref["pats"], ref["R"]; subs = subsets(len(R)); C = chi_matrix(pats, subs)
            y = target_on_cube(fn, pats, R); yh = C.T @ y / len(y)
            cn = ref["f"] @ C / len(y)
            tg, f = M.predict(fn, cond, sp=sp)
            cm = f @ C / len(y)
            supp = [j for j in range(len(subs)) if abs(yh[j]) > 1e-9 and subs[j] != ()]
            supp = sorted(supp, key=lambda j: (len(subs[j]), -abs(yh[j])))
            if len(supp) > 8:            # rmaj9: one representative per (degree, |coefficient|) class
                seen, keep = set(), []
                for j in supp:
                    k = (len(subs[j]), round(abs(yh[j]), 3), len({i // 3 for i in subs[j]}))
                    if k not in seen:
                        seen.add(k); keep.append(j)
                supp = keep
            cols = plt.cm.tab10(np.linspace(0, 1, 10))
            for c, j in enumerate(supp[:10]):
                nm = "x" + "x".join(str(R[i] + 1) for i in subs[j])
                ax.plot(np.maximum(ref["steps"], 0.7), cn[:, j] / yh[j], color=cols[c % 10], lw=1.4, label=f"{nm} ({yh[j]:+.3g})")
                ax.plot(np.maximum(tg, 0.7), cm[:, j] / yh[j], color=cols[c % 10], lw=1.2, ls="--")
            ax.set_xscale("log"); ax.set_ylim(-0.15, 1.3); ax.axhline(1, color="0.7", lw=0.6)
            ax.set_xlim(0.7, 2.2e4)
            if a == 0:
                ax.set_title(f"{cond}" if cond == "online" else f"fixed n = {cond}")
            if b == 0:
                ax.set_ylabel(fn + "\nlearned fraction")
                ax.legend(fontsize=6, loc="upper left")
            if a == len(FNS) - 1:
                ax.set_xlabel("training step")
    fig.suptitle("Network (solid, mean of 3 seeds) vs Fourier-race model (dashed); learned fraction = coefficient / target coefficient", y=0.995)
    fig.tight_layout()
    fig.savefig(out, dpi=110)
    print("wrote", out)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "fig_traj.png"))
