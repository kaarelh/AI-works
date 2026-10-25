"""Race-model predictions for the composition test, computed BEFORE looking at any network result.

For each target of boolfuncs.make_poly_suite (d = 30), training-set size n and seed, fit the race model (calibrated
constants of the classification study, theta = 1.5, Q = 3, ReLU gates) on exactly the networks' training sets, with
growth stopped when the training MSE falls below 2% of the target's variance (the classification stop rule 'sign error
0' has no meaning for real-valued targets).  Records the test-set Fourier coefficient on x1x2x3x4 and on the pairs,
relative test MSE, and the number of gates.  Writes composition/race_predictions.json.
"""
import os, sys, json, time, itertools, numpy as np
os.environ["SUITE"] = "poly"
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(HERE))
import nn_train as T
from models.race import Race

NS = [int(v) for v in os.environ.get("RACE_NS", "16,32,64,128,256,512,1024,2048,4096,8192,16384").split(",")]
SEEDS = [0, 1, 2]
FNS = sys.argv[1].split(",") if len(sys.argv) > 1 else ["compA", "compB", "compC", "compD", "compE", "compF", "compL"]
OUT = sys.argv[2] if len(sys.argv) > 2 else "race_predictions.json"
CH = {"p1234": (0, 1, 2, 3), "p12": (0, 1), "p34": (2, 3), "p23": (1, 2)}


def race_real(fit):
    cl = {k: c.cell_contents for k, c in zip(fit["predict"].__code__.co_freevars, fit["predict"].__closure__)}
    G, a, c0, relu, d = cl["G_"], cl["a_"], cl["c_"], cl["relu"], cl["d"]
    def score(Z):
        Z = np.asarray(Z, dtype=np.float32)
        W = np.zeros((len(Z), d + len(G)), dtype=np.float32); W[:, :d] = Z; Dz = d
        out = np.full(len(Z), c0)
        for j, (gw, gb, gwire, gsd, gmu) in enumerate(G):
            sz = np.rint(W[:, :len(gw)] @ gw.astype(np.float32)).astype(np.float64)
            ind = (sz > gb).astype(np.float64)
            gv = np.maximum(sz - gb, 0.0) if relu else ind
            if gwire is not None:
                W[:, Dz] = 2 * ind - 1; Dz += 1
            out += a[j] * (gv - gmu) / gsd
        return out
    return score


def main():
    out = dict(time=time.ctime(), note="computed before any composition-test network result was inspected", res={})
    for fn in FNS:
        Xte, yte = T.make_test(fn); var = float(yte.var())
        chi = {k: np.prod(Xte[:, list(S)], 1) for k, S in CH.items()}
        R = out["res"][fn] = {k: np.zeros((len(NS), len(SEEDS))).tolist() for k in list(CH) + ["rel_mse", "gates", "stop_time"]}
        for a_, n in enumerate(NS):
            for b_, s in enumerate(SEEDS):
                X, y = T.make_data(fn, s, n)
                M = Race(theta=1.5, Q=3, gate="relu", stop_mse=0.02 * var)
                fit = M.fit(X, y, np.random.default_rng([s, n, T._fn_seed(fn)]))
                f = race_real(fit)(Xte)
                for k in CH:
                    R[k][a_][b_] = float(np.mean(f * chi[k]))
                R["rel_mse"][a_][b_] = float(np.mean((f - yte) ** 2) / var)
                R["gates"][a_][b_] = fit["size"]; R["stop_time"][a_][b_] = fit["stop_time"]
            print(fn, n, "p1234", np.round(np.mean(R["p1234"][a_]), 3), "rel_mse", np.round(np.mean(R["rel_mse"][a_]), 3),
                  "gates", np.mean(R["gates"][a_]), flush=True)
    out["ns"] = NS; out["seeds"] = SEEDS
    out["d"] = T.D
    json.dump(out, open(os.path.join(HERE, OUT), "w"), indent=1)


if __name__ == "__main__":
    main()
