"""E. A simple luck model: if a forecaster predicts "year made + Delta" with Delta drawn from a
base-rate distribution, how likely is a hit within +-2 years of 2027-2028 (2025-2030), for one
forecaster and for at least m of N?  Compared with the actual hits.

For von Foerster (whose date came from a curve fit, not a chosen horizon) the hit probability
is also taken from analysis A: the share of plausible 1960-era fits landing in the window.

usage: python -I e_luck_model.py --predictions ai_predictions.csv --famous famous_forecasts.csv \
           --fits outputs/a_hyperbolic_fits_all.csv
"""
import argparse, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import pandas as pd
from scipy.stats import norm, lognorm
from common import write_table, savefig, plt, COLORS, OUT

ap = argparse.ArgumentParser()
ap.add_argument("--predictions", required=True)
ap.add_argument("--famous", required=True)
ap.add_argument("--fits", required=True)
ap.add_argument("--bandwidth", type=float, default=3.0, help="kernel bandwidth (yr) for the empirical Delta")
args = ap.parse_args()

pred = pd.read_csv(args.predictions)
pred = pred[pred.pre2012 == 1].copy()
pred["delta"] = pred.predicted_year - pred.year_made
fam = pd.read_csv(args.famous)
fits = pd.read_csv(args.fits)

WINDOWS = {"2025-2030 (+-2 of 2027-28)": (2025, 2030), "2026-2029 (+-1)": (2026, 2029), "2022-2033 (+-5)": (2022, 2033)}

# ---------------------------------------------------------------- Delta models: P(lo <= Delta <= hi)
def kde_prob(deltas, lo, hi, bw):
    return float(np.mean(norm.cdf(hi + 0.5, deltas, bw) - norm.cdf(lo - 0.5, deltas, bw)))

def delta_models(person):
    others = pred[pred.person != person].delta.values
    return {
        "empirical, leave-person-out (KDE)": lambda lo, hi: kde_prob(others, lo, hi, args.bandwidth),
        "empirical, all 13 (KDE)": lambda lo, hi: kde_prob(pred.delta.values, lo, hi, args.bandwidth),
        "lognormal median 20 yr, sd(log) 0.5": lambda lo, hi: lognorm.cdf(hi + 0.5, 0.5, scale=20) - lognorm.cdf(max(lo - 0.5, 0), 0.5, scale=20),
        "lognormal median 30 yr, sd(log) 0.4": lambda lo, hi: lognorm.cdf(hi + 0.5, 0.4, scale=30) - lognorm.cdf(max(lo - 0.5, 0), 0.4, scale=30),
        "uniform 10-50 yr": lambda lo, hi: max(0.0, min(hi + 0.5, 50) - max(lo - 0.5, 10)) / 40,
    }
MODELS = list(delta_models("x").keys())

# von Foerster: share of '1960 analyst' fits (analysis A) in the window
ens = fits[(fits.kind == "pop") & fits.cutoff.isin([1940, 1958]) & fits.start.isin([1, 1000, 1500, 1700])]
def vf_prob(lo, hi):
    return float(np.mean((ens.t0 >= lo) & (ens.t0 <= hi + 0.999)))

# ---------------------------------------------------------------- test set: earliest prediction per person + von Foerster
people = pred.sort_values("year_made").groupby("person").head(1)[["id", "person", "year_made", "predicted_year"]]
people = pd.concat([fam[fam.id == "vonfoerster1960"][["id", "person", "year_made", "predicted_year"]], people])

rows = []
for _, r in people.iterrows():
    for wname, (wlo, whi) in WINDOWS.items():
        hit = wlo <= r.predicted_year <= whi + 0.999
        row = dict(id=r.id, year_made=r.year_made, predicted_year=r.predicted_year, window=wname, actual_hit=hit)
        lo, hi = wlo - r.year_made, whi - r.year_made
        for m, f in delta_models(r.person).items():
            row[m] = f(lo, hi)
        row["von Foerster fit ensemble (A)"] = vf_prob(wlo, whi) if r.id == "vonfoerster1960" else np.nan
        rows.append(row)
P = pd.DataFrame(rows)
main_w = "2025-2030 (+-2 of 2027-28)"
print("=== E1: per-forecaster probability of landing in the window by chance ===")
print(write_table(P[P.window == main_w].drop(columns="window").round(4), "e1_per_forecaster_hit_prob", "%.6g"))
P.to_csv(os.path.join(OUT, "e1_per_forecaster_hit_prob_all_windows.csv"), index=False, float_format="%.4g")

# ---------------------------------------------------------------- Poisson-binomial: P(at least m hits among N)
def pb_pmf(ps):
    pmf = np.array([1.0])
    for p in ps:
        pmf = np.convolve(pmf, [1 - p, p])
    return pmf

