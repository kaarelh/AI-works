"""Full-grid evaluation of the hybrid model (race + kernel background) at its calibrated setting, and the scoreboard rows.

    OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python models/run_hybrid_eval.py [name] [key=value ...]
Saves <scratchpad>/model_evals/<name>.npz (default name 'hybrid', constants models.hybrid.HYBRID_DEFAULTS).
"""
import os, sys, json, time
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import numpy as np
import common as C
from models.hybrid import Hybrid, HYBRID_DEFAULTS

EVALS = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"

if __name__ == "__main__":
    name = sys.argv[1] if len(sys.argv) > 1 else "hybrid"
    kw = dict(HYBRID_DEFAULTS)
    for a in sys.argv[2:]:
        k, v = a.split("="); kw[k] = None if v == "None" else (float(v) if k in ("rho", "tau", "theta", "lam") else int(v))
    M = Hybrid(**kw); M.name = name
    t0 = time.time()
    res = C.evaluate(M)
    print(f"total {time.time() - t0:.0f}s  constants {kw}")
    C.save_eval(res, os.path.join(EVALS, f"{name}.npz"))
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB)):
        b = C.compare(res, "adam", fns=fns, verbose=False)
        print(f"{split}: n* |log2| {b['sc_mean_abs_log2_ratio']:.2f}  Spearman {b['sc_spearman']:.2f}  success {b['success_agreement']:.2f}  "
              f"curve MAE {b['curve_mae']:.3f}  per-example {b['example_agreement_score']:.2f}  time Spearman {b['time_spearman']:.2f}")
