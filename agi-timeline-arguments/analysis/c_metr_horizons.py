"""C. METR time-horizon extrapolation: how much do "1 week / 1 month / 1 year" dates move
with the trend model and fitting window?

Step 1 recomputes each agent's 50% and 80% horizons from METR's raw runs (their method:
weighted logistic regression of success on log2(human minutes), invsqrt task weights,
regularization 1e-5).  Step 2 fits exponential and superexponential trends to the frontier
models and solves for the dates at which horizons reach 40 h, 167 h and 2000 h.

usage: python -I c_metr_horizons.py --runs-th10 th1_0/runs.jsonl --runs-th11 th1_1/runs.jsonl \
           --release-dates release_dates.yaml
"""
import argparse, os, sys, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import pandas as pd
from scipy.optimize import minimize, least_squares
from common import write_table, savefig, plt, COLORS, OUT, TODAY

ap = argparse.ArgumentParser()
ap.add_argument("--runs-th10", required=True)
ap.add_argument("--runs-th11", required=True)
ap.add_argument("--release-dates", required=True)
ap.add_argument("--n-boot", type=int, default=2000)
args = ap.parse_args()

# ---------------------------------------------------------------- release dates (flat YAML map)
rel = {}
for line in open(args.release_dates):
    m = re.match(r"^\s+(.+?):\s*(\d{4}-\d{2}-\d{2})\s*$", line)
    if m:
        d = pd.Timestamp(m.group(2))
        rel[m.group(1).strip().strip("'\"")] = d.year + (d.dayofyear - 0.5) / 365.25

# ---------------------------------------------------------------- per-agent logistic fits
def logistic_horizons(x, y, w, reg=1e-5):
    """sklearn-equivalent objective: 0.5*b^2 + (1/reg) * sum w*BCE, intercept unpenalised."""
    C = 1.0 / reg
    def f(p):
        a, b = p
        z = a + b * x
        # log(1+exp(z)) computed stably
        lse = np.logaddexp(0, z)
        loss = np.sum(w * (lse - y * z))
        s = 1 / (1 + np.exp(-z))
        g = np.array([np.sum(w * (s - y)), np.sum(w * (s - y) * x)])
        return 0.5 * b * b + C * loss, np.array([C * g[0], b + C * g[1]])
    r = minimize(f, x0=[1.0, -0.5], jac=True, method="L-BFGS-B")
    a, b = r.x
    h = lambda p: 2 ** ((np.log(p / (1 - p)) - a) / b)
    return h(0.5), h(0.8), a, b

rows = []
for suite, path in [("TH1.0", args.runs_th10), ("TH1.1", args.runs_th11)]:
    runs = pd.read_json(path, lines=True)
    for alias, g in runs.groupby("alias"):
        if alias == "human":
            continue
        name = alias.replace(" (Inspect)", "")
        date = rel.get(alias, rel.get(name))
        if date is None:
            continue
        h50, h80, a, b = logistic_horizons(np.log2(g.human_minutes.values), g.score_binarized.values.astype(float),
                                           g.invsqrt_task_weight.values)
        rows.append(dict(suite=suite, agent=name, release=date, h50_min=h50, h80_min=h80, slope=b, n_runs=len(g)))
H = pd.DataFrame(rows).sort_values(["suite", "release"])
# frontier = new record 50% horizon within the suite at release
H["frontier"] = False
for suite, g in H.groupby("suite"):
    best = 0
    for i, r in g.sort_values("release").iterrows():
        if r.h50_min > best:
            H.loc[i, "frontier"] = True
            best = r.h50_min
H.to_csv(os.path.join(OUT, "c_agent_horizons.csv"), index=False, float_format="%.5g")
show = H.assign(h50_hours=H.h50_min / 60, h80_hours=H.h80_min / 60)[["suite", "agent", "release", "h50_min", "h80_min", "h50_hours", "frontier"]]
print(write_table(show.round(3), "c_agent_horizons_table", "%.6g"))

# ---------------------------------------------------------------- trend models
THRESH = {"1 week (40 h)": 40 * 60, "1 month (167 h)": 167 * 60, "1 year (2000 h)": 2000 * 60}

def fit_exp(t, lh):
    b, a = np.polyfit(t, lh, 1)
    return dict(pred=lambda tt: a + b * tt, solve=lambda L: (L - a) / b, doubling_days=365.25 / b)

def fit_quad(t, lh):
    c = np.polyfit(t - 2024, lh, 2)
    def solve(L):
        r = np.roots([c[0], c[1], c[2] - L]).real
        r = r[r + 2024 > t.max() - 1]
        return (r.min() + 2024) if len(r) else np.nan
    slope_now = 2 * c[0] * (TODAY - 2024) + c[1]
    return dict(pred=lambda tt: np.polyval(c, tt - 2024), solve=solve,
                doubling_days=365.25 / slope_now if slope_now > 0 else np.nan)

