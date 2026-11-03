"""Part 11 theory (THEORY.md): the fits of DFG v1.3 ALONE that check_theory.py needs, cached in theory/cache/.

Every fit is part11/interp/dfg_hooks.fit_toy_dfg, i.e. bit for bit the fit part11/eval_dfg.py makes for `dfg13-perm`
(harness training rows, rng default_rng([fn_seed(target), seed, n, 77]), harness.Permuted's column order, the md5-checked
frozen dfg13.py, DFG(readout="logit")); nothing in the learner changes.  Four kinds:

  p3 cells   seed 0, n = 16 ... 16384, the `designed` and `random` targets that the order analysis
             (interp/order/results/cells, seeds 0-2, 11 targets) did not fit.  Per cell, with order_fit's own replay code
             (order_fit.replay_round, split_solves, columns): for every character S of the target's exact Fourier support,
             the z-score of each candidate class at the start of every round of the final fit (z = |mean(r chi_S)| /
             threshold, DFG's own N, subsample m and residual), and the round, route (test / forced / linear block) and
             class by which chi_S became an explicit feature.  Same fields as the order cells.
  p2 cells   the parity cells (par2, par3, par4 at d = 15, 30, 60, 120) at n = 16 and 32: the variant DFG's own paired
             cross-validation chose, the held-out errors, and the characters each fold fit and the final fit hold.
  p1 null    full DFG fits on labels drawn independently of the inputs (iid fair coins), d = 30, 20 fits at each of
             n = 64, 256, 1024, 4096, and 30 fits with skewed labels (iid, P(+1) = 0.85) at n = 128: what the final model
             contains (characters by degree, linear block, spectral features, sum blocks), the variant chosen, and what
             the round-0 log of the final fit admitted.

  p5 cells   the four parity cells at n >= 64 whose FLOP count the parity-path model of check_theory.py does not
             reproduce: what each fit call admitted in round 0.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python theory_fits.py [p3] [p2] [p1] [p5]
"""
import os, sys, json, gzip, math, time, numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); INTERP = os.path.dirname(HERE)
sys.path.insert(0, INTERP); sys.path.insert(0, os.path.join(INTERP, "order"))
import dfg_hooks as H                                                  # noqa: E402
import order_fit as OF                                                 # noqa: E402  (replay_round, split_solves, ...)
TH = H.TH
CACHE = os.path.join(HERE, "cache"); os.makedirs(CACHE, exist_ok=True)
NS = [2 ** k for k in range(4, 15)]
ORDER_CELLS = os.path.join(INTERP, "order", "results", "cells")
ORDER_TARGETS = OF.TARGETS                                             # the 11 designed targets fitted there (seeds 0-2)


def _rnd(v):
    return {kk: (dict((a, (round(b, 5) if isinstance(b, float) else b)) for a, b in vv.items()) if isinstance(vv, dict)
                 else (round(vv, 6) if isinstance(vv, float) else vv)) for kk, vv in v.items()}


