"""Part 9 comparison tables (study/part9/RESULTS.md), computed from result files with compare_hybrid.py's functions.
usage: python compare_part9.py [v2_name]          (default hyb_portfolio2)

TOY (inputs permuted for the discrete learners): n* per target and summaries against nets / nets_wd / nets_cewd / nets_best
on the dev suites (designed, dlsymdev) and the held-out suites (dlheld4: definitions seen by the sum-feature builder;
dlheld5: generated after its freeze, inside its class; dlheld6: written blind to its design, Amendment 3).  Q1 subset:
the sum-structured targets (all but the controls: random formulas, DNFs, decision lists).
IMAGES: test error by n on qd_a, qd_b (held out) and the dev sets; summaries against mlp, mlp_reg (mlp_l2unit),
mlp_strong, mlp_strong1, mlp_best, by n range (all, n <= 3000, n >= 10000 = Q2).
INTEGRATION RULE (PROTOCOL.md): dev image cells n in {1000, 10000, 60000}, seed 0, mean log2(err / mlp_best err)."""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import compare_hybrid as CH
TH, DATA = CH.TH, CH.DATA
V2 = sys.argv[1] if len(sys.argv) > 1 else "hyb_portfolio2"
TOY = [("dlsymdev", "dev"), ("designed", "dev"), ("dlheld4", "held out; definitions seen by the S builder"),
       ("dlheld5", "held out; family specified after S's design summary was read, inside its representable class"),
       ("dlheld6", "held out; family written by an agent blind to the S design (Amendment 3)")]
NONSUM = {"dnf3x3", "h4rf0", "h4rf1", "h5rf0", "h5rf1", "h6_03", "h6_04", "h6_05"}   # controls (non-symmetric)
IMG_HELD, IMG_DEV = ["qd_a", "qd_b"], ["qd_dev", "mnist", "fashion_mnist"]
REFS = ("mlp", "mlp_reg", "mlp_strong", "mlp_strong1", "mlp_best")


def nst(name, suite):
    r = CH.toy_load(name, suite)
    if r is None:
        return None
    return {fn: TH.nstar(r["ns"], np.nanmean(np.array(v["err"], float), 1)) for fn, v in r["fns"].items()}


def toy_part():
    L = ["## Toy suites (d = 30): n*, inputs permuted for the discrete learners", ""]
    f = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"
    cols = [(V2 + "-perm", "v2"), ("p9_sum-perm", "p9_sum"), ("hyb_portfolio-perm", "v1"), ("lin", "lin"), ("hgb", "hgb")]
    for suite, role in TOY:
        NR = CH.toy_nstars(suite)
        if not NR:
            continue
        N = {c: nst(c, suite) for c, _ in cols}; have = [(c, h) for c, h in cols if N[c]]
        refc = [k for k in ("nets", "nets_wd", "nets_cewd", "nets_best") if k in NR]
        L += [f"### `{suite}` ({role})", "", "| target | " + " | ".join(h for _, h in have) + " | " + " | ".join(refc) + " |",
              "|---|" + "---|" * (len(have) + len(refc))]
        for fn in NR["nets"]:
            L.append(f"| {fn} | " + " | ".join(f(N[c].get(fn, np.nan)) for c, _ in have) + " | " + " | ".join(f(NR[k].get(fn, np.nan)) for k in refc) + " |")
        L += ["", "| learner | reference | targets | mean log2 n* ratio | clearly better | clearly worse | learner never | sum-structured targets: n / mean / better / worse |",
              "|---|---|---|---|---|---|---|---|"]
        for c, h in have:
            for k in refc:
                t = CH.toy_summary(N[c], NR[k])
                sub = {fn: v for fn, v in N[c].items() if fn not in NONSUM}
                ts = CH.toy_summary(sub, NR[k])
                L.append(f"| {h} | {k} | {t['targets']} | {t['mean']:+.2f} | {t['better']} | {t['worse']} | {t['learner_never']} | "
                         f"{ts['targets']} / {ts['mean']:+.2f} / {ts['better']} / {ts['worse']} |")
        for c, h in have:
            if c.endswith("-perm") and N[c]:
                r = CH.toy_load(c, suite)
                fl = max(np.nanmax(np.array(v["flops"], float)) for v in r["fns"].values()) / r["gd_flops"]
                L.append(f"\n{h}: largest FLOPs per fit / one network run: {fl:.2f}.")
        L.append("")
    return L


def img_cells(L_, ds, ref_kind, nmin=0, nmax=10 ** 9):
    return [c for c in CH.cells(CH.load(L_, ds), CH.ref(ref_kind, ds) if ref_kind in ("mlp_reg", "mlp_best") else CH.load(ref_kind, ds), ds)
            if nmin <= c["n"] <= nmax]


