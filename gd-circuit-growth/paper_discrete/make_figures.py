"""Figures for the Parts 6-9 paper (paper_discrete/).  Reads the study's result files directly and writes PDFs to
paper_discrete/figures/.  usage: python3 make_figures.py

Sources (all under gd-circuit-growth/study/):
  F1 fig_toy_portfolio.pdf   hybrid/results/toy__hyb_portfolio-perm__<suite>.json; network n* from the network result
                             directories or hybrid/results/nets_final_err.json, via compare_hybrid.toy_nstars
  F2 fig_dfg_nstar.pdf       discrete_learner/results/<run>.json (DFG error and the networks' error, per target)
  F3 fig_part7_ratio.pdf     standard_tasks/results/{mlp,dfg_bits-v1,dfg_gates-v1,dfg_dirs-v2}__<dataset>.json
  F4 fig_tabular.pdf         standard_tasks/results/{hyb_portfolio,hgb,mlp*}__<dataset>.json via compare_hybrid.cells/ref
  F5 fig_images.pdf          standard_tasks/results/{hyb_portfolio,mlp_strong,mlp_l2unit,mlp,hgb}__{mnist,fashion_mnist}.json
  F6 fig_ablations.pdf       hybrid/results/toy__{hyb_portfolio,abl_noDFG,abl_dfg}-perm__dlheld3.json and the real
                             ablation files standard_tasks/results/abl_*-quick__<dataset>.json, via ablations.py's functions
  F7 fig_p9_toy.pdf         hybrid/results/toy__{hyb_portfolio2,hyb_portfolio}-perm__{dlheld6,dlheld5,dlheld4}.json; nets_best
  F8 fig_p9_images.pdf      standard_tasks/results/{hyb_portfolio2,hyb_portfolio,mlp_strong,mlp_wide,mlp_xl,mlp_pool,cnn,hgb}__qd_{a,b}.json
n* is the study's definition (toy harness `nstar`: seed-mean test error 0.1, log-interpolated on the factor-2 grid).
"""
import os, sys, json, numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.join(os.path.dirname(HERE), "study")
FIG = os.path.join(HERE, "figures")
sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import compare_hybrid as CH                                   # noqa: E402  (toy harness CH.TH, Part 7 compare CH.SC)
import ablations as AB                                        # noqa: E402  (functions only; main() is not called)

TH, SC, DATA = CH.TH, CH.SC, CH.DATA
DL_RES = os.path.join(STUDY, "discrete_learner", "results")

# ---- style ------------------------------------------------------------------------------------------------------------
COL = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
INK, INK2, GRID = "#1a1a1a", "#4a4a4a", "#e3e3e3"
plt.rcParams.update({
    "font.family": "DejaVu Sans", "font.size": 8, "axes.titlesize": 8.5, "axes.labelsize": 8, "xtick.labelsize": 7.5,
    "ytick.labelsize": 7.5, "legend.fontsize": 7, "axes.edgecolor": "#9a9a9a", "axes.linewidth": 0.6,
    "axes.labelcolor": INK, "xtick.color": INK2, "ytick.color": INK2, "text.color": INK, "axes.titlecolor": INK,
    "figure.facecolor": "white", "axes.facecolor": "white", "savefig.facecolor": "white", "lines.linewidth": 1.5,
    "lines.markersize": 5, "pdf.fonttype": 42, "legend.frameon": False, "axes.grid": True, "grid.color": GRID,
    "grid.linewidth": 0.4, "axes.axisbelow": True, "xtick.major.width": 0.5, "ytick.major.width": 0.5,
    "xtick.minor.width": 0.3, "ytick.minor.width": 0.3})
TEXTW = 6.5                                                   # LaTeX \textwidth in inches (1in margins, letter)


def save(fig, name):
    p = os.path.join(FIG, name)
    fig.savefig(p, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)
    print("wrote", p)


def mean_err(v):
    return np.nanmean(np.array(v, float), 1)


def repel(ys, gap):
    """Spread label positions (in axis units, e.g. log10 error) so neighbours are at least `gap` apart; keeps order."""
    order = np.argsort(ys); out = np.array(ys, float)
    for _ in range(50):
        moved = False
        for a, b in zip(order[:-1], order[1:]):
            if out[b] - out[a] < gap:
                mid = (out[a] + out[b]) / 2; out[a], out[b] = mid - gap / 2, mid + gap / 2; moved = True
        if not moved:
            break
    return out


