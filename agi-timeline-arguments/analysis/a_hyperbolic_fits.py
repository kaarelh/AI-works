"""A. Hyperbolic ("doomsday") fits N(t) = C / (t0 - t)^k to world population and GWP.

How much does the singularity date t0 move with the data source, start date, cutoff,
weighting and whether k is free or fixed at 1?  Also: actual growth rates of several
series against the hyperbola-implied rate k/(t0 - t) for von Foerster's t0 = 2026.87.

usage: python -I a_hyperbolic_fits.py --roodman GWP.xlsx --hyde pop_hyde_un.csv \
           --maddison maddison2020.csv --epoch notable_ai_models.csv [--metr outputs/c_agent_horizons.csv]
"""
import argparse, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import pandas as pd
from common import (fit_hyperbola, thin_annual, load_roodman, load_cohen, load_hyde_un,
                    load_maddison_world, load_epoch, epoch_frontier, write_table, savefig,
                    plt, COLORS, VF_T0, VF_K, OUT)

ap = argparse.ArgumentParser()
ap.add_argument("--roodman", required=True)
ap.add_argument("--hyde", required=True)
ap.add_argument("--maddison", required=True)
ap.add_argument("--epoch", required=True)
ap.add_argument("--metr", default=os.path.join(OUT, "c_agent_horizons.csv"))
args = ap.parse_args()

rood = load_roodman(args.roodman)
series = {
    # name: (dataframe with year,value ; kind)
    "pop: Kremer/McEvedy-Jones composite (Roodman)": (rood[["year", "pop_m"]].dropna().rename(columns={"pop_m": "v"}), "pop"),
    "pop: Cohen 1995 average of estimates": (load_cohen(args.roodman).rename(columns={"pop_m": "v"}), "pop"),
    "pop: HYDE 2016 + UN 2017 (OWID)": (load_hyde_un(args.hyde).rename(columns={"pop_m": "v"}).query("year <= 2015"), "pop"),
    "GWP: Roodman 2020 (DeLong/Maddison/WDI)": (rood[["year", "gwp_bn"]].dropna().rename(columns={"gwp_bn": "v"}), "gdp"),
    "GWP: Maddison Project 2020 (OWID)": (load_maddison_world(args.maddison)[["year", "gdp"]].rename(columns={"gdp": "v"}), "gdp"),
}
starts = {"pop": [-10000, 1, 1000, 1500, 1700], "gdp": [-10000, 1, 1000, 1500, 1820]}
cutoffs = {"pop": [1900, 1920, 1940, 1958, 1970, 1980, 2000, 2015, 2019],
           "gdp": [1900, 1913, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2019]}

rows = []
for name, (df, kind) in series.items():
    for s in starts[kind]:
        for c in cutoffs[kind]:
            sub = df[(df.year >= s) & (df.year <= c)]
            if len(sub) < 5 or sub.year.min() > s + 300 or sub.year.max() < c - 30:
                continue  # start or cutoff not covered by this series
            for weighting in ["thinned", "all-points", "time-weighted"]:
                d = thin_annual(sub, keep=(sub.year.max(),)) if weighting != "all-points" else sub
                w = None
                if weighting == "time-weighted":  # weight = time interval each point represents
                    tt = d.year.values
                    gaps = np.diff(tt)
                    w = np.r_[gaps[0], (gaps[:-1] + gaps[1:]) / 2, gaps[-1]]
                for kfix in [None, 1.0]:
                    f = fit_hyperbola(d.year, d.v, k=kfix, w=w)
                    rows.append(dict(series=name, kind=kind, start=s, cutoff=c, last_obs=d.year.max(),
                                     weighting=weighting, k_mode="free" if kfix is None else "k=1",
                                     n=f["n"], t0=f["t0"], k=f["k"], rmse_log=f["rmse"],
                                     t0_lo95=f["t0_lo"], t0_hi95=f["t0_hi"], no_finite_t0=f["at_bound"]))
