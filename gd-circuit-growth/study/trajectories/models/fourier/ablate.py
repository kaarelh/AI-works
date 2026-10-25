"""Ablations of the Fourier-race model: switch one ingredient off, refit the five constants (one Nelder-Mead run
from the final values), and report the calibration scores.  Writes ablations.json.

    python ablate.py
"""
import os, sys, json, time
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import numpy as np
from scipy.optimize import minimize

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import model as M
import fit as F

ABLATIONS = [
    ("full model", {}, {}),
    ("no junta completion", {"COMPLETION": 0}, {}),
    ("completion only after order >= 2 moves", {"CTRIG": 0}, {}),
    ("bundles keep progress when they lose members", {"DECAY": 0}, {}),
    ("no bundle-direction (event) bases", {"EVBASE": 0}, {}),
    ("no odd-degree penalty", {"ODD": 0}, {}),
    ("no gating penalty", {"GATE": 0}, {}),
    ("root moves may reuse learned inputs", {"ROOTNEW": 0}, {}),
    ("BBP level from total bundle strength", {"DIRBBP": 0}, {}),
    ("rate ~ rho (not rho^1/2)", {"P_RHO": 1.0}, {}),
    ("no memorisation cutoff", {}, {"EPOCHS": 1e9}),
    ("no BBP shrinkage", {}, {"NBBP": 0.0}),
]


def main():
    refs = F.load_refs(F.CALIB); sps = {fn: M.spectrum(fn) for fn in F.CALIB}
    out = {}
    for name, st_over, prm_over in ABLATIONS:
        st = dict(M.STRUCT); st.update(st_over)
        fixed = dict(prm_over)
        free = [k for k in F.NAMES if k not in fixed]

        def run(prm):
            tr, on = [], []
            for fn in F.CALIB:
                for cond in F.CONDS:
                    s, f = M.predict(fn, cond, prm, sps[fn], st)
                    a, b = F.score_one(refs[(fn, cond)], s, f)
                    tr.append(a); on.append(b)
            return float(np.mean(tr)), float(np.nanmean(on))

        base = dict(M.PARAMS); base.update(fixed)
        t0 = time.time()
        mt0, mo0 = run(base)
        x0 = np.log([base[k] for k in free])

        def obj(x):
            p = dict(base); p.update(dict(zip(free, np.exp(x))))
            mt, mo = run(p)
            return F.W_TRAJ * mt + mo
        if name == "full model":
            best = base; mt, mo = mt0, mo0
        else:
            res = minimize(obj, x0, method="Nelder-Mead", options=dict(maxfev=90, xatol=0.005, fatol=1e-4,
                           initial_simplex=np.array([x0] + [x0 + 0.2 * np.eye(len(x0))[i] for i in range(len(x0))])))
            best = dict(base); best.update(dict(zip(free, [float(v) for v in np.exp(res.x)])))
            mt, mo = run(best)
        out[name] = dict(no_refit=dict(traj=mt0, onset=mo0), refit=dict(traj=mt, onset=mo),
                         params={k: round(float(v), 3) for k, v in best.items()})
        print(f"{name:40s} no refit: traj {mt0:.4f} onset {mo0:.3f} | refit: traj {mt:.4f} onset {mo:.3f}  ({time.time() - t0:.0f}s)", flush=True)
    json.dump(out, open(os.path.join(HERE, "ablations.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
