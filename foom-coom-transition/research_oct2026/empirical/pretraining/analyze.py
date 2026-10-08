#!/usr/bin/env python3
"""Offline audit and refit of a frozen controlled-vintage pretraining release.

No training is performed. Dependencies: numpy, scipy, pandas, matplotlib.
Use `python analyze.py`; all paths resolve relative to this file.
"""
from pathlib import Path
import hashlib
import itertools
import json
import re
import os
os.environ.setdefault("MPLCONFIGDIR", str(Path(__file__).parent / ".mplconfig"))
os.environ.setdefault("XDG_CACHE_HOME", str(Path(__file__).parent / ".cache"))
import numpy as np
import pandas as pd
from scipy.optimize import least_squares, minimize_scalar
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "sources"
OUT = ROOT / "results"
OUT.mkdir(exist_ok=True)
MODELS = ("constant", "exponential", "shifted_power", "cost_floor")
CORPUS_YEAR = {"openwebtext": 2019, "c4_english": 2020, "pile_original": 2021,
               "olm_cc_2022": 2022, "falcon_refinedweb": 2023,
               "fineweb_edu": 2024, "ultra_fineweb_en": 2025}
METRICS = ("olmes10", "heldout7_mean_nll", "alt8")


def verify_sources():
    m = json.loads((SRC / "manifest.json").read_text())
    for f in m["files"]:
        assert hashlib.sha256((SRC / f["file"]).read_bytes()).hexdigest() == f["sha256"], f
    return {"revision": m["revision"], "files_verified": len(m["files"])}


def extract_multipliers():
    # Extract exact printed values, not digitized graphics or synthetic yearly points.
    text = (SRC / "README.md").read_text()
    table = text.split("## Compute multipliers at 1e19 FLOPs")[1].split("‡ crossing")[0]
    rows = []
    for line in table.splitlines():
        if not re.match(r"\| 20\d\d \|", line):
            continue
        cells = [s.strip() for s in line.split("|")[1:-1]]
        for axis, j in (("recipe", 0), ("data", 2)):
            match = re.fullmatch(r"(.+): ×([0-9.]+) \[([0-9.]+), ([0-9.]+)\](‡?)", cells[j+1])
            assert match, cells
            label, value, lo, hi, extrap = match.groups()
            rows.append(dict(axis=axis, year=int(cells[j]), label=label,
                             multiplier=float(value), low68=float(lo), high68=float(hi),
                             extrapolated=bool(extrap)))
    d = pd.DataFrame(rows)
    assert len(d) == 14 and d.groupby("axis").size().eq(7).all()
    d.to_csv(ROOT / "multipliers.csv", index=False)
    return d


def pred(kind, p, t):
    t = np.asarray(t, float)
    if kind == "constant":
        return np.zeros_like(t)
    if kind == "exponential":
        return p[0] * t
    if kind == "shifted_power":
        return p[0] * np.log1p(t / np.exp(p[1]))
    if kind == "cost_floor":
        s, f = p
        return -np.log(f + (1 - f) * np.exp(-s*t))
    raise ValueError(kind)


def fit(kind, t, y):
    t, y = np.asarray(t, float), np.asarray(y, float)
    if kind == "constant":
        p, bound = [], False
    elif kind == "exponential":
        p, bound = [max(0., float(t @ y / (t @ t)))], False
    else:
        if kind == "shifted_power":
            bounds = ([0, np.log(.05)], [1e5, np.log(1e5)])
            starts = [[max(.01, np.max(y))/np.log1p(max(t)/tau), np.log(tau)]
                      for tau in (.1, 1, 10, 100, 1e4)]
        else:
            bounds = ([0, 0], [10, .999999])
            starts = [[.2, f] for f in (0, .01, .1, .3, .6)]
        fits = [least_squares(lambda p: pred(kind, p, t)-y, s, bounds=bounds,
                             max_nfev=3000, ftol=1e-11, xtol=1e-11, gtol=1e-11)
                for s in starts]
        best = min(fits, key=lambda r: np.sum(r.fun**2))
        p = best.x.tolist()
        bound = bool(np.any(np.abs(best.active_mask)>0) or
                     (kind == "cost_floor" and p[1] < 1e-7) or
                     (kind == "shifted_power" and p[1] > np.log(9e4)))
    residual = pred(kind, p, t)-y
    n = int(np.sum(t > 0))  # reference year is fixed to one, not an independent residual
    k = len(p)
    K = k + 1  # fitted residual variance is also a likelihood parameter
    sse = float(residual @ residual)
    aicc = n*np.log(max(sse, 1e-30)/n)+2*K+2*K*(K+1)/(n-K-1) if n > K+1 else None
    return {"parameters": p, "sse_log": sse, "n_nonreference": n,
            "parameter_count": k, "likelihood_parameter_count": K,
            "aicc_descriptive": aicc, "boundary_or_limit": bound}


