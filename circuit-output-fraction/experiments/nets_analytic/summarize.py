"""Merge results/suite.json (rigorous methods) and results/oracle.json
(exhaustive diagnostics) into results/summary.txt.

Columns:
  p          exact failure probability (suite.json; "?" = unknown, d > 30);
             N_MC = 3 ln(2/delta)/(eps^2 p) with eps = 0.1, delta = 0.05
  U_best     the best rigorous upper bound of this module (Chernoff-Hoelder,
             McDiarmid) and the bits of surprise it explains, log2(1/U), out of
             log2(1/p)
  tiltZ, grpZ  masses of the exponential-tilt and group-tilt envelopes
             (speed-up over Monte Carlo = 1/Z; Z >= 1 means none)
  floor1, floor2  decoupling floors (independent singletons / greedy pairs):
             lower limits of every Hoelder/TRW/BL-type decoupled bound
  K_ideal    exact Chernoff value / p: the looseness of the ideal Chernoff
             envelope exp(theta (t - f)) (oracle, enumeration)
  R_h1, R_i1 (sum sd)^2 / Var f and sum Var / Var f for the singleton even-form
             decomposition: exponent-loss factors of Hoelder and of perfect
             independence (Gaussian heuristic: log bound ~ log p / R)
  capK       K of the best ellipsoidal cap (k = 4 directions chosen with
             hindsight) containing all failures (oracle)
  alias      (2/pi) max_i ||W_{:,i}|| / rms_j ||w_j||: the smallest smoothing
             scale of a non-aliased Esseen argument, in units of the spread of
             one pre-activation
  alpha      Dobrushin coefficient bound of exp(-theta f) at theta = 10
"""

import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402


def main():
    S = json.load(open(os.path.join(HERE, "results", "suite.json")))
    O = json.load(open(os.path.join(HERE, "results", "oracle.json"))) if os.path.exists(
        os.path.join(HERE, "results", "oracle.json")) else {}
    lines = []
    hdr = ("%-24s %8s %8s %13s %10s %7s %7s %8s %8s %7s %6s %5s %8s %5s %4s" %
           ("net", "p", "N_MC", "U_best", "bits", "tiltZ", "grpZ", "floor1", "floor2", "K_ideal",
            "R_h1", "R_i1", "capK", "alias", "alpha"))
    lines.append(hdr)
    for r in S:
        net = load_net(os.path.join(HERE, "..", "nets", r["name"] + ".npz"))
        W = net.Ws[0]
        alias = (2 / math.pi) * np.linalg.norm(W, axis=0).max() / math.sqrt(np.mean(np.sum(W ** 2, axis=1)))
        p = r["p"]
        cands = {k: r[k] for k in ("CH_relu1", "CH_even1", "CH_even2", "mcd") if r.get(k) is not None}
        if cands:
            kbest = min(cands, key=cands.get)
            U = math.exp(min(cands[kbest], 0))
            ub = "%.3f %-6s" % (U, kbest.replace("CH_", ""))
            bits = "%.2f/%s" % (-math.log2(U), ("%.1f" % -math.log2(p)) if p else ("inf" if p == 0 else "?"))
        else:
            ub, bits = "-", "-"
        o = O.get(r["name"], {})
        kid = ("%.1f" % (o["chernoff_exact"] / p)) if (o and p) else ("%.1e" % o["chernoff_exact"] if o else "-")
        capk = "-"
        if o.get("cap_Z") and p:
            capk = "%.1e" % (o["cap_Z"][-1] / p)
        f = lambda k, fmt: (fmt % r[k]) if r.get(k) is not None else "-"
        ez = lambda k: ("%.3f" % math.exp(min(r[k], 50))) if r.get(k) is not None else "-"
        lines.append("%-24s %8s %8s %13s %10s %7s %7s %8s %8s %7s %6s %5s %8s %5.2f %4s" % (
            r["name"], ("%.1e" % p) if p is not None else "?", ("%.0e" % r["N_MC"]) if r.get("N_MC") else "-", ub, bits,
            ez("tilt_logZ"), ez("group_logZ"), f("floor1", "%.1e"), f("floor2", "%.1e"), kid,
            ("%.0f" % o["R_holder_1"]) if "R_holder_1" in o else "-",
            ("%.1f" % o["R_indep_1"]) if "R_indep_1" in o else "-", capk, alias,
            f("dobrushin_alpha_theta10", "%.0f")))
    txt = "\n".join(lines)
    print(txt)
    with open(os.path.join(HERE, "results", "summary.txt"), "w") as fh:
        fh.write(txt + "\n")


if __name__ == "__main__":
    main()
