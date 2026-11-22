"""Figures for the paper verified-slack-imitation.tex, from the saved experiment outputs.

Usage (from monitored-imitation/paper/):  python3 make_paper_figures.py
Reads ../results/slack_imitation_{same,summary,verifier}.json and
../verification/referee8_e7_default.out (E7's VSI column under the default schedule).
Writes fig_e6.pdf.
"""
import json
import os
import re

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")
VER = os.path.join(HERE, "..", "verification")


def load(name):
    with open(os.path.join(RES, name)) as f:
        return json.load(f)


def sush_column():
    """Parse the SUSH column (default schedule S,U,S,H, the protocol's list, no post-mortems)."""
    out = {}
    with open(os.path.join(VER, "referee8_e7_default.out")) as f:
        for line in f:
            m = re.match(r"\| (M\d'?) \| (\d+) \| [^|]+\| [^|]+\| ([\d,\.]+) ±", line)
            if m:
                out[(m.group(1), int(m.group(2)))] = float(m.group(3).replace(",", ""))
    return out


def main():
    same = load("slack_imitation_same.json")
    summ = load("slack_imitation_summary.json")
    ver = load("slack_imitation_verifier.json")
    sush = sush_column()
    n0s = [8, 32, 128]
    ns = [16, 64, 256]

    fig, axes = plt.subplots(1, 2, figsize=(9.6, 4.6))
    ax = axes[0]
    ax.plot(n0s, [same[f"noticing_n{n}_same_CI_n0"]["task_mean"] for n in ns], "k-o",
            label="chained imitation (bounded-setback human)")
    styles = {"noticing": ("C0", "-", "s", "slack imitation, bounded setback (D=0)"),
              "fooled": ("C1", "--", "^", "slack imitation, fooled human"),
              "silent": ("C3", ":", "v", "slack imitation, silent human")}
    for kind, (c, ls, mk, lab) in styles.items():
        ax.plot(n0s, [summ[f"{kind}_n{n}_sigma{n // 2}_CI"]["task_mean"] for n in ns],
                color=c, ls=ls, marker=mk, label=lab)
    ax.set_xscale("log", base=2)
    ax.set_yscale("log")
    ax.set_xticks(n0s, [str(v) for v in n0s])
    ax.set_xlabel(r"human's horizon $n_0$ (steps)")
    ax.set_ylabel("task queries until $\\leq$2% of runs fail")
    ax.set_title("(a) without a verifier (E6)", fontsize=10)
    ax.legend(fontsize=7, loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=2, frameon=False)
    ax.grid(alpha=0.3, which="both")

    ax = axes[1]
    for kind, mech, c in [("noticing", "M1", "C0"), ("fooled", "M2", "C1"), ("silent", "M3", "C3")]:
        ax.plot(n0s, [ver[f"{kind}_n{n}_sigma{n // 2}_SIV"]["task_mean"] for n in ns],
                color=c, ls="--", marker="o", mfc="none", label=f"{kind}: uniform search (SI-V)")
        ax.plot(n0s, [sush[(mech, n0)] for n0 in n0s], color=c, ls="-", marker="o",
                label=f"{kind}: VSI search (S,U,S,H)")
    ax.set_xscale("log", base=2)
    ax.set_yscale("log")
    ax.set_xticks(n0s, [str(v) for v in n0s])
    ax.set_xlabel(r"human's horizon $n_0$ (steps)")
    ax.set_ylabel("total task queries, 100 problems")
    ax.set_title("(b) with a verifier: every output correct", fontsize=10)
    ax.legend(fontsize=7, loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=2, frameon=False)
    ax.grid(alpha=0.3, which="both")
    fig.tight_layout()
    fig.savefig(os.path.join(HERE, "fig_e6.pdf"))
    print("wrote fig_e6.pdf")
    for k in sorted(sush):
        print(k, sush[k])


if __name__ == "__main__":
    main()
