"""Plot the frozen subjective prior, with conditional thermodynamic mass scales.

Run with empirical_methods/.venv/bin/python. No forecast parameters are changed.
An astronomical tick is W/(b k_B T ln 2), with W=eta M c^2, eta=b=1.
It is an erasure-equivalent reference, not a measured FLOP capacity.
"""
from pathlib import Path
import json
import os

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[1]
OUT = ROOT
os.environ["MPLCONFIGDIR"] = str(BASE / "mplconfig")
os.environ.setdefault("XDG_CACHE_HOME", str(BASE / ".cache"))
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

prior = json.loads((BASE / "prior.json").read_text())
draws = pd.read_csv(BASE / "draws.csv")
draws = draws[draws.Hmax == 60].sort_values("log10_x")
counts = draws.family.value_counts()
xx = draws.log10_x.to_numpy()
curves = {}
for key, spec in prior["weights"].items():
    weights = np.array([spec[f] / counts[f] for f in draws.family])
    assert np.isclose(weights.sum(), 1)
    curves[key] = np.cumsum(weights)

# Exact SI c and k_B; hbar from exact h. Cosmology: Planck 2018 base LCDM.
c, k_B, h = 299792458.0, 1.380649e-23, 6.62607015e-34
Mpc = 3.085677581491367e22
H0 = 67.4 * 1000 / Mpc
H_lambda = H0 * np.sqrt(1 - 0.315)
T_ds = (h / (2 * np.pi)) * H_lambda / (2 * np.pi * k_B)
temps = {"present_background": 2.725, "far_future_de_sitter": T_ds}
masses = {"Earth": 5.9722e24, "Sun": 1.9884e30,
          "Milky Way stars": 5.43e10 * 1.9884e30}
markers = []
for bath, temperature in temps.items():
    for name, mass in masses.items():
        erasures = mass * c**2 / (k_B * temperature * np.log(2))
        log_x = np.log10(erasures)
        index = np.searchsorted(xx, log_x, side="right") - 1
        probability = 0 if index < 0 else float(curves["central"][index])
        markers.append(dict(bath=bath, temperature_K=float(temperature),
                            reservoir=name, mass_kg=mass,
                            erasure_equivalent_operations=float(erasures),
                            log10_operations=float(log_x),
                            probability_stop_by_marker=probability))

median = float(xx[np.searchsorted(curves["central"], .5)])
quantiles = {str(p): float(xx[np.searchsorted(curves["central"], p)])
             for p in [.05, .1, .25, .5, .75, .9, .95]}
summary = dict(
    convention="Ideal eta=1 mass-to-work conversion; b=1 uncorrelated bit erased per toy operation; Landauer limit; no storage, collection, hardware or finite-rate costs.",
    forecast="Frozen prior.json central Hmax=60; family weight divided by family draw count; equal conditional rapid-completion subfamily weights.",
    number_of_draws=len(draws), temperature_de_sitter_K=float(T_ds),
    quantiles_log10_x=quantiles, markers=markers,
    sources={
        "Earth": "https://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html",
        "Sun": "https://nssdc.gsfc.nasa.gov/planetary/factsheet/sunfact.html",
        "Milky Way stars": "https://arxiv.org/abs/1608.00971",
        "Cosmological parameters": "https://arxiv.org/abs/1807.06209",
        "de Sitter temperature": "https://arxiv.org/html/astro-ph/0404510",
    })
(BASE / "cosmic_markers.json").write_text(json.dumps(summary, indent=2) + "\n")
pd.DataFrame(markers).to_csv(BASE / "cosmic_markers.csv", index=False)
pd.DataFrame({"log10_x": xx, **curves}).to_csv(BASE / "forecast_cdf_data.csv", index=False)

ink, muted = "#172835", "#576574"
teal, rust, purple = "#126879", "#B26934", "#8570A8"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10,
                     "text.color": ink, "axes.labelcolor": ink,
                     "xtick.color": muted, "ytick.color": muted,
                     "axes.spines.top": False, "axes.spines.right": False,
                     "axes.edgecolor": "#BAC5CA", "svg.fonttype": "none"})
fig = plt.figure(figsize=(10.6, 8.0), facecolor="white")
ax = fig.add_axes([.10, .46, .86, .32])
zoom = fig.add_axes([.10, .12, .86, .22])
fig.text(.10, .978, "When does research stop being worth the compute?",
         fontsize=16, weight="bold", va="top")
