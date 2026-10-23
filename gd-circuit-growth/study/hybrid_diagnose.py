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
    * the degree-1 sample noise: the cosine between the network's degree-1 Fourier coefficients on the irrelevant
      coordinates and each learner's (references: the raw Hebbian vector E_S[(y - ybar) x], ridge least squares).
    * error location on the test set: error rates on boundary points (some relevant coordinate flips the label) and on
      interior points; agreement with the label of the nearest training point; P(network errs | race errs?, kernel errs?).
    * swaps (diagnostic only, uses the relevant variables): sign(A's relevant part + B's sample-noise pattern rescaled to
      A's noise variance), scored like a learner.
Writes study/hybrid_diagnose.json and prints the summary tables used in HYBRID.md.

    OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python hybrid_diagnose.py            # full run (about 15 min)
    python hybrid_diagnose.py summary                                             # tables from the saved json
    python hybrid_diagnose.py ceiling                                             # network-vs-network references
"""
import os, sys, json, itertools, numpy as np
from scipy.linalg import cho_factor, cho_solve
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
from models.race import Race
from models.hybrid import Hybrid
try:
    from models.hybrid import HYBRID_DEFAULTS
except ImportError:
    HYBRID_DEFAULTS = {}
from models.baselines import nngp_table

REINIT = os.environ.get("NN_REINIT", os.path.join(os.path.dirname(C.RESULTS), "hybrid", "nn_reinit"))
PROBE = np.random.default_rng(99).choice(np.array([-1.0, 1.0], dtype=np.float32), size=(16384, C.D))
PAIRS = list(itertools.combinations(range(C.D), 2))
CH = np.stack([PROBE[:, i] * PROBE[:, j] for i, j in PAIRS], 1).astype(np.float64)   # degree-2 characters on the probe set


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


def rkey(Z, rel):
    return ((Z[:, rel] > 0).astype(np.int64) * (2 ** np.arange(len(rel)))).sum(1)


def parts(v, rel):
    mu, sd = v.mean(), max(v.std(), 1e-12)
    v = (v - mu) / sd
    key = rkey(PROBE, rel)
    cnt = np.bincount(key, minlength=2 ** len(rel)); s = np.bincount(key, weights=v, minlength=2 ** len(rel))
    tab = s / np.maximum(cnt, 1); fR = tab[key]
    f1 = PROBE @ (PROBE.T @ v / len(PROBE))
    f2 = CH @ (CH.T @ v / len(PROBE))
    return dict(v=v, R=fR, perp=v - fR, d1=f1, d2=f2, d3=v - f1 - f2, tab=tab, mu=mu, sd=sd)


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
                fte = {k: f(Xte) for k, f in L.items()}
                te = {k: np.where(v > 0, 1, -1) for k, v in fte.items()}
                pr = {k: parts(f(PROBE), rel) for k, f in L.items()}
                # swaps: the relevant-coordinate part of one learner plus the sample-noise part of another, on the test
                # set (each part standardised as on the probe set); a diagnostic only -- it uses the relevant variables
                kte = rkey(Xte, rel)
                for A, B in (("race", "kernel"), ("kernel", "race"), ("race", "nn-reinit")):
                    if A in L and B in L:
                        RA = pr[A]["tab"][kte]; RB = pr[B]["tab"][kte]
                        vA = (fte[A] - pr[A]["mu"]) / pr[A]["sd"]; vB = (fte[B] - pr[B]["mu"]) / pr[B]["sd"]
                        # A's signal and threshold, B's noise pattern rescaled to A's noise variance
                        pB = (vB - RB) * pr[A]["perp"].std() / max(pr[B]["perp"].std(), 1e-12)
                        te[f"swap:{A}R+{B}perp"] = np.where(RA + pB > -pr[A]["mu"] / pr[A]["sd"], 1, -1)
                # nearest training point label (Hamming distance = (d - x.x')/2)
                nnlab = y[np.argmax(Xte @ X.T, 1)]
                r = dict(fn=fn, n=int(n), seed=s, split="heldout" if fn in C.HELDOUT else "calib", learners=list(L))
                en = te["nn"] != yte
                for k in [k for k in te if k.startswith("swap:")]:
                    r[f"{k}/err"] = float(np.mean(te[k] != yte)); r[f"{k}/agree"] = float(np.mean(te[k] == te["nn"]))
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
                # degree-1 sample noise: the learners' degree-1 Fourier coefficients on the irrelevant coordinates,
                # against the network's; references: the raw Hebbian vector E_S[(y - ybar) x] and ridge least squares
                irr = [j for j in range(C.D) if j not in rel]
                c1 = {k: PROBE.T @ pr[k]["v"] / len(PROBE) for k in L}
                c1["hebbian"] = X.T @ (y - y.mean()) / len(y)
                c1["ridge-ls"] = np.linalg.solve(X.T @ X + np.eye(C.D), X.T @ (y - y.mean()))
                for k in c1:
                    u, v_ = c1["nn"][irr], c1[k][irr]
                    r[f"{k}/cos_deg1_noise"] = float(u @ v_ / np.sqrt((u @ u) * (v_ @ v_) + 1e-30))
                    r[f"{k}/deg1_noise_frac"] = float(np.linalg.norm(v_) / max(np.linalg.norm(c1[k]), 1e-30))
                rows.append(r)
                print(f"{fn:10s} n={int(n):5d} s={s} " + " ".join(f"{k}:err {r[k+'/err']:.2f} perp {r[k+'/corr_perp']:.2f} R {r[k+'/corr_R']:.2f}"
                                                         for k in L if k != "nn"), flush=True)
    json.dump(rows, open(os.path.join(HERE, "hybrid_diagnose.json"), "w"), indent=0)
    summarize(rows)


def agreement(rows, k, split, need=()):
    """common.compare's per-example agreement statistic for learner k, from the rows (cells where k and `need` exist)."""
    cells = {}
    for r in rows:
        if (split == "all" or r["split"] == split) and f"{k}/err" in r and all(f"{q}/err" in r for q in need):
            cells.setdefault((r["fn"], r["n"]), []).append(r)
    num = den = 0.0
    for lst in cells.values():
        en = np.mean([r["nn/err"] for r in lst]); em = np.mean([r[f"{k}/err"] for r in lst])
        ag = np.mean([r[f"{k}/agree"] for r in lst]); ind = (1 - en) * (1 - em) + en * em
        num += ag - ind; den += 1 - ind
    return num / den if den else np.nan


def summarize(rows):
    keys = sorted({k.split("/")[0] for r in rows for k in r if k.endswith("/agree")})
    for split in ("heldout", "calib"):
        print(f"\n=== per-example agreement with the network on {split} partial cells (cells where nn-reinit exists in brackets) ===")
        for k in keys:
            print(f"   {k:28s} {agreement(rows, k, split):.3f}   [{agreement(rows, k, split, need=('nn-reinit',)):.3f}]")

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
        print("degree-1 sample noise (irrelevant coordinates): cosine with the network's, and noise / total degree-1 norm")
        for k in ["nn", "race", "kernel", "hybrid", "nn-sgd", "nn-reinit", "hebbian", "ridge-ls"]:
            print(f"   {k:10s} cos {avg(k + '/cos_deg1_noise', split)[0]:.2f}   noise fraction {avg(k + '/deg1_noise_frac', split)[0]:.2f}")
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


def reinit_res(dirs=None, fns=None):
    """Re-initialised networks (hybrid_reinit.py) in the evaluate() format (n <= 2048).  With several directories, the
    prediction is the sign of the mean real-valued output of those networks (an ensemble over initialisations)."""
    dirs = dirs or [REINIT]
    fns = [f for f in (fns or C.HELDOUT) if all(os.path.exists(os.path.join(D_, f"fixed_adam_{f}.npz")) for D_ in dirs)]
    res = dict(model="nn-reinit" + (f"-ens{len(dirs)}" if len(dirs) > 1 else ""), fns=fns, ns=None, seeds=C.SEEDS,
               test_err={}, train_err={}, time={}, size={}, fit_seconds={}, pred={})
    yte = {fn: C.test_data(fn)[1] for fn in fns}
    for fn in fns:
        Z = [np.load(os.path.join(D_, f"fixed_adam_{fn}.npz")) for D_ in dirs]
        z = Z[0]; ns = [int(v) for v in z["ns"]]; res["ns"] = ns
        I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
        out = np.mean([zz["out_final"].astype(np.float64) for zz in Z], 0)          # [net, 4096]
        pred = np.array([[np.where(out[I[(n, s)]] > 0, 1, -1) for s in range(3)] for n in ns], dtype=np.int8)
        res["pred"][fn] = pred
        res["test_err"][fn] = np.mean(pred != yte[fn][None, None, :], -1)
        res["train_err"][fn] = np.array([[z["train_err"][-1, I[(n, s)]] for s in range(3)] for n in ns])
        stg = np.full(res["test_err"][fn].shape, np.nan)
        if len(dirs) == 1:
            for a, n in enumerate(ns):
                for s in range(3):
                    hit = np.where(z["test_err"][:, I[(n, s)]] <= 0.1)[0]
                    if len(hit):
                        stg[a, s] = z["step"][hit[0]]
        res["time"][fn] = stg; res["size"][fn] = np.full(stg.shape, np.nan); res["fit_seconds"][fn] = np.zeros(stg.shape)
    return res


def ceiling():
    """Network-vs-network references on HELDOUT, restricted to n <= 2048 (all HELDOUT partial cells are there)."""
    extra = [os.path.join(os.path.dirname(REINIT), f"nn_reinit_{f}") for f in (314159, 161803)]
    extra = [D_ for D_ in extra if all(os.path.exists(os.path.join(D_, f"fixed_adam_{fn}.npz")) for fn in C.HELDOUT)]
    rr = reinit_res(); ns = rr["ns"]
    sg = C.nn_as_model_res("sgd", fns=C.HELDOUT); sg["ns"] = ns
    for fn in sg["fns"]:
        for k in ("test_err", "train_err", "time", "size", "fit_seconds", "pred"):
            sg[k][fn] = sg[k][fn][:len(ns)]
    cands = [("nn-reinit (Adam, same data, new init)", rr), ("nn-sgd (SGD, same data, same init)", sg)]
    for D_ in extra:
        cands.append((f"nn-reinit {os.path.basename(D_)} (another new init)", reinit_res([D_])))
    if extra:
        cands.append((f"ensemble of {1 + len(extra)} new-init networks (sign of mean output)", reinit_res([REINIT] + extra)))
    out = {}
    for name, r in cands:
        b = C.compare(r, "adam", fns=C.HELDOUT, verbose=False); out[name] = b["example_agreement_score"]
        print(f"{name}: per-example agreement {b['example_agreement_score']:.3f} over {b['n_partial_cells']} cells; "
              f"n* |log2| {b['sc_mean_abs_log2_ratio']:.2f} (n<=2048 only); curve MAE {b['curve_mae']:.3f}")
    json.dump(out, open(os.path.join(HERE, "hybrid_ceiling.json"), "w"), indent=1)
    return out


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "ceiling":
        ceiling()
    elif len(sys.argv) > 1 and sys.argv[1] == "summary":
        summarize(json.load(open(os.path.join(HERE, "hybrid_diagnose.json"))))
    else:
        main()