def fit_superexp(t, lh, tref=2024.0):
    """Each successive doubling takes (1-r) times as long as the previous one.
    log2 h = L0 + ln(1 - r (t - tref)/T0) / ln(1 - r);  blows up at tref + T0/r."""
    def model(p, tt):
        L0, T0, r = p
        if abs(r) < 1e-6:
            return L0 + (tt - tref) / T0
        arg = np.maximum(1 - r * (tt - tref) / T0, 1e-12)
        return L0 + np.log(arg) / np.log(1 - r)
    sol = least_squares(lambda p: model(p, t) - lh, x0=[np.interp(tref, t, lh), 0.5, 0.1],
                        bounds=([-10, 0.05, -0.5], [20, 3, 0.6]))
    L0, T0, r = sol.x
    def solve(L):
        n = L - L0
        if abs(r) < 1e-6:
            return tref + n * T0
        return tref + T0 * (1 - (1 - r) ** n) / r
    # current doubling time: T0 * (1-r)^(n_now)
    n_now = model(sol.x, np.array([TODAY]))[0] - L0
    return dict(pred=lambda tt: model(sol.x, tt), solve=solve, doubling_days=365.25 * T0 * (1 - r) ** n_now,
                r=r, blowup=tref + T0 / r if r > 0 else np.inf)

fits, fit_rows = {}, []
specs = []
for suite in ["TH1.0", "TH1.1"]:
    for q in ["h50_min", "h80_min"]:
        for lo in [2019.0, 2022.0, 2023.0, 2024.0, 2025.0]:
            specs.append((suite, q, "exponential", lo))
        specs.append((suite, q, "quadratic in log h", 2019.0))
        specs.append((suite, q, "superexp (doublings shrink)", 2019.0))
        specs.append((suite, q, "superexp (doublings shrink)", 2023.0))
for suite, q, kind, lo in specs:
    g = H[(H.suite == suite) & H.frontier & (H.release >= lo)]
    if len(g) < 4:
        continue
    t, lh = g.release.values, np.log2(g[q].values)
    f = {"exponential": fit_exp, "quadratic in log h": fit_quad, "superexp (doublings shrink)": fit_superexp}[kind](t, lh)
    label = f"{suite} {q[:3]} {kind} from {int(lo)}"
    fits[label] = (suite, q, kind, lo, f, g)
    row = dict(suite=suite, horizon="50%" if q == "h50_min" else "80%", model=kind, window=f"{int(lo)}-{g.release.max():.1f}",
               n_models=len(g), doubling_days_now=f["doubling_days"],
               resid_sd_log2=np.std(lh - f["pred"](t), ddof=min(len(t) - 1, 2)))
    for k, L in THRESH.items():
        row[k] = f["solve"](np.log2(L))
    row["h_at_today_hours"] = 2 ** f["pred"](np.array([TODAY]))[0] / 60
    row["shrink_r"] = f.get("r", np.nan)
    row["blowup_year"] = f.get("blowup", np.nan)
    fit_rows.append(row)
F = pd.DataFrame(fit_rows)
print("\n=== Trend fits: date at which the horizon reaches each threshold ===")
print(write_table(F.round(2), "c_trend_fits", "%.6g"))

# ---------------------------------------------------------------- bootstrap of the headline exponential fit
rng = np.random.default_rng(1)
boot_rows = []
for suite in ["TH1.0", "TH1.1"]:
    for q in ["h50_min", "h80_min"]:
        for lo in [2019.0, 2024.0]:
            g = H[(H.suite == suite) & H.frontier & (H.release >= lo)]
            if len(g) < 4:
                continue
            t, lh = g.release.values, np.log2(g[q].values)
            dates = {k: [] for k in THRESH}
            for _ in range(args.n_boot):
                i = rng.integers(0, len(t), len(t))
                if np.ptp(t[i]) < 0.5:
                    continue
                b, a = np.polyfit(t[i], lh[i], 1)
                if b <= 0:
                    continue
                for k, L in THRESH.items():
                    dates[k].append((np.log2(L) - a) / b)
            row = dict(suite=suite, horizon=q[:3], window_from=int(lo), n_models=len(g))
            for k in THRESH:
                p = np.percentile(dates[k], [10, 50, 90])
                row[k + " p10"], row[k + " p50"], row[k + " p90"] = p
            boot_rows.append(row)
B = pd.DataFrame(boot_rows)
print("\n=== Bootstrap (resampling frontier models) of exponential fits: 10/50/90th percentile dates ===")
print(write_table(B.round(2), "c_bootstrap_exponential", "%.6g"))