# ---- F1: toy, hyb_portfolio (permuted) against the per-target best network ---------------------------------------------
SUITES = [("designed", "designed (dev, 21)", "o"), ("random", "random (DFG dev data, 20)", "s"),
          ("dlheld", "dlheld (post hoc for DFG, 12)", "^"), ("dlheld2", "dlheld2 (used once, 7)", "D"),
          ("dlheld3", "dlheld3 (fresh, 10)", "v")]


def toy_points(learner, suite, ref="nets_best"):
    NR = CH.toy_nstars(suite)
    r = CH.toy_load(learner, suite)
    out = []
    for fn, v in r["fns"].items():
        out.append((fn, NR[ref][fn], TH.nstar(r["ns"], mean_err(v["err"]))))
    return out


def fig1():
    fig, ax = plt.subplots(figsize=(4.6, 4.2))
    lo, hi = 10, 2e4
    g = np.array([lo, hi])
    ax.plot(g, g, color=INK2, lw=0.9, ls="--", zorder=1)
    for fac, lab in ((4, "4x less data"), (16, "16x less")):
        ax.plot(g, g / fac, color="#a8a8a8", lw=0.7, ls=":", zorder=1)
        ax.text(1.35e4, 1.35e4 / fac * 0.80, lab, fontsize=6.5, color=INK2, ha="right", va="top")
    ax.text(1.35e4, 1.35e4 * 0.80, "equal data", fontsize=6.5, color=INK2, ha="right", va="top")
    for i, (suite, lab, mk) in enumerate(SUITES):
        P = toy_points("hyb_portfolio-perm", suite)
        x = [p[1] for p in P]; y = [p[2] for p in P]
        fresh = suite == "dlheld3"
        ax.scatter(x, y, s=34 if fresh else 22, marker=mk, facecolor=COL[i], edgecolor=INK if fresh else "white",
                   linewidth=0.7 if fresh else 0.5, label=lab, zorder=4 if fresh else 3, alpha=1.0 if fresh else 0.9)
        for fn, xx, yy in P:
            if fn == "sym9":
                ax.annotate(f"sym9  ({yy:.0f} vs {xx:.0f})", (xx, yy), xytext=(-8, 14), textcoords="offset points",
                            fontsize=7, color=INK, ha="right",
                            arrowprops=dict(arrowstyle="-", color=INK2, lw=0.6, shrinkA=0, shrinkB=3))
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(lo, hi); ax.set_ylim(lo, hi)
    ax.set_aspect("equal")
    ax.set_xlabel(r"$n^*$ of the per-target best network variant (nets_best)")
    ax.set_ylabel(r"$n^*$ of hyb_portfolio, inputs permuted")
    ax.legend(loc="upper left", handletextpad=0.3, borderaxespad=0.6, labelspacing=0.35)
    fig.tight_layout()
    save(fig, "fig_toy_portfolio.pdf")


# ---- F2: Part 6, DFG against the networks -------------------------------------------------------------------------------
TOP = 3e4


def dl_points(run):
    r = json.load(open(os.path.join(DL_RES, run + ".json")))
    out = []
    for fn, v in r["fns"].items():
        ln = TH.nstar(r["ns"], mean_err(v["err"]))
        nn = TH.nstar(TH.NS, mean_err(v["nn_err"]))
        if np.isfinite(nn):
            out.append((fn, nn, ln))
    return out


