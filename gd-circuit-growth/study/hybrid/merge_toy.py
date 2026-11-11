"""Merge target shards written by eval_toy.py --part=K into results/toy__<learner>__<suite>.json (+ .md), in suite order.
usage: python merge_toy.py <learner> <suite>"""
import os, sys, glob, json
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common
import importlib.util
_spec = importlib.util.spec_from_file_location("toy_harness", os.path.join(common.STUDY, "discrete_learner", "harness.py"))
TH = importlib.util.module_from_spec(_spec); _spec.loader.exec_module(TH)
import boolfuncs                                            # (on the path once the toy harness is loaded)
name, suite = sys.argv[1], sys.argv[2]
order = list({"dlheld": boolfuncs.make_dl_heldout_suite, "dlheld2": boolfuncs.make_dl_heldout2_suite,
              "dlheld3": boolfuncs.make_dl_heldout3_suite, "dlsymdev": boolfuncs.make_dl_symdev_suite,
              "dlheld4": boolfuncs.make_dl_heldout4_suite, "dlheld5": boolfuncs.make_dl_heldout5_suite,
          "dlheld6": boolfuncs.make_dl_heldout6_suite,
          "dlfamdev": boolfuncs.make_dl_famdev_suite, "dlheld7": boolfuncs.make_dl_heldout7_suite}[suite](30)) if suite.startswith("dl") else list(TH.suite_targets(suite)[0])
parts = sorted(glob.glob(os.path.join(HERE, "results", f"toy__{name}__{suite}__part*.json")))
P = [json.load(open(p)) for p in parts]
out = dict(P[0]); out["fns"] = {}
for p in P:
    assert (p["ns"], p["seeds"], p["learner"]) == (P[0]["ns"], P[0]["seeds"], P[0]["learner"])
    out["fns"].update(p["fns"])
assert sorted(out["fns"]) == sorted(order), (sorted(out["fns"]), sorted(order))
out["fns"] = {k: out["fns"][k] for k in order}
tag = os.path.join(HERE, "results", f"toy__{name}__{suite}")
json.dump(out, open(tag + ".json", "w")); open(tag + ".md", "w").close(); TH.report(out, file=tag + ".md")
for p in parts:
    os.remove(p); os.remove(p[:-5] + ".md")
