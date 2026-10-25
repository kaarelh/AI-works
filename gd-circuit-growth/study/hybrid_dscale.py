"""The hybrid at d = 15 and d = 60, constants unchanged (study/HYBRID.md, section 3), against the d-scaling networks
(par2, par3, par4, stair5, mux, majpar, maj9; 2 seeds; see DSCALE.md), next to the race and the NNGP kernel.

    DIM=15 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python hybrid_dscale.py run
    DIM=60 NS_MAX=65536 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python hybrid_dscale.py run
    DIM=15 python hybrid_dscale.py ; DIM=60 NS_MAX=65536 python hybrid_dscale.py      # tables only
Saves <scratchpad>/model_evals/hybrid_d<DIM>.npz.
"""
import os, sys, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from models.hybrid import Hybrid, HYBRID_DEFAULTS

EVALS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
FNS = ["par2", "par3", "par4", "stair5", "mux", "majpar", "maj9"]

if __name__ == "__main__":
    path = os.path.join(EVALS, f"hybrid_d{C.D}.npz")
    if len(sys.argv) > 1 and sys.argv[1] == "run":
        M = Hybrid(**HYBRID_DEFAULTS); M.name = f"hybrid-d{C.D}"
        C.save_eval(C.evaluate(M, fns=FNS, seeds=[0, 1]), path)
    fmt = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"
    res = {m: C.load_eval(os.path.join(EVALS, f"{m}_d{C.D}.npz")) for m in ("race", "hybrid", "nngp-kernel")
           if os.path.exists(os.path.join(EVALS, f"{m}_d{C.D}.npz"))}
    print(f"d = {C.D}\n\n| model | n* error | n* Spearman | success agreement | curve MAE | per-example agreement |\n|---|---|---|---|---|---|")
    for m, r in res.items():
        b = C.compare(r, "adam", fns=FNS, verbose=False)
        print(f"| {m} | {b['sc_mean_abs_log2_ratio']:.2f} | {b['sc_spearman']:.2f} | {b['success_agreement']:.2f} | "
              f"{b['curve_mae']:.3f} | {b['example_agreement_score']:.2f} |")
    print("\n| target | networks | " + " | ".join(res) + " |\n|---|---|" + "---|" * len(res))
    for fn in FNS:
        nn = C.nn_fixed(fn)
        cells = []
        for m, r in res.items():
            e = np.nanmean(r["test_err"][fn], 1); ok = ~np.isnan(e)
            cells.append(fmt(C.sample_complexity(np.array(r["ns"])[ok], e[ok])))
        print(f"| {fn} | {fmt(C.sample_complexity(nn['ns'], nn['test_err'].mean(1)))} | " + " | ".join(cells) + " |")
