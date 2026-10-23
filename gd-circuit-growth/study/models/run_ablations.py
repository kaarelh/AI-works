"""Full-grid evaluations of race-model ablations (models/race_ablations.py) at the calibrated constants.

usage: OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python models/run_ablations.py NAME [NAME ...]
Each NAME in ABLATIONS is evaluated on all 21 functions x 11 n x 3 seeds and saved to
  $EVALS/race-abl-NAME.npz      (common.save_eval format)
  $DIAG/race-abl-NAME.json      (per-cell circuit diagnostics: gate counts, true vs spurious gates, orders)
A gate is 'true' if every input coordinate it depends on (through depth-1 wires) is a relevant variable of the target;
the relevant sets are used only here, after fit() has returned.
"""
import os, sys, json, time
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C
from models.race_ablations import RaceAblation

SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
EVALS = os.path.join(SCR, "model_evals"); DIAG = os.path.join(SCR, "ablation_diag")
os.makedirs(DIAG, exist_ok=True)
BASE = dict(theta=1.5, Q=3, gate="relu")          # the calibrated race model
N_ORACLE = int(os.environ.get("N_ORACLE", 16384))

ABLATIONS = {
    "base":       dict(),
    "free":       dict(align="free"),
    "free3":      dict(align="free3"),
    "flat":       dict(align="flat"),
    "K2":         dict(K=2),
    "K3":         dict(K=3),
    "reset-clock": dict(reset="clock"),
    "reset-all":  dict(reset="all"),
    "greedy":     dict(greedy=True),
    "depth1":     dict(depth=1),
    "thr":        dict(gate="thr"),
    "theta0.5":   dict(theta=0.5),
    "theta3":     dict(theta=3.0),
    "theta6":     dict(theta=6.0),
    "theta20":    dict(theta=20.0),
    "Q1":         dict(Q=1),
    "Q2":         dict(Q=2),
    "Q5":         dict(Q=5),
    "P1":         dict(P=1),
    "P32":        dict(P=32),
    "nostop":     dict(stop="none"),
    "oracle-align":  dict(oracle=True, noise="align"),
    "oracle-search": dict(oracle=True, noise="search"),
    # independent search sample of the SAME size n as the training set (oracle=0 means N = n): same noise level,
    # but the noise is no longer correlated with the training labels the readout has to fit
    "indep-search": dict(oracle=0, noise="search"),
    "indep-align":  dict(oracle=0, noise="align"),
}


class Recorder:
    """Wraps a model; records circuit diagnostics of every fit (fn set by the driver)."""
    def __init__(self, model):
        self.m, self.name, self.fn, self.rows = model, model.name, None, []

    def fit(self, X, y, rng):
        r = self.m.fit(X, y, rng)
        rel = set(C.SUITE[self.fn]["relevant"])
        sup = r.get("supports", [])
        true = [s <= rel for s in sup]
        self.rows.append(dict(fn=self.fn, n=len(X), size=r["size"], gates_at_fit=r.get("gates_at_fit"),
                              n_true=int(sum(true)), n_spur=int(len(true) - sum(true)),
                              true_at_fit=int(sum(true[:r.get("gates_at_fit") or 0])),
                              covers=bool(rel <= set().union(*[s for s, t in zip(sup, true) if t])) if any(true) else False,
                              orders=[int(o) for o in r["orders"]], fanin=r["fanin"],
                              time=r["time"], stop_time=r["stop_time"]))
        return r


def run(name):
    cfg = dict(BASE); cfg.update(ABLATIONS[name])
    oracle = cfg.pop("oracle", None)          # None, True (fresh sample of N_ORACLE) or an int N (0: N = n)
    model = RaceAblation(name=f"race-abl-{name}", **cfg)
    rec = Recorder(model)
    t0 = time.time(); res = None
    for fn in C.FNS:
        rec.fn = fn
        if oracle is not None:
            f = C.SUITE[fn]["fn"]
            N = oracle if isinstance(oracle, int) and not isinstance(oracle, bool) else N_ORACLE
            def sample(rng, n, f=f, N=N):
                Xf = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(n if N == 0 else N, C.D))
                return Xf, f(Xf).astype(np.float32)
            model.oracle = sample
        r = C.evaluate(rec, fns=[fn], verbose=True)
        if res is None:
            res = r
        else:
            res["fns"] = res["fns"] + [fn]
            for k in ("test_err", "train_err", "time", "size", "fit_seconds", "pred"):
                res[k][fn] = r[k][fn]
    res["model"] = model.name
    C.save_eval(res, os.path.join(EVALS, f"race-abl-{name}.npz"))
    json.dump(dict(name=name, cfg={k: v for k, v in cfg.items()}, oracle=oracle is not None,
                   n_oracle=None if oracle is None else ("n" if oracle is not True and oracle == 0 else N_ORACLE),
                   seconds=time.time() - t0, rows=rec.rows), open(os.path.join(DIAG, f"race-abl-{name}.json"), "w"))
    for split, fns in (("HELDOUT", C.HELDOUT), ("ALL", C.FNS)):
        s = C.compare(res, "adam", fns=fns, verbose=False)
        print(f"== {name} {split}: log2 {s['sc_mean_abs_log2_ratio']:.2f} rho {s['sc_spearman']:.2f} succ "
              f"{s['success_agreement']:.2f} mae {s['curve_mae']:.3f} ex {s['example_agreement_score']:.2f} "
              f"t_rho {s['time_spearman']:.2f}", flush=True)
    print(f"== {name} done in {time.time() - t0:.0f}s", flush=True)
    return res


if __name__ == "__main__":
    for name in sys.argv[1:]:
        res = run(name)
        if name == "base":       # must reproduce the saved race evaluation exactly
            ref = C.load_eval(os.path.join(EVALS, "race.npz"))
            same = all(np.array_equal(ref["pred"][fn], res["pred"][fn]) for fn in C.FNS)
            print("== base reproduces race.npz predictions exactly:", same, flush=True)
