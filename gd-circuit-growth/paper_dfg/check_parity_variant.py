"""Check for the d-scaling figure (sections/results.tex, fig:dscale): on the parities of the designed suite at the smallest
grid sizes, which variant DFG v1.3 alone keeps (0 = default, 1 = forced, by its own small-n cross-validation) and its test
error, refitted with the harness's exact training sets, fit rng and column permutation (discrete_learner/harness.evaluate
and harness.Permuted).  Every refitted test error is compared with the one stored in the Part 11 result file, so the
replication itself is checked.  Each fit also records its training set's label mean ybar and n (1 - ybar^2), the left side
of the exact pass criterion of THEORY.md P2 (round 0's test passes the parity iff n (1 - ybar^2) > n_thr(k, d)), with n_thr.
Writes check_parity_variant.json next to this file.
usage: OMP_NUM_THREADS=1 python3 check_parity_variant.py      (about 2 minutes, single-threaded)"""
import os, sys, json, math
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ST = os.path.join(os.path.dirname(HERE), "study")
sys.path.insert(0, os.path.join(ST, "discrete_learner")); sys.path.append(ST); sys.path.insert(0, os.path.join(ST, "part11"))
import harness as TH                                             # noqa: E402  the toy harness
import boolfuncs                                                 # noqa: E402
import eval_dfg                                                  # noqa: E402  loads the frozen dfg13.py (md5 asserted)

DFG = eval_dfg.load_dfg13().DFG
RES = os.path.join(ST, "part11", "results")
out = []
for d in (15, 30, 60, 120):
    T = boolfuncs.make_suite(d)
    R = json.load(open(os.path.join(RES, "toy__dfg13-perm__designed.json" if d == 30 else f"toy__dfg13-perm__designed_d{d}.json")))
    for name, ns in (("par2", (16, 32)), ("par3", (16, 32)), ("par4", (32,))):
        if name not in R["fns"]:
            continue
        fn = T[name]["fn"]; Xte, yte = TH.test_data(fn, name, d)
        for n in ns:
            for s in R["seeds"]:
                X, y = TH.train_data(fn, name, s, n, d)
                k = int(name[3:]); ybar = float(np.mean(y))
                D0 = DFG(readout="logit")                                         # the constructor defaults: K, c, delta
                n_thr = 2 * D0.c ** 2 * math.log(4 * D0.K * math.comb(d, k) / D0.delta)   # THEORY.md P2
                rng = np.random.default_rng([TH.fn_seed(name), s, n, 77])         # harness.evaluate's fit rng
                pi = rng.permutation(d)                                           # harness.Permuted draws this first
                o = DFG(readout="logit").fit(X[:, pi], y, rng)
                e = float(np.mean(np.asarray(o["predict"](Xte[:, pi])) != yte))
                ef = R["fns"][name]["err"][R["ns"].index(n)][R["seeds"].index(s)]
                out.append(dict(d=d, target=name, n=n, seed=s, variant=o["info"].get("variant"), cv_errs=o["info"].get("cv_errs"),
                                err=e, err_result_file=ef, same=bool(e == ef), ybar=ybar, n_eff=n * (1 - ybar ** 2), n_thr=n_thr,
                                criterion=bool(n * (1 - ybar ** 2) > n_thr)))
                print(out[-1], flush=True)
summary = dict(fits=len(out), all_same_as_result_files=all(x["same"] for x in out),
               forced_at_16={f"{x['target']}@d={x['d']}": sum(1 for y in out if y["d"] == x["d"] and y["target"] == x["target"]
                                                              and y["n"] == 16 and y["variant"] == 1)
                             for x in out if x["n"] == 16})
json.dump(dict(summary=summary, fits=out), open(os.path.join(HERE, "check_parity_variant.json"), "w"), indent=1)
print(summary)
