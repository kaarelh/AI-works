"""Repeat the interpretability analysis's identity check (check_identity in study/part10/interp/toy_interp.py) on the final
result files: for every seed-0 structure run of v3 and v2 in study/part10/interp/results/toy_final/{v3,v2}/, compare the
rerun's test error at each analysed n with the seed-0 test error in the evaluation's result file
(study/hybrid/results/toy__<learner>__<suite>.json), as that function does.  Writes check_toy_identity.json next to this file.
usage: python3 check_toy_identity.py"""
import os, json, glob
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.join(os.path.dirname(HERE), "study")
RUNS = os.path.join(STUDY, "part10", "interp", "results", "toy_final")
RES = os.path.join(STUDY, "hybrid", "results")
FILES = {"v3": ["p10_sum-perm"], "v2": ["hyb_portfolio2-perm", "p9_sum-perm"]}    # as toy_interp.NSTAR_FILES


def check(tag):
    per = {}
    for p in sorted(glob.glob(os.path.join(RUNS, tag, "*__s0.json"))):
        S = json.load(open(p)); su, tg = S["suite"], S["target"]
        for nm in FILES[tag]:
            q = os.path.join(RES, f"toy__{nm}__{su}.json")
            if not os.path.exists(q):
                continue
            D = json.load(open(q)); f = D["fns"].get(tg)
            if f is None:
                break
            r = per.setdefault(su, dict(cells=0, equal=0, differ=[]))
            for c in S["cells"]:
                if c["n"] in D["ns"]:
                    e = f["err"][D["ns"].index(c["n"])][0]
                    if e is None or not np.isfinite(e):
                        continue
                    r["cells"] += 1
                    if abs(e - c["err"]) < 1e-9:
                        r["equal"] += 1
                    else:
                        r["differ"].append([tg, c["n"], e, c["err"]])
            break
    return dict(per_suite=per, cells=sum(r["cells"] for r in per.values()), equal=sum(r["equal"] for r in per.values()))


if __name__ == "__main__":
    out = {tag: check(tag) for tag in FILES}
    json.dump(out, open(os.path.join(HERE, "check_toy_identity.json"), "w"), indent=1)
    for tag, r in out.items():
        print(tag, f"{r['equal']} of {r['cells']} cells equal;",
              ", ".join(f"{su} {v['equal']}/{v['cells']}" for su, v in sorted(r["per_suite"].items())))