res = pd.DataFrame(rows)
# a cutoff beyond the end of a series repeats the previous fit: keep only the first such cutoff
res = res.sort_values("cutoff").drop_duplicates(["series", "start", "last_obs", "weighting", "k_mode"], keep="first")
res.to_csv(os.path.join(OUT, "a_hyperbolic_fits_all.csv"), index=False, float_format="%.5g")

# ---- headline tables (thinned weighting)
main = res[res.weighting == "thinned"].copy()
main["t0_str"] = np.where(main.no_finite_t0, ">5000 yr", main.t0.round(1).astype(str))
for kind in ["pop", "gdp"]:
    for km in ["free", "k=1"]:
        m = main[(main.kind == kind) & (main.k_mode == km)]
        piv = m.pivot_table(index=["series", "start"], columns="cutoff", values="t0_str", aggfunc="first")
        txt = piv.to_string()
        with open(os.path.join(OUT, f"a_t0_table_{kind}_{km.replace('=', '')}.txt"), "w") as fh:
            fh.write(f"t0 (singularity year) by start date (rows) and cutoff (columns); {kind}, k {km}; "
                     "thinned weighting (decadal after 1950)\n" + txt + "\n")
        print(f"\n=== t0, {kind}, k {km} ===\n{txt}")
    mk = main[(main.kind == kind) & (main.k_mode == "free")]
    print(f"\nfitted k range ({kind}, k free, finite t0): {mk[~mk.no_finite_t0].k.min():.2f} .. {mk[~mk.no_finite_t0].k.max():.2f}")

# ---- von Foerster reproduction attempt: start 1 AD, cutoff 1958
vf = res[(res.start == 1) & (res.cutoff == 1958)][["series", "weighting", "k_mode", "n", "t0", "k", "t0_lo95", "t0_hi95", "rmse_log"]].sort_values(["series", "weighting", "k_mode"])
print("\n=== Reproducing von Foerster (1 AD - 1958) ===")
print(write_table(vf, "a_von_foerster_reproduction", "%.4g"))

# ---- robustness summary: spread of t0 over all finite fits, per series and k mode
def summ(g):
    fin = g[~g.no_finite_t0]
    return pd.Series(dict(n_fits=len(g), n_infinite=int(g.no_finite_t0.sum()),
                          t0_min=fin.t0.min(), t0_median=fin.t0.median(), t0_max=fin.t0.max(),
                          share_2025_2030=np.mean((g.t0 >= 2025) & (g.t0 < 2031) & ~g.no_finite_t0)))
spread = res.groupby(["series", "k_mode"]).apply(summ, include_groups=False).reset_index()
print("\n=== Spread of t0 over all start/cutoff/weighting choices ===")
print(write_table(spread, "a_t0_spread_summary", "%.4g"))

# what a 1960 analyst could have obtained: data to 1940 or 1958, historical starts 1..1700
ens = res[(res.kind == "pop") & res.cutoff.isin([1940, 1958]) & res.start.isin([1, 1000, 1500, 1700])]
def ens_summary(g):
    fin = g[~g.no_finite_t0]
    return pd.Series(dict(n_fits=len(g), t0_p10=fin.t0.quantile(0.1), t0_median=fin.t0.median(),
                          t0_p90=fin.t0.quantile(0.9), share_2025_2030=np.mean((g.t0 >= 2025) & (g.t0 < 2031)),
                          share_within_10y_of_2027=np.mean(np.abs(g.t0 - 2027.5) <= 10)))
e1 = ens.groupby("k_mode").apply(ens_summary, include_groups=False).reset_index()
e1 = pd.concat([e1, ens_summary(ens).to_frame().T.assign(k_mode="both")])
print("\n=== '1960 analyst' ensemble (pop, cutoff 1940/1958, start 1/1000/1500/1700, 3 sources, 3 weightings) ===")
print(write_table(e1, "a_1960_analyst_ensemble", "%.4g"))

# receding singularity: t0 - cutoff for GWP (k free), by cutoff
rec = main[(main.kind == "gdp")].assign(lead=lambda d: d.t0 - d.cutoff)
rec_p = rec.pivot_table(index=["series", "start", "k_mode"], columns="cutoff", values="lead").round(1)
with open(os.path.join(OUT, "a_gwp_t0_minus_cutoff.txt"), "w") as fh:
    fh.write("GWP fits: t0 minus cutoff year (years 'until the singularity' as seen at the cutoff)\n" + rec_p.to_string() + "\n")
