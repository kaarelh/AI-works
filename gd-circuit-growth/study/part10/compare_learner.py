"""The learner paper's comparison tables: v3 (hyb_portfolio3) against every baseline on every suite and dataset of the
study, computed from the result files with compare_hybrid.py's definitions (n*, cell verdicts) - writes LEARNER_RESULTS.md
and LEARNER_RESULTS.json next to this file.
usage: python compare_learner.py

Which result file stands for v3 (v3 is assembled from frozen candidates and checked identical to them on each input type,
part10/hyb_portfolio3/ASSEMBLY.md):
  toy suites      p10_sum-perm (v3 = p10_sum on toy inputs), inputs permuted per fit;
  tabular sets    hyb_portfolio3 where DFG runs (kr_vs_kp, mushroom); elsewhere v3 = v2 = v1 (identical code path: no DFG,
                  no image member; checked on optdigits), so hyb_portfolio's (v1's) Part 8 files;
  images          hyb_portfolio3 on qd_c, qd_d (Part 10 held out); p10_codes-dev (v3 = p10_codes on images) at its seed-0
                  development cells on qd_dev, fashion_mnist, qd_a, qd_b.
Toy references: the study's networks per suite (nets, nets_wd, nets_cewd, nets_cewd0.3, nets_cewd1.0 where run;
nets_best = per-target minimum over the variants run on that suite), lin, hgb; and v2, v1.
Image / tabular references: mlp, mlp_reg, mlp_strong, mlp_wide, mlp_xl, mlp_best (Part 7-8 variants), mlp_best+ (with
Part 9's wider ones), hgb; and v2, v1; context (not references): mlp_pool (an MLP on v2's pooled sums), cnn."""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "hybrid")); sys.path.insert(0, os.path.join(STUDY, "part9"))
import compare_hybrid as CH
_argv = sys.argv; sys.argv = sys.argv[:1]
import compare_part9 as C9
sys.argv = _argv
TH, DATA = CH.TH, CH.DATA
f_n = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"

TOY = [("designed", "development"), ("random", "development check (Part 6)"), ("dlheld", "held out, Part 6"),
       ("dlheld2", "held out, Part 6"), ("dlheld3", "held out, Part 8"), ("dlsymdev", "development, Part 9"),
       ("dlheld4", "held out, Part 9 (definitions seen by a builder)"), ("dlheld5", "held out, Part 9"),
       ("dlheld6", "held out, Part 9 (blind family)"), ("dlfamdev", "development, Part 10"),
       ("dlheld7", "held out, Part 10 (fresh draw of the blind family)")]
CONTROLS = {"dnf3x3", "h4rf0", "h4rf1", "h5rf0", "h5rf1", "h6_03", "h6_04", "h6_05", "fd_00", "fd_03", "fd_07",
            "f7_02", "f7_04", "f7_06"}                         # non-sum controls of the sum suites (C strata / formulas)
NETS = ("nets", "nets_wd", "nets_cewd", "nets_cewd0.3", "nets_cewd1.0")


def nst(name, suite):
    return C9.nst(name, suite) or {}


def v2_toy(suite):
    return nst("hyb_portfolio2-perm", suite) or nst("p9_sum-perm", suite)


