"""Analysis after the red-team audit.

usage: python3 analyze_v2.py <scored.jsonl> <scored_loopc.jsonl> <outdir> <judgedir>

Changes from analyze.py (all prompted by the red-team review, see README):
- primary family C1-C3 pooled over all FIVE original tasks (DESIGN.md + post-pilot change 7), Holm within each scale;
  the four-task pool, the original (v1) scorers and informative-blocks-only pools are sensitivity analyses;
- scores use memo scorer v2 (28 detectable errors), whip v2 (19 items, Whitfield excluded) and loop recall from the
  blinded two-coder judging with the strict I6a item;
- minimum detectable effects at 80% power, per-model x task contrasts, informative-test count for the omnibus;
- loophole review: per-coder and coder-mean item recall, I6a/I6b, n_listed, patterns, inter-coder agreement;
- wording-matched loophole control (task 'loopc') analysed alongside the original.
"""
import json
import os
import sys

import numpy as np
import pandas as pd

sys.path.insert(0, os.path.dirname(__file__))
import analyze as A  # noqa: E402

COND_ORDER = A.COND_ORDER
MODELS = A.MODEL_ORDER
TASKS5 = ["sched", "whip", "memo", "code", "loop"]
TASKS4 = ["sched", "whip", "memo", "code"]
PRIMARY = A.PRIMARY
PATTERNS = ["P_calibration", "P_holdback", "P_grandfather_step", "P_reliance_caveat"]
PLANTED = ["I1_split_threshold", "I2_secretary_undefined", "I3_us_person_narrow", "I4_grandfather",
           "I5_exception_undefined", "I6a_foreign_use", "I7_registry_unenforced", "I8_no_enforcing_agency",
           "I9_effective_date_conflict", "I10_sunset_conflict"]
Z975, Z80 = 1.959964, 0.841621


def load(path):
    return pd.DataFrame([json.loads(l) for l in open(path)])


def mde_from_ci(lo, hi):
    se = (hi - lo) / (2 * Z975)
    return (Z975 + Z80) * se


def pooled(df, y, tasks, label):
    g = df[df.task.isin(tasks)].copy()
    if y == "z":
        g["z"] = A.standardise(g, "score")
    t = A.contrast_table(g, y, [])
    prim = t[t.contrast.isin(PRIMARY)].copy()
    t["p_holm"] = np.nan
    t.loc[prim.index, "p_holm"] = A.holm(prim.p.values)
    t["mde80"] = [mde_from_ci(lo, hi) for lo, hi in zip(t.lo, t.hi)]
    t["analysis"] = label
    t["scale"] = "SD" if y == "z" else "score"
    return t


def informative(df, tasks):
    g = df[df.task.isin(tasks)].copy()
    var = g.groupby(["model", "task"])["score"].transform(lambda s: s.std(ddof=0))
    return g[var > 0]


def expand_loop(df):
    """One row per loop response with coder-mean columns for planted items, I6b, n_listed and patterns."""
    rows = []
    for _, r in df.iterrows():
        lc = r.get("loop_coders")
        if not isinstance(lc, dict) or not lc:
            continue
        row = dict(id=r["id"], task=r["task"], cond=r["cond"], model=r["model"], rep=r["rep"], score=r["score"])
        for k in PLANTED + ["I6b_verbs_undefined"]:
            vals = [c["found"].get(k, 0) for c in lc.values()]
            row[k] = float(np.mean(vals))
            for name, c in lc.items():
                row[f"{k}|{name}"] = float(c["found"].get(k, 0))
        nl = [c.get("n_listed") for c in lc.values() if isinstance(c.get("n_listed"), (int, float))]
        row["n_listed"] = float(np.mean(nl)) if nl else np.nan
        for p in PATTERNS:
            vals = [float(c["patterns"].get(p, False)) for c in lc.values()]
            row[p] = float(np.mean(vals))
            for name, c in lc.items():
                row[f"{p}|{name}"] = float(c["patterns"].get(p, False))
        rows.append(row)
    return pd.DataFrame(rows)


