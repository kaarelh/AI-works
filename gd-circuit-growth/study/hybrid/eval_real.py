"""Score a learner on standard datasets (learning curves, 3 seeds) -> study/standard_tasks/results/<learner>__<ds>.json.
usage: python eval_real.py <module:Class[:kwargs]> <ds,ds,...> [--quick]   (--quick: n <= 3000, seeds 0-1; writes
results with learner name suffixed '-quick')."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common
spec, names = sys.argv[1], sys.argv[2].split(",")
quick = "--quick" in sys.argv
L = common.load_learner(spec)
if quick:
    for ds in names:
        D = common.SH.DATA.load(ds)
        common.SH.evaluate(L, [ds], ns=[n for n in common.SH.DATA.grid(D) if n <= 3000], seeds=(0, 1), tag=L.name + "-quick")
else:
    common.SH.evaluate(L, names)
