"""B. Brain-compute forecasts (Moravec / Kurzweil style) and a training-corrected version.

(1) Date at which $1000 of hardware delivers B FLOP/s, B = 1e13..1e17, under (i) the
    forecasters' own assumed doubling times, re-anchored at their own forecast, and (ii) the
    realized price-performance trend measured from Epoch's notable-models data
    (training FLOP per dollar of training cost), converted to FLOP/s per $1000 of hardware.
(2) Date at which frontier training compute reaches k x B x T_life (lifetime anchor,
    T_life = 1e9 s) for k = 1..1e4.
(3) Years per order of magnitude (OOM) of each input, and an OOM ledger showing which
    omissions cancel.

usage: python -I b_brain_compute.py --epoch notable_ai_models.csv --forecasts brain_compute_forecasts.csv
"""
import argparse, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import pandas as pd
from common import load_epoch, epoch_frontier, write_table, savefig, plt, COLORS, OUT, TODAY

ap = argparse.ArgumentParser()
ap.add_argument("--epoch", required=True)
ap.add_argument("--forecasts", required=True)
ap.add_argument("--util", type=float, default=0.35, help="hardware utilization in training (Epoch data median 0.35)")
ap.add_argument("--tau-years", type=float, default=1.5, help="purchase price / cloud rental rate, in years")
args = ap.parse_args()

YR = 365.25 * 86400
T_LIFE = 1e9                  # seconds of 'lifetime' experience (~32 years)
BRAIN = [1e13, 1e14, 1e15, 1e16, 1e17]
KS = [1, 10, 100, 1e3, 1e4]
L2 = np.log2(10)              # doublings per OOM

d = load_epoch(args.epoch)
fc = pd.read_csv(args.forecasts)

# ------------------------------------------------ realized price-performance (FLOP per $ of training cost)
c = d.dropna(subset=["Training compute cost (2023 USD)"]).copy()
c = c[c.t >= 2015]
c["R"] = c.flop / c["Training compute cost (2023 USD)"]          # FLOP per 2023-dollar
bR, aR = np.polyfit(c.t, np.log10(c.R), 1)
T_real = np.log10(2) / bR                                          # doubling time, years
t_ref = 2023.5
R_ref = 10 ** (aR + bR * t_ref)
# convert FLOP per rental-dollar to peak FLOP/s per $1000 of purchased hardware:
#   R = p * u * tau  (p = peak FLOP/s per purchase-$)  =>  p1000 = 1000 R / (u tau)
p1000_ref = 1000 * R_ref / (args.util * args.tau_years * YR)
print(f"Realized training FLOP per $: x{10**bR:.2f}/yr (doubling {T_real:.2f} yr), n={len(c)} models 2015-2023; "
      f"trend value at {t_ref}: {R_ref:.2e} FLOP/$ -> {p1000_ref:.2e} peak FLOP/s per $1000 "
      f"(u={args.util}, tau={args.tau_years} yr)")

# ------------------------------------------------ realized frontier training compute
fr = epoch_frontier(d, top=5, window_years=1.0)
fr10 = fr[fr.t >= 2010]
bC, aC = np.polyfit(fr10.t, np.log10(fr10.flop), 1)
g_C = 10 ** bC
t_last = d.t.max()
C_last = 10 ** (aC + bC * t_last)
print(f"Frontier training compute (top-5 per trailing year, 2010-{t_last:.1f}): x{g_C:.2f}/yr, n={len(fr10)}; "
      f"trend at {t_last:.2f}: {C_last:.2e} FLOP; largest in data: {d.flop.max():.2e}")
bK, aK = np.polyfit(c[c['Frontier model'] == True].t, np.log10(c[c['Frontier model'] == True]["Training compute cost (2023 USD)"]), 1)
print(f"Frontier training cost (Epoch-flagged frontier models with cost): x{10**bK:.2f}/yr; trend at 2023.5: ${10**(aK + bK*2023.5):.2e}")

# ------------------------------------------------ table B1: $1000 buys B FLOP/s
rows = []
for B in BRAIN:
    r = {"brain FLOP/s": B}
    for _, f in fc.iterrows():
        r[f"{f.forecaster} {f.year_made} (own trend)"] = f.forecast_year_1000usd + f.assumed_doubling_time_yr * np.log2(B / f.brain_estimate_ops_per_s)
    for T in [2.1, T_real, 2.5]:
        r[f"realized, doubling {T:.2f} yr"] = t_ref + T * np.log2(B / p1000_ref)
    # realized with 2 doublings' credit for 8-bit / 4-bit arithmetic vs 16-bit
    r["realized 2.24 yr, +4x low precision"] = t_ref + T_real * np.log2(B / (4 * p1000_ref))
    rows.append(r)