def toy_tables():
    out, L = {}, ["## Toy suites (d = 30): n* (10% test error), learners with inputs permuted per fit", "",
                  "Mean log2 n* ratio over targets both learn; clearly better / worse: |log2 ratio| > 0.25 or only one learns it.", "",
                  "| suite | role | targets | v3 vs nets_best | v3 vs every network variant (min / max mean) | v3 vs v2 | v3 vs v1 | v3 vs lin | v3 vs hgb | v3 never |",
                  "|---|---|---|---|---|---|---|---|---|---|"]
    for su, role in TOY:
        N3 = nst("p10_sum-perm", su)
        if not N3:
            L.append(f"| {su} | {role} | (v3 not run yet) | | | | | | | |"); continue
        NR = CH.toy_nstars(su); NR = {k: v for k, v in NR.items() if k in NETS}
        fns = sorted(N3)
        nb = {t: min(NR[k][t] for k in NR if t in NR[k]) for t in fns if any(t in NR[k] for k in NR)}
        row = dict(targets=len(fns), variants=sorted(NR))
        s = lambda R: CH.toy_summary(N3, R) if R else None
        fmt = lambda t: "–" if t is None else (f"{t['mean']:+.2f}" if np.isfinite(t["mean"]) else "n/a") + f" ({t['better']}/{t['worse']})"
        row["nets_best"] = s(nb); per = {k: s(NR[k]) for k in NR}
        row["v2"] = s(v2_toy(su)); row["v1"] = s(nst("hyb_portfolio-perm", su)); row["lin"] = s(nst("lin", su)); row["hgb"] = s(nst("hgb", su))
        sub = {t: v for t, v in N3.items() if t not in CONTROLS}
        row["nets_best_sum_only"] = CH.toy_summary(sub, nb) if (nb and len(sub) < len(N3)) else None
        mm = [p["mean"] for p in per.values() if p]
        L.append(f"| {su} | {role} | {len(fns)} | {fmt(row['nets_best'])} | {min(mm):+.2f} / {max(mm):+.2f} ({len(mm)} variants) | "
                 f"{fmt(row['v2'])} | {fmt(row['v1'])} | {fmt(row['lin'])} | {fmt(row['hgb'])} | {sum(1 for v in N3.values() if not np.isfinite(v))} |"
                 if mm else f"| {su} | {role} | {len(fns)} | – | – | {fmt(row['v2'])} | {fmt(row['v1'])} | {fmt(row['lin'])} | {fmt(row['hgb'])} | |")
        row["per_target"] = {t: dict(v3=N3[t], v2=v2_toy(su).get(t), v1=nst("hyb_portfolio-perm", su).get(t), nets_best=nb.get(t),
                                     lin=nst("lin", su).get(t), hgb=nst("hgb", su).get(t), **{k: NR[k].get(t) for k in NR}) for t in fns}
        out[su] = row
    # pooled over the held-out suites
    held = [su for su, role in TOY if role.startswith("held out") and su in out]
    allr = [CH.l2r(r["v3"], r["nets_best"]) for su in held for r in out[su]["per_target"].values() if r["nets_best"] is not None]
    fin = [v for v in allr if np.isfinite(v)]
    L += ["", f"Pooled over the {len(held)} held-out suites ({len(allr)} targets): mean log2 n* ratio v3 / nets_best {np.mean(fin):+.2f} over "
              f"{len(fin)} targets both learn; clearly better {sum(1 for v in allr if v < -0.25)}, clearly worse {sum(1 for v in allr if v > 0.25)}.", ""]
    out["_pooled_heldout"] = dict(suites=held, targets=len(allr), mean=float(np.mean(fin)) if fin else None,
                                  better=sum(1 for v in allr if v < -0.25), worse=sum(1 for v in allr if v > 0.25))
    return L, out


def v3_real(ds):
    """The result file standing for v3 on a real data set (see the docstring)."""
    if ds in ("kr_vs_kp", "mushroom") or ds in ("qd_c", "qd_d"):
        return CH.load("hyb_portfolio3", ds)
    if ds in ("qd_dev", "fashion_mnist", "mnist", "qd_a", "qd_b"):
        return CH.load("p10_codes-dev", ds)
    return CH.load("hyb_portfolio", ds)


