"""Shared data access, model evaluation and behavioural comparison with the NN runs.

A *model* is any object with
    name: str
    fit(X, y, rng) -> dict with keys
        'predict': callable mapping an (m, d) +-1 array to an (m,) +-1 array
        'time':    float, the model's own training-time measure (e.g. moves, or race time)  [optional]
        'size':    int, final circuit size / number of features                                [optional]
        'trace':   list of (time, train_err) pairs                                            [optional]
X is an (n, d) float32 array of +-1, y an (n,) array of +-1.  The training sets are exactly the ones
the networks saw (nested across n for each seed), and the test set is the networks' test set.
"""
import os, json, time, numpy as np
from boolfuncs import make_suite, make_random_suite

D = int(os.environ.get("DIM", 30))          # input dimension (the d-scaling study uses 15 and 60)
SUITE = make_random_suite(D) if os.environ.get("SUITE") == "random" else make_suite(D)
FNS = list(SUITE)
NS = [2 ** k for k in range(4, int(np.log2(int(os.environ.get("NS_MAX", 16384)))) + 1)]
SEEDS = [0, 1, 2]
# Functions used to calibrate a model's global parameters, and functions held out for validation.
CALIB = ["dict", "maj3", "thr10", "par2", "par4", "stair5", "parmaj", "dnf3", "rmaj9", "andxor", "rand0", "rand2"]
HELDOUT = ["and3", "maj9", "par3", "majpar", "mux", "dlist5", "sparsepoly", "rand1", "rand3"]
RESULTS = os.environ.get("NN_RESULTS",
    "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results"
    + ("" if D == 30 else f"_d{D}") + ("_random" if os.environ.get("SUITE") == "random" else ""))

def _fn_seed(name):
    return int.from_bytes(name.encode(), "little") % (2 ** 31)

def train_data(name, seed, n):
    rng = np.random.default_rng([_fn_seed(name), seed])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(max(NS), D))[:n]
    return X, SUITE[name]["fn"](X).astype(np.float32)

def test_data(name):
    rng = np.random.default_rng([_fn_seed(name), 10 ** 6])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(4096, D))
    return X, SUITE[name]["fn"](X).astype(np.float32)

# ------------------------------------------------------------------ NN results

def nn_fixed(name, opt="adam"):
    """Returns dict with arrays indexed [n_index, seed]: final test_err, train_err, steps_to_gen
    (first checkpoint step with test_err <= 0.1, inf if never), and pred [n_index, seed, 4096] (final),
    curves test_err [ckpt, n_index, seed], step [ckpt]."""
    z = np.load(os.path.join(RESULTS, f"fixed_{opt}_{name}.npz"))
    ns, seeds = list(z["ns"]), list(z["seeds"])
    net_n, net_s = z["net_n"], z["net_s"]
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(net_n, net_s))}
    sh = (len(ns), len(seeds))
    te = np.zeros((len(z["step"]),) + sh); tr = np.zeros_like(te)
    pred = np.zeros(sh + (4096,), dtype=np.int8); stg = np.full(sh, np.inf)
    for a, n in enumerate(ns):
        for b, s in enumerate(range(len(seeds))):
            j = I[(int(n), s)]
            te[:, a, b] = z["test_err"][:, j]; tr[:, a, b] = z["train_err"][:, j]
            pred[a, b] = z["pred"][-1, j]
            hit = np.where(z["test_err"][:, j] <= 0.1)[0]
            if len(hit):
                stg[a, b] = z["step"][hit[0]]
    return dict(ns=np.array(ns), step=z["step"], test_err_curve=te, train_err_curve=tr,
                test_err=te[-1], train_err=tr[-1], pred=pred, steps_to_gen=stg)

def nn_online(name, opt="adam"):
    z = np.load(os.path.join(RESULTS, f"online_{opt}_{name}.npz"))
    te = z["test_err"]  # [ckpt, seed]
    steps = z["step"]
    s2g = []
    for j in range(te.shape[1]):
        hit = np.where(te[:, j] <= 0.1)[0]
        s2g.append(steps[hit[0]] * int(z["batch"]) if len(hit) else np.inf)
    return dict(step=steps, test_err=te, samples_to_gen=np.array(s2g, dtype=float))

# ------------------------------------------------------------------ evaluation

