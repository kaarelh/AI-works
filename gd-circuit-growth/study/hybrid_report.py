"""Scoreboard rows for study/HYBRID.md: the hybrid model and its ablations against the networks, with the race, the NNGP
kernel and network-vs-network references, using common.compare (the MODEL-SCOREBOARD.md metrics).

    OPENBLAS_NUM_THREADS=1 python hybrid_report.py [eval names ...]
Reads <scratchpad>/model_evals/<name>.npz; writes study/hybrid_scoreboard.json.
"""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from hybrid_diagnose import reinit_res, REINIT

EVALS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
KEYS = [("sc_mean_abs_log2_ratio", "mean abs log2 n* ratio"), ("sc_spearman", "n* Spearman"),
        ("success_agreement", "success agreement"), ("curve_mae", "curve MAE"),
        ("example_agreement_score", "per-example agreement"), ("time_spearman", "time Spearman")]


def main(names):
    res = {m: C.load_eval(os.path.join(EVALS, f"{m}.npz")) for m in names if os.path.exists(os.path.join(EVALS, f"{m}.npz"))}
    board = {}
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB)):
        print(f"\n## {split}\n\n| model | " + " | ".join(k[1] for k in KEYS) + " |\n|---|" + "---|" * len(KEYS))
        for m, r in res.items():
            b = C.compare(r, "adam", fns=fns, verbose=False); board[f"{m}|{split}"] = {k: b[k] for k, _ in KEYS}
            print(f"| {m} | " + " | ".join(f"{b[k]:.2f}" if b[k] == b[k] else "–" for k, _ in KEYS) + " |")
        if split == "HELDOUT":
            refs = [("nn-sgd (same data, same init)", C.nn_as_model_res("sgd", fns=C.HELDOUT))]
            if os.path.exists(os.path.join(REINIT, "fixed_adam_and3.npz")):
                refs.append(("nn-reinit (same data, new init; n <= 2048)", reinit_res()))
            for m, r in refs:
                b = C.compare(r, "adam", fns=C.HELDOUT, verbose=False); board[f"{m}|{split}"] = {k: b[k] for k, _ in KEYS}
                print(f"| *{m}* | " + " | ".join(f"*{b[k]:.2f}*" if b[k] == b[k] else "–" for k, _ in KEYS) + " |")
    fmt = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"
    print("\n## n* per function\n\n| fn | split | NN Adam | " + " | ".join(res) + " |\n|---|---|---|" + "---|" * len(res))
    for fn in C.FNS:
        nn = C.nn_fixed(fn, "adam"); cells = []
        for m, r in res.items():
            e = np.nanmean(r["test_err"][fn], 1); ok = ~np.isnan(e)
            cells.append(fmt(C.sample_complexity(np.array(r["ns"])[ok], e[ok])))
        print(f"| {fn} | {'held-out' if fn in C.HELDOUT else 'calib'} | {fmt(C.sample_complexity(nn['ns'], nn['test_err'].mean(1)))} | "
              + " | ".join(cells) + " |")
    json.dump(board, open(os.path.join(HERE, "hybrid_scoreboard.json"), "w"), indent=1, default=float)


if __name__ == "__main__":
    main(sys.argv[1:] or ["race", "hybrid", "hybrid-static", "nngp-kernel"])