B1 = pd.DataFrame(rows)
print("\n=== B1: year in which $1000 of hardware buys B FLOP/s ===")
print(write_table(B1.round(1), "b1_dollar1000_dates", "%.6g"))

# ------------------------------------------------ table B2: training compute reaches k x B x 1e9 s
def cross_date(target, growth_after=None, t_switch=2026.0):
    """First observed model reaching target, else extrapolate the 2010-2024 frontier trend
    (optionally slowing to `growth_after` per year from t_switch)."""
    hit = d[d.flop >= target]
    if len(hit):
        return hit.t.min(), "observed"
    t = t_last + np.log10(target / C_last) / bC
    if growth_after is not None and t > t_switch:
        C_sw = C_last * g_C ** (t_switch - t_last)
        t = t_switch + np.log10(target / C_sw) / np.log10(growth_after)
    return t, "extrapolated"

rows = []
for B in BRAIN:
    for k in KS:
        tgt = k * B * T_LIFE
        t1, how = cross_date(tgt)
        t2, _ = cross_date(tgt, growth_after=2.5)
        t3, _ = cross_date(tgt, growth_after=1.5)
        rows.append({"brain FLOP/s": B, "k": k, "target FLOP": tgt, "status": how,
                     f"date @x{g_C:.1f}/yr": t1, "date, x2.5/yr after 2026": t2, "date, x1.5/yr after 2026": t3})
B2 = pd.DataFrame(rows)
print("\n=== B2: year in which frontier training compute reaches k x B x 1e9 s ===")
print(write_table(B2.round(1), "b2_training_anchor_dates", "%.6g"))
piv = B2.pivot(index="k", columns="brain FLOP/s", values=f"date @x{g_C:.1f}/yr").round(1)
with open(os.path.join(OUT, "b2_training_anchor_grid.txt"), "w") as fh:
    fh.write(f"Year frontier training compute reaches k x brain FLOP/s x 1e9 s (rows k, columns brain FLOP/s); "
             f"Epoch data to {t_last:.1f}, extrapolated at x{g_C:.2f}/yr\n{piv.to_string()}\n")
print(piv.to_string())

# ------------------------------------------------ table B3: years per OOM of each input
yrs_per_oom = [
    ("$1000 criterion, forecasters' assumed trend (doubling 1.0 yr)", "brain FLOP/s, $ budget, or price-perf level", 1.0 * L2),
    ("$1000 criterion, Moravec pre-1990 pace (doubling 1.5 yr)", "same", 1.5 * L2),
    (f"$1000 criterion, realized trend (doubling {T_real:.2f} yr, Epoch data)", "same", T_real * L2),
    ("$1000 criterion, Epoch GPU FLOP/s per $ (doubling 2.5 yr)", "same", 2.5 * L2),
    (f"training criterion, frontier compute x{g_C:.1f}/yr", "brain FLOP/s, k, lifetime seconds", 1 / np.log10(g_C)),
    ("training criterion, x2.5/yr (large-scale trend / slowdown)", "same", 1 / np.log10(2.5)),
    ("training criterion, x1.5/yr (spending plateau, hardware only)", "same", 1 / np.log10(1.5)),
]
B3 = pd.DataFrame(yrs_per_oom, columns=["criterion and trend", "input moved by 1 OOM", "years per OOM"])
print("\n=== B3: years the predicted date moves per order of magnitude of input uncertainty ===")
print(write_table(B3, "b3_years_per_oom", "%.3g"))

# ------------------------------------------------ table B4: OOM ledger (training criterion vs $1000 criterion)
# $1000 criterion: 1e3 * p >= B.  Training: Budget * R >= k B T_life, R = p u tau.
# log10(threshold_train / threshold_1000) = log k + log T_life + 3 - log Budget - log u - log tau
budget_2023 = 4.06e7  # GPT-4 training cost (2023 USD) in Epoch data
ledger = [
    ("lifetime anchor: brain FLOP/s x 1e9 s of 'experience'", +9.0),
    ("Kurzweil/Moravec spend $1e3 (move to numerator)", +3.0),
    ("frontier budget: GPT-4 training cost $4.1e7 (Epoch, 2023 USD)", -np.log10(budget_2023)),
    (f"hardware utilization u = {args.util}", -np.log10(args.util)),
    (f"rented, not owned: purchase price / rental rate = {args.tau_years} yr = {args.tau_years*YR:.1e} s", -np.log10(args.tau_years * YR)),
]
L = pd.DataFrame(ledger, columns=["factor", "log10 contribution"])
net = L["log10 contribution"].sum()
L = pd.concat([L, pd.DataFrame([("NET (k = 1): OOM by which training criterion is easier(-)/harder(+)", net),
                                ("years earlier at realized hardware trend (budget fixed at 2023 level)", net * T_real * L2)],
                               columns=L.columns)])