def fig2():
    A = [("dfg-c1.0__designed", "designed (21): v1, in-sample", "o"),
         ("dfg-c1.0__random", "random (20): v1, development check", "s"),
         ("dfg-c1.0-Khi4__dlheld", "held-out 1 (12): v1 without degree 5-6, blind", "^"),
         ("dfg-v1.1-perm__dlheld2", "held-out 2 (7): v1.1, inputs permuted, blind", "D")]
    B = [("dfg-c1.0__designed_d15", "d = 15 (7 targets): v1", "o"),
         ("dfg-v1.1__designed_d60", "d = 60 (7 targets): v1.1", "s"),
         ("dfg-v1.1__designed_d120", "d = 120 (4 targets): v1.1", "^")]
    fig, axs = plt.subplots(1, 2, figsize=(TEXTW, 4.3))
    for ax, series, title in ((axs[0], A, "(a) d = 30, every suite"), (axs[1], B, "(b) d = 15, 60, 120 (designed targets)")):
        lo, hi = 10, 5e4
        g = np.array([lo, hi])
        ax.plot(g, g, color=INK2, lw=0.9, ls="--", zorder=1)
        for fac in (4, 16, 64):
            ax.plot(g, g / fac, color="#a8a8a8", lw=0.7, ls=":", zorder=1)
            ax.text(3.6e4, 3.6e4 / fac * 0.78, f"{fac}x", fontsize=6.5, color=INK2, ha="right", va="top")
        for i, (run, lab, mk) in enumerate(series):
            P = dl_points(run)
            x = [p[1] for p in P]; y = [p[2] if np.isfinite(p[2]) else TOP for p in P]
            ax.scatter(x, y, s=24, marker=mk, facecolor=COL[i], edgecolor="white", linewidth=0.5, label=lab, zorder=3)
            for fn, xx, yy in P:
                if not np.isfinite(yy):
                    ax.annotate(f"{fn}: never", (xx, TOP), xytext=(-5, 0), textcoords="offset points",
                                fontsize=6.5, ha="right", va="center", color=INK)
        if series is B:
            ax.annotate("par3, d = 60", (3410, 28), xytext=(-6, 0), textcoords="offset points", fontsize=6.5,
                        color=INK, va="center", ha="right")
            ax.annotate("par4, d = 60\npar3, d = 120", (14100, 56), xytext=(0, -7), textcoords="offset points",
                        fontsize=6.5, color=INK, va="top", ha="center", linespacing=1.1)
        ax.axhline(TOP, color="#c8c8c8", lw=0.6, zorder=1)
        ax.text(12, TOP * 1.1, "never learned", fontsize=6.3, color=INK2, va="bottom", ha="left")
        ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(lo, hi); ax.set_ylim(lo, hi)
        ax.set_aspect("equal")
        ax.set_xlabel(r"networks' $n^*$")
        ax.set_ylabel(r"DFG's $n^*$")
        ax.set_title(title, loc="left")
        ax.legend(loc="upper left", bbox_to_anchor=(-0.02, -0.15), handletextpad=0.3, labelspacing=0.3)
    fig.tight_layout(w_pad=1.5)
    save(fig, "fig_dfg_nstar.pdf")


# ---- F3: Part 7, DFG adaptations / baseline MLP per held-out dataset ----------------------------------------------------
P7 = [("dfg_bits-v1", "dfg_bits", "o"), ("dfg_gates-v1", "dfg_gates", "s"), ("dfg_dirs-v2", "dfg_dirs", "D")]


def err_at(r, n):
    ns = r["ns"][:len(r["err"])]
    if n not in ns:
        return np.nan
    return float(np.nanmean(np.array(r["err"][ns.index(n)], float)))


def fig3():
    names = list(DATA.HELDOUT)
    rows = []
    for ds in names:
        rm = SC.load("mlp", ds)
        full = rm["ns"][len(rm["err"]) - 1]
        ratio = lambda L, n: max(err_at(SC.load(L, ds), n), 0.002) / max(err_at(rm, n), 0.002)
        e3 = {L: ratio(L, 3000) if 3000 in rm["ns"] else np.nan for L, _, _ in P7}
        ef = {L: ratio(L, full) for L, _, _ in P7}
        rows.append((ds, full, e3, ef))
    rows.sort(key=lambda t: np.nanmean(list(t[3].values())))
    fig, axs = plt.subplots(1, 2, figsize=(TEXTW, 3.5), sharey=True)
    y = np.arange(len(rows))
    for ax, k, title in ((axs[0], 2, "(a) n = 3000"), (axs[1], 3, "(b) full training pool")):
        ax.axvline(1.0, color=INK2, lw=0.9, zorder=1)
        for j, (L, lab, mk) in enumerate(P7):
            v = [r[k][L] for r in rows]
            ax.scatter(v, y + (j - 1) * 0.2, marker=mk, s=20, facecolor=COL[j], edgecolor="white", linewidth=0.4,
                       label=lab, zorder=3)
        ax.set_xscale("log")
        ax.set_xlim(0.4, 5.0)
        ax.set_xticks([0.5, 1, 2, 4]); ax.set_xticklabels(["0.5", "1", "2", "4"])
        ax.minorticks_off()
        ax.set_title(title, loc="left")
        ax.set_xlabel("test error / baseline MLP's test error")
        ax.grid(axis="y", visible=False)
        if k == 2:
            for i, r in enumerate(rows):
                if not np.any(np.isfinite(list(r[2].values()))):
                    ax.text(1.0, i, "  (pool < 3000)", fontsize=6.5, color=INK2, va="center", ha="left")
    axs[0].set_yticks(y); axs[0].set_yticklabels([r[0].replace("_", "-") for r in rows])
    axs[1].tick_params(axis="y", length=0)
    tr = axs[1].get_yaxis_transform()
    for i, r in enumerate(rows):
        axs[1].text(1.03, i, f"{r[1]}", fontsize=6.5, color=INK2, va="center", ha="left", transform=tr)
    axs[1].text(1.03, len(rows) - 0.45, "full n", fontsize=6.5, color=INK2, va="bottom", ha="left", transform=tr)
    axs[0].set_ylim(-0.7, len(rows) - 0.3)
    axs[0].legend(loc="lower left", handletextpad=0.2, borderaxespad=0.4, labelspacing=0.3)
    fig.tight_layout(w_pad=1.0)
    save(fig, "fig_part7_ratio.pdf")


