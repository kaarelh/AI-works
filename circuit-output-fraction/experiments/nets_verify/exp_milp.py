"""A stronger (but unsound) deductive engine for comparison: the minimum of f
over the cube by a mixed-integer program, solved by HiGHS (scipy.milp).

For every net: min_x f(x) over {-1,+1}^d with the big-M encoding of the ReLUs
(rareprob.nets_verify.milp_min, integer inputs), time limit TL seconds. The
solver uses floating-point tolerances and its branch-and-cut proof cannot be
checked here, so:
  * a returned point x with f(x) < t (re-evaluated by us, with the rounding
    margin of Bounder) is a checkable WITNESS: p >= 2^-d, sound;
  * "optimal, min >= t" is the solver's claim that p = 0 -- not a
    certificate (a sound version would need an exactly checked proof, e.g. a
    VIPR certificate from an exact MILP solver);
  * the dual bound at the time limit is the solver's (unverified) lower bound
    on min f.
Compared with f(0) - t (the box barrier: if f(0) < t no box relaxation
certifies the root) and with the sound input branch and bound (CROWN,
r_enum = 6, frontier cap 2^24 subcubes, 2^21 for d > 64, cost cap 2e8
forward-pass equivalents) run on the same nets with the same time limit
(field "bab"). Writes results/milp.json.
"""

import json
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_verify import Bounder, bab, milp_min  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")
TL = 180.0


def jobs():
    for d in [16, 24, 32, 48, 64]:
        for s in [1500, 3000]:
            yield f"own_mse_d{d}_w32_s{s}", os.path.join(OUT, f"own_mse_d{d}_w32_s{s}.npz")
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    pick = {"mse_d24_w32_s1500", "mse_d24_w32_s2000", "mse_d28_w64_s1000", "mse_d28_w64_s1500",
            "bce_d28_w32_s100", "bce_d28_w32_s150", "bce_d28_w64x64_s100"}
    for row in suite:
        if row["name"] in pick or row["d"] >= 64:
            yield row["name"], os.path.join(NETS, row["name"] + ".npz")


def main():
    path = os.path.join(OUT, "milp.json")
    out = json.load(open(path)) if os.path.exists(path) else []
    done = {o["name"] for o in out}
    suite = {r["name"]: r for r in json.load(open(os.path.join(NETS, "suite.json")))}
    for name, f in jobs():
        if name in done or not os.path.exists(f):
            continue
        net = load_net(f)
        bd = Bounder(net)
        d = bd.d
        lb, _, _ = bd.bound(np.zeros((1, d)))
        t0 = time.time()
        info = milp_min(net, np.zeros(d), integer=True, time_limit=TL, want_info=True)
        sec = time.time() - t0
        witness = info["x"] is not None and info["f_x"] < bd.pt_fail
        claim_zero = info["status"] == 0 and info["value"] is not None and info["value"] >= bd.t and not witness
        o = dict(name=name, d=d, widths=bd.widths, loss=net.loss, t=bd.t,
                 f0_minus_t=float(bd.forward(np.zeros((1, d)))[0] - bd.t),
                 crown_root_lb_minus_t=float(lb[0] - bd.t), p_exact=suite.get(name, {}).get("p_exact"),
                 milp_status=info["status"], milp_message=info["message"], milp_nodes=info["nodes"],
                 milp_seconds=round(sec, 1), incumbent_f=info["f_x"], dual_bound=info["dual_bound"],
                 witness=bool(witness), solver_claims_p_zero=bool(claim_zero), time_limit=TL,
                 witness_x=info["x"].astype(int).tolist() if witness else None)
        print(json.dumps(o), flush=True)
        out.append(o)
        json.dump(out, open(path, "w"), indent=1)


def add_bab():
    """The sound input branch and bound on the same nets, same time limit."""
    path = os.path.join(OUT, "milp.json")
    out = json.load(open(path))
    for o in out:
        if "bab" in o:
            continue
        name = o["name"]
        f = os.path.join(OUT if name.startswith("own") else NETS, name + ".npz")
        net = load_net(f)
        # cost cap 2e8 fpe (checked before each level, so a level is never started beyond it)
        # and a smaller frontier for d > 64 (memory)
        res = bab(net, r_enum=6, min_rate=0.01, time_limit=TL, batch=1024, max_fpe=2e8,
                  max_frontier=(1 << 24) if net.d <= 64 else (1 << 21))
        o["bab"] = dict(lo=res.lo, hi=res.hi, exact=res.exact, fail=res.fail, fpe=res.fpe, seconds=round(res.seconds, 1),
                        stopped=res.stopped, nodes_bounded=res.nodes_bounded,
                        p_zero_certified=bool(res.exact and res.fail == 0))
        print(name, o["bab"], flush=True)
        json.dump(out, open(path, "w"), indent=1)


if __name__ == "__main__":
    main()
    add_bab()