rows, pmfs = [], {}
for wname in WINDOWS:
    sub = P[P.window == wname]
    obs = int(sub.actual_hit.sum())
    for m in MODELS:
        ps = sub[m].values.copy()
        vf = sub.id.values == "vonfoerster1960"
        ps_fit = ps.copy(); ps_fit[vf] = sub.loc[vf, "von Foerster fit ensemble (A)"].values
        for label, pp in [(m, ps), (m + " | vF from fit ensemble", ps_fit)]:
            pmf = pb_pmf(pp)
            if wname == main_w:
                pmfs[label] = pmf
            rows.append(dict(window=wname, delta_model=label, N=len(pp), expected_hits=pp.sum(), observed_hits=obs,
                             **{f"P(>={k})": pmf[k:].sum() for k in range(1, 6)}, p_value_obs=pmf[obs:].sum()))
Q = pd.DataFrame(rows)
print(f"\n=== E2: at least m of N = {len(people)} well-known forecasters in the window by chance ===")
print(write_table(Q[Q.window == main_w].drop(columns="window"), "e2_m_of_n", "%.3g"))
Q.to_csv(os.path.join(OUT, "e2_m_of_n_all_windows.csv"), index=False, float_format="%.4g")

# the four 'steelmanned hits' jointly (selected on the outcome -> upper bound on how surprising)
four = P[(P.window == main_w) & P.id.isin(["vonfoerster1960", "moravec1998", "kurzweil1999", "legg2009"])]
rows = []
for m in MODELS:
    ps = four[m].values.copy()
    ps_fit = ps.copy(); ps_fit[four.id.values == "vonfoerster1960"] = four.loc[four.id == "vonfoerster1960", "von Foerster fit ensemble (A)"].values
    rows.append(dict(delta_model=m, P_each=", ".join(f"{x:.2f}" for x in ps_fit), P_all_four=np.prod(ps_fit),
                     P_three_AI_forecasters=np.prod(ps_fit[four.id.values != "vonfoerster1960"])))
F4 = pd.DataFrame(rows)
print("\n=== E3: the four steelmanned hits (vF probability from fit ensemble) ===")
print(write_table(F4, "e3_four_hits", "%.3g"))

# pool size needed: expected hits from a pool of predictions with the list's year-made mix
pool = []
for m in MODELS:
    mean_p = P[(P.window == main_w) & (P.id != "vonfoerster1960")][m].mean()
    pool.append(dict(delta_model=m, mean_P_hit=mean_p, expected_hits_pool_95=95 * mean_p, expected_hits_pool_65=65 * mean_p))
PL = pd.DataFrame(pool)
print("\n=== E4: expected chance hits in a pool the size of the MIRI dataset (95) or the AI Impacts edit (65) ===")
print(write_table(PL, "e4_pool_expected_hits", "%.3g"))

# ---------------------------------------------------------------- figures
fig, axes = plt.subplots(1, 2, figsize=(13, 4.8))
ax = axes[0]
sub = P[P.window == main_w].reset_index(drop=True)
y = np.arange(len(sub))
for j, m in enumerate(MODELS):
    ax.scatter(sub[m], y + (j - 2) * 0.12, s=18, color=COLORS[j], label=m)
vfrow = sub.id == "vonfoerster1960"
ax.scatter(sub.loc[vfrow, "von Foerster fit ensemble (A)"], y[vfrow], marker="*", s=120, color="k", label="vF: share of 1960-era fits (A)")
ax.set_yticks(y)
ax.set_yticklabels([f"{r.id} -> {r.predicted_year:g}{'  HIT' if r.actual_hit else ''}" for r in sub.itertuples()], fontsize=8)
ax.set_xlabel("probability of landing in 2025-2030 by chance")
ax.set_title("Per-forecaster chance of a 'hit' near 2027-28")
ax.legend(fontsize=6.5, loc="lower right")
ax = axes[1]
obs = int(sub.actual_hit.sum())
for j, m in enumerate(MODELS):
    pmf = pmfs[m + " | vF from fit ensemble"]
    ax.plot(np.arange(len(pmf)), pmf, "o-", ms=3.5, color=COLORS[j], label=m)
ax.axvline(obs, color="k", ls="--", lw=1)
ax.text(obs + 0.1, ax.get_ylim()[1] * 0.9, f"observed: {obs}", fontsize=8)
ax.set_xlim(-0.3, 7)
ax.set_xlabel(f"number of hits among N = {len(sub)} forecasters")
ax.set_ylabel("probability")
ax.set_title("Chance distribution of the number of hits (Poisson-binomial)")
ax.legend(fontsize=6.5)
savefig(fig, "e1_luck_model.png")