# ---- F4: Part 8 tabular, per-dataset mean log2(err / mlp_best err) -----------------------------------------------------
def ds_mean(L, ds, kind="mlp_best"):
    c = CH.cells(CH.load(L, ds), CH.ref(kind, ds), ds)
    return (float(np.mean([x["lr"] for x in c])), sum(x["v"] == "better" for x in c), sum(x["v"] == "worse" for x in c)) if c else None


def fig4():
    splits = [("(a) HELDOUT2: 10 fresh PMLB datasets", list(DATA.HELDOUT2)),
              ("(b) Part 7 tabular set (references known)", [d for d in DATA.HELDOUT if d not in CH.IMG])]
    fig, axs = plt.subplots(1, 2, figsize=(TEXTW, 3.3))
    for ax, (title, names) in zip(axs, splits):
        R = [(ds, ds_mean("hyb_portfolio", ds), ds_mean("hgb", ds)) for ds in names]
        R.sort(key=lambda t: t[1][0], reverse=True)
        y = np.arange(len(R))
        ax.axvline(0, color=INK2, lw=0.9, zorder=1)
        ax.scatter([r[2][0] for r in R], y, marker="D", s=18, facecolor=COL[3], edgecolor="white", linewidth=0.4,
                   label="hgb (default histogram gradient boosting; calibration)", zorder=3)
        ax.scatter([r[1][0] for r in R], y, marker="o", s=26, facecolor=COL[0], edgecolor="white", linewidth=0.4,
                   label="hyb_portfolio", zorder=4)
        ax.set_yticks(y); ax.set_yticklabels([r[0].replace("_", "-") for r in R])
        ax.grid(axis="y", visible=False)
        ax.set_xlim(-1.35, 1.95)
        ax.set_xlabel(r"mean over $n$ of $\log_2$(error / mlp_best error)")
        ax.set_title(title, loc="left")
        ax.text(-1.3, -0.95, "lower error", fontsize=6.5, color=INK2, ha="left", va="bottom")
        ax.text(1.9, -0.95, "higher error", fontsize=6.5, color=INK2, ha="right", va="bottom")
        ax.set_ylim(-1.0, len(R) - 0.4)
    h, l = axs[0].get_legend_handles_labels()
    fig.legend(h[::-1], l[::-1], loc="lower center", ncol=2, bbox_to_anchor=(0.5, -0.01), handletextpad=0.2,
               columnspacing=1.5)
    fig.tight_layout(rect=(0, 0.06, 1, 1), w_pad=1.2)
    save(fig, "fig_tabular.pdf")


# ---- F5: images, test error against n -------------------------------------------------------------------------------------
IMGS = [("mnist", "MNIST"), ("fashion_mnist", "Fashion-MNIST")]
STY = {"hyb_portfolio": (COL[0], "o", "-"), "mlp_strong": (COL[1], "s", "--"), "mlp_l2unit": (COL[2], "^", "-."),
       "hgb": (COL[3], "D", ":"), "mlp": (COL[4], "v", (0, (5, 1.5, 1, 1.5)))}
