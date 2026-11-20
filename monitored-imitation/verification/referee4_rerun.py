"""Referee 4: independent re-run of the n = 16 and n = 64 cells of E6 (slack-imitation.md).

Calls one_human and one_human_verifier from code/slack_imitation.py with exactly the seeds,
caps and configurations of main() / main_verifier(), for n in {16, 64}, all five kinds, and
the protocols CI (sigma = 0), CI (sigma = n/2, "SI"), LAST, MIX and SI-V. Writes the re-run to
verification/referee4_rerun/rerun_n16_n64.json and prints a cell-by-cell comparison with the
saved results/slack_imitation_summary.json, _mix.json and _verifier.json.

Usage (from anywhere): python3 referee4_rerun.py
"""

import json
import os
import sys
import time
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, "code"))
import slack_imitation as si  # noqa: E402

import numpy as np  # noqa: E402

OUT = os.path.join(HERE, "referee4_rerun")


def main():
    os.makedirs(OUT, exist_ok=True)
    H = 40
    out = {}
    t0 = time.time()
    with Pool(4) as pool:
        for n in [16, 64]:
            for kind in si.KINDS:
                for sigma, proto in [(0, "CI"), (n // 2, "CI"), (n // 2, "LAST"), (n // 2, "MIX")]:
                    cap = 400 * si.M if proto == "LAST" else 40 * si.M * n
                    args = [(kind, n, sigma, proto, 1000 * n + s, cap) for s in range(H)]
                    rows = pool.map(si.one_human, args)
                    key = f"{kind}_n{n}_sigma{sigma}_{proto}"
                    out[key] = dict(kind=kind, n=n, sigma=sigma, protocol=proto, **si.summarise(rows))
                    print(key, f"[{time.time() - t0:.0f}s]", flush=True)
                rows = pool.map(si.one_human_verifier, [(kind, n, n // 2, 1000 * n + s) for s in range(H)])
                q = np.array([r[0] for r in rows], dtype=float)
                rej = np.array([r[1] for r in rows], dtype=float)
                key = f"{kind}_n{n}_sigma{n // 2}_SIV"
                out[key] = dict(kind=kind, n=n, sigma=n // 2, protocol="SI-V", humans=H,
                                task_mean=float(q.mean()), task_sem=float(q.std(ddof=1) / np.sqrt(H)),
                                rejected_mean=float(rej.mean()),
                                queries_per_rejection=float(q.sum() / max(rej.sum(), 1)),
                                worst_search=int(max(r[2] for r in rows)))
                print(key, f"[{time.time() - t0:.0f}s]", flush=True)
    with open(os.path.join(OUT, "rerun_n16_n64.json"), "w") as f:
        json.dump(out, f, indent=1)

    saved = {}
    for name in ["slack_imitation_summary.json", "slack_imitation_mix.json", "slack_imitation_verifier.json"]:
        with open(os.path.join(ROOT, "results", name)) as f:
            saved.update(json.load(f))
    print("\nComparison with the saved results (identical seeds, so values should agree exactly):")
    bad = 0
    for key, r in out.items():
        s = saved.get(key)
        if s is None:
            print(f"{key}: not in saved results")
            bad += 1
            continue
        fields = [k for k in r if isinstance(r[k], (int, float)) and k in s]
        diffs = {k: (s[k], r[k]) for k in fields if abs(float(s[k]) - float(r[k])) > 1e-9}
        status = "MATCH" if not diffs else f"DIFF {diffs}"
        if diffs:
            bad += 1
        print(f"{key:32s} saved {s['task_mean']:>10.2f}  rerun {r['task_mean']:>10.2f}  {status}")
    print(f"\ncells compared: {len(out)}, cells differing: {bad}, total time {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main()
