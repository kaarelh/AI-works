"""Tables from results/*.json: printed, written to results/summary.md, and
the rows of the headline tables written to results/tables.json (for the
paper).

Current version (interval-arithmetic verifier, implemented-flops cost
model): suite_cert.json (run_suite.py), full_d64_*.json (full_d64.py),
soundness.json (check_soundness.py). Results of the previous version of the
verifier (same certificates; its cost model counted an incremental verifier,
2 to 4 times fewer flops per leaf than the implementation) are tabulated
below them and labelled as such: knuth_suite.json, scaling.json,
gap_scan.json, subtree_d64*.json, large_d.json."""
import json
import math
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.join(HERE, "results")
MACHINE = "shared 4-core machine, other jobs running; numpy, one BLAS thread per process"


def load(name):
    p = os.path.join(R, name)
    return json.load(open(p)) if os.path.exists(p) else {}


def g(x, fmt=".2g"):
    if x is None or (isinstance(x, float) and not math.isfinite(x)):
        return "-"
    return format(x, fmt)


def suite_rows(S):
    rows = []
    for name, r in S.items():
        ex = r["exact"]
        mc, mcs = r["mc_fpe"], r["mc_seconds"]
        e2e = r["end_to_end_seconds"]
        rows.append({
            "net": name, "d": r["d"], "widths": r["widths"], "loss": r["loss"], "p": r["p_exact"], "F": ex["F"],
            "matches_suite_count": r["match_suite"], "exact": ex["exact"], "plan": r["plan"], "nodes": ex["nodes"],
            "argument_MB": ex.get("bytes", 0) / 2 ** 20,
            "verifier_fpe": ex["fpe"], "verifier_seconds": ex["verify_seconds"],
            "prover_seconds": r["prover_seconds_total"], "end_to_end_seconds": e2e,
            "exact_evals": ex.get("exact_evals", 0),
            "mc_fpe": mc, "mc_seconds": mcs, "enum_fpe": r["enum_fpe"], "enum_seconds": r["enum_seconds"],
            "mc_over_verifier_fpe": mc / ex["fpe"] if math.isfinite(mc) else None,
            "mc_over_end_to_end_seconds": mcs / e2e if math.isfinite(mcs) else None,
            "enum_over_verifier_fpe": r["enum_fpe"] / ex["fpe"],
            "enum_over_end_to_end_seconds": r["enum_seconds"] / e2e,
            "hybrid": r.get("hybrid")})
    return rows


