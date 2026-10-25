"""Pre-registered d = 120 predictions (written before any d = 120 network was trained).
Models use their d = 30 CALIB constants unchanged:
  * analytic predictor (minimal_predict.predict_curve, c = 2.25, a = 18, first_cross as in minimal_report.py);
    also the Occam law (c = 9) and no-leap (c = 2.5, a = inf) variants;
  * race model Race(theta=1.5, Q=3, gate='relu'), 4 internal random streams (RaceAblation reseed 0..3), 2 seeds,
    on exactly the training sets the d = 120 networks will see (common.train_data with DIM=120, NS_MAX=65536).
Run: DIM=120 NS_MAX=65536 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python3 predict_d120.py
"""
import os, sys, json, time
import numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.path.insert(0, STUDY)
import common as C
import minimal_predict as P
from models.race_ablations import RaceAblation

OUT = os.path.dirname(os.path.abspath(__file__))
EV = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
assert C.D == 120
NSD = {"par2": [64, 128, 256, 512, 1024, 2048, 4096, 8192],
       "maj9": [64, 128, 256, 512, 1024, 2048, 4096, 8192],
       "par3": [512, 1024, 2048, 4096, 8192, 16384, 32768, 65536],
       "mux": [256, 512, 1024, 2048, 4096, 8192, 16384, 32768]}
out = dict(time=time.ctime(), pred={}, race={})
for fn in NSD:
    out["pred"][fn] = dict(search=P.predict_curve(fn, 2.25, 18.0, 120, first_cross=True)["nstar"],
                           occam=P.predict_curve(fn, 9.0, 1.0, 120, law="occam", first_cross=True)["nstar"],
                           noleap=P.predict_curve(fn, 2.5, 1e9, 120, first_cross=True)["nstar"])
    print(fn, "predictor", {k: round(v) for k, v in out["pred"][fn].items()}, flush=True)
for k in range(4):
    for fn, ns in NSD.items():
        t0 = time.time()
        res = C.evaluate(RaceAblation(reseed=k, theta=1.5, Q=3, gate="relu", name=f"race-d120-s{k}"),
                         fns=[fn], ns=ns, seeds=[0, 1], verbose=False)
        C.save_eval(res, f"{EV}/race-d120-s{k}-{fn}.npz")
        te = res["test_err"][fn].mean(1)
        ns_ = C.sample_complexity(np.array(ns), te)
        out["race"].setdefault(fn, {})[k] = dict(nstar=ns_, curve=[float(v) for v in te])
        print(fn, "race stream", k, round(ns_) if np.isfinite(ns_) else "never", " ".join(f"{v:.2f}" for v in te),
              f"({time.time() - t0:.0f}s)", flush=True)
json.dump(out, open(f"{OUT}/predictions_d120.json", "w"), indent=1, default=float)
print("saved", time.ctime())
