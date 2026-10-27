"""Summaries and figures for the Boolean grids.

Writes results/boolean/summary_<grid>.md and figures/boolean_<grid>.{png,pdf}.
"""
import collections
import json
import os
import sys

import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from accounting import boolean_bound, boolean_any_D, DESIGN_BITS, DESIGN_FACTOR  # noqa: E402
ROOT = os.path.join(HERE, "..", "..")
SERIES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100"]   # categorical slots 1-4, fixed order
INK, INK2, GRID = "#0b0b0b", "#52514e", "#e4e3df"


def load(path):
    rows = [json.loads(l) for l in open(path)]
    for r in rows:   # reported bounds include the design charge (accounting.py)
        r["bound_f_raw"] = r["bound_f"]
        r["bound_f"] = boolean_bound(r)
        if "bits_any_D" in r:
            r["bound_f_any_D"] = boolean_any_D(r)
    return rows


def label(r):
    return r["task"] + (f" (label noise {r['noise']:g})" if r["noise"] else "")


def summarize(rows, grid):
    groups = collections.defaultdict(list)
    for r in rows:
        groups[(label(r), r["m"])].append(r)
    tasks = sorted({k[0] for k in groups}, key=lambda s: (("noise" in s), s))
    lines = [f"# Boolean grid `{grid}`: bounds on the trained network f\n",
             "Each row averages 3 seeds (training sets and initializations). `test err f`: exact "
             "(n = 20, all 2^20 inputs) or on 3x10^5 fresh inputs. `bound on f`: Theorem 2 with delta = 0.05 "
             "(Occam term for g plus an upper bound on Pr[f != g] under the uniform input distribution), "
             f"including the design charge of accounting.py ({DESIGN_BITS:g} bits, disagreement at delta/{DESIGN_FACTOR}; "
             "for n = 20 the disagreement is exact). `Occam part`, `Pr[f≠g] part` and `bits` are given without the "
             "design charge: the two parts add up to the uncharged bound, slightly below `bound on f`, and `bits` (the "
             f"description length of g) leaves out the {DESIGN_BITS:g} design bits that the paper's tables include. `float32 Occam` and `VC (d = #params)`: parameter-counting "
             "baselines for f itself. Every bound is a valid upper bound for its own seed; the table shows means.\n"]
    has_any = any("bound_f_any_D" in r for r in rows)
    hdr = "| task | m | test err f | bound on f | Occam part | Pr[f≠g] part | bits | best g (seed 0) | float32 Occam | VC (d=#params) |"
    if has_any:
        hdr += " any-D bound |"
    lines.append(hdr)
    lines.append("|" + "---|" * (hdr.count("|") - 1))
    for t in tasks:
        for m in sorted({k[1] for k in groups if k[0] == t}):
            g = sorted(groups[(t, m)], key=lambda r: r["seed"])
            mean = lambda k: np.mean([r[k] for r in g])
            row = (f"| {t} | {m} | {mean('test_err_f'):.4f} | {mean('bound_f'):.4f} | {mean('occam_g'):.4f} | "
                   f"{mean('dis_upper'):.4f} | {mean('bits'):.0f} | {g[0]['best_label']} | "
                   f"{mean('baseline_occam32'):.2f} | {mean('baseline_vc_W'):.2f} |")
            if has_any:
                row += f" {mean('bound_f_any_D'):.4f} |"
            lines.append(row)
    viol = sum(r["bound_f"] < r["test_err_f"] for r in rows)
    nonvac = sum(r["bound_f"] < 0.5 for r in rows)
    lines.append(f"\nRuns: {len(rows)}. Bound below 0.5 (non-vacuous for a binary task): {nonvac}. "
                 f"Runs where the bound is below the measured test error: {viol}.")
    params = sorted({r["params"] for r in rows})
    lines.append(f"Network f: widths {rows[0]['widths']}, {params} parameters; Adam, lr {rows[0]['lr']}, "
                 f"batch 64, trained to zero training error and mean training loss <= {rows[0].get('stop_loss')}.")
    return "\n".join(lines) + "\n", tasks, groups


def figure(tasks, groups, grid, path):
    k = len(tasks)
    cols = min(4, k)
    rws = int(np.ceil(k / cols))
    fig, axes = plt.subplots(rws, cols, figsize=(3.1 * cols, 2.7 * rws), squeeze=False, sharey=True)
    for ax in axes.ravel()[k:]:
        ax.axis("off")
    for ax, t in zip(axes.ravel(), tasks):
        ms = sorted({key[1] for key in groups if key[0] == t})
        def stat(key):
            return np.array([np.mean([r[key] for r in groups[(t, m)]]) for m in ms], dtype=float)
        te = np.maximum(stat("test_err_f"), 1e-4)
        bd = stat("bound_f")
        ax.plot(ms, bd, color=SERIES[1], lw=2, marker="o", ms=4, label="bound on f (Thm 2)")
        ax.plot(ms, te, color=SERIES[0], lw=2, marker="s", ms=4, label="test error of f")
        if "bound_f_any_D" in groups[(t, ms[0])][0]:
            ax.plot(ms, stat("bound_f_any_D"), color=SERIES[2], lw=2, marker="^", ms=4,
                    label="bound, any input distribution (Cor 3)")
        ax.axhline(0.5, color=INK2, lw=1, ls=":")
        if t == tasks[0]:
            ax.text(ms[0], 0.36, "chance", fontsize=7, color=INK2)
        ax.set_xscale("log")
        ax.set_yscale("log")
        ax.set_ylim(8e-5, 1.2)
        ax.set_title(t, fontsize=9, color=INK)
        ax.grid(True, color=GRID, lw=0.6)
        for s in ax.spines.values():
            s.set_color(GRID)
        ax.tick_params(colors=INK2, labelsize=7)
        ax.set_xlabel("training set size m", fontsize=8, color=INK2)
    axes[0, 0].set_ylabel("error (log scale)", fontsize=8, color=INK2)
    h, l = axes[0, 0].get_legend_handles_labels()
    fig.legend(h, l, loc="lower center", ncol=len(l), fontsize=8, frameon=False)
    fig.suptitle(f"Boolean tasks ({grid}); test error 0 is drawn at 1e-4. Parameter-counting (float32 Occam) and VC "
                 "bounds on the same networks are 1.0 at every m.", fontsize=9, color=INK2)
    fig.tight_layout(rect=(0, 0.06, 1, 0.95))
    fig.savefig(path + ".png", dpi=170)
    fig.savefig(path + ".pdf")
    plt.close(fig)


if __name__ == "__main__":
    grid = sys.argv[1]
    rows = load(os.path.join(ROOT, "results", "boolean", f"grid_{grid}.jsonl"))
    md, tasks, groups = summarize(rows, grid)
    open(os.path.join(ROOT, "results", "boolean", f"summary_{grid}.md"), "w").write(md)
    os.makedirs(os.path.join(ROOT, "figures"), exist_ok=True)
    figure(tasks, groups, grid, os.path.join(ROOT, "figures", f"boolean_{grid}"))
    print(md)
