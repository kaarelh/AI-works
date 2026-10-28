"""Summaries and figures for the search study (results/search/*.jsonl).

Writes results/search/summary_subsample.md, summary_twin.md, summary_mnist_subsample.md
and figures/search_curves.{png,pdf}, figures/search_restarts.{png,pdf}, figures/search_twin.{png,pdf}.
"""
import collections
import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from accounting import boolean_bound, t2_bound, DESIGN_BITS, DESIGN_FACTOR  # noqa: E402
from cgb.bounds import occam_bound, cp_upper  # noqa: E402

ROOT = os.path.join(HERE, "..", "..")
RES = os.path.join(ROOT, "results", "search")
FIG = os.path.join(ROOT, "figures")
FAMS = ["codec", "scratch", "sub_refit", "sub_refit_init", "greedy_refit", "greedy_refit_init", "update_refit",
        "sub_distill", "greedy_distill", "mixed_scratch", "mixed_greedy", "restarts"]
FAM_NAMES = {"codec": "influence codec", "scratch": "distill from scratch", "sub_refit": "subsample+refit",
             "sub_refit_init": "subsample+refit (init-rel.)", "greedy_refit": "greedy+refit",
             "greedy_refit_init": "greedy+refit (init-rel.)", "update_refit": "subsample update",
             "sub_distill": "subsample+distill", "greedy_distill": "greedy+distill",
             "mixed_scratch": "distill on fresh+training inputs", "mixed_greedy": "greedy, then distill on fresh+training inputs",
             "restarts": "best of 32 restarts (all widths run)"}


def load(name):
    p = os.path.join(RES, name)
    return [json.loads(l) for l in open(p)] if os.path.exists(p) else []


def net_key(r):
    return (r["task"], r["param"], r["width"], r["depth"], r["seed"])


FAMILY_BITS = 4.0     # a prefix code over up to 16 search families (every family pays it)
FAMILY_SLOTS = 16     # = 2**FAMILY_BITS: each family's disagreement term is taken at delta_2 / 16 as well


def family_bound(x, fam, delta=0.05):
    """Theorem 2 for one family's certified candidate, with a 4-bit family prefix (the runs
    charged 3 bits to every family but the influence codec and the restarts, whose recorded
    bits carry none) and the disagreement term at delta/2 / DESIGN_FACTOR / FAMILY_SLOTS.
    Every one of the 16 family codes thus gets weight 1/16 in both terms, so the minimum over
    whichever families were certified on a network, however many and however chosen, is
    itself a valid bound."""
    extra = FAMILY_BITS - (0.0 if fam == "codec" or fam.startswith("restarts") else 3.0)
    occ = occam_bound(x["train_err_g"], 16000, x["bits"] + extra + DESIGN_BITS, delta / 2)
    return min(1.0, occ + cp_upper(x["dis_count"], x.get("n_cert", 200_000), delta / 2 / DESIGN_FACTOR / FAMILY_SLOTS))


def merged_runs():
    """subsample.jsonl rows, with the greedy and mixed families of the follow-up files merged in;
    every family's bound is recomputed with family_bound (bound_f_run keeps the run's value)."""
    runs = {net_key(r): r for r in load("subsample.jsonl")}
    for name, pref in (("subsample_greedy.jsonl", "greedy"), ("subsample_mixed.jsonl", "mixed")):
        for g in load(name):
            k = net_key(g)
            if k in runs:
                assert abs(runs[k]["test_err_f"] - g["test_err_f"]) < 1e-12, k   # the same network
                runs[k]["final"].update({f: v for f, v in g["final"].items() if f.startswith(pref)})
                runs[k]["info"].update({x: v for x, v in g["info"].items() if x == "float_curves_greedy"})
                runs[k]["candidates"] += [c for c in g["candidates"] if c["family"].startswith(pref)]
                runs[k]["timing"].update({x: v for x, v in g["timing"].items() if x in ("greedy", "mixed")})
    # restarts_run.py: all runs on a network (any width, steps or step grid) form one family; the run
    # with the lowest estimated bound (training set and selection pool only) is the family's candidate,
    # and its certification is the one used.  restarts_steps2000.jsonl holds diagnostic runs at the
    # one-run budget, which are not part of any family.
    for name, slot in (("restarts.jsonl", "restarts"), ("restarts_steps2000.jsonl", "restarts_diag")):
        for g in load(name):
            k = net_key(g)
            if k in runs:
                g["est_best"] = min(min(x[c] for c in x if c.startswith("est_")) for x in g["rows"])
                g["cert"] = dict(g["best"], bound_f=family_bound(g["best"], "restarts"))
                runs[k].setdefault(slot, []).append(g)
    for r in runs.values():
        if r.get("restarts"):
            g = min(r["restarts"], key=lambda z: z["est_best"])
            b = g["best"]
            r["final"]["restarts"] = {"label": f"k {g['k']}, restart {b['restart']}, rel {b['rel']}", "bits": b["bits"],
                                      "train_err_g": b["train_err_g"], "dis_count": b["dis_count"],
                                      "n_cert": b["n_cert"], "bound_f": b["bound_f"], "k": g["k"]}
            r["timing"]["restarts"] = sum(z["secs"] for z in r["restarts"])
    for r in runs.values():
        for fam, x in r["final"].items():
            x.setdefault("bound_f_run", x["bound_f"])
            x["bound_f"] = family_bound(x, fam)
    return runs


