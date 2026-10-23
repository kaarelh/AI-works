"""Diagnosis of the per-example agreement gap (study/HYBRID.md, section 1).

On every partial cell (fn, n) -- the networks' seed-mean test error in [0.05, 0.45], as in common.compare -- and every
seed, compare the trained network (muP MLP, Adam) with other learners trained on the SAME training set:
    race      the race model (models/race.py, calibrated setting)
    kernel    NNGP kernel ridge regression (models/baselines.py)
    hybrid    the race + kernel-background model (models/hybrid.py, calibrated setting)
    nn-sgd    the same network trained with muP-SGD (HELDOUT only; same training set AND same initialisation)
    nn-reinit the same network trained with Adam from a different initialisation (HELDOUT only; hybrid_reinit.py)
Measures (real-valued outputs standardised on a probe set of 16384 fresh uniform points):
    * the output split into its relevant-coordinate part f_R(x) = E[f | x_R] (R = the target's relevant variables) and
      the rest f_perp = f - f_R.  The target has f_perp = 0, so f_perp is the part of the function that comes from the
      particular training sample (noise in the fit).  Report the variance share of f_perp and the correlation of each
      part with the network's.
    * the output split by Fourier degree over all d coordinates: degree 1, degree 2, degree >= 3 (variance shares,
      correlations with the network's).
    * error location on the test set: error rates on boundary points (some relevant coordinate flips the label) and on
      interior points; agreement with the label of the nearest training point; P(network errs | race errs?, kernel errs?).
Writes study/hybrid_diagnose.json and prints the summary tables used in HYBRID.md.

    OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python hybrid_diagnose.py
"""
import os, sys, json, itertools, numpy as np
from scipy.linalg import cho_factor, cho_solve
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from models.race import Race
from models.hybrid import Hybrid, HYBRID_DEFAULTS
from models.baselines import nngp_table

REINIT = os.environ.get("NN_REINIT", os.path.join(os.path.dirname(C.RESULTS), "hybrid", "nn_reinit"))
PROBE = np.random.default_rng(99).choice(np.array([-1.0, 1.0], dtype=np.float32), size=(16384, C.D))
PAIRS = list(itertools.combinations(range(C.D), 2))


def race_score(fit):
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