def evaluate(model, fns=None, ns=None, seeds=None, verbose=True, max_seconds_per_fit=None):
    fns = fns or FNS; ns = ns or NS; seeds = seeds or SEEDS
    out = dict(model=model.name, fns=fns, ns=ns, seeds=seeds, test_err={}, train_err={}, time={}, size={},
               fit_seconds={}, pred={})
    for fn in fns:
        Xte, yte = test_data(fn)
        te = np.zeros((len(ns), len(seeds))); tr = np.zeros_like(te); tm = np.full_like(te, np.nan)
        sz = np.full_like(te, np.nan); fs = np.zeros_like(te)
        pred = np.zeros((len(ns), len(seeds), len(yte)), dtype=np.int8)
        for a, n in enumerate(ns):
            for b, s in enumerate(seeds):
                X, y = train_data(fn, s, n)
                t0 = time.time()
                r = model.fit(X, y, np.random.default_rng([s, n, _fn_seed(fn)]))
                fs[a, b] = time.time() - t0
                p = np.asarray(r["predict"](Xte), dtype=float)
                if np.isnan(p).any():  # the model declined this cell (e.g. kernel too large): record NaN
                    te[a, b] = tr[a, b] = np.nan
                    continue
                pred[a, b] = np.where(p > 0, 1, -1)
                te[a, b] = np.mean(pred[a, b] != yte)
                tr[a, b] = np.mean(np.where(np.asarray(r["predict"](X)) > 0, 1, -1) != y)
                tm[a, b] = r.get("time", np.nan); sz[a, b] = r.get("size", np.nan)
        out["test_err"][fn] = te; out["train_err"][fn] = tr; out["time"][fn] = tm
        out["size"][fn] = sz; out["fit_seconds"][fn] = fs; out["pred"][fn] = pred
        if verbose:
            print(f"  {model.name:>14s} {fn:11s} test_err by n: " + " ".join(f"{v:.2f}" for v in te.mean(1))
                  + f"   ({fs.sum():.1f}s)", flush=True)
    return out

def save_eval(res, path):
    np.savez_compressed(path, **{f"{k}__{fn}": v for k in ("test_err", "train_err", "time", "size", "fit_seconds", "pred")
                                 for fn, v in res[k].items()},
                        meta=np.array(json.dumps(dict(model=res["model"], fns=res["fns"], ns=res["ns"], seeds=res["seeds"]))))

def load_eval(path):
    z = np.load(path, allow_pickle=False)
    meta = json.loads(str(z["meta"]))
    res = dict(meta, test_err={}, train_err={}, time={}, size={}, fit_seconds={}, pred={})
    for key in z.files:
        if "__" in key:
            k, fn = key.split("__", 1); res[k][fn] = z[key]
    return res

# ------------------------------------------------------------------ behavioural comparison

def sample_complexity(ns, err_by_n, thr=0.1):
    """Smallest n (log-interpolated) at which the seed-mean test error drops to <= thr; inf if never."""
    e = np.asarray(err_by_n); ln = np.log2(ns)
    for i in range(len(e)):
        if e[i] <= thr:
            if i == 0:
                return float(ns[0])
            # interpolate between i-1 and i in log2 n
            f = (e[i - 1] - thr) / max(e[i - 1] - e[i], 1e-12)
            return float(2 ** (ln[i - 1] + f * (ln[i] - ln[i - 1])))
    return np.inf

def _spearman(a, b):
    a, b = np.asarray(a, float), np.asarray(b, float)
    ra = np.argsort(np.argsort(a)); rb = np.argsort(np.argsort(b))
    return float(np.corrcoef(ra, rb)[0, 1])

