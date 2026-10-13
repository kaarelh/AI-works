"""Study 1, cross-family comparison: the Claude panel (study 1) against the GPT replication (Astra handoff).

usage: python3 src/s1_cross_family.py results/scored.jsonl results/scored_gpt.jsonl analysis_gpt [figures/fig8_cross_family.png]

For each planned contrast, on the five original tasks:
  * the family estimate with study 1's estimator (blocks = model x task x rep, equal weight per block, sign-flip
    permutation p and percentile bootstrap CI over blocks), on the raw scale and in SD units (z within model x task);
  * the same with equal weight per model (per-model mean of block contrasts, then the mean over models), because
    study 1 ran 20 replicates for Haiku and 6-8 for the others while every GPT model has 6;
  * the family difference GPT - Claude: bootstrap CI resampling blocks within each family, and an exact
    permutation p over all 70 ways of splitting the eight models into two groups of four (models as units).
All of it is exploratory: the replication was added after study 1, with study 1's analysis fixed in advance.
"""
import itertools
import json
import os
import sys

import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(__file__))
import analyze as A  # noqa: E402

TASKS5 = ["sched", "whip", "memo", "code", "loop"]
LABEL = {"haiku": "Haiku 5.5", "sonnet": "Sonnet 5.5", "opus": "Opus 5.5", "fable": "Fable 5.1", "gpt-6-astra": "GPT-6 Astra",
         "gpt-6.1-sol": "GPT-6.1 Sol", "gpt-6-luna": "GPT-6 Luna", "gpt-5.6-sol": "GPT-5.6 Sol"}
ORDER = {"Claude": ["haiku", "sonnet", "opus", "fable"], "GPT": ["gpt-6-astra", "gpt-6.1-sol", "gpt-6-luna", "gpt-5.6-sol"]}
FIG_CONTRASTS = [("C1 ai_ban - ai_neutral", "C1  AI-ban advocate − newsroom"),
                 ("C2 ai_ban - ai_industry", "C2  AI-ban advocate − AI lab"),
                 ("C3 AI-specific stance (interaction)", "C3  AI-specific stance (interaction)"),
                 ("C5 ai_ban_miri - ai_ban", "C5  MIRI − generic AI-ban coalition")]
KEEP = ["C1 ai_ban - ai_neutral", "C2 ai_ban - ai_industry", "C3 AI-specific stance (interaction)",
        "C5 ai_ban_miri - ai_ban", "C6 mining_ban - mining_industry", "C9 AI - mining (main effect)"]
RNG = np.random.default_rng(2026)


def load(p, fam):
    d = pd.DataFrame([json.loads(l) for l in open(p)])
    d = d[d.task.isin(TASKS5)].copy()
    d["family"] = fam
    d["z"] = A.standardise(d, "score")
    return d


def blocks(df, w, y):
    """Per-block contrast values with the model of each block."""
    piv = df.pivot_table(index=["model", "task", "rep"], columns="cond", values=y, aggfunc="mean")
    cols = list(w)
    piv = piv.dropna(subset=cols)
    v = (piv[cols] * pd.Series(w)).sum(axis=1)
    return pd.DataFrame({"model": v.index.get_level_values(0), "d": v.to_numpy()})


def per_model_mean(b):
    return b.groupby("model").d.mean()


def boot_family(b, n=10000, by_model=False):
    """Bootstrap of the family estimate, resampling blocks within each model (keeps the model mix fixed)."""
    groups = [g.d.to_numpy() for _, g in b.groupby("model")]
    sizes = np.array([len(g) for g in groups])
    out = np.empty(n)
    for i in range(n):
        means = [g[RNG.integers(0, len(g), len(g))].mean() for g in groups]
        out[i] = np.mean(means) if by_model else np.average(means, weights=sizes)
    return out


