"""Merge results/suite.json (rigorous methods), results/perturb_map.json
(certified perturb-and-MAP) and results/oracle.json (exhaustive diagnostics)
into results/summary.txt: two tables.

Table A: the rigorous methods against the exact p and Monte Carlo.
  p          exact failure probability ("?" = unknown, d > 30);
  N_MC       3 ln(2/delta)/(eps^2 p), eps = 0.1, delta = 0.05: Monte Carlo
             samples for a ratio-(1+eps) interval
  U_dec      the best decoupled analytic upper bound (Chernoff-Hoelder relu or
             even form, singletons or pairs; McDiarmid), certified, and the
             bits it explains, log2(1/U) out of log2(1/p)
  U_pm       the certified perturb-and-MAP bound (perturb_map.py, delta =
             0.05) and its bits; its cost is `calls` MAP calls (here each is
             an enumeration of the cube)
  tiltZ grpZ spZ   masses of the three envelope families with exact mass and
             exact sampler (tilt, group tilt, sign-pattern); an envelope of mass
             Z costs about Z times Monte Carlo (Z >= 1: no gain)
Tables C-I: certified perturb-and-MAP (perturb_map.py), cube-certified tilt
envelopes (cube_tilt.py), sign-pattern envelopes (signpattern.py), the
small-ball / few-form ceilings (smallball.py, few_forms.py), MAP-call costs
(map_cost.py), narrow nets (narrow.py), perturb-and-MAP on toy events
(pmap_toy.py). The signpat_* fields of results/suite.json come from an earlier
optimiser (n_split = 16 only) and are superseded by results/signpattern.json.
Table B: why (oracle diagnostics, d <= 28).
  F0-t       F(0) - t: < 0 bars every positive mixture of tilts with
             domination valid on R^d (box barrier)
  sym-t      min_x (F(x)+F(-x))/2 - t: < 0 bars every tilt envelope from an
             affine minorant valid on the cube (cube barrier)
  bestTiltZ  the best tilt envelope with exact cube domination (oracle)
  floor1/2   decoupling floors (independent singletons / greedy pairs): lower
             limits of every Hoelder/TRW/BL/Finner-type decoupled bound
  R_h1 R_i1  comonotone / independent variance inflation of the singleton
             even-form decomposition (Gaussian heuristic: log U ~ log p / R)
  K_ideal    exact Chernoff value / p (the ideal Chernoff envelope)
  pm_est     perturb-and-MAP estimate theta t + E R at the oracle's best
             configuration (a few dozen samples; not certified)
  mom(2k)    the best exact-moment Markov bound and its order 2k
  capK       K of the best ellipsoidal cap in 4 hindsight directions (d = 24)
  alpha      Dobrushin coefficient bound at the Chernoff tilt theta*
"""

import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))


def load(name):
    p = os.path.join(HERE, "results", name)
    return json.load(open(p)) if os.path.exists(p) else ([] if name in ("suite.json", "narrow.json") else {})


def fmt_bits(U, p):
    if U is None:
        return "-"
    b = -math.log2(max(U, 1e-300))
    tot = ("%.1f" % -math.log2(p)) if p else ("inf" if p == 0 else "?")
    return "%.2f/%s" % (b, tot)