def compare(model_res, opt="adam", thr=0.1, verbose=True, fns=None):
    """Behavioural agreement between a model and the NN (fixed protocol, given optimizer).
    fns: optional subset (e.g. HELDOUT); only functions with NN results on disk are used."""
    fns = [f for f in (fns or model_res["fns"]) if f in model_res["fns"]
           and os.path.exists(os.path.join(RESULTS, f"fixed_{opt}_{f}.npz"))]
    ns = np.array(model_res["ns"])
    rows, curve_gaps, agree_rows, succ_agree, time_pairs = [], [], [], [], []
    for fn in fns:
        nn = nn_fixed(fn, opt)
        idx = [list(nn["ns"]).index(n) for n in ns]
        m_err_full = model_res["test_err"][fn].mean(1)
        ok = ~np.isnan(m_err_full)          # cells the model actually ran (NaN = declined)
        nn_err = nn["test_err"][idx].mean(1)[ok]; m_err = m_err_full[ok]
        curve_gaps.append(np.abs(nn_err - m_err))
        sc_nn = sample_complexity(ns[ok], nn_err, thr); sc_m = sample_complexity(ns[ok], m_err, thr)
        rows.append((fn, sc_nn, sc_m))
        succ_agree += list((nn_err <= thr) == (m_err <= thr))
        nn_t = np.where(np.isfinite(nn["steps_to_gen"][idx]), nn["steps_to_gen"][idx], np.nan)
        m_t = np.where(model_res["test_err"][fn] <= thr, model_res["time"][fn], np.nan)
        for a in np.where(ok)[0]:
            for b in range(nn_t.shape[1]):
                if b < m_t.shape[1] and np.isfinite(nn_t[a, b]) and np.isfinite(m_t[a, b]) and nn_t[a, b] > 0:
                    time_pairs.append((nn_t[a, b], m_t[a, b]))
        # per-example agreement where the NN is partially right
        Xte, yte = test_data(fn)
        for a, n in enumerate(ns):
            e = nn["test_err"][idx[a]]
            if ok[a] and 0.05 <= e.mean() <= 0.45:
                P = nn["pred"][idx[a]]; Q = model_res["pred"][fn][a]
                # seeds couple training set and init: compare NN and model trained on the SAME training set (same seed);
                # nn_nn (NN seeds with different training sets) is kept only as a reference
                nn_nn = np.mean([np.mean(P[i] == P[j]) for i in range(len(P)) for j in range(len(P)) if i < j])
                nn_m = np.mean([np.mean(P[b] == Q[b]) for b in range(min(len(P), len(Q)))])
                # agreement expected if errors were independent, given the two error rates
                em = model_res["test_err"][fn][a].mean(); en = e.mean()
                indep = (1 - en) * (1 - em) + en * em
                agree_rows.append((fn, int(n), en, em, nn_nn, nn_m, indep))
    sc_nn = np.array([r[1] for r in rows]); sc_m = np.array([r[2] for r in rows])
    cap = 2.0 * max(ns)  # treat "never" as 2x the largest n for rank/ratio statistics (NaN-declined cells excluded)
    a_, b_ = np.minimum(sc_nn, cap), np.minimum(sc_m, cap)
    summary = dict(
        model=model_res["model"], opt=opt,
        curve_mae=float(np.mean(np.concatenate(curve_gaps))),
        sc_spearman=_spearman(a_, b_),
        sc_mean_abs_log2_ratio=float(np.mean(np.abs(np.log2(a_) - np.log2(b_)))),
        success_agreement=float(np.mean(succ_agree)),
        n_partial_cells=len(agree_rows),
        time_spearman=_spearman(*zip(*time_pairs)) if len(time_pairs) > 5 else np.nan,
        n_time_pairs=len(time_pairs),
        # fraction of the gap between independent-errors agreement and NN-seed-to-seed agreement that the model closes
        # per-example agreement on cells where the NN is partially right (test error in [0.05, 0.45]), same training set:
        # excess agreement over what independent errors would give, as a fraction of the maximum possible excess
        # (0 = errors unrelated to the NN's, 1 = identical predictions).  Compare with nn_as_model_res('sgd') as a ceiling.
        example_agreement_score=float(sum(r[5] - r[6] for r in agree_rows) / max(sum(1 - r[6] for r in agree_rows), 1e-6))
                                if agree_rows else np.nan,
        per_fn=[dict(fn=r[0], n_nn=r[1], n_model=r[2]) for r in rows],
        partial_cells=[dict(fn=r[0], n=r[1], nn_err=r[2], model_err=r[3], nn_nn_agree=r[4], nn_model_agree=r[5],
                            indep_agree=r[6]) for r in agree_rows],
    )
    if verbose:
        print(f"[{summary['model']} vs NN-{opt}] curve MAE {summary['curve_mae']:.3f} | sample-complexity Spearman "
              f"{summary['sc_spearman']:.2f}, mean |log2 ratio| {summary['sc_mean_abs_log2_ratio']:.2f} | "
              f"success agreement {summary['success_agreement']:.2f} | example-agreement score "
              f"{summary['example_agreement_score']:.2f} over {summary['n_partial_cells']} partial cells | time Spearman "
              f"{summary['time_spearman']:.2f} ({summary['n_time_pairs']} cells)")
        for r in rows:
            print(f"     {r[0]:11s} n*(NN)={r[1]:8.0f}  n*(model)={r[2]:8.0f}")
    return summary


def nn_as_model_res(opt="sgd", fns=None):
    """Package NN results (fixed protocol) in the evaluate() format, e.g. to compare NN-SGD with NN-Adam
    as a ceiling for how alike two gradient-descent learners are.  'time' is steps to test error <= 0.1."""
    fns = [f for f in (fns or FNS) if os.path.exists(os.path.join(RESULTS, f"fixed_{opt}_{f}.npz"))]
    res = dict(model=f"nn-{opt}", fns=fns, ns=NS, seeds=SEEDS, test_err={}, train_err={}, time={}, size={},
               fit_seconds={}, pred={})
    for fn in fns:
        nn = nn_fixed(fn, opt)
        res["test_err"][fn] = nn["test_err"]; res["train_err"][fn] = nn["train_err"]
        res["time"][fn] = np.where(np.isfinite(nn["steps_to_gen"]), nn["steps_to_gen"], np.nan)
        res["size"][fn] = np.full(nn["test_err"].shape, np.nan); res["fit_seconds"][fn] = np.zeros(nn["test_err"].shape)
        res["pred"][fn] = nn["pred"]
    return res
