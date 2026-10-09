"""Agreement between the primary loop judge (Sonnet) and a second judge (Opus) on a sample.

usage: python3 judge_agreement.py <judge_dir_A> <judge_dir_B> <out.md>
"""
import glob
import json
import os
import sys

import numpy as np


def kappa(a, b):
    a, b = np.asarray(a), np.asarray(b)
    po = (a == b).mean()
    pa, pb = a.mean(), b.mean()
    pe = pa * pb + (1 - pa) * (1 - pb)
    return (po - pe) / (1 - pe) if pe < 1 else float("nan")


def main():
    da, db, out = sys.argv[1:4]
    rows = []
    for pb in glob.glob(f"{db}/*.json"):
        rid = os.path.basename(pb)[:-5]
        pa = f"{da}/{rid}.json"
        if not os.path.exists(pa):
            continue
        A, B = json.load(open(pa)), json.load(open(pb))
        for k in (A.get("found") or {}):
            rows.append((rid, rid.split("__")[1], k, int(bool(A["found"].get(k))), int(bool((B.get("found") or {}).get(k)))))
    if not rows:
        print("no overlap")
        return
    a = [r[3] for r in rows]
    b = [r[4] for r in rows]
    lines = [f"# Loop judge agreement (Sonnet vs Opus)\n",
             f"responses: {len(set(r[0] for r in rows))}, item judgements: {len(rows)}",
             f"raw agreement: {np.mean(np.array(a) == np.array(b)):.3f}",
             f"Cohen's kappa: {kappa(a, b):.3f}",
             f"found rate Sonnet {np.mean(a):.3f} vs Opus {np.mean(b):.3f}", "",
             "| item | agree | Sonnet found | Opus found |", "|---|---|---|---|"]
    for k in sorted(set(r[2] for r in rows), key=lambda s: int(s.split("_")[0][1:])):
        rr = [r for r in rows if r[2] == k]
        lines.append(f"| {k} | {np.mean([r[3] == r[4] for r in rr]):.2f} | {np.mean([r[3] for r in rr]):.2f} | {np.mean([r[4] for r in rr]):.2f} |")
    lines += ["", "| condition | n items | agree | Sonnet−Opus found rate |", "|---|---|---|---|"]
    for c in sorted(set(r[1] for r in rows)):
        rr = [r for r in rows if r[1] == c]
        lines.append(f"| {c} | {len(rr)} | {np.mean([r[3] == r[4] for r in rr]):.2f} | {np.mean([r[3] - r[4] for r in rr]):+.2f} |")
    open(out, "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
