"""Analysis: condition means, planned contrasts, permutation tests, bootstrap CIs.

usage: python3 analyze.py <scored.jsonl> <outdir>

Blocks are (model, task, rep): replicate r uses the same item order in every
condition. A contrast with weights w (summing to 0) is evaluated per block,
d_b = sum_c w_c y_bc, and tested with a sign-flip permutation test on the block
values, with a percentile bootstrap CI over blocks. Pooled analyses standardise
y within model x task (z-scores over all conditions in that cell) before
forming block contrasts.
"""
import json
import os
import sys

import numpy as np
import pandas as pd

CONTRASTS = {
    "C1 ai_ban - ai_neutral": {"ai_ban": 1, "ai_neutral": -1},
    "C2 ai_ban - ai_industry": {"ai_ban": 1, "ai_industry": -1},
    "C3 AI-specific stance (interaction)": {"ai_ban": 1, "ai_industry": -1, "mining_ban": -1, "mining_industry": 1},
    "C4 ai_ban - mining_ban": {"ai_ban": 1, "mining_ban": -1},
    "C5 ai_ban_miri - ai_ban": {"ai_ban_miri": 1, "ai_ban": -1},
    "C6 mining_ban - mining_industry": {"mining_ban": 1, "mining_industry": -1},
    "C7 ai_ban - mean(other 5)": {"ai_ban": 1, "ai_neutral": -.2, "ai_industry": -.2, "mining_ban": -.2,
                                   "mining_neutral": -.2, "mining_industry": -.2},
    "C8 ban - industry (both domains)": {"ai_ban": .5, "mining_ban": .5, "ai_industry": -.5, "mining_industry": -.5},
    "C9 AI - mining (main effect)": {"ai_ban": 1 / 3, "ai_neutral": 1 / 3, "ai_industry": 1 / 3,
                                     "mining_ban": -1 / 3, "mining_neutral": -1 / 3, "mining_industry": -1 / 3},
}
PRIMARY = ["C1 ai_ban - ai_neutral", "C2 ai_ban - ai_industry", "C3 AI-specific stance (interaction)"]
COND_ORDER = ["ai_ban", "ai_ban_miri", "ai_neutral", "ai_industry", "mining_ban", "mining_neutral", "mining_industry"]
MODEL_ORDER = ["haiku", "sonnet", "opus", "fable"]
TASK_ORDER = ["sched", "whip", "memo", "code"]

RNG = np.random.default_rng(12345)


def block_contrast(df, w, y):
    """Per-block contrast values, using only blocks that have every condition in w."""
    piv = df.pivot_table(index=["model", "task", "rep"], columns="cond", values=y, aggfunc="mean")
    cols = list(w)
    if not all(c in piv.columns for c in cols):
        return np.array([])
    piv = piv.dropna(subset=cols)
    return (piv[cols] * pd.Series(w)).sum(axis=1).to_numpy()


def signflip_p(d, n=20000):
    if len(d) == 0:
        return np.nan
    obs = abs(d.mean())
    signs = RNG.choice([-1, 1], size=(n, len(d)))
    null = np.abs((signs * d).mean(axis=1))
    return (1 + (null >= obs - 1e-12).sum()) / (n + 1)


def boot_ci(d, n=10000):
    if len(d) == 0:
        return (np.nan, np.nan)
    idx = RNG.integers(0, len(d), size=(n, len(d)))
    m = d[idx].mean(axis=1)
    return tuple(np.percentile(m, [2.5, 97.5]))


def contrast_table(df, y, by):
    rows = []
    groups = [((), df)] if not by else list(df.groupby(by))
    for key, g in groups:
        key = key if isinstance(key, tuple) else (key,)
        for name, w in CONTRASTS.items():
            d = block_contrast(g, w, y)
            if len(d) == 0:
                continue
            lo, hi = boot_ci(d)
            rows.append(dict(zip(by, key), contrast=name, est=d.mean(), lo=lo, hi=hi, p=signflip_p(d), n_blocks=len(d)))
    return pd.DataFrame(rows)


def holm(ps):
    ps = np.asarray(ps)
    order = np.argsort(ps)
    adj = np.empty_like(ps)
    m = len(ps)
    running = 0
    for rank, i in enumerate(order):
        running = max(running, (m - rank) * ps[i])
        adj[i] = min(1, running)
    return adj


def omnibus(df, y, n=5000):
    """Permutation test of 'condition matters at all' within each model x task cell.
    Statistic: between-condition variance of means; labels permuted within blocks."""
    out = []
    for (m, t), g in df.groupby(["model", "task"]):
        piv = g.pivot_table(index="rep", columns="cond", values=y, aggfunc="mean").dropna()
        if piv.shape[0] < 2:
            continue
        X = piv.to_numpy()
        stat = X.mean(axis=0).var()
        cnt = 0
        for _ in range(n):
            Xp = np.array([RNG.permutation(r) for r in X])
            cnt += Xp.mean(axis=0).var() >= stat - 1e-15
        out.append(dict(model=m, task=t, stat=stat, p=(cnt + 1) / (n + 1), n_reps=X.shape[0]))
    return pd.DataFrame(out)