LAB = {"hyb_portfolio": "hyb_portfolio", "mlp_strong": "mlp_strong (3-net ensemble)", "mlp_l2unit": "mlp_l2unit (mlp_reg)",
       "hgb": "hgb", "mlp": "mlp (baseline)"}
SHORT = {"hyb_portfolio": "portfolio", "mlp_strong": "mlp_strong", "mlp_l2unit": "mlp_l2unit", "hgb": "hgb", "mlp": "mlp"}


def curve_mean(L, ds):
    r = CH.load(L, ds)
    ns = r["ns"][:len(r["err"])]
    return np.array(ns, float), np.array([np.nanmean(np.array(e, float)) for e in r["err"]])


def place_labels(ax, ends, gap=0.05, dx=1.18):
    """Direct labels at the right end of each line: ends = [(text, x, y_data)]; spread in axes-fraction units."""
    from matplotlib.transforms import blended_transform_factory
    tr = blended_transform_factory(ax.transData, ax.transAxes)
    to_frac = lambda yv: ax.transAxes.inverted().transform(ax.transData.transform((1.0, yv)))[1]
    fr = repel([to_frac(yv) for _, _, yv in ends], gap)
    for (t, x, yv), f in zip(ends, fr):
        ax.text(x * dx, f, t, fontsize=6.5, color=INK, va="center", ha="left", transform=tr)


def fig5():
    fig, axs = plt.subplots(2, 2, figsize=(TEXTW, 5.4), sharex=True)
    top = ["hyb_portfolio", "mlp_strong", "mlp_l2unit", "hgb"]
    bot = ["hyb_portfolio", "mlp_l2unit", "mlp", "hgb"]
    for c, (ds, name) in enumerate(IMGS):
        ax = axs[0, c]
        ends, allv = [], []
        for L in top:
            n, e = curve_mean(L, ds); col, mk, ls = STY[L]
            ax.plot(n, e, color=col, marker=mk, ls=ls, ms=4.5, mec="white", mew=0.4, label=LAB[L], zorder=3)
            ends.append((SHORT[L], n[-1], e[-1])); allv += list(e)
        ax.set_xscale("log"); ax.set_yscale("log")
        ax.set_xlim(70, 4.3e5); ax.set_ylim(min(allv) * 0.85, max(allv) * 1.15)
        ax.axvspan(2.0e4, 9e4, color="#f3f3f3", zorder=0, lw=0)
        place_labels(ax, ends)
        ax.set_title(f"({'ab'[c]}) {name}: test error", loc="left")
        if c == 0:
            ax.set_ylabel("test error (seed mean)")
        ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, _: f"{100 * v:g}%"))
        ax.yaxis.set_minor_formatter(matplotlib.ticker.FuncFormatter(
            lambda v, _: f"{100 * v:g}%" if round(v * 100, 6) in (2, 3, 5, 15, 20, 30) else ""))
        # bottom: log2 ratio to the strong MLP
        ax = axs[1, c]
        ns_ref, e_ref = curve_mean("mlp_strong", ds)
        ax.plot([60, 6.6e4], [0, 0], color=COL[1], lw=1.5, ls="--", zorder=2)
        ax.axvspan(2.0e4, 9e4, color="#f3f3f3", zorder=0, lw=0)
        ax.set_xscale("log"); ax.set_ylim(-0.45, 1.12); ax.set_xlim(70, 4.3e5)
        ends = [("mlp_strong", ns_ref[-1], 0.0)]
        for L in bot:
            n, e = curve_mean(L, ds)
            m = [list(ns_ref).index(x) for x in n if x in ns_ref]
            nn = np.array([x for x in n if x in ns_ref]); ee = np.array([e[list(n).index(x)] for x in nn])
            lr = np.log2(np.maximum(ee, 0.002) / np.maximum(e_ref[m], 0.002))
            col, mk, ls = STY[L]
            ax.plot(nn, lr, color=col, marker=mk, ls=ls, ms=4.5, mec="white", mew=0.4, label=LAB[L], zorder=3)
            ends.append((SHORT[L], nn[-1], lr[-1]))
        place_labels(ax, ends)
        ax.set_title(f"({'cd'[c]}) {name}: " + r"$\log_2$(error / mlp_strong error)", loc="left")
        ax.set_xlabel("training-set size n")
        if c == 0:
            ax.set_ylabel(r"$\log_2$ error ratio")
        ax.text(2.2e4, -0.42, "seed 0\nonly", fontsize=6.3, color=INK2, va="bottom", ha="left", linespacing=1.0)
    h = [Line2D([], [], color=STY[L][0], marker=STY[L][1], ls=STY[L][2], ms=4.5, mec="white", mew=0.4, label=LAB[L])
         for L in ["hyb_portfolio", "mlp_strong", "mlp_l2unit", "mlp", "hgb"]]
    fig.legend(handles=h, loc="lower center", ncol=5, bbox_to_anchor=(0.5, 0.0), handlelength=2.6, columnspacing=1.2)
    fig.tight_layout(rect=(0, 0.045, 1, 1), h_pad=1.0, w_pad=1.2)
    save(fig, "fig_images.pdf")


