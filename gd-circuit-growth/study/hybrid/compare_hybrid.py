"""Part 8 comparison: Part 8 learners against gradient descent on the toy suites (the study's networks) and on the
standard tasks (MLPs).  Writes study/hybrid/RESULTS.md; every table is computed from result files.
usage: python compare_hybrid.py <learner> [<learner> ...]

TOY.  Per suite and target: n* (training size reaching test error 0.1, log-interpolated).  Learners are run with their
inputs permuted per fit (`<learner>-perm`, the headline; after the protocol audit) and in the natural column order.
Network references (same μP MLP d-128-128-1, Adam, batch 64, 20000 steps, fixed training sets):
  nets       the study's networks (square loss, no weight decay);
  nets_wd    decoupled weight decay 0.1 (added after the fairness audit);
  nets_cewd  logistic loss + weight decay 0.1 (designed and dlheld3 only);
  nets_best  per target the variant with the smallest n* (hindsight; favours the networks).
`lin` (logistic regression on the raw inputs, cross-validated L2) is shown to separate wins that need no feature search.
REAL.  Per (dataset, n): seed-mean test error of the learner against three MLP references -
  mlp      the baseline (lr in {1e-3, 3e-4}, early stopping on validation);
  mlp_reg  the regularized MLP selected on validation: mlp_l2 (L2 penalty in {1e-4, 1e-3, 1e-2, 1e-1}) on tabular data,
           mlp_l2unit (the same with [0, 1] pixels) on images;
  mlp_strong quantile inputs, AdamW + cosine decay, wd chosen on validation, dropout 0.1, ensemble of 3 (mlp_strong.py;
           added after the fairness audit; 6 training runs per fit);
  mlp_best per cell the lowest seed-mean TEST error of all MLP variants run on that cell (mlp, mlp_plus, mlp_unit, mlp_l2,
           mlp_l2unit, mlp_strong, mlp_strong1) - chosen with hindsight on the test set, so it favours the MLP.
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
MLP_VARIANTS = ("mlp", "mlp_plus", "mlp_unit", "mlp_l2", "mlp_l2unit", "mlp_strong", "mlp_strong1")
NET_VARIANTS = (("nets", ""), ("nets_wd", "_wd0.1"), ("nets_cewd", "_cewd0.1"))


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


def sign_p(k, m):
    """Two-sided exact sign-test p-value: k of m datasets favour one side."""
    from math import comb
    if m == 0:
        return float("nan")
    t = min(k, m - k)
    return min(1.0, 2 * sum(comb(m, i) for i in range(t + 1)) / 2 ** m)


def summary_row(L, names, kind):
    per = {ds: cells(load(L, ds), ref(kind, ds), ds) for ds in names}
    per = {ds: c for ds, c in per.items() if c}
    C = [c for cs in per.values() for c in cs]
    if not C:
        return None
    v = [c["v"] for c in C]
    dfs = [c["df"] for c in C if np.isfinite(c["df"])]
    dm = [np.mean([c["lr"] for c in cs]) for cs in per.values()]            # per-dataset mean log2 ratio
    k = sum(x < 0 for x in dm); m = sum(x != 0 for x in dm)
    return dict(ds=len(per), cells=len(C), better=v.count("better"), tie=v.count("tie"), worse=v.count("worse"),
                mean=float(np.mean([c["lr"] for c in C])), median_df=float(np.median(dfs)) if dfs else float("nan"),
                never=len(C) - len(dfs), ds_lower=k, ds_p=sign_p(k, m))


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


def net_dir(suite, suffix):
    return os.path.join(TH.SCR, ("results" if suite == "designed" else "results_" + suite) + suffix)


def toy_load(name, suite):
    p = os.path.join(HERE, "results", f"toy__{name}__{suite}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def toy_nstars(suite):
    """{ref: {target: n*}} for the network variants and nets_best, from the networks' result files."""
    out = {}
    for ref_name, suf in NET_VARIANTS:
        d = net_dir(suite, suf)
        if not os.path.isdir(d):
            continue
        out[ref_name] = {}
        for f in sorted(os.listdir(d)):
            if f.startswith("fixed_adam_") and f.endswith(".npz"):
                fn = f[len("fixed_adam_"):-4]; e = TH.nn_reference(fn, d)
                out[ref_name][fn] = TH.nstar(TH.NS, np.nanmean(e, 1))
    exp = os.path.join(HERE, "results", "nets_final_err.json")       # the committed export (nets_export.py), used when
    if not out and os.path.exists(exp):                               # the network result directories are absent
        X = json.load(open(exp))
        for ref_name, T in X["err"].get(suite, {}).items():
            out[ref_name] = {fn: TH.nstar(X["ns"], np.nanmean(np.array(e, float), 1)) for fn, e in T.items()}
    if out:
        fns = out["nets"].keys() if "nets" in out else []
        out["nets_best"] = {fn: min(out[r][fn] for r in out if fn in out[r]) for fn in fns}
    return out