def p3_cell(suite, target, n, seed=0, T=None):
    """One fit with the order analysis' replay (order_fit.analyse_cell without the learned-fraction probes)."""
    DM, dfg = OF.frozen()
    T = H.targets(suite) if T is None else T
    with OF.SolveRec() as SR:
        rec = H.fit_toy_dfg(suite, target, n, seed, T=T)
    fin = rec["final"]; pi = np.asarray(rec["pi"]); pinv = np.argsort(pi)
    LS = OF.split_solves(SR.sols, rec["calls"])[-1]
    p = [len(w) for w in LS]; R_ = rec["rounds"]
    F, B, X, y = fin["F"], fin["B"], fin["X"], np.asarray(fin["y"], np.float64)
    fn = T[target]["fn"]; Rr = list(T[target]["relevant"])
    sup, _ = OF.target_support(fn, Rr, 30)
    yhat0 = [c for nm, S, c in sup if not S]
    chars = [(nm, S, c) for nm, S, c in sup if S]
    A = OF.columns(F, B, X)
    hi_flag, scale = rec["calls"][-1]["hi"], rec["calls"][-1]["scale"]
    Fkeys = {}
    for idx, (kind, kk) in enumerate(F):
        if kind == "chi":
            Fkeys.setdefault(tuple(kk), idx)
    replay = {nm: [] for nm, _, _ in chars}; s_rep = []
    for j in range(R_ + 1):
        w = LS[j]; r = y - np.ascontiguousarray(A[:, :p[j]]) @ w; s = math.sqrt(max(float(np.mean(r * r)), 1e-12))
        s_rep.append(s)
        for nm, S, c in chars:
            S_l = tuple(sorted(int(pinv[i]) for i in S))
            if S_l in Fkeys and Fkeys[S_l] < p[j]:
                replay[nm].append(None); continue
            replay[nm].append(_rnd(OF.replay_round(X, y, r, s, n, 30, j, F[:p[j]], w, S_l, hi_flag, scale, dfg, DM)))
    n_new = [e["n_new"] for e in fin["info"]["log"]]
    explicit = {}
    for nm, S, c in chars:
        S_l = tuple(sorted(int(pinv[i]) for i in S)); idx = Fkeys.get(S_l)
        if idx is None:
            explicit[nm] = None; continue
        j = max(k for k in range(R_) if p[k] <= idx)
        how = "test" if idx < p[j] + n_new[j] else "linear-block"
        z = replay[nm][j]["zbest"] if replay[nm][j] else None
        if how == "test" and z is not None and z <= 1.0:
            how = "forced"
        explicit[nm] = dict(round=j, how=how, cls=(replay[nm][j]["best"] if replay[nm][j] else None), z=z)
    s_check = [abs(round(s_rep[j], 4) - fin["info"]["log"][j]["s"]) <= 1.5e-4 for j in range(R_)]
    return dict(suite=suite, target=target, seed=seed, n=n, d=30, err=rec["err"], flops=rec["flops"],
                variant=rec["variant"], cv_errs=rec["cv_errs"], rounds_n=R_, size=rec["size"], pi=[int(v) for v in pi],
                s_replay=[round(v, 6) for v in s_rep], s_check=s_check, chars=[nm for nm, _, _ in chars],
                S=[list(S) for _, S, _ in chars], yhat=[c for _, _, c in chars], yhat0=(yhat0[0] if yhat0 else 0.0),
                deg=[len(S) for _, S, _ in chars], explicit=explicit, replay=replay, identity=H.check_identity(rec), p=p,
                log=rec["log"])


def p3_path(suite, target, n, seed=0):
    return os.path.join(CACHE, "p3", f"{suite}__{target}__n{n}__s{seed}.json.gz")


def p3_targets():
    des = [t for t in H.targets("designed") if t not in ORDER_TARGETS]
    return [("designed", t) for t in des] + [("random", t) for t in H.targets("random")]


def run_p3():
    os.makedirs(os.path.join(CACHE, "p3"), exist_ok=True)
    Ts = {s: H.targets(s) for s in ("designed", "random")}
    for suite, t in p3_targets():
        for n in NS:
            path = p3_path(suite, t, n)
            if os.path.exists(path):
                continue
            t0 = time.process_time(); o = p3_cell(suite, t, n, 0, T=Ts[suite]); o["cpu_seconds"] = time.process_time() - t0
            with gzip.open(path + ".tmp", "wt") as fh:
                json.dump(o, fh)
            os.replace(path + ".tmp", path)
            print(f"p3 {suite}/{t} n={n}: err {o['err']:.4f} rounds {o['rounds_n']} var {o['variant']} "
                  f"id {o['identity'].get('err_equal')}/{o['identity'].get('flops_equal')} s_ok {all(o['s_check'])} "
                  f"cpu {o['cpu_seconds']:.1f}s", flush=True)


