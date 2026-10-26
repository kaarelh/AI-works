"""Part 8 comparison: Part 8 learners against gradient descent on the toy suites (the study's networks) and on the
standard tasks (MLPs).  Writes study/hybrid/RESULTS.md; every table is computed from result files.
usage: python compare_hybrid.py <learner> [<learner> ...]

TOY.  Per suite and target: n* (training size reaching test error 0.1, log-interpolated) of the learner and of the
networks (refreshed from the networks' result files), via discrete_learner/harness.report.
REAL.  Per (dataset, n): seed-mean test error of the learner against three MLP references -
  mlp      the baseline (lr in {1e-3, 3e-4}, early stopping on validation);
  mlp_reg  the regularized MLP selected on validation: mlp_l2 (L2 penalty in {1e-4, 1e-3, 1e-2, 1e-1}) on tabular data,
           mlp_l2unit (the same with [0, 1] pixels) on images;
  mlp_best per cell the lowest seed-mean TEST error of mlp, mlp_plus, mlp_unit, mlp_l2, mlp_l2unit - chosen with hindsight on
           the test set, so it favours the MLP.
Cell verdict as in standard_tasks/compare.py: better / worse if the errors differ by > 10% relative and by > 2 s.e. (seed
spread of both, at least the binomial test-set noise); log2 ratio uses max(err, 0.002)."""
import os, sys, json, io, contextlib, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import common
import importlib.util
_spec = importlib.util.spec_from_file_location("toy_harness", os.path.join(common.STUDY, "discrete_learner", "harness.py"))
TH = importlib.util.module_from_spec(_spec); _spec.loader.exec_module(TH)
SH = common.SH; DATA = SH.DATA
sys.path.insert(0, os.path.join(common.STUDY, "standard_tasks"))
import compare as SC                                          # n_test (noise floor), curve
IMG = ["mnist", "fashion_mnist"]
SPLITS = [("held-out tabular (Part 7 set)", [d for d in DATA.HELDOUT if d not in IMG]),
          ("held-out tabular (fresh Part 8 set)", list(DATA.HELDOUT2)), ("held-out images", IMG), ("dev", list(DATA.DEV))]
TOY_SUITES = [("designed", "dev"), ("random", "held-out"), ("dlheld", "held-out"), ("dlheld2", "held-out"),
              ("dlheld3", "held-out (fresh Part 8 set)")]
MLP_VARIANTS = ("mlp", "mlp_plus", "mlp_unit", "mlp_l2", "mlp_l2unit")


