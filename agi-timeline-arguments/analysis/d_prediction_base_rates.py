"""D. Base rates of historical AI predictions: distribution of (predicted year - year made),
share of pre-2012 predictions landing in 2025-2032, hardware-based vs other.

The MIRI / Armstrong-Sotala dataset could not be downloaded from this session (aiimpacts.org
and Google Docs are blocked by the network policy), so this runs on a small hand-built list
of well-known dated predictions (data/manual/ai_predictions.csv). It is NOT a random sample:
it over-represents famous forecasts, and fame is partly caused by apparent success.

usage: python -I d_prediction_base_rates.py --predictions ai_predictions.csv
"""
import argparse, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import pandas as pd
from common import write_table, savefig, plt, COLORS, OUT

ap = argparse.ArgumentParser()
ap.add_argument("--predictions", required=True)
args = ap.parse_args()

p = pd.read_csv(args.predictions)
p = p[p.pre2012 == 1].copy()
p["delta"] = p.predicted_year - p.year_made
p["hardware_based"] = p.method.str.startswith("hardware")
p["in_2025_2032"] = p.predicted_year.between(2025, 2032)
p["range_overlaps_2025_2032"] = (p.predicted_high >= 2025) & (p.predicted_low <= 2032)

print(write_table(p[["id", "year_made", "predicted_year", "delta", "method", "in_2025_2032", "transcription_confidence"]],
                  "d_predictions_list", "%.4g"))

def summ(g, label):
    return dict(group=label, n=len(g), delta_median=g.delta.median(), delta_mean=g.delta.mean(),
                delta_p25=g.delta.quantile(0.25), delta_p75=g.delta.quantile(0.75),
                delta_min=g.delta.min(), delta_max=g.delta.max(),
                share_point_in_2025_2032=g.in_2025_2032.mean(), share_range_overlaps=g.range_overlaps_2025_2032.mean())

one_per_person = p.sort_values("year_made").groupby("person").head(1)
S = pd.DataFrame([summ(p, "all pre-2012 predictions"),
                  summ(p[p.hardware_based], "hardware-extrapolation"),
                  summ(p[~p.hardware_based], "other (judgment / survey)"),
                  summ(p[p.year_made < 1990], "made before 1990"),
                  summ(p[p.year_made >= 1990], "made 1990-2011"),
                  summ(one_per_person, "earliest prediction per person"),
                  summ(p[p.transcription_confidence == "high"], "high-confidence transcriptions only")])
print("\n=== Distribution of (predicted year - year made) ===")
print(write_table(S, "d_delta_summary", "%.3g"))

# relation between year made and delta (do later forecasters look nearer?)
b, a = np.polyfit(p.year_made, p.delta, 1)
print(f"\nOLS delta = {a:.1f} + {b:.3f} * year_made  (n={len(p)}); predicted-year vs year-made slope = {1 + b:.2f}")
with open(os.path.join(OUT, "d_notes.txt"), "w") as fh:
    fh.write(f"OLS delta on year made: slope {b:.3f} yr/yr (n={len(p)}).\n"
             "Dataset: hand-built list of well-known dated predictions; see data/manual/ai_predictions.csv.\n")

fig, axes = plt.subplots(1, 2, figsize=(12, 4.6))
ax = axes[0]
for hw, col, lab in [(True, COLORS[1], "hardware extrapolation"), (False, COLORS[0], "other (judgment / survey)")]:
    q = p[p.hardware_based == hw]
    ax.errorbar(q.year_made, q.predicted_year, yerr=[q.predicted_year - q.predicted_low, q.predicted_high - q.predicted_year],
                fmt="o", color=col, ms=5, capsize=2, lw=0.8, label=lab)
    for j, (_, r) in enumerate(q.iterrows()):
        ax.annotate(r.id, (r.year_made, r.predicted_year), fontsize=6.5, xytext=(-48 if j % 2 else 4, 4 if j % 2 else -9),
                    textcoords="offset points")
x = np.linspace(1945, 2012, 10)
for dlt in [10, 20, 30, 50]:
    ax.plot(x, x + dlt, color="#bbbbbb", lw=0.7, ls="--")
    ax.text(1946, 1946 + dlt + 1, f"+{dlt} yr", fontsize=7, color="#888888")
ax.axhspan(2025, 2032, color="#ffcc66", alpha=0.35, lw=0, label="2025-2032")
ax.plot(x, x, color="k", lw=0.6)
ax.set_xlabel("year prediction was made"); ax.set_ylabel("predicted year")
ax.set_title(f"Hand-built list of well-known pre-2012 predictions (n={len(p)})")
ax.legend(loc="upper left")
ax = axes[1]
bins = np.arange(0, 60, 5)
ax.hist([p[p.hardware_based].delta, p[~p.hardware_based].delta], bins=bins, stacked=True,
        color=[COLORS[1], COLORS[0]], label=["hardware extrapolation", "other"], edgecolor="white")
ax.set_xlabel("predicted year - year made (years)"); ax.set_ylabel("number of predictions")
ax.set_title("Forecast horizon of the predictions")
ax.legend()
savefig(fig, "d1_prediction_horizons.png")
