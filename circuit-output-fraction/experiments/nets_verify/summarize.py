"""Print the tables of results/*.json (markdown) for the report."""

import json
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.join(HERE, "results")


def load(name):
    p = os.path.join(R, name)
    return json.load(open(p)) if os.path.exists(p) else None


def g(x, k=3):
    if x is None:
        return "-"
    if isinstance(x, float) and (math.isinf(x) or math.isnan(x)):
        return str(x)
    return f"{x:.{k}g}" if isinstance(x, float) else str(x)


def suite():
    import glob
    rows = []
    for f in sorted(glob.glob(os.path.join(R, "suite*.json"))):
        rows += json.load(open(f))
    if not rows:
        return
    print("\n## Suite nets with exact p: exact count by B&B (CROWN, r_enum = 4)\n")
    print("| net | z | p | f(0)-t | B&B exact? | cost B&B (fpe) | MITM enumeration (fpe) | MC, eps=0.1 (samples) | MC / B&B |")
    print("|---|---|---|---|---|---|---|---|---|")
    for o in sorted(rows, key=lambda o: (o["d"], o["name"])):
        e = o["exact_run"]
        ok = "yes" if e["exact"] and e["fail"] == o["fail_count"] else (
            f"interval, contains" if e["fail"] <= o["fail_count"] <= e["fail"] + e["ambiguous"] + e["undecided"] else "NO")
        print(f"| {o['name']} | {o['z']:.2f} | {g(o['p_exact'])} | {o['f0'] - o['t']:+.3f} | {ok} (A={e['ambiguous']}, U={e['undecided']}) "
              f"| {g(e['fpe'])} | {g(o['full_enum_fpe'])} | {g(o['mc_samples'])} | {g(o['mc_samples'] / e['fpe'], 2)} |")
    print("\nAnytime (deterministic interval after a cost budget; two-sided interval by sampling the undecided subcubes):\n")
    print("| net | budget (fpe) | [lo, hi] deterministic | Z_undecided | K = Z_u/(p - lo) | two-sided | samples | contains p |")
    print("|---|---|---|---|---|---|---|---|")
    for o in sorted(rows, key=lambda o: (o["d"], o["name"])):
        for a in o.get("anytime", []):
            ts = a.get("two_sided")
            print(f"| {o['name']} | {g(a.get('budget_fpe'))} | [{g(a['lo'])}, {g(a['hi'])}] | {g(a['Z_undecided'])} | {g(a.get('K_undecided'))} "
                  f"| {('[' + g(ts[0]) + ', ' + g(ts[1]) + ']') if ts else '-'} | {g(a.get('samples'))} | {a.get('contains', '-')} |")


def variants():
    rows = load("variants.json")
    if not rows:
        return
    print("\n## Deductive engines on d = 24 nets (exact counts)\n")
    for o in rows:
        print(f"\n{o['name']}: p = {g(o['p'])}, F = {o['fail_count']}, MITM enumeration {g(o['full_enum_fpe'])} fpe, MC {g(o['mc_samples'])} samples\n")
        print("| engine | nodes bounded | safe nodes | points enumerated | cost (fpe) | cost / enumeration |")
        print("|---|---|---|---|---|---|")
        for r in o["runs"]:
            print(f"| {r['label']} | {r['nodes_bounded']} | {r['certified_safe_nodes']} | {r['points_enumerated']} | {g(r['fpe'])} | {g(r['fpe'] / o['full_enum_fpe'], 2)} |")


def barrier():
    rows = load("barrier.json")
    if not rows:
        return
    print("\n## Certifiable subcube dimension r50 (largest r with >= 50% of random r-dimensional subcubes certified)\n")
    print("| net | d | z | f(0)-t | CROWN | optimised slopes | any box method (upper bound) | cube (no failure) |")
    print("|---|---|---|---|---|---|---|---|")
    for o in rows:
        r = o["r50"]
        cap = max(x["r"] for x in o["rows"] if x.get("box_open") is not None)
        print(f"| {o['name']} | {o['d']} | {o['z']:.1f} | {o['f0'] - 0.5:+.3f} | {r['crown']} | {r['alpha']} | {r['box_open']}{'+' if r['box_open'] == cap else ''} | {r['cube']}{'+' if r['cube'] == 16 else ''} |")


def isolation():
    rows = load("isolation.json")
    if not rows:
        return
    print("\n## Where the failing points are\n")
    print("| net | F | mean distance (d/2) | min distance | with a failing neighbour | components | largest | greedy failing-subcube dims |")
    print("|---|---|---|---|---|---|---|---|")
    for o in rows:
        print(f"| {o['name']} | {o['F']} | {o['mean_dist']:.1f} ({o['d'] // 2}) | {o['min_dist']} | {o['frac_with_failing_neighbour']:.2f} "
              f"| {o.get('components', '-')} | {o.get('largest_components', ['-'])[0] if o.get('largest_components') else '-'} | {o.get('greedy_failing_subcube_dim_hist', '-')} |")
    print("\n## Tree of a perfect engine (pure subcubes decided) vs the CROWN tree\n")
    print("| net | d | F | 2^d | CROWN tree nodes | CROWN cost (fpe) | perfect engine, static order | perfect engine, adaptive | F (d - log2 F) | MC samples (eps=0.1) |")
    print("|---|---|---|---|---|---|---|---|---|---|")
    for o in rows:
        if "oracle_tree" not in o:
            continue
        ot = o["oracle_tree"]["r_stop=0"]
        F, d = o["F"], o["d"]
        print(f"| {o['name']} | {d} | {F} | {g(2.0 ** d)} | {g(float(o['crown_tree_nodes']))} | {g(o['crown_fpe'])} | {g(float(ot['static_nodes']))} "
              f"| {g(float(ot['greedy_nodes']))} | {g(F * (d - math.log2(F)))} | {g(o['mc_samples'])} |")


