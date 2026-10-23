"""Markdown tables for MINIMAL-MODEL.md from minimal_report.json and the saved evaluations (prints to stdout)."""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common as C
R = json.load(open(os.path.join(HERE, "minimal_report.json")))
EV = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
cap = 2 * 16384
fmt = lambda v: "–" if v is None else ("never" if not np.isfinite(v) else f"{v:.0f}")
lr = lambda m, nn: abs(np.log2(min(m, cap) / min(nn, cap)))


def spear(a, b):
    a, b = np.minimum(a, cap), np.minimum(b, cap)
    ra = np.argsort(np.argsort(a)); rb = np.argsort(np.argsort(b)); return float(np.corrcoef(ra, rb)[0, 1])


def nstar_table():
    print("| target | split | network | analytic predictor | binding term at $n^*$ | minimal model | race | Occam-law predictor |")
    print("|---|---|---|---|---|---|---|---|")
    for fn, v in R["d30"].items():
        b = v["binding"] or ""
        b = b.replace("rho2=", "ρ²=").replace("gate ", "gate ").replace("hebb", "Hebbian noise")
        print(f"| {fn} | {v['split']} | {fmt(v['nn'])} | {fmt(v['pred'])} | {b} | {fmt(v.get('model'))} | {fmt(v.get('race'))} | {fmt(v['occam'])} |")


def summary_rows():
    print("| predictor | constants (CALIB fit) | HELDOUT mean abs log2 ratio | HELDOUT Spearman | CALIB mean abs log2 ratio | CALIB Spearman |")
    print("|---|---|---|---|---|---|")
    for key, lab, cst in (("pred", "search law (this note)", f"c = {R['c_pred']}, a = {R['a_pred']}"),
                          ("occam", "Occam law N = log M_k", f"c = {R['c_occam']}"),
                          ("model", "minimal model (empirical)", "see Section 1"),
                          ("race", "race model", "θ, λ, Q")):
        row = []
        for fns in (C.HELDOUT, C.CALIB):
            nn = np.array([R["d30"][f]["nn"] for f in fns]); m = np.array([R["d30"][f].get(key) or np.nan for f in fns], float)
            row += [np.mean([lr(x, y) for x, y in zip(m, nn)]), spear(nn, m)]
        print(f"| {lab} | {cst} | {row[0]:.2f} | {row[1]:.2f} | {row[2]:.2f} | {row[3]:.2f} |")


def dscale_table():
    ds = ["15", "30", "60"]
    print("| target | network | analytic predictor | minimal model | race | no leap cost ($a=\\infty$) | Occam law |")
    print("|---|---|---|---|---|---|---|")
    for fn, row in R["dscale"].items():
        cell = lambda k: " / ".join(fmt(row[d].get(k)) for d in ds)
        print(f"| {fn} | {cell('nn')} | {cell('pred')} | {cell('model')} | {cell('race')} | {cell('noleap')} | {cell('occam')} |")
    print()
    print("| d | " + " | ".join(R["dscale"]) + " | mean |")
    print("|---|" + "---|" * (len(R["dscale"]) + 1))
    for key, lab in (("pred", "predictor"), ("model", "minimal model"), ("race", "race"), ("noleap", "no leap cost"), ("occam", "Occam law")):
        for d in ds:
            v = [lr(R["dscale"][f][d][key], R["dscale"][f][d]["nn"]) if R["dscale"][f][d].get(key) is not None and R["dscale"][f][d]["nn"] else np.nan
                 for f in R["dscale"]]
            print(f"| {lab}, d = {d} | " + " | ".join("–" if np.isnan(x) else f"{x:.2f}" for x in v) + f" | {np.nanmean(v):.2f} |")
    print()
    print("| target | network exponent | predictor | minimal model | race | no leap cost | Occam law |")
    print("|---|---|---|---|---|---|---|")
    L = np.log([15, 30, 60])
    for fn, row in R["dscale"].items():
        def ex(k):
            v = [row[d].get(k) for d in ds]
            if any(x is None or not np.isfinite(x) for x in v):
                return "–"
            return f"{np.polyfit(L, np.log(v), 1)[0]:.2f}"
        print(f"| {fn} | {ex('nn')} | {ex('pred')} | {ex('model')} | {ex('race')} | {ex('noleap')} | {ex('occam')} |")


def scoreboard(split):
    fns = C.HELDOUT if split == "HELDOUT" else C.CALIB
    keys = ["sc_mean_abs_log2_ratio", "sc_spearman", "success_agreement", "curve_mae", "example_agreement_score", "time_spearman"]
    print("| model | mean abs log2 n* ratio | n* Spearman | success agreement | curve MAE | per-example agreement | time Spearman |")
    print("|---|---|---|---|---|---|---|")
    nn = np.array([R["d30"][f]["nn"] for f in fns]); pr = np.array([R["d30"][f]["pred"] for f in fns])
    pc = R[f"pred_curve_{split}"]
    print(f"| **analytic predictor** (2 constants) | {np.mean([lr(a, b) for a, b in zip(pr, nn)]):.2f} | {spear(nn, pr):.2f} | "
          f"{pc['success_agreement']:.2f} | {pc['curve_mae']:.2f} | – | – |")
    rows = [("minimal", "**minimal model** (2 constants)"), ("race", "race (3 constants)"), ("sswm", "sswm"),
            ("nngp-kernel", "NNGP kernel"), ("occam-junta", "Occam over juntas")]
    for name, lab in rows:
        path = os.path.join(EV, name + ".npz")
        if not os.path.exists(path):
            continue
        b = C.compare(C.load_eval(path), "adam", fns=fns, verbose=False)
        print(f"| {lab} | " + " | ".join(f"{b[k]:.2f}" if b[k] == b[k] else "–" for k in keys) + " |")
    if split == "HELDOUT":
        b = C.compare(C.nn_as_model_res("sgd", fns=C.HELDOUT), "adam", fns=C.HELDOUT, verbose=False)
        print("| *reference: networks trained with μP-SGD* | " + " | ".join(f"*{b[k]:.2f}*" for k in keys) + " |")


if __name__ == "__main__":
    if sys.argv[1] == "scoreboard":
        scoreboard(sys.argv[2])
    else:
        {"nstar": nstar_table, "summary": summary_rows, "dscale": dscale_table}[sys.argv[1]]()
