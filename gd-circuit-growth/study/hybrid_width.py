"""Width check of the background picture (study/HYBRID.md): per-example agreement of the kernel, the race and the hybrid
with networks of width 32, 128 and 512 (fixed protocol, Adam; width sweep on par3, maj9, mux, stair5, seeds 0-1).

If the networks' individual mistakes come from a random-feature background, the infinite-width NNGP kernel should
agree more with wider networks.  Partial cells are those of each width's own networks.

    OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python hybrid_width.py
"""
import os, sys, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from models.race import Race
from models.hybrid import Hybrid, HYBRID_DEFAULTS
from models.baselines import NNGPKernel

S = os.path.dirname(C.RESULTS)
FNS = ["par3", "maj9", "mux", "stair5"]


def load(width, fn):
    path = os.path.join(S, "results" if width == 128 else f"results_w{width}", f"fixed_adam_{fn}.npz")
    if not os.path.exists(path):
        return None
    z = np.load(path); ns = [int(v) for v in z["ns"]]
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
    return {n: [(z["test_err"][-1, I[(n, s)]], z["pred"][-1, I[(n, s)]]) for s in (0, 1)] for n in ns}


def main():
    models = {"race": Race(theta=1.5, Q=3, gate="relu"), "nngp-kernel": NNGPKernel(), "hybrid": Hybrid(**HYBRID_DEFAULTS)}
    cache = {}
    print("| width | partial cells | " + " | ".join(models) + " |\n|---|---|" + "---|" * len(models))
    for width in (32, 128, 512):
        num = {m: 0.0 for m in models}; den = {m: 0.0 for m in models}; cells = 0
        for fn in FNS:
            nnw = load(width, fn)
            if nnw is None:
                continue
            Xte, yte = C.test_data(fn)
            for n, lst in nnw.items():
                en = np.mean([e for e, _ in lst])
                if not 0.05 <= en <= 0.45:
                    continue
                cells += 1
                for m, M in models.items():
                    preds = []
                    for s in (0, 1):
                        key = (m, fn, n, s)
                        if key not in cache:
                            X, y = C.train_data(fn, s, n)
                            cache[key] = np.where(M.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))["predict"](Xte) > 0, 1, -1)
                        preds.append(cache[key])
                    em = np.mean([np.mean(p != yte) for p in preds])
                    agree = np.mean([np.mean(p == q) for p, (_, q) in zip(preds, lst)])
                    indep = (1 - en) * (1 - em) + en * em
                    num[m] += agree - indep; den[m] += 1 - indep
        if cells:
            print(f"| {width} | {cells} | " + " | ".join(f"{num[m] / den[m]:.2f}" for m in models) + " |", flush=True)


if __name__ == "__main__":
    main()