# ---- F6: post-hoc ablations of hyb_portfolio --------------------------------------------------------------------------
def fig6():
    fig, axs = plt.subplots(1, 2, figsize=(TEXTW, 3.2), gridspec_kw=dict(width_ratios=[1.35, 1]))
    # (a) toy dlheld3: n* per target
    N, NR = AB.toy_rows("dlheld3")
    S = [("hyb_portfolio-perm", "full design", "o", COL[0]), ("abl_dfg-perm", "DFG members alone", "s", COL[1]),
         ("abl_noDFG-perm", "without DFG", "^", COL[2]), ("nets_best", "nets_best", "D", COL[3])]
    T = sorted(NR["nets_best"], key=lambda t: N["hyb_portfolio-perm"][t])
    y = np.arange(len(T)); NEV = 2.6e4
    ax = axs[0]
    for j, (k, lab, mk, col) in enumerate(S):
        src = NR["nets_best"] if k == "nets_best" else N[k]
        v = [src[t] if np.isfinite(src[t]) else NEV for t in T]
        ax.scatter(v, y + (j - 1.5) * 0.17, marker=mk, s=20, facecolor=col, edgecolor="white", linewidth=0.4, label=lab,
                   zorder=3)
        for i, t in enumerate(T):
            if not np.isfinite(src[t]):
                ax.text(NEV * 0.86, i + (j - 1.5) * 0.17, "never", fontsize=6.3, color=INK2, va="center", ha="right")
    ax.axvline(NEV, color="#c8c8c8", lw=0.6)
    ax.set_xscale("log"); ax.set_xlim(12, 3.2e4)
    ax.set_yticks(y); ax.set_yticklabels(T); ax.grid(axis="y", visible=False)
    ax.set_xlabel(r"$n^*$ (inputs permuted)")
    ax.set_title(r"(a) toy suite dlheld3: $n^*$ by member set", loc="left")
    ax.set_ylim(-0.7, len(T) - 0.3)
    ax.legend(loc="lower right", handletextpad=0.2, borderaxespad=0.3, labelspacing=0.3, bbox_to_anchor=(1.0, 0.02))
    # (b) real: mean log2(err / best MLP err) per variant, n <= 3000, seeds 0-1
    names = list(DATA.HELDOUT2) + ["mnist", "fashion_mnist"]
    V = [("hyb_portfolio", "full design"), ("abl_noKNN", "without kNN"), ("abl_gbt", "LightGBM only"),
         ("abl_et", "ExtraTrees only"), ("abl_lin", "logistic only"), ("abl_knn", "kNN only")]
    agg = {k: [] for k, _ in V}
    for ds in names:
        full = CH.load("hyb_portfolio", ds)
        ns = [n for n in full["ns"] if n <= 3000]
        mb = []
        for n in ns:
            vals = [x for x in (AB.real_err(v, ds, [n])[0] if CH.load(v, ds) else np.nan for v in CH.MLP_VARIANTS)
                    if np.isfinite(x)]
            mb.append(min(vals) if vals else np.nan)
        for k, _ in V:
            e = AB.real_err(k if k == "hyb_portfolio" else k + "-quick", ds, ns)
            for i in range(len(ns)):
                if e is not None and np.isfinite(e[i]) and np.isfinite(mb[i]):
                    agg[k].append(np.log2(max(e[i], 0.002) / max(mb[i], 0.002)))
    ax = axs[1]
    m = [np.mean(agg[k]) for k, _ in V]
    yy = np.arange(len(V))[::-1]
    ax.axvline(0, color=INK2, lw=0.9, zorder=1)
    ax.hlines(yy, 0, m, color="#b5b5b5", lw=1.5, zorder=2)
    ax.scatter(m, yy, marker="o", s=26, facecolor=[COL[0]] + [COL[6]] * (len(V) - 1), edgecolor="white", linewidth=0.4,
               zorder=3)
    for v, q, (k, _) in zip(m, yy, V):
        ax.text(v + (0.05 if v >= 0 else -0.05), q, f"{v:+.2f}".replace("-", "\u2212"), fontsize=6.5, color=INK, va="center",
                ha="left" if v >= 0 else "right")
    ax.set_yticks(yy); ax.set_yticklabels([lab for _, lab in V]); ax.grid(axis="y", visible=False)
    ax.set_xlim(-0.45, 0.75)
    ax.set_xlabel(r"mean $\log_2$(error / best MLP error)")
    ax.set_title(f"(b) HELDOUT2 + images, n \u2264 3000 ({len(agg['hyb_portfolio'])} cells)", loc="left")
    ax.set_ylim(-0.6, len(V) - 0.35)
    fig.tight_layout(w_pad=1.5)
    save(fig, "fig_ablations.pdf")
    return {k: (len(agg[k]), float(np.mean(agg[k]))) for k, _ in V}


