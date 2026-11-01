"""Compact tables from structure.json, structure_own.json, walsh.json,
geometry.json, subcube.json, adversarial.json, large_d.json, heuristics_ref.json.

usage: python3 summarize_structure.py
"""

import json
import os

from common import RES


def load(name):
    p = os.path.join(RES, name)
    return json.load(open(p)) if os.path.exists(p) else []


def fmt(v, f="%.2g"):
    if v is None:
        return "-"
    if isinstance(v, (int,)) and not isinstance(v, bool):
        return str(v)
    try:
        return f % v
    except TypeError:
        return str(v)


def main():
    rows = load("structure.json") + load("structure_own.json")
    print("== failure-set structure (S = failures; near = the 1000 lowest inputs when p = 0)")
    hdr = ("net", "F", "|mean x_i|", "halfsp K", "antip", "corr f(-x)", "even/odd drop", "E+ E- L share",
           "u+ u-", "#cmp<.5", "top eig", "g1", "minima", "min50%")
    print(" | ".join(hdr))
    for o in rows:
        print(" | ".join([
            o["name"] + (" (near)" if o.get("near") else ""), str(o["F"]),
            fmt(o["mean_abs_coord"]), fmt(o.get("halfspace_maxmargin_ratio")),
            fmt(o.get("antipode_fails_frac")), fmt(o["corr_f_fneg"]),
            fmt(o["even_drop_sd"], "%.1f") + "/" + fmt(o["odd_drop_sd"], "%.1f"),
            (fmt(o.get("share_Ep")) + " " + fmt(o.get("share_Em")) + " " + fmt(o.get("share_L"))) if "share_Ep" in o else "-",
            fmt(o.get("u_pos_ratio")) + " " + fmt(o.get("u_neg_ratio")),
            fmt(o.get("cov_n_below_half")), fmt(o.get("top_eig"), "%.1f"), fmt(o.get("g1")),
            fmt(o.get("n_minima")), fmt(o.get("minima_for_50"))]))
    print("\n== Walsh spectra (d = 24 suite nets)")
    for o in load("walsh.json"):
        print(o["name"], "mean degree %.2f odd share %.3f PR %.0f max share %.4f W2 %.2f W4 %.2f rho(1) %.2f exkurt %.3f" % (
            o["mean_degree"], o["odd_share"], o["participation"], o["max_share"], o["W"][2], o["W"][4], o["rho"][1],
            o["exkurt"]))
    print("\n== relaxation witnesses (local search; < t means the relaxation cannot certify)")
    for o in load("geometry.json"):
        print(o["name"], "t=%g cube_min=%s f(0)=%.3f box_min<=%.3f sphere_min<=%.3f m+=%s null(W+)=%s" % (
            o["threshold"], fmt(o.get("cube_min"), "%.3f"), o["f_center"], o["box_min"], o["sphere_min"],
            o.get("m_pos", "-"), o.get("null_dim_pos", "-")))
    print("\n== subcube-partition lower bounds (d <= 20)")
    for o in load("subcube.json"):
        print(o["name"], "F=%d k=%.1f random-set k=%.1f kS=%.1f LB=%.3g F/d=%.3g MC=%.3g speedup<=%.3g" % (
            o["F"], o["k_mean"], o["k_randomset_mean"], o["kS_mean"], o["lb_partition"], o["F_over_d"], o["mc_cost"],
            o["speedup_bound"]))
    print("\n== adversarial")
    for o in load("adversarial.json"):
        print({k: (fmt(v, "%.3g") if isinstance(v, float) else v) for k, v in o.items()})
    print("\n== d = 32...128 against SMC references (nets_lower)")
    for o in load("heuristics_ref.json"):
        print(o["name"], "z=%.2f p_ref=%.2e" % (o["z"], o["p_ref"]), " ".join(
            "%s=%s" % (m, fmt(o.get("log10ratio_" + m), "%+.1f")) for m in
            ("gauss", "edgeworth", "mcfit", "lin_gauss", "ginput", "sphere", "poi_even")))


if __name__ == "__main__":
    main()
