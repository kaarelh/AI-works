import math
from statistics import NormalDist
from typing import Optional

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from pathlib import Path

SHARE_MODE = 0.67
SHARE_MIN = 0.59
SHARE_MAX = 0.75
SIMULATION_SAMPLES = 2000
SHARE = SHARE_MODE

NUMERATOR_MULTIPLIER_POINT = 3.0
NUMERATOR_MULTIPLIER_LOWER = 2.0
NUMERATOR_MULTIPLIER_UPPER = 5.0
NUMERATOR_CI_LEVEL = 0.90
START_YEAR = 2022

_NUMERATOR_ALPHA = (1.0 - NUMERATOR_CI_LEVEL) / 2.0
_NUMERATOR_Z = NormalDist().inv_cdf(1.0 - _NUMERATOR_ALPHA)
_NUMERATOR_LOG_LOWER = math.log(NUMERATOR_MULTIPLIER_LOWER)
_NUMERATOR_LOG_UPPER = math.log(NUMERATOR_MULTIPLIER_UPPER)
NUMERATOR_LOG_POINT = math.log(NUMERATOR_MULTIPLIER_POINT)
NUMERATOR_LOG_MEAN = (_NUMERATOR_LOG_LOWER + _NUMERATOR_LOG_UPPER) / 2.0
NUMERATOR_LOG_STD = (_NUMERATOR_LOG_UPPER - _NUMERATOR_LOG_LOWER) / (2.0 * _NUMERATOR_Z)
REPO_ROOT = Path.cwd()
DATA_DIR = REPO_ROOT / "data"
OPENAI_RD_SPEND_PATH = DATA_DIR / "openai_rd_spend_flops.csv"
FIGURES_DIR = REPO_ROOT / "figures"
RETURNS_FIGURE_PATH = FIGURES_DIR / "openai_returns_violin.png"


def decimal_year(dates: pd.Series) -> pd.Series:
    """Convert timestamps into fractional calendar years."""
    return dates.dt.year + (dates.dt.dayofyear - 1) / 365.25


def clean_numeric(series: pd.Series) -> pd.Series:
    """Coerce messy string numerics into floats."""
    cleaned = series.astype(str).str.replace(",", "", regex=False).str.strip()
    return pd.to_numeric(cleaned, errors="coerce")


def prepare_staff_data(staff_path: Path) -> pd.DataFrame:
    staff = (
        pd.read_csv(staff_path, parse_dates=["Date"], dayfirst=False)
        .loc[lambda df: df["Date"] >= pd.Timestamp(f"{START_YEAR}-01-01")]
        .dropna(subset=["Date", "Staff count", "Company"])
    )
    staff_counts = clean_numeric(staff["Staff count"])
    staff = staff.assign(staff_count=staff_counts)
    staff = staff.loc[lambda df: df["staff_count"] > 0]
    staff = staff.assign(
        log_staff=np.log(staff["staff_count"]),
        time=decimal_year(staff["Date"]),
    )
    staff = staff.loc[
        lambda df: df.groupby("Company")["time"].transform("nunique") > 1
    ]
    return (
        staff[["Company", "log_staff", "time"]]
        .sort_values(["Company", "time"])
        .reset_index(drop=True)
    )


def prepare_openai_compute_spend(
    spend_path: Path,
    start_year: int = 2018,
    end_year: int = 2025,
) -> pd.DataFrame:
    spend = (
        pd.read_csv(spend_path)
        .assign(year=lambda df: pd.to_numeric(df["year"], errors="coerce"))
        .dropna(subset=["year"])
        .loc[lambda df: (df["year"] >= start_year) & (df["year"] <= end_year)]
        .assign(
            Company="OpenAI",
            total_flops=lambda df: pd.to_numeric(
                df["estimated_total_flops"], errors="coerce"
            ),
        )
        .dropna(subset=["total_flops"])
        .loc[lambda df: df["total_flops"] > 0]
        .assign(
            log_compute=lambda df: np.log(df["total_flops"]),
            time=lambda df: df["year"].astype(float),
        )
        .sort_values("time")
        .reset_index(drop=True)
    )
    return spend[
        [
            "Company",
            "log_compute",
            "time",
            "year",
            "total_flops",
        ]
    ]


def estimate_growth_rate(
    df: pd.DataFrame, value_col: str, time_col: str
) -> tuple[float, float, float]:
    x = df[time_col].to_numpy(dtype=float)
    y = df[value_col].to_numpy(dtype=float)
    slope, intercept = np.polyfit(x, y, 1)
    fitted = intercept + slope * x
    resid = y - fitted
    y_mean = float(np.mean(y))
    y_dev = y - y_mean
    sst = float(np.dot(y_dev, y_dev))
    ssr = float(np.dot(resid, resid))
    ratio = np.divide(
        ssr,
        sst,
        out=np.array([float("nan")], dtype=float),
        where=sst != 0,
    )[0]
    r_squared = 1.0 - ratio
    denom = float(np.dot(x - float(np.mean(x)), x - float(np.mean(x))))
    dof = max(len(x) - 2, 1)
    residual_var = ssr / dof
    slope_se = math.sqrt(residual_var / denom)
    return float(slope), float(r_squared), slope_se