print("\n=== GWP: t0 - cutoff ===\n" + rec_p.to_string())
for (nm, s), g in rec[(rec.k_mode == "free") & (rec.cutoff >= 1960)].groupby(["series", "start"]):
    print(f"  drift d(t0)/d(cutoff), 1960-2019, {nm[:20]}, start {s}: {np.polyfit(g.cutoff, g.t0, 1)[0]:.2f} yr per yr")

# cutoff-only sensitivity for the 1-AD start (the von Foerster set-up)
cs = main[(main.start == 1) & (main.k_mode == "free")][["series", "cutoff", "t0", "k", "no_finite_t0"]]
write_table(cs, "a_t0_by_cutoff_start1_kfree", "%.5g")

# ---- Figure A1: t0 vs cutoff
fig, axes = plt.subplots(2, 2, figsize=(12, 8.5), sharex=True)
start_col = {-10000: "#7f7f7f", 1: "#1f77b4", 1000: "#2ca02c", 1500: "#ff7f0e", 1700: "#d62728", 1820: "#9467bd"}
series_style = ["-", "--", ":"]
series_mark = ["o", "s", "^"]
for r, kind in enumerate(["pop", "gdp"]):
    names = [n for n, (_, k) in series.items() if k == kind]
    for cidx, km in enumerate(["free", "k=1"]):
        ax = axes[r, cidx]
        m = main[(main.kind == kind) & (main.k_mode == km)]
        for i, name in enumerate(names):
            for s in starts[kind]:
                q = m[(m.series == name) & (m.start == s) & ~m.no_finite_t0].sort_values("cutoff")
                if len(q):
                    ax.plot(q.cutoff, q.t0, ls=series_style[i], marker=series_mark[i], ms=3.5, lw=1.1,
                            color=start_col[s])
        ax.axhline(VF_T0, color="k", lw=0.8)
        ax.axhspan(2025, 2030, color="#ffcc66", alpha=0.45, lw=0)
        ax.set_ylim(1900, 2200)
        ax.set_ylabel("fitted singularity year t0")
        ax.set_title(f"{'World population' if kind == 'pop' else 'Gross world product'}, " + ("k fitted" if km == "free" else "k fixed at 1"))
        if r == 1:
            ax.set_xlabel("last year of data used in the fit (cutoff)")
        # legends: colour = start year, line style = data source
        h1 = [plt.Line2D([], [], color=start_col[s], lw=2, label=f"start {s}") for s in starts[kind]]
        h2 = [plt.Line2D([], [], color="k", ls=series_style[i], marker=series_mark[i], ms=3.5,
                         label=n.split(": ")[1]) for i, n in enumerate(names)]
        h3 = [plt.Line2D([], [], color="k", lw=0.8, label="von Foerster t0 = 2026.87 (band: 2025-2030)")]
        ax.legend(handles=h1 + h2 + h3, fontsize=6.5, loc="upper right", ncol=2)
fig.suptitle("Hyperbolic fit N = C/(t0 - t)^k: fitted singularity year vs data cutoff "
             "(thinned weighting; fits with t0 off-scale omitted)", fontsize=11)
fig.tight_layout()
savefig(fig, "a1_t0_vs_cutoff.png")

# ---- growth rates of candidate series
def growth_points(df, min_gap=5):
    """Average exponential growth rate between consecutive points >= min_gap years apart."""
    df = df.sort_values("year")
    t, v, out = df.year.values, df.v.values, []
    i = 0
    while i < len(t) - 1:
        j = i + 1
        while j < len(t) - 1 and t[j] - t[i] < min_gap:
            j += 1
        out.append(((t[i] + t[j]) / 2, np.log(v[j] / v[i]) / (t[j] - t[i])))
        i = j
    return pd.DataFrame(out, columns=["t", "g"])

def rolling_growth(t, logv, centers, half=3.0, nmin=5):
    out = []
    for c in centers:
        m = np.abs(t - c) <= half
        if m.sum() >= nmin:
            out.append((c, np.polyfit(t[m], logv[m], 1)[0]))
    return pd.DataFrame(out, columns=["t", "g"])

