"""Compare saved SSWM eval (and baselines) with the NN on HELDOUT and CALIB."""
import os, sys, json
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import numpy as np, common as C
E = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
models = {m: C.load_eval(f"{E}/{m}.npz") for m in ("sswm", "nngp-kernel", "occam-junta") if os.path.exists(f"{E}/{m}.npz")}
out = {}
for opt in ("adam", "sgd"):
    if not any(os.path.exists(os.path.join(C.RESULTS, f"fixed_{opt}_{f}.npz")) for f in C.FNS):
        continue
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB), ("ALL", C.FNS)):
        for name, res in models.items():
            print(f"===== {name} vs NN-{opt} on {split}")
            s = C.compare(res, opt, fns=fns, verbose=(name == "sswm"))
            out[f"{name}|{opt}|{split}"] = {k: v for k, v in s.items() if k not in ("partial_cells",)}
            print(f"   {name:12s} MAE {s['curve_mae']:.3f} scSp {s['sc_spearman']:.2f} sclog {s['sc_mean_abs_log2_ratio']:.2f} "
                  f"succ {s['success_agreement']:.2f} ex {s['example_agreement_score']:.2f} ({s['n_partial_cells']}) "
                  f"tSp {s['time_spearman']:.2f} ({s['n_time_pairs']})")
# NN-SGD as a model of NN-Adam (ceiling)
sgd_fns = [f for f in C.FNS if os.path.exists(os.path.join(C.RESULTS, f"fixed_sgd_{f}.npz"))]
if sgd_fns:
    nres = C.nn_as_model_res("sgd")
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB)):
        s = C.compare(nres, "adam", fns=fns, verbose=False)
        out[f"nn-sgd|adam|{split}"] = {k: v for k, v in s.items() if k not in ("partial_cells",)}
        print(f"   nn-sgd vs adam {split}: MAE {s['curve_mae']:.3f} scSp {s['sc_spearman']:.2f} sclog {s['sc_mean_abs_log2_ratio']:.2f} "
              f"succ {s['success_agreement']:.2f} ex {s['example_agreement_score']:.2f} tSp {s['time_spearman']:.2f}")
json.dump(out, open("/home/user/AI-works/gd-circuit-growth/study/models/scratch_sswm/report.json", "w"), indent=1, default=float)
