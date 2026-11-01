"""Print the tables of results/*.json and write results/summary.txt.

Table N4 (barrier_table.json): why relaxation, tilting and decoupling fail.
  F0-t       F(0) - t (exact): < 0 bars every positive mixture of full-support
             tilts whose domination is proved on the box (box barrier), and
             every box relaxation at the root
  boxmin-t   smallest f found at a real point of the box, minus t ('*': the
             MILP solver reports it optimal, a floating-point claim, not a
             certificate; otherwise an incumbent at the time limit)
  s*-t       min_x (F(x)+F(-x))/2 - t ('~': an upper bound by local search,
             d > 28): < 0 bars every tilt from an affine minorant valid on the
             cube (cube barrier)
  floor1/2   decoupling floors (independent singletons / greedy pairs, even
             form): lower limits of every Hoelder / TRW / BL / Finner bound
  U_hold     the best certified Chernoff-Hoelder bound; U_mcd McDiarmid
  tiltZ spZ  masses of the box-relaxed tilt and sign-pattern envelopes (exact
             mass and sampler; Z >= 1: no gain over Monte Carlo)
  gap8 mrg8  medians over random 8-dimensional subcubes of (cube min - CROWN
             bound) and of (cube min - t); r*: CROWN r50
  L1         level-1 Walsh weight sum_i fhat(i)^2 / Var f ('~': estimate)
Table A: certified upper bounds against the exact p and Monte Carlo
  (N_MC = 3 ln(2/delta) / (eps^2 p), eps = 0.1, delta = 0.05; an upper bound U
  is worth about ln(1/delta) / U one-sided Monte Carlo samples), with the
  certified perturb-and-MAP bound (perturb_map.py) and its MAP calls.
Table B: oracle diagnostics from the full table (oracle.py, d <= 28).
Tables C-I: certified perturb-and-MAP, cube-certified tilts, sign-pattern
envelopes, small-ball decoupling of the positive units, MAP-call costs,
narrow nets, perturb-and-MAP on toy events.
"""

import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))


def load(name):
    p = os.path.join(HERE, "results", name)
    return json.load(open(p)) if os.path.exists(p) else ([] if name in ("barrier_table.json", "narrow.json") else {})


def fmt_bits(U, p):
    if U is None:
        return "-"
    b = -math.log2(max(U, 1e-300))
    tot = ("%.1f" % -math.log2(p)) if p else ("inf" if p == 0 else "?")
    return "%.2f/%s" % (b, tot)


def ez(v, cap=50.0):
    return ("%.3g" % math.exp(min(v, cap))) if v is not None else "-"


def table_n4(T):
    rows = ["%-24s %8s %7s %8s %7s %8s %8s %7s %7s %8s %8s %6s %6s %3s %7s" % (
        "net", "p", "F0-t", "boxmin-t", "s*-t", "floor1", "floor2", "U_hold", "U_mcd", "tiltZ", "spZ",
        "gap8", "mrg8", "r*", "L1")]
    for r in T:
        bm = ("%.3f%s" % (r["box_min"] - r["t"], "*" if r["box_milp_status"] == "optimal" else "")) \
            if r.get("box_min") is not None else "-"
        ss = "%s%.3f" % ("" if r["s_star_exact"] else "~", r["s_star_minus_t"])
        f = lambda k, fm: (fm % r[k]) if r.get(k) is not None else "-"
        rows.append("%-24s %8s %7.3f %8s %7s %8s %8s %7s %7s %8s %8s %6.3f %6.3f %3d %7s" % (
            r["name"], ("%.1e" % r["p"]) if r["p"] is not None else "?", r["f0_minus_t"], bm, ss,
            f("floor1", "%.1e"), f("floor2", "%.1e"), f("holder_best", "%.3f"), f("mcdiarmid", "%.3f"),
            ez(r.get("box_tilt_logZ")), ez(r.get("sign_pattern_logZ")), r["gap_r8"], r["margin_r8"], r["r_star"],
            "%s%.4f" % ("" if r["level1_exact"] else "~", r["level1_weight"])))
    return rows


def table_seconds(T):
    rows = ["%-24s %8s %8s %8s %8s %8s %8s" % ("net", "box_min", "cube", "crown", "decoupl", "tilt", "signpat")]
    for r in T:
        s = r["seconds"]
        g = lambda k: ("%.0f" % s[k]) if k in s else "-"
        rows.append("%-24s %8s %8s %8s %8s %8s %8s" % (r["name"], g("box_min"), g("cube_pass"), g("crown_profile"),
                                                      g("decoupled_bounds"), g("box_tilt"), g("sign_pattern")))
    return rows


