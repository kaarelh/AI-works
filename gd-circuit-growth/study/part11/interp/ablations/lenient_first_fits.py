"""Part 11, Q5 (post hoc, added when the independent verification was applied): why `lenient` raises n* on 8 character
targets (ABLATIONS.md section 2).  For each of the 8 and each seed (0, 1), DFG alone's first fit is the first grid n at
which its test error is <= 0.1 (result files); this script refits DFG alone and `lenient` (delta = 0.9) at that cell with
refit.py (the evaluation's fit, bit for bit, through the instrumented copy) and records the variant the cross-validation
chose and whether the linear block entered the final fit.
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python lenient_first_fits.py
       -> results/refits_verif.json (the 32 refits) and results/lenient_first_fits.json (the summary)
"""
import os, sys, json, math
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import refit as RF                                                     # noqa: E402
OUT = os.path.join(HERE, "results", "refits_verif.json")


def res(run, su):
    return json.load(open(os.path.join(P11, "results", f"toy__{run}__{su}.json")))


def main():
    J = json.load(open(os.path.join(HERE, "ablations.json")))
    r = J["ablations"]["lenient"]["ratios"]
    tl = [k for k, v in r.items() if v is not None and J["classes"][k] == "character" and (v == math.inf or (math.isfinite(v) and v > 0.25))]
    recs, rows = [], []
    for k in tl:
        su, t = k.split("/"); R0 = res("dfg13-perm", su); RL = res("dfg13-lenient-perm", su)
        for s in (0, 1):
            e0 = np.array(R0["fns"][t]["err"])[:, R0["seeds"].index(s)]
            n = next(n for n, x in zip(R0["ns"], e0) if x <= 0.1)
            row = dict(target=k, seed=s, n=n)
            for run in ("dfg13-perm", "dfg13-lenient-perm"):
                o = RF.refit(su, t, n, s, run); recs.append(o)
                lin = any(x["origin"] == "linear" for x in o["terms"])
                row[run] = dict(err=o["err"], identical=o["identical"], variant=o["variant"], cv_errs=o["cv_errs"], linear_block=lin)
                print(f"{k:18s} seed {s} n {n:4d} {run:20s} err {o['err']:.3f} identical={o['identical']} variant={o['variant']} "
                      f"cv={o['cv_errs']} linear block={lin}", flush=True)
            rows.append(row)
    RF.save(recs, OUT)
    S = dict(cells=len(rows), first_fit_n={str(n): sum(1 for x in rows if x["n"] == n) for n in sorted({x["n"] for x in rows})},
             dfg_forced=sum(1 for x in rows if x["dfg13-perm"]["variant"] == 1),
             lin_lenient_not_default=sorted({x["target"] for x in rows if x["dfg13-lenient-perm"]["linear_block"] and not x["dfg13-perm"]["linear_block"]}),
             lin_cells=[(x["target"], x["seed"], x["n"]) for x in rows if x["dfg13-lenient-perm"]["linear_block"] and not x["dfg13-perm"]["linear_block"]],
             variant_changed=[(x["target"], x["seed"], x["n"]) for x in rows if x["dfg13-perm"]["variant"] != x["dfg13-lenient-perm"]["variant"]],
             all_identical=all(x[run]["identical"] for x in rows for run in ("dfg13-perm", "dfg13-lenient-perm")), rows=rows)
    json.dump(S, open(os.path.join(HERE, "results", "lenient_first_fits.json"), "w"), indent=1)
    print({k: v for k, v in S.items() if k != "rows"})


if __name__ == "__main__":
    main()
