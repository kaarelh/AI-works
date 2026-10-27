"""Summaries and figures: training-data-only bounds (T3), the MNIST bounds with
unlabeled inputs (T1/T2), and the initialization study.

Writes results/summary_t3.md, results/summary_t2.md, results/summary_init.md
and figures/t3_mnist.{png,pdf}, figures/init_mnist.{png,pdf}.
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
sys.path.insert(0, os.path.join(HERE, ".."))
from analyze_mnist import main as t2_table  # noqa: E402
from accounting import t1_bound, t2_bound, t3_bound, boolean_bound  # noqa: E402

ROOT = os.path.join(HERE, "..", "..")
RES = os.path.join(ROOT, "results")
FIG = os.path.join(ROOT, "figures")
SERIES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100"]
INK2, GRID = "#52514e", "#e4e3df"


def load(p):
    return [json.loads(l) for l in open(p)] if os.path.exists(p) else []


def style(ax):
    ax.grid(True, color=GRID, lw=0.6)
    for s in ax.spines.values():
        s.set_color(GRID)
    ax.tick_params(colors=INK2, labelsize=7)


def t3():
    rows = load(os.path.join(RES, "mnist", "t3.jsonl"))
    out = ["# Training-data-only bounds on the original network (Theorem 5 + Lemma 7)\n",
           "One-hidden-layer MLPs trained with Adam (20 epochs, batch 128). Dithered compression; delta = 0.04, "
           "delta' = 0.01; t1, t2 and eta/delta' per row. `T3 bound` uses only the 60k training examples: no validation set and "
           "no unlabeled data. `cert` = fraction of training points certified. `test err g` is the dithered network's "
           "test error (for reference).\n",
           "| data | hidden | weight noise | init | code ref | basis | params | train err f | test err f | bits | cert | T3 bound on f | t1, t2 | eta/delta' | float32 Occam | test err g |",
           "|" + "---|" * 16]
    for r in sorted(rows, key=lambda r: (r["data"], r.get("weight_noise", 0), r["widths"][1], r.get("init", ""), r.get("code_ref", ""), r["basis"])):
        W = r["params"]
        from cgb.bounds import occam_bound
        occ32 = occam_bound(int(round(r["train_err_f"] * 60000)), 60000, 32.0 * W + 64, 0.05)
        out.append(f"| {r['data']} | {r['widths'][1]} | {r.get('weight_noise', 0)} | {r.get('init', 'random')} | "
                   f"{r.get('code_ref', 'init')} | {r['basis']} | {W} | {r['train_err_f']:.4f} | {r['test_err_f']:.4f} | "
                   f"{r['bits']:.0f} | {r['cert_frac']:.4f} | {t3_bound(r):.4f} | {r['t1']}, {r['t2']} | "
                   f"{r['eta'] / r['delta_prime']:.1e} | {occ32:.2f} | {r['test_err_g']:.4f} |")
    bt = load(os.path.join(RES, "boolean", "t3.jsonl"))
    if bt:
        out += ["\n## Boolean tasks: training-data-only bound (valid for any input distribution) vs known-distribution bound\n",
                "| task | n | m | width | weight noise | test err f | T3 bits | cert | T3 bound (any D) | Thm-2 bound (uniform D known) | Thm-2 bits |",
                "|" + "---|" * 11]
        for r in sorted(bt, key=lambda r: (r["n"], r["task"], r["m"], r["width"], r["weight_noise"])):
            out.append(f"| {r['task']} | {r['n']} | {r['m']} | {r['width']} | {r['weight_noise']} | {r['test_err_f']:.4f} | "
                       f"{r['t3_bits']:.0f} | {r['cert_frac']:.4f} | {t3_bound(r):.4f} | "
                       f"{boolean_bound(dict(r['T2known'], m=r['m'])):.4f} | {r['T2known_bits']:.0f} |")
    open(os.path.join(RES, "summary_t3.md"), "w").write("\n".join(out) + "\n")
    # figure: bound vs hidden width, standard and noise-trained, MNIST and Fashion
    sel = [r for r in rows if r.get("init", "random") == "random" and r.get("code_ref", "init") == "init" and r["basis"] == "dct"]
    if sel:
        datas = sorted({r["data"] for r in sel})
        fig, axes = plt.subplots(1, len(datas), figsize=(3.6 * len(datas), 2.9), squeeze=False, sharey=True)
        for ax, d in zip(axes[0], datas):
            for j, wn in enumerate(sorted({r.get("weight_noise", 0) for r in sel if r["data"] == d})):
                rr = sorted([r for r in sel if r["data"] == d and r.get("weight_noise", 0) == wn], key=lambda r: r["widths"][1])
                H = [r["widths"][1] for r in rr]
                lab = "standard training" if wn == 0 else f"trained with weight noise {wn:g}"
                ax.plot(H, [t3_bound(r) for r in rr], color=SERIES[1 + 2 * j], lw=2, marker="o", ms=4,
                        label=f"T3 bound on f, {lab}")
                ax.plot(H, [r["test_err_f"] for r in rr], color=SERIES[0 + 3 * j], lw=1.5, ls="--", marker="s", ms=3,
                        label=f"test error of f, {lab}")
            ax.axhline(0.9, color=INK2, lw=1, ls=":")
            ax.set_xscale("log", base=2)
            ax.set_ylim(0, 1.02)
            ax.set_title(d, fontsize=9)
            ax.set_xlabel("hidden units", fontsize=8, color=INK2)
            style(ax)
        axes[0, 0].set_ylabel("error", fontsize=8, color=INK2)
        h, l = axes[0, 0].get_legend_handles_labels()
        fig.legend(h, l, loc="lower center", ncol=2, fontsize=7, frameon=False)
        fig.tight_layout(rect=(0, 0.16, 1, 1))
        fig.savefig(os.path.join(FIG, "t3_mnist.png"), dpi=170)
        fig.savefig(os.path.join(FIG, "t3_mnist.pdf"))
        plt.close(fig)


def init():
    rows = load(os.path.join(RES, "init", "mnist_init.jsonl"))
    out = ["# Initialization study\n", "## MNIST, 784-256-10, codes relative to the initialization vs relative to zero\n",
           "Each row: one trained f and code family, best over its compression configurations (union-bound corrected "
           "for the disagreement term; design charge of accounting.py). T1 = Occam bound on g; T2 = bound on f with unlabeled test inputs.\n",
           "| init | init scale | code ref | test err f | best T1 | bits (T1) | best T2 | bits (T2) |", "|---|---|---|---|---|---|---|---|"]
    from cgb.bounds import occam_bound, cp_upper
    groups = collections.defaultdict(list)
    for r in rows:
        groups[(r.get("init", "random"), r["init_scale"], r.get("code_ref", "init"), r["data"],
                tuple(r["widths"]), r["seed"], r["epochs"], r["lr"], r["wd"])].append(r)
    for k in sorted(groups):
        g = groups[k]
        assert len({(r["train_err_f"], r["test_err_f"]) for r in g}) == 1, "group mixes networks"
        K = len(g)
        b1 = min(g, key=t1_bound)
        b2 = min(g, key=lambda r: t2_bound(r, K))
        out.append(f"| {k[0]} | {k[1]} | {k[2]} | {g[0]['test_err_f']:.4f} | {t1_bound(b1):.4f} | {b1['bits']:.0f} | "
                   f"{t2_bound(b2, K):.4f} | {b2['bits']:.0f} |")
    ik = load(os.path.join(RES, "init", "init_kernel.jsonl"))
    if ik:
        out += ["\n## Boolean, n = 30, one hidden layer of 512: init-kernel codec vs distillation codec\n",
                "`move` = ||theta - theta0|| / ||theta0||; `lin dis` = Pr[sign of linearized f != sign of f]. "
                "Init-kernel codec: theta0 + top-r eigenvectors of the uniform-input empirical NTK at theta0 (free), "
                "r coefficients coded.\n",
                "| task | regime | m | test err f | move | lin dis | kernel codec: r | bits | bound on f | distillation codec: bits | bound on f | g |",
                "|" + "---|" * 12]
        for r in sorted(ik, key=lambda r: (r["task"], r["regime"], r["m"])):
            kc = r["kernel_codec"]
            out.append(f"| {r['task']} | {r['regime']} | {r['m']} | {r['test_err_f']:.4f} | {r['rel_param_move']:.2f} | "
                       f"{r['lin_disagreement']:.3f} | {kc['r']} | {kc['bits']:.0f} | {boolean_bound(r['kernel_cert']):.4f} | "
                       f"{r['distill_bits']:.0f} | {boolean_bound(dict(r['distill_cert'], m=r['m'])):.4f} | {r['distill_label']} |")
    open(os.path.join(RES, "summary_init.md"), "w").write("\n".join(out) + "\n")


if __name__ == "__main__":
    os.makedirs(FIG, exist_ok=True)
    t3()
    init()
    p = os.path.join(RES, "mnist", "t2.jsonl")
    if os.path.exists(p):
        txt = ("# Bounds on f with unlabeled inputs (Theorem 2; the setting of Bazinet et al. 2026) and on g (Occam)\n\n"
               "Best over K compression configurations per trained f; the disagreement term uses delta/(2K).\n\n" + t2_table(p))
        pid = os.path.join(RES, "mnist", "t2_basis_id.jsonl")
        if os.path.exists(pid):
            txt += "\n\n## Ablation: first-layer update coded in the pixel basis instead of the DCT basis\n\n" + t2_table(pid)
        open(os.path.join(RES, "summary_t2.md"), "w").write(txt + "\n")
    for f in ["summary_t3.md", "summary_init.md", "summary_t2.md"]:
        p = os.path.join(RES, f)
        if os.path.exists(p):
            print(open(p).read())
