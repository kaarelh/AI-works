"""Sensitivity analyses for the GPT replication of study 1 (exploratory; README section 5).

usage: python3 src/s1_gpt_sensitivity.py analysis_gpt/scored_with_judge.csv runs/gpt_raw analysis_gpt

Variants of the pooled five-task contrasts (raw score, study 1's estimator; a cell set missing drops its blocks):
  all                        as analysed
  industry refusals missing  the eight judge-coded refusals for the AI lab or the mining company (GPT-6 Luna's
                             scheduling declines, which came under every principal, kept)
  all refusals missing       every judge-coded refusal, Luna's scheduling declines included
  whip parsed                GPT-6 Luna's one whip count without a code block scored as parsed (100%)
  industry refusals missing + whip parsed
  possible tool use missing  the scheduling runs whose input tokens exceed 1.6 x the median for that model and task
                             (extra model requests not in the event log)
Also writes the list of flagged runs and refusal counts with exact tests.
"""
import json
import os
import sys

import numpy as np
import pandas as pd
from scipy.stats import fisher_exact

sys.path.insert(0, os.path.dirname(__file__))
import analyze as A  # noqa: E402

TASKS5 = ["sched", "whip", "memo", "code", "loop"]
KEEP = ["C1 ai_ban - ai_neutral", "C2 ai_ban - ai_industry", "C3 AI-specific stance (interaction)",
        "C5 ai_ban_miri - ai_ban", "C6 mining_ban - mining_industry", "C8 ban - industry (both domains)"]
WHIP_UNPARSED = "whip__ai_industry__gpt-6-luna__r03"


def main():
    scored, rawdir, outdir = sys.argv[1:4]
    df = pd.read_csv(scored, low_memory=False)
    df = df[df.task.isin(TASKS5)].copy()
    df["industry"] = df.cond.str.endswith("industry")
    luna_sched = (df.model == "gpt-6-luna") & (df.task == "sched")
    ref = df.j_refusal == 1
    ind_ref = ref & df.industry & ~luna_sched
    inp = {}
    for rid in df.id:
        u = json.load(open(os.path.join(rawdir, rid + ".json"))).get("usage") or {}
        inp[rid] = u.get("input_tokens")
    df["in_tokens"] = df.id.map(inp)
    med = df.groupby(["model", "task"]).in_tokens.transform("median")
    df["extra_requests"] = df.in_tokens > 1.6 * med
    tool = df.extra_requests & (df.task == "sched")

    def variant(mask_missing=None, parsed=False):
        d = df.copy()
        if parsed:
            d.loc[d.id == WHIP_UNPARSED, "score"] = 1.0
        if mask_missing is not None:
            d.loc[mask_missing.reindex(d.index, fill_value=False), "score"] = np.nan
        t = A.contrast_table(d, "score", [])
        t = t[t.contrast.isin(KEEP)].copy()
        t[["est", "lo", "hi"]] *= 100
        return t

    rows = []
    for name, kw in (("all", {}), ("industry refusals missing", dict(mask_missing=ind_ref)),
                     ("all refusals missing", dict(mask_missing=ref)), ("whip parsed", dict(parsed=True)),
                     ("industry refusals missing + whip parsed", dict(mask_missing=ind_ref, parsed=True)),
                     ("possible tool use missing", dict(mask_missing=tool))):
        t = variant(**kw)
        t.insert(0, "variant", name)
        rows.append(t)
    sens = pd.concat(rows)
    sens.to_csv(f"{outdir}/sensitivity.csv", index=False)

    flagged = df[df.extra_requests][["id", "model", "task", "cond", "in_tokens", "score"]]
    flagged.to_csv(f"{outdir}/possible_tool_use.csv", index=False)
    other = df[(df.task == "sched") & ~df.extra_requests & df.model.isin(flagged.model.unique())]
    tool_scores = pd.DataFrame({"flagged_mean": flagged[flagged.task == "sched"].groupby("model").score.mean(),
                                "flagged_n": flagged[flagged.task == "sched"].groupby("model").size(),
                                "other_mean": other.groupby("model").score.mean()}) * [100, 1, 100]

    two = df.model.isin(["gpt-6-astra", "gpt-6.1-sol"]) & df.task.isin(["code", "sched"])
    side = np.where(df.industry, "industry", np.where(df.cond.isin(["ai_ban", "ai_ban_miri", "mining_ban"]), "ban side", "newsroom"))
    counts = []
    for label, mask in (("GPT-6 Astra + GPT-6.1 Sol, code + sched", two),
                        ("all four GPT models, all tasks, Luna's scheduling excluded", ~luna_sched),
                        ("all four GPT models, all tasks", pd.Series(True, index=df.index))):
        sub = df[mask]
        s = pd.Series(side, index=df.index)[mask]
        c = {k: (int(sub[s == k].j_refusal.sum()), int((s == k).sum())) for k in ("industry", "ban side", "newsroom")}
        ind = c["industry"]
        ban = c["ban side"]
        rest = (ban[0] + c["newsroom"][0], ban[1] + c["newsroom"][1])
        counts.append(dict(subset=label, industry=f"{ind[0]}/{ind[1]}", ban_side=f"{ban[0]}/{ban[1]}",
                           newsroom=f"{c['newsroom'][0]}/{c['newsroom'][1]}",
                           p_industry_vs_ban=fisher_exact([[ind[0], ind[1] - ind[0]], [ban[0], ban[1] - ban[0]]]).pvalue,
                           p_industry_vs_rest=fisher_exact([[ind[0], ind[1] - ind[0]], [rest[0], rest[1] - rest[0]]]).pvalue))
    cnt = pd.DataFrame(counts)
    cnt.to_csv(f"{outdir}/refusal_counts.csv", index=False)
    md = ["# GPT replication of study 1: sensitivity analyses (generated by src/s1_gpt_sensitivity.py)", "",
          "Exploratory. Raw score, percentage points; study 1's estimator (equal weight per block); a response set "
          "missing drops its block from that contrast.", "", sens.to_markdown(index=False, floatfmt=".3f"), "",
          "## Judge-coded refusals by principal group (Fisher exact tests; groups chosen after reading the data)", "",
          cnt.to_markdown(index=False, floatfmt=".4f"), "",
          "## Runs with extra, unlogged model requests (input tokens > 1.6 x the model-task median)", "",
          flagged.to_markdown(index=False), "", "Scheduling scores of flagged and other runs, same models:", "",
          tool_scores.to_markdown(floatfmt=".1f"), ""]
    open(f"{outdir}/sensitivity.md", "w").write("\n".join(md))
    print("wrote", f"{outdir}/sensitivity.md")


if __name__ == "__main__":
    main()