def main():
    cl, gp, outdir = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(outdir, exist_ok=True)
    C, G = load(cl, "Claude"), load(gp, "GPT")
    rows, lines = [], []
    for y, scale in (("score", "pp"), ("z", "SD")):
        mult = 100 if y == "score" else 1
        for name in KEEP:
            w = A.CONTRASTS[name]
            bc, bg = blocks(C, w, y), blocks(G, w, y)
            r = dict(contrast=name, scale=scale)
            for fam, b in (("Claude", bc), ("GPT", bg)):
                d = b.d.to_numpy()
                lo, hi = A.boot_ci(d)
                r.update({f"{fam}_est": d.mean() * mult, f"{fam}_lo": lo * mult, f"{fam}_hi": hi * mult,
                          f"{fam}_p": A.signflip_p(d), f"{fam}_n_blocks": len(d)})
                pm = per_model_mean(b)
                bm = boot_family(b, by_model=True)
                r.update({f"{fam}_est_eqmodel": pm.mean() * mult,
                          f"{fam}_lo_eqmodel": np.percentile(bm, 2.5) * mult,
                          f"{fam}_hi_eqmodel": np.percentile(bm, 97.5) * mult})
            # family difference, equal weight per model
            diff_boot = boot_family(bg, by_model=True) - boot_family(bc, by_model=True)
            pm_all = pd.concat([per_model_mean(bc), per_model_mean(bg)])
            obs = per_model_mean(bg).mean() - per_model_mean(bc).mean()
            models = list(pm_all.index)
            gpt_set = set(per_model_mean(bg).index)
            null = []
            for combo in itertools.combinations(models, len(gpt_set)):
                s = set(combo)
                null.append(pm_all[list(s)].mean() - pm_all[[m for m in models if m not in s]].mean())
            null = np.abs(np.array(null))
            r.update(diff_est=obs * mult, diff_lo=np.percentile(diff_boot, 2.5) * mult,
                     diff_hi=np.percentile(diff_boot, 97.5) * mult,
                     diff_p_perm=(null >= abs(obs) - 1e-12).mean(), n_perm=len(null))
            rows.append(r)
            # per model
            for fam, b in (("Claude", bc), ("GPT", bg)):
                for m, g in b.groupby("model"):
                    d = g.d.to_numpy()
                    lo, hi = A.boot_ci(d)
                    lines.append(dict(contrast=name, scale=scale, family=fam, model=m, est=d.mean() * mult,
                                      lo=lo * mult, hi=hi * mult, p=A.signflip_p(d), n_blocks=len(d)))
    t = pd.DataFrame(rows)
    pm = pd.DataFrame(lines)
    prim = t[(t.scale == "pp") & t.contrast.isin(A.PRIMARY)].index
    t["GPT_p_holm"] = np.nan
    t.loc[prim, "GPT_p_holm"] = A.holm(t.loc[prim, "GPT_p"].to_numpy())
    prim_sd = t[(t.scale == "SD") & t.contrast.isin(A.PRIMARY)].index
    t.loc[prim_sd, "GPT_p_holm"] = A.holm(t.loc[prim_sd, "GPT_p"].to_numpy())
    t.to_csv(f"{outdir}/cross_family.csv", index=False)
    pm.to_csv(f"{outdir}/cross_family_per_model.csv", index=False)

    # cell means and ceiling share per family
    cells = []
    for fam, d in (("Claude", C), ("GPT", G)):
        sd = d.groupby(["model", "task"]).score.std(ddof=0)
        cells.append(dict(family=fam, cells=len(sd), zero_var_cells=int((sd == 0).sum()),
                          blocks_in_zero_var_cells=float(d.merge(sd[sd == 0].rename("z0").reset_index(),
                                                                  on=["model", "task"]).shape[0] / len(d))))
    cv = pd.DataFrame(cells)
    means = pd.concat([C, G]).pivot_table(index=["family", "model"], columns="task", values="score", aggfunc="mean") * 100
    md = ["# Study 1: Claude panel vs GPT replication (generated by src/s1_cross_family.py)", "",
          "Five original tasks. Raw scale in percentage points of task score; SD scale standardised within model x task.",
          "Equal weight per block is study 1's estimator; equal weight per model treats each model once.",
          "Family difference = GPT - Claude, equal weight per model; p from an exact permutation over the 70 splits of "
          "the eight models into two groups of four. Exploratory.", "",
          "## Family estimates and difference", "",
          t.to_markdown(index=False, floatfmt=".3f"), "",
          "## Mean task score by model (pp)", "", means.to_markdown(floatfmt=".1f"), "",
          "## Ceiling cells", "", cv.to_markdown(index=False, floatfmt=".3f"), "",
          "## Per model", "", pm.to_markdown(index=False, floatfmt=".3f"), ""]
    open(f"{outdir}/cross_family.md", "w").write("\n".join(md))
    print("wrote", f"{outdir}/cross_family.md")
    if len(sys.argv) > 4:
        figure(t, pm, sys.argv[4])