def l2r(a, b):
    if np.isfinite(a) and np.isfinite(b):
        return float(np.log2(a / b))
    return float("inf") if np.isfinite(b) else (float("-inf") if np.isfinite(a) else float("nan"))


def toy_summary(ln, rn, lin=None):
    """ln, rn: {target: n*} learner and reference.  lin: {target: n*} of `lin` (targets it already wins are also excluded)."""
    T = [t for t in ln if t in rn]
    r = {t: l2r(ln[t], rn[t]) for t in T}
    fin = [v for v in r.values() if np.isfinite(v)]
    better = [t for t in T if r[t] < -0.25]; worse = [t for t in T if r[t] > 0.25]
    out = dict(targets=len(T), mean=float(np.mean(fin)) if fin else float("nan"), better=len(better), worse=len(worse),
               ref_never=sum(1 for t in T if r[t] == float("-inf")), learner_never=sum(1 for t in T if r[t] == float("inf")))
    if lin is not None:
        rest = [t for t in T if not (t in lin and l2r(lin[t], rn[t]) < -0.25)]
        out.update(rest=len(rest), rest_better=sum(1 for t in rest if r[t] < -0.25), rest_worse=sum(1 for t in rest if r[t] > 0.25),
                   rest_mean=float(np.mean([r[t] for t in rest if np.isfinite(r[t])])) if rest else float("nan"))
    return out


def toy_section(learners, refs=("lin", "hgb")):
    L = []
    for suite, role in TOY_SUITES:
        NR = toy_nstars(suite)
        if not NR:
            continue
        cols = [(l + "-perm", l + " (perm)") for l in learners] + [(l, l + " (natural)") for l in learners] + [(r, r) for r in refs]
        R = {c: toy_load(c, suite) for c, _ in cols}
        cols = [(c, h) for c, h in cols if R[c] is not None]
        N = {c: {fn: TH.nstar(R[c]["ns"], np.nanmean(np.array(r["err"], float), 1)) for fn, r in R[c]["fns"].items()} for c, _ in cols}
        refc = [k for k in ("nets", "nets_wd", "nets_cewd", "nets_best") if k in NR]
        f = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"
        L += [f"### Toy suite `{suite}` ({role}): n* per target", "",
              "| target | " + " | ".join(h for _, h in cols) + " | " + " | ".join(refc) + " |",
              "|---|" + "---|" * (len(cols) + len(refc))]
        for fn in NR["nets"]:
            L.append(f"| {fn} | " + " | ".join(f(N[c].get(fn, np.nan)) if fn in N[c] else "–" for c, _ in cols) + " | "
                     + " | ".join(f(NR[k].get(fn, np.nan)) for k in refc) + " |")
        L += ["", "| learner | reference | targets | mean log2(n* / ref n*) (both learn) | clearly better | clearly worse | ref never | learner never | without targets `lin` wins: targets / better / worse / mean |",
              "|---|---|---|---|---|---|---|---|---|"]
        for c, h in cols:
            for k in refc:
                t = toy_summary(N[c], NR[k], N.get("lin"))
                L.append(f"| {h} | {k} | {t['targets']} | {t['mean']:+.2f} | {t['better']} | {t['worse']} | {t['ref_never']} | "
                         f"{t['learner_never']} | " + (f"{t['rest']} / {t['rest_better']} / {t['rest_worse']} / {t['rest_mean']:+.2f}"
                                                       if "rest" in t else "–") + " |")
        for c, h in cols:
            if c in [l + "-perm" for l in learners]:
                fl = max(np.nanmax(np.array(r["flops"], float)) for r in R[c]["fns"].values()) / R[c]["gd_flops"]
                L.append(f"\n{h}: largest FLOPs per fit / one network run: {fl:.2f}.")
        L.append("")
    return L