# ---------------------------------------------------------------- hindcast: fit on models released before 2026, predict 2026 releases
hc_rows = []
for q in ["h50_min", "h80_min"]:
    allf = H[(H.suite == "TH1.1")]
    train = allf[allf.frontier & (allf.release < 2026.0)]
    test = allf[allf.release >= 2026.0]
    for kind, fn in [("exponential", fit_exp), ("quadratic in log h", fit_quad), ("superexp (doublings shrink)", fit_superexp)]:
        f = fn(train.release.values, np.log2(train[q].values))
        for _, r in test.iterrows():
            pred = 2 ** f["pred"](np.array([r.release]))[0]
            hc_rows.append(dict(horizon=q[:3], model=kind, n_train=len(train), test_agent=r.agent, release=r.release,
                                actual_min=r[q], predicted_min=pred, ratio_pred_over_actual=pred / r[q]))
HC = pd.DataFrame(hc_rows)
print("\n=== Hindcast (TH1.1): train on frontier models released before 2026, predict Feb-2026 releases ===")
print(write_table(HC.round(3), "c_hindcast_2026", "%.5g"))

# overall spread across all fits
spread = F.melt(id_vars=["suite", "horizon", "model", "window"], value_vars=list(THRESH), var_name="threshold", value_name="date")
S = spread.groupby(["horizon", "threshold"]).date.agg(["count", "min", "median", "max"]).reset_index()
print("\n=== Spread across all trend fits ===")
print(write_table(S, "c_spread_summary", "%.5g"))

# ---------------------------------------------------------------- figures
fig, axes = plt.subplots(1, 2, figsize=(13, 5), sharey=True)
tt = np.linspace(2019, 2033, 400)
for ax, q in zip(axes, ["h50_min", "h80_min"]):
    for j, suite in enumerate(["TH1.0", "TH1.1"]):
        g = H[H.suite == suite]
        ax.scatter(g.release, g[q] / 60, s=14, color=COLORS[j], alpha=0.35)
        gf = g[g.frontier]
        ax.scatter(gf.release, gf[q] / 60, s=26, color=COLORS[j], edgecolor="k", lw=0.5, label=f"METR {suite} (frontier = outlined)")
    shown = [f"TH1.1 {q[:3]} exponential from 2023", f"TH1.0 {q[:3]} exponential from 2019",
             f"TH1.0 {q[:3]} exponential from 2024", f"TH1.1 {q[:3]} superexp (doublings shrink) from 2023",
             f"TH1.0 {q[:3]} quadratic in log h from 2019"]
    for i, lab in enumerate(shown):
        if lab in fits:
            f = fits[lab][4]
            yy = 2 ** f["pred"](tt) / 60
            ax.plot(tt, np.where(yy < 1e5, yy, np.nan), lw=1.2, color=COLORS[2 + i], label=lab.replace(f" {q[:3]}", ""))
    for k, L in THRESH.items():
        ax.axhline(L / 60, color="#888888", lw=0.7, ls=":")
        ax.text(2019.1, L / 60 * 1.15, k, fontsize=7, color="#555555")
    ax.axvline(TODAY, color="k", lw=0.7, ls="--")
    ax.set_yscale("log"); ax.set_ylim(5e-4, 1e4); ax.set_xlim(2019, 2033)
    ax.set_xlabel("model release date")
    ax.set_title(f"{'50%' if q == 'h50_min' else '80%'}-success time horizon")
    ax.legend(fontsize=6.5, loc="lower right")
axes[0].set_ylabel("time horizon (hours of human expert time, log scale)")
fig.suptitle("METR time horizons (recomputed from raw runs) and trend extrapolations; dashed line = 20 Nov 2026", fontsize=10)
savefig(fig, "c1_metr_horizon_extrapolations.png")

fig, ax = plt.subplots(figsize=(9, 4.8))
ypos = 0
yt, yl = [], []
for hz, mk in [("50%", "o"), ("80%", "s")]:
    for k in THRESH:
        sub = F[F.horizon == hz]
        vals = sub[k].values
        for i, (m, v) in enumerate(zip(sub.model, vals)):
            c = COLORS[0] if m == "exponential" else (COLORS[1] if m.startswith("quad") else COLORS[2])
            ax.scatter(v, ypos + (i % 5 - 2) * 0.08, color=c, marker=mk, s=20, zorder=3)
        yt.append(ypos); yl.append(f"{hz} horizon reaches {k}")
        ypos += 1
ax.set_yticks(yt); ax.set_yticklabels(yl)
ax.axvspan(2025, 2031, color="#ffe9b3", alpha=0.6, lw=0, zorder=0)
ax.axvline(TODAY, color="k", lw=0.7, ls="--", label="20 Nov 2026")
ax.set_xlim(2026, 2037)
ax.set_xlabel("extrapolated date")
ax.legend(handles=[plt.Line2D([], [], color=COLORS[0], marker="o", ls="", label="exponential (various windows)"),
                   plt.Line2D([], [], color=COLORS[1], marker="o", ls="", label="quadratic in log h"),
                   plt.Line2D([], [], color=COLORS[2], marker="o", ls="", label="superexponential (shrinking doublings)")],
          loc="lower right")
ax.set_title("Spread of extrapolated dates across trend models and fitting windows (both METR suites; shaded 2025-2030)")
savefig(fig, "c2_metr_date_spread.png")
