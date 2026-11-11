"""Merge target shards written by eval_dfg.py --part=K into results/toy__<learner>__<suite>.json (+ .md), in suite
order.  usage: python merge.py <learner-name, e.g. dfg13-perm> <suite>"""
import os, sys, glob, json
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import eval_dfg as E                                                  # noqa: E402  (toy harness, boolfuncs on the path)
TH, boolfuncs = E.TH, E.boolfuncs
name, suite = sys.argv[1], sys.argv[2]
if suite in E.DL:
    order = list(getattr(boolfuncs, E.DL[suite])(30))
elif suite.startswith("designed_d"):
    order = None
else:
    order = list(TH.suite_targets(suite)[0])
parts = sorted(glob.glob(os.path.join(HERE, "results", f"toy__{name}__{suite}__part*.json")))
P = [json.load(open(p)) for p in parts]
out = dict(P[0]); out["fns"] = {}
for p in P:
    assert (p["ns"], p["seeds"], p["learner"]) == (P[0]["ns"], P[0]["seeds"], P[0]["learner"])
    out["fns"].update(p["fns"])
if order is not None:
    assert sorted(out["fns"]) == sorted(order), (sorted(out["fns"]), sorted(order))
    out["fns"] = {k: out["fns"][k] for k in order}
tag = os.path.join(HERE, "results", f"toy__{name}__{suite}")
json.dump(out, open(tag + ".json", "w")); open(tag + ".md", "w").close(); TH.report(out, file=tag + ".md")
for p in parts:
    os.remove(p); os.remove(p[:-5] + ".md")
