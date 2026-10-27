"""Render the referee records in raw/*.json as Markdown reports.

raw/round1_*.json   first-round referee reports, keyed 'referee:<topic>:<lens>'
raw/fixes.json      the fixers' reports and the second-round re-reviews
raw/resolution.json the final audit: status of every first-round finding
"""

import json
import os
from glob import glob

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "reports")


def md_escape(s: str) -> str:
    return s.replace("\r", "")


def render_round1():
    reports = {}
    for f in sorted(glob(os.path.join(HERE, "raw", "round1_*.json"))):
        reports.update(json.load(open(f)))
    os.makedirs(OUT, exist_ok=True)
    rows = []
    for label in sorted(reports):
        r = reports[label]
        _, topic, lens = label.split(":")
        sev = [f["severity"] for f in r["findings"]]
        counts = {s: sev.count(s) for s in ("critical", "major", "minor")}
        rows.append((topic, lens, r["verdict"], counts))
        lines = [f"# Referee report: {topic} ({lens} lens)", "", f"**Verdict.** {md_escape(r['verdict'])}", "",
                 f"**What was checked.** {md_escape(r['checked'])}", "", "## Findings", ""]
        for i, f in enumerate(r["findings"], 1):
            lines += [f"### {i}. [{f['severity']}] {md_escape(f['location'])}", "",
                      f"**Problem.** {md_escape(f['problem'])}", "", f"**Proposed fix.** {md_escape(f['fix'])}", ""]
        open(os.path.join(OUT, f"round1-{topic}-{lens}.md"), "w").write("\n".join(lines))
    return rows


if __name__ == "__main__":
    rows = render_round1()
    for t, l, v, c in rows:
        print(f"{t:18s} {l:15s} {c}")
