"""Width check of the background picture (study/HYBRID.md, section 1.6): per-example agreement of the NNGP kernel, the
race and the hybrid with networks of different widths (fixed protocol, Adam, same training sets; the width sweeps in
<scratchpad>/results_w<width>, main sweep = width 128).

If the networks' individual mistakes come from a random-feature background, the infinite-width NNGP kernel should agree
more with wider networks.  Partial cells are those of each width's own networks; only targets present at every compared
width are pooled.

    OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python hybrid_width.py
"""
import os, sys, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from models.race import Race
from models.hybrid import Hybrid, HYBRID_DEFAULTS
from models.baselines import NNGPKernel

S = os.path.dirname(C.RESULTS)
WIDTHS = (32, 64, 128, 256, 512)


def load(width, fn):
    path = os.path.join(S, "results" if width == 128 else f"results_w{width}", f"fixed_adam_{fn}.npz")
    if not os.path.exists(path):
        return None
    z = np.load(path)
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
    seeds = sorted({int(s) for s in z["net_s"]})
    return {int(n): [(float(z["test_err"][-1, I[(int(n), s)]]), z["pred"][-1, I[(int(n), s)]], s) for s in seeds] for n in z["ns"]}


def main():
    models = {"race": Race(theta=1.5, Q=3, gate="relu"), "nngp-kernel": NNGPKernel(), "hybrid": Hybrid(**HYBRID_DEFAULTS)}
    avail = {w: [fn for fn in C.FNS if load(w, fn) is not None] for w in WIDTHS}
    avail = {w: f for w, f in avail.items() if f}
    cache = {}

    def score(width, fns):
        num = {m: 0.0 for m in models}; den = {m: 0.0 for m in models}; cells = 0
        for fn in fns:
            Xte, yte = C.test_data(fn)
            for n, lst in load(width, fn).items():
                en = np.mean([e for e, _, _ in lst])
                if not 0.05 <= en <= 0.45:
                    continue
                cells += 1
                for m, M in models.items():
                    preds = []
                    for _, _, s in lst:
                        key = (m, fn, n, s)
                        if key not in cache:
                            X, y = C.train_data(fn, s, n)
                            cache[key] = np.where(M.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))["predict"](Xte) > 0, 1, -1)
                        preds.append(cache[key])
                    em = np.mean([np.mean(p != yte) for p in preds])
                    agree = np.mean([np.mean(p == q) for p, (_, q, _) in zip(preds, lst)])
                    indep = (1 - en) * (1 - em) + en * em
                    num[m] += agree - indep; den[m] += 1 - indep
        return cells, {m: num[m] / den[m] if den[m] else np.nan for m in models}

    # target sets: those present at every width, then each narrower sweep's set compared with the main sweep (128)
    sets = [sorted(set.intersection(*[set(f) for f in avail.values()]))]
    sets += [sorted(set(f)) for w, f in avail.items() if w != 128 and sorted(set(f)) not in sets]
    print("| targets | width | partial cells | " + " | ".join(models) + " |\n|---|---|---|" + "---|" * len(models))
    for use in sets:
        for w in sorted(avail):
            if set(use) <= set(avail[w]):
                cells, sc = score(w, use)
                print(f"| {','.join(use)} | {w} | {cells} | " + " | ".join(f"{sc[m]:.2f}" for m in models) + " |", flush=True)


if __name__ == "__main__":
    main()
