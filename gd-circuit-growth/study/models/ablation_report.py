"""Tables for ABLATIONS.md from the saved ablation evaluations (models/run_ablations.py).

usage: python models/ablation_report.py [NAME ...]   (default: every race-abl-*.npz present)
Prints markdown: scoreboard metrics per ablation (HELDOUT, ALL), per-function n*, and circuit diagnostics.
"""
import os, sys, json, glob
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C
import functools
C.nn_fixed = functools.lru_cache(maxsize=None)(C.nn_fixed)     # the NN files are re-read by every compare() call

SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
EVALS = os.path.join(SCR, "model_evals"); DIAG = os.path.join(SCR, "ablation_diag")
KEYS = [("sc_mean_abs_log2_ratio", "abs log2 n* ratio"), ("sc_spearman", "n* Spearman"),
        ("success_agreement", "success agr."), ("curve_mae", "curve MAE"),
        ("example_agreement_score", "per-example agr."), ("time_spearman", "time Spearman")]
FAMILIES = {"parity": ["par2", "par3", "par4"], "staircase/sparse-poly": ["stair5", "sparsepoly", "mux"],
            "dense majority/halfspace": ["maj9", "thr10", "rmaj9"], "compositions": ["majpar", "parmaj", "andxor"]}


def nstar(res, fn):
    e = np.nanmean(res["test_err"][fn], 1); ok = ~np.isnan(e)
    return C.sample_complexity(np.array(res["ns"])[ok], e[ok])


def fmt_n(v):
    return "never" if not np.isfinite(v) else f"{v:.0f}"


def load(names):
    out = {}
    for nm in names:
        p = os.path.join(EVALS, f"race-abl-{nm}.npz")
        if os.path.exists(p):
            out[nm] = C.load_eval(p)
    return out


def scoreboard(res, splits=("HELDOUT", "ALL")):
    L = []
    for split in splits:
        fns = dict(HELDOUT=C.HELDOUT, CALIB=C.CALIB, ALL=C.FNS)[split]
        L += [f"#### {split}", "", "| ablation | " + " | ".join(k[1] for k in KEYS) + " |", "|---|" + "---|" * len(KEYS)]
        for nm, r in res.items():
            s = C.compare(r, "adam", fns=fns, verbose=False)
            L.append(f"| {nm} | " + " | ".join(f"{s[k]:.2f}" if s[k] == s[k] else "–" for k, _ in KEYS) + " |")
        L.append("")
    return L


def per_fn(res):
    L = ["| fn | NN | " + " | ".join(res) + " |", "|---|---|" + "---|" * len(res)]
    for fn in C.FNS:
        nn = C.nn_fixed(fn, "adam"); a = C.sample_complexity(nn["ns"], nn["test_err"].mean(1))
        L.append(f"| {fn}{'*' if fn in C.HELDOUT else ''} | {fmt_n(a)} | " + " | ".join(fmt_n(nstar(r, fn)) for r in res.values()) + " |")
    return L


def family_ratio(res):
    """mean log2(n*_model / n*_NN) per family (signed: + = model needs more data)."""
    cap = 2 * 16384
    L = ["| ablation | " + " | ".join(FAMILIES) + " | all 21 |", "|---|" + "---|" * (len(FAMILIES) + 1)]
    nnv = {fn: min(C.sample_complexity(C.nn_fixed(fn, "adam")["ns"], C.nn_fixed(fn, "adam")["test_err"].mean(1)), cap)
           for fn in C.FNS}
    for nm, r in res.items():
        cells = []
        for fam, fns in list(FAMILIES.items()) + [("all", C.FNS)]:
            v = [np.log2(min(nstar(r, fn), cap) / nnv[fn]) for fn in fns]
            cells.append(f"{np.mean(v):+.2f}")
        L.append(f"| {nm} | " + " | ".join(cells) + " |")
    return L


def time_split(res, fns=None, ncut=4096):
    """Spearman of NN steps-to-generalise vs the model's clock, separately on cells with n >= ncut (feature-learning
    speed, far above n*) and n < ncut (near n*, where delayed generalisation lives), over cells where both reach 0.1."""
    out = {}
    for nm, r in res.items():
        hi, lo = [], []
        for fn in (fns or C.FNS):
            nn = C.nn_fixed(fn, "adam"); ns = np.array(r["ns"]); idx = [list(nn["ns"]).index(n) for n in ns]
            nt = nn["steps_to_gen"][idx]; mt = np.where(r["test_err"][fn] <= 0.1, r["time"][fn], np.nan)
            for a, n in enumerate(ns):
                for b in range(min(nt.shape[1], mt.shape[1])):
                    if np.isfinite(nt[a, b]) and np.isfinite(mt[a, b]) and nt[a, b] > 0:
                        (hi if n >= ncut else lo).append((nt[a, b], mt[a, b]))
        sp = lambda P: C._spearman(*zip(*P)) if len(P) > 5 else np.nan
        out[nm] = (sp(hi), len(hi), sp(lo), len(lo))
    return out