# ---- F7: Part 9 toy held-out suites, n* of hyb_portfolio2 and hyb_portfolio against nets_best --------------------------
P9_SUITES = [("dlheld6", "(a) dlheld6: blind (Q1)"), ("dlheld5", "(b) dlheld5: inside S's class"),
             ("dlheld4", "(c) dlheld4: definitions seen")]
P9_CONTROLS = {"dnf3x3", "h4rf0", "h4rf1", "h5rf0", "h5rf1", "h6_03", "h6_04", "h6_05"}


def fig7():
    fig, axs = plt.subplots(1, 3, figsize=(TEXTW, 2.9), sharey=True)
    lo, hi, NEV = 20, 3.2e4, 2.2e4                               # "never" plotted at NEV
    g = np.array([lo, hi])
    for ax, (suite, title) in zip(axs, P9_SUITES):
        NR = CH.toy_nstars(suite)
        ax.plot(g, g, color=INK2, lw=0.8, ls="--", zorder=1)
        ax.plot(g, g / 4, color="#a8a8a8", lw=0.6, ls=":", zorder=1)
        for L, lab, fc, mk in (("hyb_portfolio-perm", "v1 (Part 8)", "white", "o"), ("hyb_portfolio2-perm", "v2 (Part 9)", COL[0], "o")):
            r = CH.toy_load(L, suite)
            if r is None:
                continue
            for fn, v in r["fns"].items():
                x = NR["nets_best"][fn]; y = TH.nstar(r["ns"], mean_err(v["err"]))
                x = x if np.isfinite(x) else NEV; y = y if np.isfinite(y) else NEV
                ctl = fn in P9_CONTROLS
                ax.scatter([x], [y], s=20, marker="s" if ctl else mk, facecolor=(fc if not ctl else ("white" if fc == "white" else COL[3])),
                           edgecolor=(COL[0] if fc == "white" else "white") if not ctl else (COL[3] if fc == "white" else "white"),
                           linewidth=0.8, zorder=3 if fc == "white" else 4)
        ax.axhline(NEV, color="#c8c8c8", lw=0.5, zorder=0); ax.text(lo * 1.15, NEV * 0.82, "never", fontsize=6, color=INK2, va="top")
        ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(lo, hi); ax.set_ylim(lo, hi); ax.set_aspect("equal")
        ax.set_title(title, loc="left", fontsize=7.2)
        ax.set_xlabel(r"$n^*$ of nets_best")
    axs[0].set_ylabel(r"$n^*$ of the discrete learner")
    h = [Line2D([], [], marker="o", ls="", mfc=COL[0], mec="white", ms=5, label="v2 = hyb_portfolio2, sum-structured target"),
         Line2D([], [], marker="o", ls="", mfc="white", mec=COL[0], ms=5, label="v1 = hyb_portfolio, same targets"),
         Line2D([], [], marker="s", ls="", mfc=COL[3], mec="white", ms=5, label="v2, control (v1: hollow square)"),
         Line2D([], [], color=INK2, ls="--", lw=0.8, label="equal data"), Line2D([], [], color="#a8a8a8", ls=":", lw=0.6, label="4x less data")]
    fig.legend(handles=h, loc="lower center", ncol=3, bbox_to_anchor=(0.5, -0.01), columnspacing=1.0, handletextpad=0.3)
    fig.tight_layout(rect=(0, 0.17, 1, 1), w_pad=0.6)
    save(fig, "fig_p9_toy.pdf")