def multiplier_analysis(d):
    results, profiles = [], []
    for axis, orig in d.groupby("axis"):
        for selection in ("all", "exclude_extrapolated_crossings"):
            g = orig if selection == "all" else orig[~orig.extrapolated]
            t = g.year.to_numpy()-2019
            y = np.log(g.multiplier.to_numpy())
            train = g.year.to_numpy() <= 2023
            for kind in MODELS:
                full = fit(kind, t, y)
                early = fit(kind, t[train], y[train])
                hold = pred(kind, early["parameters"], t[~train])
                row = dict(axis=axis, selection=selection, model=kind, full=full,
                           training=early, holdout_years=g.year.to_numpy()[~train].tolist(),
                           holdout_prediction_multiplier=np.exp(hold).tolist(),
                           holdout_rmse_log=float(np.sqrt(np.mean((hold-y[~train])**2))))
                if kind == "exponential":
                    row["annual_factor"] = float(np.exp(full["parameters"][0]))
                if kind == "cost_floor":
                    f = full["parameters"][1]
                    row["fitted_ceiling_multiplier"] = float(1/f) if f > 1e-7 else None
                results.append(row)
            # Profile is descriptive. No iid likelihood or posterior is claimed.
            for f in np.r_[0., np.geomspace(1e-5, .8, 90)]:
                opt = minimize_scalar(lambda s: float(np.sum((pred("cost_floor", [s, f], t)-y)**2)),
                                      bounds=(0, 10), method="bounded")
                profiles.append(dict(axis=axis, selection=selection, floor_fraction=float(f),
                                     slope=opt.x, sse_log=opt.fun))
    pd.DataFrame(profiles).to_csv(OUT / "floor_profiles.csv", index=False)
    return results


def audit_checkpoints():
    d = pd.read_csv(SRC / "checkpoints.csv")
    assert d.run_id.nunique() == len(d) == 50
    assert set(d.budget_flops) == {1e19}
    rows=[]
    for _, r in d.iterrows():
        j=json.loads((SRC / "checkpoints" / r.run_id / "run.json").read_text())
        # Floating conversion is necessary: 6ND exceeds signed 64-bit integer capacity.
        flops = 6. * float(r.n_nonembed_params) * float(r.train_tokens)
        assert abs(flops / j["flops_6nd"]-1) < 1e-12
        assert abs(j["extra_eval"][next(iter(j["extra_eval"]))][-1][1]-r.native_heldout_nll) < 1e-6
        rows.append(dict(run_id=r.run_id, recipe=r.recipe, corpus=r.corpus, seed=int(r.seed),
                         nominal_flops=flops, nominal_budget_ratio=flops/1e19,
                         source_exact_flops=j["flops_exact"],
                         source_exact_over_nominal=j["flops_exact"]/flops,
                         wall_seconds=j["wall_sec"], reportable=j["reportable"],
                         stage=j["experiment_stage"]))
    audit=pd.DataFrame(rows)
    audit.to_csv(OUT / "unit_audit.csv", index=False)
    raw_means=d.groupby(["recipe", "corpus"])[list(METRICS)].mean()
    # Average repeats within seed before giving each of 3 seeds equal weight.
    seeds=d.groupby(["recipe", "corpus", "seed"])[list(METRICS)].mean().reset_index()
    counts=d.groupby(["recipe", "corpus"]).agg(rows=("seed","size"), distinct_seeds=("seed","nunique"))
    counts.to_csv(OUT / "cell_counts.csv")
    means=seeds.groupby(["recipe", "corpus"])[list(METRICS)].mean()
    means.to_csv(OUT / "seed_balanced_cell_means.csv")
    delta=(means-raw_means).abs().max().to_dict()
    return d, seeds, {"rows":len(d),"distinct_cells":len(counts),
                      "distinct_cell_seed_clusters":len(seeds),
                      "all_cells_have_three_distinct_seeds":bool(counts.distinct_seeds.eq(3).all()),
                      "maximum_seed_balance_adjustment_by_metric":delta,
                      "nominal_budget_ratio_range":[audit.nominal_budget_ratio.min(),audit.nominal_budget_ratio.max()],
                      "source_exact_over_nominal_range":[audit.source_exact_over_nominal.min(),audit.source_exact_over_nominal.max()],
                      "all_run_records_marked_nonreportable":bool((~audit.reportable).all())}


