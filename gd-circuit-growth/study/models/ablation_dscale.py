"""d = 15 vs d = 30 for the key race ablations (models/run_ablations.py with DIM=15): n* and its d-exponent, and the
d-dependence of the time to generalise far above n* (median over n >= 4096), against the networks.
usage: python models/ablation_dscale.py base free greedy flat ..."""
import os, sys, importlib
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EVALS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
FNS = ["par2", "par3", "par4", "stair5", "mux", "majpar", "maj9"]


def load_dim(dim, names):
    os.environ["DIM"] = str(dim)
    import common
    C = importlib.reload(common)
    nn = {fn: C.nn_fixed(fn, "adam") for fn in FNS}
    out = {"NN": {fn: (C.sample_complexity(nn[fn]["ns"], nn[fn]["test_err"].mean(1)),
                       np.nanmedian(np.where(np.isfinite(nn[fn]["steps_to_gen"][-3:]), nn[fn]["steps_to_gen"][-3:], np.nan)))
                  for fn in FNS}}
    for nm in names:
        p = os.path.join(EVALS, f"race-abl-{nm}{'' if dim == 30 else f'-d{dim}'}.npz")
        if not os.path.exists(p):
            continue
        r = C.load_eval(p); ns = np.array(r["ns"]); big = ns >= 4096
        out[nm] = {fn: (C.sample_complexity(ns, np.nanmean(r["test_err"][fn], 1)),
                        np.nanmedian(np.where(r["test_err"][fn][big] <= 0.1, r["time"][fn][big], np.nan))) for fn in FNS}
    return out


if __name__ == "__main__":
    names = sys.argv[1:]
    A, B = load_dim(15, names), load_dim(30, names)
    keys = [k for k in A if k in B]
    fmt = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"
    print("n* at d = 15 / 30 and exponent log2(n*30/n*15):\n")
    print("| fn | " + " | ".join(keys) + " |"); print("|---|" + "---|" * len(keys))
    for fn in FNS:
        print(f"| {fn} | " + " | ".join(f"{fmt(A[k][fn][0])} / {fmt(B[k][fn][0])} ({np.log2(B[k][fn][0] / A[k][fn][0]):.2f})" for k in keys) + " |")
    print("\nmean |log2 n*_model / n*_NN| at d = 15 (7 targets): " +
          ", ".join(f"{k} {np.mean([abs(np.log2(min(A[k][fn][0], 32768) / A['NN'][fn][0])) for fn in FNS]):.2f}" for k in keys if k != "NN"))
    print("mean |exponent_model - exponent_NN|: " + ", ".join(
        f"{k} {np.mean([abs(np.log2(min(B[k][fn][0], 32768) / min(A[k][fn][0], 32768)) - np.log2(B['NN'][fn][0] / A['NN'][fn][0])) for fn in FNS]):.2f}"
        for k in keys if k != "NN"))
    print("\ntime to generalise far above n* (median over n >= 4096), ratio d=30 / d=15:\n")
    print("| fn | " + " | ".join(keys) + " |"); print("|---|" + "---|" * len(keys))
    for fn in FNS:
        print(f"| {fn} | " + " | ".join(f"{B[k][fn][1] / A[k][fn][1]:.2f}" for k in keys) + " |")