fig.text(.10, .94, "Subjective probability of switching by a given research expenditure",
         fontsize=10.5, color=muted, va="top")

styles = [("more_completion", "More weight on completion", rust, 1.4, (0, (4, 3))),
          ("more_persistence", "More weight on persistence", purple, 1.4, (0, (2, 2))),
          ("central", "Working distribution", teal, 2.4, "-")]
for a in [ax, zoom]:
    for key, label, color, width, dash in styles:
        a.step(np.r_[25., xx, 120.], np.r_[0., curves[key], 1.], where="post",
               color=color, lw=width, linestyle=dash, label=label, zorder=4 if key=="central" else 3)
    a.set_ylim(0, 1.025)
    a.set_yticks([0, .25, .5, .75, 1])
    a.yaxis.set_major_formatter(FuncFormatter(lambda x, p: f"{x:.0%}"))
    a.grid(axis="y", color="#DFE5E8", lw=.7)
    a.set_ylabel("Probability of having switched", fontsize=10)
    a.set_xlabel("Cumulative raw research operations (the model's FLOP unit)", fontsize=10)
    a.tick_params(labelsize=10)
ax.set_xlim(25, 120)
ticks = [30, 45, 60, 75, 90, 105, 120]
ax.set_xticks(ticks, [rf"$10^{{{t}}}$" for t in ticks])
handles, labels = ax.get_legend_handles_labels()
ax.legend([handles[2], handles[0], handles[1]], [labels[2], labels[0], labels[1]],
          loc="upper left", bbox_to_anchor=(.01, .97), frameon=False, fontsize=9.5)

# Separate, aligned thermodynamic reference rows avoid presenting mass as a
# unique secondary x-axis. Labels specify both the thermal bath and convention.
for bath, color, y, text_label in [
    ("present_background", rust, 1.34, "Mass as work at 2.7 K"),
    ("far_future_de_sitter", "#527694", 1.13, "Mass as work in the far future")]:
    ax.text(25, y, text_label, transform=ax.get_xaxis_transform(),
            color=color, fontsize=9, va="center")
    for m in [m for m in markers if m["bath"] == bath]:
        x = m["log10_operations"]
        label = m["reservoir"].replace("Milky Way stars", "Milky Way\n(stars)")
        ax.text(x, y + .005, label, ha="center", va="center",
                transform=ax.get_xaxis_transform(), fontsize=8.9, color=color, linespacing=1.04)
        ax.plot([x, x], [1.015, y - .065], transform=ax.get_xaxis_transform(),
                color=color, alpha=.40, lw=.8, clip_on=False)
        ax.axvline(x, color=color, alpha=.20, lw=.8, zorder=1)

zoom.set_xlim(110, 120)
zticks = [110, 112, 114, 116, 118, 120]
zoom.set_xticks(zticks, [rf"$10^{{{t}}}$" for t in zticks])
zoom.set_title("The last ten orders of magnitude, enlarged", loc="left", fontsize=11, pad=10)
zoom.plot([median, median], [0, .5], color=teal, alpha=.5, lw=1, ls=":")
zoom.scatter([median], [.5], color=teal, s=24, zorder=5)
zoom.annotate("Median ≈ 5 × $10^{117}$\nabout 0.5% of the budget",
              xy=(median, .5), xytext=(112.8, .72), fontsize=10, color=teal,
              arrowprops=dict(arrowstyle="-", color=teal, lw=.8), va="center")
zoom.text(119.88, .055, "$N = 10^{120}$", ha="right", va="bottom", fontsize=9, color=muted)
fig.text(.10, .05, "Mass markers assume all rest energy becomes usable work and one bit erasure per counted operation.",
         fontsize=9, color=muted)
fig.text(.10, .025, "Far future: an ideal de Sitter bath at about 2 × $10^{-30}$ K. Dashed curves are alternative judgments, not confidence bounds.",
         fontsize=9, color=muted)
OUT.mkdir(exist_ok=True, parents=True)
fig.savefig(OUT / "foom-coom-distribution.png", dpi=250)
fig.savefig(OUT / "foom-coom-distribution.svg")
print(json.dumps(summary, indent=2))