print("\n=== B4: OOM ledger, training criterion relative to the $1000 criterion ===")
print(write_table(L, "b4_oom_ledger", "%.3g"))
k_equiv = 10 ** (-net)
print(f"The two criteria coincide when k = {k_equiv:.2g} (k x lifetime anchor at 2023 budgets).")

# ------------------------------------------------ table B5: how much does fast growth compress date uncertainty?
# If the required training compute is log-uniform over a wide range, what share of the
# probability mass lands in 2025-2030, given the trend? (fraction of OOMs crossed in that window)
rows = []
for lo, hi in [(22, 32), (24, 30), (24, 35)]:
    targets = np.linspace(lo, hi, 2001)
    for label, ga in [(f"x{g_C:.1f}/yr throughout", None), ("x2.5/yr after 2026", 2.5), ("x1.5/yr after 2026", 1.5)]:
        dates = np.array([cross_date(10 ** x, growth_after=ga)[0] for x in targets])
        rows.append(dict(target_range=f"1e{lo}-1e{hi} FLOP (log-uniform)", growth=label,
                         share_before_2025=np.mean(dates < 2025), share_2025_2030=np.mean((dates >= 2025) & (dates <= 2030)),
                         share_after_2030=np.mean(dates > 2030)))
B5 = pd.DataFrame(rows)
print("\n=== B5: share of a log-uniform prior over required training FLOP that is crossed in 2025-2030 ===")
print(write_table(B5, "b5_compression_of_dates", "%.3g"))

# ------------------------------------------------ figure
fig, axes = plt.subplots(1, 2, figsize=(13, 5))
ax = axes[0]
p_models = 1000 * c.R / (args.util * args.tau_years * YR)
ax.scatter(c.t, p_models, s=8, color="#999999", alpha=0.6, label="models with cost data (Epoch), converted")
tt = np.linspace(1995, 2060, 300)
ax.plot(tt, p1000_ref * 2 ** ((tt - t_ref) / T_real), color="k", lw=1.5, label=f"realized trend, doubling {T_real:.2f} yr")
for i, (_, f) in enumerate(fc.iterrows()):
    ax.plot(tt, f.brain_estimate_ops_per_s * 2 ** ((tt - f.forecast_year_1000usd) / f.assumed_doubling_time_yr),
            color=COLORS[i + 1], lw=1.2, ls="--", label=f"{f.forecaster} {f.year_made} assumed (doubling {f.assumed_doubling_time_yr} yr)")
    ax.plot(f.forecast_year_1000usd, f.brain_estimate_ops_per_s, "o", color=COLORS[i + 1])
for B in BRAIN:
    ax.axhline(B, color="#cccccc", lw=0.6, ls=":")
ax.axhspan(1e13, 1e17, color="#e6f0ff", alpha=0.5, lw=0)
ax.set_yscale("log"); ax.set_ylim(1e8, 1e19); ax.set_xlim(1995, 2060)
ax.set_xlabel("year"); ax.set_ylabel("peak FLOP/s per $1000 of hardware")
ax.set_title("(1) When does $1000 buy a brain's FLOP/s? (band: 1e13-1e17)")
ax.legend(fontsize=7, loc="upper left")

ax = axes[1]
ax.scatter(d.t, d.flop, s=5, color="#bbbbbb", alpha=0.6, label="notable models (Epoch, to Sep 2024)")
ax.scatter(fr10.t, fr10.flop, s=10, color=COLORS[0], label="frontier (top-5 in trailing year)")
tt = np.linspace(2010, 2035, 200)
ax.plot(tt, C_last * g_C ** (tt - t_last), color="k", lw=1.3, label=f"trend x{g_C:.1f}/yr (2010-2024)")
tsw = tt[tt >= 2026]
C_sw = C_last * g_C ** (2026 - t_last)
ax.plot(tsw, C_sw * 2.5 ** (tsw - 2026), color="k", lw=1, ls="--", label="slowing to x2.5/yr after 2026")
for i, B in enumerate([1e13, 1e15, 1e17]):
    for k, ls in [(1, "-"), (1e3, ":")]:
        ax.axhline(k * B * T_LIFE, color=COLORS[i + 1], lw=0.9, ls=ls)
        ax.text(2010.3, k * B * T_LIFE * 1.4, f"{k:g} x {B:.0e} FLOP/s x 1e9 s", fontsize=6.5, color=COLORS[i + 1])
ax.axvline(TODAY, color="k", lw=0.6, ls="--")
ax.set_yscale("log"); ax.set_ylim(1e16, 1e30); ax.set_xlim(2010, 2035)
ax.set_xlabel("publication date"); ax.set_ylabel("training compute (FLOP)")
ax.set_title("(2) Training-corrected: frontier compute vs lifetime anchors")
ax.legend(fontsize=7, loc="lower right")
savefig(fig, "b1_brain_compute.png")