def real_section(learners):
    L = []
    for split, names in SPLITS:
        L += [f"### Summary, {split}", "",
              "| learner | reference | datasets | cells | better | tie | worse | mean log2(err / ref err) | datasets with lower mean error (sign-test p) | median data factor | ref error never reached |",
              "|---|---|---|---|---|---|---|---|---|---|---|"]
        for l in learners + ["hgb", "mlp"]:
            for kind in ("mlp", "mlp_reg", "mlp_strong", "mlp_best"):
                if l == kind or (l == "mlp" and kind == "mlp"):
                    continue
                s = summary_row(l, names, kind)
                if s:
                    L.append(f"| {l} | {kind} | {s['ds']} | {s['cells']} | {s['better']} | {s['tie']} | {s['worse']} | "
                             f"{s['mean']:+.2f} | {s['ds_lower']} of {s['ds']} ({s['ds_p']:.2g}) | {s['median_df']:.2f} | {s['never']} |")
        for l in learners:
            ff = flops_frac(l, names)
            if ff:
                L.append(f"\n{l}: largest FLOPs / budget (3 MLP runs) over these cells: {max(ff):.2f}; cells over budget: "
                         f"{sum(f > 1 for f in ff)} of {len(ff)}.")
        L.append("")
    L += ["### Test error by dataset and n (seed mean)", "",
          "| dataset | n | mlp | mlp_reg | mlp_strong | mlp_best (variant) | " + " | ".join(learners) + " | hgb |",
          "|---|---|---|---|---|---|" + "---|" * (len(learners) + 1)]
    for split, names in SPLITS:
        for ds in names:
            rm = load("mlp", ds)
            if rm is None:
                continue
            R = dict(mlp=rm, mlp_reg=ref("mlp_reg", ds), mlp_strong=load("mlp_strong", ds), mlp_best=ref("mlp_best", ds), hgb=load("hgb", ds),
                     **{l: load(l, ds) for l in learners})
            for n in rm["ns"][:len(rm["err"])]:
                def g(k):
                    r = R[k]
                    if r is None or n not in r["ns"][:len(r["err"])]:
                        return "–"
                    e = np.nanmean(np.array(r["err"][r["ns"].index(n)], float))
                    return f"{e:.4f}"
                vb = R["mlp_best"]["variant"][R["mlp_best"]["ns"].index(n)] if n in R["mlp_best"]["ns"] else ""
                L.append(f"| {ds} | {n} | {g('mlp')} | {g('mlp_reg')} | {g('mlp_strong')} | {g('mlp_best')} ({vb}) | " + " | ".join(g(l) for l in learners)
                         + f" | {g('hgb')} |")
    return L


def coverage(learners):
    """Warn about reference or learner rows missing on any grid cell (a missing cell is silently skipped otherwise)."""
    W = []
    for split, names in SPLITS:
        for ds in names:
            rm = load("mlp", ds)
            if rm is None:
                W.append(f"{ds}: mlp missing"); continue
            for k in ["mlp_reg", "mlp_strong"] + learners:
                r = ref(k, ds) if k == "mlp_reg" else load(k, ds)
                have = [] if r is None else [n for i, n in enumerate(r["ns"][:len(r["err"])]) if np.any(np.isfinite(r["err"][i]))]
                miss = [n for n in rm["ns"] if n not in have]
                if miss:
                    W.append(f"{ds}: {k} missing n = {miss}")
    return W


def main(learners):
    L = ["# Part 8 results: discrete learners against gradient descent on toy and standard tasks", "",
         "Generated by `compare_hybrid.py` from result files (see its docstring for definitions).", "",
         "## Toy Boolean suites (d = 30) against the study's networks", ""]
    L += toy_section(learners)
    L += ["## Standard tasks against MLPs", ""]
    L += real_section(learners)
    cw = coverage(learners)
    L += ["", "### Coverage", ""] + ([f"* {w}" for w in cw] if cw else ["All cells present."])
    open(os.path.join(HERE, "RESULTS.md"), "w").write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main(sys.argv[1:])
