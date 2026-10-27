"""Figures for the paper from experiments/results/*.json.

fig_speedup.pdf   small multiples: evaluations used vs surprise log2(1/p), ours vs Monte Carlo
fig_surprise.pdf  samples vs unexplained surprise bits (partially revealed triggers)
fig_proofs.pdf    DRUP proof size vs hidden-trigger width (linear hash vs SPN)
"""

import json
import math
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

HERE = os.path.dirname(__file__)
RES = os.path.join(HERE, "results")
OUT = os.path.join(HERE, "..", "paper", "figures")
os.makedirs(OUT, exist_ok=True)

BLUE, ORANGE, AQUA = "#2a78d6", "#eb6834", "#1baf7a"  # validated categorical slots 1-3
INK, INK2, GRID = "#0b0b0b", "#52514e", "#d9d8d4"

plt.rcParams.update({
    "font.size": 9, "axes.edgecolor": INK2, "axes.labelcolor": INK, "xtick.color": INK2,
    "ytick.color": INK2, "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.5,
    "axes.spines.top": False, "axes.spines.right": False, "legend.frameon": False,
    "lines.linewidth": 1.5, "lines.markersize": 5,
})

# families on the sampling path (the trigger and 6-variable block families of the
# table are computed exactly, with no sampling, so they have no curve here)
NAMES = {"dnf-obfuscated": "obfuscated DNF\n(envelope leaf)", "trigger-cycle20": "trigger + 20-var dense body\n(forcing + dense leaf)",
         "blocks-cycle16": "AND of 16-var dense blocks\n(dense leaves)", "threshold": "threshold of blocks\n(tilting)"}


def speedup():
    rows = json.load(open(os.path.join(RES, "speedup.json")))
    fams = [f for f in NAMES if any(r["family"] == f for r in rows)]
    fig, axes = plt.subplots(1, len(fams), figsize=(7.0, 2.5), sharey=True)
    for ax, f in zip(axes, fams):
        rs = sorted([r for r in rows if r["family"] == f], key=lambda r: r["p"], reverse=True)
        x = [math.log2(1 / r["p"]) for r in rs]
        ax.plot(x, [r["mc_cost"] for r in rs], color=INK2, ls="--", lw=1.2, label="Monte Carlo")
        ok = [r for r in rs if r["ratio"] <= 1.1 + 1e-9]
        ax.plot([math.log2(1 / r["p"]) for r in ok], [r["cost"] for r in ok], color=BLUE, marker="o",
                label="this note")
        bad = [r for r in rs if r["ratio"] > 1.1 + 1e-9]
        if bad:
            ax.plot([math.log2(1 / r["p"]) for r in bad], [r["cost"] for r in bad], ls="none", marker="x",
                    color=ORANGE, label="cap hit, not tight")
        ax.set_yscale("log")
        ax.set_title(NAMES[f], fontsize=8, color=INK)
        ax.set_xlabel("surprise $\\log_2(1/p)$")
    axes[0].set_ylabel("circuit evaluations")
    axes[0].legend(loc="upper left", fontsize=7)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT, "fig_speedup.pdf"))
    plt.close(fig)


def surprise():
    path = os.path.join(RES, "surprise.json")
    if not os.path.exists(path):
        return
    rows = sorted(json.load(open(path)), key=lambda r: r["unexplained_bits"])
    fig, ax = plt.subplots(figsize=(3.4, 2.4))
    x = [r["unexplained_bits"] for r in rows]
    ax.plot(x, [r["samples"] for r in rows], color=BLUE, marker="o", label="samples used")
    c = rows[0]["samples"]
    ax.plot(x, [c * 2 ** b for b in x], color=INK2, ls="--", lw=1.0, label="$\\propto 2^{\\sigma_u}$")
    ax.set_yscale("log")
    ax.set_xlabel("unexplained surprise $\\sigma_u$ (bits)")
    ax.set_ylabel("samples to ratio $\\le 1.2$")
    ax.legend(fontsize=7)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT, "fig_surprise.pdf"))
    plt.close(fig)


def proofs():
    path = os.path.join(RES, "arguments.json")
    if not os.path.exists(path):
        return
    rows = json.load(open(path))
    fig, ax = plt.subplots(figsize=(3.4, 2.4))
    for fam, col, lab in (("linhash", BLUE, "linear hash $[Mx_S=Ma]$"), ("spn", ORANGE, "SPN trigger")):
        rs = sorted([r for r in rows if r["family"] == fam and "proof_steps" in r], key=lambda r: r["k"])
        ax.plot([r["k"] for r in rs], [r["proof_steps"] for r in rs], color=col, marker="o", label=lab)
    ax.set_yscale("log")
    ax.set_xlabel("trigger width $k$ (bits)")
    ax.set_ylabel("DRUP proof steps")
    ax.legend(fontsize=7)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT, "fig_proofs.pdf"))
    plt.close(fig)


if __name__ == "__main__":
    speedup()
    surprise()
    proofs()
