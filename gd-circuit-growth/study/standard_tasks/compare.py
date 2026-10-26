"""Compare learners with the MLP on the standard tasks; writes RESULTS.md (all tables generated from results/*.json).

For each learner L and dataset:
  - test error at every grid n (seed mean), next to the MLP's;
  - cell verdict: better / worse if the seed-mean errors differ by more than 10% relative AND by more than 2 standard errors of
    the seed-to-seed spread (both learners); otherwise 'tie';
  - data factor: for each grid n, the training size at which L reaches the MLP's error at n (log-log interpolation of L's
    curve; censored at L's grid ends), divided by n.  Below 1: L needs less data than the MLP for the same error.
Summaries per learner: over held-out and dev datasets separately.
usage: python compare.py [learner ...]
"""
import os, sys, json, glob, numpy as np
import data as DATA
from harness import RES

HERE = os.path.dirname(os.path.abspath(__file__))
REFS = ["linear", "hgb"]


_NT = {}


def n_test(ds):
    if ds not in _NT:
        _NT[ds] = DATA.load(ds)["n_test"]
    return _NT[ds]


def load(learner, ds):
    p = os.path.join(RES, f"{learner}__{ds}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def curve(r):
    E = np.array(r["err"], float)
    return np.array(r["ns"][:len(E)], float), np.nanmean(E, 1), E          # (a run in progress has fewer rows)


def n_for_err(ns, e, target):
    """Smallest n (log-log interpolation along the curve) at which error <= target; nan if never reached (inf) or
    already below at the first grid point (returns ns[0] marked censored)."""
    for i in range(len(ns)):
        if e[i] <= target:
            if i == 0:
                return ns[0], "le"
            a, b = np.log(max(e[i - 1], 1e-4)), np.log(max(e[i], 1e-4)); t = np.log(max(target, 1e-4))
            f = (a - t) / max(a - b, 1e-12)
            return float(np.exp(np.log(ns[i - 1]) + f * (np.log(ns[i]) - np.log(ns[i - 1])))), "eq"
    return float("inf"), "ge"


def cells(L, ds, ref="mlp"):
    rl, rm = load(L, ds), load(ref, ds)
    if rl is None or rm is None:
        return None
    nl, el, El = curve(rl); nm, em, Em = curve(rm)
    out = []
    for j, n in enumerate(nm):
        if n not in nl:
            continue
        i = list(nl).index(n)
        kl, km = np.sum(~np.isnan(El[i])), np.sum(~np.isnan(Em[j]))
        se = np.sqrt((np.nanvar(El[i], ddof=1) / kl if kl > 1 else 0.0) + (np.nanvar(Em[j], ddof=1) / km if km > 1 else 0.0))
        a, b = el[i], em[j]
        nt = n_test(ds)                                                   # floor: binomial test-set noise of both errors
        se = max(se, np.sqrt(a * (1 - a) / nt + b * (1 - b) / nt))
        rel = (a - b) / max(b, 1e-3)
        verdict = "better" if (rel < -0.1 and b - a > 2 * se) else ("worse" if (rel > 0.1 and a - b > 2 * se) else "tie")
        nn, kind = n_for_err(nl, el, b)
        fr = float(np.nanmax(np.array(rl["flops"], float)[i]) / np.nanmax(np.array(rm["flops"], float)[j]))
        out.append(dict(n=int(n), err_l=float(a), err_m=float(b), log2_ratio=float(np.log2(max(a, 0.002) / max(b, 0.002))),
                        verdict=verdict, data_factor=nn / n if np.isfinite(nn) else float("inf"), df_kind=kind, flops_frac=fr))
    return out


def make_mlp_best(names):
    """results/mlp_best__<ds>.json: per (dataset, n), the MLP variant (mlp, mlp_plus, mlp_unit, mlp_l2) with the lowest seed-mean
    TEST error - chosen with hindsight, so it favours the MLP; used only as a stricter reference."""
    for ds in names:
        base = load("mlp", ds)
        if base is None:
            continue
        out = dict(base); out["learner"] = "mlp_best"; out["variant"] = []
        E, F = [], []
        for j, n in enumerate(base["ns"]):
            if j >= len(base["err"]):
                break
            best = ("mlp", base["err"][j], base["flops"][j])
            for v in ("mlp_plus", "mlp_unit", "mlp_l2"):
                r = load(v, ds)
                if r is not None and n in r["ns"][:len(r["err"])]:
                    k = r["ns"].index(n)
                    if np.nanmean(r["err"][k]) < np.nanmean(best[1]):
                        best = (v, r["err"][k], r["flops"][k])
            E.append(best[1]); F.append(best[2]); out["variant"].append(best[0])
        out["err"], out["flops"], out["ns"] = E, F, base["ns"][:len(E)]
        json.dump(out, open(os.path.join(RES, f"mlp_best__{ds}.json"), "w"))


def summarize(L, names, ref="mlp"):
    allc = [(ds, c) for ds in names for c in (cells(L, ds, ref) or [])]
    if not allc:
        return None
    lr = [c["log2_ratio"] for _, c in allc]
    v = [c["verdict"] for _, c in allc]
    df = [c["data_factor"] for _, c in allc if np.isfinite(c["data_factor"])]
    never = sum(1 for _, c in allc if not np.isfinite(c["data_factor"]))
    ff = [c["flops_frac"] for _, c in allc if np.isfinite(c["flops_frac"])]
    return dict(cells=len(allc), better=v.count("better"), worse=v.count("worse"), tie=v.count("tie"),
                mean_log2=float(np.mean(lr)), median_data_factor=float(np.median(df)) if df else float("nan"), never=never,
                datasets=len(set(ds for ds, _ in allc)), max_flops=max(ff) if ff else float("nan"),
                over_budget=sum(1 for f in ff if f > 1.0))


def table(L, ds):
    rl, rm = load(L, ds), load("mlp", ds)
    refs = {k: load(k, ds) for k in REFS}
    if rm is None:
        return f"*{ds}: MLP results missing*"
    nm, em, _ = curve(rm)
    head = f"| n | MLP | {L} |" + "".join(f" {k} |" for k in REFS) + " verdict | data factor | FLOPs / MLP run |"
    rows = [f"**{ds}**", "", head, "|" + "---|" * (head.count("|") - 1)]
    C = {c["n"]: c for c in (cells(L, ds) or [])}
    for j, n in enumerate(nm):
        def get(r):
            if r is None or n not in r["ns"]:
                return "–"
            return f"{np.nanmean(np.array(r['err'], float)[list(r['ns']).index(n)]):.4f}"
        c = C.get(int(n))
        dfs = "–" if c is None else ("never" if not np.isfinite(c["data_factor"]) else
                                    (f"≤{c['data_factor']:.2f}" if c["df_kind"] == "le" else f"{c['data_factor']:.2f}"))
        rows.append(f"| {int(n)} | {em[j]:.4f} | {get(rl)} |" + "".join(f" {get(refs[k])} |" for k in REFS) +
                    f" {c['verdict'] if c else '–'} | {dfs} | {'–' if c is None else format(c['flops_frac'], '.2f')} |")
    return "\n".join(rows)


def main(learners):
    L = ["# Standard tasks: DFG adaptations against the MLP", "",
         "Generated by `compare.py` from `results/*.json`. Error = test error (1 - accuracy), seed mean of 3 (images at n >=",
         "30000: seed 0 only). Verdict per (dataset, n): better / worse if the errors differ by > 10% relative and by > 2",
         "s.e. (the seed spread of both learners, at least the binomial test-set noise), else tie.",
         "Data factor: the training size at which the learner reaches the MLP's error at n, divided by n (< 1: less data",
         "than the MLP; 'never': not reached on the grid; '≤': already below at n = 100). References (not part of the",
         "comparison): `linear` = multinomial logistic regression on the MLP's encoding; `hgb` = sklearn histogram gradient",
         "boosting, default settings.", ""]
    IMG = ["mnist", "fashion_mnist"]
    for split, names in (("held-out tabular", [d for d in DATA.HELDOUT if d not in IMG]), ("held-out images", IMG),
                         ("dev", DATA.DEV)):
        L += [f"## Summary, {split} datasets", "",
              "| learner | datasets | cells | better | tie | worse | mean log2(err / MLP err) | median data factor | MLP error never reached | max FLOPs / MLP run (cells over 1) |",
              "|---|---|---|---|---|---|---|---|---|---|"]
        for l in learners + REFS:
            s = summarize(l, names)
            if s:
                fl = "–" if not np.isfinite(s["max_flops"]) else f"{s['max_flops']:.2f} ({s['over_budget']})"
                L.append(f"| {l} | {s['datasets']} | {s['cells']} | {s['better']} | {s['tie']} | {s['worse']} | {s['mean_log2']:+.2f} | "
                         f"{s['median_data_factor']:.2f} | {s['never']} | {fl} |")
        L.append("")
    make_mlp_best(DATA.HELDOUT + DATA.DEV)
    L += ["## Summary against the best MLP variant per cell (held-out datasets, tabular and images together)", "",
          "`mlp_best` = per (dataset, n) the lowest-test-error of `mlp`, `mlp_plus` (lr in {3e-3, 1e-3, 3e-4} x AdamW decay",
          "{0, 0.05}; tabular, n <= 3000), `mlp_l2` (coupled L2 penalty lam in {1e-4, 1e-3, 1e-2, 1e-1} chosen on validation,",
          "final checkpoint; tabular, n <= 3000; added after the MLP-fairness audit found the baseline under-regularized) and",
          "`mlp_unit` (inputs scaled to [-1, 1] instead of standardized; images, n <= 10000), chosen with hindsight on the test",
          "set, so it favours the MLP.", "",
          "| learner | datasets | cells | better | tie | worse | mean log2(err / best-MLP err) | median data factor | never reached |",
          "|---|---|---|---|---|---|---|---|---|"]
    for l in learners + REFS:
        s = summarize(l, DATA.HELDOUT, ref="mlp_best")
        if s:
            L.append(f"| {l} | {s['datasets']} | {s['cells']} | {s['better']} | {s['tie']} | {s['worse']} | {s['mean_log2']:+.2f} | "
                     f"{s['median_data_factor']:.2f} | {s['never']} |")
    L.append("")
    L += ["## Summary against the L2-regularized MLP (`mlp_l2`, chosen on validation; held-out tabular, n <= 3000)", "",
          "| learner | datasets | cells | better | tie | worse | mean log2(err / mlp_l2 err) | median data factor | never reached |",
          "|---|---|---|---|---|---|---|---|---|"]
    for l in learners + ["mlp"] + REFS:
        s = summarize(l, [d for d in DATA.HELDOUT if d not in IMG], ref="mlp_l2")
        if s:
            L.append(f"| {l} | {s['datasets']} | {s['cells']} | {s['better']} | {s['tie']} | {s['worse']} | {s['mean_log2']:+.2f} | "
                     f"{s['median_data_factor']:.2f} | {s['never']} |")
    L.append("")
    for l in learners:
        L += [f"## {l}: per dataset", ""]
        for ds in DATA.HELDOUT + DATA.DEV:
            if load(l, ds) is not None:
                L += [table(l, ds), ""]
    open(os.path.join(HERE, "RESULTS.md"), "w").write("\n".join(L) + "\n")
    print("\n".join(L[:40]))


if __name__ == "__main__":
    main(sys.argv[1:])
