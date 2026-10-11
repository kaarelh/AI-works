"""Pilot report for study 2: cost, headroom, refusal hints, metric choice inputs.

usage: python3 src/s2_pilot.py runs2/pilot/raw [out.md]
"""
import glob
import json
import os
import sys

import pandas as pd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import s2_analysis  # noqa: E402
import s2_fidelity  # noqa: E402
import s2_judge  # noqa: E402
import s2_petition  # noqa: E402
import s2_quant  # noqa: E402

MOD = {"analysis": s2_analysis, "petition": s2_petition, "quant": s2_quant, "fidelity": s2_fidelity}


def load(rawdir):
    rows = []
    for p in sorted(glob.glob(f"{rawdir}/*.json")):
        if os.path.basename(p).startswith("_"):
            continue
        r = json.load(open(p))
        j = r["job"]
        u = r.get("usage") or {}
        row = dict(id=j["id"], context=j["context"], arm=j["arm"], model=j["model"], rep=j["rep"],
                   cost=r.get("cost") or 0, out_tok=u.get("output_tokens"),
                   think_tok=(u.get("output_tokens_details") or {}).get("thinking_tokens"),
                   served=r.get("served_model"), wall=r.get("wall"), text=r["result"] or "")
        kind = (j.get("meta") or {}).get("kind")
        if j["unit"].startswith("identity__"):
            row["kind"] = "identity"
            row.update(s2_judge.score_probe(r, j))
        elif kind == "probe":
            row["kind"] = "credence"
            row["credence"] = s2_fidelity.parse_credence(row["text"])[0]
            row["claim_id"] = j["meta"]["claim_id"]
            row["side"] = j["meta"]["side"]
        else:
            row["kind"] = "task"
            row.update({f"s_{k}": v for k, v in MOD[j["context"]].score(j, row["text"]).items()})
        rows.append(row)
    return pd.DataFrame(rows)


def main():
    rawdir = sys.argv[1]
    df = load(rawdir)
    for c in df.columns:
        if df[c].dtype == object and c not in ("text", "id", "context", "arm", "model", "served", "kind", "claim_id", "side"):
            vals = df[c].dropna()
            if len(vals) and all(isinstance(v, (bool, int, float)) for v in vals):
                df[c] = df[c].map(lambda v: float(v) if v is not None and not (isinstance(v, float) and v != v) else float("nan"))
    out = []
    pd.set_option("display.width", 250)
    out.append(f"# Study 2 pilot report\n\n{len(df)} records, total cost ${df.cost.sum():.2f}\n")
    bad = df[df.served.notna() & (df.served != df.model)]
    out.append(f"served-model mismatches: {len(bad)}\n")
    out.append("## Cost per call (USD, mean) by context x model\n")
    out.append(df.pivot_table(index=["context", "kind"], columns="model", values="cost", aggfunc="mean").round(3).to_markdown())
    out.append("\n## Output tokens (mean)\n")
    out.append(df.pivot_table(index=["context", "kind"], columns="model", values="out_tok", aggfunc="mean").round(0).to_markdown())
    t = df[df.kind == "task"]
    a = t[t.context == "analysis"]
    if len(a):
        out.append("\n## Ctx 1 analysis: ITT score (of 1) and regex refusal hint\n")
        out.append(a.pivot_table(index="arm", columns="model", values="s_itt_score", aggfunc="mean").round(2).to_markdown())
        out.append("\n" + a.pivot_table(index="arm", columns="model", values="s_rx_refusal", aggfunc="mean").round(2).to_markdown())
    q = t[t.context == "quant"]
    if len(q):
        out.append("\n## Ctx 3 quant: core errors (of 24), hard correct (of 3), score %, verbalised strategy\n")
        for v in ["s_core_errors", "s_hard_correct", "s_score_pct", "s_verbalised_strategy"]:
            if v in q:
                out.append(f"\n{v}\n" + q.pivot_table(index="arm", columns="model", values=v, aggfunc="mean").round(2).to_markdown())
        items = [c for c in q.columns if c.startswith("s_") and c.endswith("_correct") and c[2] in "EMH" and c[3:5].isdigit()]
        acc = q[q.arm.isin(["neutral", "elicit"])][items].mean().sort_values()
        out.append("\nper-item accuracy under neutral+elicit (lowest 10):\n" + acc.head(10).round(2).to_markdown())
    p = t[t.context == "petition"]
    if len(p):
        out.append("\n## Ctx 2 petition: keyword recall (of 1), items listed\n")
        out.append(p.pivot_table(index="arm", columns="model", values="s_recall_kw", aggfunc=["mean", "std"]).round(2).to_markdown())
        out.append("\n" + p.pivot_table(index="arm", columns="model", values="s_n_items", aggfunc="mean").round(1).to_markdown())
        kw = [c for c in p.columns if c.startswith("s_kw_W")]
        out.append("\nper-item keyword hit rate:\n" + p[kw].mean().round(2).to_frame("hit").T.to_markdown())
    f = t[t.context == "fidelity"]
    if len(f):
        out.append("\n## Ctx 4 fidelity: candidate metrics pooled (pilot rule: first in [0.10, 0.90])\n")
        out.append(f[["s_share_asserted", "s_soft_note", "s_hedge_density"]].mean().round(3).to_frame("pooled mean").to_markdown())
        out.append("\nby side x model (share asserted):\n" + f.pivot_table(index="s_side", columns="model", values="s_share_asserted", aggfunc="mean").round(2).to_markdown())
        out.append("\nby side x model (soft note):\n" + f.pivot_table(index="s_side", columns="model", values="s_soft_note", aggfunc="mean").round(2).to_markdown())
        out.append("\nrefusal (lexicon full/partial):\n" + f.pivot_table(index="s_side", columns="model", values=["s_refusal_full", "s_refusal_partial"], aggfunc="mean").round(2).to_markdown())
    c = df[df.kind == "credence"]
    if len(c):
        out.append("\n## Credence probes (0-100), mean by claim x model\n")
        out.append(c.pivot_table(index=["side", "claim_id"], columns="model", values="credence", aggfunc="mean").round(0).to_markdown())
        out.append(f"\nunparsed credences: {c.credence.isna().sum()}")
    i = df[df.kind == "identity"]
    if len(i):
        out.append("\n## Identity probes\n")
        cols = [x for x in i.columns if x in ("identity_ok", "other_developer", "other_claude_model")]
        out.append(i[["model", "context"] + cols + ["text"]].assign(text=i.text.str[:90]).to_markdown(index=False))
    rep = "\n".join(out)
    if len(sys.argv) > 2:
        open(sys.argv[2], "w").write(rep)
    print(rep)


if __name__ == "__main__":
    main()
