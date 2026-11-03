"""Part 11, Q5 analysis: a PAIRED null for the ablations (post hoc; ABLATIONS.md section 0).

The ablations are paired with DFG alone: the same training sets, the same column permutation and the same
cross-validation folds (all drawn from the fit rng default_rng([fn_seed(t), seed, n, 77])), so an ablation that changes
nothing gives exactly DFG alone's n*.  What a change does is then its own effect plus whatever an arbitrary perturbation
of DFG's path does.  This run measures the second part: DFG alone (the frozen dfg13.py, eval_dfg.make_learner('dfg13',
{}), DFG(readout="logit") inside harness.Permuted, md5 checked), on the SAME training sets (harness.train_data, seed s,
first n rows) and the same test sets, but with a different fit rng, default_rng([fn_seed(t), seed, n, 77, 1]), so a
different column order and different cross-validation folds.  Nothing in the learner changes; the column order is
irrelevant to the target (the inputs are exchangeable) and to DFG's tests (THEORY.md P2), and the folds are arbitrary.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python perm_null.py <suite> [--seeds=0,1] [--fns=a,b] [--part=K]
writes results/toy__dfg13-reperm__<suite>[__partK].json in the harness's format (err, flops, cpu_seconds per n x seed).
"""
import os, sys, json, time
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, P11)
import eval_dfg as E                                                   # noqa: E402  (sets sys.path as the runner does)
TH, boolfuncs = E.TH, E.boolfuncs
OUT = os.path.join(HERE, "results"); os.makedirs(OUT, exist_ok=True)


def targets(suite):
    if suite in E.DL:
        return getattr(boolfuncs, E.DL[suite])(30)
    return TH.suite_targets(suite, 30)[0]


def run(suite, seeds=(0, 1), fns=None, part=None):
    T = targets(suite); fns = fns or list(T); ns = TH.NS
    L = E.make_learner("dfg13", {}, None)                             # md5-checked frozen DFG v1.3, Permuted
    out = dict(learner="dfg13-reperm", suite=suite, d=30, ns=ns, seeds=list(seeds), gd_flops=TH.gd_flops(30), fns={},
               fit_rng="default_rng([fn_seed(t), seed, n, 77, 1])", kw={})
    for t in fns:
        fn = T[t]["fn"]; Xte, yte = TH.test_data(fn, t, 30)
        err = np.full((len(ns), len(seeds)), np.nan); fl = np.zeros_like(err); wt = np.zeros_like(err)
        for a, n in enumerate(ns):
            for b, s in enumerate(seeds):
                X, y = TH.train_data(fn, t, s, n, 30)
                t0 = time.process_time()
                fit = L.fit(X, y, np.random.default_rng([TH.fn_seed(t), s, n, 77, 1]))
                wt[a, b] = time.process_time() - t0
                err[a, b] = float(np.mean(np.asarray(fit["predict"](Xte)) != yte)); fl[a, b] = float(fit["flops"])
        out["fns"][t] = dict(err=err.tolist(), flops=fl.tolist(), cpu_seconds=wt.tolist())
        print(f"{suite} {t:10s} n* {TH.nstar(ns, np.nanmean(err, 1)):8.0f}  cpu {wt.sum():.0f}s", flush=True)
    tag = os.path.join(OUT, f"toy__dfg13-reperm__{suite}" + (f"__part{part}" if part else "") + ".json")
    json.dump(out, open(tag, "w"))
    return out


if __name__ == "__main__":
    a = sys.argv[1:]; opt = {k[2:].split("=", 1)[0]: k.split("=", 1)[1] for k in a if k.startswith("--")}
    pos = [x for x in a if not x.startswith("--")]
    run(pos[0], seeds=[int(s) for s in opt.get("seeds", "0,1").split(",")],
        fns=opt["fns"].split(",") if "fns" in opt else None, part=opt.get("part"))