def main():
    T = load("barrier_table.json")
    PM = load("perturb_map.json")
    SP = load("signpattern.json")
    O = {}
    for fn in sorted(os.listdir(os.path.join(HERE, "results"))):
        if fn.startswith("oracle") and fn.endswith(".json"):
            O.update(load(fn))
    N4 = table_n4(T)
    A = ["%-24s %8s %7s %16s %11s %10s %11s %6s" % ("net", "p", "N_MC", "U_dec", "bits", "U_pm", "bits", "calls")]
    for r in T:
        p = r["p"]
        cands = {}
        if r.get("holder_best") is not None:
            cands["hold-" + r["holder_which"]] = r["holder_best"]
            cands["mcd"] = r["mcdiarmid"]
        if cands:
            kb = min(cands, key=cands.get)
            ud, bd = "%.3f %-9s" % (cands[kb], kb), fmt_bits(cands[kb], p)
        else:
            ud, bd = "-", "-"
        pm = PM.get(r["name"])
        n_mc = 3 * math.log(2 / 0.05) / (0.1 ** 2 * p) if p else None
        A.append("%-24s %8s %7s %16s %11s %10s %11s %6s" % (
            r["name"], ("%.1e" % p) if p is not None else "?", ("%.0e" % n_mc) if n_mc else "-", ud, bd,
            ("%.2e" % pm["U"]) if pm else "-", fmt_bits(pm["U"], p) if pm else "-",
            str(pm["map_calls"]) if pm else "-"))
    B = ["%-24s %7s %7s %9s %5s %5s %8s %8s %13s %8s %4s" % (
        "net", "F0-t", "sym-t", "bestTiltZ", "R_h1", "R_i1", "K_ideal", "pm_est", "mom(2k)", "capK", "alpha")]
    for r in T:
        o = O.get(r["name"])
        if not o:
            continue
        p = r["p"]
        kid = ("%.1f" % (o["chernoff_exact"] / p)) if p else ("%.1e" % o["chernoff_exact"])
        pms = o.get("pmap", [])
        pm_est = ("%.1e" % math.exp(min(q["log_bound_est"] for q in pms))) if pms else "-"
        mom = "%.1e(%d)" % (o["moment_best"], o["moment_order"])
        capk = ("%.1e" % (o["cap_Z"][-1] / p)) if (o.get("cap_Z") and p) else "-"
        B.append("%-24s %7.3f %7.3f %9.3g %5s %5s %8s %8s %13s %8s %4s" % (
            r["name"], o["f0_minus_t"], o["sym_gap"], math.exp(o["best_tilt_logZ"]),
            ("%.0f" % o["R_holder_1"]) if "R_holder_1" in o else "-",
            ("%.1f" % o["R_indep_1"]) if "R_indep_1" in o else "-",
            kid, pm_est, mom, capk,
            ("%.0f" % o["dobrushin_alpha_theta_star"]) if "dobrushin_alpha_theta_star" in o else "-"))
    C = ["%-24s %9s %9s %7s %6s %6s %9s %11s %9s %8s" % ("net", "p", "U_pm", "U/p", "theta", "block", "calls",
                                                       "bits", "est_U", "seconds")]
    for nm, r in PM.items():
        sec = r.get("seconds_table", 0) + r.get("seconds_pilot", 0) + r.get("seconds_final", 0)
        C.append("%-24s %9.2e %9.2e %7s %6g %6d %9d %11s %9.2e %8.0f" % (
            nm, r["p"] or 0, r["U"], ("%.0f" % r["U_over_p"]) if r.get("U_over_p") else "-", r["theta"], r["block"],
            r["map_calls"], fmt_bits(r["U"], r["p"]), math.exp(r["est_log_bound"]), sec))
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
    G = ["%-24s %9s %8s %8s" % ("net", "p", "q+", "q+_9999")]
    for nm in SB:
        r = SB[nm]
        G.append("%-24s %9.2e %8.4f %8.4f" % (nm, r["p"], r["q_plus"], r["q_plus_9999"]))
    txt = ("Table N4: barrier diagnostics (barrier_table.json)\n" + "\n".join(N4)
           + "\n\nTable N4, wall-clock seconds per part (shared 4-core machine)\n" + "\n".join(table_seconds(T))
           + "\n\nTable A: certified upper bounds\n" + "\n".join(A)
           + "\n\nTable B: oracle diagnostics (d <= 28)\n" + "\n".join(B)
           + "\n\nTable C: certified perturb-and-MAP (delta = 0.05; MAP calls answered by enumeration)\n" + "\n".join(C)
           + "\n\nTable D: cube-certified tilt envelopes (two-sided, eps = 0.1, delta = 0.05)\n" + "\n".join(D)
           + "\n\nTable E: sign-pattern envelopes (one hidden layer)\n" + "\n".join(E)
           + "\n\nTable F: small-ball decoupling of the positive units (q+)\n" + "\n".join(G))
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
    txt += ("\n\nTable G: cost of one MAP call (HiGHS MILP, time limit 120-600 s). These calls use per-coordinate\n"
            "(block 1) Gumbel perturbations; the certified bounds of Table C used blocks of up to 6 (d = 24) or 7\n"
            "(d = 28), whose MAP calls were not timed, and HiGHS's floating-point dual bound is not a certificate.\n"
            + "\n".join(H)
            + "\n\nTable H: narrow nets, exact DP interval (small_width_interval)\n" + "\n".join(I)
            + "\n\nTable I: perturb-and-MAP on toy events: log p against the bound -E dist(xhat, C)\n"
            + "\n".join(J))
    print(txt)
    with open(os.path.join(HERE, "results", "summary.txt"), "w") as fh:
        fh.write(txt + "\n")


if __name__ == "__main__":
    main()