def load(learner, ds):
    p = os.path.join(SH.RES, f"{learner}__{ds}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def ref(kind, ds):
    if kind == "mlp_reg":
        return load("mlp_l2unit" if ds in IMG else "mlp_l2", ds)
    if kind != "mlp_best":
        return load(kind, ds)
    base = load("mlp", ds)
    if base is None:
        return None
    E, F, V = [], [], []
    for j, n in enumerate(base["ns"][:len(base["err"])]):
        best = ("mlp", base["err"][j], base["flops"][j])
        for v in MLP_VARIANTS[1:]:
            r = load(v, ds)
            if r is not None and n in r["ns"][:len(r["err"])]:
                k = r["ns"].index(n)
                if np.nanmean(r["err"][k]) < np.nanmean(best[1]):
                    best = (v, r["err"][k], r["flops"][k])
        E.append(best[1]); F.append(best[2]); V.append(best[0])
    return dict(ns=base["ns"][:len(E)], err=E, flops=F, variant=V)


def cells(rl, rm, ds):
    if rl is None or rm is None:
        return []
    nl, el, El = SC.curve(rl); nm, em, Em = SC.curve(rm)
    out = []
    for j, n in enumerate(nm):
        if n not in nl or np.isnan(em[j]):
            continue
        i = list(nl).index(n)
        if np.isnan(el[i]):
            continue
        kl, km = np.sum(~np.isnan(El[i])), np.sum(~np.isnan(Em[j]))
        se = np.sqrt((np.nanvar(El[i], ddof=1) / kl if kl > 1 else 0.0) + (np.nanvar(Em[j], ddof=1) / km if km > 1 else 0.0))
        a, b = el[i], em[j]; nt = SC.n_test(ds)
        se = max(se, np.sqrt(a * (1 - a) / nt + b * (1 - b) / nt))
        rel = (a - b) / max(b, 1e-3)
        v = "better" if (rel < -0.1 and b - a > 2 * se) else ("worse" if (rel > 0.1 and a - b > 2 * se) else "tie")
        nn, _ = SC.n_for_err(nl, el, b)
        out.append(dict(n=int(n), a=float(a), b=float(b), lr=float(np.log2(max(a, 0.002) / max(b, 0.002))), v=v,
                        df=nn / n if np.isfinite(nn) else float("inf")))
    return out


def summary_row(L, names, kind):
    C = [c for ds in names for c in cells(load(L, ds), ref(kind, ds), ds)]
    if not C:
        return None
    v = [c["v"] for c in C]
    dfs = [c["df"] for c in C if np.isfinite(c["df"])]
    return dict(ds=len({ds for ds in names if cells(load(L, ds), ref(kind, ds), ds)}), cells=len(C), better=v.count("better"),
                tie=v.count("tie"), worse=v.count("worse"), mean=float(np.mean([c["lr"] for c in C])),
                median_df=float(np.median(dfs)) if dfs else float("nan"), never=len(C) - len(dfs))


def flops_frac(L, names):
    out = []
    for ds in names:
        r = load(L, ds)
        if r is None:
            continue
        D = DATA.load(ds)
        for i, n in enumerate(r["ns"][:len(r["flops"])]):
            f = np.nanmax(np.array(r["flops"][i], float)) if np.any(np.isfinite(r["flops"][i])) else np.nan
            if np.isfinite(f):
                pool, _ = DATA.splits(D, 0)
                out.append(f / common.budget_real(D["X"][pool[:n]], list(D["types"]), D["C"], n))
    return out


def toy_section(learners, refs=("hgb",)):
    L = []
    for suite, role in TOY_SUITES:
        L += [f"### Toy suite `{suite}` ({role})", ""]
        for name in learners + list(refs):
            p = os.path.join(HERE, "results", f"toy__{name}__{suite}.json")
            if not os.path.exists(p):
                continue
            res = json.load(open(p))
            rdir = os.path.join(TH.SCR, "results" if suite == "designed" else "results_" + suite)
            for fn, r in res["fns"].items():
                nr = TH.nn_reference(fn, rdir)
                r["nn_err"] = None if nr is None else nr.tolist()
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                TH.report(res)
            L += [buf.getvalue().replace(f"## {res['learner']} on", f"#### {res['learner']} on"), ""]
    return L


def real_section(learners):
    L = []
    for split, names in SPLITS:
        L += [f"### Summary, {split}", "",
              "| learner | reference | datasets | cells | better | tie | worse | mean log2(err / ref err) | median data factor | ref error never reached |",
              "|---|---|---|---|---|---|---|---|---|---|"]
        for l in learners + ["hgb", "mlp"]:
            for kind in ("mlp", "mlp_reg", "mlp_best"):
                if l == kind or (l == "mlp" and kind == "mlp"):
                    continue
                s = summary_row(l, names, kind)
                if s:
                    L.append(f"| {l} | {kind} | {s['ds']} | {s['cells']} | {s['better']} | {s['tie']} | {s['worse']} | "
                             f"{s['mean']:+.2f} | {s['median_df']:.2f} | {s['never']} |")
        for l in learners:
            ff = flops_frac(l, names)
            if ff:
                L.append(f"\n{l}: largest FLOPs / budget (3 MLP runs) over these cells: {max(ff):.2f}; cells over budget: "
                         f"{sum(f > 1 for f in ff)} of {len(ff)}.")
        L.append("")
    L += ["### Test error by dataset and n (seed mean)", "",
          "| dataset | n | mlp | mlp_reg | mlp_best | " + " | ".join(learners) + " | hgb |",
          "|---|---|---|---|---|" + "---|" * (len(learners) + 1)]
    for split, names in SPLITS:
        for ds in names:
            rm = load("mlp", ds)
            if rm is None:
                continue
            R = dict(mlp=rm, mlp_reg=ref("mlp_reg", ds), mlp_best=ref("mlp_best", ds), hgb=load("hgb", ds),
                     **{l: load(l, ds) for l in learners})
            for n in rm["ns"][:len(rm["err"])]:
                def g(k):
                    r = R[k]
                    if r is None or n not in r["ns"][:len(r["err"])]:
                        return "–"
                    e = np.nanmean(np.array(r["err"][r["ns"].index(n)], float))
                    return f"{e:.4f}"
                L.append(f"| {ds} | {n} | {g('mlp')} | {g('mlp_reg')} | {g('mlp_best')} | " + " | ".join(g(l) for l in learners)
                         + f" | {g('hgb')} |")
    return L


def main(learners):
    L = ["# Part 8 results: discrete learners against gradient descent on toy and standard tasks", "",
         "Generated by `compare_hybrid.py` from result files (see its docstring for definitions).", "",
         "## Toy Boolean suites (d = 30) against the study's networks", ""]
    L += toy_section(learners)
    L += ["## Standard tasks against MLPs", ""]
    L += real_section(learners)
    open(os.path.join(HERE, "RESULTS.md"), "w").write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main(sys.argv[1:])
