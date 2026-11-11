"""Check for the failure analysis (sections/interp.tex, sec:interp-fail): h5s1 = [signed 9-input sum in A] xor x10 x11
(dlheld5), which DFG v1.3 alone fits exactly at n = 16384 in seeds 0 and 2 and nowhere else.  Refits DFG alone exactly as
the evaluation does (study/part11/interp/dfg_hooks.fit_toy_dfg: the harness's training rows, fit rng and column
permutation, the md5-checked frozen dfg13.py) at n = 8192 and 16384 for seeds 0, 1, 2; checks each refitted test error
against the Part 11 result file; and records the model's leading terms, the round log, whether the modulating pair
chi[x10, x11] is a feature, and the pair's round-0 statistic z = |mean(r chi)| / (s sqrt(2 ln(4 K C(30, 2) / delta) / n))
on the training rows (r = y - w0, s = rms(r): THEORY.md P3a's exact round-0 test; it does not depend on the column order).
Writes check_h5s1.json next to this file.
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python3 check_h5s1.py      (about a minute, single-threaded)"""
import os, sys, json, math
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
INTERP = os.path.join(os.path.dirname(HERE), "study", "part11", "interp")
sys.path.insert(0, INTERP)
import dfg_hooks as H                                            # noqa: E402  the shared, identity-checked fit wrapper

TH = H.TH
SUITE, TARGET, PAIR = "dlheld5", "h5s1", [9, 10]                 # chi[x10, x11], original 0-based inputs
K, DELTA, D = 4, 0.1, 30
T = H.targets(SUITE, D)
out = []
for n in (8192, 16384):
    for s in (0, 1, 2):
        rec = H.fit_toy_dfg(SUITE, TARGET, n, s, T=T)
        idn = H.check_identity(rec)
        X, y = TH.train_data(T[TARGET]["fn"], TARGET, s, n, D)
        X = np.asarray(X, np.float64); y = np.asarray(y, np.float64)
        w0 = y.sum() / (n + 1e-9); r = y - w0; sres = math.sqrt(max(float(np.mean(r * r)), 1e-12))
        v = float(np.mean(r * X[:, PAIR[0]] * X[:, PAIR[1]]))
        thr = sres * math.sqrt(2 * math.log(4 * K * math.comb(D, 2) / DELTA) / n)
        pair = [t for t in rec["terms"] if t["kind"] == "chi" and t["S"] == PAIR]
        first_round = next((e["round"] for e in rec["log"] if "chi[x10,x11]" in e["new"]), None)
        out.append(dict(n=n, seed=s, err=rec["err"], err_equal_result_file=idn.get("err_equal"), variant=rec["variant"],
                        size=rec["size"], rounds=rec["rounds"], pair_round0_z=abs(v) / thr, pair_round0_v=v,
                        pair_is_feature=bool(pair), pair_share=pair[0]["share"] if pair else None,
                        pair_admitted_in_round=first_round,
                        top_terms=[[t["kind"], t["desc"], round(t["share"], 3)] for t in rec["terms"][:6]],
                        log=[dict(round=e["round"], n_new=e["n_new"], new=e["new"][:6], blocks=e["blocks"]) for e in rec["log"]]))
        print({k: out[-1][k] for k in ("n", "seed", "err", "err_equal_result_file", "variant", "size", "pair_round0_z",
                                       "pair_is_feature", "pair_admitted_in_round")}, out[-1]["top_terms"][:3], flush=True)
summary = dict(fits=len(out), all_equal_result_file=all(x["err_equal_result_file"] for x in out),
               err0=[[x["n"], x["seed"]] for x in out if x["err"] == 0],
               pair_feature=[[x["n"], x["seed"]] for x in out if x["pair_is_feature"]],
               pair_round0_pass=[[x["n"], x["seed"]] for x in out if x["pair_round0_z"] > 1])
json.dump(dict(summary=summary, fits=out), open(os.path.join(HERE, "check_h5s1.json"), "w"), indent=1, default=float)
print(summary)