def oracle_rows():
    """True-teacher references, with log2(7) bits and delta_2/7 for picking the best of 7 step sizes
    on the certification sample."""
    out = {}
    for o in load("oracle_teacher.jsonl"):
        for row in o["oracle"]:
            r = {"bits": row["bits"], "train_err_g": row["train_err_g"],   # row bits include a 3-bit family prefix
                 "dis_count": int(round(row["dis_hat"] * 200_000)), "n_cert": 200_000}
            occ = occam_bound(r["train_err_g"], 16000, r["bits"] + 3.0 + DESIGN_BITS, 0.025)   # + log2(7) for the step choice
            row["bound_f_corr"] = min(1.0, occ + cp_upper(r["dis_count"], 200_000, 0.025 / DESIGN_FACTOR / 7))
        o["best"] = min(o["oracle"], key=lambda z: z["bound_f_corr"])
        o["best"]["bound_f"] = o["best"]["bound_f_corr"]
        out[(o["task"], o["param"], o["width"], o["depth"], o["seed"])] = o
    return out


TASK_ORDER = ["maj5", "fullmaj", "parity3", "junta6", "teacher4", "teacher8"]
PARAM_NAME = {"std": "standard, Adam", "mf": "mean-field, SGD", "lazy": "standard x2, SGD"}


def sort_key(k):
    t, p, w, d, s = k
    return (d, TASK_ORDER.index(t) if t in TASK_ORDER else 99, ["std", "lazy", "mf"].index(p), w, s)


