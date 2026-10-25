"""Common harness for discrete learners compared with gradient descent at equal data and compute.

DATA. Exactly the networks' data: for target `name` and seed s, the training set of size n is the first n rows of
rng = default_rng([fn_seed(name), s]); X = rng.choice([-1, 1], size=(16384, d)) (nested across n), labels f(X); the test
set is 4096 points from default_rng([fn_seed(name), 10**6]).  Same as study/nn_train.py and study/common.py.

GRADIENT DESCENT'S COMPUTE. One network run (study/nn_train.py: muP MLP d-128-128-1, Adam, batch 64, 20000 steps) costs
    params P = d*128 + 128 + 128*128 + 128 + 128 (= 20608 at d = 30);
    forward + backward ~ 6 P FLOPs per example  ->  6 P * 64 * 20000  (= 1.58e11 at d = 30),
plus the Adam update (~10 P per step, 4e9).  We use GD_FLOPS(d) = 6 P * 64 * 20000 + 10 P * 20000 as the budget per fit,
for every n (the networks always train 20000 steps).  A learner reports its own FLOP count (multiply-adds count 2).

LEARNER API.  An object with .name and .fit(X, y, rng) -> dict(predict=callable(Z)->+-1 array, flops=float, [info=dict]).
X: (n, d) float32 in {-1, +1}; y: (n,) float32 in {-1, +1}.  fit may use only (X, y, rng).

USAGE
    from harness import evaluate, report
    res = evaluate(learner, suite="designed", fns=None, ns=None)   # runs every (fn, n, seed); returns a result dict
    report(res)                                                       # prints n* vs the networks and compute ratio
"""
import os, sys, time, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE); sys.path.insert(0, STUDY)
from boolfuncs import make_suite, make_random_suite

SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
NS = [2 ** k for k in range(4, 15)]
N_MAX, N_TEST = 16384, 4096


def gd_flops(d, N=128, batch=64, steps=20000):
    P = d * N + N + N * N + N + N
    return 6 * P * batch * steps + 10 * P * steps


def fn_seed(name):
    return int.from_bytes(name.encode(), "little") % (2 ** 31)


def suite_targets(suite, d=30):
    if suite == "designed":
        return make_suite(d), os.path.join(SCR, "results" + ("" if d == 30 else f"_d{d}")), [0, 1, 2]
    if suite == "random":
        return make_random_suite(d), os.path.join(SCR, "results_random"), [0, 1]
    raise ValueError(suite)


def train_data(fn, name, seed, n, d):
    rng = np.random.default_rng([fn_seed(name), seed])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(N_MAX, d))[:n]
    return X, fn(X).astype(np.float32)


def test_data(fn, name, d):
    rng = np.random.default_rng([fn_seed(name), 10 ** 6])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(N_TEST, d))
    return X, fn(X).astype(np.float32)


def nn_reference(name, results_dir):
    """Networks' final test error [n_index, seed] on the NS grid (Adam, fixed training set), or None."""
    p = os.path.join(results_dir, f"fixed_adam_{name}.npz")
    if not os.path.exists(p):
        return None
    z = np.load(p); ns = [int(v) for v in z["ns"]]
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
    seeds = sorted(set(int(s) for s in z["net_s"]))
    err = np.full((len(NS), len(seeds)), np.nan)
    for a, n in enumerate(NS):
        if n in ns:
            for b, s in enumerate(seeds):
                err[a, b] = z["test_err"][-1, I[(n, s)]]
    return err


def nstar(ns, err_by_n, thr=0.1):
    e = np.asarray(err_by_n, dtype=float)
    for i in range(len(e)):
        if not np.isnan(e[i]) and e[i] <= thr:
            if i == 0:
                return float(ns[0])
            if np.isnan(e[i - 1]):
                return float(ns[i])
            f = (e[i - 1] - thr) / max(e[i - 1] - e[i], 1e-12)
            return float(2 ** (np.log2(ns[i - 1]) + f * (np.log2(ns[i]) - np.log2(ns[i - 1]))))
    return float("inf")


