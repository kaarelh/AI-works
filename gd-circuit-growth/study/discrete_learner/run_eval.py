"""Evaluate a learner on a suite against the networks; writes results/<learner>__<suite>.json and appends the table to
results/<learner>__<suite>.md.   usage: python run_eval.py <module:Class[:kwargs-json]> <suite> [fns]"""
import sys, os, json, importlib
import harness as H
mod, cls, *kw = sys.argv[1].split(":", 2)
L = getattr(importlib.import_module(mod), cls)(**(json.loads(kw[0]) if kw else {}))
suite = sys.argv[2]; fns = sys.argv[3].split(",") if len(sys.argv) > 3 else None
os.makedirs("results", exist_ok=True)
if suite == "dlheld":
    from boolfuncs import make_dl_heldout_suite
    res = H.evaluate(L, suite=suite, fns=fns, targets=make_dl_heldout_suite(30), results_dir=os.path.join(H.SCR, "results_dlheld"))
elif suite.startswith("designed_d"):
    d = int(suite[len("designed_d"):]); rdir = os.path.join(H.SCR, f"results_d{d}")
    fns = fns or sorted(f[len("fixed_adam_"):-4] for f in os.listdir(rdir) if f.startswith("fixed_adam_"))
    res = H.evaluate(L, suite="designed", fns=fns, d=d, seeds=[0, 1]); res["suite"] = suite
else:
    res = H.evaluate(L, suite=suite, fns=fns)
tag = f"results/{L.name}__{suite}"
json.dump(res, open(tag + ".json", "w"))
open(tag + ".md", "w").close()
H.report(res, file=tag + ".md")