def simulate_denom_and_ratio(
    g_L: float,
    g_L_se: float,
    g_K: float,
    g_K_se: float,
    n_draws: int = SIMULATION_SAMPLES,
    random_state: Optional[int] = 0,
) -> tuple[tuple[float, float], tuple[float, float], np.ndarray]:
    rng = np.random.default_rng(random_state)
    scale_L = abs(float(np.nan_to_num(g_L_se, nan=0.0, posinf=0.0, neginf=0.0)))
    scale_K = abs(float(np.nan_to_num(g_K_se, nan=0.0, posinf=0.0, neginf=0.0)))
    g_L_draws = rng.normal(g_L, scale_L, size=n_draws)
    g_K_draws = rng.normal(g_K, scale_K, size=n_draws)
    share_draws = rng.triangular(SHARE_MIN, SHARE_MODE, SHARE_MAX, size=n_draws)
    denom_draws = share_draws * g_K_draws + (1 - share_draws) * g_L_draws
    numerator_draws = rng.normal(NUMERATOR_LOG_MEAN, NUMERATOR_LOG_STD, size=n_draws)
    ratio_draws = np.full(n_draws, np.nan, dtype=float)
    valid = np.isfinite(denom_draws) & (np.abs(denom_draws) > 1e-12)
    ratio_draws[valid] = numerator_draws[valid] / denom_draws[valid]
    denom_lower = float(np.nanpercentile(denom_draws, 2.5))
    denom_upper = float(np.nanpercentile(denom_draws, 97.5))
    ratio_lower = float(np.nanpercentile(ratio_draws, 2.5))
    ratio_upper = float(np.nanpercentile(ratio_draws, 97.5))
    return (denom_lower, denom_upper), (ratio_lower, ratio_upper), ratio_draws


def plot_ratio_violin(
    ratio_draws: np.ndarray,
    ratio_point: float,
    ratio_interval: tuple[float, float],
    output_path: Path,
) -> None:
    valid = ratio_draws[np.isfinite(ratio_draws) & (ratio_draws > 0)]
    log_draws = np.log10(valid)
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    tick_list = [0.003, 0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30, 100]
    fig, ax = plt.subplots(figsize=(8, 5))
    sns.violinplot(data=[log_draws], ax=ax, color="#74add1")
    ax.set_xticks([0])
    ax.set_xticklabels(["OpenAI 2022-2025"])
    ax.set_yticks(np.log10(np.array(tick_list)), tick_list)
    ax.set_ylim(np.log10(min(tick_list)), np.log10(max(tick_list)))
    ax.axhline(0, linestyle="dashed", color="gray")
    point_y = np.log10(ratio_point)
    ci_low, ci_high = ratio_interval
    ax.scatter(0, point_y, color="black", zorder=5)
    ax.vlines(0, np.log10(ci_low), np.log10(ci_high), color="black", linewidth=2)
    ax.set_ylabel("Returns to AI software R&D")
    ax.set_xlabel("")
    fig.tight_layout()
    fig.savefig(output_path, dpi=300)
    plt.close(fig)


def main() -> None:
    staff_path = DATA_DIR / "ai_companies" / "ai_companies_staff_reports.csv"
    compute_spend_path = OPENAI_RD_SPEND_PATH

    staff_df = prepare_staff_data(staff_path)
    staff_df = staff_df[staff_df["Company"] == "OpenAI"].reset_index(drop=True)
    compute_df = prepare_openai_compute_spend(
        compute_spend_path,
        start_year=START_YEAR,
        end_year=2025,
    )

    g_L, r2_L, se_L = estimate_growth_rate(staff_df, "log_staff", "time")
    g_K, r2_K, se_K = estimate_growth_rate(compute_df, "log_compute", "time")
    denom = SHARE * g_K + (1 - SHARE) * g_L
    (denom_low, denom_high), (ratio_low, ratio_high), ratio_draws = simulate_denom_and_ratio(
        g_L, se_L, g_K, se_K
    )
    numerator_point = NUMERATOR_LOG_POINT
    ratio_point = numerator_point / denom

    print(
        f"g_L (OpenAI staff, {START_YEAR}-2025): {g_L:.6f} "
        f"(R^2={r2_L:.4f}, SE={se_L:.6f})"
    )
    print(
        f"g_K (OpenAI total FLOPs, {START_YEAR}-2025): {g_K:.6f} "
        f"(R^2={r2_K:.4f}, SE={se_K:.6f})"
    )
    print(f"denom: {denom:.6f}")
    print(
        f"denom 95% CI (with triangular share {SHARE_MIN:.2f}-{SHARE_MAX:.2f}):"
        f" [{denom_low:.6f}, {denom_high:.6f}]"
    )
    print(
        "lambda/beta point estimate (log midpoint numerator): "
        f"{ratio_point:.6f}"
    )
    print(
        "lambda/beta 95% CI (numerator 90% between 2x-5x): "
        f"[{ratio_low:.6f}, {ratio_high:.6f}]"
    )
    plot_ratio_violin(ratio_draws, ratio_point, (ratio_low, ratio_high), RETURNS_FIGURE_PATH)


if __name__ == "__main__":
    main()