def evaluate(learner, suite="designed", fns=None, ns=None, seeds=None, d=30, targets=None, results_dir=None, verbose=True):
    """targets: optional dict name -> dict(fn=callable) to evaluate on (e.g. held-out targets); results_dir for their
    network reference."""
    if targets is None:
        targets, rdir, sds = suite_targets(suite, d)
    else:
        rdir, sds = results_dir, [0, 1, 2]
    seeds = seeds or sds
    ns = ns or NS
    fns = fns or list(targets)
    out = dict(learner=learner.name, suite=suite, d=d, ns=ns, seeds=seeds, gd_flops=gd_flops(d), fns={})
    for name in fns:
        fn = targets[name]["fn"]
        Xte, yte = test_data(fn, name, d)
        err = np.full((len(ns), len(seeds)), np.nan); fl = np.zeros_like(err); wt = np.zeros_like(err)
        for a, n in enumerate(ns):
            for b, s in enumerate(seeds):
                X, y = train_data(fn, name, s, n, d)
                t0 = time.process_time()
                fit = learner.fit(X, y, np.random.default_rng([fn_seed(name), s, n, 77]))
                wt[a, b] = time.process_time() - t0
                pred = np.asarray(fit["predict"](Xte))
                err[a, b] = float(np.mean(pred != yte)); fl[a, b] = float(fit.get("flops", np.nan))
        ref = nn_reference(name, rdir) if rdir else None
        out["fns"][name] = dict(err=err.tolist(), flops=fl.tolist(), cpu_seconds=wt.tolist(),
                                nn_err=None if ref is None else ref.tolist())
        if verbose:
            r = out["fns"][name]
            ln = nstar(ns, np.nanmean(err, 1)); nn = nstar(NS, np.nanmean(ref, 1)) if ref is not None else float("nan")
            print(f"{name:12s} n* learner {ln:8.0f}  networks {nn:8.0f}   max FLOPs/GD {np.nanmax(fl) / out['gd_flops']:.2e}   "
                  f"cpu {np.nanmax(wt):.2f}s", flush=True)
    return out


def report(res, file=None):
    L = [f"## {res['learner']} on the {res['suite']} suite (d = {res['d']})", "",
         "| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |",
         "|---|---|---|---|---|---|"]
    ratios, flr, wins, losses = [], [], 0, 0
    ns = res["ns"]
    for name, r in res["fns"].items():
        err = np.array(r["err"]); ln = nstar(ns, np.nanmean(err, 1))
        nnr = np.array(r["nn_err"]) if r["nn_err"] is not None else None
        nn = nstar(NS, np.nanmean(nnr, 1)) if nnr is not None else float("nan")
        if np.isfinite(ln) and np.isfinite(nn):
            lr = np.log2(ln / nn)
        elif np.isfinite(nn) and not np.isfinite(ln):
            lr = float("inf")
        elif np.isfinite(ln) and not np.isfinite(nn):
            lr = float("-inf")
        else:
            lr = float("nan")
        if np.isfinite(lr):
            ratios.append(lr)
        if lr < -0.25 or lr == float("-inf"):
            wins += 1
        if lr > 0.25 or lr == float("inf"):
            losses += 1
        pick = [ns.index(v) for v in (64, 256, 1024, 4096) if v in ns]
        e_l = " / ".join(f"{np.nanmean(err[i]):.2f}" for i in pick)
        e_n = " / ".join(f"{np.nanmean(nnr[NS.index(ns[i])]):.2f}" for i in pick) if nnr is not None else "–"
        fmax = np.nanmax(np.array(r["flops"])) / res["gd_flops"]; flr.append(fmax)
        f = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"
        L.append(f"| {name} | {f(ln)} | {f(nn)} | {lr:+.2f} | {e_l} ; {e_n} | {fmax:.1e} |")
    cells, worse, sig = 0, [], []
    for name, r in res["fns"].items():
        if r["nn_err"] is None:
            continue
        EL, EN = np.array(r["err"]), np.array(r["nn_err"])
        el, en = np.nanmean(EL, 1), np.nanmean(EN, 1)
        for i, n in enumerate(ns):
            j = NS.index(n) if n in NS else None
            if j is not None and not np.isnan(en[j]):
                cells += 1
                se = np.sqrt(np.nanvar(EL[i], ddof=1) / EL.shape[1] + np.nanvar(EN[j], ddof=1) / np.sum(~np.isnan(EN[j])))
                if el[i] > en[j] + 0.02:
                    worse.append(f"{name}@{n}: {el[i]:.2f} vs {en[j]:.2f}")
                    if el[i] - en[j] > 2 * se:
                        sig.append(f"{name}@{n}")
    L += ["", f"Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: "
          f"{len(worse)} of {cells}" + (" (" + "; ".join(worse) + ")" if worse else "") + ". "
          f"Of these, by more than 2 standard errors of the seed-to-seed spread: {len(sig)}" + (" (" + ", ".join(sig) + ")" if sig else "") + "."]
    L += ["", f"Mean log2 ratio over targets where both learn: {np.mean(ratios):+.2f} (negative = learner needs less data). "
          f"Learner clearly better (ratio < -0.25 or networks never): {wins}; clearly worse: {losses}; of {len(res['fns'])}. "
          f"Largest compute used: {max(flr):.1e} of a GD run."]
    txt = "\n".join(L)
    if file:
        open(file, "a").write(txt + "\n\n")
    print(txt)
    return dict(mean_log2=float(np.mean(ratios)) if ratios else float("nan"), wins=wins, losses=losses, max_flops_ratio=float(max(flr)),
                worse_cells=worse, worse_sig=sig, cells=cells)
