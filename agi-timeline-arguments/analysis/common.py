"""Shared helpers for the AGI-timeline sensitivity analyses (loaders, fits, plot style).

Scripts add this file's directory to sys.path explicitly, because they are run with
`python -I` (isolated mode), which does not put the script directory on the path.
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.optimize import minimize_scalar

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "outputs")
FIG = os.path.join(HERE, "figures")
os.makedirs(OUT, exist_ok=True)
os.makedirs(FIG, exist_ok=True)

# von Foerster, Mora & Amiot (1960), Science 132:1291-1295: N = 1.79e11 / (2026.87 - t)^0.99
VF_T0, VF_T0_SE, VF_K, VF_C = 2026.87, 5.50, 0.99, 1.79e11
TODAY = 2026 + (324 - 0.5) / 365.25  # 20 Nov 2026 as a decimal year (~2026.885)

plt.rcParams.update({
    "figure.facecolor": "white", "axes.facecolor": "white", "savefig.facecolor": "white",
    "axes.grid": True, "grid.color": "#dddddd", "grid.linewidth": 0.6,
    "axes.spines.top": False, "axes.spines.right": False,
    "font.size": 10, "axes.titlesize": 11, "legend.fontsize": 8, "legend.frameon": False,
})
COLORS = ["#1f77b4", "#d62728", "#2ca02c", "#9467bd", "#ff7f0e", "#8c564b", "#17becf", "#7f7f7f"]


def savefig(fig, name):
    path = os.path.join(FIG, name)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    return path


def write_table(df, name, float_fmt="%.4g"):
    """Write a dataframe as CSV and as an aligned text table; return the text."""
    df.to_csv(os.path.join(OUT, name + ".csv"), index=False, float_format=float_fmt)
    txt = df.to_string(index=False, float_format=lambda v: float_fmt % v)
    with open(os.path.join(OUT, name + ".txt"), "w") as f:
        f.write(txt + "\n")
    return txt


def decimal_year(dates):
    d = pd.to_datetime(dates)
    return d.dt.year + (d.dt.dayofyear - 0.5) / 365.25


# ---------------------------------------------------------------- hyperbolic fits
def fit_hyperbola(t, y, k=None, w=None, max_horizon=5000.0):
    """Least-squares fit of log y = log C - k log(t0 - t), profiling over t0.

    k=None fits k freely; otherwise k is held fixed. w = optional point weights.
    Returns dict(t0, k, C, rmse, n, at_bound, t0_lo, t0_hi). t0_lo/hi is a rough 95%
    profile interval assuming iid log-residuals (too narrow if residuals are autocorrelated).
    """
    t, ly = np.asarray(t, float), np.log(np.asarray(y, float))
    w = np.ones_like(t) if w is None else np.asarray(w, float)
    w = w / w.sum()
    tmax = t.max()

    def ssr_and_params(t0):
        x = -np.log(t0 - t)  # log y = a + kk * x
        if k is None:
            xm, ym = np.sum(w * x), np.sum(w * ly)
            kk = np.sum(w * (x - xm) * (ly - ym)) / np.sum(w * (x - xm) ** 2)
            a = ym - kk * xm
        else:
            kk = k
            a = np.sum(w * (ly - kk * x))
        r = ly - a - kk * x
        return np.sum(w * r ** 2), kk, a

    # global grid over log(t0 - tmax), then local refinement
    grid = np.geomspace(0.02, max_horizon, 1500)
    ssr = np.array([ssr_and_params(tmax + g)[0] for g in grid])
    i = int(np.argmin(ssr))
    lo, hi = np.log(grid[max(i - 1, 0)]), np.log(grid[min(i + 1, len(grid) - 1)])
    res = minimize_scalar(lambda u: ssr_and_params(tmax + np.exp(u))[0], bounds=(lo, hi), method="bounded")
    t0 = tmax + np.exp(res.x)
    s, kk, a = ssr_and_params(t0)
    n, p = len(t), (3 if k is None else 2)
    sigma2 = s * n / max(n - p, 1)  # s is a weighted mean square
    # profile interval: n*(SSR(t0)-SSRmin)/sigma2 <= 3.84
    thresh = s + 3.84 * sigma2 / n
    inside = grid[ssr <= thresh]
    t0_lo = tmax + inside.min() if len(inside) else np.nan
    t0_hi = tmax + inside.max() if len(inside) else np.nan
    return dict(t0=t0, k=kk, C=np.exp(a), rmse=np.sqrt(s), n=n,
                at_bound=bool(np.exp(res.x) > 0.95 * max_horizon), t0_lo=t0_lo, t0_hi=t0_hi)


def thin_annual(df, col="year", step=10, keep=()):
    """Keep all points before 1950; from 1950 on keep only years divisible by `step`
    (plus any years in `keep`), so dense annual data do not dominate the fit."""
    m = (df[col] < 1950) | (df[col] % step == 0) | df[col].isin(keep)
    return df[m]


# ---------------------------------------------------------------- loaders
def load_roodman(path):
    """Roodman (2020) 'Data presentation' sheet: population (millions) and GWP (billion 1990 $)."""
    d = pd.read_excel(path, sheet_name="Data presentation")
    d = d.iloc[:, :4]
    d.columns = ["year", "pop_m", "gwp_pc", "gwp_bn"]
    d = d[pd.to_numeric(d["year"], errors="coerce").notna()].astype(float)
    return d


def load_cohen(path):
    """Cohen (1995) App. 2 'Average' of historical estimates, as tabulated in Roodman's GWP.xlsx."""
    d = pd.read_excel(path, sheet_name="Cohen 1995")[["Year", "Average"]]
    d = d[pd.to_numeric(d["Year"], errors="coerce").notna()].astype(float)
    return d.rename(columns={"Year": "year", "Average": "pop_m"}).dropna()


def load_hyde_un(path):
    """OWID 'Global Population by Region - HYDE (2016) & UN (2017)': world = sum of regions."""
    d = pd.read_csv(path)
    col = "Global Population by Region (HYDE (2016) and UN (2017))"
    w = d.groupby("Year")[col].sum(min_count=6).dropna().reset_index()
    w.columns = ["year", "pop"]
    w["pop_m"] = w["pop"] / 1e6
    return w[["year", "pop_m"]].astype(float)


def load_maddison_world(path):
    d = pd.read_csv(path)
    w = d[(d["Entity"] == "World") & d["GDP"].notna()][["Year", "GDP", "Population"]]
    w.columns = ["year", "gdp", "pop"]
    return w.astype(float)


def load_epoch(path):
    d = pd.read_csv(path)
    d["date"] = pd.to_datetime(d["Publication date"], errors="coerce")
    d = d.dropna(subset=["date", "Training compute (FLOP)"]).copy()
    d["t"] = decimal_year(d["date"])
    d["flop"] = d["Training compute (FLOP)"].astype(float)
    return d


def epoch_frontier(d, top=5, window_years=1.0):
    """Models whose compute is in the top `top` of all models released in the trailing
    `window_years` (a simple frontier definition, independent of Epoch's own flag)."""
    d = d.sort_values("t")
    keep = []
    for _, r in d.iterrows():
        prior = d[(d["t"] <= r["t"]) & (d["t"] > r["t"] - window_years)]
        keep.append(r["flop"] >= np.sort(prior["flop"].values)[-min(top, len(prior))])
    return d[np.array(keep)]