def main():
    lines = []
    out = lines.append
    tables = {"machine": MACHINE, "eps": 0.1, "delta": 0.05,
              "fpe": "verifier flops as implemented / flops of one forward pass (2 sum_k m_k m_(k-1))"}
    # ---- suite (current version)
    S = load("suite_cert.json")
    if S:
        rows = suite_rows(S)
        tables["suite"] = rows
        out("\n### Suite nets with exact p (d <= 28): exact certificates (current verifier)\n")
        out(f"Costs in forward-pass equivalents (fpe) and wall-clock seconds on a {MACHINE}. "
            "MC: 3 ln(2/delta) / (eps^2 p) samples, eps = 0.1, delta = 0.05. 'end to end' = prover (with its "
            "Knuth plan) + verifier.\n")
        out("| net | p | F | plan | nodes | verifier fpe | verifier s | prover s | end to end s | MC fpe | MC s | "
            "enum fpe | enum s | MC/cert (fpe) | MC/cert (s, end to end) | enum/cert (fpe) | enum/cert (s) |")
        out("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for w in rows:
            out(f"| {w['net']} | {g(w['p'])} | {w['F']}{'' if w['matches_suite_count'] else ' (!)'} | {w['plan']} | "
                f"{w['nodes']} | {g(w['verifier_fpe'])} | {g(w['verifier_seconds'])} | {g(w['prover_seconds'])} | "
                f"{g(w['end_to_end_seconds'])} | {g(w['mc_fpe'])} | {g(w['mc_seconds'])} | {g(w['enum_fpe'])} | "
                f"{g(w['enum_seconds'])} | {g(w['mc_over_verifier_fpe'])} | {g(w['mc_over_end_to_end_seconds'])} | "
                f"{g(w['enum_over_verifier_fpe'])} | {g(w['enum_over_end_to_end_seconds'])} |")
        hy = [w for w in rows if w["hybrid"] and w["hybrid"].get("Z_open")]
        if hy:
            out("\nHybrid arguments (failure-containing subtrees sampled, sized for ratio 1.1):\n")
            out("| net | open points | samples | interval | ratio | contains p | fpe | verifier s |")
            out("|---|---|---|---|---|---|---|---|")
            for w in hy:
                h = w["hybrid"]
                out(f"| {w['net']} | {h['Z_open']} | {h['samples']} | [{g(h['lo'], '.4g')}, {g(h['hi'], '.4g')}] | "
                    f"{g(h['ratio'], '.3f')} | {h['contains_p']} | {g(h['fpe'])} | {g(h['verify_seconds'])} |")
    # ---- 'lin' + 'quad' certificates against 'lin' alone
    Q = load("suite_cert_lin+quad.json")
    if Q:
        qrows = []
        out("\n### 'lin' + 'quad' certificates against 'lin' alone (same nets, same plan)\n")
        out("| net | p | F | nodes (lin+quad / lin) | quad leaves | verifier fpe (lin+quad / lin) | "
            "verifier s (lin+quad / lin) | prover s (lin+quad / lin) |")
        out("|---|---|---|---|---|---|---|---|")
        for name, r in Q.items():
            ex, base = r["exact"], (S.get(name) or {}).get("exact", {})
            bs = S.get(name, {})
            qrows.append({"net": name, "p": r["p_exact"], "F": ex["F"], "exact": ex["exact"], "nodes": ex["nodes"],
                          "quad_leaves": ex.get("leaves", {}).get("quad"), "verifier_fpe": ex["fpe"],
                          "verifier_seconds": ex["verify_seconds"], "prover_seconds": r["prover_seconds_total"],
                          "lin_nodes": base.get("nodes"), "lin_verifier_fpe": base.get("fpe"),
                          "lin_verifier_seconds": base.get("verify_seconds"),
                          "lin_prover_seconds": bs.get("prover_seconds_total")})
            w = qrows[-1]
            out(f"| {name} | {g(w['p'])} | {w['F']} | {w['nodes']} / {w['lin_nodes']} | {w['quad_leaves']} | "
                f"{g(w['verifier_fpe'])} / {g(w['lin_verifier_fpe'])} | {g(w['verifier_seconds'])} / "
                f"{g(w['lin_verifier_seconds'])} | {g(w['prover_seconds'])} / {g(w['lin_prover_seconds'])} |")
        tables["suite_lin_quad"] = qrows
    # ---- d = 64 complete certificate attempts
    for fn in sorted(os.listdir(R)):
        if not (fn.startswith("full_d64_") and fn.endswith(".json")):
            continue
        D = load(fn)
        est = D.get("whole_cube_estimate", {})
        row = {k: D.get(k) for k in ("net", "d", "k", "pieces_total", "pieces_done", "all_exact", "F_found",
                                     "fraction_of_cube_certified", "nodes_done", "fpe_done",
                                     "prover_worker_seconds_done", "verify_worker_seconds_done", "wall_seconds",
                                     "budget_seconds", "workers", "final")}
        row["whole_cube_estimate"] = est
        tables.setdefault("d64_certificate", []).append(row)
        out(f"\n### d = 64: certificate attempt (p = 0), {D['net']} (current verifier)\n")
        out(f"Top tree of depth k = {D['k']} by the prover's own splits, then {D['pieces_total']} pieces proved "
            f"and verified in a uniformly random order, {D['workers']} worker processes, budget "
            f"{D['budget_seconds'] / 60:.0f} min wall-clock on a {MACHINE}.\n")
        out("| pieces done | fraction of cube certified exactly | failing points found | nodes | verifier fpe | "
            "prover worker s | verifier worker s | wall s |")
        out("|---|---|---|---|---|---|---|---|")
        out(f"| {D['pieces_done']} / {D['pieces_total']} | {g(D.get('fraction_of_cube_certified'), '.4f')} | "
            f"{D.get('F_found')} | {g(D.get('nodes_done'), '.3g')} | {g(D.get('fpe_done'), '.3g')} | "
            f"{g(D.get('prover_worker_seconds_done'), '.3g')} | {g(D.get('verify_worker_seconds_done'), '.3g')} | "
            f"{g(D.get('wall_seconds'), '.4g')} |")
        if est:
            out("\nWhole-cube totals (mean over the pieces done x 2^k, +- standard error): "
                + "; ".join(f"{k} {g(v[0], '.3g')} +- {g(v[1], '.2g')}" for k, v in est.items() if k != "note"))
    # ---- soundness
    So = load("soundness.json")
    if So:
        tables["soundness"] = {k: v for k, v in So.items() if k != "nets"}
        out("\n### Soundness checks (current verifier)\n")
        out(", ".join(f"{k} = {v}" for k, v in So.items() if k != "nets"))
    # ---- previous version: analysis results
    K = load("knuth_suite.json")
    if K:
        out("\n### [previous version] Knuth estimates of the uncollapsed tree (r_leaf = 5), all suite nets\n")
        out("fpe in the previous (incremental) cost model; the implemented verifier costs 2 to 4 times more per leaf.\n")
        out("| net | d | z | p | lin: nodes | lin: fpe | lin+quad: nodes | lin+quad: fpe | full enum fpe | MC fpe |")
        out("|---|---|---|---|---|---|---|---|---|---|")
        for name, r in K.items():
            a, b = r.get("lin_rl5", {}), r.get("lin+quad_rl5", {})
            p = r.get("p_exact")
            mc = 3 * math.log(40) / (0.01 * p) if p else None
            out(f"| {name} | {r['d']} | {r['z']:.2f} | {g(p)} | {g(a.get('nodes'))} | {g(a.get('fpe'))} | "
                f"{g(b.get('nodes'))} | {g(b.get('fpe'))} | {g(r['enum_full_fpe'])} | {g(mc)} |")
    Sc = load("scaling.json")
    if Sc:
        out("\n### [previous version] Scaling with d (one hidden layer, width 32; Knuth estimates, r_leaf = 5)\n")
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
    G = load("gap_scan.json")
    if G:
        out("\n### [previous version] Relaxation gap vs subcube dimension r (medians over random subcubes)\n")
        out("| net | r | margin min f - t | gap lin | gap quad | certified lin | certified quad | pure | centre >= t |")
        out("|---|---|---|---|---|---|---|---|---|")
        for name, rec in G.items():
            for r, v in sorted(((int(k), v) for k, v in rec.items())):
                out(f"| {name} | {r} | {v['median_margin']:.3f} | {v['median_gap_lin']:.3f} | "
                    f"{v['median_gap_quad']:.3f} | {v['frac_lin']:.2f} | {v['frac_quad']:.2f} | {v['frac_pure']:.2f} | "
                    f"{v['frac_centre_ok']:.2f} |")
    St = {**load("subtree_d64.json"), **load("subtree_d64_b.json")}
    if St:
        out("\n### [previous version] d = 64: verified certificates of random pieces (prover's own splits for k steps)\n")
        out("| net | k | pieces: free inputs r, nodes, verifier fpe, exact, failing points | whole-cube estimate (mean, geomean) |")
        out("|---|---|---|---|")
        for name, r in St.items():
            pcs = "; ".join(f"r={p['r']}, {p['nodes']} nodes, {g(p['fpe'])} fpe, {'exact' if p['exact'] else 'open part'}, F={p['F']}"
                            for p in r["paths"])
            out(f"| {name} | {r['k']} | {pcs} | {g(r['estimate_mean_fpe'])}, {g(r['estimate_geomean_fpe'])} |")
    Ld = load("large_d.json")
    if Ld:
        out("\n### [previous version] d = 64, 128: budgeted certificates + sampling of the open part\n")
        out("| net | nodes | certified fraction | open fraction | samples | fails | interval | fpe | MC same cost: p <= |")
        out("|---|---|---|---|---|---|---|---|---|")
        for name, r in Ld.items():
            out(f"| {name} | {r['nodes']} | {g(r['certified_fraction'], '.3g')} | {g(r['open_fraction'], '.3g')} | "
                f"{r['samples']} | {r['sample_fails']} | [{g(r['lo'])}, {g(r['hi'])}] | {g(r['fpe'])} | "
                f"{g(r['mc_same_cost_hi_if_no_fail'])} |")
    text = "\n".join(lines)
    print(text)
    open(os.path.join(R, "summary.md"), "w").write(text + "\n")
    json.dump(tables, open(os.path.join(R, "tables.json"), "w"), indent=1, default=float)


if __name__ == "__main__":
    main()
