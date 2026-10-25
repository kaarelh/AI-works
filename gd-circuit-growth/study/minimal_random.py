"""Out-of-sample test of the analytic predictor and the minimal model on the 20 fresh random formulas (SUITE=random),
with the constants calibrated on CALIB of the main suite, unchanged.  Uses whatever network results exist.
    OPENBLAS_NUM_THREADS=1 python3 minimal_random.py [--model]"""
import os, sys, json
os.environ["SUITE"] = "random"
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import numpy as np, common as C
from boolfuncs import make_random_suite
from minimal_predict import predict_curve
from models.minimal import Minimal
from minimal_report import C_PRED, A_PRED, C_OCC
EV = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
C_MODEL, A_MODEL = [float(v) for v in open(os.path.join(HERE, "minimal_constants.txt")).read().split()]
suite = make_random_suite(30)
fns = [f for f in C.FNS if os.path.exists(os.path.join(C.RESULTS, f"fixed_adam_{f}.npz"))]
if "--model" in sys.argv:
    C.save_eval(C.evaluate(Minimal(c=C_MODEL, a=A_MODEL), fns=fns, seeds=[0, 1], verbose=False), f"{EV}/minimal_random.npz")
cap = 2 * 16384
rows = {}
for fn in fns:
    nn = C.nn_fixed(fn); s = C.sample_complexity(nn["ns"], nn["test_err"].mean(1))
    row = dict(nn=s, pred=predict_curve(fn, C_PRED, A_PRED, 30, suite=suite, first_cross=True)["nstar"],
               occam=predict_curve(fn, C_OCC, 1.0, 30, law="occam", suite=suite, first_cross=True)["nstar"])
    for m, p in (("minimal", f"{EV}/minimal_random.npz"), ("race", f"{EV}/race_random.npz"),
                 ("race_check", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/minimal/race_random_check.npz")):
        if os.path.exists(p):
            r = C.load_eval(p)
            if fn in r["test_err"]:
                row["race" if m == "race_check" else m] = C.sample_complexity(np.array(r["ns"]), r["test_err"][fn].mean(1))
    rows[fn] = row
    print(fn, {k: round(v) if np.isfinite(v) else v for k, v in row.items()}, flush=True)
lr = lambda a, b: abs(np.log2(min(a, cap) / min(b, cap)))
def sp(a, b):
    a, b = np.minimum(a, cap), np.minimum(b, cap); ra = np.argsort(np.argsort(a)); rb = np.argsort(np.argsort(b))
    return float(np.corrcoef(ra, rb)[0, 1])
summ = {}
for k in ("pred", "occam", "minimal", "race"):
    v = [(r["nn"], r[k]) for r in rows.values() if k in r]
    if v:
        summ[k] = dict(n=len(v), mean_abs_log2=float(np.mean([lr(m, n) for n, m in v])), spearman=sp(*map(np.array, zip(*v))))
        print(k, summ[k])
keys = ["sc_mean_abs_log2_ratio", "sc_spearman", "success_agreement", "curve_mae", "example_agreement_score", "time_spearman"]
for m, p in (("minimal", f"{EV}/minimal_random.npz"),
             ("race", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/minimal/race_random_check.npz")):
    if os.path.exists(p):
        b = C.compare(C.load_eval(p), "adam", fns=fns, verbose=False)
        summ[m + "_scoreboard"] = {k: b[k] for k in keys}
        print(m, " ".join(f"{k}={b[k]:.2f}" for k in keys))
json.dump(dict(rows=rows, summary=summ), open(os.path.join(HERE, "minimal_random.json"), "w"), indent=1, default=float)