def standardise(df, y):
    z = df.groupby(["model", "task"])[y].transform(lambda s: (s - s.mean()) / s.std(ddof=0) if s.std(ddof=0) > 0 else s * 0)
    return z


def fmt_table(t, cols):
    return t[cols].to_markdown(index=False, floatfmt=".3f")


def main():
    path, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    df = pd.DataFrame([json.loads(l) for l in open(path)])
    df["z"] = standardise(df, "score")
    df["log_out_tokens"] = np.log(df["out_tokens"].clip(lower=1))
    report = []

    # 1. means
    means = df.groupby(["model", "task", "cond"])["score"].agg(["mean", "sem", "count"]).reset_index()
    means.to_csv(f"{outdir}/means.csv", index=False)
    wide = df.pivot_table(index=["task", "model"], columns="cond", values="score", aggfunc="mean")
    wide = wide[[c for c in COND_ORDER if c in wide.columns]]
    report.append("## Mean score by task x model x condition\n\n" + wide.to_markdown(floatfmt=".3f"))

    # 2. pooled primary contrasts on z and raw
    for y, label in (("z", "standardised score (SD units)"), ("score", "raw score")):
        t = contrast_table(df, y, [])
        prim = t[t.contrast.isin(PRIMARY)].copy()
        t["p_holm(primary)"] = np.nan
        t.loc[prim.index, "p_holm(primary)"] = holm(prim.p.values)
        t.to_csv(f"{outdir}/pooled_contrasts_{y}.csv", index=False)
        report.append(f"## Pooled contrasts, all models and tasks: {label}\n\n" +
                      fmt_table(t, ["contrast", "est", "lo", "hi", "p", "p_holm(primary)", "n_blocks"]))

    for by in (["model"], ["task"], ["model", "task"]):
        t = contrast_table(df, "z" if by != ["model", "task"] else "score", by)
        t.to_csv(f"{outdir}/contrasts_by_{'_'.join(by)}.csv", index=False)
        lab = "standardised" if by != ["model", "task"] else "raw score"
        report.append(f"## Contrasts by {' x '.join(by)} ({lab})\n\n" +
                      fmt_table(t, by + ["contrast", "est", "lo", "hi", "p", "n_blocks"]))

    om = omnibus(df, "score")
    om.to_csv(f"{outdir}/omnibus.csv", index=False)
    report.append("## Omnibus permutation test (does condition matter at all?), per model x task\n\n" +
                  om.to_markdown(index=False, floatfmt=".4f"))

    # 3. secondary outcomes
    sec = []
    for y in ["log_out_tokens", "thinking_tokens"]:
        if df[y].notna().any():
            t = contrast_table(df.dropna(subset=[y]), y, ["model"])
            t["outcome"] = y
            sec.append(t)
    w = df[df.task == "whip"].copy()
    if len(w):
        t = contrast_table(w, "pro_bill_bias", ["model"])
        t["outcome"] = "whip pro_bill_bias"
        sec.append(t)
    mm = df[df.task == "memo"].copy()
    if len(mm):
        for y in ["n_extra", "recall_stance_sections", "recall_shared_sections"]:
            t = contrast_table(mm, y, ["model"])
            t["outcome"] = "memo " + y
            sec.append(t)
    s = df[df.task == "sched"].copy()
    if len(s):
        s["strict_valid_f"] = s["strict_valid"].astype(float)
        t = contrast_table(s, "strict_valid_f", ["model"])
        t["outcome"] = "sched strict_valid"
        sec.append(t)
    if sec:
        sec = pd.concat(sec)
        sec.to_csv(f"{outdir}/secondary_contrasts.csv", index=False)
        report.append("## Secondary outcomes\n\n" + fmt_table(sec, ["outcome", "model", "contrast", "est", "lo", "hi", "p", "n_blocks"]))

    mk = df.groupby(["model", "cond"])[[c for c in df.columns if c.startswith("m_")]].mean()
    report.append("## Text markers (share of responses)\n\n" + mk.to_markdown(floatfmt=".3f"))
    cost = df.groupby("model")["cost"].sum()
    report.append("## Cost (USD)\n\n" + cost.to_markdown(floatfmt=".2f") + f"\n\nTotal: ${df.cost.sum():.2f}")

    open(f"{outdir}/report.md", "w").write("\n\n".join(report) + "\n")
    print(f"wrote {outdir}/report.md")


if __name__ == "__main__":
    main()