def milp():
    rows = load("milp.json")
    if not rows:
        return
    print("\n## HiGHS MILP for min f over the cube (unsound floating-point engine; witnesses re-checked)\n")
    print("| net | d | f(0)-t | CROWN root lb - t | p exact | MILP status | nodes | seconds | best f found | dual bound | witness (sound) | solver claims p=0 | sound B&B, same time: [lo, hi] | B&B seconds |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for o in rows:
        b = o.get("bab")
        bs = f"[{g(b['lo'])}, {g(b['hi'])}]" + (" exact" if b["exact"] else "") if b else "-"
        print(f"| {o['name']} | {o['d']} | {o['f0_minus_t']:+.3f} | {o['crown_root_lb_minus_t']:+.3g} | {g(o['p_exact'])} | {o['milp_status']} | {o['milp_nodes']} "
              f"| {o['milp_seconds']} | {g(o['incumbent_f'], 4)} | {g(o['dual_bound'], 4)} | {o['witness']} | {o['solver_claims_p_zero']} | {bs} | {b['seconds'] if b else '-'} |")


def zero():
    rows = load("zero.json")
    if not rows:
        return
    print("\n## p = 0: how often, and the cost of certifying it\n")
    print("| loss | d | steps | seed | z | f(0)-t | p=0 certified | p>0 found | hi | cost (fpe) | enumeration (fpe) | seconds |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for o in sorted(rows, key=lambda o: (o["loss"], o["d"], o["steps"], o["seed"])):
        b = o["bab"]
        print(f"| {o['loss']} | {o['d']} | {o['steps']} | {o['seed']} | {o['z']:.1f} | {o['f0'] - o['t']:+.3f} | {o['p_zero_certified']} "
              f"| {o['p_positive_certified']} | {g(b['hi'])} | {g(b['fpe'])} | {g(o['full_enum_fpe'])} | {b['seconds']} |")
    pos = [o for o in rows if o.get("F")]
    if pos:
        print("\nNets of this family with p > 0 (exact count by B&B):\n")
        print("| loss | d | steps | seed | F | p | B&B nodes bounded | B&B cost (fpe) | perfect-engine tree | MC samples |")
        print("|---|---|---|---|---|---|---|---|---|---|")
        for o in sorted(pos, key=lambda o: (o["loss"], o["d"], o["steps"], o["seed"])):
            b = o["bab"]
            print(f"| {o['loss']} | {o['d']} | {o['steps']} | {o['seed']} | {o['F']} | {g(o['F'] / 2.0 ** o['d'])} | {b['nodes_bounded']} "
                  f"| {g(b['fpe'])} | {o['oracle_tree_nodes']} | {g(o['mc_samples'])} |")
    print("\nCost of certifying p = 0 by d (median over the nets of the family with p = 0 certified):\n")
    print("| loss | d | nets | p=0 certified | median cost (fpe) | max cost (fpe) | enumeration (fpe) |")
    print("|---|---|---|---|---|---|---|")
    import statistics
    for loss in ["mse", "bce"]:
        for d in sorted({o["d"] for o in rows if o["loss"] == loss}):
            R_ = [o for o in rows if o["loss"] == loss and o["d"] == d]
            c = [o["bab"]["fpe"] for o in R_ if o["p_zero_certified"]]
            print(f"| {loss} | {d} | {len(R_)} | {len(c)} | {g(statistics.median(c)) if c else '-'} | {g(max(c)) if c else '-'} | {g(R_[0]['full_enum_fpe'])} |")


def large():
    rows = load("large.json")
    if not rows:
        return
    print("\n## Large d\n")
    print("| net | f(0)-t | CROWN certified fraction at r = 2,4,6,8,10,12,16,20,24,32,... | r50 | B&B interval at 1e7 fpe | full run (900 s) | MC with 1e7 samples: hits, interval |")
    print("|---|---|---|---|---|---|---|")
    for o in rows:
        c = o["crown_cert_rate"]
        b = o["bab_budget"]
        m = o["mc_same_budget"]
        full = o.get("bab_full")
        fs = f"[{g(full['lo'])}, {g(full['hi'])}], {g(full['fpe'])} fpe" if full else "not tried (d - r50 > 30)"
        print(f"| {o['name']} | {o['f0_minus_t']:+.3f} | {', '.join(f'{c[k]:.2f}' for k in sorted(c, key=int))} | {o.get('crown_r50', '-')} "
              f"| [{g(b['lo'])}, {g(b['hi'])}] | {fs} | {m['hits']}, [{g(m['interval'][0])}, {g(m['interval'][1])}] |")


def gap():
    rows = load("gap.json")
    if not rows:
        return
    print("\n## Looseness vs subcube dimension r (medians over 100 random subcubes)\n")
    print("| net | iota | r | margin (cube min - t) | CROWN gap | optimised-slope gap | any box bound: gap >= | CROWN cert | slopes cert | centre fails |")
    print("|---|---|---|---|---|---|---|---|---|---|")
    for o in rows:
        for x in o["rows"]:
            if x["r"] in (4, 8, 12):
                print(f"| {o['name']} | {g(o['iota'])} | {x['r']} | {x['margin']:.3f} | {x['crown_gap']:.3f} | {x['alpha_gap']:.3f} | {x['centre_gap']:.3f} "
                      f"| {x['crown_cert']:.2f} | {x['alpha_cert']:.2f} | {x['centre_fails']:.2f} |")


if __name__ == "__main__":
    suite()
    variants()
    barrier()
    isolation()
    zero()
    large()
    milp()
    gap()
    for name in ["check_soundness.json"]:
        o = load(name)
        if o:
            print("\n## Soundness checks\n\n", o)