# ------------------------------------------------------------------------------------------------ P2: parity cells
P2_CELLS = [(t, d, n) for d in (15, 30, 60, 120) for t in ("par2", "par3", "par4") for n in (16, 32)
            if not (d == 120 and t == "par4")]
P2_SEEDS = {15: [0, 1], 30: [0, 1, 2], 60: [0, 1], 120: [0, 1]}


def p2_cell(t, d, n, seed):
    T = H.targets("designed", d); fn = T[t]["fn"]; L = H.make_learner()
    X, y = TH.train_data(fn, t, seed, n, d); Xte, yte = TH.test_data(fn, t, d)
    pi = np.random.default_rng([TH.fn_seed(t), seed, n, 77]).permutation(d)
    with H.Recorder(type(L.inner)) as R:
        out = L.fit(X, y, np.random.default_rng([TH.fn_seed(t), seed, n, 77]))
    err = float(np.mean(np.asarray(out["predict"](Xte)) != yte))
    calls = []
    for c in R.calls:
        ch = [sorted(int(pi[i]) for i in k) for kind, k in c["F"] if kind == "chi" and k]
        calls.append(dict(n=c["n"], force=c["force"], hi=c["hi"], size=int(c["info"]["size"]), rounds=int(c["info"]["rounds"]),
                          chars=ch[:8], blocks=c["info"]["blocks"][:4], flops=c["flops"]))
    return dict(target=t, d=d, n=n, seed=seed, err=err, flops=float(out["flops"]), variant=out["info"].get("variant"),
                cv_errs=out["info"].get("cv_errs"), true_S=list(range(int(t[-1]))), calls=calls)


def run_p2():
    path = os.path.join(CACHE, "p2_cells.json")
    out = json.load(open(path)) if os.path.exists(path) else {}
    for t, d, n in P2_CELLS:
        for s in P2_SEEDS[d]:
            key = f"{t}__d{d}__n{n}__s{s}"
            if key in out:
                continue
            t0 = time.process_time(); out[key] = p2_cell(t, d, n, s); out[key]["cpu_seconds"] = time.process_time() - t0
            print("p2", key, "err", out[key]["err"], "variant", out[key]["variant"], out[key]["cv_errs"], flush=True)
            json.dump(out, open(path + ".tmp", "w")); os.replace(path + ".tmp", path)


# ------------------------------------------------------------------------------------------------ P1: null fits
P1_NS, P1_REPS, P1_D = [64, 256, 1024, 4096], 20, 30


def p1_data(n, rep, d=P1_D, law="fair"):
    """Null data: X uniform; y independent of X, iid fair coins (law 'fair') or iid with P(+1) = 0.85 ('biased')."""
    if law == "fair":
        rng = np.random.default_rng([20261103, n, rep])
        X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(n, d))
        y = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=n)
    else:
        rng = np.random.default_rng([20261103, n, rep, 85])
        X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(n, d))
        y = np.where(rng.random(n) < 0.85, 1.0, -1.0).astype(np.float32)
    return X, y


def p1_fit(n, rep, d=P1_D, law="fair"):
    """DFG alone on labels independent of the inputs (own rng, not the harness')."""
    X, y = p1_data(n, rep, d, law)
    L = H.make_learner()
    with H.Recorder(type(L.inner)) as R:
        out = L.fit(X, y, np.random.default_rng([20261103, n, rep, 77]))
    fin = R.calls[-1]; F = fin["F"]
    chars = [list(k) for kind, k in F if kind == "chi" and k]
    log0 = fin["info"]["log"][0] if fin["info"]["log"] else None
    folds = [c for c in R.calls[:-1]]
    return dict(n=n, rep=rep, law=law, variant=out["info"].get("variant"), cv_errs=out["info"].get("cv_errs"),
                size=int(fin["info"]["size"]), rounds=int(fin["info"]["rounds"]),
                chars_by_deg={str(k): sum(1 for S in chars if len(S) == k) for k in range(1, 13)},
                n_quad=sum(1 for kind, _ in F if kind == "quad"), n_sum_feats=sum(1 for kind, _ in F if kind == "sum"),
                blocks=list(fin["info"]["blocks"]),
                round0=(None if log0 is None else dict(n_new=log0["n_new"], new=[list(S) for S in log0["new"]],
                                                       blocks=log0["blocks"])),
                rounds_log=[dict(round=e["round"], n_new=e["n_new"], blocks=e["blocks"]) for e in fin["info"]["log"]],
                folds_nonempty=sum(1 for c in folds if c["info"]["size"] > 1),
                folds_default_nonempty=sum(1 for c in folds if c["info"]["size"] > 1 and not c["force"]),
                n_folds=len(folds), flops=float(out["flops"]))


