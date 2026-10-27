"""Render the referee records in raw/ as Markdown reports in reports/.

raw/round1_batch1.json, raw/round1_batch23.json
    first-round referee reports, keyed 'referee:<topic>:<lens>'
raw/round1_fixes_and_rereviews.json
    the fixers' reports and the independent re-reviews of their fixes
raw/new_results_integration.json
    integration of the local-threshold and affine results, their two
    referee reports each, and the fixes
raw/round2_consolidation.json
    the consolidation round (residual findings and cross-file edits)
raw/round3_final_referee.json
    the final round: a fresh referee per topic with an audit of how every
    earlier finding was resolved
raw/round3_final_fixes.json
    the fixes made after the final round
"""

import json
import os
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "raw")
OUT = os.path.join(HERE, "reports")


def load(name):
    path = os.path.join(RAW, name)
    return json.load(open(path)) if os.path.exists(path) else None


def clean(s) -> str:
    return str(s).replace("\r", "")


def findings_md(fs):
    out = []
    for i, f in enumerate(fs, 1):
        out += [f"### {i}. [{f['severity']}] {clean(f['location'])}", "",
                f"**Problem.** {clean(f['problem'])}", "", f"**Proposed fix.** {clean(f['fix'])}", ""]
    return out


def write(name, lines):
    open(os.path.join(OUT, name), "w").write("\n".join(lines) + "\n")


def main():
    os.makedirs(OUT, exist_ok=True)
    summary = []
    # round 1
    r1 = {}
    for n in ("round1_batch1.json", "round1_batch23.json"):
        r1.update(load(n) or {})
    for label in sorted(r1):
        r = r1[label]
        _, topic, lens = label.split(":")
        write(f"round1-{topic}-{lens}.md",
              [f"# Round 1 referee report: {topic} ({lens} lens)", "", f"**Verdict.** {clean(r['verdict'])}", "",
               f"**What was checked.** {clean(r['checked'])}", "", "## Findings", ""] + findings_md(r["findings"]))
        c = Counter(f["severity"] for f in r["findings"])
        summary.append(("round 1", topic, lens, c, r["verdict"]))
    # fixes and re-reviews
    fx = load("round1_fixes_and_rereviews.json") or {}
    for topic, v in sorted(fx.items()):
        lines = [f"# Fix round: {topic}", "", "## Fixer's summary", "", clean(v["fix"]["summary"]), "",
                 "## Findings resolved", ""]
        lines += [f"- {clean(x['finding'])}: {clean(x['action'])}" for x in v["fix"]["resolved"]]
        lines += ["", "## Not changed, with reasons", ""]
        lines += [f"- {clean(x['finding'])}: {clean(x['reason'])}" for x in v["fix"]["not_fixed"]] or ["- (none)"]
        rv = v.get("review")
        if rv:
            lines += ["", "## Independent re-review", "", f"**Verdict.** {clean(rv['verdict'])}", ""]
            lines += [f"- [{x['status']}] {clean(x['finding'])}: {clean(x['note'])}" for x in rv["resolution"]]
            lines += ["", "### New findings of the re-review", ""] + findings_md(rv["new_findings"])
        write(f"fix1-{topic}.md", lines)
    # integration of new results
    for t in load("new_results_integration.json") or []:
        lines = [f"# New results: {t['key']}", "", "## Integration report", "", clean(t["integ"]["summary"]), ""]
        lines += [f"- {clean(x['result'])} ({clean(x['status'])}): {clean(x['note'])}" for x in t["integ"]["included"]]
        for r in t["refs"]:
            lines += ["", "## Referee report", "", f"**Verdict.** {clean(r['verdict'])}", ""] + findings_md(r["findings"])
            c = Counter(f["severity"] for f in r["findings"])
            summary.append(("integration", t["key"], "referee", c, r["verdict"]))
        lines += ["", "## Fixes", "", clean(t["fix"]["summary"])]
        write(f"new-{t['key']}.md", lines)
    # round 2
    r2 = load("round2_consolidation.json") or []
    lines = ["# Round 2: consolidation", ""]
    for o in r2:
        lines += [f"## {o['key']}", "", clean(o["summary"]), ""]
        lines += [f"- {clean(x['item'])}: {clean(x['action'])}" for x in o["resolved"]]
        lines += [""]
    write("round2-consolidation.md", lines)
    # final round
    fin = load("round3_final_referee.json") or []
    for r in fin:
        st = Counter(x["status"] for x in r["resolution"])
        lines = [f"# Final referee report: {r['topic']}", "", f"**Verdict.** {clean(r['verdict'])}", "",
                 f"**What was checked.** {clean(r['checked'])}", "",
                 "## Audit of earlier findings", "", ", ".join(f"{k}: {v}" for k, v in st.items()), ""]
        lines += [f"- [{x['status']}] ({x['severity']}) {clean(x['finding'])}: {clean(x['note'])}" for x in r["resolution"]]
        lines += ["", "## New findings", ""] + findings_md(r["findings"])
        write(f"round3-final-{r['topic']}.md", lines)
        summary.append(("final", r["topic"], "audit + fresh review", Counter(f["severity"] for f in r["findings"]),
                        r["verdict"]))
    ff = load("round3_final_fixes.json") or []
    if ff:
        lines = ["# Fixes after the final round", ""]
        for o in ff:
            lines += [f"## {o['key']}", "", clean(o["summary"]), ""]
            lines += [f"- {clean(x['item'])}: {clean(x['action'])}" for x in o["resolved"]]
            lines += [f"- not done: {clean(x['item'])}: {clean(x['reason'])}" for x in o["not_done"]]
            lines += [""]
        write("round3-final-fixes.md", lines)
    json.dump([dict(round=a, topic=b, lens=c, counts=dict(d), verdict=e) for a, b, c, d, e in summary],
              open(os.path.join(HERE, "summary.json"), "w"), indent=1)
    for a, b, c, d, e in summary:
        print(f"{a:12s} {b:18s} {c:22s} {dict(d)}")


if __name__ == "__main__":
    main()