def seed_analysis(seeds):
    """Exact 3-cluster bootstrap sensitivity; no broad-population inference."""
    rows=[]
    cellrows=[]
    for axis in ("recipe", "data"):
        g = seeds[seeds.corpus.eq("fineweb_edu")] if axis=="recipe" else seeds[seeds.recipe.eq("v2025_olmo2_control")]
        g=g.copy()
        g["year"] = g.recipe.str[1:5].astype(int) if axis=="recipe" else g.corpus.map(CORPUS_YEAR)
        for metric in METRICS:
            pivot=g.pivot(index="year", columns="seed", values=metric).sort_index()
            assert pivot.shape == (7,3) and not pivot.isna().any().any()
            y=pivot.mean(axis=1).to_numpy(); t=pivot.index.to_numpy()-2019
            def stats(vals):
                slope,intercept=np.polyfit(t, vals, 1)
                return np.array([slope, vals[-1]-vals[0], vals[-1]-vals[4]])
            boot=np.array([stats(pivot.iloc[:,list(ix)].mean(axis=1).to_numpy())
                           for ix in itertools.product(range(3), repeat=3)])
            est=stats(y)
            early=np.polyfit(t[:5],y[:5],1)
            linear_hold=np.polyval(early,t[5:])
            flat_hold=np.repeat(y[4],2)
            rows.append(dict(axis=axis,metric=metric,slope_per_vintage_year=est[0],
                             endpoint_2025_minus_2019=est[1],endpoint_2025_minus_2023=est[2],
                             paired_seed_bootstrap_90=np.quantile(boot,[.05,.95],axis=0).tolist(),
                             bootstrap_resamples=27,distinct_seed_clusters=3,
                             holdout_linear_rmse=float(np.sqrt(np.mean((linear_hold-y[5:])**2))),
                             holdout_flat_2023_rmse=float(np.sqrt(np.mean((flat_hold-y[5:])**2)))))
            for year,score in zip(pivot.index,y):
                cellrows.append(dict(axis=axis,metric=metric,year=int(year),seed_balanced_mean=score))
    pd.DataFrame(cellrows).to_csv(OUT / "metric_by_vintage.csv",index=False)
    return rows


def plots(d, results):
    fig,axs=plt.subplots(1,2,figsize=(10,3.9),sharex=True)
    colors=dict(constant="grey", exponential="#2166ac", shifted_power="#b35806", cost_floor="#1b7837")
    for ax,axis in zip(axs,("recipe","data")):
        g=d[d.axis.eq(axis)]
        ax.errorbar(g.year, g.multiplier, yerr=[g.multiplier-g.low68,g.high68-g.multiplier],
                    fmt="o",color="black",capsize=3,label="Released multipliers ±68%")
        for _,r in g[g.extrapolated].iterrows():
            ax.plot(r.year,r.multiplier,"o",color="white",markeredgecolor="black",markersize=7,zorder=5)
        t=np.linspace(0,6.4,160)
        for r in results:
            if r["axis"]==axis and r["selection"]=="all" and r["model"]!="constant":
                ax.plot(t+2019,np.exp(pred(r["model"],r["training"]["parameters"],t)),
                        color=colors[r["model"]],label=r["model"].replace("_"," "))
        ax.axvspan(2023.5,2025.5,color="#dddddd",alpha=.45)
        ax.set(yscale="log",title=axis.capitalize()+" axis",xlabel="Recipe or corpus vintage",ylabel="Compute multiplier")
        ax.grid(alpha=.2);ax.legend(fontsize=7)
    fig.suptitle("Controlled pretraining: fits trained through 2023; 2024–25 held out")
    fig.tight_layout();fig.savefig(OUT/"chronological_holdout.png",dpi=180);plt.close(fig)
    metrics=pd.read_csv(OUT/"metric_by_vintage.csv")
    fig,axs=plt.subplots(1,3,figsize=(11,3.4))
    for ax,metric in zip(axs,METRICS):
        for axis,color in [("recipe","#2166ac"),("data","#b35806")]:
            g=metrics[(metrics.axis==axis)&(metrics.metric==metric)]
            ax.plot(g.year,g.seed_balanced_mean,"o-",label=axis,color=color)
        ax.set(title=metric,xlabel="Vintage year");ax.grid(alpha=.2);ax.legend()
    fig.suptitle("Fixed 10¹⁹ nominal FLOPs: endpoint choice changes the trend")
    fig.tight_layout();fig.savefig(OUT/"metric_sensitivity.png",dpi=180);plt.close(fig)


def main():
    verified=verify_sources()
    multipliers=extract_multipliers()
    curve_results=multiplier_analysis(multipliers)
    _, seeds, audit=audit_checkpoints()
    seed_results=seed_analysis(seeds)
    result={"source_verification":verified,"audit":audit,
            "multiplier_curve_fits":curve_results,"checkpoint_metric_fits":seed_results,
            "unidentified":["global research input", "causal raw-FLOP research productivity",
                            "universal multiplier", "asymptotic tail", "cosmic stopping distribution"]}
    (OUT/"results.json").write_text(json.dumps(result,indent=2,allow_nan=False)+"\n")
    flat=[]
    for r in curve_results:
        flat.append(dict(axis=r["axis"],selection=r["selection"],model=r["model"],
                         **r["full"],holdout_rmse_log=r["holdout_rmse_log"],
                         annual_factor=r.get("annual_factor"),
                         fitted_ceiling_multiplier=r.get("fitted_ceiling_multiplier")))
    pd.DataFrame(flat).to_csv(OUT/"curve_summary.csv",index=False)
    plots(multipliers,curve_results)
    print(json.dumps({"audit":audit,"primary_fits":[r for r in flat if r["selection"]=="all"]},indent=2))


if __name__ == "__main__":
    main()