def main():
    S = load("suite.json")
    PM = load("perturb_map.json")
    SP = load("signpattern.json")
    O = {}
    for fn in sorted(os.listdir(os.path.join(HERE, "results"))):
        if fn.startswith("oracle") and fn.endswith(".json"):
            O.update(load(fn))
    A = []
    A.append("%-24s %8s %7s %16s %11s %10s %11s %6s %7s %7s %7s" % (
        "net", "p", "N_MC", "U_dec", "bits", "U_pm", "bits", "calls", "tiltZ", "grpZ", "spZ"))
    for r in S:
        p = r["p"]
        cands = {k: r[k] for k in ("CH_relu1", "CH_even1", "CH_even2", "mcd") if r.get(k) is not None}
        if cands:
            kb = min(cands, key=cands.get)
            U = math.exp(min(cands[kb], 0))
            ud = "%.3f %-6s" % (U, kb.replace("CH_", ""))
            bd = fmt_bits(U, p)
        else:
            ud, bd = "-", "-"
        pm = PM.get(r["name"])
        upm = ("%.2e" % pm["U"]) if pm else "-"
        bpm = fmt_bits(pm["U"], p) if pm else "-"
        calls = str(pm["map_calls"]) if pm else "-"
        ez = lambda k: ("%.3g" % math.exp(min(r[k], 50))) if r.get(k) is not None else "-"
        A.append("%-24s %8s %7s %16s %11s %10s %11s %6s %7s %7s %7s" % (
            r["name"], ("%.1e" % p) if p is not None else "?", ("%.0e" % r["N_MC"]) if r.get("N_MC") else "-",
            ud, bd, upm, bpm, calls, ez("tilt_logZ"), ez("group_logZ"),
            ("%.3g" % SP[r["name"]]["Z"]) if r["name"] in SP else "-"))
    B = []
    B.append("%-24s %7s %7s %9s %8s %8s %5s %5s %8s %8s %13s %8s %4s" % (
        "net", "F0-t", "sym-t", "bestTiltZ", "floor1", "floor2", "R_h1", "R_i1", "K_ideal", "pm_est", "mom(2k)",
        "capK", "alpha"))
    for r in S:
        o = O.get(r["name"])
        if not o:
            continue
        p = r["p"]
        f = lambda k, fm: (fm % r[k]) if r.get(k) is not None else "-"
        kid = ("%.1f" % (o["chernoff_exact"] / p)) if p else ("%.1e" % o["chernoff_exact"])
        pms = o.get("pmap", [])
        pm_est = ("%.1e" % math.exp(min(q["log_bound_est"] for q in pms))) if pms else "-"
        mom = "%.1e(%d)" % (o["moment_best"], o["moment_order"])
        capk = ("%.1e" % (o["cap_Z"][-1] / p)) if (o.get("cap_Z") and p) else "-"
        B.append("%-24s %7.3f %7.3f %9.3g %8s %8s %5s %5s %8s %8s %13s %8s %4s" % (
            r["name"], o["f0_minus_t"], o["sym_gap"], math.exp(o["best_tilt_logZ"]),
            f("floor1", "%.1e"), f("floor2", "%.1e"),
            ("%.0f" % o["R_holder_1"]) if "R_holder_1" in o else "-",
            ("%.1f" % o["R_indep_1"]) if "R_indep_1" in o else "-",
            kid, pm_est, mom, capk,
            ("%.0f" % o["dobrushin_alpha_theta_star"]) if "dobrushin_alpha_theta_star" in o else "-"))
    C = ["%-24s %9s %9s %7s %6s %6s %9s %11s %9s" % ("net", "p", "U_pm", "U/p", "theta", "block", "calls",
                                                   "bits", "est_U")]
    for nm, r in PM.items():
        C.append("%-24s %9.2e %9.2e %7s %6g %6d %9d %11s %9.2e" % (
            nm, r["p"] or 0, r["U"], ("%.0f" % r["U_over_p"]) if r.get("U_over_p") else "-", r["theta"], r["block"],
            r["map_calls"], fmt_bits(r["U"], r["p"]), math.exp(r["est_log_bound"])))
    CT = load("cube_tilt.json")
    D = ["%-24s %9s %8s %9s %8s %22s %9s %7s %6s" % ("net", "p", "sym-t", "Z", "K", "interval", "samples", "1/Z",
                                                    "calls")]
    for nm, r in CT.items():
        if r.get("barred"):
            D.append("%-24s %9.2e %8.3f %9s" % (nm, r["p"] or 0, r["sym_gap"], "barred"))
            continue
        iv = ("[%.3g, %.3g]" % (r["lo"], r["hi"])) if "lo" in r else "-"
        D.append("%-24s %9.2e %8.3f %9.2e %8s %22s %9s %7.0f %6s" % (
            nm, r["p"] or 0, r["sym_gap"], r["Z"], ("%.3g" % r["K"]) if r.get("K") else "-", iv,
            str(r.get("samples", "-")), 1.0 / r["Z"], r["note"].split(", ")[1].split()[0]))
    E = ["%-24s %9s %7s %9s %4s %22s %9s %11s" % ("net", "p", "F0-t", "Z", "|N|", "interval", "samples", "MC/samp")]
    for nm, r in SP.items():
        iv = ("[%.3g, %.3g]" % (r["lo"], r["hi"])) if "lo" in r else "-"
        sp = ("%.0f" % r["speedup_samples"]) if r.get("speedup_samples") else (
            ("MC UB %.1e" % r["mc_upper_same_N"]) if "mc_upper_same_N" in r else "-")
        E.append("%-24s %9s %7.3f %9.3g %4d %22s %9s %11s" % (
            nm, ("%.2e" % r["p"]) if r["p"] is not None else "?", r["f0_minus_t"], r["Z"], r["n_split"], iv,
            str(r.get("samples", "-")), sp))
    SB = load("smallball.json")
    FF = load("few_forms.json")
    G = ["%-24s %9s %8s %8s %10s %10s %10s" % ("net", "p", "q+", "q+_9999", "Kstar_1", "Kstar_2", "Kstar_3")]
    for nm in SB:
        r, f = SB[nm], FF.get(nm, {})
        ks = [("%.0f" % f[f"best_{k}"]["Kstar"]) if f.get(f"best_{k}") else "-" for k in (1, 2, 3)]
        G.append("%-24s %9.2e %8.4f %8.4f %10s %10s %10s" % (nm, r["p"], r["q_plus"], r["q_plus_9999"], *ks))
    txt = ("Table A: rigorous methods\n" + "\n".join(A) + "\n\nTable B: oracle diagnostics (d <= 28)\n"
           + "\n".join(B) + "\n\nTable C: certified perturb-and-MAP (delta = 0.05)\n" + "\n".join(C)
           + "\n\nTable D: cube-certified tilt envelopes (two-sided, eps = 0.1, delta = 0.05)\n" + "\n".join(D)
           + "\n\nTable E: sign-pattern envelopes (one hidden layer)\n" + "\n".join(E)
           + "\n\nTable F: small-ball decoupling (q+) and hindsight few-form envelopes (K* = Z*/p)\n"
           + "\n".join(G))
    # Table G: MAP-call costs (HiGHS MILP)
    H = ["%-26s %4s %6s %28s %30s" % ("net", "d", "width", "perturbed MAP: s (gap nats)", "min f: s (incumbent / lower)")]
    for nm, r in load("map_cost.json").items():
        cs = ", ".join("%.0f (%.2g)" % (c["seconds"], c["gap_nats"] or 0) for c in r["calls"])
        H.append("%-26s %4d %6s %28s %30s" % (nm, r["d"], r["widths"], cs, "-"))
    for k, r in load("map_cost_scaling.json").items():
        cs = ", ".join("%.0f (%.2g)" % (c["seconds"], c["gap_nats"] or 0) for c in r["calls"])
        H.append("%-26s %4d %6s %28s %30s" % ("own_mse_s1500", r["d"], r["widths"], cs, "-"))
    for k, r in load("map_cost_width.json").items():
        cs = ", ".join("%.0f (%.2g)" % (c["seconds"], c["gap_nats"] or 0) for c in r["calls"])
        mf = r["min_f_problem"]
        H.append("%-26s %4d %6s %28s %30s" % ("own_mse_s1500 z=%.1f" % r["z"], r["d"], r["width"], cs,
                                            "%.0f (%.3f / %.3f)" % (mf["seconds"], r["min_f"], r["min_f_lower"])))
    I = ["%4s %6s %5s %6s %22s %9s" % ("d", "width", "loss", "steps", "DP interval", "exact p")]
    for r in load("narrow.json") or []:
        I.append("%4d %6d %5s %6d %22s %9s" % (r["d"], r["width"], r["loss"], r["steps"],
                                            "[%.3g, %.3g]" % (r["lo"], r["hi"]),
                                            ("%.3g" % r["p_exact"]) if r["p_exact"] is not None else "?"))
    J = ["%6s %10s %10s %10s %10s %10s %10s %10s %10s" % ("d", "cube logp", "bound", "hs2 logp", "bound",
                                                        "hs3 logp", "bound", "ball logp", "bound")]
    for d, r in (load("pmap_toy.json") or {}).items():
        J.append("%6s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f" % (
            d, r["subcube"]["log_p"], r["subcube"]["bound"], r["halfspace_2sqrtd"]["log_p"],
            r["halfspace_2sqrtd"]["bound"], r["halfspace_3sqrtd"]["log_p"], r["halfspace_3sqrtd"]["bound"],
            r["small_ball"]["log_p"], r["small_ball"]["bound"]))
    txt += ("\n\nTable G: cost of one MAP call (HiGHS MILP, time limit 120-600 s)\n" + "\n".join(H)
            + "\n\nTable H: narrow nets, exact DP interval (small_width_interval)\n" + "\n".join(I)
            + "\n\nTable I: perturb-and-MAP on toy events: log p against the bound -E dist(xhat, C)\n"
            + "\n".join(J))
    print(txt)
    with open(os.path.join(HERE, "results", "summary.txt"), "w") as fh:
        fh.write(txt + "\n")


if __name__ == "__main__":
    main()