def time_log(res, fns=None):
    """Magnitude-sensitive time agreement over cells where both reach test error 0.1: Pearson r of log times, and
    the scatter (std, log2 units) of log2(model time / NN steps) around its mean, i.e. how well ONE unit conversion
    maps the model's clock onto network steps (NN steps are on a 1-2-5 checkpoint grid, ~0.3 log2 quantisation)."""
    out = {}
    for nm, r in res.items():
        P = []
        for fn in (fns or [f for f in C.FNS if f in r["fns"]]):
            nn = C.nn_fixed(fn, "adam"); ns = np.array(r["ns"]); idx = [list(nn["ns"]).index(n) for n in ns]
            nt = nn["steps_to_gen"][idx]; mt = np.where(r["test_err"][fn] <= 0.1, r["time"][fn], np.nan)
            for a in range(len(ns)):
                for b in range(min(nt.shape[1], mt.shape[1])):
                    if np.isfinite(nt[a, b]) and np.isfinite(mt[a, b]) and nt[a, b] > 0 and mt[a, b] > 0:
                        P.append((np.log2(nt[a, b]), np.log2(mt[a, b])))
        P = np.array(P)
        out[nm] = (float(np.corrcoef(P[:, 0], P[:, 1])[0, 1]), float(np.std(P[:, 1] - P[:, 0])), len(P)) if len(P) > 5 else (np.nan, np.nan, 0)
    return out


def diag(names):
    """Circuit diagnostics at the NN's critical n (the grid n just below and just above n*_NN)."""
    L = ["| ablation | gates (mean) | spurious gates at n < n*_NN | spurious at n >= 2 n*_NN | true features covered at n >= 2 n*_NN | order mix of gates (1/2/3/4) |",
         "|---|---|---|---|---|---|"]
    nnv = {fn: C.sample_complexity(C.nn_fixed(fn, "adam")["ns"], C.nn_fixed(fn, "adam")["test_err"].mean(1)) for fn in C.FNS}
    for nm in names:
        p = os.path.join(DIAG, f"race-abl-{nm}.json")
        if not os.path.exists(p):
            continue
        rows = json.load(open(p))["rows"]
        below = [r for r in rows if r["n"] < nnv[r["fn"]]]
        above = [r for r in rows if np.isfinite(nnv[r["fn"]]) and r["n"] >= 2 * nnv[r["fn"]]]
        ords = np.bincount(np.concatenate([np.array(r["orders"], int) for r in rows] + [np.zeros(0, int)]), minlength=5)[1:]
        ords = ords / max(ords.sum(), 1)
        L.append(f"| {nm} | {np.mean([r['size'] for r in rows]):.1f} | "
                 f"{np.mean([r['n_spur'] / max(r['size'], 1) for r in below]):.2f} | "
                 f"{np.mean([r['n_spur'] / max(r['size'], 1) for r in above]):.2f} | "
                 f"{np.mean([r['covers'] for r in above]):.2f} | " + "/".join(f"{o:.2f}" for o in ords) + " |")
    return L


if __name__ == "__main__":
    names = sys.argv[1:] or sorted(os.path.basename(p)[9:-4] for p in glob.glob(os.path.join(EVALS, "race-abl-*.npz")))
    res = load(names)
    print("\n".join(scoreboard(res, ("HELDOUT", "CALIB", "ALL"))))
    print("\n".join(per_fn(res))); print()
    print("\n".join(family_ratio(res))); print()
    print("\n".join(diag(names))); print()
    tl = time_log(res)
    print("| ablation | time Spearman n >= 4096 (cells) | time Spearman n < 4096 (cells) | Pearson r of log times | scatter of log2 time ratio |"); print("|---|---|---|---|---|")
    for nm, (a, na, b, nb) in time_split(res).items():
        print(f"| {nm} | {a:.2f} ({na}) | {b:.2f} ({nb}) | {tl[nm][0]:.2f} | {tl[nm][1]:.2f} ({tl[nm][2]}) |")
