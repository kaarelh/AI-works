"""Export responses as plain text and build a manifest of matched pairs for qualitative review.

usage: python3 export_pairs.py <rawdir> <textdir> <manifest.json>

A pair is two responses from the same model, task and replicate (hence the same item
order) under two different principals. Comparisons:
  ban_vs_industry_ai       ai_ban vs ai_industry
  ban_vs_neutral_ai        ai_ban vs ai_neutral
  industry_ai_vs_mining    ai_industry vs mining_industry
  ban_vs_industry_mining   mining_ban vs mining_industry
  miri_vs_ban              ai_ban_miri vs ai_ban
"""
import glob
import json
import os
import random
import sys
from collections import defaultdict

COMPARISONS = {
    "ban_vs_industry_ai": ("ai_ban", "ai_industry"),
    "ban_vs_neutral_ai": ("ai_ban", "ai_neutral"),
    "industry_ai_vs_mining": ("ai_industry", "mining_industry"),
    "ban_vs_industry_mining": ("mining_ban", "mining_industry"),
    "miri_vs_ban": ("ai_ban_miri", "ai_ban"),
}


def main():
    rawdir, textdir, manifest = sys.argv[1:4]
    os.makedirs(textdir, exist_ok=True)
    idx = defaultdict(dict)  # (model, task, rep) -> cond -> path
    for p in sorted(glob.glob(f"{rawdir}/*.json")):
        rec = json.load(open(p))
        j = rec["job"]
        out = f"{textdir}/{j['id']}.txt"
        if not os.path.exists(out):
            principal = j["system"].split("About us: ")[1].split("\n")[0]
            focus = j["system"].split("Current focus: ")[1].split("\n")[0]
            with open(out, "w") as f:
                f.write(f"MODEL: {j['model']}\nTASK: {j['task']}\nCONDITION: {j['cond']}\nREPLICATE: {j['rep']}\n")
                f.write(f"PRINCIPAL: {principal}\nFOCUS: {focus}\n")
                f.write("REQUEST (first 600 chars): " + j["prompt"][:600].replace("\n", " ") + "\n")
                f.write("=" * 80 + "\nRESPONSE:\n" + (rec["result"] or "") + "\n")
        idx[(j["model"], j["task"], j["rep"])][j["cond"]] = out
    pairs = defaultdict(list)
    for (m, t, r), conds in idx.items():
        for name, (a, b) in COMPARISONS.items():
            if a in conds and b in conds:
                pairs[(name, t)].append(dict(model=m, rep=r, a=conds[a], b=conds[b], cond_a=a, cond_b=b))
    rng = random.Random(0)
    out = {}
    for (name, t), lst in pairs.items():
        rng.shuffle(lst)
        out[f"{name}|{t}"] = lst
    json.dump(out, open(manifest, "w"), indent=1)
    print({k: len(v) for k, v in out.items()})


if __name__ == "__main__":
    main()
