"""Figures and tables for the note, from the saved outputs of hidden_insights.py and
property_rules.py. Also computes, for E2, how often the "new simple property" signal
fires at a random step after Q task queries at random contents (exactly, over all
contents), which the note quotes.

Usage: python3 make_figures.py RESULTSDIR
"""

import json
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import property_rules as pr  # noqa: E402


def e1(res):
    s = json.load(open(os.path.join(res, "hidden_insights_summary.json")))
    ns = sorted({v["n"] for v in s.values()})
    names = ["CI", "US", "US-high", "CS", "MB"]
    rows = ["| n | CI task | US(γ=η/2n) task | US(γ=2η/n) final failure | CS task / checks | MB task / checks |",
            "|---|---|---|---|---|---|"]
    for n in ns:
        g = {nm: s[f"{nm}_n{n}"] for nm in names}
        rows.append(
            f"| {n} | {g['CI']['task_mean']:,.0f} | {g['US']['task_mean']:,.0f} | "
            f"{g['US-high']['final_failure_mean']:.2f} (never queries) | "
            f"{g['CS']['task_mean']:,.0f} / {g['CS']['checks_mean']:,.0f} | "
            f"{g['MB']['task_mean']:,.1f} / {g['MB']['checks_mean']:,.0f} |")
    table = "\n".join(rows)

    fig, ax = plt.subplots(1, 2, figsize=(10, 4))
    style = {"CI": ("C0", "o", "chained imitation"), "US": ("C1", "s", "uncertainty sampling (γ = η/2n)"),
             "CS": ("C2", "^", "check and scan"), "MB": ("C3", "D", "monitored bisection")}
    for nm, (col, mk, lab) in style.items():
        task = [s[f"{nm}_n{n}"]["task_mean"] for n in ns]
        tot = [s[f"{nm}_n{n}"]["task_mean"] + s[f"{nm}_n{n}"]["checks_mean"] for n in ns]
        ax[0].plot(ns, task, marker=mk, color=col, label=lab)
        ax[1].plot(ns, tot, marker=mk, color=col, label=lab)
    for a, t in zip(ax, ["task queries to reach failure ≤ 2%", "task queries + checks"]):
        a.set_xscale("log", base=2)
        a.set_yscale("log")
        a.set_xlabel("run length n")
        a.set_title(t)
        a.grid(alpha=0.3)
    ax[0].legend(fontsize=8)
    fig.suptitle("E1: hidden insights (m = 100 problems, η = 1/2), mean of 10 humans")
    fig.tight_layout()
    fig.savefig(os.path.join(res, "hidden_insights.png"), dpi=130)
    return table


def novelty_curve(seeds=3, qs=(0, 25, 50, 100, 200, 400, 800, 1600, 3200)):
    """Fraction of contents with an unsettled property of size <= s after Q task
    queries at independent uniformly random contents."""
    out = {s: [] for s in (3, 6, 9)}
    for q in qs:
        vals = {s: [] for s in out}
        for seed in range(seeds):
            rng = np.random.default_rng(seed)
            resolved = np.zeros(len(pr.MASKS) * pr.NC, dtype=bool)
            for c in rng.integers(pr.NC, size=q):
                resolved[pr.prop_ids(int(c))] = True
            # for every content, does an unsettled property of size exactly s hold?
            cs = np.arange(pr.NC, dtype=np.int64)
            for s in out:
                sel = np.flatnonzero(pr.MASK_R == s)
                ids = sel[None, :] * pr.NC + (cs[:, None] & pr.MASKS[sel][None, :])
                vals[s].append(float(np.mean((~resolved[ids]).any(axis=1))))
        for s in out:
            out[s].append(float(np.mean(vals[s])))
    return list(qs), out


def e2(res):
    s = json.load(open(os.path.join(res, "property_rules_summary.json")))
    c = json.load(open(os.path.join(res, "property_rules_curves.json")))
    labels = ["CI", "US(0.01)", "US(0.001)", "NOV(3)", "NOV(6)", "NOV(9)", "CS", "MB"]
    ns = sorted({v["n"] for v in s.values()})
    rows = ["| protocol | " + " | ".join(f"n = {n}: task / checks (reached; final failure)" for n in ns) + " |",
            "|---|" + "---|" * len(ns)]
    for lab in labels:
        cells = []
        for n in ns:
            v = s[f"{lab}_n{n}"]
            cells.append(f"{v['task_mean']:,.0f} / {v['checks_mean']:,.0f} "
                         f"({v['reached_fraction']*10:.0f}/10; {v['final_failure_mean']:.3f})")
        rows.append(f"| {lab} | " + " | ".join(cells) + " |")
    table = "\n".join(rows)

    qs, nov = novelty_curve()
    nrows = ["| task queries at random contents | " + " | ".join(str(q) for q in qs) + " |",
             "|---|" + "---|" * len(qs)]
    for sz in (3, 6, 9):
        nrows.append(f"| new property of size ≤ {sz} at a random step | " +
                     " | ".join(f"{100*v:.0f}%" for v in nov[sz]) + " |")
    ntable = "\n".join(nrows)

    fig, ax = plt.subplots(1, 2, figsize=(10, 4))
    n = 16
    style = {"CI": ("C0", "-"), "US(0.001)": ("C1", ":"), "NOV(6)": ("C4", "--"),
             "NOV(9)": ("C5", "-."), "CS": ("C2", "-"), "MB": ("C3", "-")}
    for lab, (col, ls) in style.items():
        log = np.array(c[f"{lab}_n{n}"])
        log = log[log[:, 1] > 0]  # drop the point before the first query (log axis)
        ax[0].step(log[:, 1], log[:, 3], where="post", color=col, linestyle=ls, lw=1.8, label=lab)
    ax[0].set_xscale("log")
    ax[0].set_xlabel("task queries")
    ax[0].set_ylabel("failure probability of the decoder")
    ax[0].set_title(f"E2, n = {n}, one human (US, NOV(6), NOV(9) overlap\nwhile they query every step)")
    ax[0].legend(fontsize=8)
    ax[0].grid(alpha=0.3)
    for sz, col in zip((3, 6, 9), ("C6", "C4", "C5")):
        ax[1].plot(np.maximum(qs, 1), nov[sz], marker="o", color=col, label=f"size ≤ {sz}")
    ax[1].set_xscale("log")
    ax[1].set_xlabel("task queries at random contents")
    ax[1].set_ylabel("fraction of steps with a new simple property")
    ax[1].set_title("how often 'new simple property' fires")
    ax[1].legend(fontsize=8)
    ax[1].grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(res, "property_rules.png"), dpi=130)
    return table, ntable


def main(res):
    t1 = e1(res)
    t2, t3 = e2(res)
    with open(os.path.join(res, "tables.md"), "w") as f:
        f.write("## E1\n\n" + t1 + "\n\n## E2\n\n" + t2 + "\n\n## E2 novelty\n\n" + t3 + "\n")
    print(t1, "\n\n", t2, "\n\n", t3)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../results")
