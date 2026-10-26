"""Score a learner on a toy suite against the study's networks.
usage: python eval_toy.py <module:Class[:kwargs]> <designed|random|dlheld|dlheld2|dlheld3> [fns] [--quick]
--quick: n in {64, 256, 1024, 4096}, seeds 0-1 (development).  Writes results/toy__<learner>__<suite>.json (+ .md);
--part=K (a shard of the targets, run in parallel): writes ...__<suite>__partK.json; merge with merge_toy.py.
--perm: each fit sees its input columns in a random order (discrete_learner/harness.Permuted; learner name + '-perm').
Every suite puts the relevant inputs first, and tie-breaking by column index would otherwise favour the learner."""
import os, sys, json
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common
import importlib.util                                       # the toy harness (a different module also named 'harness')
_spec = importlib.util.spec_from_file_location("toy_harness", os.path.join(common.STUDY, "discrete_learner", "harness.py"))
TH = importlib.util.module_from_spec(_spec); _spec.loader.exec_module(TH)
spec, suite = sys.argv[1], sys.argv[2]
args = [a for a in sys.argv[3:] if not a.startswith("--")]; quick = "--quick" in sys.argv
fns = args[0].split(",") if args else None
L = common.ToyAdapter(common.load_learner(spec))
if "--perm" in sys.argv:
    L = TH.Permuted(L)
kw = dict(ns=[64, 256, 1024, 4096], seeds=[0, 1]) if quick else {}
if suite in ("dlheld", "dlheld2", "dlheld3"):
    import boolfuncs
    mk = {"dlheld": boolfuncs.make_dl_heldout_suite, "dlheld2": boolfuncs.make_dl_heldout2_suite,
          "dlheld3": boolfuncs.make_dl_heldout3_suite}[suite]
    res = TH.evaluate(L, suite=suite, fns=fns, targets=mk(30), results_dir=os.path.join(TH.SCR, "results_" + suite), **kw)
else:
    res = TH.evaluate(L, suite=suite, fns=fns, **kw)
os.makedirs(os.path.join(HERE, "results"), exist_ok=True)
part = [a.split("=", 1)[1] for a in sys.argv[3:] if a.startswith("--part=")]
tag = os.path.join(HERE, "results", f"toy__{L.name}__{suite}" + ("__quick" if quick else "") + (f"__part{part[0]}" if part else ""))
json.dump(res, open(tag + ".json", "w"))
open(tag + ".md", "w").close(); TH.report(res, file=tag + ".md")