def subsample_summary():
    runs = merged_runs()
    if not runs:
        return
    L = ["# Searching for a short surrogate g of a trained Boolean network f\n",
         "n = 50, m = 16000 uniform training inputs, one network per row. Each search family's best candidate "
         "(chosen on a 30k selection pool) is certified on 2x10^5 fresh inputs; `bound` is Theorem 2 with the "
         "design charge of accounting.py, a 4-bit prefix naming one of up to 16 search families, and the disagreement "
         "term at delta_2/16 for the same 16 slots (so the best of the families certified on a network is also a valid bound). `A` is the D_X path norm sum_i ||a_i|| ||phi_i||, `A_upd` the same for "
         "the update relative to the initialization, `N_eff` = A^2 / sum_i s_i^2 the effective number of units, "
         "`|f| med` the median |logit|. Families: " + "; ".join(f"`{k}` = {v}" for k, v in FAM_NAMES.items()) + ".\n"]
    L.append("## Networks\n")
    L.append("| task | net | width | depth | seed | test err f | move | A | A_upd | N_eff | abs f median |")
    L.append("|---|---|---|---|---|---|---|---|---|---|---|")
    for k in sorted(runs, key=sort_key):
        r = runs[k]
        i = r["info"]
        L.append(f"| {r['task']} | {r['param']} | {r['width']} | {r['depth']} | {r['seed']} | {r['test_err_f']:.4f} | "
                 f"{r['rel_param_move']:.2f} | {i.get('path_norm_A', float('nan')):.1f} | "
                 f"{i.get('path_norm_A_update', float('nan')):.1f} | {i.get('eff_units', float('nan')):.0f} | "
                 + (f"{i['margin_quantiles'][4]:.2f} |" if "margin_quantiles" in i else "- |"))
    L.append("\n## Certified bound on err(f) per search family (bits of g in parentheses)\n")
    fams = [f for f in FAMS if any(f in r["final"] for r in runs.values())]
    oracle = oracle_rows()
    L.append("| task | net | width | depth | seed | test err f | " + " | ".join(FAM_NAMES[f] for f in fams)
             + " | best search | oracle: the true teacher |")
    L.append("|---|---|---|---|---|---|" + "---|" * len(fams) + "---|---|")
    for k in sorted(runs, key=sort_key):
        r = runs[k]
        cells = []
        for f in fams:
            if f in r["final"]:
                x = r["final"][f]
                cells.append(f"{x['bound_f']:.3f} ({x['bits']:.0f})")
            else:
                cells.append("-")
        best = min(r["final"].values(), key=lambda x: x["bound_f"])
        o = oracle.get(k)
        L.append(f"| {r['task']} | {r['param']} | {r['width']} | {r['depth']} | {r['seed']} | {r['test_err_f']:.4f} | "
                 + " | ".join(cells) + f" | {best['bound_f']:.3f} | "
                 + (f"{o['best']['bound_f']:.3f} ({o['best']['bits']:.0f})" if o else "-") + " |")
    L.append("\nThe oracle column codes the true teacher network (known to us, not to the search) at the best of "
             "seven step sizes, certified on its own fresh sample; it shows what a search that found the target "
             "would certify.\n")
    L.append("\n## Disagreement Pr[f != g] of the float surrogate after keeping k units and refitting the output "
             "layer (no quantization), on the selection pool\n")
    ks_show = [4, 16, 64, 256, 1024]
    L.append("| task | net | width | mode | " + " | ".join(f"k={k}" for k in ks_show) + " |")
    L.append("|---|---|---|---|" + "---|" * len(ks_show))
    for k in sorted(runs, key=sort_key):
        r = runs[k]
        if r["depth"] != 1:
            continue
        cur = r["info"].get("float_curves", []) + r["info"].get("float_curves_greedy", [])
        for mode in ["maurey_norefit", "maurey", "uniform", "topk", "greedy", "update"]:
            d = {c["k"]: c["dis"] for c in cur if c["mode"] == mode}
            if d:
                L.append(f"| {r['task']} | {r['param']} | {r['width']} | {mode} | "
                         + " | ".join(f"{d[k]:.4f}" if k in d else "-" for k in ks_show) + " |")
    rs = [(k, g, slot) for k in sorted(runs, key=sort_key) for slot in ("restarts", "restarts_diag")
          for g in runs[k].get(slot, [])]
    if rs:
        L.append("\n## Random restarts of a small student (restarts_run.py)\n")
        L.append("Each restart is a k-unit student trained from its own random initialization for `steps` Adam steps on "
                 "f's soft labels over fresh inputs plus the training set, then quantized at the step sizes `rels` "
                 "(relative to each layer's rms weight). Restart r uses the same initialization and minibatch seed "
                 "on every network. Per-restart columns give min / median / max over the 32 restarts (float student, "
                 "before quantization); `best est. after R` is the running minimum of the estimated bound "
                 "(training-set Occam term plus disagreement on the selection pool) after R restarts. Each run "
                 "certifies its best restart on fresh inputs (`own cert.`, with the family prefix and delta_2/16 "
                 "as above). All runs on a network form one family: the run with the lowest estimated bound "
                 "(`selected`) supplies the family's certified bound, so the other certifications are never used. "
                 "Runs marked `diagnostic` (2,000 steps, the one-run budget) belong to no family. "
                 "`previous best` is the best of the other families on the same network.\n")
        L.append("| task | net | width | depth | seed | k | steps | rels | train err | Pr[f != g] | err vs target | "
                 "best est. after R = 1 / 4 / 8 / 32 | own cert. (bits, train err, Pr[f != g]) | role | previous best | oracle | secs |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for k, g, slot in rs:
            r = runs[k]
            rows = g["rows"]
            q = lambda key: "/".join(f"{v:.3f}" for v in (np.min([x[key] for x in rows]), np.median([x[key] for x in rows]),
                                                           np.max([x[key] for x in rows])))
            est = np.minimum.accumulate([min(x[c] for c in x if c.startswith("est_")) for x in rows])
            x = g["cert"]
            prev = min(v["bound_f"] for f2, v in r["final"].items() if f2 != "restarts")
            role = "diagnostic" if slot == "restarts_diag" else (
                "selected" if g is min(r["restarts"], key=lambda z: z["est_best"]) else "-")
            o = oracle.get(k)
            L.append(f"| {r['task']} | {r['param']} | {r['width']} | {r['depth']} | {r['seed']} | {g['k']} | "
                     f"{g['steps']} | {g.get('rels', '1.0,0.5,0.25')} | {q('train_err')} | {q('dis_f_sel')} | "
                     f"{q('err_target')} | " + " / ".join(f"{est[i - 1]:.3f}" for i in (1, 4, 8, 32) if i <= len(est))
                     + f" | {x['bound_f']:.3f} ({x['bits']:.0f}, {x['train_err_g'] / 16000:.4f}, "
                     f"{x['dis_count'] / x['n_cert']:.4f}) | {role} | {prev:.3f} | "
                     + (f"{o['best']['bound_f']:.3f}" if o else "-") + f" | {g['secs']:.0f} |")
    L.append("\n## Compute (seconds, one CPU thread)\n")
    L.append("| task | net | width | depth | train f | " + " | ".join(sorted({t for r in runs.values() for t in r["timing"]})) + " |")
    tk = sorted({t for r in runs.values() for t in r["timing"]})
    L.append("|---|---|---|---|---|" + "---|" * len(tk))
    for k in sorted(runs, key=sort_key):
        r = runs[k]
        L.append(f"| {r['task']} | {r['param']} | {r['width']} | {r['depth']} | {r['secs_train']:.0f} | "
                 + " | ".join(f"{r['timing'][t]:.0f}" if t in r["timing"] else "-" for t in tk) + " |")
    open(os.path.join(RES, "summary_subsample.md"), "w").write("\n".join(L) + "\n")
    curves_figure(runs)
    restarts_figure(runs, oracle)


def restarts_figure(runs, oracle):
    """Estimated bound of the best student after R random restarts, relative to the oracle bound,
    for students of the teacher's width trained for 6,000 steps (restart r's estimate is the best
    over all step sizes tried for it), with the 2,000-step diagnostic runs dashed, the best one-run
    family as a marker at the left and the restart family's certified bound as a square."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    colors = {"teacher4": "#4c78a8", "teacher8": "#e45756"}
    fig, ax = plt.subplots(figsize=(5.4, 3.4))
    drawn = False
    for k in sorted(runs, key=sort_key):
        if k not in oracle or not runs[k].get("restarts"):
            continue
        kw = 4 if k[0] == "teacher4" else 8
        ob = oracle[k]["best"]["bound_f"]
        c = colors.get(k[0], "#777777")
        for slot, steps, ls in (("restarts", 6000, "-"), ("restarts_diag", 2000, "--")):
            gs = [g for g in runs[k].get(slot, []) if g["k"] == kw and g["steps"] == steps]
            if not gs:
                continue
            per = {}
            for g in gs:
                for x in g["rows"]:
                    e = min(x[cc] for cc in x if cc.startswith("est_"))
                    per[x["restart"]] = min(per.get(x["restart"], np.inf), e)
            est = np.minimum.accumulate([per[i] for i in sorted(per)])
            R = np.arange(1, len(est) + 1)
            ax.plot(R, est / ob, color=c, lw=1.1 if ls == "-" else 0.9, alpha=0.8, ls=ls, drawstyle="steps-post")
            drawn = True
        prev = min(v["bound_f"] for f2, v in runs[k]["final"].items() if f2 != "restarts")
        ax.plot([0.7], [prev / ob], marker="o", ms=4, color=c, alpha=0.8, clip_on=False)
        ax.plot([32], [runs[k]["final"]["restarts"]["bound_f"] / ob], marker="s", ms=4, color=c, alpha=0.8)
    if not drawn:
        plt.close(fig)
        return
    for t, c in colors.items():
        ax.plot([], [], color=c, lw=1.1, label=f"{t}, k = {4 if t == 'teacher4' else 8} units, 6,000 steps")
    ax.plot([], [], color="#555555", lw=0.9, ls="--", label="2,000 steps per restart (4 networks)")
    ax.plot([], [], "o", color="#555555", ms=4, label="best one-run family (certified)")
    ax.plot([], [], "s", color="#555555", ms=4, label="restart family (certified)")
    ax.axhline(1.0, color="#333333", lw=0.8, ls=":")
    ax.text(1.0, 1.0, "true teacher (oracle)", fontsize=7, ha="left", va="bottom", color="#333333")
    ax.set_xscale("log", base=2)
    ax.set_xticks([1, 2, 4, 8, 16, 32])
    ax.set_xticklabels(["1", "2", "4", "8", "16", "32"])
    ax.set_xlim(0.6, 36)
    ax.set_xlabel("random restarts R", fontsize=8)
    ax.set_ylabel("bound / oracle bound", fontsize=8)
    ax.set_title("Dense targets: best student after R restarts (estimated bound)", fontsize=8)
    ax.tick_params(labelsize=7)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=6.5, frameon=False, loc="upper right")
    fig.tight_layout()
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(FIG, f"search_restarts.{ext}"), dpi=150)
    plt.close(fig)


def curves_figure(runs):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    tasks = [t for t in ["teacher4", "parity3", "maj5"] if any(k[0] == t for k in runs)]
    nets = [("std", 512), ("std", 4096), ("mf", 512), ("mf", 4096)]
    if not tasks:
        return
    fig, axes = plt.subplots(len(tasks), len(nets), figsize=(3.2 * len(nets), 2.6 * len(tasks)), squeeze=False,
                             sharey=True)
    styles = {"maurey_norefit": ("Maurey, no refit", "#999999", ":"), "maurey": ("Maurey + refit", "#1f77b4", "-"),
              "topk": ("top-k + refit", "#ff7f0e", "-"), "greedy": ("greedy + refit", "#2ca02c", "-"),
              "update": ("update, Maurey + refit", "#9467bd", "--")}
    for i, t in enumerate(tasks):
        for j, (p, w) in enumerate(nets):
            ax = axes[i][j]
            r = runs.get((t, p, w, 1, 0))
            if r is None:
                ax.set_visible(False)
                continue
            cur = r["info"].get("float_curves", []) + r["info"].get("float_curves_greedy", [])
            for mode, (lab, col, ls) in styles.items():
                pts = sorted((c["k"], c["dis"]) for c in cur if c["mode"] == mode)
                if pts:
                    ax.plot([a for a, _ in pts], [max(b, 1e-5) for _, b in pts], ls, color=col, marker="o", ms=3, label=lab)
            ax.set_xscale("log", base=2)
            ax.set_yscale("log")
            ax.set_ylim(1e-5, 1)
            ax.set_title(f"{t}, {p} {w} (N_eff {r['info'].get('eff_units', 0):.0f})", fontsize=8)
            if i == len(tasks) - 1:
                ax.set_xlabel("units kept k", fontsize=8)
            if j == 0:
                ax.set_ylabel("Pr[f != g]", fontsize=8)
            ax.tick_params(labelsize=7)
            ax.grid(alpha=0.3)
    h, lab = axes[0][0].get_legend_handles_labels()
    fig.legend(h, lab, loc="lower center", ncol=5, fontsize=8, frameon=False)
    fig.tight_layout(rect=(0, 0.05, 1, 1))
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(FIG, f"search_curves.{ext}"), dpi=150)
    plt.close(fig)


def dedup_twins(rows):
    """Two runners may finish the same configuration; keep the first row of each."""
    seen, out = set(), []
    for r in rows:
        k = (r["kind"], r["seed"], r["twin_seed"], tuple(t["frac"] for t in r["twins"])) + (
            (r["task"], r["noise"], r["m"]) if r["kind"] == "boolean" else (r["data"], r["widths"][1]))
        if k not in seen:
            seen.add(k)
            out.append(r)
    return out


def twin_summary():
    rows = dedup_twins(load("twin_boolean.jsonl"))
    img = dedup_twins(load("twin_images.jsonl"))
    if not rows and not img:
        return
    grid = collections.defaultdict(list)
    for p in ["grid_n50.jsonl"]:
        fp = os.path.join(ROOT, "results", "boolean", p)
        if os.path.exists(fp):
            for l in open(fp):
                r = json.loads(l)
                grid[(r["task"], r["noise"], r["m"], r["seed"])].append(r)
    L = ["# Twin bound: f bounded through a twin trained on part of its own training set\n",
         "Boolean: n = 50, f = MLP (50, 512, 512, 1) trained exactly as in the main grid (same data, seed and "
         "stopping rule, so the same network). The twin f_s is trained with the same seed on the first s = frac*m "
         "training points; its errors on the other m - s points give an exact binomial bound (delta/2), and "
         "Pr[f != f_s] a Clopper-Pearson bound on 2x10^5 fresh inputs (delta/2). `compression` is the main paper's "
         "bound (Theorem 2 with the influence codec) on the same f. Means over seeds; frac = 0.5 is the "
         "pre-specified choice, the other fractions are shown for comparison.\n",
         "| task | noise | m | seeds | test err f | compression bound | twin bound (frac 0.25 / 0.5 / 0.75) | "
         "test err twin (0.5) | Pr[f != twin] (0.5) |", "|---|---|---|---|---|---|---|---|---|"]
    g = collections.defaultdict(list)
    for r in rows:
        g[(r["task"], r["noise"], r["m"])].append(r)
    for key in sorted(g, key=lambda k: (k[1], TASK_ORDER.index(k[0]) if k[0] in TASK_ORDER else 9, k[0], k[2])):
        rr = g[key]
        te = np.mean([r["test_err_f"] for r in rr])
        comp = [boolean_bound(grid[(key[0], key[1], key[2], r["seed"])][0]) for r in rr
                if (key[0], key[1], key[2], r["seed"]) in grid]
        same = all(abs(grid[(key[0], key[1], key[2], r["seed"])][0]["test_err_f"] - r["test_err_f"]) < 1e-12
                   for r in rr if (key[0], key[1], key[2], r["seed"]) in grid)
        cb = (f"{np.mean(comp):.4f}" + ("" if same else " (different f!)")) if comp else "-"
        tw = {}
        for fr in (0.25, 0.5, 0.75):
            v = [t for r in rr for t in r["twins"] if abs(t["frac"] - fr) < 1e-9]
            tw[fr] = v
        cell = " / ".join(f"{np.mean([t['bound_f'] for t in tw[fr]]):.4f}" if tw[fr] else "-" for fr in (0.25, 0.5, 0.75))
        h = tw[0.5]
        L.append(f"| {key[0]} | {key[1]:g} | {key[2]} | {len(rr)} | {te:.4f} | {cb} | {cell} | "
                 + (f"{np.mean([t['test_err_twin'] for t in h]):.4f} | {np.mean([t['dis_count'] / t['n_cert'] for t in h]):.4f} |"
                    if h else "- | - |"))
    if img:
        t2 = collections.defaultdict(list)
        fp = os.path.join(ROOT, "results", "mnist", "t2.jsonl")
        if os.path.exists(fp):
            for l in open(fp):
                r = json.loads(l)
                t2[(r["data"], r["widths"][1])].append(r)
        L += ["\n## Images (unlabeled test inputs for the disagreement term)\n",
              "f = MLP 784-H-10, Adam, 20 epochs, trained exactly as in the main paper's unlabeled-data experiments "
              "(same network). The twin is trained on a fixed random subset of s = frac*60000 training images (same "
              "seed unless `other`); its errors on the other training images give the binomial term, and its "
              "disagreement with f on the 10,000 test images, used without labels, the Clopper-Pearson term. "
              "`compression` is the main paper's unlabeled-data bound (Theorem 2, best of K configurations).\n",
              "| data | H | twin seed | test err f | compression bound | frac | twin held-out errors | twin bound | "
              "test err twin | Pr[f != twin] on test inputs |", "|---|---|---|---|---|---|---|---|---|---|"]
        ms = load("mnist_subsample.jsonl")
        for x in ms:
            t2.setdefault((x["data"], x["width"]), []).append(dict(x, test_err_f=x["test_err_f"]))
        for r in img:
            H = r["widths"][1]
            cc = t2.get((r["data"], H), [])
            same = all(abs(x["test_err_f"] - r["test_err_f"]) < 1e-12 for x in cc)
            cb = (f"{min(t2_bound(x, len(cc)) for x in cc):.3f}" + ("" if same else " (different f!)")) if cc else "-"
            for t in r["twins"]:
                L.append(f"| {r['data']} | {H} | {r['twin_seed']} | {r['test_err_f']:.4f} | {cb} | {t['frac']:g} | "
                         f"{t['heldout_errors']}/{t['heldout_n']} | {t['bound_f']:.4f} | {t['test_err_twin']:.4f} | "
                         f"{t['dis_count'] / t['n_unlabeled']:.4f} |")
    open(os.path.join(RES, "summary_twin.md"), "w").write("\n".join(L) + "\n")
    twin_figure(g, grid)


def twin_figure(g, grid):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    keys = [k for k in sorted(g, key=lambda k: (k[1], TASK_ORDER.index(k[0]) if k[0] in TASK_ORDER else 9, k[0]))
            if k[2] == 16000 and not k[0].startswith("teacher")]   # teacher4 has no main-grid compression bound
    if not keys:
        return
    lab, te, cb, tb = [], [], [], []
    for k in keys:
        rr = g[k]
        lab.append(k[0] + (" (10% noise)" if k[1] else ""))
        te.append(np.mean([r["test_err_f"] for r in rr]))
        comp = [boolean_bound(grid[(k[0], k[1], k[2], r["seed"])][0]) for r in rr if (k[0], k[1], k[2], r["seed"]) in grid]
        cb.append(np.mean(comp) if comp else np.nan)
        tb.append(np.mean([t["bound_f"] for r in rr for t in r["twins"] if abs(t["frac"] - 0.5) < 1e-9]))
    x = np.arange(len(keys))
    fig, ax = plt.subplots(figsize=(7.5, 3.0))
    w = 0.27
    floor = 1e-4
    ax.bar(x - w, np.maximum(te, floor), w, bottom=0, label="test error of f", color="#4c78a8")
    ax.bar(x, cb, w, label="compression bound (main paper)", color="#f58518")
    ax.bar(x + w, tb, w, label="twin bound (s = m/2)", color="#54a24b")
    for xi, t in zip(x, te):
        if t < floor:
            ax.text(xi - w, floor * 1.15, "0", ha="center", fontsize=7, color="#4c78a8")
    ax.set_xticks(x)
    ax.set_xticklabels(lab, rotation=20, fontsize=8, ha="right")
    ax.set_yscale("log")
    ax.set_ylim(floor, 0.5)
    ax.set_ylabel("error / bound", fontsize=8)
    ax.set_title("n = 50, m = 16000, f = MLP (50, 512, 512, 1); means over 3 seeds", fontsize=8)
    ax.legend(fontsize=7, frameon=False)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(FIG, f"search_twin.{ext}"), dpi=150)
    plt.close(fig)


def mnist_summary():
    rows = load("mnist_subsample.jsonl")
    if not rows:
        return
    K = len(rows)
    L = ["# MNIST: short surrogates of a wide network (784-1024-10)\n",
         f"Each row: one configuration; the bound on f is Theorem 2 with Pr[f != g] on the 10,000 test images (no "
         f"labels), union-bounded over all K = {K} configurations tried for this f. Kept units are coded relative to "
         "their initialization rows in the DCT basis (+ the index set); `scratch` students relative to their own "
         "seeded init.\n",
         f"f: test error {rows[0]['test_err_f']:.4f}, {rows[0]['params']} parameters, D_X path norm A = "
         f"{rows[0]['info']['path_norm_A']:.1f}, N_eff = {rows[0]['info']['eff_units']:.0f}.\n",
         "| method | k | rel | lam | bits | train err g | Pr[f != g] (test inputs) | bound on g | bound on f |",
         "|---|---|---|---|---|---|---|---|---|"]
    for r in sorted(rows, key=lambda r: (r["method"], r["k"], r["rel"], r["lam"])):
        L.append(f"| {r['method']} | {r['k']} | {r['rel']:g} | {r['lam']:g} | {r['bits']:.0f} | {r['train_err_g']:.4f} | "
                 f"{r['dis_test_inputs']:.4f} | {r['T1_bound_g']:.3f} | {t2_bound(r, K):.3f} |")
    L.append("\nBest per method:\n")
    for meth in sorted({r["method"] for r in rows}):
        b = min((r for r in rows if r["method"] == meth), key=lambda r: t2_bound(r, K))
        L.append(f"- {meth}: k = {b['k']}, {b['bits']:.0f} bits, Pr[f != g] = {b['dis_test_inputs']:.4f}, bound on f "
                 f"{t2_bound(b, K):.3f}")
    open(os.path.join(RES, "summary_mnist_subsample.md"), "w").write("\n".join(L) + "\n")


if __name__ == "__main__":
    subsample_summary()
    twin_summary()
    mnist_summary()
    print(sorted(os.listdir(RES)))