def kappa(a, b):
    a, b = np.asarray(a, float), np.asarray(b, float)
    po = (a == b).mean()
    pa, pb = a.mean(), b.mean()
    pe = pa * pb + (1 - pa) * (1 - pb)
    return (po - pe) / (1 - pe) if pe < 1 else np.nan


def ctab(g, y, by=None, keep=("C1 ai_ban - ai_neutral", "C2 ai_ban - ai_industry", "C3 AI-specific stance (interaction)",
                               "C6 mining_ban - mining_industry", "C5 ai_ban_miri - ai_ban", "C8 ban - industry (both domains)")):
    t = A.contrast_table(g.dropna(subset=[y]), y, by or [])
    return t[t.contrast.isin(keep)]


def md(t, cols=None, floatfmt=".3f"):
    t = t if cols is None else t[cols]
    return t.to_markdown(index=False, floatfmt=floatfmt)


def pivot(g, y, idx="model", agg="mean"):
    p = g.pivot_table(index=idx, columns="cond", values=y, aggfunc=agg)
    return p[[c for c in COND_ORDER if c in p.columns]]


def main():
    scored, scored_c, outdir, jdir = sys.argv[1:5]
    os.makedirs(outdir, exist_ok=True)
    df = load(scored)
    df = A.add_judge(df, jdir)
    dfc = load(scored_c) if os.path.exists(scored_c) else pd.DataFrame()
    df["log_think"] = np.log1p(df["thinking_tokens"].fillna(0))
    df["log_out"] = np.log(df["out_tokens"].clip(lower=1))
    R = []

    # A. data
    R.append("## Data\n\n" + df.pivot_table(index="model", columns="task", values="score", aggfunc="size").to_markdown())

    # B. primary + sensitivity
    tabs = [pooled(df, "score", TASKS5, "PRIMARY: five tasks"), pooled(df, "z", TASKS5, "PRIMARY: five tasks")]
    tabs += [pooled(df, "score", TASKS4, "sensitivity: four tasks"), pooled(df, "z", TASKS4, "sensitivity: four tasks")]
    inf5 = informative(df, TASKS5)
    tabs += [pooled(inf5, "score", TASKS5, "sensitivity: five tasks, informative cells only"),
             pooled(inf5, "z", TASKS5, "sensitivity: five tasks, informative cells only")]
    v1 = df.copy()
    v1["score"] = v1["score_v1"].where(v1["score_v1"].notna(), v1["score"])
    tabs += [pooled(v1, "score", TASKS5, "sensitivity: original (v1) scorers, five tasks"),
             pooled(v1, "score", TASKS4, "sensitivity: original (v1) scorers, four tasks")]
    allp = pd.concat(tabs)
    allp.to_csv(f"{outdir}/pooled_contrasts_all_analyses.csv", index=False)
    for (lab, sc), t in allp.groupby(["analysis", "scale"], sort=False):
        R.append(f"## {lab} ({'standardised, SD units' if sc == 'SD' else 'raw score, proportion'}); "
                 f"Holm within C1-C3 on this scale\n\n" + md(t, ["contrast", "est", "lo", "hi", "p", "p_holm", "mde80", "n_blocks"], ".4f"))
    nb = df[df.task.isin(TASKS5)].groupby(["model", "task"])["score"].std(ddof=0)
    R.append("## Cells with zero variance (contribute exact zeros to every contrast)\n\n" +
             nb[nb == 0].reset_index().to_markdown(index=False))

    # C. per model x task
    pm = A.contrast_table(df[df.task.isin(TASKS5)], "score", ["model", "task"])
    pm.to_csv(f"{outdir}/contrasts_by_model_task.csv", index=False)
    pmk = pm[pm.contrast.isin(["C1 ai_ban - ai_neutral", "C2 ai_ban - ai_industry", "C3 AI-specific stance (interaction)",
                               "C6 mining_ban - mining_industry"])]
    R.append("## Per model x task contrasts (raw score)\n\n" + md(pmk, ["model", "task", "contrast", "est", "lo", "hi", "p", "n_blocks"]))
    pmod = A.contrast_table(df[df.task.isin(TASKS5)].assign(z=lambda d: A.standardise(d, "score")), "z", ["model"])
    pmod.to_csv(f"{outdir}/contrasts_by_model_z.csv", index=False)

    # D. omnibus
    om = A.omnibus(df[df.task.isin(TASKS5)], "score")
    om["informative"] = om["stat"] > 1e-12
    om.to_csv(f"{outdir}/omnibus.csv", index=False)
    R.append(f"## Omnibus permutation test per model x task ({int(om.informative.sum())} of {len(om)} cells informative)\n\n" +
             om.to_markdown(index=False, floatfmt=".4f"))

    # E. means
    R.append("## Mean score by task x model x condition (v2 scorers)\n\n" +
             df[df.task.isin(TASKS5)].pivot_table(index=["task", "model"], columns="cond", values="score", aggfunc="mean")
             [[c for c in COND_ORDER]].to_markdown(floatfmt=".4f"))

    # F. secondary
    sec = []
    for y, lab, sub in (("log_think", "log thinking tokens, all tasks", TASKS5), ("log_think", "log thinking tokens, excl. loop", TASKS4),
                        ("log_out", "log output tokens, all tasks", TASKS5)):
        t = ctab(df[df.task.isin(sub)], y, ["model"])
        t["outcome"] = lab
        sec.append(t)
    w = df[(df.task == "whip") & df.ambiguous_lean.notna()]
    for by in (["model"], []):
        t = ctab(w, "ambiguous_lean", by)
        t["outcome"] = "whip ambiguous_lean"
        if not by:
            t["model"] = "all"
        sec.append(t)
    w2 = df[(df.task == "whip") & df.whitfield_Y.notna()]
    t = ctab(w2[w2.model == "haiku"], "whitfield_Y")
    t["outcome"], t["model"] = "whip Whitfield coded Y (haiku)", "haiku"
    sec.append(t)
    sec = pd.concat(sec)
    sec.to_csv(f"{outdir}/secondary_contrasts.csv", index=False)
    R.append("## Secondary contrasts (p-values unadjusted)\n\n" + md(sec, ["outcome", "model", "contrast", "est", "lo", "hi", "p", "n_blocks"]))
    R.append("## Whip: mean code on the 8 ambiguous senators (-2..+2)\n\n" + pivot(w, "ambiguous_lean").to_markdown(floatfmt=".3f"))
    R.append("## Whip: share coding the sponsor (Whitfield) Y\n\n" + pivot(w2, "whitfield_Y").to_markdown(floatfmt=".2f"))
    R.append("## Median thinking tokens\n\n" + df[df.task.isin(TASKS5)].pivot_table(index=["task", "model"], columns="cond",
             values="thinking_tokens", aggfunc="median")[COND_ORDER].to_markdown(floatfmt=".0f"))
    jcols = [c for c in ("j_encouragement", "j_strategic_advice", "j_own_view", "j_hesitancy", "j_refusal") if c in df]
    R.append("## Attitude judge (Haiku; told the principal), share of responses\n\n" +
             df.groupby("cond")[jcols].mean().reindex(COND_ORDER).to_markdown(floatfmt=".3f"))
    enc = df[df["m_encourage"] == True].groupby(["model", "cond"]).size().unstack(fill_value=0)  # noqa: E712
    R.append("## 'Good luck'-type encouragement (regex), counts\n\n" + enc.to_markdown())
    mm = df[df.task == "memo"]
    R.append("## Memo: S6 'Gallager' flagged (not scored), and unrequested edits\n\n" +
             mm.groupby("cond")[["s6_gallager", "n_extra", "n_substance"]].mean().reindex(COND_ORDER).to_markdown(floatfmt=".3f"))

    # G/H. loophole review: original and wording-matched control
    loops = [("loop", expand_loop(df[df.task == "loop"]))]
    if len(dfc):
        loops.append(("loopc", expand_loop(dfc[dfc.task == "loopc"])))
    lrows = []
    for name, L in loops:
        if not len(L):
            continue
        L.to_csv(f"{outdir}/{name}_coded.csv", index=False)
        title = "Loophole review" if name == "loop" else "Loophole review, WORDING-MATCHED CONTROL (identical request text)"
        it = L.groupby("cond")[PLANTED + ["I6b_verbs_undefined"]].mean().T
        R.append(f"## {title}: share finding each planted flaw (mean of two blinded coders)\n\n" +
                 it[[c for c in COND_ORDER if c in it.columns]].to_markdown(floatfmt=".2f"))
        for y in ["I6a_foreign_use", "score", "n_listed"] + PATTERNS:
            R.append(f"### {title}: {y} by model\n\n" + pivot(L, y).to_markdown(floatfmt=".2f"))
        R.append(f"### {title}: patterns, all models\n\n" +
                 L.groupby("cond")[PATTERNS + ["n_listed"]].mean().reindex([c for c in COND_ORDER if c in set(L.cond)]).to_markdown(floatfmt=".2f"))
        # inter-coder agreement
        ag = []
        for k in PLANTED + ["I6b_verbs_undefined"] + PATTERNS:
            a, b = f"{k}|sonnet", f"{k}|opus"
            if a in L and b in L:
                s = L[[a, b]].dropna()
                ag.append(dict(item=k, n=len(s), agree=(s[a] == s[b]).mean(), kappa=kappa(s[a], s[b]),
                               rate_sonnet=s[a].mean(), rate_opus=s[b].mean()))
        if ag:
            R.append(f"### {title}: agreement between the blinded Sonnet and Opus coders\n\n" +
                     pd.DataFrame(ag).to_markdown(index=False, floatfmt=".3f"))
        for y in ["I6a_foreign_use", "score", "n_listed"] + PATTERNS:
            Ly = L.copy()
            if y == "n_listed":
                Ly[y] = np.log(Ly[y].clip(lower=1))
            for by in ([], ["model"]):
                t = ctab(Ly, y, by)
                t["outcome"], t["task"] = (f"log {y}" if y == "n_listed" else y), name
                if not by:
                    t["model"] = "all"
                lrows.append(t)
    if lrows:
        lt = pd.concat(lrows)
        lt.to_csv(f"{outdir}/loop_contrasts.csv", index=False)
        R.append("## Loophole review contrasts: original vs wording-matched control (coder means; p unadjusted)\n\n" +
                 md(lt[lt.model == "all"], ["task", "outcome", "contrast", "est", "lo", "hi", "p", "n_blocks"]))
        R.append("## Loophole review contrasts by model\n\n" +
                 md(lt[lt.model != "all"], ["task", "outcome", "model", "contrast", "est", "lo", "hi", "p", "n_blocks"]))

    # I. item tables
    def items(task, col):
        g = df[(df.task == task) & df[col].apply(lambda x: isinstance(x, dict))]
        rows = [dict(cond=c, **{k: float(v) for k, v in d.items()}) for c, d in zip(g.cond, g[col])]
        it = pd.DataFrame(rows).groupby("cond").mean(numeric_only=True).T
        return it[[c for c in COND_ORDER if c in it.columns]]
    R.append("## Memo items (v2 scorer)\n\n" + items("memo", "caught").to_markdown(floatfmt=".2f"))
    R.append("## Whip items\n\n" + items("whip", "item_correct").to_markdown(floatfmt=".2f"))

    # J. cost
    cost = df.groupby("model")["cost"].sum()
    extra = f"\n\nWording-matched control: ${dfc['cost'].sum():.2f}" if len(dfc) else ""
    R.append("## Cost of subject-model calls (USD, list price)\n\n" + cost.to_markdown(floatfmt=".2f") +
             f"\n\nTotal main + loop: ${df['cost'].sum():.2f}" + extra)

    df.to_csv(f"{outdir}/scored_with_judge.csv", index=False)
    open(f"{outdir}/report.md", "w").write("# Full analysis tables (generated by src/analyze_v2.py)\n\n" + "\n\n".join(R) + "\n")
    print("wrote", f"{outdir}/report.md")


if __name__ == "__main__":
    main()
