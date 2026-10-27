"""Input branch and bound with CROWN bounds on the suite nets with exact p
(experiments/nets/suite.json, d <= 28).

For every net: the exact count by B&B (no budget), its cost against the
meet-in-the-middle enumeration of the whole cube and against Monte Carlo
(3 ln(2/delta) / (eps^2 p) samples for ratio 1 + eps), and the anytime
interval: deterministic [lo, hi] after a cost budget (in forward-pass equivalents), and the two-sided
interval obtained by sampling inside the undecided subcubes (one hidden
layer, squared loss). Usage: exp_suite.py [--out=FILE] [name filters...];
writes results/suite.json (or FILE; summarize.py merges results/suite*.json).
"""

import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_verify import Bounder, bab, estimate_undecided, mc_cost  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")
os.makedirs(OUT, exist_ok=True)
EPS, DELTA = 0.1, 0.05
TIME_LIMIT = 2400.0  # seconds for the exact run; beyond it the interval is reported


def main(names=None, out_name="suite.json"):
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    path = os.path.join(OUT, out_name)
    done = {r["name"]: r for r in json.load(open(path))} if os.path.exists(path) else {}
    rows = list(done.values())
    for row in suite:
        name = row["name"]
        if "p_exact" not in row or name in done or (names and not any(n in name for n in names)):
            continue
        net = load_net(os.path.join(NETS, name + ".npz"))
        bd = Bounder(net)
        p = row["p_exact"]
        out = dict(name=name, d=row["d"], widths=row["widths"], loss=row["loss"], z=row["z"], p_exact=p,
                   fail_count=row["fail_count"], f0=float(bd.forward(np.zeros((1, row["d"])))[0]), t=bd.t)
        res = bab(net, r_enum=4, min_rate=0.01, bounder=bd, time_limit=TIME_LIMIT)
        S = res.summary()
        S.pop("levels", None)
        out["exact_run"] = S
        out["exact_run_levels"] = res.levels
        out["matches_enumeration"] = bool(res.exact and res.fail == row["fail_count"])
        out["contains_enumeration"] = bool(res.fail <= row["fail_count"] <= res.fail + res.ambiguous + res.undecided)
        out["full_enum_fpe"] = bd.full_enum_flops() / bd.flops_forward
        out["mc_samples"] = mc_cost(p, EPS, DELTA)
        # anytime: budgets
        anyt = []
        rng = np.random.default_rng(11)
        # anytime runs (with sampling) only for the one-hidden-layer squared-loss nets
        budgets = [1e4, 1e5, 1e6, 3e6] if row["d"] <= 24 else [1e5, 1e6, 1e7]
        if len(row["widths"]) > 1 or row["loss"] != "mse":
            budgets = []
        for budget in budgets:
            if budget >= res.fpe:
                break
            rb = bab(net, r_enum=4, min_rate=0.01, max_fpe=budget, bounder=bd)
            ent = dict(budget_fpe=budget, nodes_bounded=rb.nodes_bounded, fpe=rb.fpe, lo=rb.lo, hi=rb.hi,
                       Z_undecided=rb.undecided / 2.0 ** rb.d, seconds=round(rb.seconds, 2))
            if p > 0:
                ent["K_undecided"] = (rb.undecided / 2.0 ** rb.d) / max(p - rb.lo, 1e-300)
                cap = int(min(3e7 if row["d"] <= 24 else 1e7, 8 * mc_cost(p, EPS, DELTA)))
                tw = estimate_undecided(net, rb, EPS, DELTA, rng, max_samples=cap, bounder=bd)
                ent.update(two_sided=[tw.lo, tw.hi], samples=tw.samples, contains=bool(tw.lo <= p <= tw.hi),
                           tight=bool(tw.lo > 0 and tw.hi <= (1 + EPS) * tw.lo),
                           total_fpe=rb.fpe + tw.samples)
            anyt.append(ent)
            print(" ", name, ent, flush=True)
        out["anytime"] = anyt
        print(json.dumps({k: v for k, v in out.items() if k not in ("exact_run_levels", "anytime")}), flush=True)
        rows.append(out)
        json.dump(rows, open(path, "w"), indent=1)


if __name__ == "__main__":
    args = sys.argv[1:]
    out_name = "suite.json"
    if args and args[0].startswith("--out="):
        out_name = args[0][len("--out="):]
        args = args[1:]
    main(args or None, out_name)
