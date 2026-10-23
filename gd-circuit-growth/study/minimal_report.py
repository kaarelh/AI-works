"""Tables for MINIMAL-MODEL.md: the analytic predictor (minimal_predict.py) and the minimal model's evaluations against the
networks, at d = 30 (21 targets) and in the d-scaling study (d = 15, 30, 60; 7 targets).  Writes minimal_report.json.
    OPENBLAS_NUM_THREADS=1 python3 minimal_report.py"""
import os, sys, json, math, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from minimal_predict import predict_curve, bottleneck

EV = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
SP = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
C_PRED, A_PRED = 2.25, 18.0          # predictor constants (CALIB argmin, search law)
C_OCC = 9.0                           # Occam-law predictor constant (CALIB argmin)
C_NOLEAP = 2.5                        # predictor without the leap cost (a = infinity): CALIB argmin over c
DS = ["par2", "par3", "par4", "stair5", "mux", "majpar", "maj9"]
cap = 2 * 16384


def nn_nstar(fn, d):
    os.environ["DIM"] = str(d)
    res = SP + "/results" + ("" if d == 30 else f"_d{d}")
    p = os.path.join(res, f"fixed_adam_{fn}.npz")
    if not os.path.exists(p):
        return None
    z = np.load(p)
    ns, seeds = list(z["ns"]), list(z["seeds"])
    te = np.zeros((len(ns), len(seeds)))
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
    for a, n in enumerate(ns):
        for b in range(len(seeds)):
            te[a, b] = z["test_err"][-1, I[(int(n), b)]]
    return C.sample_complexity(np.array(ns), te.mean(1))


def model_nstar(path, fn):
    if not os.path.exists(path):
        return None
    r = C.load_eval(path)
    if fn not in r["test_err"]:
        return None
    return C.sample_complexity(np.array(r["ns"]), r["test_err"][fn].mean(1))


def main():
    out = dict(c_pred=C_PRED, a_pred=A_PRED, c_occam=C_OCC, d30={}, dscale={})
    for fn in C.FNS:
        b = bottleneck(fn, C_PRED, A_PRED, 30)
        oc = predict_curve(fn, C_OCC, 1.0, 30, law="occam", first_cross=True)["nstar"]
        curve = predict_curve(fn, C_PRED, A_PRED, 30, ns=[float(v) for v in C.NS])["err"]
        nnz = C.nn_fixed(fn)
        nn_curve = nnz["test_err"].mean(1)
        out["d30"][fn] = dict(nn=nn_nstar(fn, 30), pred=b["n_curve"] if "n_curve" in b else b["nstar"], closed=b["nstar"],
                              n_hebb=b["n_hebb"], n_gate=b["n_gate"], binding=b["binding"], occam=oc,
                              path=[{k: s[k] for k in ("depth", "f", "k", "rho2", "N", "n_thr", "err", "dense")} for s in b["stages"]],
                              split="held-out" if fn in C.HELDOUT else "calib",
                              model=model_nstar(f"{EV}/minimal.npz", fn), race=model_nstar(f"{EV}/race.npz", fn),
                              pred_curve=list(curve), nn_curve=list(nn_curve))
        print(fn, out["d30"][fn]["nn"], round(out["d30"][fn]["pred"]), b["binding"], flush=True)
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB)):
        P = np.array([out["d30"][f]["pred_curve"] for f in fns]); Q = np.array([out["d30"][f]["nn_curve"] for f in fns])
        out[f"pred_curve_{split}"] = dict(curve_mae=float(np.mean(np.abs(P - Q))),
                                          success_agreement=float(np.mean((P <= 0.1) == (Q <= 0.1))))
        print(split, out[f"pred_curve_{split}"])
    for fn in DS:
        row = {}
        for d in (15, 30, 60):
            sfx = "" if d == 30 else f"_d{d}"
            row[d] = dict(nn=nn_nstar(fn, d), pred=predict_curve(fn, C_PRED, A_PRED, d, first_cross=True)["nstar"],
                          occam=predict_curve(fn, C_OCC, 1.0, d, law="occam", first_cross=True)["nstar"],
                          noleap=predict_curve(fn, C_NOLEAP, 1e9, d, first_cross=True)["nstar"],
                          model=model_nstar(f"{EV}/minimal{sfx}.npz", fn), race=model_nstar(f"{EV}/race{sfx}.npz", fn))
        out["dscale"][fn] = row
        print(fn, row, flush=True)
    json.dump(out, open(os.path.join(HERE, "minimal_report.json"), "w"), indent=1, default=float)


if __name__ == "__main__":
    main()