def kernel_score(X, y, ridge=1e-4):
    d = X.shape[1]; table = nngp_table(d)
    gram = lambda A, B: table[((A @ B.T).astype(np.int64) + d) // 2].astype(np.float64)
    K = gram(X, X); lam = ridge * np.trace(K) / len(X)
    c = cho_solve(cho_factor(K + lam * np.eye(len(X))), y.astype(np.float64))
    return lambda Z: np.concatenate([gram(Z[i:i + 4096], X) @ c for i in range(0, len(Z), 4096)])


def nn_score(P, j):
    p = {k: P[k][j].astype(np.float64) for k in P.files}
    def f(Z):
        h1 = np.maximum(Z @ p["W1"].T + p["b1"], 0); h2 = np.maximum(h1 @ p["W2"].T + p["b2"], 0)
        return h2 @ p["a"]
    return f


def net_index(path):
    z = np.load(path)
    return {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}


def parts(v, rel):
    v = (v - v.mean()) / max(v.std(), 1e-12)
    key = ((PROBE[:, rel] > 0).astype(np.int64) * (2 ** np.arange(len(rel)))).sum(1)
    cnt = np.bincount(key, minlength=2 ** len(rel)); s = np.bincount(key, weights=v, minlength=2 ** len(rel))
    fR = (s / np.maximum(cnt, 1))[key]
    f1 = PROBE @ (PROBE.T @ v / len(PROBE))
    Ch = np.empty((len(PROBE), len(PAIRS)), dtype=np.float32)
    for q, (i, j) in enumerate(PAIRS):
        Ch[:, q] = PROBE[:, i] * PROBE[:, j]
    f2 = Ch @ (Ch.T @ v / len(PROBE))
    return dict(v=v, R=fR, perp=v - fR, d1=f1, d2=f2, d3=v - f1 - f2)


def corr(a, b):
    a = a - a.mean(); b = b - b.mean()
    return float(a @ b / np.sqrt((a @ a) * (b @ b) + 1e-30))


def boundary(fn, X):
    """1 where flipping some relevant coordinate changes the label."""
    f = C.SUITE[fn]["fn"]; y = f(X); out = np.zeros(len(X), bool)
    for i in C.SUITE[fn]["relevant"]:
        Xf = X.copy(); Xf[:, i] *= -1; out |= f(Xf) != y
    return out


def main():
    M_race = Race(theta=1.5, Q=3, gate="relu"); M_hyb = Hybrid(**HYBRID_DEFAULTS)
    rows = []
    for fn in C.CALIB + C.HELDOUT:
        nn = C.nn_fixed(fn, "adam"); rel = C.SUITE[fn]["relevant"]
        Pa = np.load(os.path.join(C.RESULTS, f"params_fixed_adam_{fn}.npz")); Ia = net_index(os.path.join(C.RESULTS, f"fixed_adam_{fn}.npz"))
        refs = {}
        if os.path.exists(os.path.join(C.RESULTS, f"params_fixed_sgd_{fn}.npz")):
            refs["nn-sgd"] = (np.load(os.path.join(C.RESULTS, f"params_fixed_sgd_{fn}.npz")), net_index(os.path.join(C.RESULTS, f"fixed_sgd_{fn}.npz")))
        if os.path.exists(os.path.join(REINIT, f"params_fixed_adam_{fn}.npz")):
            refs["nn-reinit"] = (np.load(os.path.join(REINIT, f"params_fixed_adam_{fn}.npz")), net_index(os.path.join(REINIT, f"fixed_adam_{fn}.npz")))
        Xte, yte = C.test_data(fn); bnd = boundary(fn, Xte)
        for a_, n in enumerate(nn["ns"]):
            if not 0.05 <= nn["test_err"][a_].mean() <= 0.45:
                continue
            for s in range(3):
                X, y = C.train_data(fn, s, int(n)); rng = lambda: np.random.default_rng([s, int(n), C._fn_seed(fn)])
                L = {"nn": nn_score(Pa, Ia[(int(n), s)]), "race": race_score(M_race.fit(X, y, rng())),
                     "kernel": kernel_score(X, y), "hybrid": M_hyb.fit(X, y, rng())["score"]}
                for k, (P_, I_) in refs.items():
                    if (int(n), s) in I_:
                        L[k] = nn_score(P_, I_[(int(n), s)])
                te = {k: np.where(f(Xte) > 0, 1, -1) for k, f in L.items()}
                pr = {k: parts(f(PROBE), rel) for k, f in L.items()}
                # nearest training point label (Hamming distance = (d - x.x')/2)
                nnlab = y[np.argmax(Xte @ X.T, 1)]
                r = dict(fn=fn, n=int(n), seed=s, split="heldout" if fn in C.HELDOUT else "calib", learners=list(L))
                en = te["nn"] != yte
                for k in L:
                    e = te[k] != yte
                    r[f"{k}/err"] = float(e.mean()); r[f"{k}/agree"] = float(np.mean(te[k] == te["nn"]))
                    r[f"{k}/err_boundary"] = float(e[bnd].mean()) if bnd.any() else np.nan
                    r[f"{k}/err_interior"] = float(e[~bnd].mean()) if (~bnd).any() else np.nan
                    r[f"{k}/frac_err_on_boundary"] = float(bnd[e].mean()) if e.any() else np.nan
                    r[f"{k}/agree_1nn"] = float(np.mean(te[k] == nnlab))
                    r[f"{k}/share_perp"] = float(np.var(pr[k]["perp"]))
                    for q in ("d1", "d2", "d3"):
                        r[f"{k}/share_{q}"] = float(np.var(pr[k][q]))
                    if k != "nn":
                        for q in ("v", "R", "perp", "d1", "d2", "d3"):
                            r[f"{k}/corr_{q}"] = corr(pr["nn"][q], pr[k][q])
                        # phi coefficient of the two error indicators
                        r[f"{k}/phi_err"] = corr(en.astype(float), e.astype(float))
                er, ek = te["race"] != yte, te["kernel"] != yte
                for a1, b1 in itertools.product((0, 1), (0, 1)):
                    m = (er == a1) & (ek == b1)
                    r[f"P(nn err|race{a1},kernel{b1})"] = float(en[m].mean()) if m.any() else np.nan
                    r[f"frac(race{a1},kernel{b1})"] = float(m.mean())
                rows.append(r)
                print(f"{fn:10s} n={int(n):5d} s={s} " + " ".join(f"{k}:err {r[k+'/err']:.2f} perp {r[k+'/corr_perp']:.2f} R {r[k+'/corr_R']:.2f}"
                                                         for k in L if k != "nn"), flush=True)
    json.dump(rows, open(os.path.join(HERE, "hybrid_diagnose.json"), "w"), indent=0)
    summarize(rows)


def summarize(rows):
    def avg(key, split, learners=None):
        v = [r[key] for r in rows if key in r and (split == "all" or r["split"] == split) and np.isfinite(r[key])
             and (learners is None or all(l in r["learners"] for l in learners))]
        return (float(np.mean(v)), len(v)) if v else (np.nan, 0)
    for split, learners in (("heldout", ["race", "kernel", "hybrid", "nn-sgd", "nn-reinit"]), ("calib", ["race", "kernel", "hybrid"])):
        print(f"\n=== {split} partial cells (cell x seed averages; reference learners only where available) ===")
        print("| learner | test err | share of f_perp | corr f_R | corr f_perp | corr deg1 | corr deg2 | corr deg>=3 | phi(errors) | agree 1-NN label | err boundary / interior |")
        print("|---|---|---|---|---|---|---|---|---|---|---|")
        for k in ["nn"] + learners:
            cs = [avg(f"{k}/corr_{q}", split)[0] if k != "nn" else np.nan for q in ("R", "perp", "d1", "d2", "d3")]
            print(f"| {k} | {avg(k+'/err', split)[0]:.3f} | {avg(k+'/share_perp', split)[0]:.2f} | " + " | ".join(f"{c:.2f}" for c in cs)
                  + f" | {avg(k+'/phi_err', split)[0]:.2f} | {avg(k+'/agree_1nn', split)[0]:.3f} | {avg(k+'/err_boundary', split)[0]:.2f} / {avg(k+'/err_interior', split)[0]:.2f} |")
        print("P(nn err | race err?, kernel err?) and cell fractions:")
        for a1, b1 in itertools.product((0, 1), (0, 1)):
            print(f"   race {'wrong' if a1 else 'right'}, kernel {'wrong' if b1 else 'right'}: P(nn wrong) = {avg(f'P(nn err|race{a1},kernel{b1})', split)[0]:.2f}"
                  f"  (fraction of points {avg(f'frac(race{a1},kernel{b1})', split)[0]:.3f})")
    # by n regime
    print("\n=== corr f_perp with the network, by n (all partial cells) ===")
    for lo, hi in ((16, 64), (128, 256), (512, 1024), (2048, 16384)):
        sel = [r for r in rows if lo <= r["n"] <= hi]
        if sel:
            print(f"n in [{lo},{hi}] ({len(sel)} cell-seeds): " + "  ".join(
                f"{k} {np.nanmean([r.get(k + '/corr_perp', np.nan) for r in sel]):.2f}" for k in ("race", "kernel", "hybrid", "nn-sgd", "nn-reinit"))
                + f"   share_perp(nn) {np.mean([r['nn/share_perp'] for r in sel]):.2f}")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "summary":
        summarize(json.load(open(os.path.join(HERE, "hybrid_diagnose.json"))))
    else:
        main()
