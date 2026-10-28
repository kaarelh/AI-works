"""Markdown tables from results/*.json (printed to stdout and written to
results/summary.md)."""
import json
import math
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.join(HERE, "results")


def load(name):
    p = os.path.join(R, name)
    return json.load(open(p)) if os.path.exists(p) else {}


def g(x, fmt=".2g"):
    if x is None or (isinstance(x, float) and not math.isfinite(x)):
        return "-"
    return format(x, fmt)


def main():
    lines = []
    out = lines.append
    # ---- suite
    for kinds in ("lin", "lin+quad"):
        S = {**load(f"suite_{kinds}.json"), **load(f"suite_{kinds}_rerun.json")}
        if not S:
            continue
        out(f"\n### Suite, certificates '{kinds}' (eps = 0.1, delta = 0.05; costs in forward-pass equivalents)\n")
        out("| net | p | F | exact cert: fpe | nodes | KB | hybrid: fpe | ratio | p in interval | MC fpe | "
            "enum fpe | MC / best | enum / exact cert |")
        out("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for name, r in S.items():
            ex, hy = r["exact"], r.get("hybrid") or {}
            best = min(ex["fpe"], hy.get("fpe", math.inf)) if hy.get("contains_p", True) else ex["fpe"]
            mc = r["mc_fpe"]
            out(f"| {name} | {g(r['p_exact'])} | {ex['F']}{'' if ex['match_suite'] else ' (!)'} | {g(ex['fpe'])} | "
                f"{ex['nodes']} | {g(ex['bytes'] / 1024, '.0f')} | {g(hy.get('fpe'))} | {g(hy.get('ratio'), '.3f')} | "
                f"{hy.get('contains_p', '-')} | {g(mc)} | {g(r['enum_full_fpe'])} | "
                f"{g(mc / best if math.isfinite(mc) else math.inf)} | {g(r['enum_full_fpe'] / ex['fpe'])} |")
    # ---- knuth
    K = load("knuth_suite.json")
    if K:
        out("\n### Knuth estimates of the uncollapsed tree (r_leaf = 5), all suite nets\n")
        out("| net | d | z | p | lin: nodes | lin: fpe | lin+quad: nodes | lin+quad: fpe | full enum fpe | MC fpe |")
        out("|---|---|---|---|---|---|---|---|---|---|")
        for name, r in K.items():
            a, b = r.get("lin_rl5", {}), r.get("lin+quad_rl5", {})
            p = r.get("p_exact")
            mc = 3 * math.log(40) / (0.01 * p) if p else None
            out(f"| {name} | {r['d']} | {r['z']:.2f} | {g(p)} | {g(a.get('nodes'))} | {g(a.get('fpe'))} | "
                f"{g(b.get('nodes'))} | {g(b.get('fpe'))} | {g(r['enum_full_fpe'])} | {g(mc)} |")
    # ---- scaling
    Sc = load("scaling.json")
    if Sc:
        out("\n### Scaling with d (one hidden layer, width 32; Knuth estimates, r_leaf = 5; medians over seeds)\n")
        out("| family | d | z (median) | p (exact or MC 1e6) | cert fpe (Knuth) | cert fpe (real, d<=24) | enum fpe | MC fpe |")
        out("|---|---|---|---|---|---|---|---|")
        groups = defaultdict(list)
        for k, r in Sc.items():
            groups[(r["loss"], r["steps"], r["d"])].append(r)
        for (loss, steps, d), rs in sorted(groups.items()):
            med = lambda xs: sorted(xs)[len(xs) // 2] if xs else None  # noqa: E731
            z = med([r["z"] for r in rs])
            ps = [r.get("p", r.get("p_mc_1e6")) for r in rs]
            kf = med([r["knuth"]["fpe"] for r in rs])
            cf = med([r["cert"]["fpe"] for r in rs if "cert" in r])
            mcs = [r["mc_fpe"] or (3 * math.log(40) / (0.01 * r["p_mc_1e6"]) if r.get("p_mc_1e6") else None)
                   for r in rs]
            mcs = [m for m in mcs if m]
            out(f"| {loss} {steps} steps | {d} | {z:.2f} | {', '.join(g(p) for p in ps)} | {g(kf)} | {g(cf)} | "
                f"{g(rs[0]['enum_full_fpe'])} | {g(med(mcs)) if mcs else '-'} |")
    # ---- gap scan
    G = load("gap_scan.json")
    if G:
        out("\n### Relaxation gap vs subcube dimension r (medians over random subcubes; f in its own units)\n")
        out("| net | r | margin min f - t | gap lin | gap quad | certified lin | certified quad | pure | centre >= t |")
        out("|---|---|---|---|---|---|---|---|---|")
        for name, rec in G.items():
            for r, v in sorted(((int(k), v) for k, v in rec.items())):
                out(f"| {name} | {r} | {v['median_margin']:.3f} | {v['median_gap_lin']:.3f} | "
                    f"{v['median_gap_quad']:.3f} | {v['frac_lin']:.2f} | {v['frac_quad']:.2f} | {v['frac_pure']:.2f} | "
                    f"{v['frac_centre_ok']:.2f} |")
    # ---- verified pieces at d = 64
    St = {**load("subtree_d64.json"), **load("subtree_d64_b.json")}
    if St:
        out("\n### d = 64: verified certificates of random pieces (prover's own splits for k steps)\n")
        out("| net | k | pieces: free inputs r, nodes, verifier fpe, exact, failing points | whole-cube estimate (mean, geomean) |")
        out("|---|---|---|---|")
        for name, r in St.items():
            pcs = "; ".join(f"r={p['r']}, {p['nodes']} nodes, {g(p['fpe'])} fpe, {'exact' if p['exact'] else 'open part'}, F={p['F']}"
                            for p in r["paths"])
            out(f"| {name} | {r['k']} | {pcs} | {g(r['estimate_mean_fpe'])}, {g(r['estimate_geomean_fpe'])} |")
    # ---- large d
    Ld = load("large_d.json")
    if Ld:
        out("\n### d = 64, 128: budgeted certificates + sampling of the open part\n")
        out("| net | nodes | certified fraction | open fraction | samples | fails | interval | fpe | MC same cost: p <= |")
        out("|---|---|---|---|---|---|---|---|---|")
        for name, r in Ld.items():
            out(f"| {name} | {r['nodes']} | {g(r['certified_fraction'], '.3g')} | {g(r['open_fraction'], '.3g')} | "
                f"{r['samples']} | {r['sample_fails']} | [{g(r['lo'])}, {g(r['hi'])}] | {g(r['fpe'])} | "
                f"{g(r['mc_same_cost_hi_if_no_fail'])} |")
    # ---- soundness
    So = load("soundness.json")
    if So:
        out("\n### Soundness checks\n")
        out(", ".join(f"{k} = {v}" for k, v in So.items() if k != "nets"))
    text = "\n".join(lines)
    print(text)
    open(os.path.join(R, "summary.md"), "w").write(text + "\n")


if __name__ == "__main__":
    main()