def figure(t, pm, out):
    """Small multiples: per-model and family estimates (equal weight per model) with 95% CIs, raw scale."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    SURF, INK, INK2, GRID = "#fcfcfb", "#0b0b0b", "#52514e", "#e4e3df"
    COL = {"Claude": "#2a78d6", "GPT": "#eb6834"}
    plt.rcParams.update({"figure.facecolor": SURF, "axes.facecolor": SURF, "savefig.facecolor": SURF, "text.color": INK,
                         "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2, "axes.edgecolor": GRID,
                         "font.size": 10, "axes.spines.top": False, "axes.spines.right": False, "axes.spines.left": False})
    rows = []
    for fam in ("Claude", "GPT"):
        rows += [(fam, m, LABEL[m], False) for m in ORDER[fam]] + [(fam, None, f"{fam}, equal weight per model", True)]
    fig, axes = plt.subplots(1, len(FIG_CONTRASTS), figsize=(13, 4.8), sharey=True)
    for ax, (name, title) in zip(axes, FIG_CONTRASTS):
        tr = t[(t.contrast == name) & (t.scale == "pp")].iloc[0]
        ys, lab = [], []
        for i, (fam, m, label, pooled) in enumerate(rows):
            y = len(rows) - i + (0 if fam == "GPT" else 0.6)
            if pooled:
                est, lo, hi = tr[f"{fam}_est_eqmodel"], tr[f"{fam}_lo_eqmodel"], tr[f"{fam}_hi_eqmodel"]
            else:
                r = pm[(pm.contrast == name) & (pm.scale == "pp") & (pm.model == m)]
                if not len(r):
                    continue
                r = r.iloc[0]
                est, lo, hi = r.est, r.lo, r.hi
            ax.plot([lo, hi], [y, y], color=COL[fam], lw=2, solid_capstyle="round")
            ax.plot([est], [y], marker="o", ms=9 if pooled else 7, color=COL[fam],
                    markerfacecolor=COL[fam] if pooled else SURF, markeredgewidth=2, zorder=3)
            ys.append(y)
            lab.append(label)
        ax.axvline(0, color=INK2, lw=1, zorder=0)
        ax.grid(axis="x", color=GRID, lw=0.8)
        ax.set_axisbelow(True)
        ax.set_title(title, loc="left", fontsize=10, color=INK)
        ax.tick_params(axis="y", length=0)
        lim = max(abs(v) for v in ax.get_xlim())
        ax.set_xlim(-lim, lim)
        ax.set_xlabel("pp of task score")
    axes[0].set_yticks(ys, lab)
    fig.suptitle("Study 1 on two families: planned contrasts per model and per family (95% CIs; five tasks, raw score)\n"
                 "Claude: study 1's four models (6-20 replicates). GPT: four models via the Codex CLI (6 replicates each).",
                 x=0.01, ha="left", fontsize=11, color=INK)
    fig.tight_layout()
    fig.subplots_adjust(top=0.8)
    fig.savefig(out, dpi=160)
    plt.close(fig)
    print("wrote", out)


if __name__ == "__main__":
    main()
