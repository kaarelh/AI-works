"""Summaries for the MNIST / Fashion-MNIST runs.

T1 (bound on g) and T2 (bound on f with unlabeled inputs) are selected over
all configurations of one trained f and one code family.  The Occam part
needs no correction for the selection (it holds for all codes at once); the
disagreement part is recomputed with a union bound over the K configurations
and the design menu of accounting.py: delta/(2 K 16); descriptions pay the
4 design bits.
"""
import collections
import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
from cgb.bounds import occam_bound, cp_upper
sys.path.insert(0, HERE)
from accounting import t1_bound, t2_bound  # noqa: E402

ROOT = os.path.join(HERE, "..", "..")


def key(r):
    """One trained network f and one code family (init scheme and reference)."""
    return (r["data"], tuple(r["widths"]), r["seed"], r["epochs"], r["wd"], r["lr"], r["init_scale"],
            r.get("init", "random"), r.get("code_ref", "init"))


def main(path, delta=0.05):
    rows = [json.loads(l) for l in open(path)]
    groups = collections.defaultdict(list)
    for r in rows:
        groups[key(r)].append(r)
    out = ["| data | widths | params | train err f | test err f | float32 Occam | VC | configs K | "
           "best T1 (bound on g) | bits | test err g | best T2 (bound on f, unlabeled) | bits | Pr[f≠g] on test inputs | config |",
           "|" + "---|" * 15]
    for k, g in groups.items():
        K = len(g)
        m = 60000
        assert len({(r["train_err_f"], r["test_err_f"]) for r in g}) == 1, "group mixes networks"
        best1 = min(g, key=t1_bound)
        t2 = lambda r: t2_bound(r, K)
        best2 = min(g, key=t2)
        out.append(f"| {k[0]} | {list(k[1])} | {g[0]['params']} | {g[0]['train_err_f']:.4f} | {g[0]['test_err_f']:.4f} | "
                   f"{g[0]['baseline_occam32']:.2f} | {g[0]['baseline_vc_W']:.2f} | {K} | {t1_bound(best1):.4f} | "
                   f"{best1['bits']:.0f} | {best1['test_err_g']:.4f} | {t2(best2):.4f} | {best2['bits']:.0f} | "
                   f"{best2['dis_test_inputs']:.4f} | {best2['basis']}/{best2['mode']}/rel={best2['rel']}/lam={best2['lam']} |")
    return "\n".join(out)


if __name__ == "__main__":
    print(main(sys.argv[1]))