# ---- F8: Part 9 images, QuickDraw held-out sets ------------------------------------------------------------------------
P9_STY = {"hyb_portfolio2": (COL[0], "o", "-", "v2 = hyb_portfolio2"), "hyb_portfolio": (COL[6], "o", ":", "v1 = hyb_portfolio"),
          "mlp_strong": (COL[1], "s", "--", "mlp_strong (3 x 256-256)"), "mlp_wide": (COL[3], "s", "-.", "mlp_wide (3 x 512-512)"),
          "mlp_xl": (COL[7], "P", "", "mlp_xl (3 x 1024-1024, CPU-matched)"), "mlp_pool": (COL[2], "^", "", "mlp_pool (MLP on [x, pooled sums])"),
          "cnn": (INK2, "x", "", "cnn on unpermuted pixels (context)"), "hgb": (COL[4], "D", ":", "hgb")}


def fig8():
    fig, axs = plt.subplots(1, 2, figsize=(TEXTW, 3.05), sharey=True)
    allv = []                                                   # shared y-axis: limits over both panels
    for ax, (ds, name) in zip(axs, (("qd_a", "(a) QuickDraw qd_a (held out)"), ("qd_b", "(b) QuickDraw qd_b (held out)"))):
        for L, (col, mk, ls, lab) in P9_STY.items():
            if CH.load(L, ds) is None:
                continue
            n, e = curve_mean(L, ds); ok = np.isfinite(e); n, e = n[ok], e[ok]
            if not len(e):
                continue
            ax.plot(n, e, color=col, marker=mk, ls=ls if ls else "none", ms={"x": 5, "P": 6.5}.get(mk, 4.2), mec="white" if mk not in ("x", "P") else col,
                    mew=0.4 if mk not in ("x",) else 1.0, lw=1.3, zorder=5 if mk in ("P", "x", "^") else (4 if L == "hyb_portfolio2" else 3), label=lab)
            allv += list(e)
        ax.set_xscale("log"); ax.set_yscale("log")
        ax.axvspan(9e3, 7.5e4, color="#f3f3f3", zorder=0, lw=0)
        ax.text(1.0e4, 0.96, "Q2: n >= 10000", transform=matplotlib.transforms.blended_transform_factory(ax.transData, ax.transAxes),
                fontsize=6.3, color=INK2, va="top")
        ax.set_xlim(70, 8e4)
        ax.set_title(name, loc="left"); ax.set_xlabel("training-set size n")
        ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda v, _: f"{100 * v:g}%"))
        ax.yaxis.set_minor_formatter(matplotlib.ticker.FuncFormatter(lambda v, _: f"{100 * v:g}%" if round(v * 100, 6) in (12, 15, 20, 30, 40, 50) else ""))
    axs[0].set_ylim(np.nanmin(allv) * 0.9, np.nanmax(allv) * 1.08)
    axs[0].set_ylabel("test error (seed mean; seed 0 at n >= 30000)")
    h, l = axs[0].get_legend_handles_labels()
    fig.legend(h, l, loc="lower center", ncol=4, bbox_to_anchor=(0.5, -0.01), columnspacing=1.0, handlelength=2.2, fontsize=6.5)
    fig.tight_layout(rect=(0, 0.14, 1, 1), w_pad=0.8)
    save(fig, "fig_p9_images.pdf")


if __name__ == "__main__":
    os.makedirs(FIG, exist_ok=True)
    which = sys.argv[1:] or ["1", "2", "3", "4", "5", "6", "7", "8"]
    for w in which:
        out = {"1": fig1, "2": fig2, "3": fig3, "4": fig4, "5": fig5, "6": fig6, "7": fig7, "8": fig8}[w]()
        if out:
            print(out)