def real_tables():
    REFS = ("mlp", "mlp_reg", "mlp_strong", "mlp_wide", "mlp_xl", "mlp_best", "mlp_best+", "hgb")
    splits = [("tabular, Part 7 held-out set", [d for d in DATA.HELDOUT if d not in ("mnist", "fashion_mnist")]),
              ("tabular, Part 8 fresh set (HELDOUT2)", list(DATA.HELDOUT2)), ("tabular, development", list(DATA.DEV)),
              ("images, Part 10 held out (QuickDraw qd_c, qd_d)", ["qd_c", "qd_d"]),
              ("images, Part 9 held out (qd_a, qd_b; v3 at its seed-0 dev cells)", ["qd_a", "qd_b"]),
              ("images, development (qd_dev, Fashion-MNIST; seed-0 dev cells)", ["qd_dev", "fashion_mnist"])]
    out, L = {}, ["## Standard tasks: test error against references (cell verdicts as in Part 8)", "",
                  "| split | reference | n range | datasets | cells | better | tie | worse | mean log2(err / ref) | datasets with lower mean (sign test p) |",
                  "|---|---|---|---|---|---|---|---|---|---|"]
    for lab, names in splits:
        out[lab] = {}
        for k in REFS + (("hyb_portfolio2", "hyb_portfolio", "mlp_pool", "cnn") if "images" in lab else ()):
            for lo, hi, nl in ((0, 10 ** 9, "all"), (0, 3000, "n <= 3000"), (10000, 10 ** 9, "n >= 10000")):
                per = {}
                for ds in names:
                    R = CH.load(k, ds) if k in ("hyb_portfolio2", "hyb_portfolio", "mlp_pool", "cnn", "mlp_wide", "mlp_xl") else C9.ref(k, ds)
                    c = [x for x in CH.cells(v3_real(ds), R, ds) if lo <= x["n"] <= hi]
                    if c:
                        per[ds] = c
                C = [c for cs in per.values() for c in cs]
                if not C:
                    continue
                v = [c["v"] for c in C]; dm = [np.mean([c["lr"] for c in cs]) for cs in per.values()]
                kk = sum(x < 0 for x in dm); m = sum(x != 0 for x in dm)
                row = dict(datasets=len(per), cells=len(C), better=v.count("better"), tie=v.count("tie"), worse=v.count("worse"),
                           mean=float(np.mean([c["lr"] for c in C])), ds_lower=kk, ds_p=CH.sign_p(kk, m))
                out[lab][f"{k}|{nl}"] = row
                L.append(f"| {lab} | {k} | {nl} | {row['datasets']} | {row['cells']} | {row['better']} | {row['tie']} | {row['worse']} | "
                         f"{row['mean']:+.3f} | {kk} of {m} (p = {row['ds_p']:.2g}) |")
    L.append("")
    return L, out


def image_cells():
    """Per-cell test errors on the image sets (seed mean; seed 0 at n >= 30000) for v3 and every reference."""
    cols = ["v3", "hyb_portfolio2", "hyb_portfolio", "hgb", "mlp", "mlp_reg", "mlp_strong", "mlp_wide", "mlp_xl", "mlp_best", "mlp_best+", "mlp_pool", "cnn"]
    L = ["## Images: test error per cell", "", "| dataset | n | " + " | ".join(cols) + " |", "|---|---|" + "---|" * len(cols)]
    out = {}
    for ds in ("qd_c", "qd_d", "qd_a", "qd_b", "qd_dev", "fashion_mnist", "mnist"):
        R = {c: (v3_real(ds) if c == "v3" else CH.load(c, ds) if c in ("hyb_portfolio2", "hyb_portfolio", "hgb", "mlp", "mlp_strong", "mlp_wide", "mlp_xl", "mlp_pool", "cnn")
                 else C9.ref(c, ds)) for c in cols}
        ns = sorted({n for r in R.values() if r for n in r["ns"][:len(r["err"])]})
        out[ds] = {}
        for n in ns:
            def g(r):
                if r is None or n not in r["ns"][:len(r["err"])]:
                    return None
                v = np.array(r["err"][r["ns"].index(n)], float)
                return float(np.nanmean(v)) if np.isfinite(v).any() else None
            vals = {c: g(R[c]) for c in cols}
            if vals["v3"] is None and ds not in ("qd_c", "qd_d"):
                continue
            out[ds][n] = vals
            L.append(f"| {ds} | {n} | " + " | ".join("–" if vals[c] is None else f"{vals[c]:.4f}" for c in cols) + " |")
    return L + [""], out


if __name__ == "__main__":
    LT, T = toy_tables(); LR, Rr = real_tables(); LI, I = image_cells()
    L = ["# v3 against the baselines (learner paper tables)", "", "Generated by `compare_learner.py` from result files; definitions in its docstring.", ""] + LT + LR + LI
    open(os.path.join(HERE, "LEARNER_RESULTS.md"), "w").write("\n".join(L) + "\n")
    json.dump(dict(toy=T, real=Rr, images=I), open(os.path.join(HERE, "LEARNER_RESULTS.json"), "w"), indent=1,
              default=lambda v: None if (isinstance(v, float) and not np.isfinite(v)) else (v.item() if hasattr(v, "item") else str(v)))
    print("\n".join(L[:60]))