gr = {
    "World population (HYDE/UN)": growth_points(series["pop: HYDE 2016 + UN 2017 (OWID)"][0]),
    "GWP (Roodman)": growth_points(series["GWP: Roodman 2020 (DeLong/Maddison/WDI)"][0]),
}
ep = epoch_frontier(load_epoch(args.epoch), top=5, window_years=1.0)
gr["Frontier AI training compute (Epoch, top-5/yr)"] = rolling_growth(ep.t.values, np.log(ep.flop.values), np.arange(1960, 2023.6, 0.5), half=5)
if os.path.exists(args.metr):
    mh = pd.read_csv(args.metr)
    mh = mh[(mh.suite == "TH1.1") & mh.frontier].sort_values("release")
    gr["METR 50% time horizon (frontier, TH1.1)"] = rolling_growth(mh.release.values, np.log(mh.h50_min.values), np.arange(2020, 2026.2, 0.25), half=1.5, nmin=4)
pd.concat([g.assign(series=k) for k, g in gr.items()]).to_csv(os.path.join(OUT, "a_growth_rates.csv"), index=False, float_format="%.5g")

fig, axes = plt.subplots(1, 2, figsize=(12, 4.6))
tt = np.linspace(1700, 2026.6, 600)
for ax, (x0, x1) in zip(axes, [(1700, 2027), (1940, 2027)]):
    for i, (k, g) in enumerate(gr.items()):
        g = g[(g.t >= x0) & (g.g > 0)]
        ax.plot(g.t, g.g, "o-", ms=2.5, lw=1, color=COLORS[i], label=k)
    ax.plot(tt, 1 / (VF_T0 - tt), "k--", lw=1.2, label="hyperbola-implied rate 1/(2026.87 - t)")
    ax.set_yscale("log")
    ax.set_xlim(x0, x1)
    ax.set_ylim(1e-4 if x0 < 1900 else 3e-3, 5)
    ax.set_xlabel("year")
    ax.set_ylabel("exponential growth rate (per year, natural log)")
    ax.set_title("Actual growth rates vs. the rate a singularity in Nov 2026 requires")
axes[0].legend(loc="upper left")
savefig(fig, "a2_growth_vs_hyperbola.png")

# implied singularity date t + 1/g (k = 1) -- constant for a true hyperbola
fig, ax = plt.subplots(figsize=(7.5, 4.6))
for i, (k, g) in enumerate(gr.items()):
    g = g[(g.t >= 1800) & (g.g > 0)]
    ax.plot(g.t, g.t + 1 / g.g, "o-", ms=2.5, lw=1, color=COLORS[i], label=k)
ax.axhline(VF_T0, color="k", ls="--", lw=1, label="von Foerster t0 = 2026.87")
ax.plot([1800, 2027], [1800, 2027], color="#999999", lw=0.8, label="t0 = t (implied date = now)")
ax.set_ylim(1800, 2300); ax.set_xlim(1800, 2027)
ax.set_xlabel("year of observation t")
ax.set_ylabel("implied singularity year t + 1/g(t)  (k = 1)")
ax.set_title("Where each series' current growth rate says the singularity is")
ax.legend(loc="upper left")
savefig(fig, "a3_implied_singularity_date.png")

# compact text of growth rates at selected years
sel = []
for k, g in gr.items():
    for y in [1800, 1900, 1950, 1960, 1970, 1990, 2010, 2015, 2020, 2023, 2025]:
        if len(g) and np.min(np.abs(g.t - y)) <= 3:
            r = g.iloc[np.argmin(np.abs(g.t - y))]
            sel.append(dict(series=k, year=r.t, growth_per_yr=r.g, implied_t0_k1=r.t + 1 / r.g if r.g > 0 else np.nan,
                            vF_required_rate=1 / (VF_T0 - r.t)))
print("\n=== growth rates vs hyperbola-required rate ===")
print(write_table(pd.DataFrame(sel).drop_duplicates(), "a_growth_rates_selected", "%.4g"))