def img_part():
    L = ["## Images: test error (seed mean; seed 0 only at n >= 30000 for every learner except where noted)", ""]
    learners = [V2, "hyb_portfolio", "hgb"]
    for split, names in (("held out (QuickDraw qd_a, qd_b; pixel-permuted)", IMG_HELD), ("dev", IMG_DEV)):
        L += [f"### Summary, {split}", "",
              "| learner | reference | n range | cells | better | tie | worse | mean log2(err / ref err) |", "|---|---|---|---|---|---|---|---|"]
        for l in learners:
            for k in REFS:
                for lo, hi, lab in ((0, 10 ** 9, "all"), (0, 3000, "n <= 3000"), (10000, 10 ** 9, "n >= 10000")):
                    C = [c for ds in names for c in img_cells(l, ds, k, lo, hi)]
                    if not C:
                        continue
                    v = [c["v"] for c in C]
                    L.append(f"| {l} | {k} | {lab} | {len(C)} | {v.count('better')} | {v.count('tie')} | {v.count('worse')} | "
                             f"{np.mean([c['lr'] for c in C]):+.2f} |")
        L.append("")
        L += ["| dataset | n | " + " | ".join(learners) + " | " + " | ".join(REFS) + " |", "|---|---|" + "---|" * (len(learners) + len(REFS))]
        for ds in names:
            R = {l: CH.load(l, ds) for l in learners + ["mlp", "mlp_strong", "mlp_strong1"]}
            R["mlp_reg"], R["mlp_best"] = CH.ref("mlp_reg", ds), CH.ref("mlp_best", ds)
            base = R["mlp"] or R["mlp_strong"]
            if base is None:
                continue
            for n in base["ns"]:
                def g(k):
                    r = R.get(k)
                    if r is None or n not in r["ns"][:len(r["err"])]:
                        return "–"
                    return f"{np.nanmean(np.array(r['err'][r['ns'].index(n)], float)):.4f}"
                L.append(f"| {ds} | {n} | " + " | ".join(g(l) for l in learners) + " | " + " | ".join(g(k) for k in REFS) + " |")
        L.append("")
    return L


def img_compute():
    """Compute per image cell (audit F1, F7): own-count FLOPs / budget_real (max over seeds) and CPU seconds per fit
    (seed mean; process time) for the discrete learners, and the recorded CPU seconds of the MLP references."""
    import common
    L = ["## Images: compute per fit (own FLOP count / budget of 3 MLP runs; CPU seconds, process time)", "",
         "Prediction is not charged; see PART9.md for the per-query cost.", "",
         "| dataset | n | budget (FLOPs) | " + " | ".join(f"{l} FLOPs/budget" for l in (V2, "hyb_portfolio")) + " | "
         + " | ".join(f"{l} CPU s" for l in (V2, "hyb_portfolio", "mlp", "mlp_strong")) + " |", "|---|---|---|" + "---|" * 6]
    for ds in IMG_HELD:
        D = DATA.load(ds)
        R = {l: CH.load(l, ds) for l in (V2, "hyb_portfolio", "mlp", "mlp_strong")}
        if R[V2] is None:
            continue
        for a, n in enumerate(R[V2]["ns"]):
            B = common.budget_real(D["X"][:1], list(D["types"]), D["C"], n)
            def fr(l):
                r = R[l]
                if r is None or n not in r["ns"] or r["ns"].index(n) >= len(r.get("flops", [])):
                    return "–"
                v = np.array(r["flops"][r["ns"].index(n)], float)
                return f"{np.nanmax(v) / B:.2f}" if np.isfinite(v).any() else "–"
            def cp(l):
                r = R[l]
                if r is None or n not in r["ns"] or r["ns"].index(n) >= len(r.get("cpu_seconds", [])):
                    return "–"
                v = np.array(r["cpu_seconds"][r["ns"].index(n)], float)
                return f"{np.nanmean(v):.0f}" if np.isfinite(v).any() else "–"
            L.append(f"| {ds} | {n} | {B:.3g} | {fr(V2)} | {fr('hyb_portfolio')} | " + " | ".join(cp(l) for l in (V2, "hyb_portfolio", "mlp", "mlp_strong")) + " |")
    return L + [""]


def rule_part():
    L = ["## Integration rule: dev image cells (n in {1000, 10000, 60000}, seed 0)", "",
         "| candidate | cells | mean log2(err / mlp_best err) | per cell (ds@n: err / mlp_best) |", "|---|---|---|---|"]
    for cand, files in (("p9_gates", "p9_gates-dev"), ("p9_bank", "p9_bank-dev"), ("v1 (hyb_portfolio)", "hyb_portfolio")):
        vals, txt = [], []
        for ds in IMG_DEV:
            r = CH.load(files, ds); mb = CH.ref("mlp_best", ds)
            for n in (1000, 10000, 60000):
                if r is None or n not in r["ns"][:len(r["err"])] or n not in mb["ns"]:
                    continue
                e = float(np.array(r["err"][r["ns"].index(n)], float)[0])
                b = float(np.nanmean(np.array(mb["err"][mb["ns"].index(n)], float)))
                vals.append(np.log2(max(e, 0.002) / max(b, 0.002))); txt.append(f"{ds}@{n}: {e:.4f}/{b:.4f}")
        L.append(f"| {cand} | {len(vals)} | {np.mean(vals) if vals else float('nan'):+.3f} | {'; '.join(txt)} |")
    return L + [""]


if __name__ == "__main__":
    L = ["# Part 9 results", "", "Generated by `compare_part9.py` from result files (definitions in its docstring and in "
         "`../hybrid/compare_hybrid.py`).", ""] + rule_part() + toy_part() + img_part() + img_compute()
    open(os.path.join(HERE, "RESULTS.md"), "w").write("\n".join(L) + "\n")
    print("\n".join(L[:20]))