P1B_NS, P1B_REPS = [128], 30                                          # skewed labels, just above the n >= 4 d gate


def run_p1():
    path = os.path.join(CACHE, "p1_null_fits.json")
    out = json.load(open(path)) if os.path.exists(path) else {}
    plan = [(n, rep, "fair") for n in P1_NS for rep in range(P1_REPS)] + [(n, rep, "biased") for n in P1B_NS for rep in range(P1B_REPS)]
    for n, rep, law in plan:
            key = f"n{n}__r{rep}" + ("" if law == "fair" else f"__{law}")
            if key in out:
                continue
            t0 = time.process_time(); out[key] = p1_fit(n, rep, law=law); out[key]["cpu_seconds"] = time.process_time() - t0
            o = out[key]
            print("p1", key, "variant", o["variant"], o["cv_errs"], "size", o["size"], "round0", o["round0"], flush=True)
            json.dump(out, open(path + ".tmp", "w")); os.replace(path + ".tmp", path)


# ------------------------------------------------------------------------------------------------ P5: odd FLOP cells
P5_CELLS = [("par4", 30, 256, 1), ("par4", 60, 512, 1), ("par3", 30, 16384, 0), ("par3", 60, 8192, 1)]


def run_p5():
    """The parity cells at n >= 64 whose FLOP count the parity-path model does not reproduce: what each fit call
    admitted in round 0 (original coordinates)."""
    path = os.path.join(CACHE, "p5_cells.json")
    out = json.load(open(path)) if os.path.exists(path) else {}
    for t, d, n, s in P5_CELLS:
        key = f"{t}__d{d}__n{n}__s{s}"
        if key in out:
            continue
        T = H.targets("designed", d); fn = T[t]["fn"]; L = H.make_learner()
        X, y = TH.train_data(fn, t, s, n, d)
        pi = np.random.default_rng([TH.fn_seed(t), s, n, 77]).permutation(d)
        with H.Recorder(type(L.inner)) as R:
            o = L.fit(X, y, np.random.default_rng([TH.fn_seed(t), s, n, 77]))
        calls = []
        for c in R.calls:
            lg = c["info"]["log"]
            calls.append(dict(n=c["n"], force=c["force"], hi=c["hi"], size=int(c["info"]["size"]),
                              rounds=int(c["info"]["rounds"]), flops=c["flops"],
                              round0=(None if not lg else dict(new=[sorted(int(pi[i]) for i in S) for S in lg[0]["new"]],
                                                              blocks=lg[0]["blocks"]))))
        out[key] = dict(flops=float(o["flops"]), variant=o["info"].get("variant"), calls=calls,
                        calls_with_linear=sum(1 for c in calls if c["round0"] and "linear" in c["round0"]["blocks"]))
        print("p5", key, "calls with a linear block in round 0:", out[key]["calls_with_linear"], flush=True)
        json.dump(out, open(path + ".tmp", "w")); os.replace(path + ".tmp", path)


if __name__ == "__main__":
    what = sys.argv[1:] or ["p2", "p1", "p3", "p5"]
    if "p5" in what:
        run_p5()
    if "p2" in what:
        run_p2()
    if "p1" in what:
        run_p1()
    if "p3" in what:
        run_p3()
